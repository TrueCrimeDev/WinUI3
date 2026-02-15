#include "pch.h"
#include "PropertyReflection.h"

namespace PropertyReflection
{
    // ========================================================================
    // Type Conversion Utilities
    // ========================================================================

    winrt::IInspectable VariantToInspectable(const VARIANT& var)
    {
        switch (V_VT(&var))
        {
        case VT_EMPTY:
        case VT_NULL:
            return nullptr;

        case VT_BOOL:
            return winrt::box_value(V_BOOL(&var) != VARIANT_FALSE);

        case VT_I1:
        case VT_I2:
        case VT_I4:
        case VT_INT:
            {
                VARIANT converted;
                VariantInit(&converted);
                if (SUCCEEDED(VariantChangeType(&converted, &var, 0, VT_I4)))
                    return winrt::box_value(V_I4(&converted));
            }
            break;

        case VT_UI1:
        case VT_UI2:
        case VT_UI4:
        case VT_UINT:
            {
                VARIANT converted;
                VariantInit(&converted);
                if (SUCCEEDED(VariantChangeType(&converted, &var, 0, VT_UI4)))
                    return winrt::box_value(static_cast<uint32_t>(V_UI4(&converted)));
            }
            break;

        case VT_I8:
            return winrt::box_value(V_I8(&var));

        case VT_UI8:
            return winrt::box_value(static_cast<uint64_t>(V_UI8(&var)));

        case VT_R4:
            return winrt::box_value(static_cast<double>(V_R4(&var)));

        case VT_R8:
            return winrt::box_value(V_R8(&var));

        case VT_BSTR:
            if (V_BSTR(&var))
                return winrt::box_value(winrt::hstring(V_BSTR(&var)));
            return winrt::box_value(winrt::hstring(L""));

        case VT_DISPATCH:
            // Could be a wrapped WinRT object - check for IInspectable
            if (V_DISPATCH(&var))
            {
                winrt::IInspectable* pInsp = nullptr;
                if (SUCCEEDED(V_DISPATCH(&var)->QueryInterface(
                    winrt::guid_of<winrt::IInspectable>(),
                    reinterpret_cast<void**>(&pInsp))))
                {
                    winrt::IInspectable result;
                    winrt::copy_from_abi(result, pInsp);
                    return result;
                }
            }
            break;
        }

        return nullptr;
    }

    VARIANT InspectableToVariant(winrt::IInspectable const& value)
    {
        VARIANT result;
        VariantInit(&result);

        if (!value)
        {
            V_VT(&result) = VT_EMPTY;
            return result;
        }

        // Try common types
        if (auto b = value.try_as<winrt::IReference<bool>>())
        {
            V_VT(&result) = VT_BOOL;
            V_BOOL(&result) = b.Value() ? VARIANT_TRUE : VARIANT_FALSE;
            return result;
        }

        if (auto i = value.try_as<winrt::IReference<int32_t>>())
        {
            V_VT(&result) = VT_I4;
            V_I4(&result) = i.Value();
            return result;
        }

        if (auto d = value.try_as<winrt::IReference<double>>())
        {
            V_VT(&result) = VT_R8;
            V_R8(&result) = d.Value();
            return result;
        }

        if (auto f = value.try_as<winrt::IReference<float>>())
        {
            V_VT(&result) = VT_R8;
            V_R8(&result) = static_cast<double>(f.Value());
            return result;
        }

        // Try hstring
        if (auto str = value.try_as<winrt::hstring>())
        {
            V_VT(&result) = VT_BSTR;
            V_BSTR(&result) = SysAllocString(str->c_str());
            return result;
        }

        // Try to get string representation
        try
        {
            auto str = winrt::unbox_value<winrt::hstring>(value);
            V_VT(&result) = VT_BSTR;
            V_BSTR(&result) = SysAllocString(str.c_str());
            return result;
        }
        catch (...) {}

        // Return type name as string for unknown types
        auto typeName = GetTypeName(value);
        V_VT(&result) = VT_BSTR;
        V_BSTR(&result) = SysAllocString(typeName.c_str());
        return result;
    }

