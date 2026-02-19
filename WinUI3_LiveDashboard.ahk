#Requires AutoHotkey v2.1-alpha.14
#SingleInstance Force

#Include WinRT\winrt.ahk
#Include WinRT\AppPackage.ahk
#Include Lib\BasicXamlGui.ahk

; =============================================================================
; WinUI3 Live System Dashboard
; =============================================================================
; A real-time system monitor with acrylic backdrop, live clock, animated
; CPU/memory/disk gauges, process count, and uptime — all updating every
; second via SetTimer driving WinUI3 XAML element updates.
;
; Hotkey: Win+Alt+D to show/hide

try {
    UseWindowsAppRuntime('1.6')
} catch as e {
    MsgBox("Failed to load Windows App Runtime 1.6`n`n"
        . "Error: " e.Message, "Live Dashboard", "Icon!")
    ExitApp()
}

DQC := WinRT('Microsoft.UI.Dispatching.DispatcherQueueController').CreateOnCurrentThread()
OnExit((*) => DQC.ShutdownQueue())

; --- Permissive overload handler ---
_PermissiveOverloadAdd(self, f) {
    n := f.MinParams
    Loop (f.MaxParams - n) + 1
        self.m[n++] := f
}

; --- IReference<Color> COM helpers ---
_MakeIRefColor(a, r, g, b) {
    static prevent_gc := [], vt := _InitIRefColorVT()
    obj := Buffer(A_PtrSize + 8, 0)
    NumPut("Ptr", vt.Ptr, obj, 0)
    NumPut("UInt", 1, obj, A_PtrSize)
    NumPut("UChar", a, "UChar", r, "UChar", g, "UChar", b, obj, A_PtrSize + 4)
    prevent_gc.Push(obj)
    return obj.Ptr
}
_InitIRefColorVT() {
    vt := Buffer(7 * A_PtrSize, 0)
    NumPut("Ptr", CallbackCreate(_QI, , 3),
           "Ptr", CallbackCreate(_AR, , 1),
           "Ptr", CallbackCreate(_RL, , 1),
           "Ptr", CallbackCreate(_GI, , 3),
           "Ptr", CallbackCreate(_GC, , 2),
           "Ptr", CallbackCreate(_GT, , 2),
           "Ptr", CallbackCreate(_GV, , 2), vt)
    return vt
}
_BinGUID(str) {
    buf := Buffer(16)
    DllCall("ole32\CLSIDFromString", "Str", str, "Ptr", buf)
    return buf
}
_QI(p, riid, ppv) {
    static iU := _BinGUID("{00000000-0000-0000-C000-000000000046}")
    static iI := _BinGUID("{AF86E2E0-B12D-4C6A-9C5A-D7AA65101E90}")
    static iR := _BinGUID("{AB8E5D11-B0C1-5A21-95AE-F16BF3A37624}")
    if (_GE(riid, iU) || _GE(riid, iI) || _GE(riid, iR)) {
        NumPut("Ptr", p, ppv), _AR(p)
        return 0
    }
    NumPut("Ptr", 0, ppv)
    return 0x80004002
}
_GE(a, b) => NumGet(a, 0, "Int64") = NumGet(b.Ptr, 0, "Int64")
           && NumGet(a, 8, "Int64") = NumGet(b.Ptr, 8, "Int64")
_AR(p) => (rc := NumGet(p, A_PtrSize, "UInt") + 1, NumPut("UInt", rc, p, A_PtrSize), rc)
_RL(p) => (rc := NumGet(p, A_PtrSize, "UInt") - 1, NumPut("UInt", rc, p, A_PtrSize), rc)
_GI(p, pC, pI) => (NumPut("UInt", 0, pC), NumPut("Ptr", 0, pI), 0)
_GC(p, pN) => (NumPut("Ptr", 0, pN), 0)
_GT(p, pL) => (NumPut("UInt", 0, pL), 0)
_GV(p, pC) => (NumPut("UInt", NumGet(p, A_PtrSize + 4, "UInt"), pC), 0)

