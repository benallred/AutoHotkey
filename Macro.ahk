#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn   ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notes
;; #=Win; ^=Ctrl; +=Shift; !=Alt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants

null =

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Script Startup

SoundPlay *64
TrayTip, Macro.ahk, Loaded

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#`::
	; (Example) Set AboveNormal priority on HPC job
;	Send +{F10}m!o{Down}{Enter}
;	Sleep 1500
;	Send {Up}
return

#^+`::
	Reload
	Sleep 100
	SoundPlay *16
	return

#^+!`::
	TrayTip, Macro.ahk, Exiting!
	Sleep 5000
	ExitApp