/*
[config]
ahk_version=ANSI
icon=music.ico
bin=
*/

#SingleInstance force
#NoEnv
#Include <bass>
#Include <Class_Toolbar>
#Include <Class_GuiControlTips>
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
DetectHiddenWindows, On
Process, Priority,, High
OnExit, GuiClose

BASS_Load()
PlayN := 0



; #################################
;		界面
; #################################
;
Gui, +hwndTestGui +LastFound
Gui, Font, s12
TT := New GuiControlTips(TestGui)

; ------------ 播放进度控件
	Gui, Add, Progress, vPlaySlider w380 r1

; ------------ 音量调节控件
	hBitmap_unmute := Create_unmute_png()
	hBitmap_mute := Create_mute_png()

	Gui_Add_Picture("unmute.png", "ys w16 h16 gmute vPicMute", "hPicMute")
	Gui, Add, Progress, xp+20 w85 h16 cGray vVol, % VolNow := Round( BASS_Volume() * 100 )

;; ------------ 创建工具栏
;	Gosub, CreateToolbar

; ------------ 播放时间
	Gui, Add, Text, xp-60 yp+55 w140 cGreen vPlayPos

; ------------ 播放列表控件
	Gui, Font, bold
	Gui, Add, Text, xm yp+50 Section, 播放列表:
	Gui, Font
	Gui, Font, s12

	Gui_Add_Picture("add.png", "ys w16 h16 gAddFiles", "hPicAdd")
	SetCursor("HAND", "Static4")
	TT.Attach(hPicAdd, "添加文件")

	Gui_Add_Picture("adddir.png", "ys w16 h16 gAddFolders", "hPicAddDir")
	SetCursor("HAND", "Static5")
	TT.Attach(hPicAddDir, "添加文件夹")

	Gui_Add_Picture("del.png", "ys w16 h16 gDeleteItems", "hPicDel")
	SetCursor("HAND", "Static6")
	TT.Attach(hPicDel, "删除选中列表")

	Gui, Add, ListView, xm w500 h300 vMyListView gMyListView, 序号|文件名|文件路径
	LV_SetWidth("60|410|0")
	LV_CenterRows(2)

;
	Gui, Font, s9
	Gui, Add, StatusBar,, %A_Space%
	SB_SetParts(80)

; ------------ 点击进度条
	; http://www.autohotkey.com/board/topic/81144-progress-bar-slider/?p=516891
	OnMessage(0x201, "XClickableProgress")
	XClickableProgress() {
		global hStream, Bytes_Total

		CoordMode, Mouse, Relative
		MouseGetPos,,,, ClassNN
		IfNotInString, ClassNN, msctls_progress32, return
		MouseGetPos,,,, CtrlHwnd, 2
		ControlGet, Style, Style,,, ahk_id%CtrlHwnd%
		ControlGetPos, X, Y, W, H,, ahk_id%CtrlHwnd%
		VarSetCapacity(R, 8)
		SendMessage, 0x0407,, &R,, ahk_id%CtrlHwnd%
		R1 := NumGet(R, 0, "Int"), R2 := NumGet(R,4,"Int")
		while (GetKeyState("LButton"))
		{
			MouseGetPos, XM, YM
			ToolTip % V := (V:=(Style&0x4 ? 1-(YM-Y)/H : (XM-X)/W))>=1 ? R2 : V<=0 ? R1 : Round(V*(R2-R1)+R1)
			GuiControl, % A_Gui ":", % CtrlHwnd, % V

			; 修改音量
			if (A_GuiControl = "Vol")
				BASS_Volume(V / 100)
		}
		ToolTip

		; 修改播放位置
		if (A_GuiControl = "PlaySlider" && Bytes_Total)
			BASS_SetPos(hStream, Bytes_Total * (v/100))
	}

; 工具栏需要的代码
	; Set a function to monitor the Toolbar's messages.
	WM_COMMAND := 0x111
	OnMessage(WM_COMMAND, "TB_Messages")

	; Set a function to monitor notifications.
	WM_NOTIFY := 0x4E
	OnMessage(WM_NOTIFY, "TB_Notify")

	GuiControl, Focus, MyListView 		; 随便修改一个焦点，要不然焦点始终在工具栏按钮上

	Gui, Show

