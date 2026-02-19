#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include Lib\BasicXamlGui.ahk

; ============================================================================
; WinUI3 Nexus — Universal Command Palette
; ============================================================================
;
;   Ctrl+Space ......... summon / dismiss
;   Escape ............. clear query, then dismiss
;   Tab ................ cycle modes (> @ ?)
;   Up / Down .......... navigate results
;   Enter .............. execute selected item
;
;   (no prefix) ........ search apps + commands + windows + auto-calc
;   > .................. window switcher
;   @ .................. clipboard history
;   ? .................. web search
;   #RRGGBB ............ color swatch + copy hex
;   https://... ........ open URL
;   math expr .......... live calculator

; --- WinRT bootstrap ---
try UseWindowsAppRuntime('1.6')
catch as e {
    MsgBox("Windows App Runtime 1.6 required.`n" e.Message, "Nexus", "Icon!")
    ExitApp()
}
DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

; ============================================================================
; Design Tokens
; ============================================================================

; --- Palette (GitHub-dark inspired) ---
BG_DEEP    := "#0D1117"    ; deepest layer
BG_SURFACE := "#161B22"    ; card / panel surface
BG_HOVER   := "#1C2333"    ; hover tint
BG_ACTIVE  := "#21283B"    ; active / selected
BORDER_SUB := "#30363D"    ; subtle borders
TX_PRIMARY := "#E6EDF3"    ; main text
TX_SECOND  := "#8B949E"    ; secondary text
TX_TERTIA  := "#484F58"    ; tertiary / hints
AC_BLUE    := "#58A6FF"
AC_GREEN   := "#3FB950"
AC_ORANGE  := "#D29922"
AC_RED     := "#F85149"
AC_PURPLE  := "#BC8CFF"
AC_CYAN    := "#39D2C0"

; --- Limits ---
MAX_RESULTS := 9
MAX_CLIP    := 25

; ============================================================================
; State
; ============================================================================

global searchText     := ""
global selectedIdx    := 0
global currentResults := []
global nexusVisible   := false
global cursorOn       := true
global appCache       := []
global clipHistory    := []
global nxGui          := ""
global ih             := ""
global XR             := ""

; --- System commands ---
global sysCommands := [
    {name: "Lock Screen",      desc: "Lock workstation",           icon: "Contact",  color: AC_RED,    action: "lock"},
    {name: "Sleep",            desc: "Suspend to RAM",             icon: "Clock",    color: AC_PURPLE, action: "sleep"},
    {name: "Shutdown",         desc: "Power off",                  icon: "Cancel",   color: AC_RED,    action: "shutdown"},
    {name: "Restart",          desc: "Reboot",                     icon: "Refresh",  color: AC_ORANGE, action: "restart"},
    {name: "Empty Recycle Bin",desc: "Permanently delete files",   icon: "Delete",   color: AC_RED,    action: "recycle"},
    {name: "Screenshot",       desc: "Capture screen to clipboard",icon: "Camera",   color: AC_BLUE,   action: "screenshot"},
    {name: "Settings",         desc: "Open Windows Settings",      icon: "Setting",  color: AC_CYAN,   action: "settings"},
    {name: "Task Manager",     desc: "Open Task Manager",          icon: "Manage",   color: AC_GREEN,  action: "taskmgr"},
    {name: "File Explorer",    desc: "Open Explorer",              icon: "Folder",   color: AC_ORANGE, action: "explorer"},
    {name: "Notepad",          desc: "Open Notepad",               icon: "Edit",     color: AC_BLUE,   action: "notepad"},
    {name: "Run Dialog",       desc: "Open Run (Win+R)",           icon: "Play",     color: AC_GREEN,  action: "run"},
]

; ============================================================================
; Helpers
; ============================================================================

XmlEsc(text) {
    text := StrReplace(text, "&", "&amp;")
    text := StrReplace(text, "<", "&lt;")
    text := StrReplace(text, ">", "&gt;")
    text := StrReplace(text, "'", "&apos;")
    text := StrReplace(text, '"', "&quot;")
    return text
}

