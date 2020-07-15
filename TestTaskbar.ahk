#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include SetTaskbarProgress.ahk

SetFormat, float, 6.2



Gui, Font, s10
Gui, Add, Text,x10 y10 w200 h15, % "Timer duration (minutes)"
Gui, Add, Edit,r1 vtimeEdit x180 y10 w52 h15, 60
Gui, Add, Button, Default x10 y50 w80 h30 gsubStartStop vstartText, Start
Gui, Add, Button, x152 y50 w80 h30 gsubPauseResume vpauseText, Pause
Gui, Add, Text,vVar x10 y90 w222, Enter period
Gui, Add, Progress, x10 y120 w222 h100 vMyProgress c808080 BackgroundC0C0C0
Gui, Show        ; Show the window and taskbar button.
Gui, +LastFound  ; SetTaskbarProgress will use this window.
SetTaskbarProgress(100, "E")
GuiControl,,Var,Hello User!
timerId_u := ""
WinGet, timerId_u





; Variables to store the timer details
timerPeriod_u = 0
timerStart_u = %A_Now%
timerEnd_u = %A_Now%
elapsedSeconds_u := 0
isStarted_u := false
isRunning_u := false
loop{
	Gosub, subUpdateTimer
	sleep 500
}
return

subStartStop:
{
	if (isStarted_u) {
		isStarted_u := false
		isRunning_u := false
		GuiControl,,Var, Timer Stopped!
		GuiControl,,startText, Start


	} else {
		gui, submit, nohide
		timerStart_u := A_Now
		timerPeriod_u := timeEdit * 60
		isStarted_u := true
		isRunning_u := true
		GuiControl,,startText, Stop
	}
}
return

subPauseResume:
{
	if (isRunning_u) {
		isRunning_u := false
		GuiControl,, pauseText, Resume
		GuiControl,,Var, Timer Paused!
		
	} else {
		isRunning_u := true
		GuiControl,, pauseText, Pause
		timerStart_u = %A_Now%
		EnvAdd, timerStart_u, -elapsedSeconds_u, S
	}
}
return

subUpdateTimer:
{
	#Include SetTaskbarProgress.ahk


	if (isRunning_u) {
		SetTaskbarProgress("N", timerId_u)
	} else if (isStarted_u) {
		SetTaskbarProgress("P", timerId_u)
	} else {
		SetTaskbarProgress(100, "E", timerId_u)
	}

	if (!isRunning_u || !isStarted_u){
		return
	}

	;Check when the timer had started
	;Calculate how much time has elapsed since
	elapsedSeconds_u = %A_Now%
	EnvSub, elapsedSeconds_u, %timerStart_u%, S
	
	progressPct := (elapsedSeconds_u/timerPeriod_u*100)
	GuiControl,,Var, %elapsedSeconds_u%s of %timerPeriod_u%s Completed. %progressPct%/100
	
	SetTaskbarProgress(progressPct)
	GuiControl,, MyProgress, %progressPct%
	

	;Compare with timerPeriod_u
	if (elapsedSeconds_u >= timerPeriod_u){
		SetTaskbarProgress(100, "E")
		msgbox, Timer of %timerPeriod_u% seconds is over
		Gosub, subStartStop
	}

}
return


GuiClose:
	ExitApp
return

GuiEscape:
	ExitApp
return


~Capslock::
    ;; must use downtemp to emulate hyper key, you cannot use down in this case 
    ;; according to https://autohotkey.com/docs/commands/Send.htm, downtemp is as same as down except for ctrl/alt/shift/win keys
    ;; in those cases, downtemp tells subsequent sends that the key is not permanently down, and may be 
    ;; released whenever a keystroke calls for it.
    ;; for example, Send {Ctrl Downtemp} followed later by Send {Left} would produce a normal {Left}
    ;; keystroke, not a Ctrl{Left} keystroke
    Send {Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}{LWin DownTemp}
    KeyWait, Capslock
    Send {Ctrl Up}{Shift Up}{Alt Up}{LWin Up}
    if (A_PriorKey = "Capslock") {
        Send {Esc}
    }
return


~Capslock & p::
	SetTaskbarProgress("P")
	Gosub, subPauseResume
return