; ------------ 创建工具栏
	Gosub, CreateToolbar
	TB1.Move(0, 65)

; 载入播放列表
	himl_list := __CreateIL("list_play.png|list_pause.png", 16, 16)
	LV_SetImageList(himl_list)

	IfExist, %A_ScriptName%.PlayList
	{
		Loop, Read, %A_ScriptName%.PlayList
		{
			IfExist, %A_LoopReadLine%
			{
				SplitPath, A_LoopReadLine,,,, OutNameNoExt
				LV_Add("Icon9999999", A_Index, OutNameNoExt, A_LoopReadLine)
			}
		}

		LV_Modify(1, "Select Focus")
		GuiControl, Focus, MyListView
	}
return



; #################################
;		创建工具栏
; #################################
;
CreateToolbar:
	Gui, Add, Custom, ClassToolbarWindow32 hwndhToolbar vTop 0x0800 0x0100 0x20 Section w0

	; 创建图片列表
	himl := __CreateIL("stop.png|previous.png|play.png|next.png|pause.png|unmute.png|mute.png", 48, 48)

	TB1 := New Toolbar(hToolbar)
	TB1.SetImageList(himl)

	BtnsArray := []

	; The Cmd label has a "-" and will be hidden on start, but available in customize dialog.
	DefArray1 := [ "btn_stop=停止:1", "btn_previous=上一首:2", "btn_play=播放:3", "btn_next=下一首:4"]

	BtnsArray := DefArray1

	TB1.SetMaxTextRows(0)

	TB1.Add("", BtnsArray*)
	TB1.SetDefault("", DefArray1*)
	TB1.SetIndent(140)					; 第一个按钮距离左边的宽度
return



; #################################
;		添加播放列表
; #################################
;
AddFiles:
	FileSelectFile, FileList, M,,, (*.mp3)
	if !FileList
		return

	ListCount := LV_GetCount()

	; 分割文件路径和文件名
	RegExMatch(FileList, "O)^([^\r\n]+)[\r\n]+(.*)", match)
	FileDir := match[1], NameList := match[2]

	Loop, Parse, NameList, `n
		LV_Add("Icon9999999", ++ListCount, SubStr(A_LoopField, 1, -4), FileDir "\" A_LoopField)
return



; #################################
;		添加文件夹
; #################################
;
AddFolders:
	FileSelectFolder, FileDir, *%A_ScriptDir%
	if !FileDir
		return

	ListCount := LV_GetCount()
	Loop, %FileDir%\*.mp3,, True
		LV_Add("Icon9999999", ++ListCount, SubStr(A_LoopFileName, 1, -4), A_LoopFileFullPath)
return


; #################################
;		拖拽添加文件
; #################################
;
GuiDropFiles:
	ListCount := LV_GetCount()

	Loop, parse, A_GuiEvent, `n
	{
		IfExist, %A_LoopField%\
		{
			Loop, %A_LoopField%\*.mp3,, True
				LV_Add("Icon9999999", ++ListCount, SubStr(A_LoopFileName, 1, -4), A_LoopFileFullPath)
		}
		else
		{
			SplitPath, A_LoopField,,, Ext, FileNameNoExt
			if (Ext = "mp3")
				LV_Add("Icon9999999", ++ListCount, FileNameNoExt, A_LoopField)
		}
	}
Return



; #################################
;		删除选中列表
; #################################
;
DeleteItems:
	if !LV_GetNext()
		return

	Loop
	{
	    RowNumber := LV_GetNext(RowNumber - 1)
	    if not RowNumber
	        break
	    LV_Delete(RowNumber)
	}

	; 修改序号
	Loop, % LV_GetCount()
		LV_Modify(A_Index, "Col1", A_Index)
return



; #################################
;		双击播放列表
; #################################
;
MyListView:
	if ( A_GuiEvent = "DoubleClick" && LV_GetNext() )
	{
		__IsStoped :=
		LV_GetText(AudioFile, A_EventInfo, 3)
		StopPlay(5, "暂停")
		PlayNewFile(AudioFile)

		PlayN := A_EventInfo, ImageN := 5
		LV_Modify(PlayN, "Icon1")
	}