Trunc(text, n := 52) => StrLen(text) > n ? SubStr(text, 1, n - 1) Chr(0x2026) : text ; ellipsis

MakeBrush(color) {
    static c := Map()
    if c.Has(color)
        return c[color]
    b := XR.Load('<SolidColorBrush xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Color="' color '"/>')
    c[color] := b
    return b
}

FuzzyScore(needle, haystack) {
    n := StrLower(needle), h := StrLower(haystack)
    if SubStr(h, 1, StrLen(n)) = n
        return 200
    if InStr(h, n)
        return 150 - StrLen(h)
    ni := 1, s := 0
    for ch in StrSplit(h) {
        if ni <= StrLen(n) && ch = SubStr(n, ni, 1)
            ni++, s += 10
    }
    return ni > StrLen(n) ? s : 0
}

EvalMath(expr) {
    clean := RegExReplace(expr, "[^0-9\+\-\*\/\.\(\)\s\^%]", "")
    if clean != expr || Trim(clean) = ""
        return ""
    jsExpr := StrReplace(clean, "^", "**")
    try {
        doc := ComObject("htmlfile")
        doc.open()
        doc.write('<script>var r;try{r=eval("' jsExpr '")}catch(e){r="ERR"};document.title=String(r)</script>')
        doc.close()
        r := doc.title
        return (r = "ERR" || r = "undefined" || r = "Infinity" || r = "NaN") ? "" : r
    }
    return ""
}

IsMathExpr(t)  => RegExMatch(t, "^\s*[\d\(]") && RegExMatch(t, "[\+\-\*\/\^\%]")
IsHexColor(t)  => RegExMatch(t, "^#[0-9A-Fa-f]{6}$")
IsURL(t)       => RegExMatch(t, "^https?://")

; ============================================================================
; Data Sources
; ============================================================================

ScanStartMenu() {
    apps := []
    for dir in ["C:\ProgramData\Microsoft\Windows\Start Menu\Programs", A_StartMenu "\Programs"] {
        try Loop Files dir "\*.lnk", "R" {
            name := RegExReplace(A_LoopFileName, "\.lnk$", "")
            if RegExMatch(name, "i)Uninstall|Help|README|Website")
                continue
            apps.Push({name: name, path: A_LoopFileFullPath})
        }
    }
    return apps
}

GetOpenWindows() {
    wins := [], my := nxGui.hwnd
    for hwnd in WinGetList() {
        try {
            t := WinGetTitle(hwnd)
            if !t || t = "Program Manager"
                continue
            s := WinGetStyle(hwnd), ex := WinGetExStyle(hwnd)
            if !(s & 0x10000000) || (ex & 0x80)
                continue
            if DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr") = my
                continue
            wins.Push({title: t, hwnd: hwnd, class: WinGetClass(hwnd)})
        }
    }
    return wins
}

; ============================================================================
; Build GUI
; ============================================================================

nxGui := BasicXamlGui('-Caption +AlwaysOnTop +ToolWindow', 'Nexus')

; DWM: acrylic, dark title, rounded corners
NumPut('int', -1, 'int', -1, 'int', -1, 'int', -1, mg := Buffer(16))
DllCall("dwmapi\DwmExtendFrameIntoClientArea", 'ptr', nxGui.hwnd, 'ptr', mg, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', nxGui.hwnd, 'uint', 38, 'int*', 3, 'int', 4, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', nxGui.hwnd, 'uint', 20, 'int*', 1, 'int', 4)
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', nxGui.hwnd, 'uint', 33, 'int*', 2, 'int', 4)
nxGui.BackColor := '0D1117'

; ============================================================================
; Main XAML
; ============================================================================

