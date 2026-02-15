#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include Lib\BasicXamlGui.ahk

try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    MsgBox("Failed to load Windows App Runtime 1.6`n`n"
        . "Error: " e.Message, "HelloWorld WinUI3", "Icon!")
    ExitApp()
}

DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

xg := BasicXamlGui('+Resize', 'Hello WinUI3 - AHK v2')
ApplyThemeToXamlGui(xg)

xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
(
    <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
                Padding='32' Spacing='16' HorizontalAlignment='Center' VerticalAlignment='Center'>
        <TextBlock Text='Hello, WinUI3!' FontSize='32' FontWeight='Bold' HorizontalAlignment='Center'/>
        <TextBlock Text='Running in AHK v2 via XAML Islands' FontSize='14' Opacity='0.6' HorizontalAlignment='Center'/>
        <Button x:Name='ClickBtn' Content='Click Me' HorizontalAlignment='Center' Padding='24,8'/>
        <TextBlock x:Name='ResultText' Text='' FontSize='14' HorizontalAlignment='Center'/>
    </StackPanel>
)")
ApplyXamlTheme(xg)

clickCount := 0
xg['ClickBtn'].add_Click((btn, args) => (
    clickCount++,
    xg['ResultText'].Text := 'Clicked ' clickCount ' time' (clickCount > 1 ? 's' : '') '!'
))

xg.Show("w500 h350")
xg.NavigateFocus('First')