return



btn_stop:
	StopPlay()
return


btn_previous:
btn_next:
	if !ListTotal := LV_GetCount()
		Goto, btn_stop

	GuiControl, Focus, MyListView
	LV_Modify(PlayN, "Icon9999999")

	PlayN := (A_ThisLabel="btn_next") ? PlayN+1 : PlayN-1
	PlayN := PlayN<=0 ? ListTotal : PlayN
	PlayN := PlayN>ListTotal ? 1 : PlayN

	LV_GetText(AudioFile, PlayN, 3)

	IfNotExist, %AudioFile%
	{
		LV_Delete(PlayN)
		Goto, %A_ThisLabel%
	}

	StopPlay(5, "暂停")
	PlayNewFile(AudioFile)

	LV_Modify(0, "-Select -Focus")
	LV_Modify(PlayN, "Select Focus")
	LV_ScrollSelect(PlayN)

	LV_Modify(PlayN, "Icon1")

	SB_SetText(PlayN "/" ListTotal)
	SB_SetText(AudioFile, 2)
Return


btn_play:
	__IsStoped :=
	ImageN := ImageN=5 ? 3 : 5
	btn_txt := ImageN=5 ? "暂停" ? "播放"

	if (Bytes_Current = -1 || !Bytes_Current)
	{
		if !LV_GetCount()
			return

		PlayN := LV_GetNext() ? LV_GetNext() : 1
		LV_GetText(AudioFile, PlayN, 3)
		LV_Modify(0, "-Select -Focus")
		LV_Modify(PlayN, "Select Focus")
		GuiControl, Focus, MyListView

		PlayNewFile(AudioFile)
		LV_Modify(PlayN, "Icon1")
	}
	else
	{
		BASS_Pause()

		if __IsPaused := !__IsPaused
			LV_Modify(PlayN, "Icon2")
		else
			LV_Modify(PlayN, "Icon1")
	}

	TB1.ModifyButtonInfo(3, "Image", ImageN)
	TB1.ModifyButtonInfo(3, "Text", btn_txt)
return


mute:
	mute := !mute

	if mute
	{
		VolLast := BASS_Volume()
		GuiControl,, Vol
		BASS_Volume(0.0)
		SendMessage, 0x172, 0x0, hBitmap_mute, , % "ahk_id " hPicMute
	}
	else
	{
		BASS_Volume(VolLast)
		GuiControl,, Vol, % Round(VolLast * 100)
		SendMessage, 0x172, 0x0, hBitmap_unmute, , % "ahk_id " hPicMute
	}
return


UpdatePlayPos:
	Bytes_Current := BASS_GetPos(hStream)											; 当前播放了多少字节
	if Bytes_Current = -1
	{
		SetWorkingDir, %A_ThisLabel%, Off
		Bytes_Total := 0
		
		if !__IsStoped
			Goto, btn_next

		return
	}

	PlayPercent := Round(Bytes_Current / Bytes_Total * 100)							; 播放百分比
	Time_Current  := FormatSeconds( BASS_Bytes2Seconds(hStream, Bytes_Current) )	; 当前播放了多少时间
	GuiControl,, PlayPos, %Time_Current% / %Time_ToTal%
	GuiControl,, PlaySlider, %PlayPercent%
return


GuiClose:
	BASS_Free()

	; 保存播放列表
	if ListTotal := LV_GetCount()
	{
		FileDelete, %A_ScriptName%.PlayList
		Loop, % ListTotal
		{
			LV_GetText(AudioPath, A_Index, 3)
			FileAppend, %AudioPath%`r`n, %A_ScriptName%.PlayList
		}
	}
	ExitApp



; 快捷键
#If WinActive("ahk_id " TestGui)
Space::Goto, btn_play
^Left::Goto, btn_previous
^Right::Goto, btn_next

#IfWinActive


; ========================================= 以下是函数 =========================================

