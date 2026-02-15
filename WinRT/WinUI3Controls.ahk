#Requires AutoHotkey v2.1-alpha.16
#Include WinUI3.ahk

; =============================================================================
; WinUI3Controls - Extended wrapper classes for WinUI3-exclusive controls
; =============================================================================
; PART 1 - Built-in WinUI3 controls (Windows App SDK only):
;   InfoBar, ContentDialog, NumberBox, ColorPicker, NavigationView, TabView,
;   Expander, RatingControl, CalendarDatePicker, ProgressRing.
;
; PART 2 - Windows Community Toolkit controls (requires CommunityToolkit.WinUI):
;   SettingsCard, SettingsExpander, Segmented, TokenizingTextBox,
;   RadialGauge, RangeSelector, ImageCropper, ContentSizer, GridSplitter.
;   XAML namespace: xmlns:ctk="using:CommunityToolkit.WinUI.Controls"
;   NuGet: CommunityToolkit.WinUI.Controls
;   GitHub: https://github.com/CommunityToolkit/Windows
;
; Usage: #Include WinUI3Controls.ahk (after WinUI3.ahk)
;
; These wrappers use GetProperty/SetProperty on generic XamlElement COM objects.
; For typed COM access, Phase 2 will add C++ wrappers to WinUI3Bridge.dll.

; =========================================================================
; WinUI3Ctrl - Self-contained base class for extended control wrappers
; =========================================================================
; Mirrors WinUI3.Element API but is standalone (no dependency on WinUI3.ahk
; at parse time). When WinUI3.ahk IS loaded, WrapControl() bridges between them.

class WinUI3Ctrl {
    _com := ""
    _win := ""

    __New(comObj, win := "") {
        this._com := comObj
        this._win := win
    }

    Name {
        get {
            try return this._com.Name
            return ""
        }
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

    GetProperty(name) {
        try return this._com.GetProperty(name)
        try return this._com.%name%
        return ""
    }

    SetProperty(name, value) {
        try {
            this._com.SetProperty(name, value)
            return this
        }
        try this._com.%name% := value
        return this
    }

    Focus() {
        try this._com.Focus()
        return this
    }

    OnEvent(eventName, callback) {
        elemName := this.Name
        if elemName && this._win
            this._win.OnEvent(elemName, eventName, callback)
        return this
    }
}

; =========================================================================
; WinUI3Ctrl.InfoBar
; =========================================================================
; Notification bar with severity levels (Success, Warning, Error, Informational).
; WinUI3-exclusive - no AHK v2 equivalent exists.
;
; XAML: <InfoBar x:Name="MyInfo" Title="Title" Message="Details"
;                Severity="Warning" IsOpen="True"/>

class WinUI3Ctrl_InfoBar extends WinUI3Ctrl {
    Title {
        get => this.GetProperty("Title")
        set => this.SetProperty("Title", value)
    }

    Message {
        get => this.GetProperty("Message")
        set => this.SetProperty("Message", value)
    }

    ; Severity: "Informational" (0), "Success" (1), "Warning" (2), "Error" (3)
    Severity {
        get => this.GetProperty("Severity")
        set => this.SetProperty("Severity", value)
    }

    IsOpen {
        get => this.GetProperty("IsOpen")
        set => this.SetProperty("IsOpen", value)
    }

    IsClosable {
        get => this.GetProperty("IsClosable")
        set => this.SetProperty("IsClosable", value)
    }

    OnClosed(callback) => this.OnEvent("Closed", callback)
    OnCloseButtonClick(callback) => this.OnEvent("CloseButtonClick", callback)
}

; =========================================================================
; WinUI3Ctrl.ContentDialog
; =========================================================================
; Modal dialog with primary/secondary/close buttons.
; Replaces MsgBox with full WinUI3 styling and custom content.
;
; XAML: <ContentDialog x:Name="MyDialog" Title="Confirm"
;                      PrimaryButtonText="OK"/>

class WinUI3Ctrl_ContentDialog extends WinUI3Ctrl {
    Title {
        get => this.GetProperty("Title")
        set => this.SetProperty("Title", value)
    }

