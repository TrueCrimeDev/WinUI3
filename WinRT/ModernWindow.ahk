#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

class ModernWindow {
    static DWMWA := Map(
        "USE_IMMERSIVE_DARK_MODE", 20,
        "WINDOW_CORNER_PREFERENCE", 33,
        "BORDER_COLOR", 34,
        "CAPTION_COLOR", 35,
        "TEXT_COLOR", 36,
        "SYSTEMBACKDROP_TYPE", 38
    )
    
    static DWMWCP := Map(
        "DEFAULT", 0,
        "DONOTROUND", 1,
        "ROUND", 2,
        "ROUNDSMALL", 3
    )
    
    static DWMSBT := Map(
        "AUTO", 0,
        "NONE", 1,
        "MAINWINDOW", 2,
        "TRANSIENTWINDOW", 3,
        "TABBEDWINDOW", 4
    )
    
    static Theme := Map(
        "bg", 0x202020,
        "bgAlt", 0x2D2D2D,
        "bgHover", 0x3D3D3D,
        "bgPressed", 0x1D1D1D,
        "fg", 0xFFFFFF,
        "fgDim", 0x999999,
        "accent", 0xD47800,
        "border", 0x3D3D3D,
        "hover", 0x3D3D3D,
        "pressed", 0x1D1D1D
    )
    
    gui := ""
    hwnd := 0
    controls := Map()
    _darkMode := true
    _backdrop := "Mica"
    _corners := "Round"
    
    static _darkModeInitialized := false
    static _uxtheme := 0
    static _AllowDarkModeForWindow := 0
    static _FlushMenuThemes := 0
    static _RefreshImmersiveColorPolicyState := 0
    
    __New(title := "Modern Window", options := "") {
        if !ModernWindow._darkModeInitialized {
            ModernWindow._darkModeInitialized := true
            try {
                ModernWindow._uxtheme := DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr")
                
                SetPreferredAppMode := DllCall("GetProcAddress", "Ptr", ModernWindow._uxtheme, "Ptr", 135, "Ptr")
                if SetPreferredAppMode
                    DllCall(SetPreferredAppMode, "Int", 2)
                
                AllowDarkModeForApp := DllCall("GetProcAddress", "Ptr", ModernWindow._uxtheme, "Ptr", 132, "Ptr")
                if AllowDarkModeForApp
                    DllCall(AllowDarkModeForApp, "Int", 1)
                
                ModernWindow._AllowDarkModeForWindow := DllCall("GetProcAddress", "Ptr", ModernWindow._uxtheme, "Ptr", 133, "Ptr")
                ModernWindow._FlushMenuThemes := DllCall("GetProcAddress", "Ptr", ModernWindow._uxtheme, "Ptr", 136, "Ptr")
                ModernWindow._RefreshImmersiveColorPolicyState := DllCall("GetProcAddress", "Ptr", ModernWindow._uxtheme, "Ptr", 104, "Ptr")
                
                if ModernWindow._RefreshImmersiveColorPolicyState
                    DllCall(ModernWindow._RefreshImmersiveColorPolicyState)
                    
                if ModernWindow._FlushMenuThemes
                    DllCall(ModernWindow._FlushMenuThemes)
            }
        }
        
        this.gui := Gui("+Resize -DPIScale " options, title)
        this.hwnd := this.gui.Hwnd
        this.gui.BackColor := Format("{:06X}", ModernWindow.Theme["bg"])
        this.gui.SetFont("s10 cWhite", "Segoe UI")
        this.gui.MarginX := 16
        this.gui.MarginY := 16
        this.ApplyModernStyle()
        this.gui.OnEvent("Close", (*) => this.OnClose())
        this.gui.OnEvent("Escape", (*) => this.OnEscape())
        this.gui.OnEvent("Size", this.OnSize.Bind(this))
    }
    
    ApplyModernStyle() {
        this.SetDarkMode(this._darkMode)
        this.SetBackdrop(this._backdrop)
        this.SetCorners(this._corners)
        this.ExtendFrameIntoClientArea()
    }
    
    SetDarkMode(enable := true) {
        this._darkMode := enable
        value := enable ? 1 : 0
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "Int", ModernWindow.DWMWA["USE_IMMERSIVE_DARK_MODE"], "Int*", value, "Int", 4)
        
