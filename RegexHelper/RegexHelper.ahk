#SingleInstance Off
#NoEnv
SetBatchLines,-1
FileEncoding,UTF-8
OnExit exit
gosub gui
return

gui:
Gui, Font, s10, SimSun
Gui, Color, D4D0C8, DAF2D7

Gui, Add, Tab2, x0 y0 w800 h110 +0x108,Import|Regex|Script|Info
Gui, Tab,1,1
Gui, Add, Radio, x120 y30 w60 h20 vb_import_file gimport_change Checked,File
Gui, Add, Radio, x185 y30 w80 h20 vb_import_web gimport_change,Internet
Gui, Add, Radio, x270 y30 w100 h20 vb_import_cb gimport_change,Clipboard
Gui, Add, Text, x10 y30 w100 h20,Import from:
Gui, Add, Edit, x10 y50 w400 h20 ve_import_file,
Gui, Add, Button, x500 y30 w100 h60 gimport_import,Import
Gui, Add, CheckBox, x10 y80 w80 h20 vb_import_append,Append
Gui, Add, Button, x420 y50 w60 h20 vb_import_sel gimport_sel,File
Gui, Tab,2,1
Gui, Add, Radio, x5 y30 w80 h20 vb_regex_match Checked,Match
Gui, Add, Radio, x5 y55 w80 h20 vb_regex_replace,Replace
Gui, Add, Edit, x150 y30 w350 h20 ve_regex_needle,
Gui, Add, Edit, x150 y55 w350 h20 ve_regex_output,
Gui, Add, Edit, x150 y80 w100 h20 ve_regex_option,imsS
Gui, Add, Text, x100 y30 w50 h20,Needle
Gui, Add, Text, x100 y55 w50 h20,Output
Gui, Add, Text, x100 y80 w50 h20,Option
Gui, Add, Button, x515 y30 w80 h45 gregex_convert,Convert
Gui, Add, Button, x610 y30 w80 h45 gregex_rslt2src,Rslt2Src
Gui, Add, CheckBox, x5 y80 w80 h20 +disabled,realtime
Gui, Tab,3,1
Gui, Add, Edit, x5 y30 w640 h65 ve_script, MsgBox `%%A_Space%
Gui, Add, Button, x655 y30 w100 h30 gscript_convert, Run
Gui, Tab,4,1
Gui, Add, Text, x5 y30 w790 h60,Author: nepter `n`nThis is a very simple tool to make regex operation easier.`n
Gui, Add, Edit, x0 y110 w800 h460,
(`
Options:
i) Case-insensitive matching
m) Multiline
s) DotAll
x) Ignores whitespace characters in the pattern 
J) Allows duplicate named subpatterns
U) Ungreedy
X) PCRE_EXTRA
P) Position mode
S) Studies the pattern
C) Enables the auto-callout mode
O) Object
`n) (`r`n) to  (`n)
`r) (`r`n) to  (`r)
`a) Recognizes any type of newline, newlines can be restricted to only CR, LF, and CRLF by specifying (*ANYCRLF) 
)
Gui, Tab
Gui, Add, Edit, x0 y110 w400 h460 +0x4000000 ve_source,
Gui, Add, Edit, x400 y110 w400 h460 +0x4000000 ve_result,
Gui, Show, w800 h600,  AHK Regex Helper Tool 0.1
Return

import_change:
	Gui,submit,nohide
	if b_import_file {
		GuiControl,,e_import_file,
		GuiControl, Enable, b_import_sel
		GuiControl, Enable, e_import_file
	}
	else if b_import_web {
		GuiControl, Disable, b_import_sel
		GuiControl, Enable, e_import_file
		GuiControl,,e_import_file, http://
	}
	else if b_import_cb {
		GuiControl, Disable, b_import_sel
		GuiControl, Disable, e_import_file
	}
return

import_sel:
	FileSelectFile,import_filename,
	if import_filename
		GuiControl,,e_import_file,% import_filename
return

import_import:
	gui,submit,nohide
	if b_import_file {
		IfExist, %e_import_file%
			FileRead,source,%e_import_file%
	}
	else if b_import_web {
		URLDownloadToFile,%e_import_file%,web
		IfExist	web
			FileRead,source,web
		FileDelete, web
	}
	else if b_import_cb {
		source := Clipboard
	}
	if b_import_append
		GuiControl,,e_source,% e_source "`n" source
	else 
		GuiControl,,e_source,% source
return

regex_convert:
	gui,submit,nohide
	GuiControl, ,e_result,% run(e_source,e_regex_option,e_regex_needle,e_regex_output)
return

regex_rslt2src:
	gui,submit,nohide
	GuiControl, ,e_source,% e_result
return

script_convert:
	gui,submit,nohide
	FileAppend,%e_script%,__temp.ahk,UTf-8
	RunWait,__temp.ahk
	FileDelete,__temp.ahk
return

run(a,b,c,d) {
	global b_regex_match,b_regex_replace
	if b_regex_match {
		while RegExMatch(a,b "O)" c,key) {
			if d {
				loop % key.Count() {
					t := key.Value(A_Index)
					StringReplace,d,d,$%A_Index%,%t%,All
				}
				e .= d "`n"
			}
			else {
				loop % key.Count()
					e .= key.Value(A_Index)
				e .= "`n"
			}
			a := SubStr(a,key.Pos(0)+key.Len(0))
		}
	}
	else if b_regex_replace {
		e := RegExReplace(a,"s)" c,d)
	}
	return % e
}

exit:
GuiClose:
ExitApp