    PrimaryButtonText {
        get => this.GetProperty("PrimaryButtonText")
        set => this.SetProperty("PrimaryButtonText", value)
    }

    SecondaryButtonText {
        get => this.GetProperty("SecondaryButtonText")
        set => this.SetProperty("SecondaryButtonText", value)
    }

    CloseButtonText {
        get => this.GetProperty("CloseButtonText")
        set => this.SetProperty("CloseButtonText", value)
    }

    DefaultButton {
        get => this.GetProperty("DefaultButton")
        set => this.SetProperty("DefaultButton", value)
    }

    OnPrimaryButtonClick(callback) => this.OnEvent("PrimaryButtonClick", callback)
    OnSecondaryButtonClick(callback) => this.OnEvent("SecondaryButtonClick", callback)
    OnCloseButtonClick(callback) => this.OnEvent("CloseButtonClick", callback)

    ; ShowAsync is async - use SetProperty("IsOpen", true) or C++ bridge
    ShowAsync() {
        try this._com.ShowAsync()
    }
}

; =========================================================================
; WinUI3Ctrl.NumberBox
; =========================================================================
; Numeric input with spinner, min/max validation, step control.
; No AHK v2 equivalent - normally requires manual Edit + UpDown combo.
;
; XAML: <NumberBox x:Name="NumBox" Value="50" Minimum="0" Maximum="100"
;                  SpinButtonPlacementMode="Inline" SmallChange="1"/>

class WinUI3Ctrl_NumberBox extends WinUI3Ctrl {
    Value {
        get => this.GetProperty("Value")
        set => this.SetProperty("Value", value)
    }

    Minimum {
        get => this.GetProperty("Minimum")
        set => this.SetProperty("Minimum", value)
    }

    Maximum {
        get => this.GetProperty("Maximum")
        set => this.SetProperty("Maximum", value)
    }

    SmallChange {
        get => this.GetProperty("SmallChange")
        set => this.SetProperty("SmallChange", value)
    }

    LargeChange {
        get => this.GetProperty("LargeChange")
        set => this.SetProperty("LargeChange", value)
    }

    ; SpinButtonPlacementMode: "Hidden" (0), "Compact" (1), "Inline" (2)
    SpinButtonPlacementMode {
        get => this.GetProperty("SpinButtonPlacementMode")
        set => this.SetProperty("SpinButtonPlacementMode", value)
    }

    Header {
        get => this.GetProperty("Header")
        set => this.SetProperty("Header", value)
    }

    PlaceholderText {
        get => this.GetProperty("PlaceholderText")
        set => this.SetProperty("PlaceholderText", value)
    }

    OnValueChanged(callback) => this.OnEvent("ValueChanged", callback)
}

; =========================================================================
; WinUI3Ctrl.ColorPicker
; =========================================================================
; Full color selection with spectrum, hex input, alpha channel.
; No AHK v2 equivalent - normally requires Win32 ChooseColor dialog.
;
; XAML: <ColorPicker x:Name="Picker" IsAlphaEnabled="True"
;                    IsHexInputVisible="True"/>

class WinUI3Ctrl_ColorPicker extends WinUI3Ctrl {
    ; Color as Windows.UI.Color struct
    Color {
        get => this.GetProperty("Color")
        set => this.SetProperty("Color", value)
    }

    IsAlphaEnabled {
        get => this.GetProperty("IsAlphaEnabled")
        set => this.SetProperty("IsAlphaEnabled", value)
    }

    IsAlphaSliderVisible {
        get => this.GetProperty("IsAlphaSliderVisible")
        set => this.SetProperty("IsAlphaSliderVisible", value)
    }

    IsAlphaTextInputVisible {
        get => this.GetProperty("IsAlphaTextInputVisible")
        set => this.SetProperty("IsAlphaTextInputVisible", value)
    }

    IsHexInputVisible {
        get => this.GetProperty("IsHexInputVisible")
        set => this.SetProperty("IsHexInputVisible", value)
    }

    IsMoreButtonVisible {
        get => this.GetProperty("IsMoreButtonVisible")
        set => this.SetProperty("IsMoreButtonVisible", value)
    }

