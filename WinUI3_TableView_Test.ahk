#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include DotNet.ahk\DotNet.ahk
#Include Lib\BasicXamlGui.ahk
#Include Lib\CSharpBridge.ahk
#Include Lib\CSharp\TableViewHelper.ahk

try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    FileOpen("**", "w").Write("SDK FAIL: " e.Message "`n")
    ExitApp(1)
}

DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

try {
    model := TableViewHelper.CreateModel()
    model.AddColumn("Name", 160, "string", "Left")
    model.AddColumn("Department", 120, "string", "Left")
    model.AddColumn("Salary", 100, "number", "Right")
    model.AddRowFromValues("Alice Johnson|Engineering|$95,000", "|")
    model.AddRowFromValues("Bob Smith|Design|$88,000", "|")
    model.AddRowFromValues("Carol Chen|Engineering|$110,000", "|")
    FileOpen("**", "w").Write("Model OK: rows=" model.RowCount " cols=" model.ColumnCount "`n")
    FileOpen("**", "w").Write("Row0: " model.GetRowDisplay(0, " | ") "`n")
    FileOpen("**", "w").Write("Status: " model.GetStatus() "`n")
    model.Sort("Salary", "desc")
    FileOpen("**", "w").Write("Sorted: " model.GetRowDisplay(0, " | ") "`n")
    model.Filter("eng")
    FileOpen("**", "w").Write("Filtered: viewCount=" model.ViewCount "`n")
    model.ResetView()
} catch as e {
    FileOpen("**", "w").Write("MODEL FAIL: " e.Message "`n" e.Stack "`n")
    ExitApp(1)
}

isDark := DarkModeIsActive()

xg := BasicXamlGui('+Resize', 'TableView Model Test')
ApplyThemeToXamlGui(xg)

xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
(
    <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
                Margin='16' Spacing='12'>
        <TextBlock Text='TableView Model Test' FontSize='24' FontWeight='Bold'/>
        <StackPanel x:Name='HeaderPanel' Orientation='Horizontal'/>
        <StackPanel x:Name='RowContainer' Spacing='1'/>
        <TextBlock x:Name='StatusText' FontSize='12' Opacity='0.6' Margin='0,8,0,0'/>
    </StackPanel>
)")
ApplyXamlTheme(xg)

headerPanel := xg['HeaderPanel']
rowContainer := xg['RowContainer']
statusText := xg['StatusText']

Loop model.ColumnCount {
    idx := A_Index - 1
    colName := model.GetColumnName(idx)
    colWidth := model.GetColumnWidth(idx)
    btn := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(
        "<Button xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
        . " Content='" colName "' Width='" colWidth "' Height='32'"
        . " Background='Transparent' BorderThickness='0'/>"
    )
    headerPanel.Children.Append(btn)
}

Loop model.ViewCount {
    idx := A_Index - 1
    display := model.GetRowDisplay(idx, " | ")
    isAlt := Mod(idx, 2) = 1
    bg := isAlt ? "#252525" : "#1E1E1E"
    if !isDark
        bg := isAlt ? "#F8F8F8" : "#FFFFFF"
    rowBtn := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(
        "<Button xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
        . " HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'"
        . " Background='" bg "' BorderThickness='0' Height='34' CornerRadius='0' Padding='8,0'>"
        . "<TextBlock Text='" display "' FontSize='13' VerticalAlignment='Center'/>"
        . "</Button>"
    )
    rowContainer.Children.Append(rowBtn)
}

statusText.Text := model.GetStatus()
xg.Show("w500 h350")
xg.NavigateFocus('First')
