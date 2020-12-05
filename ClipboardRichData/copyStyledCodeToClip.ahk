;ref: https://autohotkey.com/board/topic/74670-class-winclip-direct-clipboard-manipulations/page-4#entry502253

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include <WinClipAPI>
#Include <WinClip>


CopyCode(HtmlCodeFile) {
	WinClip.Clear()
	html := FileOpen(HtmlCodeFile, "r").read()
	WinClip.SetHTML(html)
	WinClip.Paste()
	Return
}

CopyCode("bubble_sort.html")