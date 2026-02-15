#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

; =============================================================================
; WinUI3 - High-level AHK v2 wrapper for WinUI3Bridge.dll
; =============================================================================
; Provides typed control wrappers, one-line initialization, and a Window class
; that combines Gui + XAML island with auto-resize and dark mode support.

class WinUI3 {
    static _bridge := ""
    static _initialized := false
    static _windows := Map()
    static _dispatcherQueueController := ""

    ; =========================================================================
    ; Static Init / Shutdown
    ; =========================================================================

    /**
     * One-line initialization of the WinUI3 runtime.
     * @param {String} sdkVersion - Windows App SDK version (default "1.6")
     * @param {String} dllPath - Optional explicit path to WinUI3Bridge.dll
     * @returns {Boolean} true on success
     */
    static Init(sdkVersion := "1.6", dllPath := "") {
        if this._initialized
            return true

        ; Resolve DLL path
        if dllPath != ""
            this._bridge := dllPath

        if this._bridge = "" {
            SplitPath(A_LineFile, , &dir)
            candidates := [
                dir "\WinUI3Bridge.dll",
                dir "\..\GuiTesting\WinRT\WinUI3Bridge.dll",
                dir "\..\GuiTesting\WinRT\x64\Release\WinUI3Bridge.dll",
                A_ScriptDir "\WinUI3Bridge.dll",
            ]
            for _, p in candidates {
                if FileExist(p) {
                    this._bridge := p
                    break
                }
            }
            if this._bridge = ""
                this._bridge := candidates[1]
        }

        if !FileExist(this._bridge) {
            MsgBox(
                "WinUI3Bridge.dll not found.`n`n" this._bridge,
                "WinUI3 Bridge Missing", "Icon!"
            )
            return false
        }

        ; Load Windows App Runtime into package graph
        try UseWindowsAppRuntime(sdkVersion)

        ; Create DispatcherQueue for this thread (required before XAML island)
        this._EnsureDispatcherQueue()

        ; Load and initialize the bridge DLL
        DllCall("LoadLibrary", "str", this._bridge, "ptr")
        result := DllCall(this._bridge "\InitWinUI", "int")
        if !result {
            MsgBox("Failed to initialize WinUI3 runtime.", "WinUI3 Error", "Icon!")
            return false
        }

        ; Register cleanup on exit
        OnExit((*) => WinUI3.Shutdown())

        this._initialized := true
        return true
    }

    /**
     * Clean shutdown of all windows and the runtime.
     */
    static Shutdown() {
        if !this._initialized
            return

        for hwnd, win in this._windows
            win._Cleanup()
        this._windows.Clear()

        try DllCall(this._bridge "\UninitWinUI")
        this._initialized := false
    }

    /**
     * Create a DispatcherQueueController for the current thread.
     */
    static _EnsureDispatcherQueue() {
        if this._dispatcherQueueController
            return

        ; DispatcherQueueOptions struct: size=12, threadType=2 (DQTYPE_THREAD_CURRENT), apartmentType=2 (ASTA)
        options := Buffer(12, 0)
        NumPut("UInt", 12, "Int", 2, "Int", 2, options)
        try DllCall("CoreMessaging\CreateDispatcherQueueController",
            "Ptr", options, "Ptr*", &controller := 0, "HRESULT")
        this._dispatcherQueueController := controller
    }

    ; =========================================================================
    ; WinUI3.Window - Combines Gui + XamlHost into one object
    ; =========================================================================

    class Window {
        _gui := ""
        _host := ""
        _hostCom := ""
        _elements := Map()
        _handlers := Map()
        _handlerRefs := []
        _islandHwnd := 0
        _hasGetControl := -1  ; -1=unknown, 0=no, 1=yes

