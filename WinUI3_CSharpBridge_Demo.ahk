#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include DotNet.ahk\DotNet.ahk
#Include Lib\BasicXamlGui.ahk
#Include Lib\CSharpBridge.ahk
#Include Lib\CSharp\ObservableHelpers.ahk
#Include Lib\CSharp\RelayCommand.ahk
#Include Lib\CSharp\DataGridHelper.ahk
#Include Lib\CSharp\TreeViewHelper.ahk

; Global error handler for WSL compatibility (output to stdout, not MsgBox)
OnError((e, mode) => (FileOpen("**", "w").Write("ERROR [" mode "]: " e.Message "`n" (HasProp(e, "Stack") ? e.Stack : "") "`n"), -1))

try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    FileOpen("**", "w").Write("SDK FAIL: " e.Message "`n")
    ExitApp()
}

DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

CSharpBridgeDemo()

CSharpBridgeDemo() {
    xg := BasicXamlGui('+Resize', 'WinUI3 C# Bridge Demo')
    ApplyThemeToXamlGui(xg)

    ; XamlControlsResources requires a full Application host with IXamlMetadataProvider.
    ; When running as XAML Islands (without packaged app), this may fail.
    try {
        app := WinRT('Microsoft.UI.Xaml.Application').Current
        res := WinRT('Microsoft.UI.Xaml.Controls.XamlControlsResources')()
        app.Resources.MergedDictionaries.Append(res)
    }

    xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <NavigationView xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
                        Name='NavView'
                        IsBackButtonVisible='Collapsed'
                        PaneDisplayMode='Left'>

            <NavigationView.MenuItems>
                <NavigationViewItem Content='WinUI3 Controls' Tag='controls'>
                    <NavigationViewItem.Icon>
                        <SymbolIcon Symbol='Repair'/>
                    </NavigationViewItem.Icon>
                </NavigationViewItem>
                <NavigationViewItem Content='Data Binding' Tag='binding'>
                    <NavigationViewItem.Icon>
                        <SymbolIcon Symbol='List'/>
                    </NavigationViewItem.Icon>
                </NavigationViewItem>
                <NavigationViewItem Content='DataGrid' Tag='datagrid'>
                    <NavigationViewItem.Icon>
                        <SymbolIcon Symbol='ViewAll'/>
                    </NavigationViewItem.Icon>
                </NavigationViewItem>
                <NavigationViewItem Content='Commands' Tag='commands'>
                    <NavigationViewItem.Icon>
                        <SymbolIcon Symbol='Play'/>
                    </NavigationViewItem.Icon>
                </NavigationViewItem>
                <NavigationViewItem Content='TreeView' Tag='treeview'>
                    <NavigationViewItem.Icon>
                        <SymbolIcon Symbol='AllApps'/>
                    </NavigationViewItem.Icon>
                </NavigationViewItem>
            </NavigationView.MenuItems>

            <NavigationView.FooterMenuItems>
                <NavigationViewItem Content='About' Tag='about'>
                    <NavigationViewItem.Icon>
                        <SymbolIcon Symbol='Help'/>
                    </NavigationViewItem.Icon>
                </NavigationViewItem>
            </NavigationView.FooterMenuItems>

            <Frame Name='ContentFrame'/>
        </NavigationView>
    )")

    pages := Map()
    pages["controls"] := BuildControlsPage
    pages["binding"] := BuildBindingPage
    pages["datagrid"] := BuildDataGridPage
    pages["commands"] := BuildCommandsPage
    pages["treeview"] := BuildTreeViewPage
    pages["about"] := BuildAboutPage

    contentFrame := xg['ContentFrame']

    xg['NavView'].add_SelectionChanged((nav, args) => (
        item := args.SelectedItem,
        (item != "") ? (
            tag := item.Tag,
            pages.Has(tag) ? (
                page := pages[tag],
                contentFrame.Content := page()
            ) : 0
        ) : 0
    ))

    menuItems := xg['NavView'].MenuItems
    xg['NavView'].SelectedItem := menuItems.GetAt(0)

    xg.Show("w900 h650")
    xg.NavigateFocus('First')
}

