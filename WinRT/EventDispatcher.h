#pragma once
#include "pch.h"

// ============================================================================
// EventDispatcher - Bridges WinUI 3 events to AutoHotkey callbacks
// ============================================================================
// Stores a pointer to an AHK object that has an Invoke() method.
// Uses mutex for thread safety and validates callback before invocation.

class EventDispatcher
{
public:
    explicit EventDispatcher(LONGLONG ahkCallbackPtr);
    ~EventDispatcher();

    // Non-copyable but moveable
    EventDispatcher(const EventDispatcher&) = delete;
    EventDispatcher& operator=(const EventDispatcher&) = delete;
    EventDispatcher(EventDispatcher&& other) noexcept;
    EventDispatcher& operator=(EventDispatcher&& other) noexcept;

    // Called by WinUI 3 event handlers
    void Invoke();
    void Invoke(winrt::IInspectable const& sender, winrt::RoutedEventArgs const& args);

    // Invoke with event arguments (for enhanced callback support)
    void InvokeWithArgs(const std::wstring& eventName,
                        const std::wstring& elementName = L"");

    // Get the stored callback pointer
    LONGLONG GetCallbackPtr() const noexcept { return m_callbackPtr; }

    // Check if dispatcher is valid
    bool IsValid() const noexcept { return m_callbackPtr != 0; }

    // Invalidate the dispatcher (for cleanup without destruction)
    void Invalidate() noexcept;

private:
    LONGLONG m_callbackPtr;
    mutable std::mutex m_mutex;
    bool m_isValid;
};

// ============================================================================
// EventRevokerStorage - Type-erased storage for WinRT event revokers
// ============================================================================
// WinRT event_revoker types are all different, so we use type erasure
// to store them uniformly. When destroyed, the revoker automatically
// unregisters the event handler.

class IEventRevoker
{
public:
    virtual ~IEventRevoker() = default;
    virtual void Revoke() = 0;
};

template<typename TRevoker>
class EventRevokerImpl : public IEventRevoker
{
public:
    explicit EventRevokerImpl(TRevoker&& revoker)
        : m_revoker(std::move(revoker))
    {}

    void Revoke() override
    {
        m_revoker.revoke();
    }

private:
    TRevoker m_revoker;
};

// Factory function to create type-erased revokers
template<typename TRevoker>
std::unique_ptr<IEventRevoker> MakeEventRevoker(TRevoker&& revoker)
{
    return std::make_unique<EventRevokerImpl<std::decay_t<TRevoker>>>(
        std::forward<TRevoker>(revoker));
}

// ============================================================================
// EventRegistration - Stores all data for a registered event
// ============================================================================
// Owns the EventDispatcher and revoker. When destroyed, automatically
// revokes the event handler (via the revoker destructor).

struct EventRegistration
{
    std::wstring elementName;
    std::wstring eventName;
    std::unique_ptr<EventDispatcher> dispatcher;
    std::unique_ptr<IEventRevoker> revoker;  // Type-erased revoker

    // Default constructors for container use
    EventRegistration() = default;

    // Move-only semantics
    EventRegistration(const EventRegistration&) = delete;
    EventRegistration& operator=(const EventRegistration&) = delete;
    EventRegistration(EventRegistration&&) = default;
    EventRegistration& operator=(EventRegistration&&) = default;

    // Explicit cleanup
    void Revoke()
    {
        if (revoker)
        {
            revoker->Revoke();
            revoker.reset();
        }
        if (dispatcher)
        {
            dispatcher->Invalidate();
        }
    }

    ~EventRegistration()
    {
        Revoke();
    }
};