; =============================================================================
; System Info Helpers
; =============================================================================

; CPU usage via GetSystemTimes delta
GetCPUUsage() {
    static pI := 0, pK := 0, pU := 0
    DllCall("GetSystemTimes", "Int64*", &idle := 0, "Int64*", &kernel := 0, "Int64*", &user := 0)
    dI := idle - pI, dK := kernel - pK, dU := user - pU
    pI := idle, pK := kernel, pU := user
    total := dK + dU
    return total ? Round((1 - dI / total) * 100) : 0
}

; Memory via GlobalMemoryStatusEx
GetMemoryInfo() {
    buf := Buffer(64, 0)
    NumPut("UInt", 64, buf)
    DllCall("GlobalMemoryStatusEx", "Ptr", buf)
    pct := NumGet(buf, 4, "UInt")
    totalMB := NumGet(buf, 8, "UInt64") // (1024 * 1024)
    usedMB := totalMB - NumGet(buf, 16, "UInt64") // (1024 * 1024)
    return {pct: pct, usedGB: Round(usedMB / 1024, 1), totalGB: Round(totalMB / 1024, 1)}
}

; Disk via GetDiskFreeSpaceEx
GetDiskInfo(drive := "C:\") {
    DllCall("GetDiskFreeSpaceEx", "Str", drive,
            "Int64*", &freeUser := 0, "Int64*", &total := 0, "Int64*", &totalFree := 0)
    usedGB := Round((total - totalFree) / (1024**3), 1)
    totalGB := Round(total / (1024**3), 1)
    pct := total ? Round((total - totalFree) / total * 100) : 0
    return {pct: pct, usedGB: usedGB, totalGB: totalGB}
}

; Uptime
GetUptime() {
    ms := DllCall("GetTickCount64", "UInt64")
    s := ms // 1000
    d := s // 86400, s := Mod(s, 86400)
    h := s // 3600, s := Mod(s, 3600)
    m := s // 60
    return (d ? d "d " : "") h "h " m "m"
}

; Process count via ToolHelp32
GetProcessCount() {
    static PE_SIZE := A_PtrSize = 8 ? 568 : 556
    snap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x2, "UInt", 0, "Ptr")
    if snap = -1
        return 0
    pe := Buffer(PE_SIZE, 0)
    NumPut("UInt", PE_SIZE, pe)
    count := 0
    if DllCall("Process32FirstW", "Ptr", snap, "Ptr", pe) {
        count++
        while DllCall("Process32NextW", "Ptr", snap, "Ptr", pe)
            count++
    }
    DllCall("CloseHandle", "Ptr", snap)
    return count
}

; Network bytes via GetIfTable (simplified - total across all adapters)
GetNetworkRate() {
    static prevIn := 0, prevOut := 0, prevTick := 0
    ; Use GetIfTable to get aggregate bytes
    DllCall("iphlpapi\GetIfTable", "Ptr", 0, "UInt*", &sz := 0, "Int", 0)
    buf := Buffer(sz, 0)
    if DllCall("iphlpapi\GetIfTable", "Ptr", buf, "UInt*", &sz, "Int", 0)
        return {inKBs: 0, outKBs: 0}
    nRows := NumGet(buf, 0, "UInt")
    totalIn := 0, totalOut := 0
    loop nRows {
        ; MIB_IFROW is 860 bytes on x64
        off := 4 + (A_Index - 1) * 860
        totalIn += NumGet(buf, off + 552, "UInt")   ; dwInOctets
        totalOut += NumGet(buf, off + 576, "UInt")  ; dwOutOctets
    }
    tick := DllCall("GetTickCount64", "UInt64")
    dt := (tick - prevTick) / 1000
    inRate := dt > 0 ? (totalIn - prevIn) / dt / 1024 : 0
    outRate := dt > 0 ? (totalOut - prevOut) / dt / 1024 : 0
    prevIn := totalIn, prevOut := totalOut, prevTick := tick
    return {inKBs: Round(Max(inRate, 0), 1), outKBs: Round(Max(outRate, 0), 1)}
}

