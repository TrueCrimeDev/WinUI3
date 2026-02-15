#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

#Include WinUI3.ahk
#Include winrt.ahk
#Include AppPackage.ahk
#Include DWM.ahk

; =============================================================================
; WinUI3 Typed Controls Demo
; =============================================================================
; Demonstrates the improved WinUI3 API with typed control wrappers,
; auto-resize XAML island, dark mode, and Mica backdrop.

if !WinUI3.Init("1.6") {
    MsgBox("WinUI3 runtime not available.`nThis demo requires Windows App SDK 1.6 and a desktop session.", "Requirements Not Met", "Icon!")
    ExitApp()
}

try {
    win := WinUI3.Window("WinUI3 Typed Controls", "w550 h500")
} catch as e {
    MsgBox("Could not create WinUI3 window:`n" e.Message "`n`nThis demo requires a full desktop session with Windows App SDK.", "WinUI3 Error", "Icon!")
    ExitApp()
}

win.LoadXaml("
(
<StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
            Margin='24' Spacing='14'>

    <TextBlock x:Name='Title' Text='WinUI3 Bridge Demo' FontSize='28'
               FontWeight='Bold' Margin='0,0,0,8'/>

    <TextBox x:Name='NameInput' PlaceholderText='Enter your name...'/>

    <StackPanel Orientation='Horizontal' Spacing='8'>
        <Button x:Name='GreetBtn' Content='Greet'/>
        <Button x:Name='ClearBtn' Content='Clear'/>
    </StackPanel>

    <TextBlock x:Name='Output' Text='...' Opacity='0.7' TextWrapping='1'/>

    <Slider x:Name='FontSlider' Minimum='12' Maximum='48' Value='14'
            StepFrequency='1'/>
    <TextBlock x:Name='FontLabel' Text='Font Size: 14' FontSize='12'
               Opacity='0.6'/>

    <CheckBox x:Name='BoldCheck' Content='Bold output text'/>

    <ToggleSwitch x:Name='DarkToggle' Header='Dark Mode' IsOn='True'
                  OnContent='Dark' OffContent='Light'/>

    <ProgressBar x:Name='Progress' Value='0' Maximum='100'
                 Minimum='0' Height='4'/>

</StackPanel>
)")

; --- Event Handlers ---

; Greet button: read TextBox, write to TextBlock
win["GreetBtn"].OnClick((*) => GreetUser())

GreetUser() {
    name := win["NameInput"].Text
    if name = ""
        name := "World"
    win["Output"].Text := "Hello, " name "!"
    win["Progress"].Value := Min(win["Progress"].Value + 10, 100)
}

; Clear button: reset everything
win["ClearBtn"].OnClick((*) => ResetDemo())

ResetDemo() {
    win["NameInput"].Text := ""
    win["Output"].Text := "..."
    win["Progress"].Value := 0
}

; Font slider: live update output font size
win["FontSlider"].OnValueChanged((*) => UpdateFontSize())

UpdateFontSize() {
    size := Round(win["FontSlider"].Value)
    win["Output"].SetProperty("FontSize", size)
    win["FontLabel"].Text := "Font Size: " size
}

; Bold checkbox
win["BoldCheck"].OnChecked((*) => win["Output"].SetProperty("FontWeight", "Bold"))
win["BoldCheck"].OnUnchecked((*) => win["Output"].SetProperty("FontWeight", "Normal"))

; Dark mode toggle
win["DarkToggle"].OnToggled((*) => ToggleDarkMode())

ToggleDarkMode() {
    isDark := win["DarkToggle"].IsOn
    DWM.SetDarkMode(win.Hwnd, isDark)
    win.Gui.BackColor := isDark ? "0x202020" : "0xF3F3F3"
}
