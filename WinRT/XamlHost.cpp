#include "pch.h"
#include "XamlHost.h"
#include "ControlWrappers.h"

// ============================================================================
// XamlHost Implementation
// ============================================================================

XamlHost::XamlHost()
    : m_refCount(1)
    , m_parentHwnd(nullptr)
    , m_islandHwnd(nullptr)
    , m_isInitialized(false)
{
    TRACE(L"XamlHost created");
}

XamlHost::~XamlHost()
{
    Close();
    TRACE(L"XamlHost destroyed");
}

// ============================================================================
// IUnknown Implementation
// ============================================================================

STDMETHODIMP XamlHost::QueryInterface(REFIID riid, void** ppv)
{
    if (!ppv)
        return E_POINTER;

    if (riid == IID_IUnknown || riid == IID_IDispatch)
    {
        *ppv = static_cast<IDispatch*>(this);
        AddRef();
        return S_OK;
    }

    *ppv = nullptr;
    return E_NOINTERFACE;
}

STDMETHODIMP_(ULONG) XamlHost::AddRef() noexcept
{
    return m_refCount.fetch_add(1, std::memory_order_relaxed) + 1;
}

STDMETHODIMP_(ULONG) XamlHost::Release() noexcept
{
    ULONG count = m_refCount.fetch_sub(1, std::memory_order_acq_rel) - 1;
    if (count == 0)
    {
        delete this;
    }
    return count;
}

// ============================================================================
// IDispatch Implementation
// ============================================================================

STDMETHODIMP XamlHost::GetTypeInfoCount(UINT* pctinfo)
{
    if (!pctinfo)
        return E_POINTER;
    *pctinfo = 0;  // No type info (yet - TODO: add type library)
    return S_OK;
}

STDMETHODIMP XamlHost::GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo)
{
    // TODO: Implement type library support
    return E_NOTIMPL;
}

STDMETHODIMP XamlHost::GetIDsOfNames(REFIID riid, LPOLESTR* rgszNames, UINT cNames,
                                      LCID lcid, DISPID* rgDispId)
{
    if (!rgszNames || !rgDispId)
        return E_POINTER;

    for (UINT i = 0; i < cNames; i++)
    {
        std::wstring_view name(rgszNames[i]);

        if (_wcsicmp(name.data(), L"Initialize") == 0)
            rgDispId[i] = CYCB_INITIALIZE;
        else if (_wcsicmp(name.data(), L"LoadXaml") == 0)
            rgDispId[i] = CYCB_LOADXAML;
        else if (_wcsicmp(name.data(), L"GetElement") == 0)
            rgDispId[i] = CYCB_GETELEMENT;
        else if (_wcsicmp(name.data(), L"SetEventHandler") == 0)
            rgDispId[i] = CYCB_SETEVENTHANDLER;
        else if (_wcsicmp(name.data(), L"RemoveEventHandler") == 0)
            rgDispId[i] = CYCB_REMOVEEVENTHANDLER;
        else if (_wcsicmp(name.data(), L"Resize") == 0)
            rgDispId[i] = CYCB_RESIZE;
        else if (_wcsicmp(name.data(), L"Close") == 0)
            rgDispId[i] = CYCB_CLOSE;
        else if (_wcsicmp(name.data(), L"Hwnd") == 0)
            rgDispId[i] = CYCB_HWND;
        else if (_wcsicmp(name.data(), L"ParentHwnd") == 0)
            rgDispId[i] = CYCB_PARENTHWND;
        else if (_wcsicmp(name.data(), L"IsInitialized") == 0)
            rgDispId[i] = CYCB_ISINITIALIZED;
        else if (_wcsicmp(name.data(), L"GetControl") == 0)
            rgDispId[i] = CYCB_GETCONTROL;
        else
            rgDispId[i] = CYCB_DEFAULT;  // Unknown
    }

    return S_OK;
}