BuildControlsPage() {
    page := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <ScrollViewer xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                      xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'>
        <StackPanel Margin='24' Spacing='20'>

            <TextBlock Text='WinUI 3 Exclusive Controls' FontSize='28' FontWeight='Bold'/>
            <TextBlock Text='Controls unavailable in standard AHK v2 Gui — only possible through WinUI3 XAML islands.'
                       Opacity='0.7' TextWrapping='Wrap'/>

            <!-- InfoBar -->
            <TextBlock Text='InfoBar' FontSize='20' FontWeight='SemiBold' Margin='0,8,0,0'/>
            <InfoBar Name='InfoSuccess' Title='Success' Message='Operation completed successfully.' Severity='Success' IsOpen='True' IsClosable='False'/>
            <InfoBar Name='InfoWarning' Title='Warning' Message='Disk space running low.' Severity='Warning' IsOpen='True' IsClosable='True'/>
            <InfoBar Name='InfoError' Title='Error' Message='Connection lost. Retrying...' Severity='Error' IsOpen='True' IsClosable='True'/>
            <StackPanel Orientation='Horizontal' Spacing='8'>
                <Button Name='ToggleInfoBtn' Content='Toggle Severity'/>
                <TextBlock Name='InfoStatus' VerticalAlignment='Center' FontSize='13' Opacity='0.6'/>
            </StackPanel>

            <!-- NumberBox -->
            <TextBlock Text='NumberBox' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <StackPanel Orientation='Horizontal' Spacing='16'>
                <NumberBox Name='NumBoxA' Header='Value A' Value='25' Minimum='0' Maximum='100'
                           SmallChange='1' LargeChange='10' SpinButtonPlacementMode='Inline' Width='180'/>
                <NumberBox Name='NumBoxB' Header='Value B' Value='17' Minimum='0' Maximum='100'
                           SmallChange='1' LargeChange='10' SpinButtonPlacementMode='Inline' Width='180'/>
                <StackPanel VerticalAlignment='Bottom'>
                    <TextBlock Name='NumBoxResult' FontSize='16' FontWeight='SemiBold'/>
                </StackPanel>
            </StackPanel>

            <!-- RatingControl -->
            <TextBlock Text='RatingControl' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <StackPanel Spacing='8'>
                <StackPanel Orientation='Horizontal' Spacing='16'>
                    <RatingControl Name='RatingInteractive' Value='3' MaxRating='5' IsClearEnabled='True' Caption='Rate this demo'/>
                    <TextBlock Name='RatingText' VerticalAlignment='Center' FontSize='14'/>
                </StackPanel>
                <RatingControl Name='RatingReadonly' Value='4.5' MaxRating='5' IsReadOnly='True'/>
                <TextBlock Text='Read-only rating (4.5/5)' FontSize='12' Opacity='0.5'/>
            </StackPanel>

            <!-- ProgressRing -->
            <TextBlock Text='ProgressRing' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <StackPanel Orientation='Horizontal' Spacing='24'>
                <StackPanel HorizontalAlignment='Center' Spacing='4'>
                    <ProgressRing Name='RingIndeterminate' IsActive='True' Width='40' Height='40'/>
                    <TextBlock Text='Indeterminate' FontSize='12' Opacity='0.6' HorizontalAlignment='Center'/>
                </StackPanel>
                <StackPanel HorizontalAlignment='Center' Spacing='4'>
                    <ProgressRing Name='RingDeterminate' IsIndeterminate='False' Value='65' Width='40' Height='40'/>
                    <TextBlock Name='RingValueText' Text='65%%' FontSize='12' Opacity='0.6' HorizontalAlignment='Center'/>
                </StackPanel>
                <Slider Name='RingSlider' Minimum='0' Maximum='100' Value='65' Width='200' VerticalAlignment='Center'/>
            </StackPanel>

            <!-- ColorPicker -->
            <TextBlock Text='ColorPicker' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <StackPanel Orientation='Horizontal' Spacing='16'>
                <ColorPicker Name='ColorPick' IsAlphaEnabled='False' IsHexInputVisible='True'
                             IsMoreButtonVisible='True' IsColorSliderVisible='True'/>
                <StackPanel Spacing='8' VerticalAlignment='Top'>
                    <Border Name='ColorPreview' Width='80' Height='80' CornerRadius='8'/>
                    <TextBlock Name='ColorHex' FontSize='14' FontFamily='Consolas'/>
                    <TextBlock Name='ColorRgb' FontSize='12' Opacity='0.6'/>
                </StackPanel>
            </StackPanel>

            <!-- Expander -->
            <TextBlock Text='Expander' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <Expander Header='System Information' IsExpanded='True' HorizontalAlignment='Stretch' HorizontalContentAlignment='Stretch'>
                <StackPanel Spacing='6' Margin='4'>
                    <TextBlock Name='ExpanderAhk' FontSize='13'/>
                    <TextBlock Name='ExpanderOS' FontSize='13'/>
                    <TextBlock Name='ExpanderScreen' FontSize='13'/>
                    <TextBlock Name='ExpanderDPI' FontSize='13'/>
                </StackPanel>
            </Expander>
            <Expander Header='Advanced Settings' IsExpanded='False' HorizontalAlignment='Stretch' HorizontalContentAlignment='Stretch'>
                <StackPanel Spacing='8' Margin='4'>
                    <ToggleSwitch Name='ToggleDarkMode' Header='Force Dark Mode' IsOn='False'/>
                    <ToggleSwitch Name='ToggleAnimations' Header='Enable Animations' IsOn='True'/>
                    <ToggleSwitch Name='ToggleNotifications' Header='Show Notifications' IsOn='True'/>
                    <TextBlock Name='ToggleStatus' FontSize='12' Opacity='0.6'/>
                </StackPanel>
            </Expander>

            <!-- CalendarDatePicker -->
            <TextBlock Text='CalendarDatePicker' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <StackPanel Orientation='Horizontal' Spacing='16'>
                <CalendarDatePicker Name='CalPicker' PlaceholderText='Select a date...' IsTodayHighlighted='True'/>
                <TextBlock Name='CalResult' VerticalAlignment='Center' FontSize='14'/>
            </StackPanel>

            <!-- BreadcrumbBar -->
            <TextBlock Text='BreadcrumbBar' FontSize='20' FontWeight='SemiBold' Margin='0,12,0,0'/>
            <BreadcrumbBar Name='Breadcrumb'/>
            <TextBlock Name='BreadcrumbResult' FontSize='13' Opacity='0.6'/>

        </StackPanel>
        </ScrollViewer>
    )")

    sevIdx := 0
    severities := ["Success", "Warning", "Error", "Informational"]
    page.FindName('InfoStatus').Text := 'Current: Success'

    page.FindName('ToggleInfoBtn').add_Click((btn, args) => (
        sevIdx := Mod(sevIdx + 1, 4),
        page.FindName('InfoSuccess').Severity := severities[sevIdx + 1],
        page.FindName('InfoSuccess').Title := severities[sevIdx + 1],
        page.FindName('InfoStatus').Text := 'Current: ' severities[sevIdx + 1]
    ))

    updateSum := () => (
        page.FindName('NumBoxResult').Text := 'Sum: ' (page.FindName('NumBoxA').Value + page.FindName('NumBoxB').Value)
    )
    updateSum()
    page.FindName('NumBoxA').add_ValueChanged((s, a) => updateSum())
    page.FindName('NumBoxB').add_ValueChanged((s, a) => updateSum())

    page.FindName('RatingText').Text := 'Rating: 3/5'
    page.FindName('RatingInteractive').add_ValueChanged((s, a) => (
        page.FindName('RatingText').Text := 'Rating: ' s.Value '/5'
    ))

    page.FindName('RingSlider').add_ValueChanged((s, a) => (
        page.FindName('RingDeterminate').Value := s.Value,
        page.FindName('RingValueText').Text := Round(s.Value) '%'
    ))

    page.FindName('ColorPick').add_ColorChanged((s, a) => (
        clr := s.Color,
        page.FindName('ColorHex').Text := Format('#{:02X}{:02X}{:02X}', clr.R, clr.G, clr.B),
        page.FindName('ColorRgb').Text := Format('rgb({}, {}, {})', clr.R, clr.G, clr.B)
    ))

    page.FindName('ExpanderAhk').Text := 'AutoHotkey: ' A_AhkVersion
    page.FindName('ExpanderOS').Text := 'OS: Windows ' A_OSVersion
    page.FindName('ExpanderScreen').Text := 'Screen: ' A_ScreenWidth 'x' A_ScreenHeight
    page.FindName('ExpanderDPI').Text := 'DPI: ' A_ScreenDPI

    updateToggles := () => (
        page.FindName('ToggleStatus').Text := 'Dark: '
            . (page.FindName('ToggleDarkMode').IsOn ? 'ON' : 'OFF')
            . ' | Animations: '
            . (page.FindName('ToggleAnimations').IsOn ? 'ON' : 'OFF')
            . ' | Notifications: '
            . (page.FindName('ToggleNotifications').IsOn ? 'ON' : 'OFF')
    )
    updateToggles()
    page.FindName('ToggleDarkMode').add_Toggled((s, a) => updateToggles())
    page.FindName('ToggleAnimations').add_Toggled((s, a) => updateToggles())
    page.FindName('ToggleNotifications').add_Toggled((s, a) => updateToggles())

    page.FindName('CalPicker').add_DateChanged((s, a) => (
        page.FindName('CalResult').Text := 'Selected: ' (s.Date != '' ? String(s.Date) : 'none')
    ))

    page.FindName('BreadcrumbResult').Text := 'Home > Documents > Projects > WinUI3'
    try {
        bc := page.FindName('Breadcrumb')
        bc.add_ItemClicked((s, a) => (
            page.FindName('BreadcrumbResult').Text := 'Clicked: ' a.Item
        ))
    }

    return page
}

