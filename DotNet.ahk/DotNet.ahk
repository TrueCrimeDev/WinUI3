#Requires AutoHotkey v2.0

DotNet_LoadLibrary(AssemblyName) {
    return DotNet.LoadAssembly(AssemblyName)
}

; class DotNet_Change_Path {
;     static _ := DotNet_LoadLibrary.AHK_DotNet_Interop_Path := "C:\custom\AHK_Dotnet_Interop.dll"
; }

class DotNet {

    static __New() {
        SplitPath A_LineFile,, &A_LineDir
        toSort:=[]
        Loop Files "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\*", "D" {
            ; semver: major.minor.patch-prerelease
            RegExMatch(A_LoopFileName, "^(\d+)\.(\d+)\.(\d+)(?:-(.+))?$", &OutputVar)
            if (!OutputVar) {
                continue
            }
            ; Only include versions that actually have the runtime (coreclr.dll)
            if !FileExist(A_LoopFileFullPath "\coreclr.dll")
                continue
            toSort.Push(OutputVar)
        }
        if (!toSort.Length) {
            throw Error("No .NET version found in C:\Program Files\dotnet\shared\Microsoft.NETCore.App")
        }
        InsertionSort(toSort, semver_cmp)
        latest_version := toSort[toSort.Length]
        NETCore_path := "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\" latest_version.0
        WindowsDesktop_path := "C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App\" latest_version.0
        ; AspNetCore_path := "C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\" latest_version.0
        coreclr_fullpath := NETCore_path "\coreclr.dll"
        coreclr_hModule := DllCall("LoadLibraryW", "WStr", coreclr_fullpath, "Ptr")
        SplitPath A_AhkPath,, &exeDir
        AHK_DotNet_Interop_Path := DotNet_LoadLibrary.HasOwnProp("AHK_DotNet_Interop_Path") ? DotNet_LoadLibrary.AHK_DotNet_Interop_Path : A_LineDir "\AHK_DotNet_Interop.dll"
        CodeAnalysis_Path := DotNet_LoadLibrary.HasOwnProp("CodeAnalysis_Path") ? DotNet_LoadLibrary.CodeAnalysis_Path : A_LineDir "\Microsoft.CodeAnalysis.dll"
        CodeAnalysis_CSharp_Path := DotNet_LoadLibrary.HasOwnProp("CodeAnalysis_CSharp_Path") ? DotNet_LoadLibrary.CodeAnalysis_CSharp_Path : A_LineDir "\Microsoft.CodeAnalysis.CSharp.dll"
        TRUSTED_PLATFORM_ASSEMBLIES := ";" AHK_DotNet_Interop_Path
        TRUSTED_PLATFORM_ASSEMBLIES .= ";" CodeAnalysis_Path
        TRUSTED_PLATFORM_ASSEMBLIES .= ";" CodeAnalysis_CSharp_Path
        Loop Files NETCore_path "\*.dll", "F" {
            TRUSTED_PLATFORM_ASSEMBLIES .= ";" A_LoopFileFullPath
        }
        Loop Files WindowsDesktop_path "\*.dll", "F" {
            TRUSTED_PLATFORM_ASSEMBLIES .= ";" A_LoopFileFullPath
        }
        ; Loop Files AspNetCore_path "\*.dll", "F" {
        ;     TRUSTED_PLATFORM_ASSEMBLIES .= ";" A_LoopFileFullPath
        ; }
        propertyKeys := Buffer(A_PtrSize)
        propertyValues := Buffer(A_PtrSize)
        TRUSTED_PLATFORM_ASSEMBLIES_KEY := UTF8("TRUSTED_PLATFORM_ASSEMBLIES")
        NumPut("Ptr", TRUSTED_PLATFORM_ASSEMBLIES_KEY.Ptr, propertyKeys)
        TRUSTED_PLATFORM_ASSEMBLIES_VALUE := UTF8(TRUSTED_PLATFORM_ASSEMBLIES)
        NumPut("Ptr", TRUSTED_PLATFORM_ASSEMBLIES_VALUE.Ptr, propertyValues)
        ; https://github.com/dotnet/runtime/blob/main/src/coreclr/hosts/inc/coreclrhost.h
        DllCall("coreclr\coreclr_initialize", "Ptr", UTF8(exeDir), "AStr", "AutoHotkeyHost", "Int", 1, "Ptr", propertyKeys, "Ptr", propertyValues, "Ptr*", &hostHandle:=0, "Uint*", &domainId:=0)
        DllCall("coreclr\coreclr_create_delegate", "Ptr", hostHandle, "Uint", domainId, "AStr", "System.Private.CoreLib", "AStr", "Internal.Runtime.InteropServices.ComponentActivator", "AStr", "LoadAssemblyBytes", "Ptr*", &load_assembly_bytes:=0)
        ; https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/Internal/Runtime/InteropServices/ComponentActivator.cs
        ; https://github.com/dotnet/runtime/blob/main/src/native/corehost/coreclr_delegates.h
        DllCall("coreclr\coreclr_create_delegate", "Ptr", hostHandle, "Uint", domainId, "AStr", "AHK_DotNet_Interop", "AStr", "AHK_DotNet_Interop.Lib", "AStr", "GetClass", "Ptr*", &GetClass_delegate:=0)
        DotNet.__GetClass_delegate := GetClass_delegate
        DllCall("coreclr\coreclr_create_delegate", "Ptr", hostHandle, "Uint", domainId, "AStr", "AHK_DotNet_Interop", "AStr", "AHK_DotNet_Interop.Lib", "AStr", "LoadAssembly", "Ptr*", &LoadAssembly_delegate:=0)
        DotNet.__LoadAssembly_delegate := LoadAssembly_delegate
        DllCall("coreclr\coreclr_create_delegate", "Ptr", hostHandle, "Uint", domainId, "AStr", "AHK_DotNet_Interop", "AStr", "AHK_DotNet_Interop.Lib", "AStr", "CompileAssembly", "Ptr*", &CompileAssembly_delegate:=0)
        DotNet.__CompileAssembly_delegate := CompileAssembly_delegate

        this.CompilerWrapper_Path := DotNet_LoadLibrary.HasOwnProp("CompilerWrapper_Path") ? DotNet_LoadLibrary.CompilerWrapper_Path : A_LineDir "\CSharpCompileServer\CompilerWrapper.dll"

        this.compileServerStarted := false

        _Type := DotNet.using("System.Type")
        _Type.GetType("System.Console, System.Console")

        UTF8(str) {
            ; StrPut: In 2-parameter mode, this function returns the required buffer size in bytes,
            ; including space for the null-terminator.
            buf := Buffer(StrPut(str, "UTF-8"))
            StrPut(str, buf, "UTF-8")
            return buf
        }

        semver_cmp(a, b) {
            major := a.1 - b.1
            if (major) {
                return major
            }
            minor := a.2 - b.2
            if (minor) {
                return minor
            }
            patch := a.3 - b.3
            if (patch) {
                return patch
            }
            ; no pre-release is higher
            if (!a.4) {
                return 1
            }
            if (!b.4) {
                return -1
            }
            ; string compare (bad)
            return a > b ? 1 : -1 ; cannot be equal, so else is a < b
        }

        InsertionSort(A, cmp) {
            ; https://en.wikipedia.org/wiki/Insertion_sort#Algorithm
            ; i ← 1
            ; while i < length(A)
            ;     x ← A[i]
            ;     j ← i
            ;     while j > 0 and A[j-1] > x
            ;         A[j] ← A[j-1]
            ;         j ← j - 1
            ;     end while
            ;     A[j] ← x
            ;     i ← i + 1
            ; end while
            i := 2
            while (i <= A.Length) {
                x := A[i]
                j := i
                while (j > 1 && cmp(A[j-1], x) > 0) {
                    A[j] := A[j - 1]
                    j := j - 1
                }
                A[j] := x
                i := i + 1
            }
            return A
        }
    }