STDMETHODIMP XamlHost::Invoke(DISPID dispIdMember, REFIID riid, LCID lcid, WORD wFlags,
                               DISPPARAMS* pDispParams, VARIANT* pVarResult,
                               EXCEPINFO* pExcepInfo, UINT* puArgErr)
{
    if (pVarResult)
        VariantInit(pVarResult);

    try
    {
        switch (dispIdMember)
        {
        case CYCB_INITIALIZE:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                HWND hwnd = reinterpret_cast<HWND>(
                    static_cast<LONGLONG>(V_I8(&pDispParams->rgvarg[0])));
                bool result = Initialize(hwnd);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = result ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            break;

        case CYCB_LOADXAML:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring_view xaml(V_BSTR(&pDispParams->rgvarg[0]));
                IDispatch* element = LoadXaml(xaml);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_DISPATCH;
                    V_DISPATCH(pVarResult) = element;
                }
            }
            break;

        case CYCB_GETELEMENT:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring_view name(V_BSTR(&pDispParams->rgvarg[0]));
                IDispatch* element = GetElement(name);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_DISPATCH;
                    V_DISPATCH(pVarResult) = element;
                }
            }
            break;

        case CYCB_SETEVENTHANDLER:
            if (pDispParams && pDispParams->cArgs >= 3)
            {
                // Args are in reverse order
                std::wstring_view elemName(V_BSTR(&pDispParams->rgvarg[2]));
                std::wstring_view eventName(V_BSTR(&pDispParams->rgvarg[1]));
                LONGLONG callback = V_I8(&pDispParams->rgvarg[0]);
                bool result = SetEventHandler(elemName, eventName, callback);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = result ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            break;

        case CYCB_REMOVEEVENTHANDLER:
            if (pDispParams && pDispParams->cArgs >= 2)
            {
                std::wstring_view elemName(V_BSTR(&pDispParams->rgvarg[1]));
                std::wstring_view eventName(V_BSTR(&pDispParams->rgvarg[0]));
                bool result = RemoveEventHandler(elemName, eventName);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = result ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            break;

        case CYCB_RESIZE:
            if (pDispParams && pDispParams->cArgs >= 2)
            {
                int width = V_I4(&pDispParams->rgvarg[1]);
                int height = V_I4(&pDispParams->rgvarg[0]);
                Resize(width, height);
            }
            else
            {
                Resize();
            }
            break;

        case CYCB_CLOSE:
            Close();
            break;

        case CYCB_HWND:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_I8;
                    V_I8(pVarResult) = reinterpret_cast<LONGLONG>(m_islandHwnd);
                }
            }
            break;

        case CYCB_PARENTHWND:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_I8;
                    V_I8(pVarResult) = reinterpret_cast<LONGLONG>(m_parentHwnd);
                }
            }
            break;

        case CYCB_ISINITIALIZED:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = m_isInitialized ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            break;

        case CYCB_GETCONTROL:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring_view name(V_BSTR(&pDispParams->rgvarg[0]));
                IDispatch* control = GetControl(name);
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_DISPATCH;
                    V_DISPATCH(pVarResult) = control;
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
        TRACE(L"XamlHost::Invoke WinRT exception: 0x%08X - %s",
              e.code().value, e.message().c_str());
        return e.code();
    }

    return S_OK;
}

// ============================================================================
// Public Methods
// ============================================================================

bool XamlHost::Initialize(HWND parentHwnd)
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    TRACE(L"XamlHost::Initialize - Parent HWND: %p", parentHwnd);

    if (m_isInitialized)
    {
        TRACE(L"Already initialized");
        return true;
    }

    if (!parentHwnd || !IsWindow(parentHwnd))
    {
        TRACE(L"Invalid parent HWND");
        return false;
    }

    m_parentHwnd = parentHwnd;

    try
    {
        // Get the dispatcher queue for thread safety
        m_dispatcherQueue = winrt::DispatcherQueue::GetForCurrentThread();
        if (!m_dispatcherQueue)
        {
            TRACE(L"Warning: No DispatcherQueue on current thread");
        }

        // Create the DesktopWindowXamlSource
        m_xamlSource = winrt::DesktopWindowXamlSource();

        // Get the native interface for attaching to Win32 window
        ComPtr<IDesktopWindowXamlSourceNative> nativeSource;
        HRESULT hr = m_xamlSource.as<::IUnknown>()->QueryInterface(
            IID_PPV_ARGS(&nativeSource));

        if (FAILED(hr) || !nativeSource)
        {
            TRACE(L"Failed to get IDesktopWindowXamlSourceNative: 0x%08X", hr);
            return false;
        }

        // Attach to the parent window (this creates the XAML island as a child)
        TRACE(L"Attaching XAML source to window: %p", parentHwnd);
        hr = nativeSource->AttachToWindow(parentHwnd);
        if (FAILED(hr))
        {
            TRACE(L"AttachToWindow failed: 0x%08X", hr);
            return false;
        }

        // Get the island window handle
        hr = nativeSource->get_WindowHandle(&m_islandHwnd);
        if (FAILED(hr))
        {
            TRACE(L"Failed to get island HWND: 0x%08X", hr);
        }
        else
        {
            TRACE(L"XAML Island HWND: %p", m_islandHwnd);
        }

        // Position the island to fill the parent
        Resize();

        m_isInitialized = true;
        TRACE(L"XamlHost initialized successfully");
        return true;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"Initialize WinRT error: 0x%08X - %s",
              e.code().value, e.message().c_str());
        Close();
        return false;
    }
}

