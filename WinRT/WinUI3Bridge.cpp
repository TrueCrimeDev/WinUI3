#include "pch.h"
#include "XamlHost.h"

// Windows App SDK Bootstrap types (if not included)
#ifndef PACKAGE_VERSION_DEFINED
#define PACKAGE_VERSION_DEFINED
typedef struct PACKAGE_VERSION
{
    UINT16 Revision;
    UINT16 Build;
    UINT16 Minor;
    UINT16 Major;
} PACKAGE_VERSION;
#endif

// Global state
static bool g_initialized = false;
static winrt::Microsoft::UI::Xaml::Application g_application{ nullptr };
static std::mutex g_mutex;

// DLL Entry Point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        DisableThreadLibraryCalls(hModule);
        TRACE(L"WinUI3Bridge DLL loaded");
        break;
        
    case DLL_PROCESS_DETACH:
        TRACE(L"WinUI3Bridge DLL unloading");
        break;
    }
    return TRUE;
}

// Check if Windows App SDK is available
extern "C" __declspec(dllexport) BOOL IsWinUI3Available()
{
    TRACE(L"IsWinUI3Available called");
    
    // Try to load the Windows App SDK DLL
    HMODULE hMod = LoadLibraryW(L"Microsoft.ui.xaml.dll");
    if (hMod)
    {
        FreeLibrary(hMod);
        TRACE(L"Windows App SDK detected");
        return TRUE;
    }
    
    // Try alternate location
    hMod = LoadLibraryW(L"Microsoft.WindowsAppRuntime.dll");
    if (hMod)
    {
        FreeLibrary(hMod);
        TRACE(L"Windows App Runtime detected");
        return TRUE;
    }
    
    TRACE(L"Windows App SDK not found");
    return FALSE;
}

// Initialize WinUI 3 runtime
extern "C" __declspec(dllexport) BOOL InitWinUI()
{
    std::lock_guard<std::mutex> lock(g_mutex);
    
    TRACE(L"InitWinUI called");
    
    if (g_initialized)
    {
        TRACE(L"Already initialized");
        return TRUE;
    }
    
    try
    {
        // Initialize WinRT
        winrt::init_apartment(winrt::apartment_type::single_threaded);
        
        // Initialize Windows App SDK
        // Note: This requires the WindowsAppSDK NuGet package
        
        // For XAML Islands, we need to initialize the XAML application
        // This is typically done by calling WindowsAppSDK bootstrap API
        
        // Try to load the bootstrapper
        HMODULE hBootstrap = LoadLibraryW(L"Microsoft.WindowsAppRuntime.Bootstrap.dll");
        if (hBootstrap)
        {
            typedef HRESULT(WINAPI* PFN_BOOTSTRAP_INITIALIZE)(UINT32, PCWSTR, PACKAGE_VERSION);
            auto pfnInit = (PFN_BOOTSTRAP_INITIALIZE)GetProcAddress(hBootstrap, "MddBootstrapInitialize");
            
            if (pfnInit)
            {
                // Windows App SDK 1.4+ version
                PACKAGE_VERSION minVersion = {};
                minVersion.Major = 1;
                minVersion.Minor = 4;
                
                HRESULT hr = pfnInit(0x00010004, nullptr, minVersion);
                if (FAILED(hr))
                {
                    TRACE(L"MddBootstrapInitialize failed: 0x%08X", hr);
                    // Continue anyway - might work if SDK is already initialized
                }
            }
        }
        
        g_initialized = true;
        TRACE(L"WinUI 3 initialized successfully");
        return TRUE;
    }
    catch (const winrt::hresult_error& e)
    {
        TRACE(L"InitWinUI WinRT error: 0x%08X - %s", e.code().value, e.message().c_str());
        return FALSE;
    }
    catch (const std::exception& e)
    {
        TRACE(L"InitWinUI exception: %S", e.what());
        return FALSE;
    }
}

// Uninitialize WinUI 3 runtime
extern "C" __declspec(dllexport) void UninitWinUI()
{
    std::lock_guard<std::mutex> lock(g_mutex);
    
    TRACE(L"UninitWinUI called");
    
    if (!g_initialized)
        return;
    
    try
    {
        // Shutdown bootstrap
        HMODULE hBootstrap = GetModuleHandleW(L"Microsoft.WindowsAppRuntime.Bootstrap.dll");
        if (hBootstrap)
        {
            typedef void(WINAPI* PFN_BOOTSTRAP_SHUTDOWN)();
            auto pfnShutdown = (PFN_BOOTSTRAP_SHUTDOWN)GetProcAddress(hBootstrap, "MddBootstrapShutdown");
            if (pfnShutdown)
            {
                pfnShutdown();
            }
        }
        
        g_application = nullptr;
        g_initialized = false;
        
        winrt::uninit_apartment();
        
        TRACE(L"WinUI 3 uninitialized");
    }
    catch (...)
    {
        TRACE(L"UninitWinUI exception");
    }
}

// Create a new XAML host
extern "C" __declspec(dllexport) IDispatch* CreateXamlHost()
{
    TRACE(L"CreateXamlHost called");
    
    if (!g_initialized)
    {
        TRACE(L"WinUI not initialized");
        return nullptr;
    }
    
    try
    {
        XamlHost* host = new XamlHost();
        TRACE(L"XamlHost created: %p", host);
        return static_cast<IDispatch*>(host);
    }
    catch (const std::exception& e)
    {
        TRACE(L"CreateXamlHost exception: %S", e.what());
        return nullptr;
    }
}

// Get version info (named differently to avoid Windows API conflict)
extern "C" __declspec(dllexport) void GetBridgeVersion(LPWSTR buffer, int bufferSize)
{
    wcscpy_s(buffer, bufferSize, L"WinUI3Bridge v1.0.0");
}