    ; ColorSpectrumShape: "Box" (0), "Ring" (1)
    ColorSpectrumShape {
        get => this.GetProperty("ColorSpectrumShape")
        set => this.SetProperty("ColorSpectrumShape", value)
    }

    OnColorChanged(callback) => this.OnEvent("ColorChanged", callback)
}

; =========================================================================
; WinUI3Ctrl.NavigationView
; =========================================================================
; Side navigation with hamburger toggle, items, content area switching.
; WinUI3-exclusive - closest AHK v2 has is TreeView + manual panel logic.
;
; XAML: <NavigationView x:Name="NavView" PaneDisplayMode="Left"
;                       IsBackButtonVisible="Collapsed">

class WinUI3Ctrl_NavigationView extends WinUI3Ctrl {
    IsPaneOpen {
        get => this.GetProperty("IsPaneOpen")
        set => this.SetProperty("IsPaneOpen", value)
    }

    ; PaneDisplayMode: "Auto" (0), "Left" (1), "Top" (2),
    ;                  "LeftCompact" (3), "LeftMinimal" (4)
    PaneDisplayMode {
        get => this.GetProperty("PaneDisplayMode")
        set => this.SetProperty("PaneDisplayMode", value)
    }

    ; IsBackButtonVisible: "Collapsed" (0), "Visible" (1), "Auto" (2)
    IsBackButtonVisible {
        get => this.GetProperty("IsBackButtonVisible")
        set => this.SetProperty("IsBackButtonVisible", value)
    }

    IsSettingsVisible {
        get => this.GetProperty("IsSettingsVisible")
        set => this.SetProperty("IsSettingsVisible", value)
    }

    Header {
        get => this.GetProperty("Header")
        set => this.SetProperty("Header", value)
    }

    SelectedItem {
        get => this.GetProperty("SelectedItem")
        set => this.SetProperty("SelectedItem", value)
    }

    CompactModeThresholdWidth {
        get => this.GetProperty("CompactModeThresholdWidth")
        set => this.SetProperty("CompactModeThresholdWidth", value)
    }

    OnSelectionChanged(callback) => this.OnEvent("SelectionChanged", callback)
    OnItemInvoked(callback) => this.OnEvent("ItemInvoked", callback)
    OnBackRequested(callback) => this.OnEvent("BackRequested", callback)
    OnPaneOpening(callback) => this.OnEvent("PaneOpening", callback)
    OnPaneClosing(callback) => this.OnEvent("PaneClosing", callback)
}

; =========================================================================
; WinUI3Ctrl.TabView
; =========================================================================
; Tabbed interface with close buttons, add tab button, drag reorder.
; No AHK v2 equivalent - Tab3 control is far more limited.
;
; XAML: <TabView x:Name="Tabs" IsAddTabButtonVisible="True"
;                TabWidthMode="Equal" CloseButtonOverlayMode="Auto"/>

class WinUI3Ctrl_TabView extends WinUI3Ctrl {
    SelectedIndex {
        get => this.GetProperty("SelectedIndex")
        set => this.SetProperty("SelectedIndex", value)
    }

    SelectedItem {
        get => this.GetProperty("SelectedItem")
        set => this.SetProperty("SelectedItem", value)
    }

    IsAddTabButtonVisible {
        get => this.GetProperty("IsAddTabButtonVisible")
        set => this.SetProperty("IsAddTabButtonVisible", value)
    }

    ; TabWidthMode: "Equal" (0), "SizeToContent" (1), "Compact" (2)
    TabWidthMode {
        get => this.GetProperty("TabWidthMode")
        set => this.SetProperty("TabWidthMode", value)
    }

    ; CloseButtonOverlayMode: "Auto" (0), "OnPointerOver" (1), "Always" (2)
    CloseButtonOverlayMode {
        get => this.GetProperty("CloseButtonOverlayMode")
        set => this.SetProperty("CloseButtonOverlayMode", value)
    }

    CanDragTabs {
        get => this.GetProperty("CanDragTabs")
        set => this.SetProperty("CanDragTabs", value)
    }

