#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include Lib\BasicXamlGui.ahk

; ============================================================================
; WinUI3 Nexus — Universal Command Palette
; ============================================================================
; A Raycast/Spotlight-style launcher built with AHK v2 + WinUI3 XAML Islands.
;
; Features:
;   App launcher ............ fuzzy search Start Menu programs
;   Live calculator ......... auto-detects math (2+2, 15*3.5, etc.)
;   Window switcher ......... > prefix or auto-match
;   Clipboard history ....... @ prefix, last 25 entries, paste on Enter
;   System commands ......... lock, sleep, shutdown, restart, recycle bin
;   Web search .............. ? prefix opens default browser
;   Color preview ........... type #RRGGBB to see swatch + copy
;   URL opener .............. type https://... to open in browser
;
; Hotkey: Alt+Space to summon/dismiss
;         Escape to clear search or dismiss
;         Tab to cycle modes (> @ ?)
;         Up/Down to navigate, Enter to execute

; --- WinRT Init ---
try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    MsgBox("Failed to load Windows App Runtime 1.6`n`n" e.Message, "Nexus", "Icon!")
    ExitApp()
}
DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

; --- Constants ---
MAX_RESULTS := 8
MAX_CLIP := 25
C_BLUE := "#4CC2FF", C_GREEN := "#2DB84D", C_ORANGE := "#FF8C00"
C_RED := "#E84040", C_PURPLE := "#8B5CF6", C_YELLOW := "#FFB900"

; --- State ---
global searchText := ""
global selectedIdx := 0
global currentResults := []
global nexusVisible := false
global cursorOn := true
global appCache := []
global clipHistory := []
global nxGui := ""
global ih := ""
global XR := ""

; --- System Commands ---
global sysCommands := [
    {name: "Lock Screen", desc: "Lock the workstation", icon: "Contact", color: C_RED, action: "lock"},
    {name: "Sleep", desc: "Put computer to sleep", icon: "Clock", color: C_PURPLE, action: "sleep"},
    {name: "Shutdown", desc: "Shut down the computer", icon: "Cancel", color: C_RED, action: "shutdown"},
    {name: "Restart", desc: "Restart the computer", icon: "Refresh", color: C_ORANGE, action: "restart"},
    {name: "Empty Recycle Bin", desc: "Permanently delete recycled files", icon: "Delete", color: C_RED, action: "recycle"},
    {name: "Screenshot", desc: "Capture screen to clipboard", icon: "Camera", color: C_BLUE, action: "screenshot"},
    {name: "Settings", desc: "Open Windows Settings", icon: "Setting", color: C_BLUE, action: "settings"},
    {name: "Task Manager", desc: "Open Task Manager", icon: "Manage", color: C_GREEN, action: "taskmgr"},
    {name: "File Explorer", desc: "Open File Explorer", icon: "Folder", color: C_YELLOW, action: "explorer"},
    {name: "Notepad", desc: "Open Notepad", icon: "Edit", color: C_BLUE, action: "notepad"},
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

Truncate(text, maxLen := 55) {
    if StrLen(text) > maxLen
        return SubStr(text, 1, maxLen - 3) "..."
    return text
}

MakeBrush(color) {
    static cache := Map()
    if cache.Has(color)
        return cache[color]
    b := XR.Load('<SolidColorBrush xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Color="' color '"/>')
    cache[color] := b
    return b
}

FuzzyScore(needle, haystack) {
    needle := StrLower(needle)
    haystack := StrLower(haystack)
    if SubStr(haystack, 1, StrLen(needle)) = needle
        return 200
    if InStr(haystack, needle)
        return 150 - StrLen(haystack)
    ni := 1, score := 0
    for c in StrSplit(haystack) {
        if ni <= StrLen(needle) && c = SubStr(needle, ni, 1)
            ni++, score += 10
    }
    return ni > StrLen(needle) ? score : 0
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
        result := doc.title
        if result = "ERR" || result = "undefined" || result = "Infinity" || result = "NaN"
            return ""
        return result
    }
    return ""
}

IsMathExpr(text) => RegExMatch(text, "^\s*[\d\(]") && RegExMatch(text, "[\+\-\*\/\^\%]")
IsHexColor(text) => RegExMatch(text, "^#[0-9A-Fa-f]{6}$")
IsURL(text) => RegExMatch(text, "^https?://")

; ============================================================================
; Data Sources
; ============================================================================