IDispatch* XamlHost::LoadXaml(std::wstring_view xamlString)
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    TRACE(L"XamlHost::LoadXaml");

    if (!m_isInitialized || !m_xamlSource)
    {
        TRACE(L"XAML source not initialized");
        return nullptr;
    }

    try
    {
        // Clear existing content and cache
        ClearElementCache();
        m_eventRegistrations.clear();
        m_rootElement = nullptr;

        // Parse the XAML string
        winrt::hstring xaml(xamlString);
        winrt::IInspectable content = winrt::XamlReader::Load(xaml);

        m_rootElement = content.as<winrt::UIElement>();
        m_xamlSource.Content(m_rootElement);

        TRACE(L"XAML loaded successfully");

        // Return wrapped root element if it's a FrameworkElement
        if (auto fe = m_rootElement.try_as<winrt::FrameworkElement>())
        {
            auto* element = new XamlElement(fe);
            return static_cast<IDispatch*>(element);
        }

        return nullptr;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"LoadXaml error: 0x%08X - %s",
              e.code().value, e.message().c_str());
        return nullptr;
    }
}

IDispatch* XamlHost::GetElement(std::wstring_view name)
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    TRACE(L"XamlHost::GetElement - Name: %.*s",
          static_cast<int>(name.length()), name.data());

    if (!m_rootElement)
        return nullptr;

    // Check cache first
    auto cached = GetCachedElement(name);
    if (cached)
    {
        return new XamlElement(cached);
    }

    // Find element by x:Name
    auto fe = FindElementByName(m_rootElement, name);
    if (fe)
    {
        CacheElement(name, fe);
        return new XamlElement(fe);
    }

    TRACE(L"Element not found: %.*s",
          static_cast<int>(name.length()), name.data());
    return nullptr;
}

IDispatch* XamlHost::GetControl(std::wstring_view name)
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    TRACE(L"XamlHost::GetControl - Name: %.*s",
          static_cast<int>(name.length()), name.data());

    if (!m_rootElement)
        return nullptr;

    // Check cache first
    auto cached = GetCachedElement(name);
    winrt::FrameworkElement fe = cached;

    if (!fe)
    {
        // Find element by x:Name
        fe = FindElementByName(m_rootElement, name);
        if (!fe)
        {
            TRACE(L"Control not found: %.*s",
                  static_cast<int>(name.length()), name.data());
            return nullptr;
        }
        CacheElement(name, fe);
    }

    // Try to create a typed control wrapper
    IControlWrapper* wrapper = CreateControlWrapper(fe);
    if (wrapper)
    {
        TRACE(L"GetControl: Returning typed wrapper for '%.*s'",
              static_cast<int>(name.length()), name.data());
        return static_cast<IDispatch*>(wrapper);
    }

    // Fall back to generic XamlElement
    TRACE(L"GetControl: No typed wrapper, returning XamlElement for '%.*s'",
          static_cast<int>(name.length()), name.data());
    return new XamlElement(fe);
}

bool XamlHost::SetEventHandler(std::wstring_view elementName,
                                std::wstring_view eventName,
                                LONGLONG callbackPtr)
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    TRACE(L"XamlHost::SetEventHandler - Element: %.*s, Event: %.*s",
          static_cast<int>(elementName.length()), elementName.data(),
          static_cast<int>(eventName.length()), eventName.data());

    if (!m_rootElement || callbackPtr == 0)
        return false;

    // Find the element
    auto element = FindElementByName(m_rootElement, elementName);
    if (!element)
    {
        TRACE(L"Element not found: %.*s",
              static_cast<int>(elementName.length()), elementName.data());
        return false;
    }

    // Remove any existing handler for this element/event combo
    RemoveEventHandler(elementName, eventName);

    // Create the event registration
    EventRegistration reg;
    reg.elementName = std::wstring(elementName);
    reg.eventName = std::wstring(eventName);
    reg.dispatcher = std::make_unique<EventDispatcher>(callbackPtr);

    // Attach the event (this sets up the revoker)
    if (!AttachEvent(element, eventName, reg))
    {
        TRACE(L"Failed to attach event: %.*s",
              static_cast<int>(eventName.length()), eventName.data());
        return false;
    }

    // Store the registration (takes ownership)
    m_eventRegistrations.push_back(std::move(reg));

    TRACE(L"Event handler attached successfully");
    return true;
}