BuildBindingPage() {
    page := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    Margin='24' Spacing='12'>
            <TextBlock Text='Observable Data Binding' FontSize='28' FontWeight='Bold'/>
            <TextBlock Text='Items are backed by ObservableCollection - the ListView updates automatically.'
                       Opacity='0.7' TextWrapping='Wrap'/>

            <StackPanel Orientation='Horizontal' Spacing='8' Margin='0,8,0,0'>
                <TextBox Name='BindingInput' PlaceholderText='New item name...' Width='250'/>
                <Button Name='BindingAdd' Content='Add'/>
                <Button Name='BindingRemove' Content='Remove Selected'/>
                <Button Name='BindingClear' Content='Clear All'/>
            </StackPanel>

            <TextBlock Name='BindingCount' FontSize='13' Opacity='0.6'/>

            <ListView Name='BindingList' Height='350' SelectionMode='Single'/>
        </StackPanel>
    )")

    list := ObservableHelpers.CreateList()
    Loop 3 {
        list.Add(ObservableHelpers.CreateItemWith("Display", "Sample Item " A_Index))
    }

    page.FindName('BindingList').ItemsSource := list
    page.FindName('BindingCount').Text := 'Count: ' list.Count

    updateCount := () => page.FindName('BindingCount').Text := 'Count: ' list.Count

    page.FindName('BindingAdd').add_Click((btn, args) => (
        name := page.FindName('BindingInput').Text,
        (name != '') ? (
            list.Add(ObservableHelpers.CreateItemWith("Display", name)),
            page.FindName('BindingInput').Text := '',
            updateCount()
        ) : 0
    ))

    page.FindName('BindingRemove').add_Click((btn, args) => (
        idx := page.FindName('BindingList').SelectedIndex,
        (idx >= 0) ? (list.RemoveAt(idx), updateCount()) : 0
    ))

    page.FindName('BindingClear').add_Click((btn, args) => (
        list.Clear(),
        updateCount()
    ))

    return page
}