; Battery status
GetBatteryInfo() {
    sps := Buffer(12, 0)
    if !DllCall("GetSystemPowerStatus", "Ptr", sps)
        return {hasBattery: false, pct: 0, charging: false}
    flag := NumGet(sps, 0, "UChar")
    pct := NumGet(sps, 2, "UChar")
    charging := flag & 8
    return {hasBattery: pct != 255, pct: pct = 255 ? 0 : pct, charging: charging}
}

; =============================================================================
; Build GUI
; =============================================================================
xg := BasicXamlGui('+Resize +AlwaysOnTop', 'System Dashboard')

; Acrylic backdrop
NumPut('int', -1, 'int', -1, 'int', -1, 'int', -1, margins := Buffer(16))
DllCall("dwmapi\DwmExtendFrameIntoClientArea", 'ptr', xg.hwnd, 'ptr', margins, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', xg.hwnd, 'uint', 38, 'int*', 3, 'int', 4, 'hresult')
DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', xg.hwnd, 'uint', 20, 'int*', 1, 'int', 4)
xg.BackColor := '1A1A2E'

; =============================================================================
; XAML
; =============================================================================
xaml := "
(
<Grid xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
      xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
      Background='Transparent' RowDefinitions='Auto,*'>

    <!-- Title Bar -->
    <Border Grid.Row='0' Height='40' Background='#20FFFFFF'>
        <Grid ColumnDefinitions='Auto,*,Auto' Margin='16,0'>
            <StackPanel Orientation='Horizontal' Spacing='8' VerticalAlignment='Center'>
                <SymbolIcon Symbol='AllApps' Foreground='#4CC2FF'/>
                <TextBlock Text='System Dashboard' FontSize='13' FontWeight='SemiBold' Foreground='#FFFFFF'/>
            </StackPanel>
            <TextBlock x:Name='ClockText' Grid.Column='2' Text='00:00:00'
                       FontSize='13' FontFamily='Cascadia Mono' Foreground='#88FFFFFF'
                       VerticalAlignment='Center'/>
        </Grid>
    </Border>

    <!-- Main Content -->
    <ScrollViewer Grid.Row='1' VerticalScrollBarVisibility='Auto'>
        <StackPanel Padding='16,12,16,16' Spacing='10'>

            <!-- Row 1: CPU + Memory -->
            <Grid ColumnDefinitions='*,12,*'>
                <!-- CPU Card -->
                <Border Background='#20FFFFFF' CornerRadius='12' Padding='16'>
                    <StackPanel Spacing='8'>
                        <Grid ColumnDefinitions='Auto,*,Auto'>
                            <SymbolIcon Symbol='MapDrive' Foreground='#4CC2FF'/>
                            <TextBlock Grid.Column='2' x:Name='CpuPct' Text='0' FontSize='28'
                                       FontWeight='Bold' Foreground='#4CC2FF' FontFamily='Cascadia Mono'/>
                        </Grid>
                        <TextBlock Text='CPU Usage' FontSize='11' Foreground='#88FFFFFF'/>
                        <Border Background='#20FFFFFF' CornerRadius='3' Height='6'>
                            <Border x:Name='CpuBar' Background='#4CC2FF' CornerRadius='3' Height='6'
                                    HorizontalAlignment='Left' Width='0'/>
                        </Border>
                        <TextBlock x:Name='CpuCores' Text='' FontSize='10' Foreground='#55FFFFFF'/>
                    </StackPanel>
                </Border>

                <!-- Memory Card -->
                <Border Grid.Column='2' Background='#20FFFFFF' CornerRadius='12' Padding='16'>
                    <StackPanel Spacing='8'>
                        <Grid ColumnDefinitions='Auto,*,Auto'>
                            <SymbolIcon Symbol='Manage' Foreground='#8B5CF6'/>
                            <TextBlock Grid.Column='2' x:Name='MemPct' Text='0' FontSize='28'
                                       FontWeight='Bold' Foreground='#8B5CF6' FontFamily='Cascadia Mono'/>
                        </Grid>
                        <TextBlock Text='Memory' FontSize='11' Foreground='#88FFFFFF'/>
                        <Border Background='#20FFFFFF' CornerRadius='3' Height='6'>
                            <Border x:Name='MemBar' Background='#8B5CF6' CornerRadius='3' Height='6'
                                    HorizontalAlignment='Left' Width='0'/>
                        </Border>
                        <TextBlock x:Name='MemDetail' Text='' FontSize='10' Foreground='#55FFFFFF'/>
                    </StackPanel>
                </Border>
            </Grid>

            <!-- Row 2: Disk + Network -->
            <Grid ColumnDefinitions='*,12,*'>
                <!-- Disk Card -->
                <Border Background='#20FFFFFF' CornerRadius='12' Padding='16'>
                    <StackPanel Spacing='8'>
                        <Grid ColumnDefinitions='Auto,*,Auto'>
                            <SymbolIcon Symbol='MoveToFolder' Foreground='#2DB84D'/>
                            <TextBlock Grid.Column='2' x:Name='DiskPct' Text='0' FontSize='28'
                                       FontWeight='Bold' Foreground='#2DB84D' FontFamily='Cascadia Mono'/>
                        </Grid>
                        <TextBlock Text='Disk C:' FontSize='11' Foreground='#88FFFFFF'/>
                        <Border Background='#20FFFFFF' CornerRadius='3' Height='6'>
                            <Border x:Name='DiskBar' Background='#2DB84D' CornerRadius='3' Height='6'
                                    HorizontalAlignment='Left' Width='0'/>
                        </Border>
                        <TextBlock x:Name='DiskDetail' Text='' FontSize='10' Foreground='#55FFFFFF'/>
                    </StackPanel>
                </Border>

                <!-- Network Card -->
                <Border Grid.Column='2' Background='#20FFFFFF' CornerRadius='12' Padding='16'>
                    <StackPanel Spacing='8'>
                        <Grid ColumnDefinitions='Auto,*,Auto'>
                            <SymbolIcon Symbol='World' Foreground='#FF8C00'/>
                            <TextBlock Grid.Column='2' Text='NET' FontSize='14'
                                       FontWeight='Bold' Foreground='#FF8C00'/>
                        </Grid>
                        <Grid ColumnDefinitions='Auto,*,Auto' Margin='0,4,0,0'>
                            <TextBlock Text='IN' FontSize='10' Foreground='#55FFFFFF' Margin='0,0,6,0'/>
                            <TextBlock Grid.Column='2' x:Name='NetIn' Text='0 KB/s'
                                       FontSize='12' Foreground='#2DB84D' FontFamily='Cascadia Mono'/>
                        </Grid>
                        <Grid ColumnDefinitions='Auto,*,Auto'>
                            <TextBlock Text='OUT' FontSize='10' Foreground='#55FFFFFF' Margin='0,0,6,0'/>
                            <TextBlock Grid.Column='2' x:Name='NetOut' Text='0 KB/s'
                                       FontSize='12' Foreground='#E84040' FontFamily='Cascadia Mono'/>
                        </Grid>
                    </StackPanel>
                </Border>
            </Grid>

            <!-- Row 3: System Info Strip -->
            <Border Background='#20FFFFFF' CornerRadius='12' Padding='16,12'>
                <Grid ColumnDefinitions='*,*,*,*'>
                    <StackPanel HorizontalAlignment='Center'>
                        <TextBlock Text='UPTIME' FontSize='9' Foreground='#55FFFFFF'
                                   HorizontalAlignment='Center'/>
                        <TextBlock x:Name='Uptime' Text='0h 0m' FontSize='13'
                                   FontWeight='SemiBold' Foreground='#FFFFFF'
                                   HorizontalAlignment='Center' FontFamily='Cascadia Mono'/>
                    </StackPanel>
                    <StackPanel Grid.Column='1' HorizontalAlignment='Center'>
                        <TextBlock Text='PROCESSES' FontSize='9' Foreground='#55FFFFFF'
                                   HorizontalAlignment='Center'/>
                        <TextBlock x:Name='ProcCount' Text='0' FontSize='13'
                                   FontWeight='SemiBold' Foreground='#FFFFFF'
                                   HorizontalAlignment='Center' FontFamily='Cascadia Mono'/>
                    </StackPanel>
                    <StackPanel Grid.Column='2' HorizontalAlignment='Center'>
                        <TextBlock Text='BATTERY' FontSize='9' Foreground='#55FFFFFF'
                                   HorizontalAlignment='Center'/>
                        <TextBlock x:Name='BattText' Text='N/A' FontSize='13'
                                   FontWeight='SemiBold' Foreground='#FFFFFF'
                                   HorizontalAlignment='Center' FontFamily='Cascadia Mono'/>
                    </StackPanel>
                    <StackPanel Grid.Column='3' HorizontalAlignment='Center'>
                        <TextBlock Text='DATE' FontSize='9' Foreground='#55FFFFFF'
                                   HorizontalAlignment='Center'/>
                        <TextBlock x:Name='DateText' Text='' FontSize='13'
                                   FontWeight='SemiBold' Foreground='#FFFFFF'
                                   HorizontalAlignment='Center'/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Row 4: Top Processes -->
            <Border Background='#20FFFFFF' CornerRadius='12' Padding='16,12'>
                <StackPanel Spacing='6'>
                    <Grid ColumnDefinitions='Auto,*'>
                        <SymbolIcon Symbol='List' Foreground='#88FFFFFF'/>
                        <TextBlock Grid.Column='1' Text='  Top Memory Consumers' FontSize='11'
                                   Foreground='#88FFFFFF' VerticalAlignment='Center'/>
                    </Grid>
                    <Border Height='1' Background='#15FFFFFF' Margin='0,2'/>
                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock x:Name='Proc1Name' Text='-' FontSize='11' Foreground='#CCFFFFFF'/>
                        <TextBlock x:Name='Proc1Mem' Grid.Column='1' Text='' FontSize='11'
                                   Foreground='#8B5CF6' FontFamily='Cascadia Mono'/>
                    </Grid>
                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock x:Name='Proc2Name' Text='-' FontSize='11' Foreground='#CCFFFFFF'/>
                        <TextBlock x:Name='Proc2Mem' Grid.Column='1' Text='' FontSize='11'
                                   Foreground='#8B5CF6' FontFamily='Cascadia Mono'/>
                    </Grid>
                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock x:Name='Proc3Name' Text='-' FontSize='11' Foreground='#CCFFFFFF'/>
                        <TextBlock x:Name='Proc3Mem' Grid.Column='1' Text='' FontSize='11'
                                   Foreground='#8B5CF6' FontFamily='Cascadia Mono'/>
                    </Grid>
                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock x:Name='Proc4Name' Text='-' FontSize='11' Foreground='#CCFFFFFF'/>
                        <TextBlock x:Name='Proc4Mem' Grid.Column='1' Text='' FontSize='11'
                                   Foreground='#8B5CF6' FontFamily='Cascadia Mono'/>
                    </Grid>
                    <Grid ColumnDefinitions='*,Auto'>
                        <TextBlock x:Name='Proc5Name' Text='-' FontSize='11' Foreground='#CCFFFFFF'/>
                        <TextBlock x:Name='Proc5Mem' Grid.Column='1' Text='' FontSize='11'
                                   Foreground='#8B5CF6' FontFamily='Cascadia Mono'/>
                    </Grid>
                </StackPanel>
            </Border>

            <!-- Footer -->
            <TextBlock Text='Win+Alt+D to toggle  |  Built with AHK v2 + WinUI3'
                       FontSize='10' Foreground='#33FFFFFF' HorizontalAlignment='Center'
                       Margin='0,4,0,0'/>
        </StackPanel>
    </ScrollViewer>
</Grid>
)"

xg.Content := WinRT('Microsoft.UI.Xaml.Markup.XamlReader').Load(xaml)
try xg.Content.RequestedTheme := 2

; --- Custom title bar ---
try {
    _saved := OverloadedFunc.Prototype.GetOwnPropDesc('Add')
    OverloadedFunc.Prototype.DefineProp('Add', {Call: _PermissiveOverloadAdd})
    try {
        wid := WinRT('Microsoft.UI.WindowId')()
        wid.Value := xg.hwnd
        appWin := WinRT('Microsoft.UI.Windowing.AppWindow').GetFromWindowId(wid)
        tb := appWin.TitleBar
        tb.ExtendsContentIntoTitleBar := true

        bgRef   := _MakeIRefColor(0, 0, 0, 0)
        hoverBg := _MakeIRefColor(255, 0x33, 0x33, 0x33)
        pressBg := _MakeIRefColor(255, 0x44, 0x44, 0x44)
        fgRef   := _MakeIRefColor(255, 0xE0, 0xE0, 0xE0)
        hoverFg := _MakeIRefColor(255, 0xFF, 0xFF, 0xFF)
        pressFg := _MakeIRefColor(255, 0xFF, 0xFF, 0xFF)
        inactBg := _MakeIRefColor(0, 0, 0, 0)
        inactFg := _MakeIRefColor(255, 0x99, 0x99, 0x99)

        ComCall(9,  tb.ptr, "Ptr", bgRef)
        ComCall(11, tb.ptr, "Ptr", fgRef)
        ComCall(13, tb.ptr, "Ptr", hoverBg)
        ComCall(15, tb.ptr, "Ptr", hoverFg)
        ComCall(17, tb.ptr, "Ptr", inactBg)
        ComCall(19, tb.ptr, "Ptr", inactFg)
        ComCall(21, tb.ptr, "Ptr", pressBg)
        ComCall(23, tb.ptr, "Ptr", pressFg)
    }
    OverloadedFunc.Prototype.DefineProp('Add', _saved)
}

; --- CPU core count ---
coreCount := 0
for proc in ComObjGet("winmgmts:").ExecQuery("SELECT NumberOfLogicalProcessors FROM Win32_Processor")
    coreCount := proc.NumberOfLogicalProcessors
try xg['CpuCores'].Text := coreCount ' logical cores'

; --- Initial date ---
try xg['DateText'].Text := FormatTime(, 'MMM d')

; --- Seed CPU baseline ---
GetCPUUsage()
GetNetworkRate()
Sleep(100)

; Max bar width (approximate for card width minus padding)
global BAR_MAX := 140

; =============================================================================
; Top Processes (by working set)
; =============================================================================
GetTopProcesses(n := 5) {
    static PE_SIZE := A_PtrSize = 8 ? 568 : 556
    static EXE_OFFSET := A_PtrSize = 8 ? 44 : 36
    procs := []
    snap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x2, "UInt", 0, "Ptr")
    if snap = -1
        return procs
    pe := Buffer(PE_SIZE, 0)
    NumPut("UInt", PE_SIZE, pe)
    if DllCall("Process32FirstW", "Ptr", snap, "Ptr", pe) {
        loop {
            pid := NumGet(pe, 8, "UInt")
            name := StrGet(pe.Ptr + EXE_OFFSET, 260, "UTF-16")
            if pid > 0
                procs.Push({name: name, pid: pid, mem: 0})
        } until !DllCall("Process32NextW", "Ptr", snap, "Ptr", pe)
    }
    DllCall("CloseHandle", "Ptr", snap)

    ; Get working set for each
    for p in procs {
        hProc := DllCall("OpenProcess", "UInt", 0x0400 | 0x0010, "Int", 0, "UInt", p.pid, "Ptr")
        if hProc {
            pmc := Buffer(72, 0)
            if DllCall("psapi\GetProcessMemoryInfo", "Ptr", hProc, "Ptr", pmc, "UInt", 72)
                p.mem := NumGet(pmc, A_PtrSize = 8 ? 16 : 12, "UPtr")  ; WorkingSetSize
            DllCall("CloseHandle", "Ptr", hProc)
        }
    }

    ; Sort descending by mem (simple bubble sort for small n)
    loop procs.Length - 1 {
        i := A_Index
        loop procs.Length - i {
            j := A_Index
            if procs[j].mem < procs[j + 1].mem {
                tmp := procs[j], procs[j] := procs[j + 1], procs[j + 1] := tmp
            }
        }
    }

    result := []
    loop Min(n, procs.Length)
        result.Push(procs[A_Index])
    return result
}