bool XamlHost::RemoveEventHandler(std::wstring_view elementName,
                                   std::wstring_view eventName)
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    auto it = std::remove_if(m_eventRegistrations.begin(), m_eventRegistrations.end(),
        [&](const EventRegistration& reg) {
            return reg.elementName == elementName && reg.eventName == eventName;
        });

    if (it != m_eventRegistrations.end())
    {
        m_eventRegistrations.erase(it, m_eventRegistrations.end());
        TRACE(L"Event handler removed: %.*s.%.*s",
              static_cast<int>(elementName.length()), elementName.data(),
              static_cast<int>(eventName.length()), eventName.data());
        return true;
    }

    return false;
}

void XamlHost::Resize()
{
    if (m_parentHwnd && m_islandHwnd)
    {
        RECT rc;
        GetClientRect(m_parentHwnd, &rc);
        Resize(rc.right - rc.left, rc.bottom - rc.top);
    }
}

void XamlHost::Resize(int width, int height)
{
    if (m_islandHwnd)
    {
        SetWindowPos(m_islandHwnd, nullptr, 0, 0, width, height,
                     SWP_NOZORDER | SWP_SHOWWINDOW);
    }
}

void XamlHost::Close()
{
    std::lock_guard<std::recursive_mutex> lock(m_mutex);

    TRACE(L"XamlHost::Close");

    // 1. Clear event handlers first (automatic revocation via revokers)
    m_eventRegistrations.clear();

    // 2. Clear element cache
    ClearElementCache();

    // 3. Clear root element BEFORE closing source
    m_rootElement = nullptr;

    // 4. Close XAML source
    if (m_xamlSource)
    {
        try
        {
            m_xamlSource.Close();
        }
        catch (...)
        {
            TRACE(L"Exception during XAML source close");
        }
        m_xamlSource = nullptr;
    }

    // 5. Clear state
    m_islandHwnd = nullptr;
    m_parentHwnd = nullptr;
    m_dispatcherQueue = nullptr;
    m_isInitialized = false;

    TRACE(L"XamlHost closed");
}

bool XamlHost::HasThreadAccess() const
{
    if (m_dispatcherQueue)
    {
        return m_dispatcherQueue.HasThreadAccess();
    }
    return true;  // Assume yes if no dispatcher queue
}

// ============================================================================
// Internal Methods
// ============================================================================

winrt::FrameworkElement XamlHost::FindElementByName(winrt::DependencyObject const& parent,
                                                     std::wstring_view name)
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