BuildDataGridPage() {
    page := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    Margin='24' Spacing='12'>
            <TextBlock Text='DataGrid Model' FontSize='28' FontWeight='Bold'/>
            <TextBlock Text='Sortable, filterable data model with ObservableCollection backing.'
                       Opacity='0.7' TextWrapping='Wrap'/>

            <StackPanel Orientation='Horizontal' Spacing='8' Margin='0,8,0,0'>
                <TextBox Name='FilterInput' PlaceholderText='Filter by name...' Width='200'/>
                <Button Name='FilterBtn' Content='Filter'/>
                <Button Name='ResetBtn' Content='Reset'/>
                <Button Name='SortAscBtn' Content='Sort A-Z'/>
                <Button Name='SortDescBtn' Content='Sort Z-A'/>
                <Button Name='AddRowBtn' Content='Add Row'/>
            </StackPanel>

            <TextBlock Name='GridInfo' FontSize='13' Opacity='0.6'/>

            <ListView Name='GridList' Height='350' SelectionMode='Single'/>
        </StackPanel>
    )")

    model := DataGridHelper.CreateModel()
    model.AddColumn("Name", "string")
    model.AddColumn("Role", "string")
    model.AddColumn("Score", "int")

    sampleData := [
        ["Alice", "Engineer", 95],
        ["Bob", "Designer", 87],
        ["Carol", "Manager", 92],
        ["Dave", "Analyst", 78],
        ["Eve", "Engineer", 91]
    ]

    for data in sampleData {
        row := model.AddRow()
        row.Set("Name", data[1]).Set("Role", data[2]).Set("Score", data[3])
    }

    gridList := page.FindName('GridList')
    gridList.ItemsSource := model.Rows

    updateInfo := () => page.FindName('GridInfo').Text := 'Rows: ' model.RowCount

    updateInfo()
    rowCounter := 5

    page.FindName('FilterBtn').add_Click((btn, args) => (
        val := page.FindName('FilterInput').Text,
        (val != '') ? (
            filtered := model.Filter("Name", val),
            gridList.ItemsSource := filtered,
            page.FindName('GridInfo').Text := 'Filtered: ' filtered.Count ' rows'
        ) : 0
    ))

    page.FindName('ResetBtn').add_Click((btn, args) => (
        gridList.ItemsSource := model.Rows,
        page.FindName('FilterInput').Text := '',
        updateInfo()
    ))

    page.FindName('SortAscBtn').add_Click((btn, args) => (
        model.Sort("Name", true),
        updateInfo()
    ))

    page.FindName('SortDescBtn').add_Click((btn, args) => (
        model.Sort("Name", false),
        updateInfo()
    ))

    page.FindName('AddRowBtn').add_Click((btn, args) => (
        rowCounter++,
        model.AddRow().Set("Name", "New " rowCounter).Set("Role", "Added").Set("Score", Random(60, 100)),
        updateInfo()
    ))

    return page
}

