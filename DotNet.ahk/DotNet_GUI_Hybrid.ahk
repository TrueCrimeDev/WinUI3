#Requires AutoHotkey v2.0
#Include DotNet.ahk

; Hybrid approach: AHK GUI + .NET functionality
; This is the intended use pattern for DotNet.ahk
; AHK handles the GUI, .NET provides powerful backend functionality

; Load .NET assemblies
runtimePath := GetLatestDotNetCorePath()
try DotNet.LoadAssembly(runtimePath "\System.Security.Cryptography.Algorithms.dll")
try DotNet.LoadAssembly(runtimePath "\System.Text.Json.dll")

; Get .NET types
Encoding := DotNet.using("System.Text.Encoding")
SHA256 := DotNet.using("System.Security.Cryptography.SHA256")
MD5 := DotNet.using("System.Security.Cryptography.MD5")
Guid := DotNet.using("System.Guid")
Stopwatch := DotNet.using("System.Diagnostics.Stopwatch")
DateTime := DotNet.using("System.DateTime")
Environment := DotNet.using("System.Environment")
Path := DotNet.using("System.IO.Path")
File_ := DotNet.using("System.IO.File")
Console := DotNet.using("System.Console")

; Print to console (visible if run with /ErrorStdOut)
Console.WriteLine("DotNet.ahk loaded successfully!")
Console.WriteLine("Running on: " Environment.OSVersion.ToString())

; Create AHK GUI (use myGui to avoid any shadowing)
myGui := Gui("+Resize", ".NET Toolkit (AHK + .NET)")
myGui.SetFont("s10", "Segoe UI")
myGui.BackColor := "White"

; Title
myGui.AddText("w500 Center", ".NET Functionality via AutoHotkey v2").SetFont("s14 Bold")
myGui.AddText("w500 Center cGray", "Powered by DotNet.ahk - .NET " Environment.Version.ToString())

; Input section
myGui.AddGroupBox("w510 h80 Section", "Input Text")
inputEdit := myGui.AddEdit("xp+10 yp+25 w490 h40", "Hello, World!")

; Hash section
myGui.AddGroupBox("xs w510 h130", "Cryptographic Hashes")
myGui.AddText("xp+10 yp+25", "SHA256:")
sha256Edit := myGui.AddEdit("x+5 w400 ReadOnly")
myGui.AddText("xs+10 y+10", "MD5:     ")
md5Edit := myGui.AddEdit("x+5 w400 ReadOnly")
btnHash := myGui.AddButton("xs+10 y+10 w100", "Compute Hashes")
btnHash.OnEvent("Click", ComputeHashes)

; Utilities section
myGui.AddGroupBox("xs w510 h100", "Utilities")
btnGuid := myGui.AddButton("xp+10 yp+25 w120", "Generate GUID")
btnTime := myGui.AddButton("x+10 w120", "Current Time")
btnTempPath := myGui.AddButton("x+10 w120", "Temp Path")
btnBench := myGui.AddButton("x+10 w120", "Benchmark")
utilOutput := myGui.AddEdit("xs+10 y+10 w490 h30 ReadOnly")
btnGuid.OnEvent("Click", GenerateGuid)
btnTime.OnEvent("Click", ShowTime)
btnTempPath.OnEvent("Click", ShowTempPath)
btnBench.OnEvent("Click", RunBenchmark)

; File section
myGui.AddGroupBox("xs w510 h80", "File Operations (.NET System.IO)")
btnReadFile := myGui.AddButton("xp+10 yp+25 w120", "Read This Script")
btnFileInfo := myGui.AddButton("x+10 w120", "File Exists?")
fileOutput := myGui.AddEdit("xs+10 y+10 w490 h25 ReadOnly")
btnReadFile.OnEvent("Click", ReadThisScript)
btnFileInfo.OnEvent("Click", CheckFileExists)

; System Info section
myGui.AddGroupBox("xs w510 h100", "System Information (.NET Environment)")
sysInfo := myGui.AddEdit("xp+10 yp+25 w490 h60 ReadOnly Multi")
PopulateSystemInfo()

myGui.OnEvent("Close", (*) => ExitApp())
myGui.OnEvent("Size", GuiResize)
myGui.Show("w530")

; Event handlers
ComputeHashes(*) {
    global inputEdit, sha256Edit, md5Edit, SHA256, MD5, Encoding

    text := inputEdit.Value
    bytes := Encoding.UTF8.GetBytes(text)

    ; SHA256
    sha := SHA256.Create()
    hashBytes := sha.ComputeHash(bytes)
    hex := ""
    for b in hashBytes
        hex .= Format("{:02x}", b)
    sha256Edit.Value := hex

    ; MD5
    md := MD5.Create()
    hashBytes := md.ComputeHash(bytes)
    hex := ""
    for b in hashBytes
        hex .= Format("{:02x}", b)
    md5Edit.Value := hex
}

GenerateGuid(*) {
    global utilOutput, Guid
    utilOutput.Value := "GUID: " Guid.NewGuid().ToString()
}

ShowTime(*) {
    global utilOutput, DateTime
    now := DateTime.Now
    utilOutput.Value := "DateTime: " now.ToString("yyyy-MM-dd HH:mm:ss.fff")
}

ShowTempPath(*) {
    global utilOutput, Path
    utilOutput.Value := "Temp: " Path.GetTempPath()
}

RunBenchmark(*) {
    global utilOutput, Stopwatch, SHA256, Encoding

    sw := Stopwatch.StartNew()
    sha := SHA256.Create()
    bytes := Encoding.UTF8.GetBytes("benchmark test string")

    Loop 10000
        sha.ComputeHash(bytes)

    sw.Stop()
    utilOutput.Value := "10,000 SHA256 hashes in " sw.ElapsedMilliseconds " ms"
}

ReadThisScript(*) {
    global fileOutput, File_

    try {
        content := File_.ReadAllText(A_ScriptFullPath)
        lines := StrSplit(content, "`n")
        fileOutput.Value := "Script has " lines.Length " lines, " StrLen(content) " chars"
    } catch as e {
        fileOutput.Value := "Error: " e.Message
    }
}

CheckFileExists(*) {
    global fileOutput, File_

    testPath := A_ScriptFullPath
    exists := File_.Exists(testPath)
    fileOutput.Value := (exists ? "✓ EXISTS: " : "✗ NOT FOUND: ") testPath
}

PopulateSystemInfo() {
    global sysInfo, Environment

    info := ""
    info .= "Machine: " Environment.MachineName
    info .= " | User: " Environment.UserName
    info .= " | Cores: " Environment.ProcessorCount
    info .= "`n64-bit OS: " (Environment.Is64BitOperatingSystem ? "Yes" : "No")
    info .= " | 64-bit Process: " (Environment.Is64BitProcess ? "Yes" : "No")
    info .= " | CLR: " Environment.Version.ToString()

    sysInfo.Value := info
}

GuiResize(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
}

; Helper function
GetLatestDotNetCorePath() {
    root := "C:\Program Files\dotnet\shared\Microsoft.NETCore.App"
    versions := []
    Loop Files root "\*", "D" {
        if RegExMatch(A_LoopFileName, "^(\d+)\.(\d+)\.(\d+)(?:-(.+))?$", &m)
            versions.Push(m)
    }
    if (!versions.Length)
        throw Error("No .NET Core runtime found")
    InsertionSort(versions, semver_cmp)
    return root "\" versions[versions.Length].0
}

semver_cmp(a, b) {
    if (a.1 - b.1)
        return a.1 - b.1
    if (a.2 - b.2)
        return a.2 - b.2
    if (a.3 - b.3)
        return a.3 - b.3
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