ScanStartMenu() {
    apps := []
    dirs := [
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs",
        A_StartMenu "\Programs"
    ]
    for dir in dirs {
        try {
            Loop Files dir "\*.lnk", "R" {
                name := RegExReplace(A_LoopFileName, "\.lnk$", "")
                if InStr(name, "Uninstall") || InStr(name, "Help") || InStr(name, "README")
                    continue
                apps.Push({name: name, path: A_LoopFileFullPath})
            }
        }
    }
    return apps
}

GetOpenWindows() {
    windows := []
    myHwnd := nxGui.hwnd
    for hwnd in WinGetList() {
        try {
            title := WinGetTitle(hwnd)
            if !title || title = "Program Manager"
                continue
            style := WinGetStyle(hwnd)
            exStyle := WinGetExStyle(hwnd)
            if !(style & 0x10000000) || (exStyle & 0x80)
                continue
            root := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")
            if root = myHwnd
                continue
            windows.Push({title: title, hwnd: hwnd, class: WinGetClass(hwnd)})
        }
    }
    return windows
}

; ============================================================================
; Build GUI
; ============================================================================

nxGui := BasicXamlGui('-Caption +AlwaysOnTop +ToolWindow', 'Nexus')

; Acrylic + dark + rounded
NumPut('int', -1, 'int', -1, 'int', -1, 'int', -1, m := Buffer(16))
DllCall("dwmapi\DwmExtendFrameIntoClientArea", 'ptr', nxGui.hwnd, 'ptr', m, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', nxGui.hwnd, 'uint', 38, 'int*', 3, 'int', 4, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', nxGui.hwnd, 'uint', 20, 'int*', 1, 'int', 4)
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', nxGui.hwnd, 'uint', 33, 'int*', 2, 'int', 4)
nxGui.BackColor := '0C0C1A'