BuildCommandsPage() {
    page := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    Margin='24' Spacing='12'>
            <TextBlock Text='ICommand Pattern' FontSize='28' FontWeight='Bold'/>
            <TextBlock Text='RelayCommand bridges ICommand to AHK callbacks for XAML command binding.'
                       Opacity='0.7' TextWrapping='Wrap'/>

            <StackPanel Spacing='8' Margin='0,16,0,0'>
                <Button Name='CmdGreet' Content='Greet (RelayCommand)' Width='200'/>
                <Button Name='CmdCount' Content='Count Clicks' Width='200'/>
                <Button Name='CmdToggle' Content='Toggle State' Width='200'/>
            </StackPanel>

            <TextBlock Name='CmdOutput' FontSize='16' Margin='0,16,0,0' TextWrapping='Wrap'/>
            <TextBlock Name='CmdState' FontSize='14' Opacity='0.6'/>
        </StackPanel>
    )")

    clickCount := 0
    toggled := false

    greetCmd := RelayCommandHelper.Create({Call: (param) => (
        page.FindName('CmdOutput').Text := 'Hello from RelayCommand! Parameter: ' (param ?? 'none')
    )})

    countCmd := RelayCommandHelper.Create({Call: (param) => (
        clickCount++,
        page.FindName('CmdOutput').Text := 'Click count: ' clickCount
    )})

    toggleCmd := RelayCommandHelper.Create({Call: (param) => (
        toggled := !toggled,
        page.FindName('CmdState').Text := 'State: ' (toggled ? 'ON' : 'OFF'),
        page.FindName('CmdOutput').Text := 'Toggled to ' (toggled ? 'ON' : 'OFF')
    )})

    page.FindName('CmdGreet').add_Click((btn, args) => greetCmd.Execute("AHK"))
    page.FindName('CmdCount').add_Click((btn, args) => countCmd.Execute(""))
    page.FindName('CmdToggle').add_Click((btn, args) => toggleCmd.Execute(""))

    page.FindName('CmdOutput').Text := 'Click a button to test commands...'
    page.FindName('CmdState').Text := 'State: OFF'

    return page
}

