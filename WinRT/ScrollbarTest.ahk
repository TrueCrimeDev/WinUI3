#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

#Include DWM.ahk
#Include Theme.ahk
#Include ModernWindow.ahk

ScrollbarTest()

class ScrollbarTest extends ModernWindow {
    __New() {
        super.__New("Clipped Scrollbar Test - Mica Theme", "+MinimizeBox")
        this.BuildUI()
        this.Show("w700 h500")
    }
    
    BuildUI() {
        this.gui.SetFont("s10", "Segoe UI")
        
        items := []
        Loop 30
            items.Push("Item " A_Index " - Testing clipped scrollbar")
        
        this.AddText("xm Section w300", "1. ListView - Clipped Scrollbar")
        container1 := this.gui.AddText("xm w285 h200 +0x50000000")
        this.lv1 := this.gui.AddListView("xp yp w300 h200 -E0x200 Background" Format("{:06X}", ModernWindow.Theme["bg"]) " +LV0x10000", ["Name", "Value"])
        for item in items
            this.lv1.Add("", item, "Data " A_Index)
        this.lv1.ModifyCol(1, 185)
        this.lv1.ModifyCol(2, 80)
        DllCall("SetParent", "Ptr", this.lv1.Hwnd, "Ptr", container1.Hwnd)
        DllCall("SetWindowPos", "Ptr", this.lv1.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 300, "Int", 200, "UInt", 0x14)
        
        this.AddText("x+40 ys w300", "2. ListView - Clipped Scrollbar")
        container2 := this.gui.AddText("xp w285 h200 +0x50000000")
        this.lv2 := this.gui.AddListView("xp yp w300 h200 -E0x200 Background" Format("{:06X}", ModernWindow.Theme["bg"]) " +LV0x10000", ["Name", "Value"])
        for item in items
            this.lv2.Add("", item, "Data " A_Index)
        this.lv2.ModifyCol(1, 185)
        this.lv2.ModifyCol(2, 80)
        DllCall("SetParent", "Ptr", this.lv2.Hwnd, "Ptr", container2.Hwnd)
        DllCall("SetWindowPos", "Ptr", this.lv2.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 300, "Int", 200, "UInt", 0x14)
        
        this.AddText("xm y+30 Section w300", "3. Edit - Clipped Scrollbar")
        editText := ""
        Loop 30
            editText .= "Line " A_Index " - Edit control text`n"
        container3 := this.gui.AddText("xm w285 h120 +0x50000000")
        this.edit1 := this.gui.AddEdit("xp yp w300 h120 -E0x200 Multi Background" Format("{:06X}", ModernWindow.Theme["bg"]), editText)
        DllCall("SetParent", "Ptr", this.edit1.Hwnd, "Ptr", container3.Hwnd)
        DllCall("SetWindowPos", "Ptr", this.edit1.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 300, "Int", 120, "UInt", 0x14)
        
        this.AddText("x+40 ys w300", "4. TreeView - Clipped Scrollbar")
        container4 := this.gui.AddText("xp w285 h120 +0x50000000")
        this.tv := this.gui.AddTreeView("xp yp w300 h120 -E0x200 Background" Format("{:06X}", ModernWindow.Theme["bg"]))
        Loop 25 {
            p := this.tv.Add("Parent " A_Index)
            this.tv.Add("Child 1", p)
            this.tv.Add("Child 2", p)
        }
        DllCall("SetParent", "Ptr", this.tv.Hwnd, "Ptr", container4.Hwnd)
        DllCall("SetWindowPos", "Ptr", this.tv.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 300, "Int", 120, "UInt", 0x14)
        
        this.AddText("xm y+20 w650 cGray", "All controls have scrollbars clipped - use mouse wheel to scroll.")
    }
    
    OnClose() {
        ExitApp()
    }
}




