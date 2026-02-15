#include "pch.h"
#include "EventDispatcher.h"

// ============================================================================
// EventDispatcher Implementation
// ============================================================================

EventDispatcher::EventDispatcher(LONGLONG ahkCallbackPtr)
    : m_callbackPtr(ahkCallbackPtr)
    , m_isValid(ahkCallbackPtr != 0)
{
    TRACE(L"EventDispatcher created with callback: 0x%llX", ahkCallbackPtr);
}

EventDispatcher::~EventDispatcher()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    m_isValid = false;
    m_callbackPtr = 0;
    TRACE(L"EventDispatcher destroyed");
}

EventDispatcher::EventDispatcher(EventDispatcher&& other) noexcept
    : m_callbackPtr(0)
    , m_isValid(false)
{
    std::lock_guard<std::mutex> lock(other.m_mutex);
    m_callbackPtr = other.m_callbackPtr;
    m_isValid = other.m_isValid;
    other.m_callbackPtr = 0;
    other.m_isValid = false;
}

EventDispatcher& EventDispatcher::operator=(EventDispatcher&& other) noexcept
{
    if (this != &other)
    {
        std::scoped_lock lock(m_mutex, other.m_mutex);
        m_callbackPtr = other.m_callbackPtr;
        m_isValid = other.m_isValid;
        other.m_callbackPtr = 0;
        other.m_isValid = false;
    }
    return *this;
}

void EventDispatcher::Invalidate() noexcept
{
    std::lock_guard<std::mutex> lock(m_mutex);
    m_isValid = false;
    // Note: We don't clear m_callbackPtr here to allow for debugging
    TRACE(L"EventDispatcher invalidated");
}

void EventDispatcher::Invoke()
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (!m_isValid || m_callbackPtr == 0)
    {
        TRACE(L"EventDispatcher::Invoke - Invalid or invalidated callback");
        return;
    }

    TRACE(L"EventDispatcher::Invoke - Calling AHK callback at 0x%llX", m_callbackPtr);

    // The callback pointer is an AHK object pointer
    // We need to call its Invoke method via COM IDispatch
    IDispatch* pDispatch = reinterpret_cast<IDispatch*>(m_callbackPtr);

    if (!pDispatch)
    {
        TRACE(L"EventDispatcher::Invoke - Null IDispatch pointer");
        return;
    }

    try
    {
        DISPPARAMS params = { nullptr, nullptr, 0, 0 };
        VARIANT result;
        VariantInit(&result);

        // Try calling "Invoke" method first (DISPID lookup)
        DISPID dispid = 0;
        OLECHAR* methodName = const_cast<OLECHAR*>(L"Invoke");
        HRESULT hr = pDispatch->GetIDsOfNames(IID_NULL, &methodName, 1,
                                               LOCALE_USER_DEFAULT, &dispid);

        if (SUCCEEDED(hr))
        {
            hr = pDispatch->Invoke(dispid, IID_NULL, LOCALE_USER_DEFAULT,
                                   DISPATCH_METHOD, &params, &result,
                                   nullptr, nullptr);
            if (FAILED(hr))
            {
                TRACE(L"EventDispatcher::Invoke - IDispatch::Invoke failed: 0x%08X", hr);
            }
        }
        else
        {
            // Try calling as default method (DISPID 0)
            hr = pDispatch->Invoke(0, IID_NULL, LOCALE_USER_DEFAULT,
                                   DISPATCH_METHOD, &params, &result,
                                   nullptr, nullptr);
            if (FAILED(hr))
            {
                TRACE(L"EventDispatcher::Invoke - Default invoke failed: 0x%08X", hr);
            }
        }

        VariantClear(&result);
    }
    catch (const std::exception& e)
    {
        TRACE(L"EventDispatcher::Invoke - Exception: %S", e.what());
    }
    catch (...)
    {
        TRACE(L"EventDispatcher::Invoke - Unknown exception");
    }
}

void EventDispatcher::Invoke(winrt::IInspectable const& sender,
                             winrt::RoutedEventArgs const& args)
{
    // For now, just call the simple invoke
    // Future enhancement: pass sender and args info to AHK
    Invoke();
}

void EventDispatcher::InvokeWithArgs(const std::wstring& eventName,
                                      const std::wstring& elementName)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    if (!m_isValid || m_callbackPtr == 0)
    {
        TRACE(L"EventDispatcher::InvokeWithArgs - Invalid callback");
        return;
    }

    IDispatch* pDispatch = reinterpret_cast<IDispatch*>(m_callbackPtr);
    if (!pDispatch)
        return;

    try
    {
        // Build argument array (in reverse order for IDispatch)
        VARIANT args[2];
        VariantInit(&args[0]);
        VariantInit(&args[1]);

        // args[0] = eventName (last parameter)
        V_VT(&args[0]) = VT_BSTR;
        V_BSTR(&args[0]) = SysAllocString(eventName.c_str());

        // args[1] = elementName (first parameter)
        V_VT(&args[1]) = VT_BSTR;
        V_BSTR(&args[1]) = SysAllocString(elementName.c_str());

        DISPPARAMS params = {};
        params.rgvarg = args;
        params.cArgs = 2;
        params.rgdispidNamedArgs = nullptr;
        params.cNamedArgs = 0;

        VARIANT result;
        VariantInit(&result);

        // Call the callback
        HRESULT hr = pDispatch->Invoke(0, IID_NULL, LOCALE_USER_DEFAULT,
                                        DISPATCH_METHOD, &params, &result,
                                        nullptr, nullptr);

        // Cleanup
        VariantClear(&result);
        VariantClear(&args[0]);
        VariantClear(&args[1]);

        if (FAILED(hr))
        {
            TRACE(L"EventDispatcher::InvokeWithArgs - Invoke failed: 0x%08X", hr);
        }
    }
    catch (...)
    {
        TRACE(L"EventDispatcher::InvokeWithArgs - Exception");
    }
}
