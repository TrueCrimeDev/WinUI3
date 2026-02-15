#Requires AutoHotkey v2.0
#Include DotNet.ahk

; .NET Windows Forms GUI Example
; Creates and displays a real .NET Windows Forms window from AHK

; Get the Windows Desktop runtime path (contains Windows Forms)
desktopPath := GetLatestWindowsDesktopPath()

; Load required Windows Forms assemblies
DotNet.LoadAssembly(desktopPath "\System.Windows.Forms.dll")
DotNet.LoadAssembly(desktopPath "\System.Drawing.dll")
DotNet.LoadAssembly(desktopPath "\System.Drawing.Primitives.dll")
DotNet.LoadAssembly(desktopPath "\System.ComponentModel.Primitives.dll")

; Get .NET types
Form := DotNet.using("System.Windows.Forms.Form")
Button := DotNet.using("System.Windows.Forms.Button")
Label := DotNet.using("System.Windows.Forms.Label")
TextBox := DotNet.using("System.Windows.Forms.TextBox")
MessageBox := DotNet.using("System.Windows.Forms.MessageBox")
Application := DotNet.using("System.Windows.Forms.Application")
Point := DotNet.using("System.Drawing.Point")
Size := DotNet.using("System.Drawing.Size")
Color := DotNet.using("System.Drawing.Color")
ContentAlignment := DotNet.using("System.Drawing.ContentAlignment")
FormStartPosition := DotNet.using("System.Windows.Forms.FormStartPosition")
FlatStyle := DotNet.using("System.Windows.Forms.FlatStyle")
Activator := DotNet.using("System.Activator")

; Create the main form
form := Activator.CreateInstance(Form)
form.Text := ".NET WinForms GUI from AHK"
form.Size := Size.op_Implicit(Activator.CreateInstance(Size, 450, 320))
form.StartPosition := FormStartPosition.CenterScreen
form.BackColor := Color.WhiteSmoke

; Create title label
titleLabel := Activator.CreateInstance(Label)
titleLabel.Text := "Welcome to .NET Windows Forms!"
titleLabel.Location := Point.op_Implicit(Activator.CreateInstance(Point, 20, 20))
titleLabel.Size := Size.op_Implicit(Activator.CreateInstance(Size, 400, 30))
titleLabel.Font := CreateFont("Segoe UI", 14, true)
titleLabel.ForeColor := Color.DarkBlue
form.Controls.Add(titleLabel)

; Create input label
inputLabel := Activator.CreateInstance(Label)
inputLabel.Text := "Enter your name:"
inputLabel.Location := Point.op_Implicit(Activator.CreateInstance(Point, 20, 70))
inputLabel.Size := Size.op_Implicit(Activator.CreateInstance(Size, 150, 25))
form.Controls.Add(inputLabel)

; Create text input
textBox := Activator.CreateInstance(TextBox)
textBox.Location := Point.op_Implicit(Activator.CreateInstance(Point, 20, 100))
textBox.Size := Size.op_Implicit(Activator.CreateInstance(Size, 390, 30))
textBox.Font := CreateFont("Segoe UI", 11, false)
form.Controls.Add(textBox)

; Create greet button
greetBtn := Activator.CreateInstance(Button)
greetBtn.Text := "Greet Me!"
greetBtn.Location := Point.op_Implicit(Activator.CreateInstance(Point, 20, 150))
greetBtn.Size := Size.op_Implicit(Activator.CreateInstance(Size, 120, 40))
greetBtn.FlatStyle := FlatStyle.Flat
greetBtn.BackColor := Color.DodgerBlue
greetBtn.ForeColor := Color.White
greetBtn.Font := CreateFont("Segoe UI", 10, true)
form.Controls.Add(greetBtn)

; Create info button
infoBtn := Activator.CreateInstance(Button)
infoBtn.Text := "Show Info"
infoBtn.Location := Point.op_Implicit(Activator.CreateInstance(Point, 160, 150))
infoBtn.Size := Size.op_Implicit(Activator.CreateInstance(Size, 120, 40))
infoBtn.FlatStyle := FlatStyle.Flat
infoBtn.BackColor := Color.ForestGreen
infoBtn.ForeColor := Color.White
infoBtn.Font := CreateFont("Segoe UI", 10, true)
form.Controls.Add(infoBtn)

; Create close button
closeBtn := Activator.CreateInstance(Button)
closeBtn.Text := "Close"
closeBtn.Location := Point.op_Implicit(Activator.CreateInstance(Point, 300, 150))
closeBtn.Size := Size.op_Implicit(Activator.CreateInstance(Size, 110, 40))
closeBtn.FlatStyle := FlatStyle.Flat
closeBtn.BackColor := Color.Crimson
closeBtn.ForeColor := Color.White
closeBtn.Font := CreateFont("Segoe UI", 10, true)
form.Controls.Add(closeBtn)

