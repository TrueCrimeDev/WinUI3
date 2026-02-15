#include "pch.h"
#include "XamlHost.h"

// ============================================================================
// XamlHost Implementation
// ============================================================================

XamlHost::XamlHost()
    : m_refCount(1)
    , m_parentHwnd(nullptr)
    , m_islandHwnd(nullptr)
{
    TRACE(L"XamlHost created");
}

XamlHost::~XamlHost()
{
    Close();
    TRACE(L"XamlHost destroyed");
}

// IUnknown implementation
STDMETHODIMP XamlHost::QueryInterface(REFIID riid, void** ppv)
{
    if (!ppv) return E_POINTER;
    
    if (riid == IID_IUnknown || riid == IID_IDispatch)
    {
        *ppv = static_cast<IDispatch*>(this);
        AddRef();
        return S_OK;
    }
    
    *ppv = nullptr;
    return E_NOINTERFACE;
}

STDMETHODIMP_(ULONG) XamlHost::AddRef()
{
    return InterlockedIncrement(&m_refCount);
}

STDMETHODIMP_(ULONG) XamlHost::Release()
{
    ULONG count = InterlockedDecrement(&m_refCount);
    if (count == 0)
    {
        delete this;
    }
    return count;
}

// IDispatch implementation
STDMETHODIMP XamlHost::GetTypeInfoCount(UINT* pctinfo)
{
    if (!pctinfo) return E_POINTER;
    *pctinfo = 0;
    return S_OK;
}

STDMETHODIMP XamlHost::GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo)
{
    return E_NOTIMPL;
}

STDMETHODIMP XamlHost::GetIDsOfNames(REFIID riid, LPOLESTR* rgszNames, UINT cNames, LCID lcid, DISPID* rgDispId)
{
    if (!rgszNames || !rgDispId) return E_POINTER;
    
    for (UINT i = 0; i < cNames; i++)
    {
        std::wstring name(rgszNames[i]);
        
        if (_wcsicmp(name.c_str(), L"Initialize") == 0)
            rgDispId[i] = DISPID_INITIALIZE;
        else if (_wcsicmp(name.c_str(), L"LoadXaml") == 0)
            rgDispId[i] = DISPID_LOADXAML;
        else if (_wcsicmp(name.c_str(), L"GetElement") == 0)
            rgDispId[i] = DISPID_GETELEMENT;
        else if (_wcsicmp(name.c_str(), L"SetEventHandler") == 0)
            rgDispId[i] = DISPID_SETEVENTHANDLER;
        else if (_wcsicmp(name.c_str(), L"Close") == 0)
            rgDispId[i] = DISPID_CLOSE;
        else if (_wcsicmp(name.c_str(), L"Hwnd") == 0)
            rgDispId[i] = DISPID_HWND;
        else
            rgDispId[i] = DISPID_UNKNOWN;
    }
    
    return S_OK;
}

