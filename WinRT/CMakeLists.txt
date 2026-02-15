# ============================================================================
# CMakeLists.txt - WinUI3Bridge
# ============================================================================
# Cross-platform build system for the WinUI3 <-> AutoHotkey bridge DLL.
# Supports Visual Studio 2019/2022 and Ninja builds.
#
# Quick Start:
#   cmake -B build -G "Visual Studio 17 2022" -A x64
#   cmake --build build --config Release
#
# Or with presets:
#   cmake --preset vs2022-release
#   cmake --build --preset vs2022-release
# ============================================================================

cmake_minimum_required(VERSION 3.21)

project(WinUI3Bridge
    VERSION 1.0.0
    DESCRIPTION "WinUI3 XAML Islands Bridge for AutoHotkey"
    LANGUAGES CXX
)

# ============================================================================
# Build Options
# ============================================================================

option(WINUI3_ENABLE_DEBUG_TRACE "Enable debug trace output" ON)
option(WINUI3_USE_PRECOMPILED_HEADERS "Use precompiled headers for faster builds" ON)
option(WINUI3_ENABLE_ASAN "Enable Address Sanitizer (Debug builds)" OFF)

# ============================================================================
# Global Settings
# ============================================================================

# C++20 is required for WinRT/C++ and modern features
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Windows-specific settings
if(WIN32)
    # Use Unicode
    add_compile_definitions(UNICODE _UNICODE)

    # Windows SDK version (10.0 = latest)
    set(CMAKE_SYSTEM_VERSION "10.0" CACHE STRING "Windows SDK version")

    # Default to x64 if not specified
    if(NOT CMAKE_GENERATOR_PLATFORM AND NOT CMAKE_VS_PLATFORM_NAME)
        set(CMAKE_GENERATOR_PLATFORM "x64" CACHE STRING "Target platform")
    endif()
endif()

# ============================================================================
# Find Dependencies
# ============================================================================

# Windows App SDK paths (NuGet packages)
set(WASDK_VERSION "1.4.231219000")
set(CPPWINRT_VERSION "2.0.230706.1")