bool XamlHost::AttachEvent(winrt::FrameworkElement const& element,
                            std::wstring_view eventName,
                            EventRegistration& reg)
{
    // Get raw pointer to dispatcher (still owned by reg)
    EventDispatcher* dispatcher = reg.dispatcher.get();

    // Handle common events - using auto_revoke pattern
    if (_wcsicmp(eventName.data(), L"Click") == 0)
    {
        if (auto button = element.try_as<winrt::ButtonBase>())
        {
            auto revoker = button.Click(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"Click handler attached with auto-revoke");
            return true;
        }
    }
    else if (_wcsicmp(eventName.data(), L"TextChanged") == 0)
    {
        if (auto textBox = element.try_as<winrt::TextBox>())
        {
            auto revoker = textBox.TextChanged(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::TextChangedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"TextChanged handler attached with auto-revoke");
            return true;
        }
    }
    else if (_wcsicmp(eventName.data(), L"SelectionChanged") == 0)
    {
        if (auto selector = element.try_as<winrt::Selector>())
        {
            auto revoker = selector.SelectionChanged(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::SelectionChangedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"SelectionChanged handler attached with auto-revoke");
            return true;
        }
    }
    else if (_wcsicmp(eventName.data(), L"Toggled") == 0)
    {
        if (auto toggleSwitch = element.try_as<winrt::ToggleSwitch>())
        {
            auto revoker = toggleSwitch.Toggled(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"Toggled handler attached with auto-revoke");
            return true;
        }
    }
    else if (_wcsicmp(eventName.data(), L"ValueChanged") == 0)
    {
        if (auto slider = element.try_as<winrt::Slider>())
        {
            auto revoker = slider.ValueChanged(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::RangeBaseValueChangedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"ValueChanged handler attached with auto-revoke");
            return true;
        }
    }
    else if (_wcsicmp(eventName.data(), L"Checked") == 0)
    {
        if (auto toggleButton = element.try_as<winrt::ToggleButton>())
        {
            auto revoker = toggleButton.Checked(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"Checked handler attached with auto-revoke");
            return true;
        }
    }
    else if (_wcsicmp(eventName.data(), L"Unchecked") == 0)
    {
        if (auto toggleButton = element.try_as<winrt::ToggleButton>())
        {
            auto revoker = toggleButton.Unchecked(winrt::auto_revoke,
                [dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                    if (dispatcher && dispatcher->IsValid())
                        dispatcher->Invoke();
                });
            reg.revoker = MakeEventRevoker(std::move(revoker));
            TRACE(L"Unchecked handler attached with auto-revoke");
            return true;
        }
    }
    // NOTE: PointerEntered and PointerExited events are temporarily disabled
    // due to WinUI3 PointerEventHandler compatibility issues with auto_revoke.
    // These can be re-enabled with proper token-based event management.
    /*
    else if (_wcsicmp(eventName.data(), L"PointerEntered") == 0)
    {
        // TODO: Implement with manual token management
        TRACE(L"PointerEntered not yet supported");
        return false;
    }
    else if (_wcsicmp(eventName.data(), L"PointerExited") == 0)
    {
        // TODO: Implement with manual token management
        TRACE(L"PointerExited not yet supported");
        return false;
    }
    */
    else if (_wcsicmp(eventName.data(), L"GotFocus") == 0)
    {
        auto revoker = element.GotFocus(winrt::auto_revoke,
            [dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                if (dispatcher && dispatcher->IsValid())
                    dispatcher->Invoke();
            });
        reg.revoker = MakeEventRevoker(std::move(revoker));
        TRACE(L"GotFocus handler attached with auto-revoke");
        return true;
    }
    else if (_wcsicmp(eventName.data(), L"LostFocus") == 0)
    {
        auto revoker = element.LostFocus(winrt::auto_revoke,
            [dispatcher](winrt::IInspectable const&, winrt::RoutedEventArgs const&) {
                if (dispatcher && dispatcher->IsValid())
                    dispatcher->Invoke();
            });
        reg.revoker = MakeEventRevoker(std::move(revoker));
        TRACE(L"LostFocus handler attached with auto-revoke");
        return true;
    }

    TRACE(L"Unsupported event: %.*s",
          static_cast<int>(eventName.length()), eventName.data());
    return false;
}

void XamlHost::ClearElementCache()
{
    m_elementCache.clear();
}

winrt::FrameworkElement XamlHost::GetCachedElement(std::wstring_view name)
{
    std::wstring key(name);
    auto it = m_elementCache.find(key);
    if (it != m_elementCache.end())
    {
        // Try to get strong reference from weak ref
        if (auto element = it->second.element.get())
        {
            it->second.lastAccess = std::chrono::steady_clock::now();
            return element;
        }
        else
        {
            // Element was destroyed, remove from cache
            m_elementCache.erase(it);
        }
    }
    return nullptr;
}

void XamlHost::CacheElement(std::wstring_view name, winrt::FrameworkElement const& element)
{
    CachedElement cache;
    cache.element = winrt::make_weak(element);
    cache.lastAccess = std::chrono::steady_clock::now();
    m_elementCache[std::wstring(name)] = std::move(cache);
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

// ============================================================================
// IUnknown Implementation
// ============================================================================

STDMETHODIMP XamlElement::QueryInterface(REFIID riid, void** ppv)
{
    if (!ppv)
        return E_POINTER;

    if (riid == IID_IUnknown || riid == IID_IDispatch)
    {
        *ppv = static_cast<IDispatch*>(this);
        AddRef();
        return S_OK;
    }

    *ppv = nullptr;
    return E_NOINTERFACE;
}

STDMETHODIMP_(ULONG) XamlElement::AddRef() noexcept
{
    return m_refCount.fetch_add(1, std::memory_order_relaxed) + 1;
}

STDMETHODIMP_(ULONG) XamlElement::Release() noexcept
{
    ULONG count = m_refCount.fetch_sub(1, std::memory_order_acq_rel) - 1;
    if (count == 0)
        delete this;
    return count;
}

// ============================================================================
// IDispatch Implementation
// ============================================================================

STDMETHODIMP XamlElement::GetTypeInfoCount(UINT* pctinfo)
{
    if (!pctinfo)
        return E_POINTER;
    *pctinfo = 0;
    return S_OK;
}

STDMETHODIMP XamlElement::GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo)
{
    return E_NOTIMPL;
}

