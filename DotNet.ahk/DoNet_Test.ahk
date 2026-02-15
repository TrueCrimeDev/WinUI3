#Requires AutoHotkey v2.1-alpha.17
#SingleInstance Force

#Include DotNet.ahk

; Allocate a console window BEFORE loading .NET types
DllCall("AllocConsole")

; Redirect standard handles so .NET Console can use them
DllCall("kernel32\SetStdHandle", "UInt", -10, "Ptr", DllCall("kernel32\GetStdHandle", "UInt", -10, "Ptr"))  ; STD_INPUT
DllCall("kernel32\SetStdHandle", "UInt", -11, "Ptr", DllCall("kernel32\GetStdHandle", "UInt", -11, "Ptr"))  ; STD_OUTPUT
DllCall("kernel32\SetStdHandle", "UInt", -12, "Ptr", DllCall("kernel32\GetStdHandle", "UInt", -12, "Ptr"))  ; STD_ERROR

; Get Console and related types
Console := DotNet.using("System.Console")
Environment := DotNet.using("System.Environment")
NetThread := DotNet.using("System.Threading.Thread")
ConsoleColor := DotNet.using("System.ConsoleColor")
AHK_DotNet_Interop := DotNet.using("AHK_DotNet_Interop.Lib")

; Set console title using Windows API (more reliable)
DllCall("SetConsoleTitleW", "WStr", "Advanced .NET Console Demo")

; Try to clear, skip if it fails
AHK_DotNet_Interop.DebugWriteLineEnabled := false
try {
    Console.Clear()
}
AHK_DotNet_Interop.DebugWriteLineEnabled := true

; === COLORED OUTPUT ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== .NET Console Advanced Demo ===")
Console.WriteLine("")

; Multiple colors - log levels
Console.ForegroundColor := ConsoleColor.Green
Console.Write("[SUCCESS] ")
Console.ForegroundColor := ConsoleColor.White
Console.WriteLine("Operation completed successfully")

Console.ForegroundColor := ConsoleColor.Yellow
Console.Write("[WARNING] ")
Console.ForegroundColor := ConsoleColor.White
Console.WriteLine("This is a warning message")

Console.ForegroundColor := ConsoleColor.Red
Console.Write("[ERROR] ")
Console.ForegroundColor := ConsoleColor.White
Console.WriteLine("This is an error message")

Console.ForegroundColor := ConsoleColor.Magenta
Console.Write("[DEBUG] ")
Console.ForegroundColor := ConsoleColor.Gray
Console.WriteLine("Debug information here")

Console.WriteLine("")

; === BACKGROUND COLORS ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Background Colors ===")

Console.BackgroundColor := ConsoleColor.DarkBlue
Console.ForegroundColor := ConsoleColor.White
Console.WriteLine("  White on Dark Blue  ")

Console.BackgroundColor := ConsoleColor.DarkGreen
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine("  Yellow on Dark Green  ")

Console.BackgroundColor := ConsoleColor.DarkRed
Console.ForegroundColor := ConsoleColor.White
Console.WriteLine("  White on Dark Red  ")

; Reset colors
Console.ResetColor()
Console.WriteLine("")

; === SYSTEM INFO ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== System Information ===")
Console.ResetColor()

Console.Write("Machine Name: ")
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine(Environment.MachineName)
Console.ResetColor()

Console.Write("User Name: ")
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine(Environment.UserName)
Console.ResetColor()

Console.Write("OS Version: ")
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine(Environment.OSVersion.ToString())
Console.ResetColor()

Console.Write(".NET Version: ")
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine(Environment.Version.ToString())
Console.ResetColor()

Console.Write("Processor Count: ")
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine(Environment.ProcessorCount)
Console.ResetColor()

Console.Write("64-bit OS: ")
Console.ForegroundColor := ConsoleColor.Yellow
Console.WriteLine(Environment.Is64BitOperatingSystem)
Console.ResetColor()

Console.WriteLine("")