        if enable {
            this.gui.BackColor := Format("{:06X}", ModernWindow.Theme["bg"])
            if ModernWindow._AllowDarkModeForWindow
                DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", this.hwnd, "Int", 1)
            if ModernWindow._FlushMenuThemes
                DllCall(ModernWindow._FlushMenuThemes)
        } else {
            this.gui.BackColor := "FFFFFF"
        }
        return this
    }
    
    SetBackdrop(type := "Mica") {
        this._backdrop := type
        backdropValue := 0
        switch type {
            case "None":
                backdropValue := ModernWindow.DWMSBT["NONE"]
            case "Mica":
                backdropValue := ModernWindow.DWMSBT["MAINWINDOW"]
            case "Acrylic":
                backdropValue := ModernWindow.DWMSBT["TRANSIENTWINDOW"]
            case "Tabbed":
                backdropValue := ModernWindow.DWMSBT["TABBEDWINDOW"]
            default:
                backdropValue := ModernWindow.DWMSBT["AUTO"]
        }
        if VerCompare(A_OSVersion, "10.0.22000") >= 0 {
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "UInt", ModernWindow.DWMWA["SYSTEMBACKDROP_TYPE"], "Int*", backdropValue, "Int", 4)
        }
        return this
    }
    
    SetCorners(style := "Round") {
        this._corners := style
        cornerValue := 0
        switch style {
            case "Default":
                cornerValue := ModernWindow.DWMWCP["DEFAULT"]
            case "None":
                cornerValue := ModernWindow.DWMWCP["DONOTROUND"]
            case "Round":
                cornerValue := ModernWindow.DWMWCP["ROUND"]
            case "RoundSmall":
                cornerValue := ModernWindow.DWMWCP["ROUNDSMALL"]
        }
        if VerCompare(A_OSVersion, "10.0.22000") >= 0 {
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "Int", ModernWindow.DWMWA["WINDOW_CORNER_PREFERENCE"], "Int*", cornerValue, "Int", 4)
        }
        return this
    }
    
    SetBorderColor(color := 0x3D3D3D) {
        if VerCompare(A_OSVersion, "10.0.22000") >= 0 {
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "Int", ModernWindow.DWMWA["BORDER_COLOR"], "UInt*", color, "Int", 4)
        }
        return this
    }
    
    SetCaptionColor(color := 0x202020) {
        if VerCompare(A_OSVersion, "10.0.22000") >= 0 {
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "Int", ModernWindow.DWMWA["CAPTION_COLOR"], "UInt*", color, "Int", 4)
        }
        return this
    }
    
    SetTextColor(color := 0xFFFFFF) {
        if VerCompare(A_OSVersion, "10.0.22000") >= 0 {
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.hwnd, "Int", ModernWindow.DWMWA["TEXT_COLOR"], "UInt*", color, "Int", 4)
        }
        return this
    }
    
    ExtendFrameIntoClientArea(left := -1, right := -1, top := -1, bottom := -1) {
        margins := Buffer(16, 0)
        NumPut("Int", left, "Int", right, "Int", top, "Int", bottom, margins)
        DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", this.hwnd, "Ptr", margins)
        return this
    }
    
    AddText(options := "", text := "") {
        ctrl := this.gui.AddText(options " c" Format("{:06X}", ModernWindow.Theme["fg"]), text)
        return ctrl
    }
    
    AddEdit(options := "", text := "") {
        ctrl := this.gui.AddEdit(options " Background" Format("{:06X}", ModernWindow.Theme["bgAlt"]), text)
        this.ApplyDarkScrollbar(ctrl.Hwnd)
        return ctrl
    }
    
    AddButton(options := "", text := "") {
        if this._darkMode {
            ctrl := MicaButton(this.gui, options, text)
            return ctrl
        }
        ctrl := this.gui.AddButton(options, text)
        return ctrl
    }
    
    AddListView(options := "", headers := "") {
        if this._darkMode {
            ctrl := DarkListView(this.gui, this.hwnd, options, headers)
            return ctrl
        }
        ctrl := this.gui.AddListView(options, headers)
        return ctrl
    }
    
    AddTreeView(options := "") {
        ctrl := this.gui.AddTreeView(options " Background" Format("{:06X}", ModernWindow.Theme["bgAlt"]) " c" Format("{:06X}", ModernWindow.Theme["fg"]))
        this.ApplyDarkScrollbar(ctrl.Hwnd)
        this.SetExplorerTheme(ctrl.Hwnd)
        return ctrl
    }
    
    AddComboBox(options := "", items := "") {
        ctrl := this.gui.AddComboBox(options, items)
        if this._darkMode
            DarkComboBox(ctrl, this.hwnd)
        return ctrl
    }
    
    AddDropDownList(options := "", items := "") {
        ctrl := this.gui.AddDropDownList(options, items)
        if this._darkMode
            DarkComboBox(ctrl, this.hwnd)
        return ctrl
    }
    
    AddGridView(options := "", items := "") {
        if this._darkMode {
            ctrl := DarkGridView(this.gui, this.hwnd, options, items)
            return ctrl
        }
        ctrl := this.gui.AddListView(options " Icon", "")
        return ctrl
    }
    
    AddCheckbox(options := "", text := "") {
        ctrl := this.gui.AddCheckbox(options " c" Format("{:06X}", ModernWindow.Theme["fg"]), text)
        if this._darkMode {
            if ModernWindow._AllowDarkModeForWindow
                DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", ctrl.Hwnd, "Int", 1)
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
        }
        return ctrl
    }
    
    AddRadio(options := "", text := "") {
        ctrl := this.gui.AddRadio(options " c" Format("{:06X}", ModernWindow.Theme["fg"]), text)
        if this._darkMode {
            if ModernWindow._AllowDarkModeForWindow
                DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", ctrl.Hwnd, "Int", 1)
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
        }
        return ctrl
    }
    
    AddGroupBox(options := "", text := "") {
        ctrl := this.gui.AddGroupBox(options " c" Format("{:06X}", ModernWindow.Theme["fg"]), text)
        return ctrl
    }
    
    AddProgress(options := "", value := 0) {
        ctrl := this.gui.AddProgress(options " Background" Format("{:06X}", ModernWindow.Theme["bgAlt"]) " c" Format("{:06X}", ModernWindow.Theme["accent"]))
        if value
            ctrl.Value := value
        return ctrl
    }
    
    AddSlider(options := "") {
        ctrl := this.gui.AddSlider(options)
        return ctrl
    }
    
    AddTab3(options := "", tabs := "") {
        ctrl := this.gui.AddTab3(options " Background" Format("{:06X}", ModernWindow.Theme["bg"]), tabs)
        return ctrl
    }
    
    AddStatusBar(options := "", text := "") {
        ctrl := this.gui.AddStatusBar(options, text)
        return ctrl
    }
    
    ApplyDarkScrollbar(hwnd) {
        if this._darkMode {
            if ModernWindow._AllowDarkModeForWindow
                DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", hwnd, "Int", 1)
            DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
            if ModernWindow._FlushMenuThemes
                DllCall(ModernWindow._FlushMenuThemes)
            DllCall("user32\SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27)
        }
    }
    
    ApplyDarkComboBox(hwnd) {
        if this._darkMode {
            if ModernWindow._AllowDarkModeForWindow
                DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", hwnd, "Int", 1)
            DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
            
            cbInfo := Buffer(40 + A_PtrSize, 0)
            NumPut("UInt", 40 + A_PtrSize, cbInfo, 0)
            if DllCall("user32\GetComboBoxInfo", "Ptr", hwnd, "Ptr", cbInfo) {
                hwndList := NumGet(cbInfo, 40, "Ptr")
                if hwndList {
                    if ModernWindow._AllowDarkModeForWindow
                        DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", hwndList, "Int", 1)
                    DllCall("uxtheme\SetWindowTheme", "Ptr", hwndList, "Str", "DarkMode_CFD", "Ptr", 0)
                }
            }
            if ModernWindow._FlushMenuThemes
                DllCall(ModernWindow._FlushMenuThemes)
        }
    }
    
    SetExplorerTheme(hwnd) {
        if this._darkMode {
            DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
        } else {
            DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "Explorer", "Ptr", 0)
        }
    }
    
    Show(options := "") {
        this.gui.Show(options)
        return this
    }
    
    Hide() {
        this.gui.Hide()
        return this
    }
    
    Toggle() {
        if WinExist("ahk_id " this.hwnd)
            if DllCall("IsWindowVisible", "Ptr", this.hwnd)
                this.Hide()
            else
                this.Show()
        else
            this.Show()
        return this
    }
    
    Minimize() {
        this.gui.Minimize()
        return this
    }
    
    Maximize() {
        this.gui.Maximize()
        return this
    }
    
    Restore() {
        this.gui.Restore()
        return this
    }
    
    Move(x := "", y := "", w := "", h := "") {
        this.gui.Move(x, y, w, h)
        return this
    }
    
    GetPos(&x?, &y?, &w?, &h?) {
        this.gui.GetPos(&x, &y, &w, &h)
    }
    
    GetClientPos(&x?, &y?, &w?, &h?) {
        this.gui.GetClientPos(&x, &y, &w, &h)
    }
    
    SetFont(options := "", fontName := "") {
        this.gui.SetFont(options, fontName)
        return this
    }
    
    OnSize(guiObj, minMax, width, height) {
    }
    
    OnClose() {
        this.gui.Hide()
    }
    
    OnEscape() {
        this.gui.Hide()
    }
    
    Destroy() {
        this.gui.Destroy()
    }
    
    __Delete() {
        if this.gui
            this.gui.Destroy()
    }
    
    static IsDarkModeEnabled() {
        try {
            regValue := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
            return regValue = 0
        }
        return true
    }
    
    static IsWindows11() {
        return VerCompare(A_OSVersion, "10.0.22000") >= 0
    }
    
    static GetAccentColor() {
        try {
            regValue := RegRead("HKCU\SOFTWARE\Microsoft\Windows\DWM", "AccentColor")
            return regValue
        }
        return 0x0078D4
    }
}


class DarkListView {
    static Instances := Map()
    static OrigWndProcs := Map()
    static HeaderWndProcs := Map()
    static Callbacks := Map()
    static HeaderCallbacks := Map()
    static LVM_GETHEADER := 0x101F
    static LVM_SETBKCOLOR := 0x1001
    static LVM_SETTEXTCOLOR := 0x1024
    static LVM_SETTEXTBKCOLOR := 0x1026
    static LVM_SETEXTENDEDLISTVIEWSTYLE := 0x1036
    static LVM_GETEXTENDEDLISTVIEWSTYLE := 0x1037
    static LVS_EX_DOUBLEBUFFER := 0x10000
    static LVS_EX_GRIDLINES := 0x1
    static WM_CHANGEUISTATE := 0x0127
    static UIS_SET := 1
    static UISF_HIDEFOCUS := 0x1
    
    ctrl := ""
    _hwnd := 0
    headerHwnd := 0
    parentHwnd := 0
    
    bgColor := 0x202020
    bgAltColor := 0x2D2D2D
    fgColor := 0xFFFFFF
    borderColor := 0x3D3D3D
    