    CanReorderTabs {
        get => this.GetProperty("CanReorderTabs")
        set => this.SetProperty("CanReorderTabs", value)
    }

    OnTabCloseRequested(callback) => this.OnEvent("TabCloseRequested", callback)
    OnSelectionChanged(callback) => this.OnEvent("SelectionChanged", callback)
    OnAddTabButtonClick(callback) => this.OnEvent("AddTabButtonClick", callback)
}

; =========================================================================
; WinUI3Ctrl.Expander
; =========================================================================
; Collapsible section with animated expand/collapse and custom header/content.
; No AHK v2 native equivalent.
;
; XAML: <Expander x:Name="Exp" Header="Section Title" IsExpanded="False"
;                 ExpandDirection="Down"/>

class WinUI3Ctrl_Expander extends WinUI3Ctrl {
    IsExpanded {
        get => this.GetProperty("IsExpanded")
        set => this.SetProperty("IsExpanded", value)
    }

    Header {
        get => this.GetProperty("Header")
        set => this.SetProperty("Header", value)
    }

    ; ExpandDirection: "Down" (0), "Up" (1)
    ExpandDirection {
        get => this.GetProperty("ExpandDirection")
        set => this.SetProperty("ExpandDirection", value)
    }

    OnExpanding(callback) => this.OnEvent("Expanding", callback)
    OnCollapsed(callback) => this.OnEvent("Collapsed", callback)
}

; =========================================================================
; WinUI3Ctrl.RatingControl
; =========================================================================
; Star rating with half-star support, read-only mode.
; No AHK v2 equivalent whatsoever.
;
; XAML: <RatingControl x:Name="Rating" Value="3" MaxRating="5"
;                      IsReadOnly="False" IsClearEnabled="True"/>

class WinUI3Ctrl_RatingControl extends WinUI3Ctrl {
    Value {
        get => this.GetProperty("Value")
        set => this.SetProperty("Value", value)
    }

    MaxRating {
        get => this.GetProperty("MaxRating")
        set => this.SetProperty("MaxRating", value)
    }

    IsReadOnly {
        get => this.GetProperty("IsReadOnly")
        set => this.SetProperty("IsReadOnly", value)
    }

    IsClearEnabled {
        get => this.GetProperty("IsClearEnabled")
        set => this.SetProperty("IsClearEnabled", value)
    }

    PlaceholderValue {
        get => this.GetProperty("PlaceholderValue")
        set => this.SetProperty("PlaceholderValue", value)
    }

    Caption {
        get => this.GetProperty("Caption")
        set => this.SetProperty("Caption", value)
    }

    OnValueChanged(callback) => this.OnEvent("ValueChanged", callback)
}

; =========================================================================
; WinUI3Ctrl.CalendarDatePicker
; =========================================================================
; Calendar popup for date selection with min/max range.
; No AHK v2 equivalent - DateTime picker is a different (Win32) control.
;
; XAML: <CalendarDatePicker x:Name="DatePick"
;                           PlaceholderText="Pick a date"/>

class WinUI3Ctrl_CalendarDatePicker extends WinUI3Ctrl {
    ; Date as DateTimeOffset
    Date {
        get => this.GetProperty("Date")
        set => this.SetProperty("Date", value)
    }

    MinDate {
        get => this.GetProperty("MinDate")
        set => this.SetProperty("MinDate", value)
    }

    MaxDate {
        get => this.GetProperty("MaxDate")
        set => this.SetProperty("MaxDate", value)
    }

    PlaceholderText {
        get => this.GetProperty("PlaceholderText")
        set => this.SetProperty("PlaceholderText", value)
    }

    IsTodayHighlighted {
        get => this.GetProperty("IsTodayHighlighted")
        set => this.SetProperty("IsTodayHighlighted", value)
    }

    IsCalendarOpen {
        get => this.GetProperty("IsCalendarOpen")
        set => this.SetProperty("IsCalendarOpen", value)
    }

    Header {
        get => this.GetProperty("Header")
        set => this.SetProperty("Header", value)
    }

