#Requires AutoHotkey v2.0
#Include DotNet.ahk

; .NET GUI demo: SHA256 hashing, GUID creation, Stopwatch timing.
if (SubStr(A_AhkVersion, 1, 1) != "2") {
    MsgBox "This script requires AutoHotkey v2.`nDetected: " A_AhkVersion
    ExitApp
}
runtimePath := GetLatestDotNetCorePath()
DotNet.LoadAssembly(runtimePath "\System.Security.Cryptography.dll")
DotNet.LoadAssembly(runtimePath "\System.Security.Cryptography.Primitives.dll")
DotNet.LoadAssembly(runtimePath "\System.Security.Cryptography.Algorithms.dll")
DotNet.LoadAssembly(runtimePath "\System.Diagnostics.TraceSource.dll")
DotNet.LoadAssembly(runtimePath "\System.Text.Encoding.Extensions.dll")

Encoding := DotNet.using("System.Text.Encoding")
SHA256 := DotNet.using("System.Security.Cryptography.SHA256")
Activator := DotNet.using("System.Activator")
Stopwatch := DotNet.using("System.Diagnostics.Stopwatch")
Guid := DotNet.using("System.Guid")

sw := 0
timerRunning := false

myGui := Gui(, ".NET via AHK v2")
myGui.SetFont("s10", "Segoe UI")
myGui.AddText(, "Input text:")
inputEdit := myGui.AddEdit("w460 r4")
btnHash := myGui.AddButton("w120", "SHA256")
btnGuid := myGui.AddButton("x+10 w120", "New GUID")
btnTimer := myGui.AddButton("x+10 w120", "Start Timer")
myGui.AddText("xm y+10", "Output:")
outputEdit := myGui.AddEdit("w460 r6 ReadOnly")

btnHash.OnEvent("Click", HashText)
btnGuid.OnEvent("Click", MakeGuid)
btnTimer.OnEvent("Click", ToggleTimer)
myGui.Show()

HashText(*) {
    global Encoding, SHA256, inputEdit, outputEdit
    try {
        sha := SHA256.Create()
        if (!sha) {
            outputEdit.Value := "Error: SHA256.Create() returned null"
            return
        }
        bytes := Encoding.UTF8.GetBytes(inputEdit.Value)
        hashBytes := sha.ComputeHash(bytes)
        hex := ""
        for b in hashBytes
            hex .= Format("{:02X}", b)
        outputEdit.Value := "SHA256:`n" hex
    } catch as e {
        outputEdit.Value := "Error: " e.Message
    }
}

MakeGuid(*) {
    global Guid, outputEdit
    outputEdit.Value := "GUID:`n" Guid.NewGuid().ToString()
}

ToggleTimer(*) {
    global Stopwatch, sw, timerRunning, btnTimer, outputEdit
    if (!timerRunning) {
        sw := Stopwatch.StartNew()
        timerRunning := true
        btnTimer.Text := "Stop Timer"
        outputEdit.Value := "Timer started..."
    } else {
        sw.Stop()
        timerRunning := false
        btnTimer.Text := "Start Timer"
        outputEdit.Value := "Elapsed ms:`n" sw.ElapsedMilliseconds
    }
}

GetLatestDotNetCorePath() {
    root := "C:\Program Files\dotnet\shared\Microsoft.NETCore.App"
    versions := []
    Loop Files root "\*", "D" {
        if RegExMatch(A_LoopFileName, "^(\d+)\.(\d+)\.(\d+)(?:-(.+))?$", &m) {
            versions.Push(m)
        }
    }
    if (!versions.Length) {
        throw Error("No .NET version found in " root)
    }
    InsertionSort(versions, semver_cmp)
    latest := versions[versions.Length]
    return root "\" latest.0
}

semver_cmp(a, b) {
    major := a.1 - b.1
    if (major) {
        return major
    }
    minor := a.2 - b.2
    if (minor) {
        return minor
    }
    patch := a.3 - b.3
    if (patch) {
        return patch
    }
    if (!a.4) {
        return 1
    }
    if (!b.4) {
        return -1
    }
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
