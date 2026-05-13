#Requires AutoHotkey v2.0
#SingleInstance Force

; Re-launch as admin if not already elevated
if !A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; Load the DLL (put VirtualDesktopAccessor.dll next to this script)
global hVDA := DllCall("LoadLibrary", "Str", A_ScriptDir "\VirtualDesktopAccessor.dll", "Ptr")

FocusTopWindow() {
    ; Give the desktop transition a moment to settle
    Sleep 150 
    
    ids := WinGetList()
    targetHwnd := 0

    ; Loop through all windows in Z-order (top to bottom)
    for index, hwnd in ids {
        try {
            class := WinGetClass(hwnd)
            
            ; Skip the desktop background, taskbar, and hidden system wrappers
            if (class = "WorkerW" || class = "Shell_TrayWnd" || class = "Progman" || class = "ApplicationFrameWindow")
                continue
                
            ; Skip invisible windows
            style := WinGetStyle(hwnd)
            if !(style & 0x10000000) ; WS_VISIBLE
                continue
                
            ; Skip windows without titles (usually background phantom processes)
            if (WinGetTitle(hwnd) = "")
                continue
            
            ; Check if this window actually lives on the desktop we just switched to
            isOnCurrent := DllCall(A_ScriptDir "\VirtualDesktopAccessor.dll\IsWindowOnCurrentVirtualDesktop", "Ptr", hwnd, "Int")
            
            if (isOnCurrent) {
                targetHwnd := hwnd
                break ; We found the top-most valid app, stop searching
            }
        }
    }

    ; If we found a valid application window, forcefully pull it to the front
    if (targetHwnd) {
        foreHwnd := DllCall("GetForegroundWindow", "Ptr")
        foreThread := DllCall("GetWindowThreadProcessId", "Ptr", foreHwnd, "Ptr", 0, "UInt")
        curThread := DllCall("GetCurrentThreadId", "UInt")

        ; Temporarily attach our script's thread to the foreground thread to bypass Windows lock
        if (foreThread != curThread)
            DllCall("AttachThreadInput", "UInt", curThread, "UInt", foreThread, "Int", 1)

        DllCall("SetForegroundWindow", "Ptr", targetHwnd)
        DllCall("BringWindowToTop", "Ptr", targetHwnd)

        if (foreThread != curThread)
            DllCall("AttachThreadInput", "UInt", curThread, "UInt", foreThread, "Int", 0)

        WinActivate(targetHwnd)
    }
}

GoToDesktop(num) {
    DllCall(A_ScriptDir "\VirtualDesktopAccessor.dll\GoToDesktopNumber", "Int", num)
    FocusTopWindow()
}

MoveWindow(num) {
    try {
        hwnd := WinExist("A")
        if hwnd
            DllCall(A_ScriptDir "\VirtualDesktopAccessor.dll\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", num)
    }
}

; Win + Shift + 1..9 → move active window to desktop N
#+1::MoveWindow(0)
#+2::MoveWindow(1)
#+3::MoveWindow(2)
#+4::MoveWindow(3)
#+5::MoveWindow(4)
#+6::MoveWindow(5)
#+7::MoveWindow(6)
#+8::MoveWindow(7)
#+9::MoveWindow(8)

; Win + Shift + Q → close active window
#+q::WinClose("A")

; Win + 1..9 → switch to desktop (0-indexed)
#1::GoToDesktop(0)
#2::GoToDesktop(1)
#3::GoToDesktop(2)
#4::GoToDesktop(3)
#5::GoToDesktop(4)
#6::GoToDesktop(5)
#7::GoToDesktop(6)
#8::GoToDesktop(7)
#9::GoToDesktop(8)