    OnDateChanged(callback) => this.OnEvent("DateChanged", callback)
}

; =========================================================================
; WinUI3Ctrl.ProgressRing
; =========================================================================
; Circular indeterminate/determinate progress indicator.
; WinUI3-exclusive - no AHK v2 circular progress exists.
;
; XAML: <ProgressRing x:Name="Ring" IsActive="True"
;                     IsIndeterminate="True"/>

class WinUI3Ctrl_ProgressRing extends WinUI3Ctrl {
    IsActive {
        get => this.GetProperty("IsActive")
        set => this.SetProperty("IsActive", value)
    }

    IsIndeterminate {
        get => this.GetProperty("IsIndeterminate")
        set => this.SetProperty("IsIndeterminate", value)
    }

    Value {
        get => this.GetProperty("Value")
        set => this.SetProperty("Value", value)
    }

    Minimum {
        get => this.GetProperty("Minimum")
        set => this.SetProperty("Minimum", value)
    }

    Maximum {
        get => this.GetProperty("Maximum")
        set => this.SetProperty("Maximum", value)
    }
}

; *************************************************************************
; PART 2: Windows Community Toolkit Controls
; *************************************************************************
; Requires: CommunityToolkit.WinUI.Controls NuGet package
; XAML namespace: xmlns:ctk="using:CommunityToolkit.WinUI.Controls"
; These controls are .NET/WinUI3 assemblies from the Community Toolkit.

; =========================================================================
; CtkCtrl.SettingsCard
; =========================================================================
; Windows 11-style settings row with icon, header, description, and action.
; No AHK v2 equivalent - requires manual layout with multiple controls.
;
; XAML: <ctk:SettingsCard x:Name="Card" Header="Appearance"
;                         Description="Change theme and colors"
;                         HeaderIcon="{SymbolIcon Symbol=Personalize}">
;           <ComboBox SelectedIndex="0"><ComboBoxItem Content="Dark"/>...</ComboBox>
;       </ctk:SettingsCard>

class CtkCtrl_SettingsCard extends WinUI3Ctrl {
    Header {
        get => this.GetProperty("Header")
        set => this.SetProperty("Header", value)
    }

    Description {
        get => this.GetProperty("Description")
        set => this.SetProperty("Description", value)
    }

    ; ActionIcon shown on the right side
    ActionIcon {
        get => this.GetProperty("ActionIcon")
        set => this.SetProperty("ActionIcon", value)
    }

    IsClickEnabled {
        get => this.GetProperty("IsClickEnabled")
        set => this.SetProperty("IsClickEnabled", value)
    }

    IsActionIconVisible {
        get => this.GetProperty("IsActionIconVisible")
        set => this.SetProperty("IsActionIconVisible", value)
    }

    ; ContentAlignment: "Right" (default), "Left", "Vertical"
    ContentAlignment {
        get => this.GetProperty("ContentAlignment")
        set => this.SetProperty("ContentAlignment", value)
    }

    OnClick(callback) => this.OnEvent("Click", callback)
}

; =========================================================================
; CtkCtrl.SettingsExpander
; =========================================================================
; Expandable settings group with header card and child SettingsCards.
; Combines Expander behavior with SettingsCard header layout.
;
; XAML: <ctk:SettingsExpander x:Name="Expander" Header="Advanced"
;                             Description="Configure advanced options">
;           <ctk:SettingsExpander.Items>
;               <ctk:SettingsCard Header="Option 1">...</ctk:SettingsCard>
;           </ctk:SettingsExpander.Items>
;       </ctk:SettingsExpander>

class CtkCtrl_SettingsExpander extends WinUI3Ctrl {
    Header {
        get => this.GetProperty("Header")
        set => this.SetProperty("Header", value)
    }

    Description {
        get => this.GetProperty("Description")
        set => this.SetProperty("Description", value)
    }

    IsExpanded {
        get => this.GetProperty("IsExpanded")
        set => this.SetProperty("IsExpanded", value)
    }

    ; HeaderIcon for the header card
    HeaderIcon {
        get => this.GetProperty("HeaderIcon")
        set => this.SetProperty("HeaderIcon", value)
    }

