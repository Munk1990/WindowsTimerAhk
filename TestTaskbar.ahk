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

updateProgressBar:
{
	progret := SetTaskbarProgress(50, N, timerId_u)
	msgbox, Progess: %progret%
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

	if (!isRunning_u || !isStarted_u){
		return
	}

	;Check when the timer had started
	;Calculate how much time has elapsed since
	elapsedSeconds_u = %A_Now%
	EnvSub, elapsedSeconds_u, %timerStart_u%, S
	
	progressPct := (elapsedSeconds_u/timerPeriod_u*100)
	GuiControl,,Var, %elapsedSeconds_u%s of %timerPeriod_u%s Completed. %progressPct%/100
	
	SetTaskbarProgress(progressPct, N)
	GuiControl,, MyProgress, %progressPct%
	

	;Compare with timerPeriod_u
	if (elapsedSeconds_u >= timerPeriod_u){
		msgbox, Timer of %timerPeriod_u% seconds is over
		Gosub, subStartStop
	}

}
return

GuiClose:
GuiEscape:
ExitApp


;-----------------------------------


/*


subOk:
{
	; Get time into variable
	; Add period to current time
	; Loop with sleep to check if curtime < totaltime
	gui, submit, nohide
	startTime = %A_Now%
	timerPeriod := (timeEdit*60)
	timerStart = %A_Now%
	timerEnd = %A_Now%
	EnvAdd, timerEnd, timerPeriod, S
	SetTaskbarProgress(0, N)
	elapsedSeconds := 0
	isPaused := false


	Gosub, startTimer

}
return

subPause:
{
	msgbox, Entering paused subroutine with isPaused = %isPaused%
	if (isPaused)
	{
		isPaused := false
		Gosub, startTimer

	} 
	else
	{
		isPaused := true
	}
}
return 

subCancel:
{
	msgbox, You clicked the cancel button
}
return

updateTimer:
{
	remainingPeriod := timerPeriod - elapsedSeconds
	endTime = %A_Now%
	EnvAdd, endTime, remainingPeriod, S
	timerStart = %A_Now%
	EnvAdd, timerStart, -elapsedSeconds, S
	loop
		{
			if (isPaused){
				break
			}
			remainingPeriod := endTime
			EnvSub, remainingPeriod, %A_Now%, S
			if (remainingPeriod <= 0) {
				msgbox, Enter comparison
				break
			}
			elapsedSeconds = %A_Now%
			EnvSub, elapsedSeconds, %timerStart%, S
			GuiControl,,Var, %elapsedSeconds%s Completed
			if (%timerEnd% < %A_Now%)
				break
			progressPct := (elapsedSeconds/timerPeriod*100)
			SetTaskbarProgress(progressPct)
			sleep 500
		}
	
}
return 
*/