; This function will receive the messages sent by both Toolbar's buttons.
TB_Messages(wParam, lParam)
{
    Global ; Function (or at least the Handles) must be global.
    TB1.OnMessage(wParam) ; Handles messages from TB1
}

; This function will receive the notifications.
TB_Notify(wParam, lParam)
{
    Global TB1 ; Function (or at least the Handles) must be global.
    ReturnCode := TB1.OnNotify(lParam, MX, MY, Label, ID) ; Handles notifications.
    return ReturnCode
}

FormatSeconds(NumberOfSeconds)  ; Convert the specified number of seconds to hh:mm:ss format.
{
	NumberOfSeconds := Round(NumberOfSeconds)

    time = 19990101  ; *Midnight* of an arbitrary date.
    time += %NumberOfSeconds%, seconds
    FormatTime, mmss, %time%, mm:ss
    hours := NumberOfSeconds // 3600 ; This method is used to support more than 24 hours worth of sections.
    hours := hours < 10 ? "0" . hours : hours

    _out := hours ":" mmss
    StringReplace, _out, _out, 00:,, All
    Return, _out
}

__CreateIL(images, cx, cy)
{
    himl := DllCall("ImageList_Create", "Int",cx, "Int",cy, "UInt",0x20, "Int",1, "Int",5, "UPtr")

    Loop, Parse, images, |
    {
        StringReplace, name, A_LoopField, ., _, a
        hicon := Create_%name%()
        DllCall("ImageList_AddIcon", "Ptr",himl, "Ptr",hicon)
        DllCall("DestroyIcon", "Ptr", hicon)
    }

    Return, himl
}

Gui_Add_Picture(file, Options = "", hWnd = "hPic")
{
	global
	StringReplace, name, file, ., _, a
	Gui, Add, Picture, 0xE %Options% hWnd%hWnd%
	SendMessage, 0x172, 0x0, % ( Create_%name%() ), , % "ahk_id " %hWnd%
}

LV_SetWidth(WidthList)
{
	WidthList := RegExReplace(WidthList, "[^\d]+", "#")
	WidthList := Trim(WidthList, "#")
	loop, parse, WidthList, #
		LV_ModifyCol(A_Index, A_LoopField)
}

LV_CenterRows(Rows)
{
	Loop, %Rows%
		LV_ModifyCol(A_Index, "Center")
}

PlayNewFile(AudioFile)
{
	global
	__IsStoped :=
	hStream := BASS_Play(AudioFile)

	; 获取音频播放时间
	Bytes_Total := BASS_GetLen(hStream)											; 音频字节长度
	Time_ToTal  := FormatSeconds( BASS_Bytes2Seconds(hStream, Bytes_Total) )	; 音频时间长度
	SetTimer, UpdatePlayPos, 1000

	SB_SetText(LV_GetNext() "/" LV_GetCount())
	SB_SetText(AudioFile, 2)
}

StopPlay(__ImageN=3, __btn_txt="播放")
{
	global
	__IsStoped := true
	BASS_Stop()
	
	TB1.ModifyButtonInfo(3, "Image", __ImageN)
	TB1.ModifyButtonInfo(3, "Text", __btn_txt)
	GuiControl,, PlaySlider
	GuiControl,, PlayPos
	LV_Modify(PlayN, "Icon9999999")

	ImageN := __ImageN
}

LV_ScrollSelect(RowNumber)
{
	global

	Winwait, % "ahk_id " TestGui
	GuiControl, Focus, MyListView
	LV_Modify(0, "-Select -Focus")

	if RowNumber > 1
	{
		LV_Modify(RowNumber - 1, "Select Focus")
		ControlSend, SysListView321, {Down}
	}
	Else
	{
		LV_Modify(RowNumber, "Select Focus")
		ControlSend, SysListView321, {Home}
	}
}

#Include, <Create_stop_png>
#Include, <Create_next_png>
#Include, <Create_pause_png>
#Include, <Create_play_png>
#Include, <Create_previous_png>
#Include, <Create_unmute_png>
#Include, <Create_mute_png>
#Include, <Create_add_png>
#Include, <Create_adddir_png>
#Include, <Create_del_png>
#Include, <Create_list_play_png>
#Include, <Create_list_pause_png>