    OnExpanding(callback) => this.OnEvent("Expanding", callback)
    OnCollapsed(callback) => this.OnEvent("Collapsed", callback)
}

; =========================================================================
; CtkCtrl.Segmented
; =========================================================================
; iOS-style segmented control / horizontal pill-button picker.
; No AHK v2 equivalent - closest is Radio buttons but visually different.
;
; XAML: <ctk:Segmented x:Name="Seg" SelectedIndex="0">
;           <ctk:SegmentedItem Content="Day"/>
;           <ctk:SegmentedItem Content="Week"/>
;           <ctk:SegmentedItem Content="Month"/>
;       </ctk:Segmented>

class CtkCtrl_Segmented extends WinUI3Ctrl {
    SelectedIndex {
        get => this.GetProperty("SelectedIndex")
        set => this.SetProperty("SelectedIndex", value)
    }

    SelectedItem {
        get => this.GetProperty("SelectedItem")
        set => this.SetProperty("SelectedItem", value)
    }

    ; SelectionMode: "Single" (default), "Multiple"
    SelectionMode {
        get => this.GetProperty("SelectionMode")
        set => this.SetProperty("SelectionMode", value)
    }

    OnSelectionChanged(callback) => this.OnEvent("SelectionChanged", callback)
}

; =========================================================================
; CtkCtrl.TokenizingTextBox
; =========================================================================
; Tag/token input with auto-suggest (like email To: field or tag editors).
; No AHK v2 equivalent - would require custom Edit + ListView combo.
;
; XAML: <ctk:TokenizingTextBox x:Name="Tags"
;                              PlaceholderText="Add tags..."
;                              MaximumTokens="10"
;                              QueryIcon="{SymbolIcon Symbol=Find}"/>

class CtkCtrl_TokenizingTextBox extends WinUI3Ctrl {
    PlaceholderText {
        get => this.GetProperty("PlaceholderText")
        set => this.SetProperty("PlaceholderText", value)
    }

    MaximumTokens {
        get => this.GetProperty("MaximumTokens")
        set => this.SetProperty("MaximumTokens", value)
    }

    Text {
        get => this.GetProperty("Text")
        set => this.SetProperty("Text", value)
    }

    ; SelectedTokens - collection of selected token objects
    SelectedTokens {
        get => this.GetProperty("SelectedTokens")
    }

    OnTokenItemAdding(callback) => this.OnEvent("TokenItemAdding", callback)
    OnTokenItemAdded(callback) => this.OnEvent("TokenItemAdded", callback)
    OnTokenItemRemoving(callback) => this.OnEvent("TokenItemRemoving", callback)
    OnTokenItemRemoved(callback) => this.OnEvent("TokenItemRemoved", callback)
    OnTextChanged(callback) => this.OnEvent("TextChanged", callback)
    OnSuggestionChosen(callback) => this.OnEvent("SuggestionChosen", callback)
}

; =========================================================================
; CtkCtrl.RadialGauge
; =========================================================================
; Circular gauge / speedometer visualization with animated needle.
; No AHK v2 equivalent - would require GDI+ custom drawing.
;
; XAML: <ctk:RadialGauge x:Name="Gauge" Value="65"
;                        Minimum="0" Maximum="100"
;                        TickSpacing="10" ScaleWidth="26"
;                        NeedleWidth="4" NeedleLength="80"
;                        Unit="%" ValueStringFormat="{}{0:0}"/>

class CtkCtrl_RadialGauge extends WinUI3Ctrl {
    Value {
        get => this.GetProperty("Value")
        set => this.SetProperty("Value", value)
    }

    Minimum {
        get => this.GetProperty("Minimum")
        set => this.SetProperty("Minimum", value)
    }

    Maximum {
        get => this.GetProperty("Maximum")
        set => this.SetProperty("Maximum", value)
    }

    StepSize {
        get => this.GetProperty("StepSize")
        set => this.SetProperty("StepSize", value)
    }

    TickSpacing {
        get => this.GetProperty("TickSpacing")
        set => this.SetProperty("TickSpacing", value)
    }

    ScaleWidth {
        get => this.GetProperty("ScaleWidth")
        set => this.SetProperty("ScaleWidth", value)
    }

