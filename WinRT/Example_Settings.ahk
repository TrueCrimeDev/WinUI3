#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

#Include DWM.ahk
#Include Theme.ahk
#Include ModernWindow.ahk

class SettingsPanel extends ModernWindow {
    sections := Map()
    
    __New() {
        super.__New("Settings", "+MinimizeBox")
        Theme.Auto()
        this.SetDarkMode(Theme.IsDark)
        this.BuildUI()
        this.Show("w400 h500")
    }
    
    BuildUI() {
        this.gui.SetFont("s12 Bold", "Segoe UI")
        this.AddText("xm Section w360", "Settings")
        
        this.gui.SetFont("s9 Norm", "Segoe UI")
        this.AddText("xm w360 c" Format("{:06X}", ModernWindow.Theme["fgDim"]), "Customize your experience")
        
        this.AddSection("Appearance")
        
        this.themeLabel := this.AddText("xm y+10 w120", "Theme")
        this.themeDDL := this.AddDropDownList("x+10 yp-3 w200 Choose1", ["Dark", "Light", "High Contrast"])
        this.themeDDL.OnEvent("Change", this.OnThemeChange.Bind(this))
        
        this.accentLabel := this.AddText("xm y+15 w120", "Accent Color")
        this.accentBtn := this.AddButton("x+10 yp-3 w200 h26", "Use System Accent")
        this.accentBtn.OnEvent("Click", this.OnAccentClick.Bind(this))
        
        this.AddSection("Window Effects")
        
        this.backdropLabel := this.AddText("xm y+10 w120", "Backdrop")
        this.backdropDDL := this.AddDropDownList("x+10 yp-3 w200 Choose1", ["Mica", "Acrylic", "Tabbed", "None"])
        this.backdropDDL.OnEvent("Change", this.OnBackdropChange.Bind(this))
        
        this.cornerLabel := this.AddText("xm y+15 w120", "Corners")
        this.cornerDDL := this.AddDropDownList("x+10 yp-3 w200 Choose1", ["Round", "RoundSmall", "Square"])
        this.cornerDDL.OnEvent("Change", this.OnCornerChange.Bind(this))
        
        this.AddSection("Notifications")
        
        this.notifyChk := this.AddCheckbox("xm y+10 Checked", "Enable notifications")
        this.soundChk := this.AddCheckbox("xm y+10 Checked", "Play sounds")
        this.badgeChk := this.AddCheckbox("xm y+10", "Show badge on taskbar")
        
        this.AddSection("About")
        
        this.AddText("xm y+10 w360", "Windows 11 Modern GUI Framework")
        this.AddText("xm w360 c" Format("{:06X}", ModernWindow.Theme["fgDim"]), "Version 1.0.0 - Pure AHK v2 Implementation")
        this.AddText("xm w360 c" Format("{:06X}", ModernWindow.Theme["fgDim"]), "Uses DWM attributes for native Windows 11 styling")
        
        this.AddButton("xm y+30 w180 h32 Default", "Save Settings").OnEvent("Click", this.OnSave.Bind(this))
        this.AddButton("x+10 w180 h32", "Cancel").OnEvent("Click", (*) => this.gui.Hide())
    }
    
    AddSection(title) {
        this.gui.SetFont("s10 Bold", "Segoe UI")
        this.AddText("xm y+25 w360 c" Format("{:06X}", ModernWindow.Theme["accent"]), title)
        this.gui.SetFont("s9 Norm", "Segoe UI")
        separator := this.gui.AddProgress("xm y+5 w360 h1 Background" Format("{:06X}", ModernWindow.Theme["border"]))
        this.sections[title] := separator
    }
    
    OnThemeChange(*) {
        themeName := this.themeDDL.Text
        switch themeName {
            case "High Contrast":
                Theme.Current := "HighContrast"
            default:
                Theme.Current := themeName
        }
        this.SetDarkMode(Theme.IsDark)
        this.RefreshColors()
    }
    
    OnAccentClick(*) {
        Theme.ApplySystemAccent()
        MsgBox("System accent color applied!", "Settings", "Iconi")
    }
    
    OnBackdropChange(*) {
        this.SetBackdrop(this.backdropDDL.Text)
    }
    
    OnCornerChange(*) {
        cornerMap := Map("Round", "Round", "RoundSmall", "RoundSmall", "Square", "None")
        this.SetCorners(cornerMap[this.cornerDDL.Text])
    }
    
    OnSave(*) {
        MsgBox("Settings saved!", "Settings", "Iconi")
        this.gui.Hide()
    }
    
    RefreshColors() {
        bgColor := Theme.IsDark ? Format("{:06X}", ModernWindow.Theme["bg"]) : "F3F3F3"
        this.gui.BackColor := bgColor
    }
    
    OnClose() {
        ExitApp()
    }
}

SettingsPanel()