; =============================================================================
; Update Loop
; =============================================================================
global tickCount := 0

UpdateDashboard() {
    global tickCount
    tickCount++

    try {
        ; Clock - every tick
        xg['ClockText'].Text := FormatTime(, 'HH:mm:ss')

        ; CPU
        cpu := GetCPUUsage()
        xg['CpuPct'].Text := cpu "%"
        xg['CpuBar'].Width := Max(1, cpu / 100 * BAR_MAX)

        ; Memory
        mem := GetMemoryInfo()
        xg['MemPct'].Text := mem.pct "%"
        xg['MemBar'].Width := Max(1, mem.pct / 100 * BAR_MAX)
        xg['MemDetail'].Text := mem.usedGB ' / ' mem.totalGB ' GB'

        ; Disk (every 5 ticks)
        if Mod(tickCount, 5) = 1 {
            disk := GetDiskInfo()
            xg['DiskPct'].Text := disk.pct "%"
            xg['DiskBar'].Width := Max(1, disk.pct / 100 * BAR_MAX)
            xg['DiskDetail'].Text := disk.usedGB ' / ' disk.totalGB ' GB'
        }

        ; Network
        net := GetNetworkRate()
        xg['NetIn'].Text := FormatRate(net.inKBs)
        xg['NetOut'].Text := FormatRate(net.outKBs)

        ; System info (every 3 ticks)
        if Mod(tickCount, 3) = 1 {
            xg['Uptime'].Text := GetUptime()
            xg['ProcCount'].Text := String(GetProcessCount())

            batt := GetBatteryInfo()
            if batt.hasBattery
                xg['BattText'].Text := String(batt.pct) "%" (batt.charging ? "+" : "")
            else
                xg['BattText'].Text := 'AC'

            xg['DateText'].Text := FormatTime(, 'MMM d')
        }

        ; Top processes (every 5 ticks - expensive)
        if Mod(tickCount, 5) = 0 {
            top := GetTopProcesses(5)
            loop 5 {
                if A_Index <= top.Length {
                    xg['Proc' A_Index 'Name'].Text := top[A_Index].name
                    xg['Proc' A_Index 'Mem'].Text := String(Round(top[A_Index].mem / (1024 * 1024), 1)) " MB"
                }
            }
        }
    }
}

FormatRate(kbs) {
    if kbs >= 1024
        return Round(kbs / 1024, 1) ' MB/s'
    return Round(kbs, 1) ' KB/s'
}

; =============================================================================
; Start
; =============================================================================
xg.Show("w420 h580")
xg.NavigateFocus('First')

; Start the live update timer - 1 second interval
SetTimer(UpdateDashboard, 1000)
; Run once immediately
UpdateDashboard()

; Hotkey to toggle visibility
#!d:: {
    static visible := true
    if visible
        xg.Hide()
    else
        xg.Show()
    visible := !visible
}