    NeedleWidth {
        get => this.GetProperty("NeedleWidth")
        set => this.SetProperty("NeedleWidth", value)
    }

    NeedleLength {
        get => this.GetProperty("NeedleLength")
        set => this.SetProperty("NeedleLength", value)
    }

    Unit {
        get => this.GetProperty("Unit")
        set => this.SetProperty("Unit", value)
    }

    IsInteractive {
        get => this.GetProperty("IsInteractive")
        set => this.SetProperty("IsInteractive", value)
    }

    ; Colors
    TrailBrush {
        get => this.GetProperty("TrailBrush")
        set => this.SetProperty("TrailBrush", value)
    }

    ScaleBrush {
        get => this.GetProperty("ScaleBrush")
        set => this.SetProperty("ScaleBrush", value)
    }

    NeedleBrush {
        get => this.GetProperty("NeedleBrush")
        set => this.SetProperty("NeedleBrush", value)
    }

    OnValueChanged(callback) => this.OnEvent("ValueChanged", callback)
}

; =========================================================================
; CtkCtrl.RangeSelector
; =========================================================================
; Dual-thumb slider for selecting a min/max range.
; No AHK v2 equivalent - standard Slider has only one thumb.
;
; XAML: <ctk:RangeSelector x:Name="Range"
;                          Minimum="0" Maximum="100"
;                          RangeStart="20" RangeEnd="80"
;                          StepFrequency="1"/>

class CtkCtrl_RangeSelector extends WinUI3Ctrl {
    Minimum {
        get => this.GetProperty("Minimum")
        set => this.SetProperty("Minimum", value)
    }

    Maximum {
        get => this.GetProperty("Maximum")
        set => this.SetProperty("Maximum", value)
    }

    RangeStart {
        get => this.GetProperty("RangeStart")
        set => this.SetProperty("RangeStart", value)
    }

    RangeEnd {
        get => this.GetProperty("RangeEnd")
        set => this.SetProperty("RangeEnd", value)
    }

    StepFrequency {
        get => this.GetProperty("StepFrequency")
        set => this.SetProperty("StepFrequency", value)
    }

    IsDragging {
        get => this.GetProperty("IsDragging")
    }

    OnValueChanged(callback) => this.OnEvent("ValueChanged", callback)
    OnThumbDragStarted(callback) => this.OnEvent("ThumbDragStarted", callback)
    OnThumbDragCompleted(callback) => this.OnEvent("ThumbDragCompleted", callback)
}

; =========================================================================
; CtkCtrl.ImageCropper
; =========================================================================
; Interactive image cropping with drag handles and aspect ratio lock.
; No AHK v2 equivalent - would require GDI+ and complex mouse handling.
;
; XAML: <ctk:ImageCropper x:Name="Cropper"
;                         CropShape="Rectangular"
;                         AspectRatio="1.777"/>

class CtkCtrl_ImageCropper extends WinUI3Ctrl {
    ; CropShape: "Rectangular" (0), "Circular" (1)
    CropShape {
        get => this.GetProperty("CropShape")
        set => this.SetProperty("CropShape", value)
    }

    AspectRatio {
        get => this.GetProperty("AspectRatio")
        set => this.SetProperty("AspectRatio", value)
    }

    ; ThumbPlacement: "All" (0), "Corners" (1)
    ThumbPlacement {
        get => this.GetProperty("ThumbPlacement")
        set => this.SetProperty("ThumbPlacement", value)
    }

    ; CroppedRegion - read-only Rect of the crop area
    CroppedRegion {
        get => this.GetProperty("CroppedRegion")
    }

    ; Reset crop to full image
    Reset() {
        try this._com.Reset()
        return this
    }
}

; =========================================================================
; CtkCtrl.ContentSizer
; =========================================================================
; Draggable sizer that resizes an adjacent control.
; No AHK v2 equivalent - AHK has no splitter/sizer controls.
;
; XAML: <Grid ColumnDefinitions="*,Auto,*">
;           <Border Grid.Column="0">...</Border>
;           <ctk:ContentSizer x:Name="Sizer" Grid.Column="1"
;                             TargetControl="{Binding ElementName=LeftPanel}"/>
;           <Border Grid.Column="2">...</Border>
;       </Grid>

class CtkCtrl_ContentSizer extends WinUI3Ctrl {
    TargetControl {
        get => this.GetProperty("TargetControl")
        set => this.SetProperty("TargetControl", value)
    }