STDMETHODIMP XamlHost::Invoke(DISPID dispIdMember, REFIID riid, LCID lcid, WORD wFlags, DISPPARAMS* pDispParams, VARIANT* pVarResult, EXCEPINFO* pExcepInfo, UINT* puArgErr)
{
    if (pVarResult) VariantInit(pVarResult);
    
    try
    {
        switch (dispIdMember)
        {
        case DISPID_INITIALIZE:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                HWND hwnd = reinterpret_cast<HWND>(static_cast<LONGLONG>(V_I8(&pDispParams->rgvarg[0])));
                bool result = Initialize(hwnd);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = result ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            break;
            
        case DISPID_LOADXAML:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring xaml(V_BSTR(&pDispParams->rgvarg[0]));
                IDispatch* element = LoadXaml(xaml);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_DISPATCH;
                    V_DISPATCH(pVarResult) = element;
                }
            }
            break;
            
        case DISPID_GETELEMENT:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring name(V_BSTR(&pDispParams->rgvarg[0]));
                IDispatch* element = GetElement(name);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_DISPATCH;
                    V_DISPATCH(pVarResult) = element;
                }
            }
            break;
            
        case DISPID_SETEVENTHANDLER:
            if (pDispParams && pDispParams->cArgs >= 3)
            {
                // Args are in reverse order
                std::wstring elemName(V_BSTR(&pDispParams->rgvarg[2]));
                std::wstring eventName(V_BSTR(&pDispParams->rgvarg[1]));
                LONGLONG callback = V_I8(&pDispParams->rgvarg[0]);
                SetEventHandler(elemName, eventName, callback);
            }
            break;
            
        case DISPID_CLOSE:
            Close();
            break;
            
        case DISPID_HWND:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_I8;
                    V_I8(pVarResult) = reinterpret_cast<LONGLONG>(m_islandHwnd);
                }
            }
            break;
            
        default:
            return DISP_E_MEMBERNOTFOUND;
        }
    }
    catch (const std::exception& e)
    {
        TRACE(L"XamlHost::Invoke exception: %S", e.what());
        return E_FAIL;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"XamlHost::Invoke WinRT exception: %s", e.message().c_str());
        return e.code();
    }
    
    return S_OK;
}

bool XamlHost::Initialize(HWND parentHwnd)
{
    TRACE(L"XamlHost::Initialize - Parent HWND: %p", parentHwnd);
    
    if (!parentHwnd || !IsWindow(parentHwnd))
    {
        TRACE(L"Invalid parent HWND");
        return false;
    }
    
    m_parentHwnd = parentHwnd;
    
    try
    {
        // Create the DesktopWindowXamlSource
        m_xamlSource = winrt::DesktopWindowXamlSource();
        
        // Get the interop interface to attach to our window
        auto interop = m_xamlSource.as<IDesktopWindowXamlSourceNative>();
        
        HRESULT hr = interop->AttachToWindow(parentHwnd);
        if (FAILED(hr))
        {
            TRACE(L"AttachToWindow failed: 0x%08X", hr);
            return false;
        }
        
        // Get the XAML island HWND
        hr = interop->get_WindowHandle(&m_islandHwnd);
        if (FAILED(hr))
        {
            TRACE(L"get_WindowHandle failed: 0x%08X", hr);
            return false;
        }
        
        TRACE(L"XAML Island HWND: %p", m_islandHwnd);
        
        // Position the island to fill the parent
        RECT rc;
        GetClientRect(parentHwnd, &rc);
        SetWindowPos(m_islandHwnd, nullptr, 0, 0, rc.right - rc.left, rc.bottom - rc.top,
            SWP_NOZORDER | SWP_SHOWWINDOW);
        
        return true;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"Initialize WinRT error: 0x%08X - %s", e.code().value, e.message().c_str());
        return false;
    }
}

IDispatch* XamlHost::LoadXaml(const std::wstring& xamlString)
{
    TRACE(L"XamlHost::LoadXaml");
    
    if (!m_xamlSource)
    {
        TRACE(L"XAML source not initialized");
        return nullptr;
    }
    
    try
    {
        // Parse the XAML string
        auto xamlReader = winrt::XamlReader();
        winrt::IInspectable content = xamlReader.Load(winrt::hstring(xamlString));
        
        m_rootElement = content.as<winrt::UIElement>();
        m_xamlSource.Content(m_rootElement);
        
        TRACE(L"XAML loaded successfully");
        
        // Return wrapped root element
        auto fe = m_rootElement.try_as<winrt::FrameworkElement>();
        if (fe)
        {
            return new XamlElement(fe);
        }
        
        return nullptr;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"LoadXaml error: 0x%08X - %s", e.code().value, e.message().c_str());
        return nullptr;
    }
}

