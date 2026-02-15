#Requires AutoHotkey v2.0

; =============================================================================
; RelayCommandHelper - ICommand bridge from C# to AHK callbacks
; =============================================================================
; Creates .NET ICommand objects that delegate to AHK callback objects.
; The AHK callback must have a Call(param) method.

class RelayCommandHelper {
    static _compiled := false
    static _factory := ""

    static _code := "
    (
    using System;

    public class SimpleCommand
    {
        private dynamic _callback;

        public SimpleCommand(dynamic callback)
        {
            _callback = callback;
        }

        public void Execute(string parameter)
        {
            try { _callback.Call(parameter); }
            catch { }
        }

        public bool CanExecute(string parameter)
        {
            return true;
        }
    }

    public class CommandFactory
    {
        public SimpleCommand Create(dynamic callback)
        {
            return new SimpleCommand(callback);
        }
    }
    )"

    static Init() {
        if this._compiled
            return
        this._factory := CSharpBridge.CreateInstance(this._code, "CommandFactory", "RelayCommandHelper")
        this._compiled := true
    }

    static Create(callback) {
        this.Init()
        return this._factory.Create(callback)
    }
}