STDMETHODIMP XamlElement::GetIDsOfNames(REFIID riid, LPOLESTR* rgszNames, UINT cNames,
                                         LCID lcid, DISPID* rgDispId)
{
    if (!rgszNames || !rgDispId)
        return E_POINTER;

    for (UINT i = 0; i < cNames; i++)
    {
        std::wstring_view name(rgszNames[i]);

        if (_wcsicmp(name.data(), L"Name") == 0)
            rgDispId[i] = ELEM_NAME;
        else if (_wcsicmp(name.data(), L"ClassName") == 0)
            rgDispId[i] = ELEM_CLASSNAME;
        else if (_wcsicmp(name.data(), L"Content") == 0)
            rgDispId[i] = ELEM_CONTENT;
        else if (_wcsicmp(name.data(), L"Text") == 0)
            rgDispId[i] = ELEM_TEXT;
        else if (_wcsicmp(name.data(), L"Width") == 0)
            rgDispId[i] = ELEM_WIDTH;
        else if (_wcsicmp(name.data(), L"Height") == 0)
            rgDispId[i] = ELEM_HEIGHT;
        else if (_wcsicmp(name.data(), L"IsEnabled") == 0)
            rgDispId[i] = ELEM_ISENABLED;
        else if (_wcsicmp(name.data(), L"Visibility") == 0)
            rgDispId[i] = ELEM_VISIBILITY;
        else if (_wcsicmp(name.data(), L"GetProperty") == 0)
            rgDispId[i] = ELEM_GETPROPERTY;
        else if (_wcsicmp(name.data(), L"SetProperty") == 0)
            rgDispId[i] = ELEM_SETPROPERTY;
        else if (_wcsicmp(name.data(), L"Focus") == 0)
            rgDispId[i] = ELEM_FOCUS;
        else
            rgDispId[i] = ELEM_DEFAULT;
    }

    return S_OK;
}

STDMETHODIMP XamlElement::Invoke(DISPID dispIdMember, REFIID riid, LCID lcid, WORD wFlags,
                                  DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                  EXCEPINFO* pExcepInfo, UINT* puArgErr)
{
    if (pVarResult)
        VariantInit(pVarResult);

    try
    {
        switch (dispIdMember)
        {
        case ELEM_NAME:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BSTR;
                    V_BSTR(pVarResult) = SysAllocString(GetName().c_str());
                }
            }
            break;

        case ELEM_CLASSNAME:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BSTR;
                    V_BSTR(pVarResult) = SysAllocString(GetClassName().c_str());
                }
            }
            break;

        case ELEM_CONTENT:
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
                    SetContent(std::wstring_view(V_BSTR(&pDispParams->rgvarg[0])));
                }
            }
            break;

        case ELEM_TEXT:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BSTR;
                    V_BSTR(pVarResult) = SysAllocString(GetText().c_str());
                }
            }
            else if (wFlags & DISPATCH_PROPERTYPUT)
            {
                if (pDispParams && pDispParams->cArgs >= 1)
                {
                    SetText(std::wstring_view(V_BSTR(&pDispParams->rgvarg[0])));
                }
            }
            break;

        case ELEM_WIDTH:
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

        case ELEM_HEIGHT:
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

        case ELEM_ISENABLED:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = GetIsEnabled() ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            else if (wFlags & DISPATCH_PROPERTYPUT)
            {
                if (pDispParams && pDispParams->cArgs >= 1)
                {
                    SetIsEnabled(V_BOOL(&pDispParams->rgvarg[0]) == VARIANT_TRUE);
                }
            }
            break;

        case ELEM_VISIBILITY:
            if (wFlags & DISPATCH_PROPERTYGET)
            {
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_I4;
                    V_I4(pVarResult) = GetVisibility();
                }
            }
            else if (wFlags & DISPATCH_PROPERTYPUT)
            {
                if (pDispParams && pDispParams->cArgs >= 1)
                {
                    SetVisibility(V_I4(&pDispParams->rgvarg[0]));
                }
            }
            break;

        case ELEM_GETPROPERTY:
            if (pDispParams && pDispParams->cArgs >= 1)
            {
                std::wstring_view name(V_BSTR(&pDispParams->rgvarg[0]));
                if (pVarResult)
                {
                    *pVarResult = GetProperty(name);
                }
            }
            break;

        case ELEM_SETPROPERTY:
            if (pDispParams && pDispParams->cArgs >= 2)
            {
                std::wstring_view name(V_BSTR(&pDispParams->rgvarg[1]));
                SetProperty(name, pDispParams->rgvarg[0]);
            }
            break;

        case ELEM_FOCUS:
            {
                bool result = Focus();
                if (pVarResult)
                {
                    V_VT(pVarResult) = VT_BOOL;
                    V_BOOL(pVarResult) = result ? VARIANT_TRUE : VARIANT_FALSE;
                }
            }
            break;

        default:
            return DISP_E_MEMBERNOTFOUND;
        }
    }
    catch (const std::exception& e)
    {
        TRACE(L"XamlElement::Invoke exception: %S", e.what());
        return E_FAIL;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"XamlElement::Invoke WinRT exception: 0x%08X", e.code().value);
        return e.code();
    }

    return S_OK;
}