    __New(guiObj, parentHwnd, options := "", headers := "") {
        this.parentHwnd := parentHwnd
        this.bgColor := ModernWindow.Theme["bg"]
        this.bgAltColor := ModernWindow.Theme["bgAlt"]
        this.fgColor := ModernWindow.Theme["fg"]
        this.borderColor := ModernWindow.Theme["border"]
        
        this.ctrl := guiObj.AddListView(options, headers)
        this._hwnd := this.ctrl.Hwnd
        this.headerHwnd := SendMessage(DarkListView.LVM_GETHEADER, 0, 0, this._hwnd)
        
        currentStyle := SendMessage(DarkListView.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0, this._hwnd)
        newStyle := (currentStyle | DarkListView.LVS_EX_DOUBLEBUFFER) & ~DarkListView.LVS_EX_GRIDLINES
        SendMessage(DarkListView.LVM_SETEXTENDEDLISTVIEWSTYLE, 0, newStyle, this._hwnd)
        
        if ModernWindow._AllowDarkModeForWindow {
            DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", this._hwnd, "Int", 1)
            if this.headerHwnd
                DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", this.headerHwnd, "Int", 1)
        }
        
        DllCall("uxtheme\SetWindowTheme", "Ptr", this._hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
        DllCall("user32\SetWindowPos", "Ptr", this._hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27)
        if this.headerHwnd
            DllCall("uxtheme\SetWindowTheme", "Ptr", this.headerHwnd, "Str", "DarkMode_ItemsView", "Ptr", 0)
        
        if ModernWindow._FlushMenuThemes
            DllCall(ModernWindow._FlushMenuThemes)
        
        SendMessage(DarkListView.LVM_SETBKCOLOR, 0, this.bgColor, this._hwnd)
        SendMessage(DarkListView.LVM_SETTEXTCOLOR, 0, this.fgColor, this._hwnd)
        SendMessage(DarkListView.LVM_SETTEXTBKCOLOR, 0, this.bgColor, this._hwnd)
        
        SendMessage(DarkListView.WM_CHANGEUISTATE, (DarkListView.UIS_SET << 8) | DarkListView.UISF_HIDEFOCUS, 0, this._hwnd)
        
        DllCall("user32\SendMessage", "Ptr", this._hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
        DllCall("user32\SendMessage", "Ptr", this._hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
        DllCall("user32\InvalidateRect", "Ptr", this._hwnd, "Ptr", 0, "Int", 1)
        
        this.ctrl.OnMessage(0x031A, (*) => 0)
        this.ctrl.OnMessage(0x4E, this._OnNotify.Bind(this))
        
        DarkListView.Instances[this._hwnd] := this
        
        if !DarkListView.OrigWndProcs.Has(parentHwnd) {
            cb := CallbackCreate(ObjBindMethod(DarkListView, "_WndProc"), "F", 4)
            DarkListView.Callbacks[parentHwnd] := cb
            DarkListView.OrigWndProcs[parentHwnd] := DllCall("SetWindowLongPtr", "Ptr", parentHwnd, "Int", -4, "Ptr", cb, "Ptr")
        }
        
        if this.headerHwnd && !DarkListView.HeaderWndProcs.Has(this.headerHwnd) {
            hdrCb := CallbackCreate(ObjBindMethod(this, "_HeaderWndProc"), "F", 4)
            DarkListView.HeaderCallbacks[this.headerHwnd] := hdrCb
            DarkListView.HeaderWndProcs[this.headerHwnd] := DllCall("SetWindowLongPtr", "Ptr", this.headerHwnd, "Int", -4, "Ptr", hdrCb, "Ptr")
        }
    }
    
    _HeaderWndProc(hwnd, msg, wParam, lParam) {
        static WM_ERASEBKGND := 0x14
        
        if msg = WM_ERASEBKGND {
            hdc := wParam
            rect := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hwnd, "Ptr", rect)
            hBrush := DllCall("CreateSolidBrush", "UInt", this.bgColor, "Ptr")
            DllCall("FillRect", "Ptr", hdc, "Ptr", rect, "Ptr", hBrush)
            DllCall("DeleteObject", "Ptr", hBrush)
            return 1
        }
        
        if DarkListView.HeaderWndProcs.Has(hwnd)
            return DllCall("CallWindowProc", "Ptr", DarkListView.HeaderWndProcs[hwnd], "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
        return DllCall("DefWindowProc", "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }
    
    _OnNotify(ctrl, wParam, lParam, msg) {
        static NM_CUSTOMDRAW := -12
        static CDDS_PREPAINT := 0x1
        static CDDS_ITEMPREPAINT := 0x10001
        static CDRF_NOTIFYITEMDRAW := 0x20
        static CDRF_SKIPDEFAULT := 0x4
        static HDI_TEXT := 0x2
        static HDM_GETITEMW := 0x120B
        
        code := NumGet(lParam, A_PtrSize * 2, "Int")
        if code != NM_CUSTOMDRAW
            return
        
        hwndFrom := NumGet(lParam, 0, "Ptr")
        if hwndFrom != this.headerHwnd
            return
        
        dwDrawStage := NumGet(lParam, A_PtrSize * 3, "UInt")
        
        switch dwDrawStage {
            case CDDS_PREPAINT:
                return CDRF_NOTIFYITEMDRAW
            case CDDS_ITEMPREPAINT:
                hdc := NumGet(lParam, A_PtrSize * 3 + 8, "Ptr")
                
                rcLeft := NumGet(lParam, A_PtrSize * 3 + 8 + A_PtrSize, "Int")
                rcTop := NumGet(lParam, A_PtrSize * 3 + 8 + A_PtrSize + 4, "Int")
                rcRight := NumGet(lParam, A_PtrSize * 3 + 8 + A_PtrSize + 8, "Int")
                rcBottom := NumGet(lParam, A_PtrSize * 3 + 8 + A_PtrSize + 12, "Int")
                
                itemRect := Buffer(16, 0)
                NumPut("Int", rcLeft, "Int", rcTop, "Int", rcRight, "Int", rcBottom, itemRect)
                hBrush := DllCall("CreateSolidBrush", "UInt", this.bgColor, "Ptr")
                DllCall("FillRect", "Ptr", hdc, "Ptr", itemRect, "Ptr", hBrush)
                DllCall("DeleteObject", "Ptr", hBrush)
                
                hPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", this.borderColor, "Ptr")
                hOldPen := DllCall("SelectObject", "Ptr", hdc, "Ptr", hPen, "Ptr")
                DllCall("MoveToEx", "Ptr", hdc, "Int", rcRight - 1, "Int", rcTop + 4, "Ptr", 0)
                DllCall("LineTo", "Ptr", hdc, "Int", rcRight - 1, "Int", rcBottom - 4)
                DllCall("SelectObject", "Ptr", hdc, "Ptr", hOldPen, "Ptr")
                DllCall("DeleteObject", "Ptr", hPen)
                
                itemIndex := NumGet(lParam, A_PtrSize * 3 + 8 + A_PtrSize + 16, "UPtr")
                
                textBuf := Buffer(520, 0)
                hdItem := Buffer(A_PtrSize = 8 ? 72 : 48, 0)
                NumPut("UInt", HDI_TEXT, hdItem, 0)
                NumPut("Ptr", textBuf.Ptr, hdItem, 8)
                NumPut("Int", 260, hdItem, A_PtrSize = 8 ? 24 : 12)
                SendMessage(HDM_GETITEMW, itemIndex, hdItem.Ptr, this.headerHwnd)
                
                DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
                DllCall("SetTextColor", "Ptr", hdc, "UInt", this.fgColor)
                
                textRect := Buffer(16, 0)
                NumPut("Int", rcLeft + 8, "Int", rcTop, "Int", rcRight - 8, "Int", rcBottom, textRect)
                DllCall("DrawTextW", "Ptr", hdc, "Ptr", textBuf.Ptr, "Int", -1, "Ptr", textRect, "UInt", 0x8804)
                
                return CDRF_SKIPDEFAULT
        }
    }
    
    __Delete() {
        if DarkListView.Instances.Has(this._hwnd)
            DarkListView.Instances.Delete(this._hwnd)
    }
    
    Add(args*) => this.ctrl.Add(args*)
    Delete(args*) => this.ctrl.Delete(args*)
    Insert(args*) => this.ctrl.Insert(args*)
    Modify(args*) => this.ctrl.Modify(args*)
    ModifyCol(args*) => this.ctrl.ModifyCol(args*)
    GetCount(args*) => this.ctrl.GetCount(args*)
    GetNext(args*) => this.ctrl.GetNext(args*)
    GetText(args*) => this.ctrl.GetText(args*)
    SetImageList(args*) => this.ctrl.SetImageList(args*)
    OnEvent(args*) => this.ctrl.OnEvent(args*)
    
    Hwnd => this._hwnd
    Focused => this.ctrl.Focused
    
    static _WndProc(hwnd, msg, wParam, lParam) {
        static WM_NOTIFY := 0x4E
        static NM_CUSTOMDRAW := -12
        static CDDS_PREPAINT := 0x1
        static CDDS_ITEMPREPAINT := 0x10001
        static CDRF_NOTIFYITEMDRAW := 0x20
        static CDRF_NEWFONT := 0x2
        
        if msg = WM_NOTIFY {
            hwndFrom := NumGet(lParam, 0, "Ptr")
            code := NumGet(lParam, A_PtrSize * 2, "Int")
            
            if code = NM_CUSTOMDRAW {
                for lvHwnd, instance in DarkListView.Instances {
                    if hwndFrom = lvHwnd {
                        dwDrawStage := NumGet(lParam, A_PtrSize * 3, "UInt")
                        
                        if dwDrawStage = CDDS_PREPAINT
                            return CDRF_NOTIFYITEMDRAW
                        
                        if dwDrawStage = CDDS_ITEMPREPAINT {
                            clrTextOffset := A_PtrSize = 8 ? 72 : 48
                            clrTextBkOffset := A_PtrSize = 8 ? 76 : 52
                            dwItemSpecOffset := A_PtrSize = 8 ? 48 : 36
                            
                            itemIndex := NumGet(lParam, dwItemSpecOffset, "UPtr")
                            bgCol := (itemIndex & 1) ? instance.bgAltColor : instance.bgColor
                            
                            NumPut("UInt", instance.fgColor, lParam, clrTextOffset)
                            NumPut("UInt", bgCol, lParam, clrTextBkOffset)
                            return CDRF_NEWFONT
                        }
                    }
                }
            }
        }
        
        if DarkListView.OrigWndProcs.Has(hwnd)
            return DllCall("CallWindowProc", "Ptr", DarkListView.OrigWndProcs[hwnd], "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
        return DllCall("DefWindowProc", "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }
}

class DarkComboBox {
    static Instances := Map()
    static OrigWndProcs := Map()
    
    ctrl := ""
    _hwnd := 0
    _listHwnd := 0
    _parentHwnd := 0
    bgColor := 0x202020
    fgColor := 0xFFFFFF
    
    __New(ctrl, parentHwnd) {
        this.ctrl := ctrl
        this._hwnd := ctrl.Hwnd
        this._parentHwnd := parentHwnd
        
        this.bgColor := ModernWindow.Theme["bg"]
        this.fgColor := ModernWindow.Theme["fg"]
        
        if ModernWindow._AllowDarkModeForWindow
            DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", this._hwnd, "Int", 1)
        DllCall("uxtheme\SetWindowTheme", "Ptr", this._hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
        
        cbInfo := Buffer(40 + A_PtrSize, 0)
        NumPut("UInt", 40 + A_PtrSize, cbInfo, 0)
        if DllCall("user32\GetComboBoxInfo", "Ptr", this._hwnd, "Ptr", cbInfo) {
            this._listHwnd := NumGet(cbInfo, 40, "Ptr")
            if this._listHwnd {
                if ModernWindow._AllowDarkModeForWindow
                    DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", this._listHwnd, "Int", 1)
                DllCall("uxtheme\SetWindowTheme", "Ptr", this._listHwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
                
                static SWP_FRAMECHANGED := 0x20
                static SWP_NOMOVE := 0x2
                static SWP_NOSIZE := 0x1
                static SWP_NOZORDER := 0x4
                static SWP_NOACTIVATE := 0x10
                DllCall("SetWindowPos", "Ptr", this._listHwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE)
                
                DarkComboBox.Instances[this._hwnd] := this
                
                if !DarkComboBox.OrigWndProcs.Has(parentHwnd) {
                    origProc := DllCall("SetWindowLongPtr", "Ptr", parentHwnd, "Int", -4, "Ptr", CallbackCreate(DarkComboBox_WndProc, , 4), "Ptr")
                    DarkComboBox.OrigWndProcs[parentHwnd] := origProc
                }
            }
        }
        
        if ModernWindow._FlushMenuThemes
            DllCall(ModernWindow._FlushMenuThemes)
    }
}

DarkComboBox_WndProc(hwnd, msg, wParam, lParam) {
    static WM_CTLCOLORLISTBOX := 0x134
    static WM_CTLCOLOREDIT := 0x133
    
    if (msg = WM_CTLCOLORLISTBOX || msg = WM_CTLCOLOREDIT) {
        for cbHwnd, instance in DarkComboBox.Instances {
            if (instance._listHwnd = lParam || instance._hwnd = DllCall("GetParent", "Ptr", lParam, "Ptr")) {
                DllCall("SetTextColor", "Ptr", wParam, "UInt", instance.fgColor)
                DllCall("SetBkColor", "Ptr", wParam, "UInt", instance.bgColor)
                if !instance.HasOwnProp("_listBrush")
                    instance._listBrush := DllCall("CreateSolidBrush", "UInt", instance.bgColor, "Ptr")
                return instance._listBrush
            }
        }
    }
    
    if DarkComboBox.OrigWndProcs.Has(hwnd)
        return DllCall("CallWindowProc", "Ptr", DarkComboBox.OrigWndProcs[hwnd], "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    return DllCall("DefWindowProc", "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

class MicaButton {
    ctrl := ""
    _hwnd := 0
    _cornerRadius := 5
    _text := ""
    _isHovered := false
    _isPressed := false
    _wndProcCb := 0
    _origProc := 0

    __New(guiObj, options := "", text := "") {
        this._text := text
        this.ctrl := guiObj.AddButton(options " +0x0B", text)
        this._hwnd := this.ctrl.Hwnd
        DllCall("uxtheme\SetWindowTheme", "Ptr", this._hwnd, "Ptr", 0, "Ptr", 0)
        this._wndProcCb := CallbackCreate(ObjBindMethod(this, "_WndProc"), , 4)
        this._origProc := DllCall("SetWindowLongPtr", "Ptr", this._hwnd, "Int", -4, "Ptr", this._wndProcCb, "Ptr")
        this._TrackMouse()
    }

    Hwnd => this._hwnd
    Value {
        get => this.ctrl.Value
        set => this.ctrl.Value := value
    }
    Text {
        get => this._text
        set {
            this._text := value
            this._Redraw()
        }
    }

    OnEvent(eventName, callback, addRemove := 1) {
        this.ctrl.OnEvent(eventName, callback, addRemove)
    }

    _TrackMouse() {
        tme := Buffer(24, 0)
        NumPut("UInt", 24, tme, 0)
        NumPut("UInt", 2, tme, 4)
        NumPut("Ptr", this._hwnd, tme, 8)
        DllCall("TrackMouseEvent", "Ptr", tme)
    }

    _WndProc(hwnd, msg, wParam, lParam) {
        static WM_PAINT := 0x0F, WM_ERASEBKGND := 0x14, WM_MOUSEMOVE := 0x200
        static WM_MOUSELEAVE := 0x2A3, WM_LBUTTONDOWN := 0x201, WM_LBUTTONUP := 0x202

        switch msg {
            case WM_ERASEBKGND:
                return 1
            case WM_PAINT:
                this._OnPaint()
                return 0
            case WM_MOUSEMOVE:
                if !this._isHovered {
                    this._isHovered := true
                    this._TrackMouse()
                    this._Redraw()
                }
                return 0
            case WM_MOUSELEAVE:
                this._isHovered := false
                this._Redraw()
                return 0
            case WM_LBUTTONDOWN:
                this._isPressed := true
                DllCall("SetCapture", "Ptr", hwnd)
                this._Redraw()
                return 0
            case WM_LBUTTONUP:
                wasPressed := this._isPressed
                this._isPressed := false
                DllCall("ReleaseCapture")
                this._Redraw()
                if wasPressed {
                    pt := Buffer(8, 0)
                    DllCall("GetCursorPos", "Ptr", pt)
                    DllCall("ScreenToClient", "Ptr", hwnd, "Ptr", pt)
                    rect := Buffer(16, 0)
                    DllCall("GetClientRect", "Ptr", hwnd, "Ptr", rect)
                    x := NumGet(pt, 0, "Int"), y := NumGet(pt, 4, "Int")
                    r := NumGet(rect, 8, "Int"), b := NumGet(rect, 12, "Int")
                    if (x >= 0 && y >= 0 && x < r && y < b) {
                        ; Get proper control ID for WM_COMMAND (not hwnd)
                        ctrlId := DllCall("GetDlgCtrlID", "Ptr", hwnd, "Int")
                        PostMessage(0x111, ctrlId, hwnd, DllCall("GetParent", "Ptr", hwnd, "Ptr"))
                    }
                }
                return 0
        }
        return DllCall("CallWindowProc", "Ptr", this._origProc, "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }

    _OnPaint() {
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", this._hwnd, "Ptr", ps, "Ptr")
        rect := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", this._hwnd, "Ptr", rect)
        w := NumGet(rect, 8, "Int"), h := NumGet(rect, 12, "Int")

        if this._isPressed
            bgColor := ModernWindow.Theme["bgPressed"]
        else if this._isHovered
            bgColor := ModernWindow.Theme["bgHover"]
        else
            bgColor := ModernWindow.Theme["bgAlt"]

        borderColor := ModernWindow.Theme["border"]
        textColor := ModernWindow.Theme["fg"]

        rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w, "Int", h,
            "Int", this._cornerRadius * 2, "Int", this._cornerRadius * 2, "Ptr")
        brush := DllCall("CreateSolidBrush", "UInt", bgColor, "Ptr")
        DllCall("FillRgn", "Ptr", hdc, "Ptr", rgn, "Ptr", brush)
        DllCall("DeleteObject", "Ptr", brush)

        pen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", borderColor, "Ptr")
        oldPen := DllCall("SelectObject", "Ptr", hdc, "Ptr", pen, "Ptr")
        oldBrush := DllCall("SelectObject", "Ptr", hdc, "Ptr", DllCall("GetStockObject", "Int", 5, "Ptr"), "Ptr")
        DllCall("RoundRect", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w-1, "Int", h-1,
            "Int", this._cornerRadius * 2, "Int", this._cornerRadius * 2)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldPen)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldBrush)
        DllCall("DeleteObject", "Ptr", pen)
        DllCall("DeleteObject", "Ptr", rgn)

        DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
        DllCall("SetTextColor", "Ptr", hdc, "UInt", textColor)
        hFont := SendMessage(0x31, 0, 0, this._hwnd)
        if hFont
            oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")

        textRect := Buffer(16, 0)
        NumPut("Int", 0, "Int", 0, "Int", w, "Int", h, textRect)
        DllCall("DrawTextW", "Ptr", hdc, "WStr", this._text, "Int", -1, "Ptr", textRect, "UInt", 0x25)

        if hFont && IsSet(oldFont)
            DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
        DllCall("EndPaint", "Ptr", this._hwnd, "Ptr", ps)
    }

    _Redraw() {
        DllCall("InvalidateRect", "Ptr", this._hwnd, "Ptr", 0, "Int", 1)
    }
}

class DarkGridView {
    static Instances := Map()
    static OrigWndProcs := Map()
    static Callbacks := Map()
    static GdipToken := 0
    static ShellIcons := Map()
    static FolderIconNames := Map(
        "Documents", 0, "Pictures", 0, "Music", 0, "Videos", 0,
        "Downloads", 0, "Desktop", 0, "Projects", 0, "Archive", 0
    )
    
    static SelectionMode := Map(
        "None", 0,
        "Single", 1,
        "Multiple", 2,
        "Extended", 3
    )
    
    ctrl := ""
    _hwnd := 0
    parentHwnd := 0
    items := []
    selectedIndices := []
    hoveredIndex := 0
    focusedIndex := 1
    scrollOffset := 0
    
    itemWidth := 120
    itemHeight := 100
    itemPadding := 8
    iconSize := 48
    
    bgColor := 0x202020
    fgColor := 0xFFFFFF
    selectedBg := 0x0078D4
    selectedFg := 0xFFFFFF
    hoverBg := 0x3D3D3D
    borderColor := 0x3D3D3D
    
    selectionMode := 1
    columns := 0
    rows := 0
    visibleRows := 0
    totalHeight := 0
    clientWidth := 0
    clientHeight := 0
    
    _scrollBar := ""
    _scrollBarWidth := 16
    _hasScrollBar := false
    
    __New(guiObj, parentHwnd, options := "", items := "") {
        this.parentHwnd := parentHwnd
        this.bgColor := ModernWindow.Theme["bg"]
        this.fgColor := ModernWindow.Theme["fg"]
        this.hoverBg := ModernWindow.Theme["bgAlt"]
        this.borderColor := ModernWindow.Theme["border"]
        this.selectedBg := ModernWindow.Theme.Has("accent") ? ModernWindow.Theme["accent"] : 0x0078D4
        
        DarkGridView._InitGdiPlus()
        
        this.ctrl := guiObj.AddText(options " +0x100 +Border", "")
        this._hwnd := this.ctrl.Hwnd
        
        if ModernWindow._AllowDarkModeForWindow
            DllCall(ModernWindow._AllowDarkModeForWindow, "Ptr", this._hwnd, "Int", 1)
        
        DarkGridView.Instances[this._hwnd] := this
        
        cb := CallbackCreate(ObjBindMethod(this, "_WndProc"), "F", 4)
        DarkGridView.Callbacks[this._hwnd] := cb
        DarkGridView.OrigWndProcs[this._hwnd] := DllCall("SetWindowLongPtr", "Ptr", this._hwnd, "Int", -4, "Ptr", cb, "Ptr")
        
        if (items != "" && items is Array)
            this.SetItems(items)
        
        this._UpdateLayout()
    }
    
    static _InitGdiPlus() {
        if (DarkGridView.GdipToken != 0)
            return
        
        input := Buffer(24, 0)
        NumPut("UInt", 1, input, 0)
        token := 0
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", input, "Ptr", 0)
        DarkGridView.GdipToken := token
    }
    
    SetItems(items) {
        this.items := []
        this.selectedIndices := []
        this.hoveredIndex := 0
        this.focusedIndex := items.Length > 0 ? 1 : 0
        this.scrollOffset := 0
        
        for item in items {
            if (item is String)
                this.items.Push(Map("text", item, "icon", ""))
            else if (item is Map)
                this.items.Push(item)
            else
                this.items.Push(Map("text", String(item), "icon", ""))
        }
        
        this._UpdateLayout()
        this._Invalidate()
    }
    
    AddItem(text, icon := "") {
        this.items.Push(Map("text", text, "icon", icon))
        this._UpdateLayout()
        this._Invalidate()
    }
    
    RemoveItem(index) {
        if (index < 1 || index > this.items.Length)
            return
        
        this.items.RemoveAt(index)
        
        newSelected := []
        for i in this.selectedIndices {
            if (i < index)
                newSelected.Push(i)
            else if (i > index)
                newSelected.Push(i - 1)
        }
        this.selectedIndices := newSelected
        
        if (this.focusedIndex > this.items.Length)
            this.focusedIndex := this.items.Length
        if (this.focusedIndex < 1 && this.items.Length > 0)
            this.focusedIndex := 1
        
        this._UpdateLayout()
        this._Invalidate()
    }
    
    Clear() {
        this.items := []
        this.selectedIndices := []
        this.hoveredIndex := 0
        this.focusedIndex := 0
        this.scrollOffset := 0
        this._UpdateLayout()
        this._Invalidate()
    }
    
    GetSelectedItems() {
        result := []
        for idx in this.selectedIndices {
            if (idx >= 1 && idx <= this.items.Length)
                result.Push(this.items[idx])
        }
        return result
    }
    
    GetSelectedIndex() {
        return this.selectedIndices.Length > 0 ? this.selectedIndices[1] : 0
    }
    
    SetSelectedIndex(index) {
        if (this.selectionMode = 0)
            return
        
        this.selectedIndices := []
        if (index >= 1 && index <= this.items.Length) {
            this.selectedIndices.Push(index)
            this.focusedIndex := index
            this._EnsureVisible(index)
        }
        this._Invalidate()
    }
    
    _UpdateLayout() {
        rect := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", this._hwnd, "Ptr", rect)
        this.clientWidth := NumGet(rect, 8, "Int")
        this.clientHeight := NumGet(rect, 12, "Int")
        
        effectiveWidth := this.clientWidth - 4
        this.columns := Max(1, effectiveWidth // (this.itemWidth + this.itemPadding))
        this.rows := Ceil(this.items.Length / this.columns)
        this.totalHeight := this.rows * (this.itemHeight + this.itemPadding) + this.itemPadding
        this.visibleRows := Ceil(this.clientHeight / (this.itemHeight + this.itemPadding))
        
        this._hasScrollBar := this.totalHeight > this.clientHeight
        
        maxScroll := Max(0, this.totalHeight - this.clientHeight)
        if (this.scrollOffset > maxScroll)
            this.scrollOffset := maxScroll
    }
    
    _GetItemRect(index) {
        if (index < 1 || index > this.items.Length)
            return ""
        
        col := Mod(index - 1, this.columns)
        row := (index - 1) // this.columns
        
        x := this.itemPadding + col * (this.itemWidth + this.itemPadding) + 2
        y := this.itemPadding + row * (this.itemHeight + this.itemPadding) - this.scrollOffset + 2
        
        return Map("x", x, "y", y, "w", this.itemWidth, "h", this.itemHeight)
    }
    
    _HitTest(x, y) {
        for index, item in this.items {
            rect := this._GetItemRect(index)
            if (rect = "")
                continue
            
            if (x >= rect["x"] && x < rect["x"] + rect["w"] &&
                y >= rect["y"] && y < rect["y"] + rect["h"]) {
                return index
            }
        }
        return 0
    }
    
    _EnsureVisible(index) {
        rect := this._GetItemRect(index)
        if (rect = "")
            return
        
        actualY := rect["y"] + this.scrollOffset - 2
        
        if (actualY < this.scrollOffset)
            this.scrollOffset := actualY - this.itemPadding
        else if (actualY + rect["h"] > this.scrollOffset + this.clientHeight)
            this.scrollOffset := actualY + rect["h"] - this.clientHeight + this.itemPadding
        
        this.scrollOffset := Max(0, Min(this.scrollOffset, this.totalHeight - this.clientHeight))
    }
    
    _IsSelected(index) {
        for i in this.selectedIndices {
            if (i = index)
                return true
        }
        return false
    }
    
    _ToggleSelection(index) {
        for i, idx in this.selectedIndices {
            if (idx = index) {
                this.selectedIndices.RemoveAt(i)
                return
            }
        }
        this.selectedIndices.Push(index)
    }
    
    _SelectRange(fromIndex, toIndex) {
        startIdx := Min(fromIndex, toIndex)
        endIdx := Max(fromIndex, toIndex)
        
        loop endIdx - startIdx + 1 {
            idx := startIdx + A_Index - 1
            if (!this._IsSelected(idx))
                this.selectedIndices.Push(idx)
        }
    }
    
    _Invalidate() {
        DllCall("InvalidateRect", "Ptr", this._hwnd, "Ptr", 0, "Int", 1)
    }
    
    _Paint(hdc) {
        rect := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", this._hwnd, "Ptr", rect)
        width := NumGet(rect, 8, "Int")
        height := NumGet(rect, 12, "Int")
        
        memDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
        memBmp := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", width, "Int", height, "Ptr")
        oldBmp := DllCall("SelectObject", "Ptr", memDC, "Ptr", memBmp, "Ptr")
        
        bgBrush := DllCall("CreateSolidBrush", "UInt", this.bgColor, "Ptr")
        fillRect := Buffer(16, 0)
        NumPut("Int", 0, fillRect, 0)
        NumPut("Int", 0, fillRect, 4)
        NumPut("Int", width, fillRect, 8)
        NumPut("Int", height, fillRect, 12)
        DllCall("FillRect", "Ptr", memDC, "Ptr", fillRect, "Ptr", bgBrush)
        DllCall("DeleteObject", "Ptr", bgBrush)
        
        graphics := 0
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", memDC, "Ptr*", &graphics)
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", graphics, "Int", 4)
        DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", graphics, "Int", 5)
        
        for index, item in this.items {
            itemRect := this._GetItemRect(index)
            if (itemRect = "")
                continue
            
            if (itemRect["y"] + itemRect["h"] < 0 || itemRect["y"] > height)
                continue
            
            isSelected := this._IsSelected(index)
            isHovered := (index = this.hoveredIndex)
            isFocused := (index = this.focusedIndex)
            
            this._DrawItem(graphics, itemRect, item, isSelected, isHovered, isFocused)
        }
        
        if (this._hasScrollBar)
            this._DrawScrollBar(memDC, width, height)
        
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", graphics)
        
        DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", width, "Int", height, 
                "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
        
        DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
        DllCall("DeleteObject", "Ptr", memBmp)
        DllCall("DeleteDC", "Ptr", memDC)
    }
    
    _DrawItem(graphics, rect, item, isSelected, isHovered, isFocused) {
        x := rect["x"]
        y := rect["y"]
        w := rect["w"]
        h := rect["h"]
        
        bgARGB := 0
        if (isSelected)
            bgARGB := 0xFF000000 | ((this.selectedBg & 0xFF) << 16) | (this.selectedBg & 0xFF00) | ((this.selectedBg >> 16) & 0xFF)
        else if (isHovered)
            bgARGB := 0xFF000000 | ((this.hoverBg & 0xFF) << 16) | (this.hoverBg & 0xFF00) | ((this.hoverBg >> 16) & 0xFF)
        
        if (bgARGB != 0) {
            brush := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", bgARGB, "Ptr*", &brush)
            
            path := 0
            DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
            radius := 4.0
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y, "Float", radius * 2, "Float", radius * 2, "Float", 180.0, "Float", 90.0)
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - radius * 2, "Float", y, "Float", radius * 2, "Float", radius * 2, "Float", 270.0, "Float", 90.0)
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - radius * 2, "Float", y + h - radius * 2, "Float", radius * 2, "Float", radius * 2, "Float", 0.0, "Float", 90.0)
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y + h - radius * 2, "Float", radius * 2, "Float", radius * 2, "Float", 90.0, "Float", 90.0)
            DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
            DllCall("gdiplus\GdipFillPath", "Ptr", graphics, "Ptr", brush, "Ptr", path)
            DllCall("gdiplus\GdipDeletePath", "Ptr", path)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
        }
        
        if (isFocused && !isSelected) {
            pen := 0
            focusARGB := 0xFF000000 | ((this.borderColor & 0xFF) << 16) | (this.borderColor & 0xFF00) | ((this.borderColor >> 16) & 0xFF)
            DllCall("gdiplus\GdipCreatePen1", "UInt", focusARGB, "Float", 1.0, "Int", 2, "Ptr*", &pen)
            
            path := 0
            DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
            radius := 4.0
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + 0.5, "Float", y + 0.5, "Float", radius * 2, "Float", radius * 2, "Float", 180.0, "Float", 90.0)
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - radius * 2 - 0.5, "Float", y + 0.5, "Float", radius * 2, "Float", radius * 2, "Float", 270.0, "Float", 90.0)
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - radius * 2 - 0.5, "Float", y + h - radius * 2 - 0.5, "Float", radius * 2, "Float", radius * 2, "Float", 0.0, "Float", 90.0)
            DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + 0.5, "Float", y + h - radius * 2 - 0.5, "Float", radius * 2, "Float", radius * 2, "Float", 90.0, "Float", 90.0)
            DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
            DllCall("gdiplus\GdipDrawPath", "Ptr", graphics, "Ptr", pen, "Ptr", path)
            DllCall("gdiplus\GdipDeletePath", "Ptr", path)
            DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
        }
        
        iconY := y + 10
        iconX := x + (w - this.iconSize) // 2
        
        if (item.Has("icon") && item["icon"] != "") {
            iconPath := item["icon"]
            image := 0
            if FileExist(iconPath)
                DllCall("gdiplus\GdipLoadImageFromFile", "WStr", iconPath, "Ptr*", &image)
            
            if (image) {
                DllCall("gdiplus\GdipDrawImageRectI", "Ptr", graphics, "Ptr", image, 
                        "Int", iconX, "Int", iconY, "Int", this.iconSize, "Int", this.iconSize)
                DllCall("gdiplus\GdipDisposeImage", "Ptr", image)
            } else {
                this._DrawPlaceholderIcon(graphics, iconX, iconY, this.iconSize)
            }
        } else {
            this._DrawPlaceholderIcon(graphics, iconX, iconY, this.iconSize)
        }
        
        textY := iconY + this.iconSize + 6
        textH := h - (textY - y) - 4
        
        textColor := isSelected ? this.selectedFg : this.fgColor
        textARGB := 0xFF000000 | ((textColor & 0xFF) << 16) | (textColor & 0xFF00) | ((textColor >> 16) & 0xFF)
        
        textBrush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", textARGB, "Ptr*", &textBrush)
        
        fontFamily := 0
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", &fontFamily)
        
        font := 0
        DllCall("gdiplus\GdipCreateFont", "Ptr", fontFamily, "Float", 11.0, "Int", 0, "Int", 2, "Ptr*", &font)
        
        stringFormat := 0
        DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &stringFormat)
        DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", stringFormat, "Int", 1)
        DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", stringFormat, "Int", 0)
        DllCall("gdiplus\GdipSetStringFormatTrimming", "Ptr", stringFormat, "Int", 3)
        
        textRect := Buffer(16, 0)
        NumPut("Float", x + 4, textRect, 0)
        NumPut("Float", textY, textRect, 4)
        NumPut("Float", w - 8, textRect, 8)
        NumPut("Float", textH, textRect, 12)
        
        text := item.Has("text") ? item["text"] : ""
        DllCall("gdiplus\GdipDrawString", "Ptr", graphics, "WStr", text, "Int", -1, 
                "Ptr", font, "Ptr", textRect, "Ptr", stringFormat, "Ptr", textBrush)
        
        DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", stringFormat)
        DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", fontFamily)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", textBrush)
    }
    
    _DrawPlaceholderIcon(graphics, x, y, size) {
        this._DrawFolderIcon(graphics, x, y, size)
    }
    
    _DrawFolderIcon(graphics, x, y, size) {
        folderColor := 0xFFF4C142
        folderDark := 0xFFD4A832
        
        brush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", folderColor, "Ptr*", &brush)
        
        tabW := size * 0.4
        tabH := size * 0.15
        path := 0
        DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y, "Float", 4.0, "Float", 4.0, "Float", 180.0, "Float", 90.0)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", x + 2, "Float", y, "Float", x + tabW - 2, "Float", y)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", x + tabW - 2, "Float", y, "Float", x + tabW + 2, "Float", y + tabH)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", x + tabW + 2, "Float", y + tabH, "Float", x + size - 2, "Float", y + tabH)
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + size - 4, "Float", y + tabH, "Float", 4.0, "Float", 4.0, "Float", 270.0, "Float", 90.0)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", x + size, "Float", y + tabH + 2, "Float", x + size, "Float", y + size - 2)
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + size - 4, "Float", y + size - 4, "Float", 4.0, "Float", 4.0, "Float", 0.0, "Float", 90.0)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", x + size - 2, "Float", y + size, "Float", x + 2, "Float", y + size)
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y + size - 4, "Float", 4.0, "Float", 4.0, "Float", 90.0, "Float", 90.0)
        DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
        DllCall("gdiplus\GdipFillPath", "Ptr", graphics, "Ptr", brush, "Ptr", path)
        DllCall("gdiplus\GdipDeletePath", "Ptr", path)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
        
        darkBrush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", folderDark, "Ptr*", &darkBrush)
        bodyTop := y + tabH + 2
        bodyH := size - tabH - 4
        path2 := 0
        DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path2)
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path2, "Float", x, "Float", bodyTop, "Float", 4.0, "Float", 4.0, "Float", 180.0, "Float", 90.0)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path2, "Float", x + 2, "Float", bodyTop, "Float", x + size - 2, "Float", bodyTop)
        DllCall("gdiplus\GdipAddPathArc", "Ptr", path2, "Float", x + size - 4, "Float", bodyTop, "Float", 4.0, "Float", 4.0, "Float", 270.0, "Float", 90.0)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path2, "Float", x + size, "Float", bodyTop + 2, "Float", x + size, "Float", bodyTop + bodyH * 0.3)
        DllCall("gdiplus\GdipAddPathLine", "Ptr", path2, "Float", x + size, "Float", bodyTop + bodyH * 0.3, "Float", x, "Float", bodyTop + bodyH * 0.3)
        DllCall("gdiplus\GdipClosePathFigure", "Ptr", path2)
        DllCall("gdiplus\GdipFillPath", "Ptr", graphics, "Ptr", darkBrush, "Ptr", path2)
        DllCall("gdiplus\GdipDeletePath", "Ptr", path2)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", darkBrush)
    }
    
    _DrawScrollBar(hdc, width, height) {
        if (this.totalHeight <= height)
            return
        
        sbX := width - this._scrollBarWidth - 2
        sbY := 2
        sbW := this._scrollBarWidth - 2
        sbH := height - 4
        
        trackBrush := DllCall("CreateSolidBrush", "UInt", this.bgColor, "Ptr")
        trackRect := Buffer(16, 0)
        NumPut("Int", sbX, trackRect, 0)
        NumPut("Int", sbY, trackRect, 4)
        NumPut("Int", sbX + sbW, trackRect, 8)
        NumPut("Int", sbY + sbH, trackRect, 12)
        DllCall("FillRect", "Ptr", hdc, "Ptr", trackRect, "Ptr", trackBrush)
        DllCall("DeleteObject", "Ptr", trackBrush)
        
        thumbRatio := height / this.totalHeight
        thumbH := Max(30, sbH * thumbRatio)
        thumbY := sbY + (this.scrollOffset / (this.totalHeight - height)) * (sbH - thumbH)
        
        thumbBrush := DllCall("CreateSolidBrush", "UInt", this.borderColor, "Ptr")
        thumbRect := Buffer(16, 0)
        NumPut("Int", sbX + 2, thumbRect, 0)
        NumPut("Int", Integer(thumbY), thumbRect, 4)
        NumPut("Int", sbX + sbW - 2, thumbRect, 8)
        NumPut("Int", Integer(thumbY + thumbH), thumbRect, 12)
        DllCall("FillRect", "Ptr", hdc, "Ptr", thumbRect, "Ptr", thumbBrush)
        DllCall("DeleteObject", "Ptr", thumbBrush)
    }
    
    _HandleClick(x, y, ctrl, shift) {
        if (this.selectionMode = 0)
            return
        
        index := this._HitTest(x, y)
        if (index = 0) {
            if (!ctrl && !shift)
                this.selectedIndices := []
            this._Invalidate()
            return
        }
        
        this.focusedIndex := index
        
        switch this.selectionMode {
            case 1:
                this.selectedIndices := [index]
            case 2:
                this._ToggleSelection(index)
            case 3:
                if (ctrl)
                    this._ToggleSelection(index)
                else if (shift && this.selectedIndices.Length > 0)
                    this._SelectRange(this.selectedIndices[1], index)
                else
                    this.selectedIndices := [index]
        }
        
        this._Invalidate()
        this._FireSelectionChanged()
    }
    
    _HandleKeyDown(vk) {
        if (this.items.Length = 0)
            return false
        
        static VK_LEFT := 0x25, VK_UP := 0x26, VK_RIGHT := 0x27, VK_DOWN := 0x28
        static VK_HOME := 0x24, VK_END := 0x23, VK_PRIOR := 0x21, VK_NEXT := 0x22
        static VK_SPACE := 0x20, VK_RETURN := 0x0D, VK_A := 0x41
        
        ctrl := GetKeyState("Control", "P")
        shift := GetKeyState("Shift", "P")
        
        newIndex := this.focusedIndex
        
        switch vk {
            case VK_LEFT:
                newIndex := Max(1, this.focusedIndex - 1)
            case VK_RIGHT:
                newIndex := Min(this.items.Length, this.focusedIndex + 1)
            case VK_UP:
                newIndex := Max(1, this.focusedIndex - this.columns)
            case VK_DOWN:
                newIndex := Min(this.items.Length, this.focusedIndex + this.columns)
            case VK_HOME:
                newIndex := 1
            case VK_END:
                newIndex := this.items.Length
            case VK_PRIOR:
                newIndex := Max(1, this.focusedIndex - this.columns * this.visibleRows)
            case VK_NEXT:
                newIndex := Min(this.items.Length, this.focusedIndex + this.columns * this.visibleRows)
            case VK_SPACE, VK_RETURN:
                if (this.selectionMode = 2)
                    this._ToggleSelection(this.focusedIndex)
                else if (this.selectionMode != 0)
                    this.selectedIndices := [this.focusedIndex]
                this._Invalidate()
                this._FireSelectionChanged()
                return true
            case VK_A:
                if (ctrl && this.selectionMode >= 2) {
                    this.selectedIndices := []
                    loop this.items.Length
                        this.selectedIndices.Push(A_Index)
                    this._Invalidate()
                    this._FireSelectionChanged()
                    return true
                }
                return false
            default:
                return false
        }
        
        if (newIndex != this.focusedIndex) {
            this.focusedIndex := newIndex
            
            if (this.selectionMode != 0) {
                if (shift && this.selectionMode = 3 && this.selectedIndices.Length > 0) {
                    this._SelectRange(this.selectedIndices[1], newIndex)
                } else if (!ctrl || this.selectionMode = 1) {
                    this.selectedIndices := [newIndex]
                }
            }
            
            this._EnsureVisible(newIndex)
            this._Invalidate()
            this._FireSelectionChanged()
            return true
        }
        
        return false
    }
    
    _HandleMouseWheel(delta) {
        if (!this._hasScrollBar)
            return
        
        scrollAmount := (this.itemHeight + this.itemPadding) * (delta < 0 ? 1 : -1)
        this.scrollOffset := Max(0, Min(this.scrollOffset + scrollAmount, this.totalHeight - this.clientHeight))
        this._Invalidate()
    }
    
    _FireSelectionChanged() {
        if (this.ctrl && this.ctrl.HasMethod("OnEvent"))
            return
    }
    
    _WndProc(hwnd, msg, wParam, lParam) {
        static WM_PAINT := 0x0F, WM_ERASEBKGND := 0x14, WM_LBUTTONDOWN := 0x201
        static WM_MOUSEMOVE := 0x200, WM_MOUSELEAVE := 0x2A3, WM_MOUSEWHEEL := 0x20A
        static WM_KEYDOWN := 0x100, WM_SIZE := 0x05, WM_SETFOCUS := 0x07
        static TME_LEAVE := 0x02
        
        if (msg = WM_PAINT) {
            ps := Buffer(72, 0)
            hdc := DllCall("BeginPaint", "Ptr", hwnd, "Ptr", ps, "Ptr")
            this._Paint(hdc)
            DllCall("EndPaint", "Ptr", hwnd, "Ptr", ps)
            return 0
        }
        
        if (msg = WM_ERASEBKGND)
            return 1
        
        if (msg = WM_SIZE) {
            this._UpdateLayout()
            this._Invalidate()
            return 0
        }
        
        if (msg = WM_LBUTTONDOWN) {
            DllCall("SetFocus", "Ptr", hwnd)
            x := lParam & 0xFFFF
            y := (lParam >> 16) & 0xFFFF
            ctrl := (wParam & 0x08) != 0
            shift := (wParam & 0x04) != 0
            this._HandleClick(x, y, ctrl, shift)
            return 0
        }
        
        if (msg = WM_MOUSEMOVE) {
            x := lParam & 0xFFFF
            y := (lParam >> 16) & 0xFFFF
            
            newHover := this._HitTest(x, y)
            if (newHover != this.hoveredIndex) {
                this.hoveredIndex := newHover
                this._Invalidate()
            }
            
            tme := Buffer(24, 0)
            NumPut("UInt", 24, tme, 0)
            NumPut("UInt", TME_LEAVE, tme, 4)
            NumPut("Ptr", hwnd, tme, 8)
            DllCall("TrackMouseEvent", "Ptr", tme)
            return 0
        }
        
        if (msg = WM_MOUSELEAVE) {
            if (this.hoveredIndex != 0) {
                this.hoveredIndex := 0
                this._Invalidate()
            }
            return 0
        }
        
        if (msg = WM_MOUSEWHEEL) {
            delta := (wParam >> 16) & 0xFFFF
            if (delta > 0x7FFF)
                delta := delta - 0x10000
            this._HandleMouseWheel(delta)
            return 0
        }
        
        if (msg = WM_KEYDOWN) {
            if (this._HandleKeyDown(wParam))
                return 0
        }
        
        if (msg = WM_SETFOCUS) {
            this._Invalidate()
            return 0
        }
        
        if DarkGridView.OrigWndProcs.Has(hwnd)
            return DllCall("CallWindowProc", "Ptr", DarkGridView.OrigWndProcs[hwnd], "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
        return DllCall("DefWindowProc", "Ptr", hwnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    }
    
    __Delete() {
        if DarkGridView.Callbacks.Has(this._hwnd) {
            DllCall("SetWindowLongPtr", "Ptr", this._hwnd, "Int", -4, "Ptr", DarkGridView.OrigWndProcs[this._hwnd], "Ptr")
            CallbackFree(DarkGridView.Callbacks[this._hwnd])
            DarkGridView.Callbacks.Delete(this._hwnd)
            DarkGridView.OrigWndProcs.Delete(this._hwnd)
        }
        
        if DarkGridView.Instances.Has(this._hwnd)
            DarkGridView.Instances.Delete(this._hwnd)
    }
}
