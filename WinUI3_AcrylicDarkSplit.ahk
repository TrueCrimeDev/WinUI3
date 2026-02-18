#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include Lib\BasicXamlGui.ahk

; =============================================================================
; WinUI3 Acrylic / Dark Mode Split Demo
; =============================================================================
; Demonstrates a split-pane layout where the left half uses a translucent
; acrylic backdrop (showing the desktop through) and the right half uses a
; solid dark-mode surface. Both sides share WinUI3 controls.

try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    MsgBox("Failed to load Windows App Runtime 1.6`n`n"
        . "Error: " e.Message, "Acrylic Dark Split", "Icon!")
    ExitApp()
}

DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

; --- Permissive overload handler (for AppWindow title bar) ---
_PermissiveOverloadAdd(self, f) {
    n := f.MinParams
    Loop (f.MaxParams - n) + 1
        self.m[n++] := f
}

; --- IReference<Color> COM helpers for caption button colors ---
_MakeIRefColor(a, r, g, b) {
    static prevent_gc := [], vt := _InitIRefColorVT()
    obj := Buffer(A_PtrSize + 8, 0)
    NumPut("Ptr", vt.Ptr, obj, 0)
    NumPut("UInt", 1, obj, A_PtrSize)
    NumPut("UChar", a, "UChar", r, "UChar", g, "UChar", b, obj, A_PtrSize + 4)
    prevent_gc.Push(obj)
    return obj.Ptr
}
_InitIRefColorVT() {
    vt := Buffer(7 * A_PtrSize, 0)
    NumPut("Ptr", CallbackCreate(_QI, , 3),
           "Ptr", CallbackCreate(_AddRef, , 1),
           "Ptr", CallbackCreate(_Release, , 1),
           "Ptr", CallbackCreate(_GetIids, , 3),
           "Ptr", CallbackCreate(_GetClass, , 2),
           "Ptr", CallbackCreate(_GetTrust, , 2),
           "Ptr", CallbackCreate(_GetVal, , 2), vt)
    return vt
}
_BinGUID(str) {
    buf := Buffer(16)
    DllCall("ole32\CLSIDFromString", "Str", str, "Ptr", buf)
    return buf
}
_QI(this_ptr, riid, ppv) {
    static iidU := _BinGUID("{00000000-0000-0000-C000-000000000046}")
    static iidI := _BinGUID("{AF86E2E0-B12D-4C6A-9C5A-D7AA65101E90}")
    static iidR := _BinGUID("{AB8E5D11-B0C1-5A21-95AE-F16BF3A37624}")
    if (_GuidEq(riid, iidU) || _GuidEq(riid, iidI) || _GuidEq(riid, iidR)) {
        NumPut("Ptr", this_ptr, ppv)
        _AddRef(this_ptr)
        return 0
    }
    NumPut("Ptr", 0, ppv)
    return 0x80004002
}
_GuidEq(a, b) => NumGet(a, 0, "Int64") = NumGet(b.Ptr, 0, "Int64")
                && NumGet(a, 8, "Int64") = NumGet(b.Ptr, 8, "Int64")
_AddRef(p) => (rc := NumGet(p, A_PtrSize, "UInt") + 1, NumPut("UInt", rc, p, A_PtrSize), rc)
_Release(p) => (rc := NumGet(p, A_PtrSize, "UInt") - 1, NumPut("UInt", rc, p, A_PtrSize), rc)
_GetIids(p, pC, pI) => (NumPut("UInt", 0, pC), NumPut("Ptr", 0, pI), 0)
_GetClass(p, pN) => (NumPut("Ptr", 0, pN), 0)
_GetTrust(p, pL) => (NumPut("UInt", 0, pL), 0)
_GetVal(p, pC) => (NumPut("UInt", NumGet(p, A_PtrSize + 4, "UInt"), pC), 0)

; =============================================================================
; Build the GUI
; =============================================================================
xg := BasicXamlGui('+Resize', 'Acrylic / Dark Mode Split')

; --- Apply DWM acrylic backdrop to the entire window ---
NumPut('int', -1, 'int', -1, 'int', -1, 'int', -1, margins := Buffer(16))
DllCall("dwmapi\DwmExtendFrameIntoClientArea", 'ptr', xg.hwnd, 'ptr', margins, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', xg.hwnd, 'uint', 38, 'int*', 3, 'int', 4, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', xg.hwnd, 'uint', 20, 'int*', 1, 'int', 4)