        /**
         * Create a new WinUI3 window.
         * @param {String} title - Window title
         * @param {String} options - Gui options (e.g. "w600 h400")
         * @param {Boolean} darkMode - Enable dark title bar (default true)
         * @param {String} backdrop - Backdrop type: "Mica", "Acrylic", "Tabbed", "None" (default "Mica")
         */
        __New(title := "WinUI3", options := "w800 h600", darkMode := true, backdrop := "Mica") {
            if !WinUI3._initialized
                throw Error("Call WinUI3.Init() first")

            ; Create the Gui window
            this._gui := Gui("+Resize", title)
            this._gui.BackColor := "0x202020"
            this._gui.Show(options)

            hwnd := this._gui.Hwnd

            ; Apply DWM styling
            if IsSet(DWM) {
                DWM.SetDarkMode(hwnd, darkMode)
                if DWM.IsWindows11() {
                    DWM.SetBackdrop(hwnd, backdrop)
                    DWM.SetCorners(hwnd, "Round")
                }
                DWM.ExtendFrameIntoClientArea(hwnd)
            }

            ; Create XAML host
            ptr := DllCall(WinUI3._bridge "\CreateXamlHost", "ptr")
            if !ptr
                throw Error("Failed to create XAML host")

            this._hostCom := ComObjFromPtr(ptr)

            ; Initialize with parent HWND
            success := false
            try {
                success := this._hostCom.Initialize(hwnd)
            } catch {
                try success := this._hostCom.Initialize()
            }
            if !success {
                this._hostCom := ""
                try this._gui.Destroy()
                this._gui := ""
                throw Error("Failed to initialize XAML island")
            }

            this._islandHwnd := this._hostCom.Hwnd

            ; Auto-resize the XAML island when the window resizes
            this._gui.OnEvent("Size", this._OnResize.Bind(this))
            this._gui.OnEvent("Close", this._OnClose.Bind(this))

            ; Initial resize to fill window
            this._ResizeIsland()

            ; Track this window
            WinUI3._windows[hwnd] := this
        }

        __Delete() {
            this._Cleanup()
        }

        ; ----- Public API -----

        /**
         * Load XAML content from a string.
         * @param {String} xamlString - XAML markup
         * @returns {WinUI3.Window} this (for chaining)
         */
        LoadXaml(xamlString) {
            this._elements.Clear()
            rootElement := this._hostCom.LoadXaml(xamlString)
            if !rootElement
                throw Error("Failed to load XAML content")
            return this
        }

        /**
         * Get a typed control by x:Name.
         * @param {String} name - The x:Name of the element
         * @returns {WinUI3.Element} A typed control wrapper
         */
        __Item[name] {
            get {
                if this._elements.Has(name)
                    return this._elements[name]

                wrapped := this._GetTypedControl(name)
                if wrapped {
                    this._elements[name] := wrapped
                    return wrapped
                }
                throw Error("Element not found: " name)
            }
        }

        /**
         * Get element (non-throwing version).
         * @returns {WinUI3.Element|String} Element or empty string if not found
         */
        GetElement(name) {
            try return this[name]
            return ""
        }

        /**
         * Register an event handler for a named element.
         * @param {String} elementName - x:Name of the element
         * @param {String} eventName - Event name (e.g. "Click", "TextChanged")
         * @param {Func} callback - Callback function
         * @returns {WinUI3.Window} this
         */
        OnEvent(elementName, eventName, callback) {
            key := elementName "_" eventName
            dispatcher := WinUI3.EventDispatcher(callback)
            this._handlers[key] := dispatcher
            this._handlerRefs.Push(dispatcher)
            this._hostCom.SetEventHandler(elementName, eventName, dispatcher.Ptr)
            return this
        }

        /**
         * Show the window (if hidden).
         */
        Show(options := "") {
            this._gui.Show(options)
            this._ResizeIsland()
            return this
        }

        /**
         * Hide the window.
         */
        Hide() {
            this._gui.Hide()
            return this
        }

        /**
         * The Gui object (for advanced use).
         */
        Gui => this._gui

        /**
         * The window HWND.
         */
        Hwnd => this._gui.Hwnd

        /**
         * The XAML island HWND.
         */
        IslandHwnd => this._islandHwnd

        ; ----- Internal -----

        _GetTypedControl(name) {
            comObj := ""

            ; Try GetControl first (returns typed wrapper from DLL)
            if this._hasGetControl != 0 {
                try {
                    comObj := this._hostCom.GetControl(name)
                    this._hasGetControl := 1
                } catch {
                    this._hasGetControl := 0
                }
            }

            ; Fall back to GetElement (returns generic XamlElement)
            if !comObj {
                try comObj := this._hostCom.GetElement(name)
            }
            if !comObj
                return ""

            return this._CreateWrapper(comObj)
        }