IDispatch* XamlHost::GetElement(const std::wstring& name)
{
    TRACE(L"XamlHost::GetElement - Name: %s", name.c_str());
    
    if (!m_rootElement)
        return nullptr;
    
    // Check cache first
    auto it = m_elements.find(name);
    if (it != m_elements.end())
    {
        return new XamlElement(it->second);
    }
    
    // Find element by x:Name
    auto fe = FindElementByName(m_rootElement, name);
    if (fe)
    {
        m_elements[name] = fe;
        return new XamlElement(fe);
    }
    
    return nullptr;
}

winrt::FrameworkElement XamlHost::FindElementByName(winrt::DependencyObject const& parent, const std::wstring& name)
{
    // Check if parent matches
    if (auto fe = parent.try_as<winrt::FrameworkElement>())
    {
        if (fe.Name() == winrt::hstring(name))
            return fe;
    }
    
    // Search children
    int childCount = winrt::VisualTreeHelper::GetChildrenCount(parent);
    for (int i = 0; i < childCount; i++)
    {
        auto child = winrt::VisualTreeHelper::GetChild(parent, i);
        auto result = FindElementByName(child, name);
        if (result)
            return result;
    }
    
    return nullptr;
}

void XamlHost::SetEventHandler(const std::wstring& elementName, const std::wstring& eventName, LONGLONG callbackPtr)
{
    TRACE(L"XamlHost::SetEventHandler - Element: %s, Event: %s", elementName.c_str(), eventName.c_str());
    
    if (!m_rootElement)
        return;
    
    auto element = FindElementByName(m_rootElement, elementName);
    if (!element)
    {
        TRACE(L"Element not found: %s", elementName.c_str());
        return;
    }
    
    // Create event dispatcher
    auto dispatcher = std::make_unique<EventDispatcher>(callbackPtr);
    AttachEvent(element, eventName, dispatcher.get());
    
    // Store registration
    EventRegistration reg;
    reg.elementName = elementName;
    reg.eventName = eventName;
    reg.dispatcher = std::move(dispatcher);
    m_eventRegistrations.push_back(std::move(reg));
}

void XamlHost::AttachEvent(winrt::FrameworkElement const& element, const std::wstring& eventName, EventDispatcher* dispatcher)
{
    // Handle common events
    if (_wcsicmp(eventName.c_str(), L"Click") == 0)
    {
        if (auto button = element.try_as<winrt::Microsoft::UI::Xaml::Controls::Primitives::ButtonBase>())
        {
            button.Click([dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                dispatcher->Invoke();
            });
            TRACE(L"Click handler attached");
        }
    }
    else if (_wcsicmp(eventName.c_str(), L"TextChanged") == 0)
    {
        if (auto textBox = element.try_as<winrt::TextBox>())
        {
            textBox.TextChanged([dispatcher](winrt::IInspectable const&, winrt::TextChangedEventArgs const&) {
                dispatcher->Invoke();
            });
            TRACE(L"TextChanged handler attached");
        }
    }
    else if (_wcsicmp(eventName.c_str(), L"SelectionChanged") == 0)
    {
        if (auto selector = element.try_as<winrt::Microsoft::UI::Xaml::Controls::Primitives::Selector>())
        {
            selector.SelectionChanged([dispatcher](winrt::IInspectable const&, winrt::SelectionChangedEventArgs const&) {
                dispatcher->Invoke();
            });
            TRACE(L"SelectionChanged handler attached");
        }
    }
    else if (_wcsicmp(eventName.c_str(), L"Toggled") == 0)
    {
        if (auto toggleSwitch = element.try_as<winrt::ToggleSwitch>())
        {
            toggleSwitch.Toggled([dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                dispatcher->Invoke();
            });
            TRACE(L"Toggled handler attached");
        }
    }
    else if (_wcsicmp(eventName.c_str(), L"ValueChanged") == 0)
    {
        if (auto slider = element.try_as<winrt::Slider>())
        {
            slider.ValueChanged([dispatcher](winrt::IInspectable const&, winrt::Microsoft::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs const&) {
                dispatcher->Invoke();
            });
            TRACE(L"ValueChanged handler attached");
        }
    }
}