    static LoadAssembly(path) {
        DllCall(DotNet.__LoadAssembly_delegate, "WStr", path, "Ptr*", IDisPatch:=ComValue(9, 0))
        return IDisPatch
    }

    static EnsureCompileServer() {
        if (!this.compileServerStarted) {
            this.compileServerStarted := true
            if (!DllCall("WaitNamedPipeW", "WStr", "\\.\pipe\CSharp-Compiler-Wrapper", "Uint", 0)) {
                run_cmd := "`"C:\Program Files\dotnet\dotnet.exe`" `"" this.CompilerWrapper_Path "`""
                Run run_cmd,, "hide" ; C# side waits for pipe to exist, no need to wait here
            }
            ; try {
                ; FileOpen("\\.\pipe\CSharp-Compiler-Wrapper", "r").Close()
            ; } catch Error as e {
            ;     if (e.Message == "(2) The system cannot find the file specified.") {
            ;         throw
            ;     }
            ; }
        }
    }

    static CompileAssembly(code, assemblyName:="", externalReferences:="") {
        if (!this.compileServerStarted) {
            this.EnsureCompileServer()
        }
        DllCall(DotNet.__CompileAssembly_delegate, "WStr", code, "WStr", assemblyName, "WStr", externalReferences, "Ptr*", IDisPatch:=ComValue(9, 0))
        return IDisPatch
    }

    static using(FullName) {
        DllCall(DotNet.__GetClass_delegate, "AStr", FullName, "Ptr*", IDisPatch:=ComValue(9, 0))
        return IDisPatch
    }
}

; Console := DotNet.using("System.Console")
; Console.WriteLine("Hello from C#")

; File_ := DotNet.using("System.IO.File")
; Console.WriteLine(File_.ReadAllText(A_LineFile))
