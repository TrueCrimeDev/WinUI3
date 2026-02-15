#include "pch.h"
#include "ControlWrappers.h"

// ============================================================================
// Control Wrapper Factory
// ============================================================================

IControlWrapper* CreateControlWrapper(winrt::FrameworkElement const& element)
{
    if (!element)
        return nullptr;

    // Try specific control types in order of likelihood

    // Button types
    if (auto button = element.try_as<winrt::Button>())
        return new ButtonWrapper(button);

    if (auto toggleButton = element.try_as<winrt::ToggleButton>())
    {
        // Check if it's a CheckBox or RadioButton
        if (element.try_as<winrt::CheckBox>() || element.try_as<winrt::RadioButton>())
            return new CheckBoxWrapper(toggleButton);
        // Otherwise it's a ToggleButton
        return new ButtonWrapper(toggleButton);
    }

    // Text input types
    if (auto textBox = element.try_as<winrt::TextBox>())
        return new TextBoxWrapper(textBox);

    if (auto passwordBox = element.try_as<winrt::PasswordBox>())
        return new TextBoxWrapper(passwordBox);

    // Selection types
    if (auto comboBox = element.try_as<winrt::ComboBox>())
        return new ComboBoxWrapper(comboBox);

    if (auto listView = element.try_as<winrt::ListView>())
        return new ListViewWrapper(listView);

    if (auto gridView = element.try_as<winrt::GridView>())
        return new ListViewWrapper(gridView);

    // Range types
    if (auto slider = element.try_as<winrt::Slider>())
        return new SliderWrapper(slider);

    if (auto progressBar = element.try_as<winrt::ProgressBar>())
        return new ProgressBarWrapper(progressBar);

    if (auto progressRing = element.try_as<winrt::ProgressRing>())
        return new ProgressBarWrapper(progressRing);

    // Display types
    if (auto textBlock = element.try_as<winrt::TextBlock>())
        return new TextBlockWrapper(textBlock);

    // Toggle types
    if (auto toggleSwitch = element.try_as<winrt::ToggleSwitch>())
        return new ToggleSwitchWrapper(toggleSwitch);

    // Unknown type - return nullptr
    TRACE(L"CreateControlWrapper: Unknown control type for element '%s'",
          element.Name().c_str());
    return nullptr;
}

// ============================================================================
// ButtonWrapper Implementation
// ============================================================================

ButtonWrapper::ButtonWrapper(winrt::ButtonBase const& button)
    : m_button(button)
{
}

winrt::FrameworkElement ButtonWrapper::GetElement() const
{
    return m_button;
}

std::wstring ButtonWrapper::GetContent() const
{
    if (!m_button)
        return L"";

    auto content = m_button.Content();
    if (auto str = content.try_as<winrt::hstring>())
        return std::wstring(*str);

    // Try to get string representation
    if (auto textBlock = content.try_as<winrt::TextBlock>())
        return std::wstring(textBlock.Text());

    return L"";
}

void ButtonWrapper::SetContent(std::wstring_view value)
{
    if (m_button)
        m_button.Content(winrt::box_value(winrt::hstring(value)));
}

bool ButtonWrapper::GetIsPressed() const
{
    if (auto toggle = m_button.try_as<winrt::ToggleButton>())
    {
        auto isChecked = toggle.IsChecked();
        return isChecked.has_value() && isChecked.value();
    }
    return false;
}

void ButtonWrapper::SetIsPressed(bool value)
{
    if (auto toggle = m_button.try_as<winrt::ToggleButton>())
        toggle.IsChecked(value);
}