    IsDragging {
        get => this.GetProperty("IsDragging")
    }

    ; Orientation: "Vertical" (1), "Horizontal" (0)
    Orientation {
        get => this.GetProperty("Orientation")
        set => this.SetProperty("Orientation", value)
    }
}

; =========================================================================
; CtkCtrl.GridSplitter
; =========================================================================
; Splitter bar for Grid rows/columns (like WinForms SplitContainer).
; No AHK v2 equivalent.
;
; XAML: <ctk:GridSplitter x:Name="Splitter" Grid.Column="1"
;                         Width="16" ResizeBehavior="BasedOnAlignment"
;                         ResizeDirection="Auto"/>

class CtkCtrl_GridSplitter extends WinUI3Ctrl {
    ; ResizeDirection: "Auto" (0), "Columns" (1), "Rows" (2)
    ResizeDirection {
        get => this.GetProperty("ResizeDirection")
        set => this.SetProperty("ResizeDirection", value)
    }

    ; ResizeBehavior: "BasedOnAlignment" (0), "CurrentAndNext" (1), "PreviousAndCurrent" (2), "PreviousAndNext" (3)
    ResizeBehavior {
        get => this.GetProperty("ResizeBehavior")
        set => this.SetProperty("ResizeBehavior", value)
    }

    ; GripperCursor type
    CursorBehavior {
        get => this.GetProperty("CursorBehavior")
        set => this.SetProperty("CursorBehavior", value)
    }
}

; =========================================================================
; Factory: WrapControl()
; =========================================================================
; Wraps a COM object or WinUI3.Element in the appropriate typed class.
;
; Usage with WinUI3.Window:
;   el := win.GetElement("MyInfoBar")
;   infoBar := WrapControl(el._com, el._win, "InfoBar")
;
; Usage with BasicXamlGui (direct WinRT FindName):
;   comObj := xg['MyInfoBar']
;   infoBar := WrapControl(comObj, "", "InfoBar")

WrapControl(comObj, win, controlType) {
    if !comObj
        return ""

    switch controlType {
        ; Built-in WinUI3 controls
        case "InfoBar":              return WinUI3Ctrl_InfoBar(comObj, win)
        case "ContentDialog":        return WinUI3Ctrl_ContentDialog(comObj, win)
        case "NumberBox":            return WinUI3Ctrl_NumberBox(comObj, win)
        case "ColorPicker":          return WinUI3Ctrl_ColorPicker(comObj, win)
        case "NavigationView":       return WinUI3Ctrl_NavigationView(comObj, win)
        case "TabView":              return WinUI3Ctrl_TabView(comObj, win)
        case "Expander":             return WinUI3Ctrl_Expander(comObj, win)
        case "RatingControl":        return WinUI3Ctrl_RatingControl(comObj, win)
        case "CalendarDatePicker":   return WinUI3Ctrl_CalendarDatePicker(comObj, win)
        case "ProgressRing":         return WinUI3Ctrl_ProgressRing(comObj, win)
        ; Community Toolkit controls
        case "SettingsCard":         return CtkCtrl_SettingsCard(comObj, win)
        case "SettingsExpander":     return CtkCtrl_SettingsExpander(comObj, win)
        case "Segmented":            return CtkCtrl_Segmented(comObj, win)
        case "TokenizingTextBox":    return CtkCtrl_TokenizingTextBox(comObj, win)
        case "RadialGauge":          return CtkCtrl_RadialGauge(comObj, win)
        case "RangeSelector":        return CtkCtrl_RangeSelector(comObj, win)
        case "ImageCropper":         return CtkCtrl_ImageCropper(comObj, win)
        case "ContentSizer":         return CtkCtrl_ContentSizer(comObj, win)
        case "GridSplitter":         return CtkCtrl_GridSplitter(comObj, win)
        default:                     return WinUI3Ctrl(comObj, win)
    }
}