; === PROGRESS BAR DEMO ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Progress Bar Demo ===")
Console.ResetColor()

Console.Write("Processing: [")
Loop 20 {
    Console.ForegroundColor := ConsoleColor.Green
    Console.Write("#")
    NetThread.Sleep(50)
}
Console.ResetColor()
Console.WriteLine("] Done!")

Console.WriteLine("")

; === FORMATTED TABLE ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Formatted Table ===")
Console.ResetColor()

; Header
Console.ForegroundColor := ConsoleColor.White
Console.BackgroundColor := ConsoleColor.DarkGray
Console.WriteLine(" ID   | Name          | Status     | Score ")
Console.ResetColor()

; Rows
PrintTableRow("001", "Alice", "Active", "95", ConsoleColor.Green)
PrintTableRow("002", "Bob", "Pending", "87", ConsoleColor.Yellow)
PrintTableRow("003", "Carol", "Active", "92", ConsoleColor.Green)
PrintTableRow("004", "Dave", "Inactive", "78", ConsoleColor.Red)

Console.WriteLine("")

; === BEEP / SOUND ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Sound Demo ===")
Console.ResetColor()
Console.WriteLine("Playing a short melody...")

; Simple melody using Console.Beep(frequency, duration)
Console.Beep(523, 200)  ; C5
Console.Beep(587, 200)  ; D5
Console.Beep(659, 200)  ; E5
Console.Beep(698, 200)  ; F5
Console.Beep(784, 400)  ; G5

Console.WriteLine("")

; === LOADING ANIMATION ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Loading Animation ===")
Console.ResetColor()

Console.Write("  Loading ")
Loop 15 {
    Console.ForegroundColor := ConsoleColor.Yellow
    Console.Write(".")
    NetThread.Sleep(150)
}
Console.ForegroundColor := ConsoleColor.Green
Console.WriteLine(" Done!")
Console.ResetColor()

Console.WriteLine("")

; === COUNTDOWN ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Countdown Timer ===")
Console.ResetColor()

Console.Write("Countdown: ")
Loop 5 {
    num := 6 - A_Index
    Console.ForegroundColor := num <= 2 ? ConsoleColor.Red : ConsoleColor.Yellow
    Console.Write(num " ")
    NetThread.Sleep(500)
}
Console.ForegroundColor := ConsoleColor.Green
Console.WriteLine("GO!")
Console.ResetColor()

Console.WriteLine("")

; === INTERACTIVE INPUT ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("=== Interactive Demo ===")
Console.ResetColor()

Console.WriteLine("  (An input box will appear...)")

; Use AHK InputBox since Console.ReadLine doesn't work through COM
ib := InputBox("Enter your name:", "Interactive Demo", "w300 h120")
name := (ib.Result = "OK" && ib.Value != "") ? ib.Value : "User"

Console.Write("  Hello, ")
Console.ForegroundColor := ConsoleColor.Green
Console.Write(name)
Console.ResetColor()
Console.WriteLine("! Welcome to .NET Console from AHK!")

Console.WriteLine("")

; === FINAL MESSAGE ===
Console.ForegroundColor := ConsoleColor.Cyan
Console.WriteLine("========================================")
Console.WriteLine("        Demo Complete!                  ")
Console.WriteLine("========================================")
Console.ResetColor()

; Wait using AHK (Console.ReadKey doesn't work through COM)
MsgBox("Click OK to close the console demo.", "Demo Complete", "0x40")

; Clean up
try Console.Clear()
DllCall("FreeConsole")
ExitApp

; Helper function for table rows
PrintTableRow(id, name, status, score, statusColor) {
    global Console, ConsoleColor
    Console.Write(" " PadRight(id, 4) " | ")
    Console.Write(PadRight(name, 13) " | ")
    Console.ForegroundColor := statusColor
    Console.Write(PadRight(status, 10))
    Console.ResetColor()
    Console.WriteLine(" | " score)
}

PadRight(str, len) {
    while StrLen(str) < len
        str .= " "
    return str
}