xaml := "
(
<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
      xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
      Background='Transparent'>

    <Border Background='#F2161B22' CornerRadius='14'
            BorderBrush='#30363D' BorderThickness='1'>
        <Grid RowDefinitions='Auto,Auto,*,Auto'>

            <!-- Branding strip -->
            <Border Grid.Row='0' Padding='18,11,18,0'>
                <Grid ColumnDefinitions='Auto,*,Auto'>
                    <TextBlock Text='Nexus' FontSize='11' FontWeight='SemiBold'
                               Foreground='#484F58' VerticalAlignment='Center'/>
                    <Border Grid.Column='2' Background='#10FFFFFF' CornerRadius='5'
                            Padding='6,2' VerticalAlignment='Center'>
                        <TextBlock Text='Ctrl+Space' FontSize='9'
                                   Foreground='#484F58' FontFamily='Cascadia Mono'/>
                    </Border>
                </Grid>
            </Border>

            <!-- Search bar -->
            <Border Grid.Row='1' x:Name='SearchBorder' Background='#0D1117'
                    CornerRadius='10' Margin='12,8,12,6' Padding='14,11'
                    BorderBrush='#58A6FF' BorderThickness='1'>
                <Grid ColumnDefinitions='Auto,*,Auto'>
                    <SymbolIcon Symbol='Find' Foreground='#58A6FF'
                                Margin='0,0,10,0' VerticalAlignment='Center'/>
                    <TextBlock x:Name='SearchText' Grid.Column='1'
                               Text='Search apps, commands, math...'
                               FontSize='15' Foreground='#484F58'
                               VerticalAlignment='Center'/>
                    <Border x:Name='ModeBox' Grid.Column='2' CornerRadius='6'
                            Padding='8,3' Visibility='Collapsed'
                            VerticalAlignment='Center' Background='#1558A6FF'>
                        <TextBlock x:Name='ModeTag' Text='' FontSize='9'
                                   FontWeight='Bold' FontFamily='Cascadia Mono'
                                   Foreground='#58A6FF'/>
                    </Border>
                </Grid>
            </Border>

            <!-- Results -->
            <ScrollViewer Grid.Row='2' VerticalScrollBarVisibility='Auto'
                          Padding='0'>
                <StackPanel x:Name='ResultsList' Spacing='1'
                            Padding='10,2,10,6'/>
            </ScrollViewer>

            <!-- Bottom bar with keycaps -->
            <Border Grid.Row='3' Background='#0D1117' Padding='14,8'
                    CornerRadius='0,0,14,14'
                    BorderBrush='#20FFFFFF' BorderThickness='0,1,0,0'>
                <Grid ColumnDefinitions='*,Auto'>
                    <StackPanel Orientation='Horizontal' Spacing='3'
                                VerticalAlignment='Center'>
                        <Border Background='#15FFFFFF' CornerRadius='4'
                                Padding='5,2'>
                            <TextBlock Text='↑↓' FontSize='10'
                                       Foreground='#8B949E'
                                       FontFamily='Cascadia Mono'/>
                        </Border>
                        <TextBlock Text='Navigate' FontSize='10'
                                   Foreground='#484F58' Margin='2,0,10,0'
                                   VerticalAlignment='Center'/>
                        <Border Background='#15FFFFFF' CornerRadius='4'
                                Padding='5,2'>
                            <TextBlock Text='⏎' FontSize='10'
                                       Foreground='#8B949E'/>
                        </Border>
                        <TextBlock Text='Open' FontSize='10'
                                   Foreground='#484F58' Margin='2,0,10,0'
                                   VerticalAlignment='Center'/>
                        <Border Background='#15FFFFFF' CornerRadius='4'
                                Padding='5,2'>
                            <TextBlock Text='Tab' FontSize='9'
                                       Foreground='#8B949E'
                                       FontFamily='Cascadia Mono'/>
                        </Border>
                        <TextBlock Text='Mode' FontSize='10'
                                   Foreground='#484F58' Margin='2,0,10,0'
                                   VerticalAlignment='Center'/>
                        <Border Background='#15FFFFFF' CornerRadius='4'
                                Padding='5,2'>
                            <TextBlock Text='Esc' FontSize='9'
                                       Foreground='#8B949E'
                                       FontFamily='Cascadia Mono'/>
                        </Border>
                        <TextBlock Text='Close' FontSize='10'
                                   Foreground='#484F58' Margin='2,0,0,0'
                                   VerticalAlignment='Center'/>
                    </StackPanel>
                    <TextBlock x:Name='ResultCount' Grid.Column='1' Text=''
                               FontSize='10' Foreground='#484F58'
                               FontFamily='Cascadia Mono'
                               VerticalAlignment='Center'/>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Grid>
)"