void XamlHost::Close()
{
    TRACE(L"XamlHost::Close");
    
    m_eventRegistrations.clear();
    m_elements.clear();
    
    if (m_xamlSource)
    {
        m_xamlSource.Close();
        m_xamlSource = nullptr;
    }
    
    m_rootElement = nullptr;
    m_islandHwnd = nullptr;
}

// ============================================================================
// XamlElement Implementation
// ============================================================================

XamlElement::XamlElement(winrt::FrameworkElement const& element)
    : m_refCount(1)
    , m_element(element)
{
    TRACE(L"XamlElement created: %s", element.Name().c_str());
}

XamlElement::~XamlElement()
{
    TRACE(L"XamlElement destroyed");
}

STDMETHODIMP XamlElement::QueryInterface(REFIID riid, void** ppv)
{
    if (!ppv) return E_POINTER;
    
    if (riid == IID_IUnknown || riid == IID_IDispatch)
    {
        *ppv = static_cast<IDispatch*>(this);
        AddRef();
        return S_OK;
    }
    
    *ppv = nullptr;
    return E_NOINTERFACE;
}

STDMETHODIMP_(ULONG) XamlElement::AddRef()
{
    return InterlockedIncrement(&m_refCount);
}

STDMETHODIMP_(ULONG) XamlElement::Release()
{
    ULONG count = InterlockedDecrement(&m_refCount);
    if (count == 0)
        delete this;
    return count;
}

STDMETHODIMP XamlElement::GetTypeInfoCount(UINT* pctinfo)
{
    if (!pctinfo) return E_POINTER;
    *pctinfo = 0;
    return S_OK;
}

STDMETHODIMP XamlElement::GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo)
{
    return E_NOTIMPL;
}

STDMETHODIMP XamlElement::GetIDsOfNames(REFIID riid, LPOLESTR* rgszNames, UINT cNames, LCID lcid, DISPID* rgDispId)
{
    if (!rgszNames || !rgDispId) return E_POINTER;
    
    for (UINT i = 0; i < cNames; i++)
    {
        std::wstring name(rgszNames[i]);
        
        if (_wcsicmp(name.c_str(), L"Name") == 0)
            rgDispId[i] = DISPID_NAME;
        else if (_wcsicmp(name.c_str(), L"Content") == 0)
            rgDispId[i] = DISPID_CONTENT;
        else if (_wcsicmp(name.c_str(), L"Width") == 0)
            rgDispId[i] = DISPID_WIDTH;
        else if (_wcsicmp(name.c_str(), L"Height") == 0)
            rgDispId[i] = DISPID_HEIGHT;
        else if (_wcsicmp(name.c_str(), L"GetProperty") == 0)
            rgDispId[i] = DISPID_GETPROPERTY;
        else if (_wcsicmp(name.c_str(), L"SetProperty") == 0)
            rgDispId[i] = DISPID_SETPROPERTY;
        else if (_wcsicmp(name.c_str(), L"Focus") == 0)
            rgDispId[i] = DISPID_FOCUS;
        else
            rgDispId[i] = DISPID_UNKNOWN;
    }
    
    return S_OK;
}