STDMETHODIMP ButtonWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                           LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"Content")
            rgDispId[i] = DISPID_CONTENT;
        else if (name == L"IsPressed")
            rgDispId[i] = DISPID_ISPRESSED;
        else if (name == L"Click")
            rgDispId[i] = DISPID_CLICK;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP ButtonWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                    DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                    EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    // Try common properties first
    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_CONTENT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetContent().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetContent(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ISPRESSED:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsPressed() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsPressed(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;

    case DISPID_CLICK:
        if (wFlags & DISPATCH_METHOD)
        {
            // Programmatically invoke click
            if (auto buttonAuto = m_button.try_as<winrt::Microsoft::UI::Xaml::Automation::Provider::IInvokeProvider>())
            {
                buttonAuto.Invoke();
                V_VT(pVarResult) = VT_BOOL;
                V_BOOL(pVarResult) = VARIANT_TRUE;
                return S_OK;
            }
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = VARIANT_FALSE;
            return S_OK;
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// TextBoxWrapper Implementation
// ============================================================================

TextBoxWrapper::TextBoxWrapper(winrt::Control const& textBox)
    : m_control(textBox)
    , m_isPasswordBox(textBox.try_as<winrt::PasswordBox>() != nullptr)
{
}

winrt::FrameworkElement TextBoxWrapper::GetElement() const
{
    return m_control;
}

std::wstring TextBoxWrapper::GetControlType() const
{
    return m_isPasswordBox ? L"PasswordBox" : L"TextBox";
}

bool TextBoxWrapper::IsValid() const
{
    return m_control != nullptr;
}

std::wstring TextBoxWrapper::GetText() const
{
    if (m_isPasswordBox)
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            return std::wstring(pb.Password());
    }
    else
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return std::wstring(tb.Text());
    }
    return L"";
}

void TextBoxWrapper::SetText(std::wstring_view value)
{
    if (m_isPasswordBox)
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            pb.Password(winrt::hstring(value));
    }
    else
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.Text(winrt::hstring(value));
    }
}

std::wstring TextBoxWrapper::GetPlaceholderText() const
{
    if (m_isPasswordBox)
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            return std::wstring(pb.PlaceholderText());
    }
    else
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return std::wstring(tb.PlaceholderText());
    }
    return L"";
}

void TextBoxWrapper::SetPlaceholderText(std::wstring_view value)
{
    if (m_isPasswordBox)
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            pb.PlaceholderText(winrt::hstring(value));
    }
    else
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.PlaceholderText(winrt::hstring(value));
    }
}

int TextBoxWrapper::GetSelectionStart() const
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return tb.SelectionStart();
    }
    return 0;
}

void TextBoxWrapper::SetSelectionStart(int value)
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.SelectionStart(value);
    }
}

int TextBoxWrapper::GetSelectionLength() const
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return tb.SelectionLength();
    }
    return 0;
}

void TextBoxWrapper::SetSelectionLength(int value)
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.SelectionLength(value);
    }
}

std::wstring TextBoxWrapper::GetSelectedText() const
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return std::wstring(tb.SelectedText());
    }
    return L"";
}

bool TextBoxWrapper::GetIsReadOnly() const
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return tb.IsReadOnly();
    }
    return false;
}

void TextBoxWrapper::SetIsReadOnly(bool value)
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.IsReadOnly(value);
    }
}

int TextBoxWrapper::GetMaxLength() const
{
    if (m_isPasswordBox)
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            return pb.MaxLength();
    }
    else
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            return tb.MaxLength();
    }
    return 0;
}

void TextBoxWrapper::SetMaxLength(int value)
{
    if (m_isPasswordBox)
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            pb.MaxLength(value);
    }
    else
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.MaxLength(value);
    }
}

void TextBoxWrapper::SelectAll()
{
    if (!m_isPasswordBox)
    {
        if (auto tb = m_control.try_as<winrt::TextBox>())
            tb.SelectAll();
    }
    else
    {
        if (auto pb = m_control.try_as<winrt::PasswordBox>())
            pb.SelectAll();
    }
}

void TextBoxWrapper::Clear()
{
    SetText(L"");
}