XR := WinRT('Microsoft.UI.Xaml.Markup.XamlReader')
nxGui.Content := XR.Load(xaml)
try nxGui.Content.RequestedTheme := 2

; ============================================================================
; Card Builders (dynamic XAML)
; ============================================================================

; Standard result card — icon badge + title + desc + optional enter hint
BuildCard(icon, title, desc, accent, isSel := false) {
    ; Outer container
    bg := isSel ? "#18" SubStr(accent, 2) : "Transparent"
    bd := isSel ? "#30" SubStr(accent, 2) : "Transparent"
    bw := isSel ? "1" : "0"

    ; Icon badge colors
    ibg := "#15" SubStr(accent, 2)

    t := XmlEsc(Trunc(title, 48))
    d := XmlEsc(Trunc(desc, 58))

    ; Enter hint visibility
    eVis := isSel ? "Visible" : "Collapsed"

    return XR.Load("
    (
    <Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            Background='" bg "' CornerRadius='10' Padding='10,7'
            BorderBrush='" bd "' BorderThickness='" bw "'>
        <Grid ColumnDefinitions='Auto,*,Auto'>
            <Border Width='32' Height='32' CornerRadius='8'
                    Background='" ibg "' Margin='0,0,12,0'
                    VerticalAlignment='Center'>
                <SymbolIcon Symbol='" icon "' Foreground='" accent "' />
            </Border>
            <StackPanel Grid.Column='1' VerticalAlignment='Center' Spacing='1'>
                <TextBlock Text='" t "' FontSize='13' Foreground='#E6EDF3'/>
                <TextBlock Text='" d "' FontSize='11' Foreground='#8B949E'/>
            </StackPanel>
            <Border Grid.Column='2' Background='#12FFFFFF' CornerRadius='5'
                    Padding='6,3' VerticalAlignment='Center'
                    Visibility='" eVis "'>
                <TextBlock Text='⏎' FontSize='11' Foreground='#8B949E'/>
            </Border>
        </Grid>
    </Border>
    )")
}

; Calculator card — shows big result on right
BuildCalcCard(expr, result, isSel := false) {
    bg := isSel ? "#18" SubStr(AC_GREEN, 2) : "Transparent"
    bd := isSel ? "#30" SubStr(AC_GREEN, 2) : "Transparent"
    bw := isSel ? "1" : "0"
    ibg := "#15" SubStr(AC_GREEN, 2)
    return XR.Load("
    (
    <Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            Background='" bg "' CornerRadius='10' Padding='10,7'
            BorderBrush='" bd "' BorderThickness='" bw "'>
        <Grid ColumnDefinitions='Auto,*,Auto'>
            <Border Width='32' Height='32' CornerRadius='8'
                    Background='" ibg "' Margin='0,0,12,0'
                    VerticalAlignment='Center'>
                <SymbolIcon Symbol='Calculator' Foreground='" AC_GREEN "'/>
            </Border>
            <StackPanel Grid.Column='1' VerticalAlignment='Center' Spacing='1'>
                <TextBlock Text='" XmlEsc(Trunc(expr, 30)) "' FontSize='13'
                           Foreground='#E6EDF3'/>
                <TextBlock Text='Enter to copy result' FontSize='11'
                           Foreground='#8B949E'/>
            </StackPanel>
            <TextBlock Grid.Column='2' Text='= " XmlEsc(String(result)) "'
                       FontSize='24' FontWeight='Bold' Foreground='" AC_GREEN "'
                       FontFamily='Cascadia Mono' VerticalAlignment='Center'
                       Margin='14,0,4,0'/>
        </Grid>
    </Border>
    )")
}

; Color swatch card
BuildColorCard(hex, isSel := false) {
    bg := isSel ? "#12FFFFFF" : "Transparent"
    bd := isSel ? hex : "Transparent"
    bw := isSel ? "1" : "0"
    return XR.Load("
    (
    <Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            Background='" bg "' CornerRadius='10' Padding='10,7'
            BorderBrush='" bd "' BorderThickness='" bw "'>
        <Grid ColumnDefinitions='Auto,*,Auto'>
            <Border Width='32' Height='32' CornerRadius='8' Background='" hex "'
                    Margin='0,0,12,0' VerticalAlignment='Center'
                    BorderBrush='#20FFFFFF' BorderThickness='1'/>
            <StackPanel Grid.Column='1' VerticalAlignment='Center' Spacing='1'>
                <TextBlock Text='" XmlEsc(hex) "' FontSize='14'
                           Foreground='#E6EDF3' FontFamily='Cascadia Mono'/>
                <TextBlock Text='Enter to copy hex code' FontSize='11'
                           Foreground='#8B949E'/>
            </StackPanel>
            <Border Grid.Column='2' Background='#12FFFFFF' CornerRadius='5'
                    Padding='6,3' VerticalAlignment='Center'
                    Visibility='" (isSel ? "Visible" : "Collapsed") "'>
                <TextBlock Text='⏎' FontSize='11' Foreground='#8B949E'/>
            </Border>
        </Grid>
    </Border>
    )")
}

; Section divider
BuildDivider(label) {
    return XR.Load("
    (
    <TextBlock xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
               Text='" XmlEsc(label) "' FontSize='10' FontWeight='SemiBold'
               Foreground='#484F58' Margin='8,6,0,2'/>
    )")
}

; ============================================================================
; Search & Filter
; ============================================================================

FilterResults(query) {
    results := []

    ; --- Empty: show category hints ---
    if query = "" {
        results.Push({name: "Applications",    desc: "Search installed programs",       icon: "AllApps",    color: AC_BLUE,   type: "hint", prefix: ""})
        results.Push({name: "Calculator",      desc: "Type any math expression",        icon: "Calculator", color: AC_GREEN,  type: "hint", prefix: ""})
        results.Push({name: "Window Switcher", desc: "Prefix with > to list windows",   icon: "SwitchApps", color: AC_ORANGE, type: "hint", prefix: ">"})
        results.Push({name: "Clipboard",       desc: "Prefix with @ for clipboard",     icon: "Paste",      color: AC_PURPLE, type: "hint", prefix: "@"})
        results.Push({name: "System Commands", desc: "lock, sleep, shutdown, restart",   icon: "Setting",    color: AC_RED,    type: "hint", prefix: ""})
        results.Push({name: "Web Search",      desc: "Prefix with ? to search the web", icon: "Globe",      color: AC_CYAN,   type: "hint", prefix: "?"})
        return results
    }

    pf := SubStr(query, 1, 1)

    ; --- > Window mode ---
    if pf = ">" {
        wq := Trim(SubStr(query, 2))
        for w in GetOpenWindows() {
            if wq = "" || FuzzyScore(wq, w.title) > 0
                results.Push({name: w.title, desc: w.class, icon: "SwitchApps",
                              color: AC_ORANGE, type: "window", hwnd: w.hwnd})
            if results.Length >= MAX_RESULTS
                break
        }
        if !results.Length
            results.Push({name: "No windows match", desc: "Try different terms",
                          icon: "SwitchApps", color: TX_TERTIA, type: "none"})
        return results
    }

    ; --- @ Clipboard mode ---
    if pf = "@" {
        cq := Trim(SubStr(query, 2))
        for i, text in clipHistory {
            p := RegExReplace(text, "[\r\n\t]+", " ")
            if cq = "" || FuzzyScore(cq, p) > 0
                results.Push({name: Trunc(p, 52), desc: "#" i " — enter to paste",
                              icon: "Paste", color: AC_PURPLE, type: "clipboard",
                              clipText: text})
            if results.Length >= MAX_RESULTS
                break
        }
        if !results.Length
            results.Push({name: "Clipboard empty", desc: "Copy text to see it here",
                          icon: "Paste", color: TX_TERTIA, type: "none"})
        return results
    }

    ; --- ? Web search ---
    if pf = "?" {
        wq := Trim(SubStr(query, 2))
        if wq
            results.Push({name: wq, desc: "Search the web", icon: "Globe",
                          color: AC_CYAN, type: "websearch", query: wq})
        return results
    }

    ; --- Auto-detect: calculator ---
    if IsMathExpr(query) {
        mr := EvalMath(query)
        if mr != ""
            results.Push({name: query " = " mr, desc: "Calculator", icon: "Calculator",
                          color: AC_GREEN, type: "calc", result: mr})
    }

    ; --- Hex color ---
    if IsHexColor(query)
        results.Push({name: query, desc: "Color", icon: "FontColor",
                      color: query, type: "color", hex: query})

    ; --- URL ---
    if IsURL(query)
        results.Push({name: query, desc: "Open in browser", icon: "Globe",
                      color: AC_CYAN, type: "url", url: query})

    ; --- Apps (fuzzy sorted) ---
    scored := []
    for app in appCache {
        s := FuzzyScore(query, app.name)
        if s > 0
            scored.Push({app: app, score: s})
    }
    loop scored.Length - 1 {
        i := A_Index
        loop scored.Length - i {
            j := A_Index
            if scored[j].score < scored[j + 1].score {
                tmp := scored[j], scored[j] := scored[j + 1], scored[j + 1] := tmp
            }
        }
    }
    for s in scored {
        if results.Length >= MAX_RESULTS
            break
        results.Push({name: s.app.name, desc: "Application", icon: "AllApps",
                      color: AC_BLUE, type: "app", path: s.app.path})
    }

    ; --- System commands ---
    for cmd in sysCommands {
        if results.Length >= MAX_RESULTS
            break
        if FuzzyScore(query, cmd.name) > 0
            results.Push({name: cmd.name, desc: cmd.desc, icon: cmd.icon,
                          color: cmd.color, type: "command", action: cmd.action})
    }

    ; --- Open windows ---
    for w in GetOpenWindows() {
        if results.Length >= MAX_RESULTS
            break
        if FuzzyScore(query, w.title) > 0
            results.Push({name: w.title, desc: w.class, icon: "SwitchApps",
                          color: AC_ORANGE, type: "window", hwnd: w.hwnd})
    }

    ; --- Fallback: web search ---
    if !results.Length
        results.Push({name: query, desc: "Search the web", icon: "Globe",
                      color: AC_CYAN, type: "websearch", query: query})

    return results
}

; ============================================================================
; Display Update
; ============================================================================

UpdateDisplay() {
    global searchText, selectedIdx, currentResults, cursorOn

    try {
        ; --- Search text + cursor ---
        if searchText = "" {
            nxGui['SearchText'].Text := cursorOn ? "|  Search apps, commands, math..." : "   Search apps, commands, math..."
            nxGui['SearchText'].Foreground := MakeBrush(TX_TERTIA)
        } else {
            nxGui['SearchText'].Text := searchText (cursorOn ? "|" : "")
            nxGui['SearchText'].Foreground := MakeBrush(TX_PRIMARY)
        }

        ; --- Mode tag ---
        p := SubStr(searchText, 1, 1)
        showMode := true
        if p = ">" {
            nxGui['ModeTag'].Text := "WINDOWS"
            nxGui['ModeBox'].Background := MakeBrush("#15" SubStr(AC_ORANGE, 2))
            nxGui['ModeTag'].Foreground := MakeBrush(AC_ORANGE)
        } else if p = "@" {
            nxGui['ModeTag'].Text := "CLIPBOARD"
            nxGui['ModeBox'].Background := MakeBrush("#15" SubStr(AC_PURPLE, 2))
            nxGui['ModeTag'].Foreground := MakeBrush(AC_PURPLE)
        } else if p = "?" {
            nxGui['ModeTag'].Text := "WEB"
            nxGui['ModeBox'].Background := MakeBrush("#15" SubStr(AC_CYAN, 2))
            nxGui['ModeTag'].Foreground := MakeBrush(AC_CYAN)
        } else if searchText != "" && IsMathExpr(searchText) {
            nxGui['ModeTag'].Text := "CALC"
            nxGui['ModeBox'].Background := MakeBrush("#15" SubStr(AC_GREEN, 2))
            nxGui['ModeTag'].Foreground := MakeBrush(AC_GREEN)
        } else {
            showMode := false
        }
        nxGui['ModeBox'].Visibility := showMode ? 0 : 1

        ; --- Filter results ---
        currentResults := FilterResults(searchText)
        if selectedIdx >= currentResults.Length
            selectedIdx := Max(0, currentResults.Length - 1)

        ; --- Rebuild result cards ---
        rl := nxGui['ResultsList']
        rl.Children.Clear()

        for i, r in currentResults {
            sel := (i - 1) = selectedIdx

            if r.type = "calc" && r.HasProp("result")
                rl.Children.Append(BuildCalcCard(searchText, r.result, sel))
            else if r.type = "color" && r.HasProp("hex")
                rl.Children.Append(BuildColorCard(r.hex, sel))
            else
                rl.Children.Append(BuildCard(r.icon, r.name, r.desc, r.color, sel))
        }

        ; --- Result count ---
        nxGui['ResultCount'].Text := searchText != ""
            ? String(currentResults.Length) " result" (currentResults.Length != 1 ? "s" : "")
            : ""
    }
}

; ============================================================================
; Input Handling
; ============================================================================

ShowNexus() {
    global searchText, selectedIdx, nexusVisible, ih

    if nexusVisible {
        HideNexus()
        return
    }

    searchText := ""
    selectedIdx := 0
    nexusVisible := true

    ; Position: centered horizontally, upper-third vertically
    MonitorGetWorkArea(1, &mL, &mT, &mR, &mB)
    ww := 540, wh := 480
    nxGui.Show("x" (mL + (mR - mL - ww) // 2)
             " y" (mT + (mB - mT) // 4)
             " w" ww " h" wh " NoActivate")
    WinActivate("ahk_id " nxGui.hwnd)
    UpdateDisplay()

    SetTimer(BlinkCursor, 530)
    SetTimer(CheckFocus, 200)

    ih := InputHook("V")
    ih.OnChar := OnNxChar
    ih.KeyOpt("{All}", "N")
    ih.OnKeyDown := OnNxKeyDown
    ih.Start()
}

HideNexus() {
    global nexusVisible, ih
    nexusVisible := false
    if IsObject(ih)
        ih.Stop()
        ih := ""
    SetTimer(BlinkCursor, 0)
    SetTimer(CheckFocus, 0)
    nxGui.Hide()
}

OnNxChar(ih, char) {
    if !WinActive("ahk_id " nxGui.hwnd)
        return
    global searchText, selectedIdx
    searchText .= char
    selectedIdx := 0
    UpdateDisplay()
}

OnNxKeyDown(ih, vk, sc) {
    if !WinActive("ahk_id " nxGui.hwnd)
        return
    global searchText, selectedIdx, currentResults

    switch vk {
        case 8:   ; Backspace
            if searchText != "" {
                searchText := SubStr(searchText, 1, -1)
                selectedIdx := 0
                UpdateDisplay()
            }
        case 27:  ; Escape
            if searchText != "" {
                searchText := ""
                selectedIdx := 0
                UpdateDisplay()
            } else {
                HideNexus()
            }
        case 38:  ; Up
            if selectedIdx > 0
                selectedIdx--
            UpdateDisplay()
        case 40:  ; Down
            if selectedIdx < currentResults.Length - 1
                selectedIdx++
            UpdateDisplay()
        case 13:  ; Enter
            ExecuteSelected()
        case 9:   ; Tab
            CycleMode()
    }
}

BlinkCursor() {
    global cursorOn
    if !nexusVisible
        return
    cursorOn := !cursorOn
    try {
        if searchText = ""
            nxGui['SearchText'].Text := cursorOn ? "|  Search apps, commands, math..." : "   Search apps, commands, math..."
        else
            nxGui['SearchText'].Text := searchText (cursorOn ? "|" : "")
    }
}

CheckFocus() {
    if nexusVisible && !WinActive("ahk_id " nxGui.hwnd)
        HideNexus()
}

CycleMode() {
    global searchText, selectedIdx
    modes := [">", "@", "?", ""]
    cur := SubStr(searchText, 1, 1)
    idx := 0
    for i, m in modes
        if m = cur
            idx := i
    body := (cur = ">" || cur = "@" || cur = "?") ? SubStr(searchText, 2) : searchText
    searchText := modes[Mod(idx, modes.Length) + 1] body
    selectedIdx := 0
    UpdateDisplay()
}

; ============================================================================
; Actions
; ============================================================================

ExecuteSelected() {
    global selectedIdx, currentResults, searchText

    if selectedIdx < 0 || selectedIdx >= currentResults.Length
        return
    r := currentResults[selectedIdx + 1]

    switch r.type {
        case "app":
            HideNexus()
            try Run(r.path)
        case "window":
            HideNexus()
            try WinActivate("ahk_id " r.hwnd)
            try WinRestore("ahk_id " r.hwnd)
        case "command":
            HideNexus()
            RunSysCmd(r.action)
        case "calc":
            A_Clipboard := String(r.result)
            HideNexus()
        case "clipboard":
            A_Clipboard := r.clipText
            HideNexus()
            Sleep(50)
            Send("^v")
        case "websearch":
            HideNexus()
            try Run("https://www.google.com/search?q=" StrReplace(r.query, " ", "+"))
        case "url":
            HideNexus()
            try Run(r.url)
        case "color":
            A_Clipboard := r.hex
            HideNexus()
        case "hint":
            if r.HasProp("prefix") && r.prefix != "" {
                searchText := r.prefix
                selectedIdx := 0
                UpdateDisplay()
            }
    }
}

RunSysCmd(a) {
    switch a {
        case "lock":       DllCall("LockWorkStation")
        case "sleep":      DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
        case "shutdown":   Shutdown(1)
        case "restart":    Shutdown(2)
        case "recycle":    DllCall("Shell32\SHEmptyRecycleBin", "Ptr", 0, "Ptr", 0, "UInt", 0x7)
        case "screenshot": Send("#{PrintScreen}")
        case "settings":   Run("ms-settings:")
        case "taskmgr":    Run("taskmgr")
        case "explorer":   Run("explorer.exe")
        case "notepad":    Run("notepad")
        case "run":        Send("#r")
    }
}

; ============================================================================
; Clipboard Monitor
; ============================================================================

OnClipboardChange(OnClipChanged)
OnClipChanged(dataType) {
    if dataType != 1
        return
    global clipHistory
    text := A_Clipboard
    if !text || !StrLen(text)
        return
    loop clipHistory.Length
        if clipHistory[A_Index] = text {
            clipHistory.RemoveAt(A_Index)
            break
        }
    clipHistory.InsertAt(1, text)
    if clipHistory.Length > MAX_CLIP
        clipHistory.Pop()
}

; ============================================================================
; Boot
; ============================================================================

appCache := ScanStartMenu()
nxGui.OnEvent("Close", (*) => HideNexus())

^Space:: ShowNexus()