STDMETHODIMP XamlElement::Invoke(DISPID dispIdMember, REFIID riid, LCID lcid, WORD wFlags, DISPPARAMS* pDispParams, VARIANT* pVarResult, EXCEPINFO* pExcepInfo, UINT* puArgErr)
{
    if (pVarResult) VariantInit(pVarResult);
    
    try
    {
        switch (dispIdMember)
        {
        case DISPID_NAME:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BSTR;
                    V_BSTR(pVarResult) = SysAllocString(GetName().c_str());
                }
            }
            break;
            
        case DISPID_CONTENT:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BSTR;
                    V_BSTR(pVarResult) = SysAllocString(GetContent().c_str());
                }
            }
            else if (wFlags & DISPATCH_PROPERTYPUT)
            {
                if (pDispParams && pDispParams->cArgs >= 1)
                {
                    SetContent(std::wstring(V_BSTR(&pDispParams->rgvarg[0])));
                }
            }
            break;
            
        case DISPID_WIDTH:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_R8;
                    V_R8(pVarResult) = GetWidth();
                }
            }
            else if (wFlags & DISPATCH_PROPERTYPUT)
            {
                if (pDispParams && pDispParams->cArgs >= 1)
                {
                    SetWidth(V_R8(&pDispParams->rgvarg[0]));
                }
            }
            break;
            
        case DISPID_HEIGHT:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_R8;
                    V_R8(pVarResult) = GetHeight();
                }
            }
            else if (wFlags & DISPATCH_PROPERTYPUT)
            {
                if (pDispParams && pDispParams->cArgs >= 1)
                {
                    SetHeight(V_R8(&pDispParams->rgvarg[0]));
                }
            }
            break;
            
        case DISPID_GETPROPERTY:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring name(V_BSTR(&pDispParams->rgvarg[0]));
                if (pVarResult)
                {
                    *pVarResult = GetProperty(name);
                }
            }
            break;
            
        case DISPID_SETPROPERTY:
            if (pDispParams && pDispParams->cArgs >= 2)
            {
                std::wstring name(V_BSTR(&pDispParams->rgvarg[1]));
                SetProperty(name, pDispParams->rgvarg[0]);
            }
            break;
            
        case DISPID_FOCUS:
            Focus();
            break;
            
        default:
            return DISP_E_MEMBERNOTFOUND;
        }
    }
    catch (...)
    {
        return E_FAIL;
    }
    
    return S_OK;
}

std::wstring XamlElement::GetName() const
{
    if (m_element)
        return std::wstring(m_element.Name());
    return L"";
}

std::wstring XamlElement::GetContent() const
{
    if (auto contentControl = m_element.try_as<winrt::ContentControl>())
    {
        auto content = contentControl.Content();
        if (auto str = content.try_as<winrt::hstring>())
            return std::wstring(*str);
    }
    else if (auto textBlock = m_element.try_as<winrt::TextBlock>())
    {
        return std::wstring(textBlock.Text());
    }
    else if (auto textBox = m_element.try_as<winrt::TextBox>())
    {
        return std::wstring(textBox.Text());
    }
    return L"";
}

void XamlElement::SetContent(const std::wstring& value)
{
    if (auto contentControl = m_element.try_as<winrt::ContentControl>())
    {
        contentControl.Content(winrt::box_value(winrt::hstring(value)));
    }
    else if (auto textBlock = m_element.try_as<winrt::TextBlock>())
    {
        textBlock.Text(winrt::hstring(value));
    }
    else if (auto textBox = m_element.try_as<winrt::TextBox>())
    {
        textBox.Text(winrt::hstring(value));
    }
}

double XamlElement::GetWidth() const
{
    if (m_element)
        return m_element.Width();
    return 0;
}

void XamlElement::SetWidth(double value)
{
    if (m_element)
        m_element.Width(value);
}

double XamlElement::GetHeight() const
{
    if (m_element)
        return m_element.Height();
    return 0;
}

void XamlElement::SetHeight(double value)
{
    if (m_element)
        m_element.Height(value);
}