xaml := "
(
<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
      xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
      Background='Transparent'>
    <Border Background='#DD0C0C1A' CornerRadius='16'>
        <Grid RowDefinitions='Auto,*,Auto'>

            <!-- Search Bar -->
            <Border Grid.Row='0' Background='#15FFFFFF' CornerRadius='12'
                    Margin='16,16,16,8' Padding='14,12'
                    BorderBrush='#304CC2FF' BorderThickness='1'>
                <Grid ColumnDefinitions='Auto,*,Auto'>
                    <SymbolIcon Symbol='Find' Foreground='#4CC2FF'
                                Margin='0,0,12,0' VerticalAlignment='Center'/>
                    <TextBlock x:Name='SearchText' Grid.Column='1'
                               Text='Type to search...' FontSize='16'
                               Foreground='#55FFFFFF' VerticalAlignment='Center'/>
                    <Border x:Name='ModeBox' Grid.Column='2' Background='#204CC2FF'
                            CornerRadius='6' Padding='8,3' Visibility='Collapsed'
                            VerticalAlignment='Center'>
                        <TextBlock x:Name='ModeTag' Text='' FontSize='10'
                                   Foreground='#4CC2FF' FontWeight='SemiBold'/>
                    </Border>
                </Grid>
            </Border>

            <!-- Results -->
            <ScrollViewer Grid.Row='1' VerticalScrollBarVisibility='Auto' Margin='8,0'>
                <StackPanel x:Name='ResultsList' Spacing='2' Padding='8,4,8,8'/>
            </ScrollViewer>

            <!-- Hint Bar -->
            <Border Grid.Row='2' Padding='14,8' CornerRadius='0,0,16,16'>
                <Grid ColumnDefinitions='*,Auto'>
                    <StackPanel Orientation='Horizontal' Spacing='12' VerticalAlignment='Center'>
                        <TextBlock Text='↑↓ Navigate' FontSize='10' Foreground='#33FFFFFF'/>
                        <TextBlock Text='⏎ Select' FontSize='10' Foreground='#33FFFFFF'/>
                        <TextBlock Text='Tab Mode' FontSize='10' Foreground='#33FFFFFF'/>
                        <TextBlock Text='Esc Close' FontSize='10' Foreground='#33FFFFFF'/>
                    </StackPanel>
                    <TextBlock x:Name='ResultCount' Grid.Column='1' Text=''
                               FontSize='10' Foreground='#33FFFFFF'
                               VerticalAlignment='Center' FontFamily='Cascadia Mono'/>
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
; Dynamic Card Builders
; ============================================================================

BuildCard(icon, title, desc, accent, isSel := false) {
    bg := isSel ? "#20" SubStr(accent, 2) : "#08FFFFFF"
    bdr := isSel ? accent : "Transparent"
    bw := isSel ? "2,0,0,0" : "0"
    t := XmlEsc(Truncate(title, 50))
    d := XmlEsc(Truncate(desc, 60))
    return XR.Load("
    (
    <Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            Background='" bg "' CornerRadius='8' Padding='12,9'
            BorderBrush='" bdr "' BorderThickness='" bw "'>
        <Grid ColumnDefinitions='Auto,*'>
            <SymbolIcon Symbol='" icon "' Foreground='" accent "'
                        Margin='0,0,12,0' VerticalAlignment='Center'/>
            <StackPanel Grid.Column='1' VerticalAlignment='Center'>
                <TextBlock Text='" t "' FontSize='13' Foreground='#EEFFFFFF'/>
                <TextBlock Text='" d "' FontSize='10' Foreground='#55FFFFFF' Margin='0,1,0,0'/>
            </StackPanel>
        </Grid>
    </Border>
    )")
}

BuildCalcCard(expr, result, isSel := false) {
    bg := isSel ? "#20" SubStr(C_GREEN, 2) : "#08FFFFFF"
    bdr := isSel ? C_GREEN : "Transparent"
    bw := isSel ? "2,0,0,0" : "0"
    return XR.Load("
    (
    <Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            Background='" bg "' CornerRadius='8' Padding='12,9'
            BorderBrush='" bdr "' BorderThickness='" bw "'>
        <Grid ColumnDefinitions='Auto,*,Auto'>
            <SymbolIcon Symbol='Calculator' Foreground='" C_GREEN "'
                        Margin='0,0,12,0' VerticalAlignment='Center'/>
            <StackPanel Grid.Column='1' VerticalAlignment='Center'>
                <TextBlock Text='" XmlEsc(expr) "' FontSize='13' Foreground='#EEFFFFFF'/>
                <TextBlock Text='Enter to copy result' FontSize='10'
                           Foreground='#55FFFFFF' Margin='0,1,0,0'/>
            </StackPanel>
            <TextBlock Grid.Column='2' Text='= " XmlEsc(String(result)) "' FontSize='22'
                       FontWeight='Bold' Foreground='" C_GREEN "' VerticalAlignment='Center'
                       FontFamily='Cascadia Mono' Margin='12,0,0,0'/>
        </Grid>
    </Border>
    )")
}

BuildColorCard(hex, isSel := false) {
    bg := isSel ? "#15FFFFFF" : "#08FFFFFF"
    bdr := isSel ? hex : "Transparent"
    bw := isSel ? "2,0,0,0" : "0"
    return XR.Load("
    (
    <Border xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
            Background='" bg "' CornerRadius='8' Padding='12,9'
            BorderBrush='" bdr "' BorderThickness='" bw "'>
        <Grid ColumnDefinitions='Auto,Auto,*'>
            <Border Width='28' Height='28' CornerRadius='14' Background='" hex "'
                    Margin='0,0,12,0' VerticalAlignment='Center'
                    BorderBrush='#30FFFFFF' BorderThickness='1'/>
            <StackPanel Grid.Column='1' VerticalAlignment='Center'>
                <TextBlock Text='" XmlEsc(hex) "' FontSize='14' Foreground='#EEFFFFFF'
                           FontFamily='Cascadia Mono'/>
                <TextBlock Text='Enter to copy hex' FontSize='10'
                           Foreground='#55FFFFFF' Margin='0,1,0,0'/>
            </StackPanel>
        </Grid>
    </Border>
    )")
}

; ============================================================================
; Search & Filter
; ============================================================================

FilterResults(query) {
    results := []

    if query = "" {
        results.Push({name: "Applications", desc: "Search installed apps", icon: "AllApps", color: C_BLUE, type: "hint", prefix: ""})
        results.Push({name: "Calculator", desc: "Type a math expression (2+2, 15*3.5)", icon: "Calculator", color: C_GREEN, type: "hint", prefix: ""})
        results.Push({name: "Window Switcher", desc: "Type > to list open windows", icon: "SwitchApps", color: C_ORANGE, type: "hint", prefix: ">"})
        results.Push({name: "Clipboard History", desc: "Type @ to browse clipboard", icon: "Paste", color: C_PURPLE, type: "hint", prefix: "@"})
        results.Push({name: "System Commands", desc: "lock, sleep, shutdown, restart...", icon: "Setting", color: C_RED, type: "hint", prefix: ""})
        results.Push({name: "Web Search", desc: "Type ? followed by your query", icon: "Globe", color: C_BLUE, type: "hint", prefix: "?"})
        return results
    }

    prefix := SubStr(query, 1, 1)

    ; --- Window mode ---
    if prefix = ">" {
        wq := Trim(SubStr(query, 2))
        for w in GetOpenWindows() {
            if wq = "" || FuzzyScore(wq, w.title) > 0
                results.Push({name: w.title, desc: "Window — " w.class, icon: "SwitchApps",
                              color: C_ORANGE, type: "window", hwnd: w.hwnd})
            if results.Length >= MAX_RESULTS
                break
        }
        if results.Length = 0
            results.Push({name: "No windows found", desc: "Try a different query", icon: "SwitchApps", color: "#555555", type: "none"})
        return results
    }

    ; --- Clipboard mode ---
    if prefix = "@" {
        cq := Trim(SubStr(query, 2))
        for i, text in clipHistory {
            preview := RegExReplace(text, "[\r\n\t]+", " ")
            if cq = "" || FuzzyScore(cq, preview) > 0
                results.Push({name: Truncate(preview, 55), desc: "Clip #" i " — Enter to paste",
                              icon: "Paste", color: C_PURPLE, type: "clipboard", clipText: text})
            if results.Length >= MAX_RESULTS
                break
        }
        if results.Length = 0
            results.Push({name: "No clipboard history", desc: "Copy text to see it here", icon: "Paste", color: "#555555", type: "none"})
        return results
    }

    ; --- Web search mode ---
    if prefix = "?" {
        wq := Trim(SubStr(query, 2))
        if wq
            results.Push({name: "Search: " wq, desc: "Open in default browser",
                          icon: "Globe", color: C_BLUE, type: "websearch", query: wq})
        return results
    }

    ; --- Auto-detect ---

    ; Math?
    if IsMathExpr(query) {
        mr := EvalMath(query)
        if mr != ""
            results.Push({name: query " = " mr, desc: "Calculator", icon: "Calculator",
                          color: C_GREEN, type: "calc", result: mr})
    }

    ; Hex color?
    if IsHexColor(query)
        results.Push({name: query, desc: "Color preview", icon: "FontColor",
                      color: query, type: "color", hex: query})

    ; URL?
    if IsURL(query)
        results.Push({name: query, desc: "Open URL in browser", icon: "Globe",
                      color: C_BLUE, type: "url", url: query})

    ; Apps (fuzzy scored + sorted)
    scored := []
    for app in appCache {
        s := FuzzyScore(query, app.name)
        if s > 0
            scored.Push({app: app, score: s})
    }
    ; Sort descending
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
                      color: C_BLUE, type: "app", path: s.app.path})
    }

    ; System commands
    for cmd in sysCommands {
        if results.Length >= MAX_RESULTS
            break
        if FuzzyScore(query, cmd.name) > 0
            results.Push({name: cmd.name, desc: cmd.desc, icon: cmd.icon,
                          color: cmd.color, type: "command", action: cmd.action})
    }

    ; Windows
    for w in GetOpenWindows() {
        if results.Length >= MAX_RESULTS
            break
        if FuzzyScore(query, w.title) > 0
            results.Push({name: w.title, desc: "Window — " w.class, icon: "SwitchApps",
                          color: C_ORANGE, type: "window", hwnd: w.hwnd})
    }

    ; Fallback: web search
    if results.Length = 0
        results.Push({name: "Search web: " query, desc: "Open in default browser",
                      icon: "Globe", color: C_BLUE, type: "websearch", query: query})

    return results
}

; ============================================================================
; Display
; ============================================================================

UpdateDisplay() {
    global searchText, selectedIdx, currentResults, cursorOn

    try {
        ; Search bar
        if searchText = "" {
            nxGui['SearchText'].Text := cursorOn ? "|  Type to search..." : "   Type to search..."
            nxGui['SearchText'].Foreground := MakeBrush("#44FFFFFF")
        } else {
            nxGui['SearchText'].Text := searchText (cursorOn ? "|" : "")
            nxGui['SearchText'].Foreground := MakeBrush("#FFFFFF")
        }

        ; Mode tag
        p := SubStr(searchText, 1, 1)
        if p = ">" {
            nxGui['ModeBox'].Visibility := 0
            nxGui['ModeTag'].Text := "WINDOWS"
        } else if p = "@" {
            nxGui['ModeBox'].Visibility := 0
            nxGui['ModeTag'].Text := "CLIPBOARD"
        } else if p = "?" {
            nxGui['ModeBox'].Visibility := 0
            nxGui['ModeTag'].Text := "WEB"
        } else if searchText != "" && IsMathExpr(searchText) {
            nxGui['ModeBox'].Visibility := 0
            nxGui['ModeTag'].Text := "CALC"
        } else {
            nxGui['ModeBox'].Visibility := 1  ; Collapsed
        }

        ; Filter
        currentResults := FilterResults(searchText)

        ; Clamp selection
        if selectedIdx >= currentResults.Length
            selectedIdx := Max(0, currentResults.Length - 1)

        ; Rebuild cards
        rl := nxGui['ResultsList']
        rl.Children.Clear()

        for i, r in currentResults {
            isSel := (i - 1) = selectedIdx
            card := ""

            if r.type = "calc" && r.HasProp("result")
                card := BuildCalcCard(searchText, r.result, isSel)
            else if r.type = "color" && r.HasProp("hex")
                card := BuildColorCard(r.hex, isSel)
            else
                card := BuildCard(r.icon, r.name, r.desc, r.color, isSel)

            rl.Children.Append(card)
        }

        ; Count
        nxGui['ResultCount'].Text := searchText != "" ? String(currentResults.Length) " results" : ""
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

    ; Center on primary monitor, upper third
    MonitorGetWorkArea(1, &mL, &mT, &mR, &mB)
    ww := 560, wh := 460
    wx := mL + (mR - mL - ww) // 2
    wy := mT + (mB - mT) // 4

    nxGui.Show("x" wx " y" wy " w" ww " h" wh " NoActivate")
    WinActivate("ahk_id " nxGui.hwnd)
    UpdateDisplay()

    SetTimer(BlinkCursor, 530)
    SetTimer(CheckFocus, 200)

    ; InputHook captures keyboard while palette is open
    ih := InputHook("V")
    ih.OnChar := OnNxChar
    ih.KeyOpt("{All}", "N")
    ih.OnKeyDown := OnNxKeyDown
    ih.Start()
}

HideNexus() {
    global nexusVisible, ih

    nexusVisible := false
    if IsObject(ih) {
        ih.Stop()
        ih := ""
    }
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
        case 8:  ; Backspace
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
        case 9:   ; Tab — cycle mode
            CycleMode()
    }
}

BlinkCursor() {
    global cursorOn, nexusVisible
    if !nexusVisible
        return
    cursorOn := !cursorOn
    try {
        if searchText = ""
            nxGui['SearchText'].Text := cursorOn ? "|  Type to search..." : "   Type to search..."
        else
            nxGui['SearchText'].Text := searchText (cursorOn ? "|" : "")
    }
}

CheckFocus() {
    global nexusVisible
    if nexusVisible && !WinActive("ahk_id " nxGui.hwnd)
        HideNexus()
}

CycleMode() {
    global searchText, selectedIdx
    modes := [">", "@", "?", ""]
    current := SubStr(searchText, 1, 1)
    idx := 0
    for i, m in modes {
        if m = current {
            idx := i
            break
        }
    }
    nextIdx := Mod(idx, modes.Length) + 1
    body := (current = ">" || current = "@" || current = "?") ? SubStr(searchText, 2) : searchText
    searchText := modes[nextIdx] body
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
            try {
                WinActivate("ahk_id " r.hwnd)
                WinRestore("ahk_id " r.hwnd)
            }
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

RunSysCmd(action) {
    switch action {
        case "lock":
            DllCall("LockWorkStation")
        case "sleep":
            DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
        case "shutdown":
            Shutdown(1)
        case "restart":
            Shutdown(2)
        case "recycle":
            DllCall("Shell32\SHEmptyRecycleBin", "Ptr", 0, "Ptr", 0, "UInt", 0x7)
        case "screenshot":
            Send("#{PrintScreen}")
        case "settings":
            Run("ms-settings:")
        case "taskmgr":
            Run("taskmgr")
        case "explorer":
            Run("explorer.exe")
        case "notepad":
            Run("notepad")
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
    if !text || StrLen(text) = 0
        return
    ; Remove duplicate
    loop clipHistory.Length {
        if clipHistory[A_Index] = text {
            clipHistory.RemoveAt(A_Index)
            break
        }
    }
    clipHistory.InsertAt(1, text)
    if clipHistory.Length > MAX_CLIP
        clipHistory.Pop()
}

; ============================================================================
; Startup
; ============================================================================

; Index Start Menu apps
appCache := ScanStartMenu()

; Prevent close from killing script
nxGui.OnEvent("Close", (*) => HideNexus())

; Global hotkey
!Space:: ShowNexus()