// ============================================================================
// Property Implementations
// ============================================================================

std::wstring XamlElement::GetName() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_element)
        return std::wstring(m_element.Name());
    return L"";
}

std::wstring XamlElement::GetClassName() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_element)
        return std::wstring(winrt::get_class_name(m_element));
    return L"";
}

std::wstring XamlElement::GetContent() const
{
    std::lock_guard<std::mutex> lock(m_mutex);

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

    return L"";
}

void XamlElement::SetContent(std::wstring_view value)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (auto contentControl = m_element.try_as<winrt::ContentControl>())
    {
        contentControl.Content(winrt::box_value(winrt::hstring(value)));
    }
    else if (auto textBlock = m_element.try_as<winrt::TextBlock>())
    {
        textBlock.Text(winrt::hstring(value));
    }
}

std::wstring XamlElement::GetText() const
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (auto textBox = m_element.try_as<winrt::TextBox>())
    {
        return std::wstring(textBox.Text());
    }
    else if (auto textBlock = m_element.try_as<winrt::TextBlock>())
    {
        return std::wstring(textBlock.Text());
    }
    else if (auto passwordBox = m_element.try_as<winrt::PasswordBox>())
    {
        return std::wstring(passwordBox.Password());
    }

    return L"";
}

void XamlElement::SetText(std::wstring_view value)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (auto textBox = m_element.try_as<winrt::TextBox>())
    {
        textBox.Text(winrt::hstring(value));
    }
    else if (auto textBlock = m_element.try_as<winrt::TextBlock>())
    {
        textBlock.Text(winrt::hstring(value));
    }
    else if (auto passwordBox = m_element.try_as<winrt::PasswordBox>())
    {
        passwordBox.Password(winrt::hstring(value));
    }
}

double XamlElement::GetWidth() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_element ? m_element.Width() : 0.0;
}

void XamlElement::SetWidth(double value)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_element)
        m_element.Width(value);
}

double XamlElement::GetHeight() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_element ? m_element.Height() : 0.0;
}

void XamlElement::SetHeight(double value)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_element)
        m_element.Height(value);
}

bool XamlElement::GetIsEnabled() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (auto control = m_element.try_as<winrt::Control>())
    {
        return control.IsEnabled();
    }
    return true;
}

void XamlElement::SetIsEnabled(bool value)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (auto control = m_element.try_as<winrt::Control>())
    {
        control.IsEnabled(value);
    }
}

int XamlElement::GetVisibility() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_element ? static_cast<int>(m_element.Visibility()) : 0;
}

void XamlElement::SetVisibility(int value)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_element)
    {
        m_element.Visibility(static_cast<winrt::Visibility>(value));
    }
}

