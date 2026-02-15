#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

class Theme {
    static Presets := Map(
        "Dark", Map(
            "bg", 0x202020,
            "bgAlt", 0x2D2D2D,
            "bgHover", 0x3D3D3D,
            "bgPressed", 0x4D4D4D,
            "fg", 0xFFFFFF,
            "fgDim", 0x999999,
            "fgDisabled", 0x666666,
            "accent", 0x0078D4,
            "accentHover", 0x1084D8,
            "accentPressed", 0x006CBE,
            "border", 0x3D3D3D,
            "borderFocus", 0x0078D4,
            "error", 0xE81123,
            "warning", 0xFFB900,
            "success", 0x107C10,
            "info", 0x0078D4
        ),
        "Light", Map(
            "bg", 0xF3F3F3,
            "bgAlt", 0xFFFFFF,
            "bgHover", 0xE5E5E5,
            "bgPressed", 0xD0D0D0,
            "fg", 0x1A1A1A,
            "fgDim", 0x666666,
            "fgDisabled", 0x999999,
            "accent", 0x0078D4,
            "accentHover", 0x1084D8,
            "accentPressed", 0x006CBE,
            "border", 0xD0D0D0,
            "borderFocus", 0x0078D4,
            "error", 0xE81123,
            "warning", 0xFFB900,
            "success", 0x107C10,
            "info", 0x0078D4
        ),
        "HighContrast", Map(
            "bg", 0x000000,
            "bgAlt", 0x1A1A1A,
            "bgHover", 0x333333,
            "bgPressed", 0x4D4D4D,
            "fg", 0xFFFFFF,
            "fgDim", 0xCCCCCC,
            "fgDisabled", 0x808080,
            "accent", 0x00FFFF,
            "accentHover", 0x33FFFF,
            "accentPressed", 0x00CCCC,
            "border", 0xFFFFFF,
            "borderFocus", 0x00FFFF,
            "error", 0xFF0000,
            "warning", 0xFFFF00,
            "success", 0x00FF00,
            "info", 0x00FFFF
        )
    )
    
    static _current := "Dark"
    static _colors := Map()
    static _onChangeCallbacks := []
    
    static __New() {
        Theme._colors := Theme.Presets["Dark"].Clone()
    }
    
    static Current {
        get => Theme._current
        set {
            if Theme.Presets.Has(value) {
                Theme._current := value
                Theme._colors := Theme.Presets[value].Clone()
                Theme.NotifyChange()
            }
        }
    }
    
    static IsDark => Theme._current = "Dark" || Theme._current = "HighContrast"
    
    static Get(key) {
        return Theme._colors.Has(key) ? Theme._colors[key] : 0
    }
    
    static GetHex(key) {
        return Format("{:06X}", Theme.Get(key))
    }
    
    static GetRGB(key) {
        color := Theme.Get(key)
        return Map(
            "r", (color >> 16) & 0xFF,
            "g", (color >> 8) & 0xFF,
            "b", color & 0xFF
        )
    }
    
    static Set(key, value) {
        Theme._colors[key] := value
        Theme.NotifyChange()
    }
    
    static SetMultiple(colors) {
        for key, value in colors
            Theme._colors[key] := value
        Theme.NotifyChange()
    }
    
    static Reset() {
        Theme._colors := Theme.Presets[Theme._current].Clone()
        Theme.NotifyChange()
    }
    
    static OnChange(callback) {
        Theme._onChangeCallbacks.Push(callback)
    }
    
    static NotifyChange() {
        for callback in Theme._onChangeCallbacks
            callback()
    }
    
    static Auto() {
        try {
            regValue := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
            Theme.Current := regValue = 0 ? "Dark" : "Light"
        }
    }
    
    static GetSystemAccentColor() {
        try {
            return RegRead("HKCU\SOFTWARE\Microsoft\Windows\DWM", "AccentColor")
        }
        return 0x0078D4
    }
    
    static ApplySystemAccent() {
        accent := Theme.GetSystemAccentColor()
        Theme.Set("accent", accent)
        r := (accent >> 16) & 0xFF
        g := (accent >> 8) & 0xFF
        b := accent & 0xFF
        hoverR := Min(r + 12, 255)
        hoverG := Min(g + 12, 255)
        hoverB := Min(b + 12, 255)
        Theme.Set("accentHover", (hoverR << 16) | (hoverG << 8) | hoverB)
        pressedR := Max(r - 10, 0)
        pressedG := Max(g - 10, 0)
        pressedB := Max(b - 10, 0)
        Theme.Set("accentPressed", (pressedR << 16) | (pressedG << 8) | pressedB)
    }
    
    static CreateCustom(name, baseTheme := "Dark", overrides := Map()) {
        if !Theme.Presets.Has(baseTheme)
            return false
        newTheme := Theme.Presets[baseTheme].Clone()
        for key, value in overrides
            newTheme[key] := value
        Theme.Presets[name] := newTheme
        return true
    }
    
    static Export() {
        result := "{"
        isFirst := true
        for key, value in Theme._colors {
            if !isFirst
                result .= ","
            result .= "`n  `"" key "`": `"" Format("0x{:06X}", value) "`""
            isFirst := false
        }
        result .= "`n}"
        return result
    }
    
    static Import(jsonStr) {
        jsonStr := Trim(jsonStr, " `t`n`r{}")
        for pair in StrSplit(jsonStr, ",") {
            pair := Trim(pair, " `t`n`r")
            if RegExMatch(pair, "`"(\w+)`"\s*:\s*`"?(0x[0-9A-Fa-f]+|\d+)`"?", &match) {
                key := match[1]
                value := match[2]
                if SubStr(value, 1, 2) = "0x"
                    value := Integer(value)
                Theme._colors[key] := value
            }
        }
        Theme.NotifyChange()
    }
}
