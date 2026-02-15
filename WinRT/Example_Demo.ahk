#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

#Include DWM.ahk
#Include Theme.ahk
#Include ModernWindow.ahk

class DemoApp extends ModernWindow {
    __New() {
        super.__New("Windows 11 Modern GUI Demo", "+MinimizeBox")
        this.BuildUI()
        this.Show("w500 h820")
    }
    
    BuildUI() {
        this.gui.SetFont("s11", "Segoe UI")
        
        this.AddText("xm Section w460", "Windows 11 Modern GUI Base Class")
        this.gui.SetFont("s9", "Segoe UI")
        this.AddText("xm w460 c" Format("{:06X}", ModernWindow.Theme["fgDim"]), "Pure AHK v2 with DWM attributes - Mica, Dark Mode, Rounded Corners")
        
        this.AddText("xm y+20 Section w460", "Backdrop Style:")
        this.backdropDDL := this.AddDropDownList("xm w200 Choose1", ["Mica", "Acrylic", "Tabbed", "None"])
        this.backdropDDL.OnEvent("Change", this.OnBackdropChange.Bind(this))
        
        this.AddText("xm y+15 Section w460", "Corner Style:")
        this.cornerDDL := this.AddDropDownList("xm w200 Choose1", ["Round", "RoundSmall", "None", "Default"])
        this.cornerDDL.OnEvent("Change", this.OnCornerChange.Bind(this))
        
        this.darkModeChk := this.AddCheckbox("xm y+15 Checked", "Dark Mode")
        this.darkModeChk.OnEvent("Click", this.OnDarkModeToggle.Bind(this))
        
        this.AddText("xm y+20 Section w460", "Sample Controls:")
        
        this.AddText("xm y+10 w80", "Text Input:")
        this.sampleEdit := this.AddEdit("x+10 yp-3 w280", "Type something here...")
        
        this.AddText("xm y+15 w80", "Progress:")
        this.sampleProgress := this.AddProgress("x+10 yp w280 h20", 65)
        
        this.AddText("xm y+20 Section w460", "ListView Example:")
        this.lv := this.AddListView("xm w460 h100 Grid", ["Name", "Type", "Status"])
        this.lv.Add("", "ModernWindow.ahk", "Class", "Active")
        this.lv.Add("", "DWM.ahk", "Library", "Loaded")
        this.lv.Add("", "Theme.ahk", "Library", "Loaded")
        this.lv.ModifyCol(1, 200)
        this.lv.ModifyCol(2, 120)
        this.lv.ModifyCol(3, 100)
        
        this.AddText("xm y+20 Section w460", "GridView Example:")
        gridItems := ["Documents", "Pictures", "Music", "Videos", "Downloads", "Desktop", "Projects", "Archive"]
        this.gv := this.AddGridView("xm w460 h180", gridItems)
        this.gv.itemWidth := 100
        this.gv.itemHeight := 80
        this.gv.iconSize := 32
        this.gv._UpdateLayout()
        this.gv._Invalidate()
        
        this.AddButton("xm y+20 w120 h32", "Action 1").OnEvent("Click", (*) => MsgBox("Button 1 clicked!"))
        this.AddButton("x+10 w120 h32", "Action 2").OnEvent("Click", (*) => MsgBox("Button 2 clicked!"))
        this.AddButton("x+10 w120 h32", "Close").OnEvent("Click", (*) => this.gui.Hide())
    }
    
    OnBackdropChange(*) {
        this.SetBackdrop(this.backdropDDL.Text)
    }
    
    OnCornerChange(*) {
        this.SetCorners(this.cornerDDL.Text)
    }
    
    OnDarkModeToggle(*) {
        this.SetDarkMode(this.darkModeChk.Value)
        if this.darkModeChk.Value {
            this.gui.BackColor := Format("{:06X}", ModernWindow.Theme["bg"])
        } else {
            this.gui.BackColor := "F3F3F3"
        }
    }
    
    OnClose() {
        ExitApp()
    }
}

DemoApp()