VARIANT XamlElement::GetProperty(std::wstring_view name) const
{
    std::lock_guard<std::mutex> lock(m_mutex);

    VariantGuard result;

    if (_wcsicmp(name.data(), L"Text") == 0)
    {
        V_VT(result.Get()) = VT_BSTR;
        V_BSTR(result.Get()) = SysAllocString(GetText().c_str());
    }
    else if (_wcsicmp(name.data(), L"IsEnabled") == 0)
    {
        V_VT(result.Get()) = VT_BOOL;
        V_BOOL(result.Get()) = GetIsEnabled() ? VARIANT_TRUE : VARIANT_FALSE;
    }
    else if (_wcsicmp(name.data(), L"IsChecked") == 0)
    {
        if (auto checkBox = m_element.try_as<winrt::CheckBox>())
        {
            auto val = checkBox.IsChecked();
            V_VT(result.Get()) = VT_BOOL;
            V_BOOL(result.Get()) = (val && val.Value()) ? VARIANT_TRUE : VARIANT_FALSE;
        }
    }
    else if (_wcsicmp(name.data(), L"IsOn") == 0)
    {
        if (auto toggleSwitch = m_element.try_as<winrt::ToggleSwitch>())
        {
            V_VT(result.Get()) = VT_BOOL;
            V_BOOL(result.Get()) = toggleSwitch.IsOn() ? VARIANT_TRUE : VARIANT_FALSE;
        }
    }
    else if (_wcsicmp(name.data(), L"Value") == 0)
    {
        if (auto slider = m_element.try_as<winrt::Slider>())
        {
            V_VT(result.Get()) = VT_R8;
            V_R8(result.Get()) = slider.Value();
        }
        else if (auto progressBar = m_element.try_as<winrt::ProgressBar>())
        {
            V_VT(result.Get()) = VT_R8;
            V_R8(result.Get()) = progressBar.Value();
        }
    }
    else if (_wcsicmp(name.data(), L"SelectedIndex") == 0)
    {
        if (auto selector = m_element.try_as<winrt::Selector>())
        {
            V_VT(result.Get()) = VT_I4;
            V_I4(result.Get()) = selector.SelectedIndex();
        }
    }
    else if (_wcsicmp(name.data(), L"Visibility") == 0)
    {
        V_VT(result.Get()) = VT_I4;
        V_I4(result.Get()) = GetVisibility();
    }
    else if (_wcsicmp(name.data(), L"Opacity") == 0)
    {
        V_VT(result.Get()) = VT_R8;
        V_R8(result.Get()) = m_element ? m_element.Opacity() : 1.0;
    }

    return result.Release();
}

void XamlElement::SetProperty(std::wstring_view name, const VARIANT& value)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (_wcsicmp(name.data(), L"Text") == 0)
    {
        if (V_VT(&value) == VT_BSTR)
        {
            SetText(std::wstring_view(V_BSTR(&value)));
        }
    }
    else if (_wcsicmp(name.data(), L"IsEnabled") == 0)
    {
        SetIsEnabled(V_BOOL(&value) == VARIANT_TRUE);
    }
    else if (_wcsicmp(name.data(), L"IsChecked") == 0)
    {
        if (auto checkBox = m_element.try_as<winrt::CheckBox>())
        {
            checkBox.IsChecked(V_BOOL(&value) == VARIANT_TRUE);
        }
    }
    else if (_wcsicmp(name.data(), L"IsOn") == 0)
    {
        if (auto toggleSwitch = m_element.try_as<winrt::ToggleSwitch>())
        {
            toggleSwitch.IsOn(V_BOOL(&value) == VARIANT_TRUE);
        }
    }
    else if (_wcsicmp(name.data(), L"Value") == 0)
    {
        if (auto slider = m_element.try_as<winrt::Slider>())
        {
            slider.Value(V_R8(&value));
        }
        else if (auto progressBar = m_element.try_as<winrt::ProgressBar>())
        {
            progressBar.Value(V_R8(&value));
        }
    }
    else if (_wcsicmp(name.data(), L"SelectedIndex") == 0)
    {
        if (auto selector = m_element.try_as<winrt::Selector>())
        {
            selector.SelectedIndex(V_I4(&value));
        }
    }
    else if (_wcsicmp(name.data(), L"Visibility") == 0)
    {
        SetVisibility(V_I4(&value));
    }
    else if (_wcsicmp(name.data(), L"Opacity") == 0)
    {
        if (m_element)
        {
            m_element.Opacity(V_R8(&value));
        }
    }
}

bool XamlElement::Focus()
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (auto control = m_element.try_as<winrt::Control>())
    {
        return control.Focus(winrt::FocusState::Programmatic);
    }
    return false;
}