    std::wstring GetTypeName(winrt::IInspectable const& obj)
    {
        if (!obj)
            return L"null";

        try
        {
            auto className = winrt::get_class_name(obj);
            return std::wstring(className);
        }
        catch (...)
        {
            return L"Unknown";
        }
    }

    // ========================================================================
    // Property Access Implementation
    // ========================================================================

    VARIANT GetProperty(winrt::DependencyObject const& obj, std::wstring_view propertyName)
    {
        VARIANT result;
        VariantInit(&result);

        if (!obj)
            return result;

        // Try to find the DependencyProperty
        auto dp = FindDependencyProperty(obj, propertyName);
        if (dp)
        {
            try
            {
                auto value = obj.GetValue(dp);
                return InspectableToVariant(value);
            }
            catch (...)
            {
                TRACE(L"GetProperty: Failed to get value for '%.*s'",
                      static_cast<int>(propertyName.length()), propertyName.data());
            }
        }

        // Try common properties via direct access
        if (auto elem = obj.try_as<winrt::FrameworkElement>())
        {
            if (propertyName == L"Width")
            {
                V_VT(&result) = VT_R8;
                V_R8(&result) = Common::GetWidth(elem);
                return result;
            }
            if (propertyName == L"Height")
            {
                V_VT(&result) = VT_R8;
                V_R8(&result) = Common::GetHeight(elem);
                return result;
            }
            if (propertyName == L"ActualWidth")
            {
                V_VT(&result) = VT_R8;
                V_R8(&result) = Common::GetActualWidth(elem);
                return result;
            }
            if (propertyName == L"ActualHeight")
            {
                V_VT(&result) = VT_R8;
                V_R8(&result) = Common::GetActualHeight(elem);
                return result;
            }
            if (propertyName == L"Name")
            {
                V_VT(&result) = VT_BSTR;
                V_BSTR(&result) = SysAllocString(Common::GetName(elem).c_str());
                return result;
            }
        }

        if (auto ctrl = obj.try_as<winrt::Control>())
        {
            if (propertyName == L"IsEnabled")
            {
                V_VT(&result) = VT_BOOL;
                V_BOOL(&result) = Common::GetIsEnabled(ctrl) ? VARIANT_TRUE : VARIANT_FALSE;
                return result;
            }
            if (propertyName == L"FontSize")
            {
                V_VT(&result) = VT_R8;
                V_R8(&result) = Common::GetFontSize(ctrl);
                return result;
            }
        }

        if (auto cc = obj.try_as<winrt::ContentControl>())
        {
            if (propertyName == L"Content")
            {
                V_VT(&result) = VT_BSTR;
                V_BSTR(&result) = SysAllocString(Common::GetContent(cc).c_str());
                return result;
            }
        }

        if (auto tb = obj.try_as<winrt::TextBlock>())
        {
            if (propertyName == L"Text")
            {
                V_VT(&result) = VT_BSTR;
                V_BSTR(&result) = SysAllocString(Common::GetText(tb).c_str());
                return result;
            }
        }

        if (auto textBox = obj.try_as<winrt::TextBox>())
        {
            if (propertyName == L"Text")
            {
                V_VT(&result) = VT_BSTR;
                V_BSTR(&result) = SysAllocString(Common::GetTextBoxText(textBox).c_str());
                return result;
            }
        }

        return result;
    }

