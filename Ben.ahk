#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notes
;; #=Win; ^=Ctrl; +=Shift; !=Alt

ClickCounter = 0
LastClickTime = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants

null =

;;;;;;;;;;
;; Windows Messages (http://www.autohotkey.com/docs/misc/SendMessageList.htm)
WM_NCHITTEST = 0x84
WM_SYSCOMMAND = 0x112

;;;;;;;;;;
;; WM_NCHITTEST Return Values (http://msdn.microsoft.com/en-us/library/windows/desktop/ms645618(v=vs.85).aspx)
HTCAPTION   =  2 ; In a title bar.
HTSYSMENU   =  3 ; In a window menu or in a Close button in a child window.
HTMINBUTTON =  8 ; In a Minimize button.
HTMAXBUTTON =  9 ; In a Maximize button.
HTCLOSE     = 20 ; In a Close button.
HTHELP      = 21 ; In a Help button.

;;;;;;;;;;
;; WM_SYSCOMMAND Parameters (http://msdn.microsoft.com/en-us/library/windows/desktop/ms646360(v=vs.85).aspx)
SC_CLOSE = 0xF060 ; Closes the window.

;;;;;;;;;;
;; Mouse Cursors (http://msdn.microsoft.com/en-us/library/windows/desktop/ms648391(v=vs.85).aspx)
IDC_ARROW = 32512 ; Standard arrow
IDC_CROSS = 32515 ; Crosshair
IDC_IBEAM = 32513 ; I-beam

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Startup

Menu, Tray, Icon, BenAutoHotkey.ico, , 1
SoundPlay *64
TrayTip, Ben.ahk, Loaded!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AutoHotkey Shortcuts

#^+e::Edit

#^+t::
Run, devenv.exe %A_ScriptFullPath% /edit
return

#^+r::
	Reload
	Sleep 100
	SoundPlay *16
;	MsgBox, 52, , The script could not be reloaded.  Would you like to open it for editing?
;	IfMsgBox, Yes, Edit
	return

#^+s::
	Suspend, Toggle
	if A_IsSuspended = 1
	{
		Menu, Tray, Icon, BenAutoHotkey-Suspend.ico, , 1
		TrayTip, Ben.ahk, Suspended!
	}
	else
	{
		Menu, Tray, Icon, BenAutoHotkey.ico, , 1
		TrayTip, Ben.ahk, Resumed!
	}
	return

;#^+l::ListHotkeys

#^+h::Run "%ProgramFiles%\AutoHotkey\AutoHotkey.chm"

#^+m::
	Run ".\Macro.ahk"
	Run notepad ".\Macro.ahk"
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;#IfWinActive, ahk_class Notepad
;WinClose, ahk_class Notepad
;#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Programs

#n::Run notepad

#s::
	RegRead, origImagesPath, HKEY_CURRENT_USER, Control Panel\Screen Saver.Slideshow, ImageDirectory
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Screen Saver.Slideshow, ImageDirectory, C:\Ben\Settings\Backgrounds - Work
	Sleep 500
	Run "C:\Ben\Programs\Microsoft\Screensaver\XP\ssmypics.scr" /s
	Sleep 500
	RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Screen Saver.Slideshow, ImageDirectory, %origImagesPath%
return

#IfWinActive, ahk_class Notepad
^=::Send !of!s{Down}{Enter}
^-::Send !of!s{Up}{Enter}
#IfWinActive

#v::
	clipboardOrig := ClipboardAll
	Clipboard := Clipboard
	Send ^v
	Sleep 500 ; clipboardOrig was being copied back before ^v happened
	Clipboard := clipboardOrig
	clipboardOrig = ; free memory in case clipboard was large
return

#IfWinActive, ahk_class IEFrame
::minussites::-site:fixya.com
#IfWinActive

#t::
	todo := []
	Input key, L1 M T1
	if key = w
	{
		todo.Insert({ Description:"Family Tree", Minutes:20, Commands:["http://www.ancestry.com"] })
		todo.Insert({ Description:"Random Wikipedia page", Minutes:20, Commands:["C:\Program Files\Internet Explorer\iexplore.exe ""http://en.wikipedia.org/wiki/Special:Random""", {Monitor:2,State:"max"}, "http://en.wikipedia.org/wiki/Main_Page"] })
	}
	else if key = h
	{
		todo.Insert({ Description:"Scripture Study", Minutes:20, Commands:[] })
		todo.Insert({ Description:"Download new audio book", Minutes:2, Commands:["iexplore", "C:\Program Files (x86)\OverDrive for Windows\MediaConsole.exe"] })
		todo.Insert({ Description:"Ripping pipeline (Ember)", Minutes:2, Commands:["N:\zMovies", {Monitor:1,Left:0,Top:0}, "N:\zTV", {Monitor:1,Right:0,Top:0}, "M:\zMovies", {Monitor:1,Left:0,Bottom:0}, "M:\zTV", {Monitor:1,Right:0,Bottom:0}, "C:\Ben\Programs\Ember Media Manager\Ember_1.3.0.20\Ember Media Manager.exe"] })
		todo.Insert({ Description:"Ripping pipeline (MKV)", Minutes:1, Commands:["P:\Original Media - Can Delete\Ripped", {Monitor:1,Left:"center",Top:"center"}, "C:\Program Files\Handbrake\Handbrake.exe", {WaitWinTitle:"HandBrake",Monitor:2,Left:"center",Top:"center"}] })
		todo.Insert({ Description:"Ripping pipeline (Rip)", Minutes:1, Commands:["C:\Program Files (x86)\SlySoft\AnyDVD\AnyDVD.exe -iso"] })
		todo.Insert({ Description:"Cleanup desk", Minutes:5, Commands:[] })
	}

	if todo.MaxIndex() = ""
	{
		send #t
	}
	else
	{
		Gui, AutoToDo:New
		for i, item in todo
		{
			Gui, Add, Text, v%i%Description x10, % item.Description
			Gui, Add, Button, v%i% yp-5 x150, % "   Go   "
		}

		Gui, Show, , AutoToDo
		WinGetPos, , , guiWidth, guiHeight, A
		SysGet, primaryMonitor, MonitorWorkArea
		SysGet, borderWidth, 32 ; SM_CXSIZEFRAME
		SysGet, borderHeight, 33 ; SM_CYSIZEFRAME
		WinMove, A, , primaryMonitorRight - guiWidth - borderWidth, primaryMonitorBottom - guiHeight - borderHeight
	}
return

AutoToDoButtonGo:
	item := todo[A_GuiControl]
	status := item.Description " (" item.Minutes " min)" ; `n`nExecuted commands:`n"
	for j, command in item.Commands
	{
		if IsObject(command)
		{
			status := status . "`n`t"
			if (command.Sleep != "")
			{
				status := status " S:" command.Sleep
				sleep, command.Sleep
				WinWait, A
			}
			if (command.WaitWinTitle != "")
			{
				status := status " W"
				WinWait, % command.WaitWinTitle
			}
			if (command.Monitor != "")
			{
				SysGet, mon, MonitorWorkArea, % command.Monitor
				status := status " M:" command.Monitor
			}
			else
			{
				SysGet, mon, MonitorWorkArea, 1
			}
			monWidth  := monRight  - monLeft
			monHeight := monBottom - monTop
			if command.State != ""
			{
				status := status " " command.State
				if (command.State = "restore")
				{
					WinRestore
				}
				else if (command.State = "min")
				{
					WinMinimize
				}
				else if (command.State = "max")
				{
					WinMaximize
				}
			}
			WinGetPos, lastRunX, lastRunY, lastRunWidth, lastRunHeight
			if command.Left != ""
			{
				if (command.Left = "center")
				{
					newX := monLeft + (monWidth / 2 - lastRunWidth / 2)
				}
				else
				{
					newX := monLeft + command.Left
				}
				status := status . " L:" . command.Left
			}
			else if command.Right != ""
			{
				newX := monRight - lastRunWidth - command.Right
				status := status . " R:" . command.Right
			}
			else
			{
				newX := lastRunX
			}
			if command.Top != ""
			{
				if (command.Top = "center")
				{
					newY := monTop + (monHeight / 2 - lastRunHeight / 2)
				}
				else
				{
					newY := monTop + command.Top
				}
				status := status . " T:" . command.Top
			}
			else if command.Bottom != ""
			{
				newY :=  monBottom - lastRunHeight - command.Bottom
				status := status . " B:" . command.Bottom
			}
			else
			{
				newY := lastRunY
			}
			WinMove, newX, newY
		}
		else if command is digit
		{
			status := status "`n`tS:" command
			sleep, command
		}
		else
		{
			startSubStr := StrLen(command) - 200 / item.Commands.MaxIndex()
			status := status "`n`t" SubStr(command, startSubStr > 0 ? startSubStr : 1)
			run, % command, , , lastRunPID
			sleep, 1000
			WinWait, A
		}
	}
	TrayTip, Ben.ahk AutoToDo, % status
	GuiControl, Hide, % A_GuiControl
;	GuiControl, Hide, % A_GuiControl "Description"
;	Gui, Show, AutoSize
	descriptionClosure_%A_GuiControl% := item.Description " (" item.Minutes " min)"
	sleep, item.Minutes * 60*1000
	if (descriptionClosure_%A_GuiControl% = item.Description " (" item.Minutes " min)")
	{
		Loop 20
		{
			Gui, Flash
			Sleep, 500
		}
		MsgBox, , Ben.ahk AutoToDo, % "Allotted time completed for """ descriptionClosure_%A_GuiControl% """"
	}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OneNote

#d::
Input key, L1 M T1
if key = s
{
	daysUntilSunday := 8 - A_WDay
;	thisSundayDay := A_DD + daysUntilSunday
;	thisSundayMonth := thisSundayDay > A_DD ? A_MM + 0 : mod(A_MM, 12) + 1
;	if (thisSundayDay < 10)
;	{
;		thisSundayDay = 0%thisSundayDay%
;	}
;	if (thisSundayMonth < 10)
;	{
;		thisSundayMonth = 0%thisSundayMonth%
;	}
;	send Week ending %thisSundayMonth%-%thisSundayDay%, Sunday
	date = %A_Now%
	date += daysUntilSunday, days
	FormatTime, dateString, %date%, 'Week ending' MM-dd, 'Sunday'
	send %dateString%
}
else if key = w
{
	send 월 - {enter}화 - {enter}수 - {enter}목 - {enter}금 - {enter}토 - {enter}일 -{space}
}
else if (key = "=" || key = "+" || key = "-")
{
	date = %A_Now%
	Input key2, L1 M T1
	if (key2 >= 1 && key2 <= 9)
	{
		if (key = "-")
		{
			date += key2 * -1, days
		}
		else if (key = "=" || key = "+")
		{
			date += key2, days
		}
	}
	FormatTime, dateString, %date%, yyyy-MM-dd, dddd
	send %dateString%
}
else
{
	send %A_YYYY%-%A_MM%-%A_DD%, %A_DDDD%
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Visual Studio

#IfWinActive, ahk_exe devenv.exe

; Open solution folder
#^e::Send ^ws{Home}+{F10}x

; Open PowerShell in solution folder
#^p::
	Gosub, #^e
	WinWaitActive, ahk_class CabinetWClass
	WinGet, solutionFolderId, ID
	Send !fsa
	WinWaitActive, ahk_class ConsoleWindowClass
	WinClose, ahk_id %solutionFolderId%
return

#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autofills

$#a::
;Transform, CtrlN, Chr, 14 ; Store the character for Ctrl-N in the CtrlN var. 
Input, key, L1 M T1
if key = n
{
	Input, key2, L1 M T1
	if key2 = t
	{
		Input, key3, L1 M T1
		if key3 = 1
		{
			SendInput FirstName{tab}LastName
		}
		else
		{
			SendInput FirstName{tab}{tab}LastName
		}
	}
	else
	{
		SendInput FirstName LastName
	}
}
else if key = a
{
	Input, key2, L1 M T1
	if key2 = 2
	{
		SendInput City{tab}STATE{tab}Zip
	}
	else
	{
		SendInput AddressLine1
	}
}
else if key = p
{
	Input, key2, L1 M T1
	if key2 = t
	{
		SendInput 123{tab}456{tab}7890
	}
	else if key2 = a
	{
		SendInput 1234567890
	}
	else
	{
		SendInput 123-456-7890
	}
}
else if key = e
{
	SendInput you@domain.com
}
else if key = b
{
	SendInput 01/01/1900
}
else if key = u
{
	SendInput UserName
}
else
{
	SendInput #a
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window Manipulation

$#w::
Input, key, L1 M T1
if key = t
{
	WinSet, AlwaysOnTop, Toggle, A
}
else if key = r
{
	Input, key2, L1 M T1
	if (key2 >= 1 && key2 <= 9)
	{
		WinSet, Transparent, % key2 * 25.5, A
	}
	else if key2 = p
	{
		TrayTip, Ben.ahk, Click pixel to choose color, 10
		;HCURSOR := DllCall("LoadCursor", "UInt", null, "Int", IDC_CROSS)
		;HCURSOR := DllCall("CopyIcon", "UInt", HCURSOR)
		;qwer := DllCall("SetSystemCursor", "UInt", HCURSOR, "Int", IDC_ARROW)
		;TrayTip, Ben.ahk, %HCURSOR%`n%qwer%
		;Input, key3, L1 M T10
		Hotkey, LButton, On
		KeyWait, LButton, D T10
		if ErrorLevel = 0
		{
			MouseGetPos, mouseX, mouseY
			PixelGetColor, color, %mouseX%, %mouseY%
			TrayTip, Ben.ahk, Pixel color: %color%
		}
		else
		{
			TrayTip, Ben.ahk, Canceled
		}
		Hotkey, LButton, Off
	}
	else
	{
		WinSet, Transparent, Off, A
	}
}
else if key = w
{
	;;;;;;;;;;
	; Setup - Don't need to touch this
	SysGet, monCount, MonitorCount
	SysGet, mon1, MonitorWorkArea, 1
	if monCount > 2 ; greater than 2 instead of 1 lets me extend the laptop monitor to a presentation screen (projector/TV) and still rearrange windows as if there was only one monitor
	{
		SysGet, mon2, MonitorWorkArea, 2
;		SysGet, mon3, MonitorWorkArea, 3
;		SysGet, mon4, MonitorWorkArea, 4
; for some reason, after monitor 3 died and plugging in a new one in its place, monitors 3 and 4 are getting switched here (even though windows correctly identifies them)
		SysGet, mon3, MonitorWorkArea, 4
		SysGet, mon4, MonitorWorkArea, 3
	}
	else
	{
		SysGet, mon2, MonitorWorkArea, 1
		SysGet, mon3, MonitorWorkArea, 1
		SysGet, mon4, MonitorWorkArea, 1
	}
	mon1Width  := mon1Right  - mon1Left
	mon1Height := mon1Bottom - mon1Top
	mon2Width  := mon2Right  - mon2Left
	mon2Height := mon2Bottom - mon2Top
	mon3Width  := mon3Right  - mon3Left
	mon3Height := mon3Bottom - mon3Top
	mon4Width  := mon4Right  - mon4Left
	mon4Height := mon4Bottom - mon4Top
;TrayTip, Ben.ahk, %mon1Left% %mon2Left% %mon3Left% %mon4Left%
	
	SetWinDelay, -1
	SetTitleMatchMode, 2
	
	;;;;;;;;;;
	; Your settings
	;
	; Should all follow the format
	;	WinRestore <- if the window is currently maximized (whether you want it maximized or not) moving and/or resizing a maximized window works but causes border display issues
	;	WinMove
	;	WinMaximize <- if desired
	
	; Monitor 1
	WinRestore, Lync
	WinGetPos, , , LyncWidth, LyncHeight, Lync
	WinMove, Lync, , mon1Right - LyncWidth, mon1Bottom - LyncHeight
	
	; Monitor 2
	WinRestore, LINQPad 4
	WinMove, LINQPad 4, , mon2Left, mon2Top
	WinMaximize, LINQPad 4
	
	; Monitor 3
	WinRestore, - Outlook
	WinMove, - Outlook, , mon3Left, mon3Top, mon3Width < 1200 ? mon3Width : 1200, mon3Height < 1240 ? mon3Height : 1240
;	WinRestore, Windows Media Player
;	WinMove, Windows Media Player, , mon3Right - 564, mon3Bottom - 650, 564, 650
	WinRestore, - OneNote
	WinMove, - OneNote, , mon3Left, mon3Bottom - 718, 785, 718
	
	; Monitor 4
;	GroupAdd, InternetExplorerGroup, ahk_class IEFrame
	WinGet, internetExplorerId, List, ahk_class IEFrame
	Loop, %internetExplorerId%
	{
		currentId := internetExplorerId%A_Index%
		WinRestore, ahk_id %currentId%
		WinMove, ahk_id %currentId%, , mon4Left, mon4Top
		WinMaximize, ahk_id %currentId%
	}
	
	; Resize only
	WinMove, ahk_class CabinetWClass, , , , 880, 600
	
	; Visual Studio Window Layout
	visualStudioWindowLayout := monCount > 2 ? 1 : 2
	WinGet, visualStudioId, List, - Microsoft Visual Studio
	Loop, %visualStudioId%
	{
		currentId := visualStudioId%A_Index%
		ControlSend, , {Alt down}{Shift down}%visualStudioWindowLayout%{Shift up}{Alt up}, ahk_id %currentId%
	}
	
	; All monitors
	if monCount = 1
	{
		WinMinimizeAll
	}
}
else if key = s
{
	RegRead, screenSaverPath, HKEY_CURRENT_USER, Control Panel\Desktop, SCRNSAVE.EXE
	if (screenSaverPath <> null)
	{
;		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, ScreenSaveActive, 0
;		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, ScreenSaveTimeOut, 0
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, ScreenSaverIsSecure, 0
		RegDelete, HKEY_CURRENT_USER, Control Panel\Desktop, SCRNSAVE.EXE
		TrayTip, Ben.ahk, Screen Saver Disabled!
		ToolTip, Screen Saver Disabled, 1920, 1157
	}
	else
	{
;		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, ScreenSaveActive, 1
;		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, ScreenSaveTimeOut, 180
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, ScreenSaverIsSecure, 1
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, SCRNSAVE.EXE, C:\Ben\Programs\MICROS~1\SCREEN~1\XP\ssmypics.scr
		TrayTip, Ben.ahk, Screen Saver Enabled!
		ToolTip
	}
}
else
{
	SendInput #w
}
return

#IfWinNotActive, ahk_class IEFrame
~MButton::
CoordMode, Mouse, Screen
MouseGetPos, mouseX, mouseY, windowUnderCursor
if WinExist("ahk_class Shell_TrayWnd") != windowUnderCursor
{
	SendMessage, WM_NCHITTEST, , ( mouseY << 16 )|mouseX, , ahk_id %windowUnderCursor%
	WM_NCHITTEST_Result = %ErrorLevel%
;	If WM_NCHITTEST_Result = %HTCAPTION%
	If WM_NCHITTEST_Result in %HTCAPTION%,%HTSYSMENU%,%HTMINBUTTON%,%HTMAXBUTTON%,%HTCLOSE%,%HTHELP%
	{
		PostMessage, WM_SYSCOMMAND, SC_CLOSE, , , ahk_id %windowUnderCursor%
	}
	else
	{
		CoordMode, Mouse, Relative
		MouseGetPos, , mouseRelY
		SysGet, captionBarHeight, 31
		SysGet, borderHeight, 33
		if (mouseRelY <= captionBarHeight + borderHeight)
		{
			PostMessage, WM_SYSCOMMAND, SC_CLOSE, , , ahk_id %windowUnderCursor%
		}
	}
}
return
#IfWinNotActive

;;;;;;;;;;
;; Window Dragging

;#LButton::
;LButton::Send {LButton}
~LButton & RButton::
CoordMode, Mouse
MouseGetPos, mouseStartX, mouseStartY, windowUnderCursor
WinGetPos, originalX, originalY,,, ahk_id %windowUnderCursor%
WinGet, windowState, MinMax, ahk_id %windowUnderCursor%
SetWinDelay, -1
WinActivate, ahk_id %windowUnderCursor%
; if the window isn't minimized or maximized
if windowState = 0
	SetTimer, DragMouseTimer, 10
return

DragMouseTimer:
GetKeyState, lbuttonState, LButton, P
; left mouse button released, stop moving
if lbuttonState = U
{
	SetTimer, DragMouseTimer, off
	return
}
GetKeyState, escapeState, Escape, P
; escape button pressed, cancel
if escapeState = D
{
	SetTimer, DragMouseTimer, off
	WinMove, ahk_id %windowUnderCursor%,, %originalX%, %originalY%
	return
}
; else move the window to follow the mouse
CoordMode, Mouse
MouseGetPos, mouseX, mouseY
WinGetPos, windowX, windowY, , , ahk_id %windowUnderCursor%
SetWinDelay, -1
WinMove, ahk_id %windowUnderCursor%, , windowX + mouseX - mouseStartX, windowY + mouseY - mouseStartY
mouseStartX := mouseX
mouseStartY := mouseY
return

;~LButton::
;if (A_TickCount > LastClickTime + 1500)
;{
;	ClickCounter = 0
;	LastClickTime := A_TickCount
;}
;else
;{
;	if (ClickCounter < 3)
;	{
;		ClickCounter := ClickCounter + 1
;		LastClickTime := A_TickCount
;	}
;	else
;	{
;		SysGet, mon1, MonitorWorkArea, 1
;		SysGet, mon2, MonitorWorkArea, 2
;		SysGet, mon3, MonitorWorkArea, 3
;		SysGet, mon4, MonitorWorkArea, 4
;		CoordMode, Mouse
;		MouseGetPos, mouseX, mouseY
;		if (mouseX < mon3Right)
;		{
;			x := mon3Left
;			y := mon3Top
;			w := mon3Right - mon3Left
;			h := mon3Bottom - mon3Top
;		}
;		else if (mouseX < mon1Right)
;		{
;			x := mon1Left
;			y := mon1Top
;			w := mon1Right - mon1Left
;			h := mon1Bottom - mon1Top
;		}
;		else if (mouseX < mon2Right)
;		{
;			x := mon2Left
;			y := mon2Top
;			w := mon2Right - mon2Left
;			h := mon2Bottom - mon2Top
;		}
;		else if (mouseX < mon4Right)
;		{
;			x := mon4Left
;			y := mon4Top
;			w := mon4Right - mon4Left
;			h := mon4Bottom - mon4Top
;		}
;		Progress, zh0 fs400 zY200 ct880000 w%w% h%h% x%x%, 그만!
;		Sleep 5000
;		Progress, Off
;	}
;}
;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions

SplashText(text)
{
	SplashTextOn, , , %text%
	Sleep StrLen(text) * 150
	SplashTextOff
}