#Requires AutoHotkey v2.1-alpha.16
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

; ConsoleColor enum values (integers)
CC_Black := 0
CC_DarkBlue := 1
CC_DarkGreen := 2
CC_DarkCyan := 3
CC_DarkRed := 4
CC_DarkMagenta := 5
CC_DarkYellow := 6
CC_Gray := 7
CC_DarkGray := 8
CC_Blue := 9
CC_Green := 10
CC_Cyan := 11
CC_Red := 12
CC_Magenta := 13
CC_Yellow := 14
CC_White := 15

; Set console title using Windows API (more reliable)
DllCall("SetConsoleTitleW", "WStr", "Advanced .NET Console Demo")

; Try to clear, skip if it fails
try {
    Console.Clear()
}

; === COLORED OUTPUT ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== .NET Console Advanced Demo ===")
Console.WriteLine("")

; Multiple colors - log levels
Console.ForegroundColor := CC_Green
Console.Write("[SUCCESS] ")
Console.ForegroundColor := CC_White
Console.WriteLine("Operation completed successfully")

Console.ForegroundColor := CC_Yellow
Console.Write("[WARNING] ")
Console.ForegroundColor := CC_White
Console.WriteLine("This is a warning message")

Console.ForegroundColor := CC_Red
Console.Write("[ERROR] ")
Console.ForegroundColor := CC_White
Console.WriteLine("This is an error message")

Console.ForegroundColor := CC_Magenta
Console.Write("[DEBUG] ")
Console.ForegroundColor := CC_Gray
Console.WriteLine("Debug information here")

Console.WriteLine("")

; === BACKGROUND COLORS ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== Background Colors ===")

Console.BackgroundColor := CC_DarkBlue
Console.ForegroundColor := CC_White
Console.WriteLine("  White on Dark Blue  ")

Console.BackgroundColor := CC_DarkGreen
Console.ForegroundColor := CC_Yellow
Console.WriteLine("  Yellow on Dark Green  ")

Console.BackgroundColor := CC_DarkRed
Console.ForegroundColor := CC_White
Console.WriteLine("  White on Dark Red  ")

; Reset colors
Console.ResetColor()
Console.WriteLine("")

; === SYSTEM INFO ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== System Information ===")
Console.ResetColor()

Console.Write("Machine Name: ")
Console.ForegroundColor := CC_Yellow
Console.WriteLine(Environment.MachineName)
Console.ResetColor()

Console.Write("User Name: ")
Console.ForegroundColor := CC_Yellow
Console.WriteLine(Environment.UserName)
Console.ResetColor()

Console.Write("OS Version: ")
Console.ForegroundColor := CC_Yellow
Console.WriteLine(Environment.OSVersion.ToString())
Console.ResetColor()

Console.Write(".NET Version: ")
Console.ForegroundColor := CC_Yellow
Console.WriteLine(Environment.Version.ToString())
Console.ResetColor()

Console.Write("Processor Count: ")
Console.ForegroundColor := CC_Yellow
Console.WriteLine(Environment.ProcessorCount)
Console.ResetColor()

Console.Write("64-bit OS: ")
Console.ForegroundColor := CC_Yellow
Console.WriteLine(Environment.Is64BitOperatingSystem)
Console.ResetColor()

Console.WriteLine("")

; === PROGRESS BAR DEMO ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== Progress Bar Demo ===")
Console.ResetColor()

Console.Write("Processing: [")
Loop 20 {
    Console.ForegroundColor := CC_Green
    Console.Write("#")
    NetThread.Sleep(50)
}
Console.ResetColor()
Console.WriteLine("] Done!")

Console.WriteLine("")

; === FORMATTED TABLE ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== Formatted Table ===")
Console.ResetColor()

; Header
Console.ForegroundColor := CC_White
Console.BackgroundColor := CC_DarkGray
Console.WriteLine(" ID   | Name          | Status     | Score ")
Console.ResetColor()

; Rows
PrintTableRow("001", "Alice", "Active", "95", CC_Green)
PrintTableRow("002", "Bob", "Pending", "87", CC_Yellow)
PrintTableRow("003", "Carol", "Active", "92", CC_Green)
PrintTableRow("004", "Dave", "Inactive", "78", CC_Red)

Console.WriteLine("")

; === BEEP / SOUND ===
Console.ForegroundColor := CC_Cyan
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
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== Loading Animation ===")
Console.ResetColor()

Console.Write("  Loading ")
Loop 15 {
    Console.ForegroundColor := CC_Yellow
    Console.Write(".")
    NetThread.Sleep(150)
}
Console.ForegroundColor := CC_Green
Console.WriteLine(" Done!")
Console.ResetColor()

Console.WriteLine("")

; === COUNTDOWN ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== Countdown Timer ===")
Console.ResetColor()

Console.Write("Countdown: ")
Loop 5 {
    num := 6 - A_Index
    Console.ForegroundColor := num <= 2 ? CC_Red : CC_Yellow
    Console.Write(num " ")
    NetThread.Sleep(500)
}
Console.ForegroundColor := CC_Green
Console.WriteLine("GO!")
Console.ResetColor()

Console.WriteLine("")

; === INTERACTIVE INPUT ===
Console.ForegroundColor := CC_Cyan
Console.WriteLine("=== Interactive Demo ===")
Console.ResetColor()

Console.WriteLine("  (An input box will appear...)")

; Use AHK InputBox since Console.ReadLine doesn't work through COM
ib := InputBox("Enter your name:", "Interactive Demo", "w300 h120")
name := (ib.Result = "OK" && ib.Value != "") ? ib.Value : "User"

Console.Write("  Hello, ")
Console.ForegroundColor := CC_Green
Console.Write(name)
Console.ResetColor()
Console.WriteLine("! Welcome to .NET Console from AHK!")

Console.WriteLine("")

; === FINAL MESSAGE ===
Console.ForegroundColor := CC_Cyan
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
    global Console, CC_White
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