    bool SetProperty(winrt::DependencyObject const& obj, std::wstring_view propertyName,
                     const VARIANT& value)
    {
        if (!obj)
            return false;

        // Try to find the DependencyProperty
        auto dp = FindDependencyProperty(obj, propertyName);
        if (dp)
        {
            try
            {
                auto val = VariantToInspectable(value);
                obj.SetValue(dp, val);
                return true;
            }
            catch (...)
            {
                TRACE(L"SetProperty: Failed to set value for '%.*s'",
                      static_cast<int>(propertyName.length()), propertyName.data());
            }
        }

        // Try common properties via direct access
        if (auto elem = obj.try_as<winrt::FrameworkElement>())
        {
            if (propertyName == L"Width" && V_VT(&value) == VT_R8)
            {
                Common::SetWidth(elem, V_R8(&value));
                return true;
            }
            if (propertyName == L"Height" && V_VT(&value) == VT_R8)
            {
                Common::SetHeight(elem, V_R8(&value));
                return true;
            }
        }

        if (auto ctrl = obj.try_as<winrt::Control>())
        {
            if (propertyName == L"IsEnabled" && V_VT(&value) == VT_BOOL)
            {
                Common::SetIsEnabled(ctrl, V_BOOL(&value) != VARIANT_FALSE);
                return true;
            }
            if (propertyName == L"FontSize" && V_VT(&value) == VT_R8)
            {
                Common::SetFontSize(ctrl, V_R8(&value));
                return true;
            }
        }

        if (auto cc = obj.try_as<winrt::ContentControl>())
        {
            if (propertyName == L"Content" && V_VT(&value) == VT_BSTR)
            {
                Common::SetContent(cc, V_BSTR(&value));
                return true;
            }
        }

        if (auto tb = obj.try_as<winrt::TextBlock>())
        {
            if (propertyName == L"Text" && V_VT(&value) == VT_BSTR)
            {
                Common::SetText(tb, V_BSTR(&value));
                return true;
            }
        }

        if (auto textBox = obj.try_as<winrt::TextBox>())
        {
            if (propertyName == L"Text" && V_VT(&value) == VT_BSTR)
            {
                Common::SetTextBoxText(textBox, V_BSTR(&value));
                return true;
            }
        }

        return false;
    }

    bool HasProperty(winrt::DependencyObject const& obj, std::wstring_view propertyName)
    {
        if (!obj)
            return false;

        // Check for DependencyProperty
        auto dp = FindDependencyProperty(obj, propertyName);
        if (dp)
            return true;

        // Check common properties
        static const std::vector<std::wstring> commonProps = {
            L"Width", L"Height", L"ActualWidth", L"ActualHeight",
            L"Name", L"IsEnabled", L"FontSize", L"Content", L"Text"
        };

        for (const auto& prop : commonProps)
        {
            if (prop == propertyName)
                return true;
        }

        return false;
    }

    std::vector<PropertyInfo> GetProperties(winrt::DependencyObject const& obj)
    {
        std::vector<PropertyInfo> props;

        if (!obj)
            return props;

        // Add common FrameworkElement properties
        if (obj.try_as<winrt::FrameworkElement>())
        {
            props.push_back({ L"Width", L"Double", true, true, false });
            props.push_back({ L"Height", L"Double", true, true, false });
            props.push_back({ L"MinWidth", L"Double", true, true, false });
            props.push_back({ L"MinHeight", L"Double", true, true, false });
            props.push_back({ L"MaxWidth", L"Double", true, true, false });
            props.push_back({ L"MaxHeight", L"Double", true, true, false });
            props.push_back({ L"ActualWidth", L"Double", true, false, false });
            props.push_back({ L"ActualHeight", L"Double", true, false, false });
            props.push_back({ L"Name", L"String", true, false, false });
            props.push_back({ L"Tag", L"Object", true, true, false });
        }

        // Add UIElement properties
        if (obj.try_as<winrt::UIElement>())
        {
            props.push_back({ L"Opacity", L"Double", true, true, false });
            props.push_back({ L"Visibility", L"Visibility", true, true, false });
            props.push_back({ L"IsHitTestVisible", L"Boolean", true, true, false });
        }

        // Add Control properties
        if (obj.try_as<winrt::Control>())
        {
            props.push_back({ L"IsEnabled", L"Boolean", true, true, false });
            props.push_back({ L"IsTabStop", L"Boolean", true, true, false });
            props.push_back({ L"TabIndex", L"Int32", true, true, false });
            props.push_back({ L"FontSize", L"Double", true, true, false });
        }

        // Add ContentControl properties
        if (obj.try_as<winrt::ContentControl>())
        {
            props.push_back({ L"Content", L"Object", true, true, false });
        }

        // Add TextBlock properties
        if (obj.try_as<winrt::TextBlock>())
        {
            props.push_back({ L"Text", L"String", true, true, false });
            props.push_back({ L"TextWrapping", L"TextWrapping", true, true, false });
            props.push_back({ L"TextAlignment", L"TextAlignment", true, true, false });
            props.push_back({ L"MaxLines", L"Int32", true, true, false });
        }

        // Add TextBox properties
        if (obj.try_as<winrt::TextBox>())
        {
            props.push_back({ L"Text", L"String", true, true, false });
            props.push_back({ L"PlaceholderText", L"String", true, true, false });
            props.push_back({ L"SelectionStart", L"Int32", true, true, false });
            props.push_back({ L"SelectionLength", L"Int32", true, true, false });
            props.push_back({ L"SelectedText", L"String", true, false, false });
            props.push_back({ L"IsReadOnly", L"Boolean", true, true, false });
            props.push_back({ L"MaxLength", L"Int32", true, true, false });
        }

        return props;
    }