; Create output label
outputLabel := Activator.CreateInstance(Label)
outputLabel.Text := "Output will appear here..."
outputLabel.Location := Point.op_Implicit(Activator.CreateInstance(Point, 20, 210))
outputLabel.Size := Size.op_Implicit(Activator.CreateInstance(Size, 390, 60))
outputLabel.Font := CreateFont("Segoe UI", 10, false)
outputLabel.BackColor := Color.White
outputLabel.BorderStyle := 1 ; FixedSingle
form.Controls.Add(outputLabel)

; Store references for event handling
global g_form := form
global g_textBox := textBox
global g_outputLabel := outputLabel
global g_MessageBox := MessageBox

; Show the form non-modally so we can handle events via AHK timer
form.Show()

; Use AHK to poll for button clicks (workaround since direct .NET event binding is complex)
SetTimer(CheckButtons, 50)

CheckButtons() {
    global greetBtn, infoBtn, closeBtn, g_textBox, g_outputLabel, g_MessageBox, g_form
    static lastGreetState := 0, lastInfoState := 0, lastCloseState := 0

    try {
        ; Check if form is still open
        if !g_form.Visible {
            SetTimer(CheckButtons, 0)
            ExitApp
        }

        ; Check Greet button (MouseButtons property indicates if pressed)
        ; Alternative: use Capture property check or focus state
        if greetBtn.Focused && GetKeyState("Enter", "P") {
            name := g_textBox.Text
            if (name = "")
                name := "Guest"
            g_outputLabel.Text := "Hello, " name "! Welcome to .NET from AHK."
        }

        if infoBtn.Focused && GetKeyState("Enter", "P") {
            g_outputLabel.Text := "This GUI is a real .NET Windows Forms window!`nRunning via AHK DotNet interop."
        }

        if closeBtn.Focused && GetKeyState("Enter", "P") {
            g_form.Close()
        }
    }
}

; Alternative: Create an AHK GUI with buttons to trigger .NET actions
ahkGui := Gui(, "AHK Control Panel")
ahkGui.SetFont("s10", "Segoe UI")
ahkGui.AddText(, "Click buttons to interact with .NET Form:")
ahkGui.AddButton("w150", "Greet").OnEvent("Click", DoGreet)
ahkGui.AddButton("w150", "Show Info").OnEvent("Click", DoInfo)
ahkGui.AddButton("w150", "Close .NET Form").OnEvent("Click", DoClose)
ahkGui.OnEvent("Close", (*) => ExitApp())
ahkGui.Show("x50 y50")

DoGreet(*) {
    global g_textBox, g_outputLabel
    name := g_textBox.Text
    if (name = "")
        name := "Guest"
    g_outputLabel.Text := "Hello, " name "! Welcome to .NET from AHK."
}

DoInfo(*) {
    global g_outputLabel, g_MessageBox
    g_outputLabel.Text := "This is a real .NET WinForms GUI!`nCreated from AutoHotkey v2."
    g_MessageBox.Show("This MessageBox is from .NET System.Windows.Forms!", "Info", 64)
}

DoClose(*) {
    global g_form
    g_form.Close()
    ExitApp
}

; Helper function to create fonts
CreateFont(fontFamily, size, bold) {
    Font := DotNet.using("System.Drawing.Font")
    FontStyle := DotNet.using("System.Drawing.FontStyle")
    Activator := DotNet.using("System.Activator")
    style := bold ? FontStyle.Bold : FontStyle.Regular
    return Activator.CreateInstance(Font, fontFamily, Float(size), style)
}

; Get latest Windows Desktop runtime path
GetLatestWindowsDesktopPath() {
    root := "C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App"
    versions := []
    Loop Files root "\*", "D" {
        if RegExMatch(A_LoopFileName, "^(\d+)\.(\d+)\.(\d+)(?:-(.+))?$", &m) {
            versions.Push(m)
        }
    }
    if (!versions.Length) {
        throw Error("No Windows Desktop runtime found in " root)
    }
    InsertionSort(versions, semver_cmp)
    latest := versions[versions.Length]
    return root "\" latest.0
}

semver_cmp(a, b) {
    major := a.1 - b.1
    if (major)
        return major
    minor := a.2 - b.2
    if (minor)
        return minor
    patch := a.3 - b.3
    if (patch)
        return patch
    if (!a.4)
        return 1
    if (!b.4)
        return -1
    return a > b ? 1 : -1
}

InsertionSort(A, cmp) {
    i := 2
    while (i <= A.Length) {
        x := A[i]
        j := i
        while (j > 1 && cmp(A[j-1], x) > 0) {
            A[j] := A[j - 1]
            j := j - 1
        }
        A[j] := x
        i := i + 1
    }
    return A
}
