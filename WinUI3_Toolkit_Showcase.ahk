#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include Lib\BasicXamlGui.ahk

try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    FileOpen("**", "w").Write("SDK FAIL: " e.Message "`n")
    ExitApp(1)
}

DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

global app := ToolkitShowcase()

class ToolkitShowcase {
    __New() {
        this.isDark := DarkModeIsActive()
        this.InitColors()
        this.activePage := "RangeSelector"
        this.activeTab := "Home"
        this.selectedContact := 0
        this.rangeMin := 25
        this.rangeMax := 75
        this._rangeUpdating := false
        this.BuildGui()
    }

    InitColors() {
        this.c := Map()
        c := this.c
        if this.isDark {
            c["bg"] := "#1E1E1E", c["card"] := "#2D2D2D", c["fg"] := "#E0E0E0"
            c["dim"] := "#999999", c["accent"] := "#4CC2FF", c["accentBg"] := "#1A3A5C"
            c["border"] := "#404040", c["tagBg"] := "#3A3A3A", c["tagFg"] := "#4CC2FF"
            c["canvasBg"] := "#252525", c["selected"] := "#1A3A5C", c["toolbar"] := "#2A2A2A"
            c["gaugeTrack"] := "#333333", c["gaugeGreen"] := "#2DB84D"
            c["gaugeYellow"] := "#E8A317", c["gaugeRed"] := "#E84040"
            c["navBg"] := "#252525", c["navHover"] := "#333333"
        } else {
            c["bg"] := "#FFFFFF", c["card"] := "#F5F5F5", c["fg"] := "#1A1A1A"
            c["dim"] := "#666666", c["accent"] := "#0078D4", c["accentBg"] := "#CCE4F7"
            c["border"] := "#D0D0D0", c["tagBg"] := "#E0E8F0", c["tagFg"] := "#0078D4"
            c["canvasBg"] := "#F0F0F0", c["selected"] := "#CCE4F7", c["toolbar"] := "#F0F0F0"
            c["gaugeTrack"] := "#E0E0E0", c["gaugeGreen"] := "#107C10"
            c["gaugeYellow"] := "#CA5010", c["gaugeRed"] := "#D13438"
            c["navBg"] := "#F0F0F0", c["navHover"] := "#E0E0E0"
        }
    }

    BuildGui() {
        this.xg := BasicXamlGui('+Resize', 'Community Toolkit Showcase - AHK v2')
        ApplyThemeToXamlGui(this.xg)
        xaml := this.BuildMainXaml()
        try {
            this.xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
        } catch as err {
            FileOpen("**", "w").Write("XAML ERROR: " err.Message "`n")
            throw err
        }
        ApplyXamlTheme(this.xg)
        this.WireNavigation()
        this.WireRangeSelector()
        this.WireRadialGauge()
        this.WireTabbedCommandBar()
        this.WireMasterDetail()
        this.WireSettingsCard()
        this.WireSegmented()
        this.WireColorPicker()
        this.xg.Show("w950 h700")
        this.xg.NavigateFocus('First')
    }