    // ========================================================================
    // Dependency Property Lookup
    // ========================================================================

    winrt::DependencyProperty FindDependencyProperty(
        winrt::DependencyObject const& obj,
        std::wstring_view propertyName)
    {
        if (!obj)
            return nullptr;

        // First check the registry
        auto typeName = GetTypeName(obj);
        auto& registry = PropertyRegistry::Instance();
        auto cached = registry.FindProperty(typeName, propertyName);
        if (cached)
            return *cached;

        // Try to find by constructing property name + "Property"
        std::wstring dpName = std::wstring(propertyName) + L"Property";

        // Try common types
        try
        {
            // FrameworkElement properties
            if (propertyName == L"Width")
                return winrt::FrameworkElement::WidthProperty();
            if (propertyName == L"Height")
                return winrt::FrameworkElement::HeightProperty();
            if (propertyName == L"MinWidth")
                return winrt::FrameworkElement::MinWidthProperty();
            if (propertyName == L"MinHeight")
                return winrt::FrameworkElement::MinHeightProperty();
            if (propertyName == L"MaxWidth")
                return winrt::FrameworkElement::MaxWidthProperty();
            if (propertyName == L"MaxHeight")
                return winrt::FrameworkElement::MaxHeightProperty();

            // UIElement properties
            if (propertyName == L"Opacity")
                return winrt::UIElement::OpacityProperty();
            if (propertyName == L"Visibility")
                return winrt::UIElement::VisibilityProperty();

            // Control properties
            if (propertyName == L"IsEnabled")
                return winrt::Control::IsEnabledProperty();
            if (propertyName == L"FontSize")
                return winrt::Control::FontSizeProperty();

            // TextBlock properties
            if (auto tb = obj.try_as<winrt::TextBlock>())
            {
                if (propertyName == L"Text")
                    return winrt::TextBlock::TextProperty();
                if (propertyName == L"TextWrapping")
                    return winrt::TextBlock::TextWrappingProperty();
                if (propertyName == L"MaxLines")
                    return winrt::TextBlock::MaxLinesProperty();
            }

            // TextBox properties
            if (auto textBox = obj.try_as<winrt::TextBox>())
            {
                if (propertyName == L"Text")
                    return winrt::TextBox::TextProperty();
                if (propertyName == L"PlaceholderText")
                    return winrt::TextBox::PlaceholderTextProperty();
                if (propertyName == L"IsReadOnly")
                    return winrt::TextBox::IsReadOnlyProperty();
                if (propertyName == L"MaxLength")
                    return winrt::TextBox::MaxLengthProperty();
            }
        }
        catch (...)
        {
            // Property not found
        }

        return nullptr;
    }

    // ========================================================================
    // Common Property Accessors
    // ========================================================================

