@echo off
REM ============================================================================
REM Build Script for WinUI3Bridge
REM ============================================================================
REM Usage:
REM   build.bat             - Build Release (default)
REM   build.bat debug       - Build Debug
REM   build.bat clean       - Clean build directory
REM   build.bat rebuild     - Clean and rebuild
REM   build.bat vs          - Generate Visual Studio solution
REM ============================================================================

setlocal enabledelayedexpansion

REM Configuration
set BUILD_TYPE=Release
set GENERATOR=Ninja
set BUILD_DIR=build

REM Parse arguments
if "%1"=="debug" (
    set BUILD_TYPE=Debug
    shift
)
if "%1"=="Debug" (
    set BUILD_TYPE=Debug
    shift
)
if "%1"=="clean" (
    echo Cleaning build directory...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    echo Done.
    goto :eof
)
if "%1"=="rebuild" (
    echo Cleaning build directory...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    goto :build
)
if "%1"=="vs" (
    echo Generating Visual Studio 2022 solution...
    cmake -B build-vs -G "Visual Studio 17 2022" -A x64
    if errorlevel 1 goto :error
    echo.
    echo Solution generated at: build-vs\WinUI3Bridge.sln
    echo Opening in Visual Studio...
    start "" "build-vs\WinUI3Bridge.sln"
    goto :eof
)

:build
echo.
echo ============================================
echo Building WinUI3Bridge (%BUILD_TYPE%)
echo ============================================
echo.

REM Check for Visual Studio environment
where cl >nul 2>&1
if errorlevel 1 (
    echo Setting up Visual Studio environment...

    REM Try VS 2022
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
        call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
    ) else (
        echo ERROR: Could not find Visual Studio. Please run from Developer Command Prompt.
        exit /b 1
    )
)

REM Check for Ninja
where ninja >nul 2>&1
if errorlevel 1 (
    echo Ninja not found, using NMake Makefiles instead...
    set GENERATOR=NMake Makefiles
)

REM Check for NuGet packages
if not exist "packages\Microsoft.WindowsAppSDK.1.4.231219000" (
    echo.
    echo NuGet packages not found. Installing...
    if exist "nuget.exe" (
        nuget.exe restore packages.config -PackagesDirectory packages
    ) else (
        echo ERROR: nuget.exe not found. Please run:
        echo   nuget restore packages.config -PackagesDirectory packages
        exit /b 1
    )
)

REM Configure
echo Configuring with CMake...
cmake -B "%BUILD_DIR%\%BUILD_TYPE%" -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=%BUILD_TYPE%
if errorlevel 1 goto :error

REM Build
echo.
echo Building...
cmake --build "%BUILD_DIR%\%BUILD_TYPE%" --config %BUILD_TYPE%
if errorlevel 1 goto :error

echo.
echo ============================================
echo Build successful!
echo Output: WinUI3Bridge.dll
echo ============================================
goto :eof

:error
echo.
echo ============================================
echo BUILD FAILED
echo ============================================
exit /b 1