STDMETHODIMP TextBoxWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                            LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"Text")
            rgDispId[i] = DISPID_TEXT;
        else if (name == L"PlaceholderText")
            rgDispId[i] = DISPID_PLACEHOLDERTEXT;
        else if (name == L"SelectionStart")
            rgDispId[i] = DISPID_SELECTIONSTART;
        else if (name == L"SelectionLength")
            rgDispId[i] = DISPID_SELECTIONLENGTH;
        else if (name == L"SelectedText")
            rgDispId[i] = DISPID_SELECTEDTEXT;
        else if (name == L"IsReadOnly")
            rgDispId[i] = DISPID_ISREADONLY;
        else if (name == L"MaxLength")
            rgDispId[i] = DISPID_MAXLENGTH;
        else if (name == L"SelectAll")
            rgDispId[i] = DISPID_SELECTALL;
        else if (name == L"Clear")
            rgDispId[i] = DISPID_CLEAR;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP TextBoxWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                     DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                     EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_TEXT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetText().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetText(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_PLACEHOLDERTEXT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetPlaceholderText().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetPlaceholderText(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_SELECTIONSTART:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetSelectionStart();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetSelectionStart(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_SELECTIONLENGTH:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetSelectionLength();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetSelectionLength(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_SELECTEDTEXT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetSelectedText().c_str());
            return S_OK;
        }
        break;

    case DISPID_ISREADONLY:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsReadOnly() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsReadOnly(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;

    case DISPID_MAXLENGTH:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetMaxLength();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetMaxLength(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_SELECTALL:
        if (wFlags & DISPATCH_METHOD)
        {
            SelectAll();
            return S_OK;
        }
        break;

    case DISPID_CLEAR:
        if (wFlags & DISPATCH_METHOD)
        {
            Clear();
            return S_OK;
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// CheckBoxWrapper Implementation
// ============================================================================

CheckBoxWrapper::CheckBoxWrapper(winrt::ToggleButton const& toggleButton)
    : m_toggleButton(toggleButton)
    , m_isRadioButton(toggleButton.try_as<winrt::RadioButton>() != nullptr)
{
}

winrt::FrameworkElement CheckBoxWrapper::GetElement() const
{
    return m_toggleButton;
}

std::wstring CheckBoxWrapper::GetControlType() const
{
    return m_isRadioButton ? L"RadioButton" : L"CheckBox";
}

std::wstring CheckBoxWrapper::GetContent() const
{
    if (!m_toggleButton)
        return L"";

    auto content = m_toggleButton.Content();
    if (auto str = content.try_as<winrt::hstring>())
        return std::wstring(*str);

    if (auto textBlock = content.try_as<winrt::TextBlock>())
        return std::wstring(textBlock.Text());

    return L"";
}

void CheckBoxWrapper::SetContent(std::wstring_view value)
{
    if (m_toggleButton)
        m_toggleButton.Content(winrt::box_value(winrt::hstring(value)));
}

int CheckBoxWrapper::GetIsChecked() const
{
    if (!m_toggleButton)
        return 0;

    auto isChecked = m_toggleButton.IsChecked();
    if (!isChecked.has_value())
        return 2;  // Indeterminate
    return isChecked.value() ? 1 : 0;
}

void CheckBoxWrapper::SetIsChecked(int value)
{
    if (!m_toggleButton)
        return;

    switch (value)
    {
    case 0:
        m_toggleButton.IsChecked(false);
        break;
    case 1:
        m_toggleButton.IsChecked(true);
        break;
    case 2:
        if (!m_isRadioButton)  // RadioButton doesn't support indeterminate
            m_toggleButton.IsChecked(std::nullopt);
        break;
    }
}

bool CheckBoxWrapper::GetIsThreeState() const
{
    if (auto checkBox = m_toggleButton.try_as<winrt::CheckBox>())
        return checkBox.IsThreeState();
    return false;
}

void CheckBoxWrapper::SetIsThreeState(bool value)
{
    if (auto checkBox = m_toggleButton.try_as<winrt::CheckBox>())
        checkBox.IsThreeState(value);
}

STDMETHODIMP CheckBoxWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                             LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"Content")
            rgDispId[i] = DISPID_CONTENT;
        else if (name == L"IsChecked")
            rgDispId[i] = DISPID_ISCHECKED;
        else if (name == L"IsThreeState")
            rgDispId[i] = DISPID_ISTHREESTATE;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP CheckBoxWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                      DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                      EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_CONTENT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetContent().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetContent(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ISCHECKED:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetIsChecked();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetIsChecked(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ISTHREESTATE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsThreeState() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsThreeState(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// ComboBoxWrapper Implementation
// ============================================================================

ComboBoxWrapper::ComboBoxWrapper(winrt::ComboBox const& comboBox)
    : m_comboBox(comboBox)
{
}

winrt::FrameworkElement ComboBoxWrapper::GetElement() const
{
    return m_comboBox;
}

int ComboBoxWrapper::GetSelectedIndex() const
{
    return m_comboBox ? m_comboBox.SelectedIndex() : -1;
}

void ComboBoxWrapper::SetSelectedIndex(int value)
{
    if (m_comboBox)
        m_comboBox.SelectedIndex(value);
}

std::wstring ComboBoxWrapper::GetSelectedText() const
{
    if (!m_comboBox)
        return L"";

    auto selectedItem = m_comboBox.SelectedItem();
    if (auto str = selectedItem.try_as<winrt::hstring>())
        return std::wstring(*str);

    return L"";
}

int ComboBoxWrapper::GetItemCount() const
{
    return m_comboBox ? static_cast<int>(m_comboBox.Items().Size()) : 0;
}

std::wstring ComboBoxWrapper::GetPlaceholderText() const
{
    return m_comboBox ? std::wstring(m_comboBox.PlaceholderText()) : L"";
}

void ComboBoxWrapper::SetPlaceholderText(std::wstring_view value)
{
    if (m_comboBox)
        m_comboBox.PlaceholderText(winrt::hstring(value));
}

bool ComboBoxWrapper::GetIsEditable() const
{
    return m_comboBox ? m_comboBox.IsEditable() : false;
}

void ComboBoxWrapper::SetIsEditable(bool value)
{
    if (m_comboBox)
        m_comboBox.IsEditable(value);
}

void ComboBoxWrapper::AddItem(std::wstring_view text)
{
    if (m_comboBox)
        m_comboBox.Items().Append(winrt::box_value(winrt::hstring(text)));
}

void ComboBoxWrapper::RemoveItemAt(int index)
{
    if (m_comboBox && index >= 0 && index < static_cast<int>(m_comboBox.Items().Size()))
        m_comboBox.Items().RemoveAt(static_cast<uint32_t>(index));
}

void ComboBoxWrapper::Clear()
{
    if (m_comboBox)
        m_comboBox.Items().Clear();
}

std::wstring ComboBoxWrapper::GetItemAt(int index) const
{
    if (!m_comboBox || index < 0 || index >= static_cast<int>(m_comboBox.Items().Size()))
        return L"";

    auto item = m_comboBox.Items().GetAt(static_cast<uint32_t>(index));
    if (auto str = item.try_as<winrt::hstring>())
        return std::wstring(*str);

    return L"";
}

STDMETHODIMP ComboBoxWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                             LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"SelectedIndex")
            rgDispId[i] = DISPID_SELECTEDINDEX;
        else if (name == L"SelectedText")
            rgDispId[i] = DISPID_SELECTEDTEXT;
        else if (name == L"ItemCount" || name == L"Count")
            rgDispId[i] = DISPID_ITEMCOUNT;
        else if (name == L"PlaceholderText")
            rgDispId[i] = DISPID_PLACEHOLDERTEXT;
        else if (name == L"IsEditable")
            rgDispId[i] = DISPID_ISEDITABLE;
        else if (name == L"AddItem" || name == L"Add")
            rgDispId[i] = DISPID_ADDITEM;
        else if (name == L"RemoveAt" || name == L"RemoveItemAt")
            rgDispId[i] = DISPID_REMOVEAT;
        else if (name == L"Clear")
            rgDispId[i] = DISPID_CLEAR;
        else if (name == L"GetAt" || name == L"GetItemAt")
            rgDispId[i] = DISPID_GETAT;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP ComboBoxWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                      DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                      EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_SELECTEDINDEX:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetSelectedIndex();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetSelectedIndex(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_SELECTEDTEXT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetSelectedText().c_str());
            return S_OK;
        }
        break;

    case DISPID_ITEMCOUNT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetItemCount();
            return S_OK;
        }
        break;

    case DISPID_PLACEHOLDERTEXT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetPlaceholderText().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetPlaceholderText(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ISEDITABLE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsEditable() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsEditable(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;

    case DISPID_ADDITEM:
        if (wFlags & DISPATCH_METHOD)
        {
            if (pDispParams->cArgs >= 1)
            {
                VariantGuard var;
                if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
                {
                    AddItem(V_BSTR(&var));
                    return S_OK;
                }
            }
        }
        break;

    case DISPID_REMOVEAT:
        if (wFlags & DISPATCH_METHOD)
        {
            if (pDispParams->cArgs >= 1)
            {
                VariantGuard var;
                if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
                {
                    RemoveItemAt(V_I4(&var));
                    return S_OK;
                }
            }
        }
        break;

    case DISPID_CLEAR:
        if (wFlags & DISPATCH_METHOD)
        {
            Clear();
            return S_OK;
        }
        break;

    case DISPID_GETAT:
        if (wFlags & DISPATCH_METHOD)
        {
            if (pDispParams->cArgs >= 1)
            {
                VariantGuard var;
                if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
                {
                    V_VT(pVarResult) = VT_BSTR;
                    V_BSTR(pVarResult) = SysAllocString(GetItemAt(V_I4(&var)).c_str());
                    return S_OK;
                }
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// SliderWrapper Implementation
// ============================================================================

SliderWrapper::SliderWrapper(winrt::Slider const& slider)
    : m_slider(slider)
{
}

winrt::FrameworkElement SliderWrapper::GetElement() const
{
    return m_slider;
}

double SliderWrapper::GetValue() const
{
    return m_slider ? m_slider.Value() : 0.0;
}

void SliderWrapper::SetValue(double value)
{
    if (m_slider)
        m_slider.Value(value);
}

double SliderWrapper::GetMinimum() const
{
    return m_slider ? m_slider.Minimum() : 0.0;
}

void SliderWrapper::SetMinimum(double value)
{
    if (m_slider)
        m_slider.Minimum(value);
}

double SliderWrapper::GetMaximum() const
{
    return m_slider ? m_slider.Maximum() : 100.0;
}

void SliderWrapper::SetMaximum(double value)
{
    if (m_slider)
        m_slider.Maximum(value);
}

double SliderWrapper::GetStepFrequency() const
{
    return m_slider ? m_slider.StepFrequency() : 1.0;
}

void SliderWrapper::SetStepFrequency(double value)
{
    if (m_slider)
        m_slider.StepFrequency(value);
}

int SliderWrapper::GetOrientation() const
{
    return m_slider ? static_cast<int>(m_slider.Orientation()) : 0;
}

void SliderWrapper::SetOrientation(int value)
{
    if (m_slider)
        m_slider.Orientation(static_cast<winrt::Orientation>(value));
}

STDMETHODIMP SliderWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                           LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"Value")
            rgDispId[i] = DISPID_VALUE;
        else if (name == L"Minimum" || name == L"Min")
            rgDispId[i] = DISPID_MINIMUM;
        else if (name == L"Maximum" || name == L"Max")
            rgDispId[i] = DISPID_MAXIMUM;
        else if (name == L"StepFrequency" || name == L"Step")
            rgDispId[i] = DISPID_STEPFREQUENCY;
        else if (name == L"Orientation")
            rgDispId[i] = DISPID_ORIENTATION;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP SliderWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                    DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                    EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_VALUE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetValue();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetValue(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_MINIMUM:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetMinimum();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetMinimum(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_MAXIMUM:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetMaximum();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetMaximum(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_STEPFREQUENCY:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetStepFrequency();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetStepFrequency(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ORIENTATION:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetOrientation();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetOrientation(V_I4(&var));
                return S_OK;
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// ProgressBarWrapper Implementation
// ============================================================================

ProgressBarWrapper::ProgressBarWrapper(winrt::Control const& progressControl)
    : m_control(progressControl)
    , m_isProgressRing(progressControl.try_as<winrt::ProgressRing>() != nullptr)
{
}

winrt::FrameworkElement ProgressBarWrapper::GetElement() const
{
    return m_control;
}

std::wstring ProgressBarWrapper::GetControlType() const
{
    return m_isProgressRing ? L"ProgressRing" : L"ProgressBar";
}

bool ProgressBarWrapper::IsValid() const
{
    return m_control != nullptr;
}

double ProgressBarWrapper::GetValue() const
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            return ring.Value();
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            return bar.Value();
    }
    return 0.0;
}

void ProgressBarWrapper::SetValue(double value)
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            ring.Value(value);
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            bar.Value(value);
    }
}

double ProgressBarWrapper::GetMinimum() const
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            return ring.Minimum();
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            return bar.Minimum();
    }
    return 0.0;
}

void ProgressBarWrapper::SetMinimum(double value)
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            ring.Minimum(value);
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            bar.Minimum(value);
    }
}

double ProgressBarWrapper::GetMaximum() const
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            return ring.Maximum();
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            return bar.Maximum();
    }
    return 100.0;
}

void ProgressBarWrapper::SetMaximum(double value)
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            ring.Maximum(value);
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            bar.Maximum(value);
    }
}