    namespace Common
    {
        double GetWidth(winrt::FrameworkElement const& elem) { return elem.Width(); }
        void SetWidth(winrt::FrameworkElement const& elem, double value) { elem.Width(value); }
        double GetHeight(winrt::FrameworkElement const& elem) { return elem.Height(); }
        void SetHeight(winrt::FrameworkElement const& elem, double value) { elem.Height(value); }
        double GetMinWidth(winrt::FrameworkElement const& elem) { return elem.MinWidth(); }
        void SetMinWidth(winrt::FrameworkElement const& elem, double value) { elem.MinWidth(value); }
        double GetMinHeight(winrt::FrameworkElement const& elem) { return elem.MinHeight(); }
        void SetMinHeight(winrt::FrameworkElement const& elem, double value) { elem.MinHeight(value); }
        double GetMaxWidth(winrt::FrameworkElement const& elem) { return elem.MaxWidth(); }
        void SetMaxWidth(winrt::FrameworkElement const& elem, double value) { elem.MaxWidth(value); }
        double GetMaxHeight(winrt::FrameworkElement const& elem) { return elem.MaxHeight(); }
        void SetMaxHeight(winrt::FrameworkElement const& elem, double value) { elem.MaxHeight(value); }
        double GetActualWidth(winrt::FrameworkElement const& elem) { return elem.ActualWidth(); }
        double GetActualHeight(winrt::FrameworkElement const& elem) { return elem.ActualHeight(); }
        std::wstring GetName(winrt::FrameworkElement const& elem) { return std::wstring(elem.Name()); }

        std::wstring GetTag(winrt::FrameworkElement const& elem)
        {
            auto tag = elem.Tag();
            if (auto str = tag.try_as<winrt::hstring>())
                return std::wstring(*str);
            return L"";
        }

        void SetTag(winrt::FrameworkElement const& elem, std::wstring_view value)
        {
            elem.Tag(winrt::box_value(winrt::hstring(value)));
        }

        double GetOpacity(winrt::UIElement const& elem) { return elem.Opacity(); }
        void SetOpacity(winrt::UIElement const& elem, double value) { elem.Opacity(value); }
        int GetVisibility(winrt::UIElement const& elem) { return static_cast<int>(elem.Visibility()); }
        void SetVisibility(winrt::UIElement const& elem, int value) { elem.Visibility(static_cast<winrt::Visibility>(value)); }
        bool GetIsHitTestVisible(winrt::UIElement const& elem) { return elem.IsHitTestVisible(); }
        void SetIsHitTestVisible(winrt::UIElement const& elem, bool value) { elem.IsHitTestVisible(value); }

        bool GetIsEnabled(winrt::Control const& ctrl) { return ctrl.IsEnabled(); }
        void SetIsEnabled(winrt::Control const& ctrl, bool value) { ctrl.IsEnabled(value); }
        bool GetIsTabStop(winrt::Control const& ctrl) { return ctrl.IsTabStop(); }
        void SetIsTabStop(winrt::Control const& ctrl, bool value) { ctrl.IsTabStop(value); }
        int GetTabIndex(winrt::Control const& ctrl) { return ctrl.TabIndex(); }
        void SetTabIndex(winrt::Control const& ctrl, int value) { ctrl.TabIndex(value); }
        double GetFontSize(winrt::Control const& ctrl) { return ctrl.FontSize(); }
        void SetFontSize(winrt::Control const& ctrl, double value) { ctrl.FontSize(value); }

        std::wstring GetContent(winrt::ContentControl const& ctrl)
        {
            auto content = ctrl.Content();
            if (auto str = content.try_as<winrt::hstring>())
                return std::wstring(*str);
            if (auto tb = content.try_as<winrt::TextBlock>())
                return std::wstring(tb.Text());
            return L"";
        }

        void SetContent(winrt::ContentControl const& ctrl, std::wstring_view value)
        {
            ctrl.Content(winrt::box_value(winrt::hstring(value)));
        }

        std::wstring GetText(winrt::TextBlock const& tb) { return std::wstring(tb.Text()); }
        void SetText(winrt::TextBlock const& tb, std::wstring_view value) { tb.Text(winrt::hstring(value)); }
        std::wstring GetTextBoxText(winrt::TextBox const& tb) { return std::wstring(tb.Text()); }
        void SetTextBoxText(winrt::TextBox const& tb, std::wstring_view value) { tb.Text(winrt::hstring(value)); }
    }