xg.BackColor := '1E1E1E'

; =============================================================================
; XAML Layout - Split pane: Acrylic left, Dark right
; =============================================================================
xaml := "
(
<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
      xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
      Background='Transparent' ColumnDefinitions='*,*'>

    <!-- LEFT HALF: Acrylic / Translucent -->
    <Grid Grid.Column='0' Background='Transparent' RowDefinitions='48,*'>

        <StackPanel Grid.Row='0' Orientation='Horizontal' Spacing='10'
                    VerticalAlignment='Center' Margin='20,0,0,0'>
            <SymbolIcon Symbol='Setting' Foreground='#FFFFFF'/>
            <TextBlock Text='Acrylic Backdrop' FontSize='14' FontWeight='SemiBold'
                       Foreground='#FFFFFF'/>
        </StackPanel>

        <StackPanel Grid.Row='1' Padding='24,8,24,24' Spacing='16'>
            <TextBlock Text='Translucent Surface' FontSize='20' FontWeight='Bold'
                       Foreground='#FFFFFF'/>
            <TextBlock TextWrapping='Wrap' Foreground='#CCFFFFFF' FontSize='13'
                       Text='This side uses the DWM Acrylic backdrop. The desktop shows through the translucent blur. Great for tool palettes, sidebars, and floating panels.'/>

            <Border Background='#30FFFFFF' CornerRadius='8' Padding='16' Margin='0,8,0,0'>
                <StackPanel Spacing='12'>
                    <TextBlock Text='Quick Actions' FontSize='13' FontWeight='SemiBold' Foreground='#FFFFFF'/>
                    <Button x:Name='AcrylicBtn1' Content='New Item'
                            HorizontalAlignment='Stretch'
                            Background='#40FFFFFF' Foreground='#FFFFFF'
                            BorderThickness='0' CornerRadius='6' Padding='12,8'/>
                    <Button x:Name='AcrylicBtn2' Content='Open File'
                            HorizontalAlignment='Stretch'
                            Background='#40FFFFFF' Foreground='#FFFFFF'
                            BorderThickness='0' CornerRadius='6' Padding='12,8'/>
                    <Button x:Name='AcrylicBtn3' Content='Settings'
                            HorizontalAlignment='Stretch'
                            Background='#40FFFFFF' Foreground='#FFFFFF'
                            BorderThickness='0' CornerRadius='6' Padding='12,8'/>
                </StackPanel>
            </Border>

            <Border Background='#30FFFFFF' CornerRadius='8' Padding='16' Margin='0,4,0,0'>
                <StackPanel Spacing='10'>
                    <TextBlock Text='System Status' FontSize='13' FontWeight='SemiBold' Foreground='#FFFFFF'/>

                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock Text='CPU Usage' Foreground='#AAFFFFFF' FontSize='12'/>
                        <TextBlock Grid.Column='1' Text='24' Foreground='#4CC2FF' FontSize='12' FontWeight='SemiBold'/>
                    </Grid>
                    <Border Background='#30FFFFFF' CornerRadius='3' Height='6'>
                        <Border Background='#4CC2FF' CornerRadius='3' Height='6'
                                HorizontalAlignment='Left' Width='96'/>
                    </Border>

                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock Text='Memory' Foreground='#AAFFFFFF' FontSize='12'/>
                        <TextBlock Grid.Column='1' Text='61' Foreground='#8B5CF6' FontSize='12' FontWeight='SemiBold'/>
                    </Grid>
                    <Border Background='#30FFFFFF' CornerRadius='3' Height='6'>
                        <Border Background='#8B5CF6' CornerRadius='3' Height='6'
                                HorizontalAlignment='Left' Width='244'/>
                    </Border>

                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock Text='Disk I/O' Foreground='#AAFFFFFF' FontSize='12'/>
                        <TextBlock Grid.Column='1' Text='12' Foreground='#2DB84D' FontSize='12' FontWeight='SemiBold'/>
                    </Grid>
                    <Border Background='#30FFFFFF' CornerRadius='3' Height='6'>
                        <Border Background='#2DB84D' CornerRadius='3' Height='6'
                                HorizontalAlignment='Left' Width='48'/>
                    </Border>
                </StackPanel>
            </Border>
        </StackPanel>
    </Grid>

    <!-- RIGHT HALF: Solid Dark Mode -->
    <Grid Grid.Column='1' Background='#FF1E1E1E' RowDefinitions='48,*'>

        <Border Grid.Row='0' Background='#FF252525' BorderBrush='#FF333333' BorderThickness='0,0,0,1'>
            <StackPanel Orientation='Horizontal' Spacing='10'
                        VerticalAlignment='Center' Margin='20,0,0,0'>
                <SymbolIcon Symbol='View' Foreground='#4CC2FF'/>
                <TextBlock Text='Dark Mode Surface' FontSize='14' FontWeight='SemiBold'
                           Foreground='#E0E0E0'/>
            </StackPanel>
        </Border>

        <ScrollViewer Grid.Row='1' VerticalScrollBarVisibility='Auto'>
            <StackPanel Padding='24,16,24,24' Spacing='16'>
                <TextBlock Text='Solid Surface' FontSize='20' FontWeight='Bold' Foreground='#E0E0E0'/>
                <TextBlock TextWrapping='Wrap' Foreground='#999999' FontSize='13'
                           Text='This side uses an opaque dark background. Ideal for content areas, editors, and primary workspace panels where readability is key.'/>

                <!-- Notifications Card -->
                <Border Background='#FF2D2D2D' CornerRadius='8' Padding='16' Margin='0,4,0,0'
                        BorderBrush='#FF404040' BorderThickness='1'>
                    <StackPanel Spacing='12'>
                        <Grid ColumnDefinitions='*,Auto'>
                            <TextBlock Text='Notifications' FontSize='13' FontWeight='SemiBold' Foreground='#E0E0E0'/>
                            <Border Grid.Column='1' Background='#4CC2FF' CornerRadius='10' Padding='8,2'>
                                <TextBlock Text='3 new' FontSize='10' Foreground='#000000' FontWeight='SemiBold'/>
                            </Border>
                        </Grid>

                        <Border Background='#FF353535' CornerRadius='6' Padding='12,10'>
                            <Grid ColumnDefinitions='Auto,*'>
                                <SymbolIcon Symbol='Accept' Foreground='#2DB84D' Margin='0,0,10,0'/>
                                <StackPanel Grid.Column='1'>
                                    <TextBlock Text='Build succeeded' FontSize='12' Foreground='#E0E0E0'/>
                                    <TextBlock Text='Project compiled with 0 warnings' FontSize='11' Foreground='#666666'/>
                                </StackPanel>
                            </Grid>
                        </Border>

                        <Border Background='#FF353535' CornerRadius='6' Padding='12,10'>
                            <Grid ColumnDefinitions='Auto,*'>
                                <SymbolIcon Symbol='Download' Foreground='#4CC2FF' Margin='0,0,10,0'/>
                                <StackPanel Grid.Column='1'>
                                    <TextBlock Text='Update available' FontSize='12' Foreground='#E0E0E0'/>
                                    <TextBlock Text='WinUI3 SDK 1.7 preview' FontSize='11' Foreground='#666666'/>
                                </StackPanel>
                            </Grid>
                        </Border>

                        <Border Background='#FF353535' CornerRadius='6' Padding='12,10'>
                            <Grid ColumnDefinitions='Auto,*'>
                                <SymbolIcon Symbol='Important' Foreground='#E8A317' Margin='0,0,10,0'/>
                                <StackPanel Grid.Column='1'>
                                    <TextBlock Text='Memory threshold' FontSize='12' Foreground='#E0E0E0'/>
                                    <TextBlock Text='Process using 512 MB' FontSize='11' Foreground='#666666'/>
                                </StackPanel>
                            </Grid>
                        </Border>
                    </StackPanel>
                </Border>

                <!-- Controls Card -->
                <Border Background='#FF2D2D2D' CornerRadius='8' Padding='16'
                        BorderBrush='#FF404040' BorderThickness='1'>
                    <StackPanel Spacing='12'>
                        <TextBlock Text='Interactive Controls' FontSize='13' FontWeight='SemiBold' Foreground='#E0E0E0'/>
                        <ToggleSwitch x:Name='DarkToggle' IsOn='True'/>
                        <Slider x:Name='OpacitySlider' Minimum='0' Maximum='100' Value='60'/>
                        <TextBlock x:Name='SliderLabel' Text='Tint: 60' FontSize='12' Foreground='#999999'/>
                    </StackPanel>
                </Border>

                <!-- Info Card -->
                <Border Background='#FF2D2D2D' CornerRadius='8' Padding='16'
                        BorderBrush='#FF404040' BorderThickness='1'>
                    <StackPanel Spacing='8'>
                        <TextBlock Text='About This Demo' FontSize='13' FontWeight='SemiBold' Foreground='#E0E0E0'/>
                        <TextBlock TextWrapping='Wrap' FontSize='12' Foreground='#999999'
                                   Text='Built with AutoHotkey v2 and WinUI3 XAML Islands. The left panel uses DWM Acrylic backdrop (attribute 38) with DwmExtendFrameIntoClientArea. The right panel uses an opaque dark surface.'/>
                        <StackPanel Orientation='Horizontal' Spacing='16' Margin='0,4,0,0'>
                            <StackPanel>
                                <TextBlock Text='Framework' FontSize='10' Foreground='#666666'/>
                                <TextBlock Text='WinUI 3' FontSize='12' Foreground='#4CC2FF' FontWeight='SemiBold'/>
                            </StackPanel>
                            <StackPanel>
                                <TextBlock Text='Host' FontSize='10' Foreground='#666666'/>
                                <TextBlock Text='AHK v2' FontSize='12' Foreground='#8B5CF6' FontWeight='SemiBold'/>
                            </StackPanel>
                            <StackPanel>
                                <TextBlock Text='Backdrop' FontSize='10' Foreground='#666666'/>
                                <TextBlock Text='Acrylic' FontSize='12' Foreground='#2DB84D' FontWeight='SemiBold'/>
                            </StackPanel>
                        </StackPanel>
                    </StackPanel>
                </Border>
            </StackPanel>
        </ScrollViewer>
    </Grid>
</Grid>
)"

xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)

; Apply dark theme to XAML content
try xg.Content.RequestedTheme := 2  ; ElementTheme.Dark

; =============================================================================
; Set up custom title bar with transparent caption buttons
; =============================================================================
try {
    _saved := OverloadedFunc.Prototype.GetOwnPropDesc('Add')
    OverloadedFunc.Prototype.DefineProp('Add', {Call: _PermissiveOverloadAdd})
    try {
        wid := WinRT('Microsoft.UI.WindowId')()
        wid.Value := xg.hwnd
        appWin := WinRT('Microsoft.UI.Windowing.AppWindow').GetFromWindowId(wid)
        tb := appWin.TitleBar
        tb.ExtendsContentIntoTitleBar := true
        tb.PreferredHeightOption := 1  ; Tall

        bgRef   := _MakeIRefColor(0, 0, 0, 0)
        hoverBg := _MakeIRefColor(255, 0x33, 0x33, 0x33)
        pressBg := _MakeIRefColor(255, 0x44, 0x44, 0x44)
        inactBg := _MakeIRefColor(0, 0, 0, 0)
        fgRef   := _MakeIRefColor(255, 0xE0, 0xE0, 0xE0)
        hoverFg := _MakeIRefColor(255, 0xFF, 0xFF, 0xFF)
        pressFg := _MakeIRefColor(255, 0xFF, 0xFF, 0xFF)
        inactFg := _MakeIRefColor(255, 0x99, 0x99, 0x99)

        ComCall(9,  tb.ptr, "Ptr", bgRef)
        ComCall(11, tb.ptr, "Ptr", fgRef)
        ComCall(13, tb.ptr, "Ptr", hoverBg)
        ComCall(15, tb.ptr, "Ptr", hoverFg)
        ComCall(17, tb.ptr, "Ptr", inactBg)
        ComCall(19, tb.ptr, "Ptr", inactFg)
        ComCall(21, tb.ptr, "Ptr", pressBg)
        ComCall(23, tb.ptr, "Ptr", pressFg)
    }
    OverloadedFunc.Prototype.DefineProp('Add', _saved)
}

; =============================================================================
; Wire up interactive controls
; =============================================================================
try {
    xg['OpacitySlider'].add_ValueChanged((sender, args) => (
        val := Integer(sender.Value),
        xg['SliderLabel'].Text := 'Tint: ' val
    ))
}

try {
    xg['AcrylicBtn1'].add_Click((*) => ToolTip('New Item clicked'))
    xg['AcrylicBtn2'].add_Click((*) => ToolTip('Open File clicked'))
    xg['AcrylicBtn3'].add_Click((*) => ToolTip('Settings clicked'))
}

xg.Show("w900 h600")
xg.NavigateFocus('First')