        _CreateWrapper(comObj) {
            controlType := ""
            try controlType := comObj.ControlType

            switch controlType {
                case "Button":       return WinUI3.Button(comObj, this)
                case "TextBox":      return WinUI3.TextBox(comObj, this)
                case "PasswordBox":  return WinUI3.TextBox(comObj, this)
                case "CheckBox":     return WinUI3.CheckBox(comObj, this)
                case "RadioButton":  return WinUI3.CheckBox(comObj, this)
                case "ComboBox":     return WinUI3.ComboBox(comObj, this)
                case "Slider":       return WinUI3.Slider(comObj, this)
                case "ProgressBar":  return WinUI3.ProgressBar(comObj, this)
                case "ProgressRing": return WinUI3.ProgressBar(comObj, this)
                case "TextBlock":    return WinUI3.TextBlock(comObj, this)
                case "ListView":     return WinUI3.ListView(comObj, this)
                case "GridView":     return WinUI3.ListView(comObj, this)
                case "ToggleSwitch": return WinUI3.ToggleSwitch(comObj, this)
            }

            ; Generic fallback
            return WinUI3.Element(comObj, this)
        }

        _OnResize(guiObj, minMax, width, height) {
            if minMax = -1  ; minimized
                return
            this._ResizeIsland()
        }

        _ResizeIsland() {
            if !this._islandHwnd || !this._gui.Hwnd
                return
            DllCall("GetClientRect", "Ptr", this._gui.Hwnd, "Ptr", rc := Buffer(16))
            w := NumGet(rc, 8, "Int") - NumGet(rc, 0, "Int")
            h := NumGet(rc, 12, "Int") - NumGet(rc, 4, "Int")
            DllCall("SetWindowPos", "Ptr", this._islandHwnd, "Ptr", 0,
                "Int", 0, "Int", 0, "Int", w, "Int", h,
                "UInt", 0x0004 | 0x0002)  ; SWP_NOZORDER | SWP_NOMOVE... actually SWP_NOMOVE=2, SWP_NOZORDER=4
        }

        _OnClose(guiObj) {
            this._Cleanup()
        }

        _Cleanup() {
            this._handlers.Clear()
            this._handlerRefs := []
            this._elements.Clear()
            if this._hostCom {
                try this._hostCom.Close()
                this._hostCom := ""
            }
            if this._gui {
                try {
                    hwnd := this._gui.Hwnd
                    if WinUI3._windows.Has(hwnd)
                        WinUI3._windows.Delete(hwnd)
                }
                try this._gui.Destroy()
                this._gui := ""
            }
        }
    }

    ; =========================================================================
    ; WinUI3.Element - Base class for all control wrappers
    ; =========================================================================

    class Element {
        _com := ""
        _win := ""

        __New(comObj, win) {
            this._com := comObj
            this._win := win
        }

        ; --- Common Properties ---

        Name {
            get {
                try return this._com.Name
                return ""
            }
        }

        ClassName {
            get {
                try return this._com.ClassName
                return ""
            }
        }

        ControlType {
            get {
                try return this._com.ControlType
                return ""
            }
        }

        Width {
            get {
                try return this._com.Width
                return 0
            }
            set => (this._com.Width := value)
        }

        Height {
            get {
                try return this._com.Height
                return 0
            }
            set => (this._com.Height := value)
        }

        IsEnabled {
            get {
                try return this._com.IsEnabled
                return true
            }
            set => (this._com.IsEnabled := value)
        }

        Visibility {
            get {
                try return this._com.Visibility
                return 0
            }
            set => (this._com.Visibility := value)
        }

        Opacity {
            get => this.GetProperty("Opacity")
            set => this.SetProperty("Opacity", value)
        }

        ; --- Common Methods ---

        GetProperty(name) {
            try return this._com.GetProperty(name)
            ; For typed wrappers, try direct property access
            try return this._com.%name%
            return ""
        }

        SetProperty(name, value) {
            try {
                this._com.SetProperty(name, value)
                return this
            }
            ; For typed wrappers, try direct property set
            try this._com.%name% := value
            return this
        }