    // ========================================================================
    // Property Registry Implementation
    // ========================================================================

    PropertyRegistry& PropertyRegistry::Instance()
    {
        static PropertyRegistry instance;
        return instance;
    }

    std::wstring PropertyRegistry::MakeKey(std::wstring_view typeName, std::wstring_view propName)
    {
        std::wstring key;
        key.reserve(typeName.size() + 1 + propName.size());
        key.append(typeName);
        key.push_back(L'.');
        key.append(propName);
        return key;
    }

    void PropertyRegistry::RegisterProperty(std::wstring_view typeName, std::wstring_view propName,
                                             winrt::DependencyProperty const& dp)
    {
        std::unique_lock lock(m_mutex);
        m_properties[MakeKey(typeName, propName)] = dp;
    }

    std::optional<winrt::DependencyProperty> PropertyRegistry::FindProperty(
        std::wstring_view typeName, std::wstring_view propName) const
    {
        std::shared_lock lock(m_mutex);
        auto it = m_properties.find(MakeKey(typeName, propName));
        if (it != m_properties.end())
            return it->second;
        return std::nullopt;
    }

    void PropertyRegistry::InitializeCommonProperties()
    {
        // Pre-register common properties for faster lookup
        // This is called on first use
    }

} // namespace PropertyReflection

// ============================================================================
// DynamicPropertyAccessor Implementation
// ============================================================================

DynamicPropertyAccessor::DynamicPropertyAccessor(winrt::DependencyObject const& obj)
    : m_object(obj)
{
}

STDMETHODIMP DynamicPropertyAccessor::QueryInterface(REFIID riid, void** ppv)
{
    if (!ppv)
        return E_POINTER;

    *ppv = nullptr;

    if (riid == IID_IUnknown || riid == IID_IDispatch)
    {
        *ppv = static_cast<IDispatch*>(this);
        AddRef();
        return S_OK;
    }

    return E_NOINTERFACE;
}

STDMETHODIMP_(ULONG) DynamicPropertyAccessor::AddRef() noexcept
{
    return m_refCount.fetch_add(1, std::memory_order_relaxed) + 1;
}

STDMETHODIMP_(ULONG) DynamicPropertyAccessor::Release() noexcept
{
    ULONG count = m_refCount.fetch_sub(1, std::memory_order_acq_rel) - 1;
    if (count == 0)
        delete this;
    return count;
}

STDMETHODIMP DynamicPropertyAccessor::GetTypeInfoCount(UINT* pctinfo)
{
    if (!pctinfo)
        return E_POINTER;
    *pctinfo = 0;
    return S_OK;
}

STDMETHODIMP DynamicPropertyAccessor::GetTypeInfo(UINT, LCID, ITypeInfo**)
{
    return E_NOTIMPL;
}

DISPID DynamicPropertyAccessor::GetOrCreateDispId(const std::wstring& name) const
{
    std::lock_guard<std::mutex> lock(m_mutex);

    auto it = m_nameToDispId.find(name);
    if (it != m_nameToDispId.end())
        return it->second;

    DISPID dispId = m_nextDispId++;
    m_nameToDispId[name] = dispId;
    m_dispIdToName[dispId] = name;
    return dispId;
}

std::wstring DynamicPropertyAccessor::GetNameFromDispId(DISPID dispId) const
{
    std::lock_guard<std::mutex> lock(m_mutex);

    auto it = m_dispIdToName.find(dispId);
    if (it != m_dispIdToName.end())
        return it->second;
    return L"";
}