BuildTreeViewPage() {
    page := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    Margin='24' Spacing='12'>
            <TextBlock Text='TreeView Builder' FontSize='28' FontWeight='Bold'/>
            <TextBlock Text='Hierarchical TreeView built from C# with node management.'
                       Opacity='0.7' TextWrapping='Wrap'/>

            <StackPanel Orientation='Horizontal' Spacing='8' Margin='0,8,0,0'>
                <Button Name='TreeExpandAll' Content='Expand All'/>
                <Button Name='TreeCollapseAll' Content='Collapse All'/>
                <Button Name='TreeAddNode' Content='Add Node'/>
            </StackPanel>

            <Border Name='TreeContainer' Height='400'
                    BorderBrush='{ThemeResource CardStrokeColorDefaultBrush}'
                    BorderThickness='1' CornerRadius='4' Padding='8'/>
        </StackPanel>
    )")

    builder := TreeViewHelper.Create()

    docs := builder.AddRootNode("Documents")
    builder.AddChildNode(docs, "Resume.pdf")
    builder.AddChildNode(docs, "CoverLetter.docx")

    projects := builder.AddChildNode(docs, "Projects")
    builder.AddChildNode(projects, "WinUI3Demo.ahk")
    builder.AddChildNode(projects, "CSharpBridge.ahk")

    photos := builder.AddRootNode("Photos")
    builder.AddChildNode(photos, "Vacation.jpg")
    builder.AddChildNode(photos, "Family.png")

    music := builder.AddRootNode("Music")
    rock := builder.AddChildNode(music, "Rock")
    builder.AddChildNode(rock, "track01.mp3")
    builder.AddChildNode(rock, "track02.mp3")
    jazz := builder.AddChildNode(music, "Jazz")
    builder.AddChildNode(jazz, "smooth.mp3")

    page.FindName('TreeContainer').Child := builder.Control

    nodeCounter := 0
    page.FindName('TreeExpandAll').add_Click((btn, args) => builder.ExpandAll())
    page.FindName('TreeCollapseAll').add_Click((btn, args) => builder.CollapseAll())
    page.FindName('TreeAddNode').add_Click((btn, args) => (
        nodeCounter++,
        builder.AddRootNode("New Folder " nodeCounter)
    ))

    return page
}

BuildAboutPage() {
    page := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load("
    (
        <StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
                    Margin='24' Spacing='16'>
            <TextBlock Text='About' FontSize='28' FontWeight='Bold'/>

            <StackPanel Spacing='8'>
                <TextBlock Name='AboutAhk' FontSize='14'/>
                <TextBlock Name='AboutDotNet' FontSize='14'/>
                <TextBlock Name='AboutBridge' FontSize='14'/>
                <TextBlock Name='AboutWinUI' FontSize='14'/>
            </StackPanel>

            <TextBlock Text='Architecture' FontSize='20' FontWeight='SemiBold' Margin='0,16,0,0'/>

            <TextBlock TextWrapping='Wrap' Opacity='0.8' FontSize='13'
                       Text='AHK (winrt.ahk) hosts WinUI3 XAML islands. C# helpers compiled at runtime via DotNet.ahk + Roslyn provide managed types (INotifyPropertyChanged, ObservableCollection, ICommand) that bridge to AHK through IDispatch COM wrappers.'/>

            <TextBlock Text='Components' FontSize='20' FontWeight='SemiBold' Margin='0,8,0,0'/>

            <StackPanel Spacing='4'>
                <TextBlock FontSize='13' Opacity='0.8'
                           Text='BasicXamlGui - XAML island wrapper extending Gui'/>
                <TextBlock FontSize='13' Opacity='0.8'
                           Text='CSharpBridge - Runtime C# compilation with WinUI3 refs'/>
                <TextBlock FontSize='13' Opacity='0.8'
                           Text='ObservableHelpers - INotifyPropertyChanged + ObservableCollection'/>
                <TextBlock FontSize='13' Opacity='0.8'
                           Text='RelayCommand - ICommand bridging to AHK callbacks'/>
                <TextBlock FontSize='13' Opacity='0.8'
                           Text='DataGridHelper - Sortable/filterable data model'/>
                <TextBlock FontSize='13' Opacity='0.8'
                           Text='TreeViewHelper - Hierarchical TreeView builder'/>
            </StackPanel>
        </StackPanel>
    )")

    page.FindName('AboutAhk').Text := 'AutoHotkey: ' A_AhkVersion
    page.FindName('AboutBridge').Text := 'WinUI DLL: ' CSharpBridge.WinUIDll

    try {
        infoCode := "
        (
        using System;
        public class RuntimeInfo {
            public string GetVersion() { return Environment.Version.ToString(); }
        }
        )"
        infoObj := CSharpBridge.CreateInstance(infoCode, "RuntimeInfo", "RuntimeInfo")
        page.FindName('AboutDotNet').Text := '.NET Runtime: ' infoObj.GetVersion()
    } catch as e {
        page.FindName('AboutDotNet').Text := '.NET Runtime: ' e.Message
    }

    page.FindName('AboutWinUI').Text := 'SDK: Windows App Runtime 1.6'

    return page
}