set(WASDK_PATH "${CMAKE_CURRENT_SOURCE_DIR}/packages/Microsoft.WindowsAppSDK.${WASDK_VERSION}")
set(CPPWINRT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/packages/Microsoft.Windows.CppWinRT.${CPPWINRT_VERSION}")

# Verify packages exist
if(NOT EXISTS "${WASDK_PATH}")
    message(FATAL_ERROR
        "Windows App SDK not found at: ${WASDK_PATH}\n"
        "Please run 'nuget restore packages.config' to install dependencies."
    )
endif()

if(NOT EXISTS "${CPPWINRT_PATH}")
    message(FATAL_ERROR
        "C++/WinRT not found at: ${CPPWINRT_PATH}\n"
        "Please run 'nuget restore packages.config' to install dependencies."
    )
endif()

# ============================================================================
# Type Library Generation (IDL -> TLB)
# ============================================================================

# Find MIDL compiler
find_program(MIDL_EXECUTABLE midl
    HINTS
        "$ENV{WindowsSdkDir}/bin/${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}/x64"
        "$ENV{WindowsSdkDir}/bin/x64"
        "C:/Program Files (x86)/Windows Kits/10/bin/10.0.22621.0/x64"
        "C:/Program Files (x86)/Windows Kits/10/bin/10.0.19041.0/x64"
)

if(MIDL_EXECUTABLE)
    message(STATUS "MIDL compiler found: ${MIDL_EXECUTABLE}")

    set(IDL_FILE "${CMAKE_CURRENT_SOURCE_DIR}/WinUI3Bridge.idl")
    set(TLB_FILE "${CMAKE_CURRENT_BINARY_DIR}/WinUI3Bridge.tlb")
    set(HEADER_FILE "${CMAKE_CURRENT_BINARY_DIR}/WinUI3Bridge_i.h")
    set(IID_FILE "${CMAKE_CURRENT_BINARY_DIR}/WinUI3Bridge_i.c")

    add_custom_command(
        OUTPUT ${TLB_FILE} ${HEADER_FILE} ${IID_FILE}
        COMMAND ${MIDL_EXECUTABLE}
            /nologo
            /W3
            /char signed
            /env x64
            /h "WinUI3Bridge_i.h"
            /iid "WinUI3Bridge_i.c"
            /tlb "WinUI3Bridge.tlb"
            /out "${CMAKE_CURRENT_BINARY_DIR}"
            "${IDL_FILE}"
        DEPENDS ${IDL_FILE}
        COMMENT "Compiling IDL file to generate type library"
        VERBATIM
    )

    add_custom_target(TypeLibrary DEPENDS ${TLB_FILE})

    # Copy TLB to source directory for distribution
    add_custom_command(TARGET TypeLibrary POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${TLB_FILE}"
            "${CMAKE_CURRENT_SOURCE_DIR}/WinUI3Bridge.tlb"
        COMMENT "Copying WinUI3Bridge.tlb to project root"
    )
else()
    message(WARNING "MIDL compiler not found - type library will not be generated")
endif()

# ============================================================================
# WinUI3Bridge Library
# ============================================================================

add_library(WinUI3Bridge SHARED
    # Source files
    pch.cpp
    WinUI3Bridge.cpp
    XamlHost.cpp
    EventDispatcher.cpp
    ControlWrappers.cpp
    PropertyReflection.cpp

    # Headers (for IDE visibility)
    pch.h
    XamlHost.h
    EventDispatcher.h
    IControlWrapper.h
    ControlWrappers.h
    PropertyReflection.h

    # Module definition for exports
    WinUI3Bridge.def
)

# Set target properties
set_target_properties(WinUI3Bridge PROPERTIES
    # Output name (without lib prefix on Windows)
    OUTPUT_NAME "WinUI3Bridge"
    PREFIX ""

    # Use Windows subsystem
    WIN32_EXECUTABLE FALSE

    # Generate .pdb for Release builds too
    COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
    COMPILE_PDB_NAME "WinUI3Bridge"

    # Version info
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
)

# ============================================================================
# Include Directories
# ============================================================================

target_include_directories(WinUI3Bridge PRIVATE
    # Project includes
    ${CMAKE_CURRENT_SOURCE_DIR}

    # Windows App SDK
    "${WASDK_PATH}/include"
    "${WASDK_PATH}/include/winrt"

    # C++/WinRT
    "${CPPWINRT_PATH}/build/native/include"
)

# ============================================================================
# Link Libraries
# ============================================================================

# Platform-specific library path
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(WASDK_ARCH "x64")
else()
    set(WASDK_ARCH "x86")
endif()

target_link_directories(WinUI3Bridge PRIVATE
    "${WASDK_PATH}/lib/win10-${WASDK_ARCH}"
)

target_link_libraries(WinUI3Bridge PRIVATE
    # Windows App SDK runtime
    Microsoft.WindowsAppRuntime

    # Windows system libraries
    dwmapi
    ole32
    oleaut32
    uuid
    user32
    gdi32
    advapi32
    shell32
)

# ============================================================================
# Compile Definitions
# ============================================================================

target_compile_definitions(WinUI3Bridge PRIVATE
    # Windows version targeting
    WINVER=0x0A00
    _WIN32_WINNT=0x0A00
    NTDDI_VERSION=0x0A000007

    # Lean Windows headers
    WIN32_LEAN_AND_MEAN
    NOMINMAX
    STRICT

    # DLL export
    _USRDLL
    _WINDOWS

    # Debug-specific
    $<$<CONFIG:Debug>:_DEBUG>
    $<$<CONFIG:Release>:NDEBUG>
)

# Debug trace option
if(WINUI3_ENABLE_DEBUG_TRACE)
    target_compile_definitions(WinUI3Bridge PRIVATE
        $<$<CONFIG:Debug>:WINUI3_DEBUG_TRACE>
    )
endif()

# ============================================================================
# Compile Options
# ============================================================================

target_compile_options(WinUI3Bridge PRIVATE
    # Warning level
    /W4
    /WX-  # Warnings not as errors (for now)

    # Standard conformance
    /permissive-
    /Zc:__cplusplus
    /Zc:preprocessor

    # C++/WinRT specific
    /await:strict
    /bigobj

    # Optimization
    $<$<CONFIG:Debug>:/Od /Zi /RTC1>
    $<$<CONFIG:Release>:/O2 /Oi /GL /Gy>

    # Runtime library
    $<$<CONFIG:Debug>:/MDd>
    $<$<CONFIG:Release>:/MD>

    # Exception handling
    /EHsc
)

# Link options
target_link_options(WinUI3Bridge PRIVATE
    # Release optimizations
    $<$<CONFIG:Release>:/LTCG /OPT:REF /OPT:ICF>

    # Debug info
    /DEBUG:FULL
)

# ============================================================================
# Precompiled Headers
# ============================================================================

if(WINUI3_USE_PRECOMPILED_HEADERS)
    target_precompile_headers(WinUI3Bridge PRIVATE
        "$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch.h>"
    )
endif()

# ============================================================================
# Address Sanitizer (Optional)
# ============================================================================

if(WINUI3_ENABLE_ASAN AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(WinUI3Bridge PRIVATE /fsanitize=address)
    target_link_options(WinUI3Bridge PRIVATE /fsanitize=address)
endif()

# ============================================================================
# Post-Build: Copy DLL to Project Root
# ============================================================================

add_custom_command(TARGET WinUI3Bridge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:WinUI3Bridge>"
        "${CMAKE_CURRENT_SOURCE_DIR}/WinUI3Bridge.dll"
    COMMENT "Copying WinUI3Bridge.dll to project root"
)

# Also copy PDB in Debug builds
add_custom_command(TARGET WinUI3Bridge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E $<IF:$<CONFIG:Debug>,copy_if_different,true>
        "$<TARGET_FILE_DIR:WinUI3Bridge>/WinUI3Bridge.pdb"
        "${CMAKE_CURRENT_SOURCE_DIR}/WinUI3Bridge.pdb"
    COMMENT "Copying PDB to project root (Debug only)"
)

# ============================================================================
# Install Rules
# ============================================================================

include(GNUInstallDirs)

install(TARGETS WinUI3Bridge
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(FILES
    XamlHost.h
    EventDispatcher.h
    pch.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/WinUI3Bridge
)

# ============================================================================
# CPack Configuration (Optional)
# ============================================================================

set(CPACK_PACKAGE_NAME "WinUI3Bridge")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_GENERATOR "ZIP")
include(CPack)

# ============================================================================
# Print Configuration Summary
# ============================================================================

message(STATUS "")
message(STATUS "=== WinUI3Bridge Configuration ===")
message(STATUS "  Version:              ${PROJECT_VERSION}")
message(STATUS "  C++ Standard:         C++${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type:           ${CMAKE_BUILD_TYPE}")
message(STATUS "  Windows App SDK:      ${WASDK_VERSION}")
message(STATUS "  C++/WinRT:            ${CPPWINRT_VERSION}")
message(STATUS "  Precompiled Headers:  ${WINUI3_USE_PRECOMPILED_HEADERS}")
message(STATUS "  Debug Trace:          ${WINUI3_ENABLE_DEBUG_TRACE}")
message(STATUS "")