    BuildMainXaml() {
        c := this.c
        return this.R("
        (
        <Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
              xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
              ColumnDefinitions='220,*'>

            <Border Grid.Column='0' Background='{{NAV_BG}}' BorderBrush='{{BORDER}}'
                    BorderThickness='0,0,1,0'>
                <StackPanel>
                    <TextBlock Text='Toolkit Showcase' FontSize='16' FontWeight='Bold'
                               Margin='16,20,16,4'/>
                    <TextBlock Text='WinUI3 XAML Islands' FontSize='11'
                               Foreground='{{DIM}}' Margin='16,0,16,16'/>
                    <Border Height='1' Background='{{BORDER}}' Margin='12,0'/>
                    <StackPanel Margin='8,8' Spacing='2'>
                        <Button x:Name='NavRangeSelector' Content='RangeSelector'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='{{ACCENT_BG}}' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Button x:Name='NavRadialGauge' Content='RadialGauge'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Button x:Name='NavTabbedCommandBar' Content='TabbedCommandBar'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Button x:Name='NavListDetailsView' Content='ListDetailsView'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Button x:Name='NavMarkdownTextBlock' Content='MarkdownTextBlock'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Border Height='1' Background='{{BORDER}}' Margin='4,6'/>
                        <Button x:Name='NavSettingsCard' Content='SettingsCard'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Button x:Name='NavSegmented' Content='Segmented'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                        <Button x:Name='NavColorPicker' Content='ColorPickerButton'
                                HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'
                                Background='Transparent' Height='36' Padding='12,0'
                                CornerRadius='6' BorderThickness='0'/>
                    </StackPanel>
                </StackPanel>
            </Border>

            <ScrollViewer Grid.Column='1' VerticalScrollBarVisibility='Auto'>
                <StackPanel Padding='28,24' Spacing='16' MaxWidth='700'>

                    <StackPanel x:Name='PageRangeSelector' Spacing='12'>
                        <TextBlock Text='RangeSelector' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='A double slider to select a sub-range. Drag either thumb independently.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='20'>
                            <StackPanel Spacing='12'>
                                <Grid Height='48'>
                                    <StackPanel x:Name='RangeTrackContainer' VerticalAlignment='Center'/>
                                    <Slider x:Name='RangeGhost' Minimum='0' Maximum='100'
                                            Value='25' StepFrequency='1' Opacity='0.02'/>
                                </Grid>
                                <TextBlock x:Name='RangeDisplay'
                                           Text='Range: 25 - 75 | Span: 50'
                                           Foreground='{{DIM}}' FontSize='12' HorizontalAlignment='Center'/>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                    <StackPanel x:Name='PageRadialGauge' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='RadialGauge' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='Circular gauge with color-coded value indicator and threshold zones.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='20'>
                            <StackPanel Spacing='12' HorizontalAlignment='Center'>
                                <Grid HorizontalAlignment='Center'>
                                    <Border x:Name='GaugeOuter' Width='180' Height='180' CornerRadius='90'
                                            Background='{{GAUGE_TRACK}}' HorizontalAlignment='Center'>
                                        <Border x:Name='GaugeInner' Width='140' Height='140' CornerRadius='70'
                                                Background='{{CARD}}' HorizontalAlignment='Center'
                                                VerticalAlignment='Center'>
                                            <StackPanel VerticalAlignment='Center' HorizontalAlignment='Center'
                                                        Margin='8'>
                                                <TextBlock x:Name='GaugeValue' Text='65'
                                                           HorizontalAlignment='Center'
                                                           FontSize='28' FontWeight='Bold'
                                                           Foreground='{{GAUGE_GREEN}}'/>
                                                <TextBlock x:Name='GaugeLabel' Text='Good'
                                                           HorizontalAlignment='Center'
                                                           FontSize='12' Foreground='{{DIM}}'/>
                                            </StackPanel>
                                        </Border>
                                    </Border>
                                </Grid>
                                <Grid Width='320' HorizontalAlignment='Center'>
                                    <Border Background='{{GAUGE_TRACK}}' Height='8' CornerRadius='4'/>
                                    <Border x:Name='GaugeBar' Background='{{GAUGE_GREEN}}'
                                            Height='8' CornerRadius='4'
                                            HorizontalAlignment='Left' Width='208'/>
                                </Grid>
                                <Slider x:Name='GaugeSlider' Minimum='0' Maximum='100' Value='65'
                                        StepFrequency='1' Width='320'/>
                                <StackPanel Orientation='Horizontal' Spacing='8' HorizontalAlignment='Center'>
                                    <Button x:Name='Gauge0' Content='0' Height='30' MinWidth='46' Padding='10,0'/>
                                    <Button x:Name='Gauge25' Content='25' Height='30' MinWidth='46' Padding='10,0'/>
                                    <Button x:Name='Gauge50' Content='50' Height='30' MinWidth='46' Padding='10,0'/>
                                    <Button x:Name='Gauge75' Content='75' Height='30' MinWidth='46' Padding='10,0'/>
                                    <Button x:Name='Gauge100' Content='100' Height='30' MinWidth='46' Padding='10,0'/>
                                </StackPanel>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                    <StackPanel x:Name='PageTabbedCommandBar' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='TabbedCommandBar' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='CommandBar organized in switchable tabs (Home / Insert / View).'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='0'
                                BorderBrush='{{BORDER}}' BorderThickness='1'>
                            <StackPanel>
                                <Border Background='{{TOOLBAR}}' Padding='6' CornerRadius='8,8,0,0'>
                                    <StackPanel Orientation='Horizontal' Spacing='4'>
                                        <Button x:Name='TabHome' Content='Home' Height='30' MinWidth='70'
                                                Background='{{ACCENT_BG}}' FontWeight='SemiBold' FontSize='12'
                                                CornerRadius='6'/>
                                        <Button x:Name='TabInsert' Content='Insert' Height='30' MinWidth='70'
                                                Background='Transparent' FontSize='12' CornerRadius='6'/>
                                        <Button x:Name='TabView' Content='View' Height='30' MinWidth='70'
                                                Background='Transparent' FontSize='12' CornerRadius='6'/>
                                    </StackPanel>
                                </Border>
                                <Border Padding='12,8' MinHeight='50'>
                                    <StackPanel x:Name='TabContent' Orientation='Horizontal' Spacing='6'/>
                                </Border>
                                <TextBlock x:Name='TabStatus' Text='Home tab active'
                                           Foreground='{{ACCENT}}' FontSize='12' Margin='12,0,12,8'/>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                    <StackPanel x:Name='PageListDetailsView' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='ListDetailsView' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='Master list with detail pane. Click a contact to see details.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='0'
                                BorderBrush='{{BORDER}}' BorderThickness='1' Height='320'>
                            <Grid ColumnDefinitions='220,*'>
                                <Border Grid.Column='0' BorderBrush='{{BORDER}}' BorderThickness='0,0,1,0'>
                                    <ScrollViewer VerticalScrollBarVisibility='Auto'>
                                        <StackPanel x:Name='MasterList' Spacing='0'/>
                                    </ScrollViewer>
                                </Border>
                                <ScrollViewer Grid.Column='1'>
                                    <StackPanel x:Name='DetailPanel' Padding='20' Spacing='8'>
                                        <TextBlock Text='Select a contact' FontSize='16'
                                                   Foreground='{{DIM}}' HorizontalAlignment='Center'
                                                   Margin='0,80,0,0'/>
                                    </StackPanel>
                                </ScrollViewer>
                            </Grid>
                        </Border>
                    </StackPanel>

                    <StackPanel x:Name='PageMarkdownTextBlock' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='MarkdownTextBlock' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='Renders markdown-style content as styled XAML text blocks.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='20'>
                            <StackPanel Spacing='6'>
                                <TextBlock Text='Getting Started' FontSize='22' FontWeight='Bold'/>
                                <Border Background='{{BORDER}}' Height='1' Margin='0,0,0,4'/>
                                <TextBlock Text='Welcome to the AHK v2 WinUI3 toolkit showcase.' FontSize='14' TextWrapping='Wrap'/>
                                <TextBlock Text='Features' FontSize='18' FontWeight='SemiBold' Margin='0,8,0,0'/>
                                <TextBlock Text='- XAML Islands - Native WinUI3 controls in AHK' FontSize='13' Foreground='{{DIM}}'/>
                                <TextBlock Text='- C# Bridge - Compile and call C# from AHK' FontSize='13' Foreground='{{DIM}}'/>
                                <TextBlock Text='- Dark Mode - Auto-detected system theme' FontSize='13' Foreground='{{DIM}}'/>
                                <TextBlock Text='- ComboBox IsEditable - Text input for XAML Islands' FontSize='13' Foreground='{{DIM}}'/>
                                <TextBlock Text='Code Example' FontSize='18' FontWeight='SemiBold' Margin='0,8,0,0'/>
                                <Border Background='{{CANVAS_BG}}' CornerRadius='4' Padding='12'>
                                    <StackPanel Spacing='2'>
                                        <TextBlock Text='xg := BasicXamlGui(&quot;+Resize&quot;, &quot;Title&quot;)' FontFamily='Consolas' FontSize='12' Foreground='{{ACCENT}}'/>
                                        <TextBlock Text='xg.Content := XamlReader.Load(xaml)' FontFamily='Consolas' FontSize='12' Foreground='{{ACCENT}}'/>
                                        <TextBlock Text='xg.Show(&quot;w800 h600&quot;)' FontFamily='Consolas' FontSize='12' Foreground='{{ACCENT}}'/>
                                    </StackPanel>
                                </Border>
                                <Border Background='{{ACCENT_BG}}' CornerRadius='4' Padding='10' Margin='0,4,0,0'>
                                    <TextBlock Text='Tip: Use ComboBox IsEditable as a TextBox replacement in XAML Islands.'
                                               FontSize='12' TextWrapping='Wrap'/>
                                </Border>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                    <StackPanel x:Name='PageSettingsCard' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='SettingsCard' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='Settings page with grouped options. Each card has an icon, title, description, and interactive control.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='0'
                                BorderBrush='{{BORDER}}' BorderThickness='1'>
                            <StackPanel>
                                <Border Padding='16,12' BorderBrush='{{BORDER}}' BorderThickness='0,0,0,1'>
                                    <TextBlock Text='Appearance' FontSize='14' FontWeight='SemiBold'/>
                                </Border>
                                <Border Padding='16,10' BorderBrush='{{BORDER}}' BorderThickness='0,0,0,1'>
                                    <Grid ColumnDefinitions='36,*,Auto'>
                                        <SymbolIcon Symbol='View' VerticalAlignment='Center'/>
                                        <StackPanel Grid.Column='1' Margin='12,0' VerticalAlignment='Center'>
                                            <TextBlock Text='Dark mode' FontSize='13' FontWeight='SemiBold'/>
                                            <TextBlock Text='Switch between light and dark theme' FontSize='12' Foreground='{{DIM}}'/>
                                        </StackPanel>
                                        <ToggleSwitch x:Name='SettDarkMode' Grid.Column='2' IsOn='True' VerticalAlignment='Center'/>
                                    </Grid>
                                </Border>
                                <Border Padding='16,10' BorderBrush='{{BORDER}}' BorderThickness='0,0,0,1'>
                                    <Grid ColumnDefinitions='36,*,Auto'>
                                        <SymbolIcon Symbol='Font' VerticalAlignment='Center'/>
                                        <StackPanel Grid.Column='1' Margin='12,0' VerticalAlignment='Center'>
                                            <TextBlock Text='Font size' FontSize='13' FontWeight='SemiBold'/>
                                            <TextBlock Text='Adjust the display font size' FontSize='12' Foreground='{{DIM}}'/>
                                        </StackPanel>
                                        <Slider x:Name='SettFontSize' Grid.Column='2' Minimum='10' Maximum='24'
                                                Value='14' Width='140' VerticalAlignment='Center'/>
                                    </Grid>
                                </Border>
                                <Border Padding='16,12' BorderBrush='{{BORDER}}' BorderThickness='0,0,0,1'>
                                    <TextBlock Text='Notifications' FontSize='14' FontWeight='SemiBold'/>
                                </Border>
                                <Border Padding='16,10' BorderBrush='{{BORDER}}' BorderThickness='0,0,0,1'>
                                    <Grid ColumnDefinitions='36,*,Auto'>
                                        <SymbolIcon Symbol='Mail' VerticalAlignment='Center'/>
                                        <StackPanel Grid.Column='1' Margin='12,0' VerticalAlignment='Center'>
                                            <TextBlock Text='Email notifications' FontSize='13' FontWeight='SemiBold'/>
                                            <TextBlock Text='Receive email alerts for updates' FontSize='12' Foreground='{{DIM}}'/>
                                        </StackPanel>
                                        <ToggleSwitch x:Name='SettEmail' Grid.Column='2' IsOn='True' VerticalAlignment='Center'/>
                                    </Grid>
                                </Border>
                                <Border Padding='16,10' BorderBrush='{{BORDER}}' BorderThickness='0,0,0,1'>
                                    <Grid ColumnDefinitions='36,*,Auto'>
                                        <SymbolIcon Symbol='Volume' VerticalAlignment='Center'/>
                                        <StackPanel Grid.Column='1' Margin='12,0' VerticalAlignment='Center'>
                                            <TextBlock Text='Sound effects' FontSize='13' FontWeight='SemiBold'/>
                                            <TextBlock Text='Play sounds for actions' FontSize='12' Foreground='{{DIM}}'/>
                                        </StackPanel>
                                        <ToggleSwitch x:Name='SettSound' Grid.Column='2' VerticalAlignment='Center'/>
                                    </Grid>
                                </Border>
                                <Border Padding='16,10'>
                                    <Grid ColumnDefinitions='36,*,Auto'>
                                        <SymbolIcon Symbol='Download' VerticalAlignment='Center'/>
                                        <StackPanel Grid.Column='1' Margin='12,0' VerticalAlignment='Center'>
                                            <TextBlock Text='Auto-update' FontSize='13' FontWeight='SemiBold'/>
                                            <TextBlock Text='Automatically check for updates' FontSize='12' Foreground='{{DIM}}'/>
                                        </StackPanel>
                                        <CheckBox x:Name='SettAutoUpdate' Grid.Column='2' IsChecked='True' VerticalAlignment='Center'/>
                                    </Grid>
                                </Border>
                            </StackPanel>
                        </Border>
                        <TextBlock x:Name='SettStatus' Text='Dark mode: On | Font size: 14 | Email: On | Sound: Off | Auto-update: On'
                                   Foreground='{{DIM}}' FontSize='12'/>
                    </StackPanel>

                    <StackPanel x:Name='PageSegmented' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='Segmented' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='A set of buttons that act as a single selection group, similar to iOS segmented control.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='20'>
                            <StackPanel Spacing='16'>
                                <TextBlock Text='View mode' FontSize='13' FontWeight='SemiBold'/>
                                <Border Background='{{CANVAS_BG}}' CornerRadius='8' Padding='4'
                                        HorizontalAlignment='Center'>
                                    <StackPanel x:Name='SegmentedBar' Orientation='Horizontal' Spacing='2'/>
                                </Border>
                                <Border Background='{{CANVAS_BG}}' CornerRadius='6' Padding='16' MinHeight='120'>
                                    <StackPanel x:Name='SegmentedContent' Spacing='6'/>
                                </Border>
                                <TextBlock Text='Icon style' FontSize='13' FontWeight='SemiBold' Margin='0,8,0,0'/>
                                <Border Background='{{CANVAS_BG}}' CornerRadius='8' Padding='4'
                                        HorizontalAlignment='Center'>
                                    <StackPanel x:Name='SegmentedIcons' Orientation='Horizontal' Spacing='2'/>
                                </Border>
                                <TextBlock x:Name='SegIconLabel' Text='Grid view selected'
                                           Foreground='{{DIM}}' FontSize='12' HorizontalAlignment='Center'/>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                    <StackPanel x:Name='PageColorPicker' Spacing='12' Visibility='Collapsed'>
                        <TextBlock Text='ColorPickerButton' FontSize='24' FontWeight='Bold'/>
                        <TextBlock Text='Pick a color using RGB sliders with live preview swatch and hex output.'
                                   Foreground='{{DIM}}' FontSize='13' TextWrapping='Wrap'/>
                        <Border Background='{{CARD}}' CornerRadius='8' Padding='20'>
                            <StackPanel Spacing='12'>
                                <Grid ColumnDefinitions='*,120'>
                                    <StackPanel Spacing='10'>
                                        <StackPanel Orientation='Horizontal' Spacing='8'>
                                            <TextBlock Text='R' FontSize='13' FontWeight='SemiBold'
                                                       Foreground='#E84040' Width='16' VerticalAlignment='Center'/>
                                            <Slider x:Name='ColorR' Minimum='0' Maximum='255' Value='78'
                                                    StepFrequency='1' Width='280'/>
                                            <TextBlock x:Name='ColorRVal' Text='78' FontSize='12'
                                                       Foreground='{{DIM}}' Width='30' VerticalAlignment='Center'/>
                                        </StackPanel>
                                        <StackPanel Orientation='Horizontal' Spacing='8'>
                                            <TextBlock Text='G' FontSize='13' FontWeight='SemiBold'
                                                       Foreground='#2DB84D' Width='16' VerticalAlignment='Center'/>
                                            <Slider x:Name='ColorG' Minimum='0' Maximum='255' Value='194'
                                                    StepFrequency='1' Width='280'/>
                                            <TextBlock x:Name='ColorGVal' Text='194' FontSize='12'
                                                       Foreground='{{DIM}}' Width='30' VerticalAlignment='Center'/>
                                        </StackPanel>
                                        <StackPanel Orientation='Horizontal' Spacing='8'>
                                            <TextBlock Text='B' FontSize='13' FontWeight='SemiBold'
                                                       Foreground='#4CC2FF' Width='16' VerticalAlignment='Center'/>
                                            <Slider x:Name='ColorB' Minimum='0' Maximum='255' Value='255'
                                                    StepFrequency='1' Width='280'/>
                                            <TextBlock x:Name='ColorBVal' Text='255' FontSize='12'
                                                       Foreground='{{DIM}}' Width='30' VerticalAlignment='Center'/>
                                        </StackPanel>
                                    </StackPanel>
                                    <StackPanel Grid.Column='1' HorizontalAlignment='Center' Spacing='6'>
                                        <Border x:Name='ColorPreview' Width='80' Height='80' CornerRadius='12'
                                                Background='#4EC2FF' BorderBrush='{{BORDER}}' BorderThickness='1'/>
                                        <TextBlock x:Name='ColorHex' Text='#4EC2FF' FontSize='12'
                                                   FontFamily='Consolas' HorizontalAlignment='Center'/>
                                    </StackPanel>
                                </Grid>
                                <Border Height='1' Background='{{BORDER}}'/>
                                <TextBlock Text='Presets' FontSize='13' FontWeight='SemiBold'/>
                                <StackPanel Orientation='Horizontal' Spacing='6'>
                                    <Button x:Name='CPreset1' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#FF4444' BorderThickness='0'/>
                                    <Button x:Name='CPreset2' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#FF8C00' BorderThickness='0'/>
                                    <Button x:Name='CPreset3' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#FFD700' BorderThickness='0'/>
                                    <Button x:Name='CPreset4' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#2DB84D' BorderThickness='0'/>
                                    <Button x:Name='CPreset5' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#4CC2FF' BorderThickness='0'/>
                                    <Button x:Name='CPreset6' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#0078D4' BorderThickness='0'/>
                                    <Button x:Name='CPreset7' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#8B5CF6' BorderThickness='0'/>
                                    <Button x:Name='CPreset8' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#1E1E1E' BorderThickness='1' BorderBrush='{{BORDER}}'/>
                                    <Button x:Name='CPreset9' Height='36' Width='36' CornerRadius='18' Padding='0'
                                            Background='#FFFFFF' BorderThickness='1' BorderBrush='{{BORDER}}'/>
                                </StackPanel>
                            </StackPanel>
                        </Border>
                    </StackPanel>

                </StackPanel>
            </ScrollViewer>
        </Grid>
        )")
    }

    R(xaml) {
        c := this.c
        xaml := StrReplace(xaml, "{{CARD}}", c["card"])
        xaml := StrReplace(xaml, "{{DIM}}", c["dim"])
        xaml := StrReplace(xaml, "{{FG}}", c["fg"])
        xaml := StrReplace(xaml, "{{ACCENT}}", c["accent"])
        xaml := StrReplace(xaml, "{{ACCENT_BG}}", c["accentBg"])
        xaml := StrReplace(xaml, "{{BORDER}}", c["border"])
        xaml := StrReplace(xaml, "{{TAG_BG}}", c["tagBg"])
        xaml := StrReplace(xaml, "{{TAG_FG}}", c["tagFg"])
        xaml := StrReplace(xaml, "{{CANVAS_BG}}", c["canvasBg"])
        xaml := StrReplace(xaml, "{{SELECTED}}", c["selected"])
        xaml := StrReplace(xaml, "{{TOOLBAR}}", c["toolbar"])
        xaml := StrReplace(xaml, "{{GAUGE_TRACK}}", c["gaugeTrack"])
        xaml := StrReplace(xaml, "{{GAUGE_GREEN}}", c["gaugeGreen"])
        xaml := StrReplace(xaml, "{{NAV_BG}}", c["navBg"])
        return xaml
    }

    EscapeXml(text) {
        text := StrReplace(text, "&", "&amp;")
        text := StrReplace(text, "<", "&lt;")
        text := StrReplace(text, ">", "&gt;")
        text := StrReplace(text, "'", "&apos;")
        text := StrReplace(text, '"', "&quot;")
        return text
    }

    MakeBrush(color) {
        return WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(
            "<SolidColorBrush xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' Color='" color "'/>"
        )
    }

    WireNavigation() {
        pages := ["RangeSelector", "RadialGauge", "TabbedCommandBar", "ListDetailsView", "MarkdownTextBlock", "SettingsCard", "Segmented", "ColorPicker"]
        for name in pages {
            this.xg["Nav" name].add_Click(this.OnNavigate.Bind(this, name))
        }
    }

    OnNavigate(pageName, *) {
        c := this.c
        pages := ["RangeSelector", "RadialGauge", "TabbedCommandBar", "ListDetailsView", "MarkdownTextBlock", "SettingsCard", "Segmented", "ColorPicker"]
        for name in pages {
            this.xg["Page" name].Visibility := (name = pageName) ? 0 : 1
            bg := (name = pageName) ? c["accentBg"] : "Transparent"
            this.xg["Nav" name].Background := this.MakeBrush(bg)
        }
        this.activePage := pageName
    }

    ;=== RangeSelector ===
    WireRangeSelector() {
        this.xg['RangeGhost'].add_ValueChanged(this.OnRangeGhost.Bind(this))
        this.RebuildRangeTrack()
    }

    OnRangeGhost(*) {
        if this._rangeUpdating
            return
        val := Round(this.xg['RangeGhost'].Value)
        distMin := Abs(val - this.rangeMin)
        distMax := Abs(val - this.rangeMax)
        if distMin <= distMax {
            this.rangeMin := Min(val, this.rangeMax)
        } else {
            this.rangeMax := Max(val, this.rangeMin)
        }
        span := this.rangeMax - this.rangeMin
        this.xg['RangeDisplay'].Text := "Range: " this.rangeMin " - " this.rangeMax " | Span: " span
        this.RebuildRangeTrack()
    }

    RebuildRangeTrack() {
        container := this.xg['RangeTrackContainer']
        container.Children.Clear()
        c := this.c
        left := Max(0.1, this.rangeMin)
        mid := Max(0.1, this.rangeMax - this.rangeMin)
        right := Max(0.1, 100 - this.rangeMax)
        xaml := "<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
            . " Height='24' Margin='10,0'"
            . " ColumnDefinitions='" left "*," mid "*," right "*'>"
            . "<Border Grid.ColumnSpan='3' Background='" c["gaugeTrack"] "'"
            . " Height='4' CornerRadius='2' VerticalAlignment='Center'/>"
            . "<Border Grid.Column='1' Background='" c["accent"] "'"
            . " Height='6' CornerRadius='3' VerticalAlignment='Center'/>"
            . "<Border Grid.Column='1' Width='12' Height='24' CornerRadius='6'"
            . " Background='" c["accent"] "' HorizontalAlignment='Left'"
            . " VerticalAlignment='Center' Margin='-6,0,0,0'/>"
            . "<Border Grid.Column='1' Width='12' Height='24' CornerRadius='6'"
            . " Background='" c["accent"] "' HorizontalAlignment='Right'"
            . " VerticalAlignment='Center' Margin='0,0,-6,0'/>"
            . "</Grid>"
        container.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml))
    }

    ;=== RadialGauge ===
    WireRadialGauge() {
        this.xg['GaugeSlider'].add_ValueChanged(this.OnGaugeChange.Bind(this))
        this.xg['Gauge0'].add_Click(this.SetGauge.Bind(this, 0))
        this.xg['Gauge25'].add_Click(this.SetGauge.Bind(this, 25))
        this.xg['Gauge50'].add_Click(this.SetGauge.Bind(this, 50))
        this.xg['Gauge75'].add_Click(this.SetGauge.Bind(this, 75))
        this.xg['Gauge100'].add_Click(this.SetGauge.Bind(this, 100))
        this.OnGaugeChange()
    }

    OnGaugeChange(*) {
        val := Round(this.xg['GaugeSlider'].Value)
        c := this.c
        if val < 33 {
            color := c["gaugeGreen"]
            label := "Good"
        } else if val < 66 {
            color := c["gaugeYellow"]
            label := "Warning"
        } else {
            color := c["gaugeRed"]
            label := "Critical"
        }
        this.xg['GaugeValue'].Text := String(val)
        this.xg['GaugeValue'].Foreground := this.MakeBrush(color)
        this.xg['GaugeLabel'].Text := label
        this.xg['GaugeOuter'].Background := this.MakeBrush(color)
        barWidth := Max(4, Round(val * 3.2))
        this.xg['GaugeBar'].Width := barWidth
        this.xg['GaugeBar'].Background := this.MakeBrush(color)
    }

    SetGauge(val, *) {
        this.xg['GaugeSlider'].Value := val
    }

    ;=== TabbedCommandBar ===
    WireTabbedCommandBar() {
        this.xg['TabHome'].add_Click(this.OnTabSwitch.Bind(this, "Home"))
        this.xg['TabInsert'].add_Click(this.OnTabSwitch.Bind(this, "Insert"))
        this.xg['TabView'].add_Click(this.OnTabSwitch.Bind(this, "View"))
        this.OnTabSwitch("Home")
    }

    OnTabSwitch(tabName, *) {
        this.activeTab := tabName
        c := this.c
        tabs := Map("Home", this.xg['TabHome'], "Insert", this.xg['TabInsert'], "View", this.xg['TabView'])
        for name, btn in tabs {
            bg := (name = tabName) ? c["accentBg"] : "Transparent"
            btn.Background := this.MakeBrush(bg)
        }
        content := this.xg['TabContent']
        content.Children.Clear()
        if tabName = "Home" {
            items := [["Paste", "Paste"], ["Cut", "Cut"], ["Copy", "Copy"], ["|", ""], ["Bold", "Bold"], ["Italic", "Italic"], ["Underline", "Underline"]]
        } else if tabName = "Insert" {
            items := [["Add", "Table"], ["Camera", "Picture"], ["Link", "Link"], ["|", ""], ["Globe", "Shape"], ["Document", "Chart"]]
        } else {
            items := [["View", "Normal"], ["AllApps", "Outline"], ["|", ""], ["ZoomIn", "Zoom In"], ["ZoomOut", "Zoom Out"], ["FullScreen", "Full Screen"]]
        }
        for pair in items {
            if pair[1] = "|" {
                sep := "<Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                    . " Width='1' Background='" c["border"] "' Margin='2,6'/>"
                content.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(sep))
                continue
            }
            xaml := "<Button xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " Height='36' Padding='10,4' CornerRadius='4'>"
                . "<StackPanel Orientation='Horizontal' Spacing='6'>"
                . "<SymbolIcon Symbol='" pair[1] "'/>"
                . "<TextBlock Text='" pair[2] "' VerticalAlignment='Center' FontSize='12'/>"
                . "</StackPanel></Button>"
            btn := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
            content.Children.Append(btn)
        }
        this.xg['TabStatus'].Text := tabName " tab active"
    }

    ;=== ListDetailsView ===
    WireMasterDetail() {
        contacts := [
            ["Alice Johnson", "Engineering", "alice@company.com", "Senior Engineer", "Seattle, WA", "2019"],
            ["Bob Smith", "Design", "bob@company.com", "Lead Designer", "Portland, OR", "2018"],
            ["Carol Chen", "Engineering", "carol@company.com", "Staff Engineer", "San Jose, CA", "2017"],
            ["David Kim", "Marketing", "david@company.com", "Senior Marketer", "Austin, TX", "2020"],
            ["Eva Martinez", "Engineering", "eva@company.com", "Junior Engineer", "Denver, CO", "2022"],
            ["Grace Lee", "Product", "grace@company.com", "Product Lead", "New York, NY", "2015"]
        ]
        this.contacts := contacts
        c := this.c
        masterList := this.xg['MasterList']
        for i, contact in contacts {
            xaml := "<Button xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " HorizontalAlignment='Stretch' HorizontalContentAlignment='Left'"
                . " Background='Transparent' BorderThickness='0' Padding='12,8'"
                . " CornerRadius='0' Height='48'>"
                . "<StackPanel>"
                . "<TextBlock Text='" this.EscapeXml(contact[1]) "' FontSize='13' FontWeight='SemiBold'/>"
                . "<TextBlock Text='" this.EscapeXml(contact[2]) "' FontSize='11' Foreground='" c["dim"] "'/>"
                . "</StackPanel></Button>"
            btn := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
            btn.add_Click(this.OnContactSelect.Bind(this, i))
            masterList.Children.Append(btn)
        }
    }

    OnContactSelect(idx, *) {
        if idx < 1 || idx > this.contacts.Length
            return
        contact := this.contacts[idx]
        c := this.c
        this.selectedContact := idx
        masterList := this.xg['MasterList']
        Loop masterList.Children.Size {
            i := A_Index - 1
            bg := (A_Index = idx) ? c["selected"] : "Transparent"
            masterList.Children.GetAt(i).Background := this.MakeBrush(bg)
        }
        detail := this.xg['DetailPanel']
        detail.Children.Clear()
        nameXaml := "<TextBlock xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
            . " Text='" this.EscapeXml(contact[1]) "' FontSize='20' FontWeight='Bold'/>"
        detail.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(nameXaml))
        titleXaml := "<TextBlock xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
            . " Text='" this.EscapeXml(contact[4] " - " contact[2]) "'"
            . " FontSize='13' Foreground='" c["dim"] "' Margin='0,0,0,12'/>"
        detail.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(titleXaml))
        labels := ["Name", "Department", "Email", "Title", "Location", "Hired"]
        for i, lbl in labels {
            val := contact[i]
            rowXaml := "<Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " Background='" c["canvasBg"] "' CornerRadius='4' Padding='10,6' Margin='0,2'>"
                . "<Grid ColumnDefinitions='80,*'>"
                . "<TextBlock Text='" this.EscapeXml(lbl) "'"
                . " FontSize='12' Foreground='" c["dim"] "' VerticalAlignment='Center'/>"
                . "<TextBlock Grid.Column='1' Text='" this.EscapeXml(val) "'"
                . " FontSize='13' VerticalAlignment='Center'/>"
                . "</Grid></Border>"
            detail.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(rowXaml))
        }
    }

    ;=== SettingsCard ===
    WireSettingsCard() {
        this.xg['SettDarkMode'].add_Toggled(this.OnSettingsChange.Bind(this))
        this.xg['SettFontSize'].add_ValueChanged(this.OnSettingsChange.Bind(this))
        this.xg['SettEmail'].add_Toggled(this.OnSettingsChange.Bind(this))
        this.xg['SettSound'].add_Toggled(this.OnSettingsChange.Bind(this))
        this.xg['SettAutoUpdate'].add_Click(this.OnSettingsChange.Bind(this))
    }

    OnSettingsChange(*) {
        dark := this.xg['SettDarkMode'].IsOn ? "On" : "Off"
        font := Round(this.xg['SettFontSize'].Value)
        email := this.xg['SettEmail'].IsOn ? "On" : "Off"
        sound := this.xg['SettSound'].IsOn ? "On" : "Off"
        update := this.xg['SettAutoUpdate'].IsChecked ? "On" : "Off"
        this.xg['SettStatus'].Text := "Dark mode: " dark " | Font size: " font
            . " | Email: " email " | Sound: " sound " | Auto-update: " update
    }

    ;=== Segmented ===
    WireSegmented() {
        this.segSelected := "List"
        this.segIconSelected := "Grid"
        c := this.c
        bar := this.xg['SegmentedBar']
        for label in ["List", "Grid", "Cards", "Table"] {
            bg := (label = this.segSelected) ? c["accent"] : "Transparent"
            fg := (label = this.segSelected) ? "#FFFFFF" : c["fg"]
            xaml := "<Button xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " Content='" label "' Height='30' MinWidth='70' CornerRadius='6'"
                . " Background='" bg "' Foreground='" fg "'"
                . " FontSize='12' FontWeight='SemiBold' BorderThickness='0' Padding='12,0'/>"
            btn := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
            btn.add_Click(this.OnSegmentPick.Bind(this, label))
            bar.Children.Append(btn)
        }
        iconBar := this.xg['SegmentedIcons']
        for item in [["ViewAll", "Grid"], ["List", "List"], ["Target", "Map"], ["Globe", "Web"]] {
            bg := (item[2] = this.segIconSelected) ? c["accent"] : "Transparent"
            xaml := "<Button xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " Height='34' Width='42' CornerRadius='6'"
                . " Background='" bg "' BorderThickness='0' Padding='0'>"
                . "<SymbolIcon Symbol='" item[1] "'/></Button>"
            btn := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
            btn.add_Click(this.OnSegIconPick.Bind(this, item[2]))
            iconBar.Children.Append(btn)
        }
        this.RefreshSegmentContent()
    }

    OnSegmentPick(label, *) {
        this.segSelected := label
        c := this.c
        bar := this.xg['SegmentedBar']
        idx := 0
        for l in ["List", "Grid", "Cards", "Table"] {
            bg := (l = label) ? c["accent"] : "Transparent"
            fg := (l = label) ? "#FFFFFF" : c["fg"]
            bar.Children.GetAt(idx).Background := this.MakeBrush(bg)
            bar.Children.GetAt(idx).Foreground := this.MakeBrush(fg)
            idx++
        }
        this.RefreshSegmentContent()
    }

    RefreshSegmentContent() {
        c := this.c
        panel := this.xg['SegmentedContent']
        panel.Children.Clear()
        items := ["Project Alpha", "Project Beta", "Project Gamma", "Project Delta"]
        if this.segSelected = "List" {
            for item in items {
                xaml := "<Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                    . " Background='" c["card"] "' CornerRadius='4' Padding='12,8' Margin='0,2'>"
                    . "<StackPanel Orientation='Horizontal' Spacing='8'>"
                    . "<SymbolIcon Symbol='Document'/>"
                    . "<TextBlock Text='" item "' FontSize='13' VerticalAlignment='Center'/>"
                    . "</StackPanel></Border>"
                panel.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml))
            }
        } else if this.segSelected = "Grid" {
            row := "<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " ColumnDefinitions='*,*' RowDefinitions='Auto,Auto' HorizontalAlignment='Stretch'>"
            col := 0
            rowN := 0
            for item in items {
                row .= "<Border Grid.Column='" col "' Grid.Row='" rowN "'"
                    . " Background='" c["card"] "' CornerRadius='6' Padding='12' Margin='4'>"
                    . "<StackPanel HorizontalAlignment='Center' Spacing='4'>"
                    . "<SymbolIcon Symbol='Document'/>"
                    . "<TextBlock Text='" item "' FontSize='12'/>"
                    . "</StackPanel></Border>"
                col++
                if col > 1 {
                    col := 0
                    rowN++
                }
            }
            row .= "</Grid>"
            panel.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(row))
        } else if this.segSelected = "Cards" {
            for item in items {
                xaml := "<Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                    . " Background='" c["card"] "' CornerRadius='8' Padding='16' Margin='0,4'"
                    . " BorderBrush='" c["border"] "' BorderThickness='1'>"
                    . "<StackPanel Spacing='4'>"
                    . "<TextBlock Text='" item "' FontSize='14' FontWeight='SemiBold'/>"
                    . "<TextBlock Text='A sample project card with description text.' FontSize='12' Foreground='" c["dim"] "'/>"
                    . "</StackPanel></Border>"
                panel.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml))
            }
        } else {
            header := "<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                . " ColumnDefinitions='*,80,80' Margin='0,0,0,4'>"
                . "<TextBlock Text='Name' FontSize='12' FontWeight='SemiBold' Foreground='" c["dim"] "'/>"
                . "<TextBlock Grid.Column='1' Text='Status' FontSize='12' FontWeight='SemiBold' Foreground='" c["dim"] "'/>"
                . "<TextBlock Grid.Column='2' Text='Priority' FontSize='12' FontWeight='SemiBold' Foreground='" c["dim"] "'/>"
                . "</Grid>"
            panel.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(header))
            statuses := ["Active", "Paused", "Active", "Draft"]
            priorities := ["High", "Medium", "Low", "Medium"]
            idx := 1
            for item in items {
                xaml := "<Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'"
                    . " Background='" c["card"] "' CornerRadius='4' Padding='8,6' Margin='0,1'>"
                    . "<Grid ColumnDefinitions='*,80,80'>"
                    . "<TextBlock Text='" item "' FontSize='12' VerticalAlignment='Center'/>"
                    . "<TextBlock Grid.Column='1' Text='" statuses[idx] "' FontSize='12' Foreground='" c["accent"] "'/>"
                    . "<TextBlock Grid.Column='2' Text='" priorities[idx] "' FontSize='12' Foreground='" c["dim"] "'/>"
                    . "</Grid></Border>"
                panel.Children.Append(WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml))
                idx++
            }
        }
    }

    OnSegIconPick(label, *) {
        this.segIconSelected := label
        c := this.c
        iconBar := this.xg['SegmentedIcons']
        idx := 0
        for item in [["ViewAll", "Grid"], ["List", "List"], ["Target", "Map"], ["Globe", "Web"]] {
            bg := (item[2] = label) ? c["accent"] : "Transparent"
            iconBar.Children.GetAt(idx).Background := this.MakeBrush(bg)
            idx++
        }
        this.xg['SegIconLabel'].Text := label " view selected"
    }

    ;=== ColorPicker ===
    WireColorPicker() {
        this.xg['ColorR'].add_ValueChanged(this.OnColorChange.Bind(this))
        this.xg['ColorG'].add_ValueChanged(this.OnColorChange.Bind(this))
        this.xg['ColorB'].add_ValueChanged(this.OnColorChange.Bind(this))
        presets := [
            [1, 255, 68, 68], [2, 255, 140, 0], [3, 255, 215, 0],
            [4, 45, 184, 77], [5, 76, 194, 255], [6, 0, 120, 212],
            [7, 139, 92, 246], [8, 30, 30, 30], [9, 255, 255, 255]
        ]
        for p in presets {
            this.xg['CPreset' p[1]].add_Click(this.OnColorPreset.Bind(this, p[2], p[3], p[4]))
        }
    }

    OnColorChange(*) {
        r := Round(this.xg['ColorR'].Value)
        g := Round(this.xg['ColorG'].Value)
        b := Round(this.xg['ColorB'].Value)
        this.xg['ColorRVal'].Text := String(r)
        this.xg['ColorGVal'].Text := String(g)
        this.xg['ColorBVal'].Text := String(b)
        hex := "#" Format("{:02X}", r) Format("{:02X}", g) Format("{:02X}", b)
        this.xg['ColorHex'].Text := hex
        this.xg['ColorPreview'].Background := this.MakeBrush(hex)
    }

    OnColorPreset(r, g, b, *) {
        this.xg['ColorR'].Value := r
        this.xg['ColorG'].Value := g
        this.xg['ColorB'].Value := b
    }
}
