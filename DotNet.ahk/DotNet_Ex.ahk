#Requires AutoHotkey v2.1-alpha.16
#SingleInstance Force

#Include DotNet.ahk

Console := DotNet.using("System.Console")
Console.WriteLine("Hello from C#")

File_ := DotNet.using("System.IO.File")
Console.WriteLine(File_.ReadAllText(A_LineFile))