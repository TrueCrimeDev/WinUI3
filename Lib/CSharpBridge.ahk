#Requires AutoHotkey v2.0

; =============================================================================
; CSharpBridge - Runtime C# compilation with WinUI3 references
; =============================================================================
; Wraps DotNet.ahk's CompileAssembly to add WinUI3 DLL references
; so compiled C# code can use Microsoft.UI.Xaml types.
;
; Usage:
;   assembly := CSharpBridge.Compile(csharpCode, "MyAssembly")
;   instance := assembly.CreateInstance("MyClassName")
;
; Or one-liner:
;   instance := CSharpBridge.CreateInstance(csharpCode, "MyClassName", "MyAssembly")

class CSharpBridge {
    static _cache := Map()
    static _winuiDll := ""

    /**
     * Path to Microsoft.WinUI.dll for reference resolution.
     */
    static WinUIDll {
        get {
            if this._winuiDll = ""
                this._winuiDll := this._FindWinUIDll()
            return this._winuiDll
        }
    }

    static _FindWinUIDll() {
        SplitPath(A_LineFile, , &dir)
        candidates := [
            dir "\..\DotNet.ahk\WinUI3\Microsoft.WinUI.dll",
            dir "\..\DotNet.ahk\Microsoft.WinUI.dll",
            A_ScriptDir "\Microsoft.WinUI.dll",
        ]
        for p in candidates
            if FileExist(p)
                return p
        return ""
    }

    /**
     * Compile C# code and return the assembly IDispatch.
     * Results are cached by name to avoid recompilation.
     * @param code The C# source code
     * @param name Assembly name (also used as cache key)
     * @returns Assembly IDispatch with CreateInstance() method
     */
    static Compile(code, name := "") {
        if name != "" && this._cache.Has(name)
            return this._cache[name]

        refs := this.WinUIDll
        assembly := DotNet.CompileAssembly(code, name, refs)

        if name != ""
            this._cache[name] := assembly
        return assembly
    }

    /**
     * Compile C# code and create an instance of the specified class.
     * @param code The C# source code
     * @param className The class to instantiate
     * @param name Assembly name for caching
     * @returns IDispatch instance of the class
     */
    static CreateInstance(code, className, name := "") {
        assembly := this.Compile(code, name)
        return assembly.CreateInstance(className)
    }
}