bool ProgressBarWrapper::GetIsIndeterminate() const
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            return ring.IsIndeterminate();
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            return bar.IsIndeterminate();
    }
    return false;
}

void ProgressBarWrapper::SetIsIndeterminate(bool value)
{
    if (m_isProgressRing)
    {
        if (auto ring = m_control.try_as<winrt::ProgressRing>())
            ring.IsIndeterminate(value);
    }
    else
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            bar.IsIndeterminate(value);
    }
}

bool ProgressBarWrapper::GetShowPaused() const
{
    if (!m_isProgressRing)
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            return bar.ShowPaused();
    }
    return false;
}

void ProgressBarWrapper::SetShowPaused(bool value)
{
    if (!m_isProgressRing)
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            bar.ShowPaused(value);
    }
}

bool ProgressBarWrapper::GetShowError() const
{
    if (!m_isProgressRing)
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            return bar.ShowError();
    }
    return false;
}

void ProgressBarWrapper::SetShowError(bool value)
{
    if (!m_isProgressRing)
    {
        if (auto bar = m_control.try_as<winrt::ProgressBar>())
            bar.ShowError(value);
    }
}

STDMETHODIMP ProgressBarWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                                LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"Value")
            rgDispId[i] = DISPID_VALUE;
        else if (name == L"Minimum" || name == L"Min")
            rgDispId[i] = DISPID_MINIMUM;
        else if (name == L"Maximum" || name == L"Max")
            rgDispId[i] = DISPID_MAXIMUM;
        else if (name == L"IsIndeterminate")
            rgDispId[i] = DISPID_ISINDETERMINATE;
        else if (name == L"ShowPaused")
            rgDispId[i] = DISPID_SHOWPAUSED;
        else if (name == L"ShowError")
            rgDispId[i] = DISPID_SHOWERROR;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP ProgressBarWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                         DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                         EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_VALUE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetValue();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetValue(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_MINIMUM:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetMinimum();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetMinimum(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_MAXIMUM:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetMaximum();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetMaximum(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ISINDETERMINATE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsIndeterminate() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsIndeterminate(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;

    case DISPID_SHOWPAUSED:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetShowPaused() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetShowPaused(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;

    case DISPID_SHOWERROR:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetShowError() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetShowError(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// TextBlockWrapper Implementation
// ============================================================================

TextBlockWrapper::TextBlockWrapper(winrt::TextBlock const& textBlock)
    : m_textBlock(textBlock)
{
}

winrt::FrameworkElement TextBlockWrapper::GetElement() const
{
    return m_textBlock;
}

std::wstring TextBlockWrapper::GetText() const
{
    return m_textBlock ? std::wstring(m_textBlock.Text()) : L"";
}

void TextBlockWrapper::SetText(std::wstring_view value)
{
    if (m_textBlock)
        m_textBlock.Text(winrt::hstring(value));
}

int TextBlockWrapper::GetTextWrapping() const
{
    return m_textBlock ? static_cast<int>(m_textBlock.TextWrapping()) : 0;
}

void TextBlockWrapper::SetTextWrapping(int value)
{
    if (m_textBlock)
        m_textBlock.TextWrapping(static_cast<winrt::TextWrapping>(value));
}

int TextBlockWrapper::GetTextAlignment() const
{
    return m_textBlock ? static_cast<int>(m_textBlock.TextAlignment()) : 0;
}

void TextBlockWrapper::SetTextAlignment(int value)
{
    if (m_textBlock)
        m_textBlock.TextAlignment(static_cast<winrt::TextAlignment>(value));
}

double TextBlockWrapper::GetFontSize() const
{
    return m_textBlock ? m_textBlock.FontSize() : 14.0;
}

void TextBlockWrapper::SetFontSize(double value)
{
    if (m_textBlock)
        m_textBlock.FontSize(value);
}

int TextBlockWrapper::GetMaxLines() const
{
    return m_textBlock ? m_textBlock.MaxLines() : 0;
}

void TextBlockWrapper::SetMaxLines(int value)
{
    if (m_textBlock)
        m_textBlock.MaxLines(value);
}

bool TextBlockWrapper::GetIsTextSelectionEnabled() const
{
    return m_textBlock ? m_textBlock.IsTextSelectionEnabled() : false;
}

void TextBlockWrapper::SetIsTextSelectionEnabled(bool value)
{
    if (m_textBlock)
        m_textBlock.IsTextSelectionEnabled(value);
}

STDMETHODIMP TextBlockWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                              LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"Text")
            rgDispId[i] = DISPID_TEXT;
        else if (name == L"TextWrapping")
            rgDispId[i] = DISPID_TEXTWRAPPING;
        else if (name == L"TextAlignment")
            rgDispId[i] = DISPID_TEXTALIGNMENT;
        else if (name == L"FontSize")
            rgDispId[i] = DISPID_FONTSIZE;
        else if (name == L"MaxLines")
            rgDispId[i] = DISPID_MAXLINES;
        else if (name == L"IsTextSelectionEnabled")
            rgDispId[i] = DISPID_ISTEXTSELECTIONENABLED;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP TextBlockWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                       DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                       EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_TEXT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetText().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetText(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_TEXTWRAPPING:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetTextWrapping();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetTextWrapping(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_TEXTALIGNMENT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetTextAlignment();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetTextAlignment(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_FONTSIZE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_R8;
            V_R8(pVarResult) = GetFontSize();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_R8)))
            {
                SetFontSize(V_R8(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_MAXLINES:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetMaxLines();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetMaxLines(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ISTEXTSELECTIONENABLED:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsTextSelectionEnabled() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsTextSelectionEnabled(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// ListViewWrapper Implementation
// ============================================================================

ListViewWrapper::ListViewWrapper(winrt::ListViewBase const& listView)
    : m_listView(listView)
    , m_isGridView(listView.try_as<winrt::GridView>() != nullptr)
{
}

winrt::FrameworkElement ListViewWrapper::GetElement() const
{
    return m_listView;
}

std::wstring ListViewWrapper::GetControlType() const
{
    return m_isGridView ? L"GridView" : L"ListView";
}

int ListViewWrapper::GetSelectedIndex() const
{
    return m_listView ? m_listView.SelectedIndex() : -1;
}

void ListViewWrapper::SetSelectedIndex(int value)
{
    if (m_listView)
        m_listView.SelectedIndex(value);
}

int ListViewWrapper::GetItemCount() const
{
    return m_listView ? static_cast<int>(m_listView.Items().Size()) : 0;
}

int ListViewWrapper::GetSelectionMode() const
{
    return m_listView ? static_cast<int>(m_listView.SelectionMode()) : 0;
}

void ListViewWrapper::SetSelectionMode(int value)
{
    if (m_listView)
        m_listView.SelectionMode(static_cast<winrt::ListViewSelectionMode>(value));
}

void ListViewWrapper::AddItem(std::wstring_view text)
{
    if (m_listView)
        m_listView.Items().Append(winrt::box_value(winrt::hstring(text)));
}

void ListViewWrapper::RemoveItemAt(int index)
{
    if (m_listView && index >= 0 && index < static_cast<int>(m_listView.Items().Size()))
        m_listView.Items().RemoveAt(static_cast<uint32_t>(index));
}

void ListViewWrapper::Clear()
{
    if (m_listView)
        m_listView.Items().Clear();
}

void ListViewWrapper::ScrollIntoView(int index)
{
    if (m_listView && index >= 0 && index < static_cast<int>(m_listView.Items().Size()))
    {
        auto item = m_listView.Items().GetAt(static_cast<uint32_t>(index));
        m_listView.ScrollIntoView(item);
    }
}

STDMETHODIMP ListViewWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                             LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"SelectedIndex")
            rgDispId[i] = DISPID_SELECTEDINDEX;
        else if (name == L"ItemCount" || name == L"Count")
            rgDispId[i] = DISPID_ITEMCOUNT;
        else if (name == L"SelectionMode")
            rgDispId[i] = DISPID_SELECTIONMODE;
        else if (name == L"AddItem" || name == L"Add")
            rgDispId[i] = DISPID_ADDITEM;
        else if (name == L"RemoveAt" || name == L"RemoveItemAt")
            rgDispId[i] = DISPID_REMOVEAT;
        else if (name == L"Clear")
            rgDispId[i] = DISPID_CLEAR;
        else if (name == L"ScrollIntoView")
            rgDispId[i] = DISPID_SCROLLINTOVIEW;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP ListViewWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                      DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                      EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_SELECTEDINDEX:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetSelectedIndex();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetSelectedIndex(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ITEMCOUNT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetItemCount();
            return S_OK;
        }
        break;

    case DISPID_SELECTIONMODE:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_I4;
            V_I4(pVarResult) = GetSelectionMode();
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
            {
                SetSelectionMode(V_I4(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_ADDITEM:
        if (wFlags & DISPATCH_METHOD)
        {
            if (pDispParams->cArgs >= 1)
            {
                VariantGuard var;
                if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
                {
                    AddItem(V_BSTR(&var));
                    return S_OK;
                }
            }
        }
        break;

    case DISPID_REMOVEAT:
        if (wFlags & DISPATCH_METHOD)
        {
            if (pDispParams->cArgs >= 1)
            {
                VariantGuard var;
                if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
                {
                    RemoveItemAt(V_I4(&var));
                    return S_OK;
                }
            }
        }
        break;

    case DISPID_CLEAR:
        if (wFlags & DISPATCH_METHOD)
        {
            Clear();
            return S_OK;
        }
        break;

    case DISPID_SCROLLINTOVIEW:
        if (wFlags & DISPATCH_METHOD)
        {
            if (pDispParams->cArgs >= 1)
            {
                VariantGuard var;
                if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_I4)))
                {
                    ScrollIntoView(V_I4(&var));
                    return S_OK;
                }
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}

// ============================================================================
// ToggleSwitchWrapper Implementation
// ============================================================================

ToggleSwitchWrapper::ToggleSwitchWrapper(winrt::ToggleSwitch const& toggleSwitch)
    : m_toggleSwitch(toggleSwitch)
{
}

winrt::FrameworkElement ToggleSwitchWrapper::GetElement() const
{
    return m_toggleSwitch;
}

bool ToggleSwitchWrapper::GetIsOn() const
{
    return m_toggleSwitch ? m_toggleSwitch.IsOn() : false;
}

void ToggleSwitchWrapper::SetIsOn(bool value)
{
    if (m_toggleSwitch)
        m_toggleSwitch.IsOn(value);
}

std::wstring ToggleSwitchWrapper::GetOnContent() const
{
    if (!m_toggleSwitch)
        return L"";

    auto content = m_toggleSwitch.OnContent();
    if (auto str = content.try_as<winrt::hstring>())
        return std::wstring(*str);

    return L"";
}

void ToggleSwitchWrapper::SetOnContent(std::wstring_view value)
{
    if (m_toggleSwitch)
        m_toggleSwitch.OnContent(winrt::box_value(winrt::hstring(value)));
}

std::wstring ToggleSwitchWrapper::GetOffContent() const
{
    if (!m_toggleSwitch)
        return L"";

    auto content = m_toggleSwitch.OffContent();
    if (auto str = content.try_as<winrt::hstring>())
        return std::wstring(*str);

    return L"";
}

void ToggleSwitchWrapper::SetOffContent(std::wstring_view value)
{
    if (m_toggleSwitch)
        m_toggleSwitch.OffContent(winrt::box_value(winrt::hstring(value)));
}

std::wstring ToggleSwitchWrapper::GetHeader() const
{
    if (!m_toggleSwitch)
        return L"";

    auto header = m_toggleSwitch.Header();
    if (auto str = header.try_as<winrt::hstring>())
        return std::wstring(*str);

    return L"";
}

void ToggleSwitchWrapper::SetHeader(std::wstring_view value)
{
    if (m_toggleSwitch)
        m_toggleSwitch.Header(winrt::box_value(winrt::hstring(value)));
}

STDMETHODIMP ToggleSwitchWrapper::GetIDsOfNames(REFIID, LPOLESTR* rgszNames, UINT cNames,
                                                 LCID, DISPID* rgDispId)
{
    for (UINT i = 0; i < cNames; i++)
    {
        if (TryGetCommonDispId(rgszNames[i], &rgDispId[i]))
            continue;

        std::wstring name(rgszNames[i]);
        if (name == L"IsOn")
            rgDispId[i] = DISPID_ISON;
        else if (name == L"OnContent")
            rgDispId[i] = DISPID_ONCONTENT;
        else if (name == L"OffContent")
            rgDispId[i] = DISPID_OFFCONTENT;
        else if (name == L"Header")
            rgDispId[i] = DISPID_HEADER;
        else
            return DISP_E_UNKNOWNNAME;
    }
    return S_OK;
}

STDMETHODIMP ToggleSwitchWrapper::Invoke(DISPID dispId, REFIID, LCID, WORD wFlags,
                                          DISPPARAMS* pDispParams, VARIANT* pVarResult,
                                          EXCEPINFO*, UINT*)
{
    if (!pVarResult)
        return E_POINTER;

    VariantInit(pVarResult);

    HRESULT hr = TryInvokeCommon(dispId, wFlags, pDispParams, pVarResult);
    if (hr != DISP_E_MEMBERNOTFOUND)
        return hr;

    switch (dispId)
    {
    case DISPID_ISON:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BOOL;
            V_BOOL(pVarResult) = GetIsOn() ? VARIANT_TRUE : VARIANT_FALSE;
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BOOL)))
            {
                SetIsOn(V_BOOL(&var) != VARIANT_FALSE);
                return S_OK;
            }
        }
        break;

    case DISPID_ONCONTENT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetOnContent().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetOnContent(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_OFFCONTENT:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetOffContent().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetOffContent(V_BSTR(&var));
                return S_OK;
            }
        }
        break;

    case DISPID_HEADER:
        if (wFlags & DISPATCH_PROPERTYGET)
        {
            V_VT(pVarResult) = VT_BSTR;
            V_BSTR(pVarResult) = SysAllocString(GetHeader().c_str());
            return S_OK;
        }
        else if (wFlags & DISPATCH_PROPERTYPUT)
        {
            VariantGuard var;
            if (SUCCEEDED(VariantChangeType(&var, &pDispParams->rgvarg[0], 0, VT_BSTR)))
            {
                SetHeader(V_BSTR(&var));
                return S_OK;
            }
        }
        break;
    }

    return DISP_E_MEMBERNOTFOUND;
}