        Focus() {
            try this._com.Focus()
            return this
        }

        OnEvent(eventName, callback) {
            elemName := this.Name
            if elemName
                this._win.OnEvent(elemName, eventName, callback)
            return this
        }
    }

    ; =========================================================================
    ; WinUI3.Button
    ; =========================================================================

    class Button extends WinUI3.Element {
        Content {
            get {
                try return this._com.Content
                return ""
            }
            set => (this._com.Content := value)
        }

        OnClick(callback) => this.OnEvent("Click", callback)

        Click() {
            try this._com.Click()
            return this
        }
    }

    ; =========================================================================
    ; WinUI3.TextBox (also wraps PasswordBox)
    ; =========================================================================

    class TextBox extends WinUI3.Element {
        Text {
            get {
                try return this._com.Text
                return ""
            }
            set => (this._com.Text := value)
        }

        PlaceholderText {
            get {
                try return this._com.PlaceholderText
                return ""
            }
            set => (this._com.PlaceholderText := value)
        }

        SelectionStart {
            get {
                try return this._com.SelectionStart
                return 0
            }
        }

        SelectionLength {
            get {
                try return this._com.SelectionLength
                return 0
            }
        }

        SelectedText {
            get {
                try return this._com.SelectedText
                return ""
            }
        }

        IsReadOnly {
            get {
                try return this._com.IsReadOnly
                return false
            }
            set => (this._com.IsReadOnly := value)
        }

        MaxLength {
            get {
                try return this._com.MaxLength
                return 0
            }
            set => (this._com.MaxLength := value)
        }

        OnTextChanged(callback) => this.OnEvent("TextChanged", callback)

        SelectAll() {
            try this._com.SelectAll()
            return this
        }

        Clear() {
            try this._com.Clear()
            return this
        }
    }

    ; =========================================================================
    ; WinUI3.CheckBox (also wraps RadioButton)
    ; =========================================================================

    class CheckBox extends WinUI3.Element {
        Content {
            get {
                try return this._com.Content
                return ""
            }
            set => (this._com.Content := value)
        }

        /**
         * 0=unchecked, 1=checked, 2=indeterminate
         */
        IsChecked {
            get {
                try return this._com.IsChecked
                return 0
            }
            set => (this._com.IsChecked := value)
        }

        IsThreeState {
            get {
                try return this._com.IsThreeState
                return false
            }
            set => (this._com.IsThreeState := value)
        }

        OnChecked(callback) => this.OnEvent("Checked", callback)
        OnUnchecked(callback) => this.OnEvent("Unchecked", callback)
    }

    ; =========================================================================
    ; WinUI3.ComboBox
    ; =========================================================================

    class ComboBox extends WinUI3.Element {
        SelectedIndex {
            get {
                try return this._com.SelectedIndex
                return -1
            }
            set => (this._com.SelectedIndex := value)
        }

        SelectedText {
            get {
                try return this._com.SelectedText
                return ""
            }
        }

        ItemCount {
            get {
                try return this._com.ItemCount
                return 0
            }
        }

        PlaceholderText {
            get {
                try return this._com.PlaceholderText
                return ""
            }
            set => (this._com.PlaceholderText := value)
        }

        IsEditable {
            get {
                try return this._com.IsEditable
                return false
            }
            set => (this._com.IsEditable := value)
        }

        OnSelectionChanged(callback) => this.OnEvent("SelectionChanged", callback)

        AddItem(text) {
            try this._com.AddItem(text)
            return this
        }

        RemoveAt(index) {
            try this._com.RemoveAt(index)
            return this
        }

        Clear() {
            try this._com.Clear()
            return this
        }

        GetAt(index) {
            try return this._com.GetAt(index)
            return ""
        }
    }

    ; =========================================================================
    ; WinUI3.Slider
    ; =========================================================================

    class Slider extends WinUI3.Element {
        Value {
            get {
                try return this._com.Value
                return 0
            }
            set => (this._com.Value := value)
        }

        Minimum {
            get {
                try return this._com.Minimum
                return 0
            }
            set => (this._com.Minimum := value)
        }

        Maximum {
            get {
                try return this._com.Maximum
                return 100
            }
            set => (this._com.Maximum := value)
        }

