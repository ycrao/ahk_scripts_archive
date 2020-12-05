; WinClip by Deo:
; -> http://www.autohotkey.com/board/topic/74670-class-winclip-direct-clipboard-manipulations/
#Include <WinClipAPI>
#Include <WinClip>

CopyImage("dog-kill.gif")

CopyImage(ImageFile) {
	WinClip.Clear()

	; Make sure ImageFile is full path
	Loop, %ImageFile%
		ImageFile := A_LoopFileLongPath

	WinClip.SetHTML( "<IMG src=""" ImageFile """>" )

	; Below two lines might not needed.
	WinClip.SetFiles( ImageFile )
	WinClip.SetBitmap( ImageFile )
}