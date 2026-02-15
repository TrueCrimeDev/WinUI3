#Requires AutoHotkey v2.1-alpha.11

; =============================================================================
; BasicXamlGui - XAML Island wrapper extending Gui
; =============================================================================
; Wraps a standard AHK Gui with WinUI3 XAML island support via direct WinRT.
; No bridge DLL needed - uses DesktopWindowXamlSource directly.
;
; Usage:
;   xg := BasicXamlGui('+Resize', 'My App')
;   ApplyThemeToXamlGui(xg)
;   xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
;   ApplyXamlTheme(xg)
;   xg.Show("w800 h600")

class BasicXamlGui extends Gui {
    __new(opt := '', title := unset) {
        super.__new(opt ' -DPIScale', IsSet(title) ? title : A_ScriptName, this)

        ; Set up message handlers for keyboard input
        static _ := (
            OnMessage(0x100, BasicXamlGui._OnKeyDown.Bind(BasicXamlGui))
        )

        ; Create the XAML island host
        this._dwxs := dwxs := WinRT('Microsoft.UI.Xaml.Hosting.DesktopWindowXamlSource')()

        ; Initialize with the parent window
        wid := WinRT('Microsoft.UI.WindowId')()
        wid.Value := this.hwnd
        dwxs.Initialize(wid)
        this._xwnd := dwxs.SiteBridge.WindowId.Value

        ; Auto-resize XAML content to match parent window
        dwxs.SiteBridge.ResizePolicy := 'ResizeContentToParentWindow'
    }

    Content {
        get => this._dwxs.Content
        set => this._dwxs.Content := value
    }

    __Item[name] => this._dwxs.Content.FindName(name)

    NavigateFocus(reason) =>
        this._dwxs.NavigateFocus(
            WinRT('Microsoft.UI.Xaml.Hosting.XamlSourceFocusNavigationRequest')(reason))

    static _OnKeyDown(wParam, lParam, nmsg, hwnd) {
        if !(wnd := GuiFromHwnd(hwnd, true)) || !(wnd is BasicXamlGui)
            return
        kmsg := Buffer(48, 0)
        NumPut('ptr', hwnd, 'ptr', nmsg, 'ptr', wParam, 'ptr', lParam
            , 'uint', A_EventInfo, kmsg)
        if DllCall("Microsoft.UI.Windowing.Core.dll\ContentPreTranslateMessage", 'ptr', kmsg)
            return 0
    }
}

; =============================================================================
; Theme Helpers
; =============================================================================

/**
 * Apply system theme to BasicXamlGui window.
 * Sets background color, dark title bar, and Mica/Acrylic backdrop.
 */
ApplyThemeToXamlGui(xg) {
    ; Match system background color
    bc := WinRT('Windows.UI.ViewManagement.UISettings')().GetColorValue('Background')
    xg.BackColor := Format('{:02x}{:02x}{:02x}', bc.R, bc.G, bc.B)

    ; Apply dark title bar if system is dark
    if DarkModeIsActive()
        SetDarkWindowFrame(xg.hwnd, true)

    ; Enable Mica/Acrylic backdrop effect
    NumPut('int', -1, 'int', -1, 'int', -1, 'int', -1, margins := Buffer(16))
    DllCall("dwmapi\DwmExtendFrameIntoClientArea", 'ptr', xg.hwnd, 'ptr', margins, 'hresult')
    DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', xg.hwnd, 'uint', 38, 'int*', 3, 'int', 4, 'hresult')
}

/**
 * Apply XAML theme to loaded content.
 * Sets RequestedTheme on the root element to match system theme.
 */
ApplyXamlTheme(xg) {
    try {
        if DarkModeIsActive()
            xg.Content.RequestedTheme := 2  ; ElementTheme.Dark
        else
            xg.Content.RequestedTheme := 1  ; ElementTheme.Light
    }
}

/**
 * Check if the system is using dark mode.
 */
DarkModeIsActive() {
    clr := WinRT('Windows.UI.ViewManagement.UISettings')().GetColorValue('Foreground')
    return ((5 * clr.G) + (2 * clr.R) + clr.B) > (8 * 128)
}

/**
 * Set dark window frame via DWM attribute.
 */
SetDarkWindowFrame(hwnd, dark) {
    if VerCompare(A_OSVersion, "10.0.17763") >= 0 {
        attr := VerCompare(A_OSVersion, "10.0.18985") >= 0 ? 20 : 19
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", dark, "int", 4)
    }
}