VARIANT XamlElement::GetProperty(const std::wstring& name)
{
    VARIANT result;
    VariantInit(&result);
    
    if (_wcsicmp(name.c_str(), L"Text") == 0)
    {
        if (auto textBox = m_element.try_as<winrt::TextBox>())
        {
            V_VT(&result) = VT_BSTR;
            V_BSTR(&result) = SysAllocString(textBox.Text().c_str());
        }
    }
    else if (_wcsicmp(name.c_str(), L"IsEnabled") == 0)
    {
        if (auto control = m_element.try_as<winrt::Control>())
        {
            V_VT(&result) = VT_BOOL;
            V_BOOL(&result) = control.IsEnabled() ? VARIANT_TRUE : VARIANT_FALSE;
        }
    }
    else if (_wcsicmp(name.c_str(), L"IsChecked") == 0)
    {
        if (auto checkBox = m_element.try_as<winrt::CheckBox>())
        {
            auto val = checkBox.IsChecked();
            V_VT(&result) = VT_BOOL;
            V_BOOL(&result) = (val && val.Value()) ? VARIANT_TRUE : VARIANT_FALSE;
        }
    }
    else if (_wcsicmp(name.c_str(), L"IsOn") == 0)
    {
        if (auto toggleSwitch = m_element.try_as<winrt::ToggleSwitch>())
        {
            V_VT(&result) = VT_BOOL;
            V_BOOL(&result) = toggleSwitch.IsOn() ? VARIANT_TRUE : VARIANT_FALSE;
        }
    }
    else if (_wcsicmp(name.c_str(), L"Value") == 0)
    {
        if (auto slider = m_element.try_as<winrt::Slider>())
        {
            V_VT(&result) = VT_R8;
            V_R8(&result) = slider.Value();
        }
    }
    else if (_wcsicmp(name.c_str(), L"SelectedIndex") == 0)
    {
        if (auto selector = m_element.try_as<winrt::Microsoft::UI::Xaml::Controls::Primitives::Selector>())
        {
            V_VT(&result) = VT_I4;
            V_I4(&result) = selector.SelectedIndex();
        }
    }
    else if (_wcsicmp(name.c_str(), L"Visibility") == 0)
    {
        V_VT(&result) = VT_I4;
        V_I4(&result) = static_cast<int>(m_element.Visibility());
    }
    
    return result;
}

void XamlElement::SetProperty(const std::wstring& name, const VARIANT& value)
{
    if (_wcsicmp(name.c_str(), L"Text") == 0)
    {
        if (auto textBox = m_element.try_as<winrt::TextBox>())
        {
            if (V_VT(&value) == VT_BSTR)
                textBox.Text(winrt::hstring(V_BSTR(&value)));
        }
    }
    else if (_wcsicmp(name.c_str(), L"IsEnabled") == 0)
    {
        if (auto control = m_element.try_as<winrt::Control>())
        {
            control.IsEnabled(V_BOOL(&value) == VARIANT_TRUE);
        }
    }
    else if (_wcsicmp(name.c_str(), L"IsChecked") == 0)
    {
        if (auto checkBox = m_element.try_as<winrt::CheckBox>())
        {
            checkBox.IsChecked(V_BOOL(&value) == VARIANT_TRUE);
        }
    }
    else if (_wcsicmp(name.c_str(), L"IsOn") == 0)
    {
        if (auto toggleSwitch = m_element.try_as<winrt::ToggleSwitch>())
        {
            toggleSwitch.IsOn(V_BOOL(&value) == VARIANT_TRUE);
        }
    }
    else if (_wcsicmp(name.c_str(), L"Value") == 0)
    {
        if (auto slider = m_element.try_as<winrt::Slider>())
        {
            slider.Value(V_R8(&value));
        }
    }
    else if (_wcsicmp(name.c_str(), L"SelectedIndex") == 0)
    {
        if (auto selector = m_element.try_as<winrt::Microsoft::UI::Xaml::Controls::Primitives::Selector>())
        {
            selector.SelectedIndex(V_I4(&value));
        }
    }
    else if (_wcsicmp(name.c_str(), L"Visibility") == 0)
    {
        m_element.Visibility(static_cast<winrt::Visibility>(V_I4(&value)));
    }
}

void XamlElement::Focus()
{
    if (auto control = m_element.try_as<winrt::Control>())
    {
        control.Focus(winrt::FocusState::Programmatic);
    }
}