        StepFrequency {
            get {
                try return this._com.StepFrequency
                return 1
            }
            set => (this._com.StepFrequency := value)
        }

        OnValueChanged(callback) => this.OnEvent("ValueChanged", callback)
    }

    ; =========================================================================
    ; WinUI3.ProgressBar (also wraps ProgressRing)
    ; =========================================================================

    class ProgressBar extends WinUI3.Element {
        Value {
            get {
                try return this._com.Value
                return 0
            }
            set => (this._com.Value := value)
        }

        Minimum {
            get {
                try return this._com.Minimum
                return 0
            }
            set => (this._com.Minimum := value)
        }

        Maximum {
            get {
                try return this._com.Maximum
                return 100
            }
            set => (this._com.Maximum := value)
        }

        IsIndeterminate {
            get {
                try return this._com.IsIndeterminate
                return false
            }
            set => (this._com.IsIndeterminate := value)
        }
    }

    ; =========================================================================
    ; WinUI3.TextBlock
    ; =========================================================================

    class TextBlock extends WinUI3.Element {
        Text {
            get {
                try return this._com.Text
                return ""
            }
            set => (this._com.Text := value)
        }

        FontSize {
            get {
                try return this._com.FontSize
                return 14
            }
            set => (this._com.FontSize := value)
        }

        MaxLines {
            get {
                try return this._com.MaxLines
                return 0
            }
            set => (this._com.MaxLines := value)
        }

        TextWrapping {
            get {
                try return this._com.TextWrapping
                return 0
            }
            set => (this._com.TextWrapping := value)
        }
    }

    ; =========================================================================
    ; WinUI3.ListView (also wraps GridView)
    ; =========================================================================

    class ListView extends WinUI3.Element {
        SelectedIndex {
            get {
                try return this._com.SelectedIndex
                return -1
            }
            set => (this._com.SelectedIndex := value)
        }

        ItemCount {
            get {
                try return this._com.ItemCount
                return 0
            }
        }

        SelectionMode {
            get {
                try return this._com.SelectionMode
                return 1
            }
            set => (this._com.SelectionMode := value)
        }

        OnSelectionChanged(callback) => this.OnEvent("SelectionChanged", callback)

        AddItem(text) {
            try this._com.AddItem(text)
            return this
        }

        RemoveAt(index) {
            try this._com.RemoveAt(index)
            return this
        }

        Clear() {
            try this._com.Clear()
            return this
        }

        ScrollIntoView(index) {
            try this._com.ScrollIntoView(index)
            return this
        }
    }

    ; =========================================================================
    ; WinUI3.ToggleSwitch
    ; =========================================================================

    class ToggleSwitch extends WinUI3.Element {
        IsOn {
            get {
                try return this._com.IsOn
                return false
            }
            set => (this._com.IsOn := value)
        }

        Header {
            get {
                try return this._com.Header
                return ""
            }
            set => (this._com.Header := value)
        }

        OnContent {
            get {
                try return this._com.OnContent
                return ""
            }
            set => (this._com.OnContent := value)
        }

        OffContent {
            get {
                try return this._com.OffContent
                return ""
            }
            set => (this._com.OffContent := value)
        }

        OnToggled(callback) => this.OnEvent("Toggled", callback)
    }

    ; =========================================================================
    ; WinUI3.EventDispatcher - Bridges AHK callbacks to C++ event system
    ; =========================================================================
    ; The _handlerRefs array on the Window keeps these alive. No manual
    ; ObjAddRef/ObjRelease needed - AHK's normal ref counting handles it.

    class EventDispatcher {
        _callback := ""
        _ptr := 0

        __New(callback) {
            this._callback := callback
            this._ptr := ObjPtr(this)
            ; AddRef so the C++ side can invoke us even after AHK might
            ; otherwise release the last AHK-side reference. The matching
            ; Release happens in __Delete or when the Window clears handlers.
            ObjAddRef(this._ptr)
        }

        __Delete() {
            if this._ptr {
                ObjRelease(this._ptr)
                this._ptr := 0
            }
        }

        Ptr => this._ptr

        Call(args*) {
            if this._callback
                this._callback.Call(args*)
        }

        Invoke() {
            if this._callback
                this._callback.Call()
        }
    }
}