STDMETHODIMP DynamicPropertyAccessor::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                                     LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        std::wstring name(rgszNames[i]);

        // Check special methods
        if (name == L"GetProperty")
            rgDispId[i] = CYCB_GETPROPERTY;
        else if (name == L"SetProperty")
            rgDispId[i] = CYCB_SETPROPERTY;
        else if (name == L"HasProperty")
            rgDispId[i] = CYCB_HASPROPERTY;
        else if (name == L"GetProperties")
            rgDispId[i] = CYCB_GETPROPERTIES;
        else if (name == L"TypeName")
            rgDispId[i] = CYCB_TYPENAME;
        else
            rgDispId[i] = GetOrCreateDispId(name);
    }
    return S_OK;
}

STDMETHODIMP DynamicPropertyAccessor::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                              DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                              EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    if (!m_object)
        return E_FAIL;

    switch (dispId)
    {
    case CYCB_TYPENAME:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(
                PropertyReflection::GetTypeName(m_object).c_str());
            return S_OK;
        }
        break;

    case CYCB_GETPROPERTY:
        if (wFlags & DISPATCH_METHOD && pDispParams->cArgs >= 1)
        {
            VariantGuard nameVar;
            HRESULT hrConv = VariantChangeType(nameVar.Get(), &pDispParams->rgvarg[0], 0, VT_BSTR);
            if (SUCCEEDED(hrConv))
            {
                *pVarResult = PropertyReflection::GetProperty(m_object, V_BSTR(nameVar.Get()));
                return S_OK;
            }
            return DISP_E_TYPEMISMATCH;
        }
        break;

    case CYCB_SETPROPERTY:
        if (wFlags & DISPATCH_METHOD && pDispParams->cArgs >= 2)
        {
            // Args are in reverse order
            VariantGuard nameVar;
            HRESULT hrConv = VariantChangeType(nameVar.Get(), &pDispParams->rgvarg[1], 0, VT_BSTR);
            if (SUCCEEDED(hrConv))
            {
                bool success = PropertyReflection::SetProperty(
                    m_object, V_BSTR(nameVar.Get()), pDispParams->rgvarg[0]);
                V_VT(pVarResult) = VT_BOOL;
                V_BOOL(pVarResult) = success ? VARIANT_TRUE : VARIANT_FALSE;
                return S_OK;
            }
            return DISP_E_TYPEMISMATCH;
        }
        break;

    case CYCB_HASPROPERTY:
        if (wFlags & DISPATCH_METHOD && pDispParams->cArgs >= 1)
        {
            VariantGuard nameVar;
            HRESULT hrConv = VariantChangeType(nameVar.Get(), &pDispParams->rgvarg[0], 0, VT_BSTR);
            if (SUCCEEDED(hrConv))
            {
                bool exists = PropertyReflection::HasProperty(m_object, V_BSTR(nameVar.Get()));
                V_VT(pVarResult) = VT_BOOL;
                V_BOOL(pVarResult) = exists ? VARIANT_TRUE : VARIANT_FALSE;
                return S_OK;
            }
            return DISP_E_TYPEMISMATCH;
        }
        break;

    case CYCB_GETPROPERTIES:
        if (wFlags & DISPATCH_METHOD)
        {
            auto props = PropertyReflection::GetProperties(m_object);

            // Build a string list for simplicity
            std::wstring result;
            for (const auto& prop : props)
            {
                if (!result.empty())
                    result += L";";
                result += prop.name + L":" + prop.typeName;
            }

            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(result.c_str());
            return S_OK;
        }
        break;

    default:
        // Dynamic property access
        {
            std::wstring propName = GetNameFromDispId(dispId);
            if (propName.empty())
                return DISP_E_MEMBERNOTFOUND;

            if (wFlags & DISPATCH_PROPERTYGET)
            {
                *pVarResult = PropertyReflection::GetProperty(m_object, propName);
                return S_OK;
            }
            else if (wFlags & DISPATCH_PROPERTYPUT && pDispParams->cArgs >= 1)
            {
                if (PropertyReflection::SetProperty(m_object, propName, pDispParams->rgvarg[0]))
                    return S_OK;
                return DISP_E_MEMBERNOTFOUND;
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

std::vector<PropertyReflection::PropertyInfo> DynamicPropertyAccessor::GetProperties() const
{
    return PropertyReflection::GetProperties(m_object);
}
