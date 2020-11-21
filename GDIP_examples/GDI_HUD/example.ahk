/*
AutoHotkey 版本: 1.1.3.0(L)
操作系统:    WIN7
作者:        Nigh
网站:
脚本说明：
脚本版本：   Alpha
*/

#NoEnv
;~ 如果你的库中没有gdip，请手动包含它。
;~ #Include gdip.ahk
#Include gdip.ahk
#Include class_GDI_HUD.ahk
FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%
OnExit, Exit

;~ 新建两个GDI_HUD对象
name1:=new GDI_HUD
name2:=new GDI_HUD

;~ 注册图片
name1.setBitmap("ledon.png",1)
name1.setBitmap("ledoff.png",2)

name2.setBitmap("0.png",0)
name2.setBitmap("1.png",1)
name2.setBitmap("2.png",2)
name2.setBitmap("3.png",3)
name2.setBitmap("4.png",4)
name2.setBitmap("5.png",5)
name2.setBitmap("6.png",6)
name2.setBitmap("7.png",7)
name2.setBitmap("8.png",8)
name2.setBitmap("9.png",9)

;~ 建立作图区
name1.createGraphics()
name2.createGraphics()

;~ 依次显示10个注册的图片
Loop, 10
{
Sleep, 300
name2.drawImage(10-A_Index)
}

;~ 透明度的更改，渐隐效果的实现
Loop, 255
{
	name2.setTransparency(255-A_Index)
	name2.updateLayer()
	If(!mod(A_Index,4))
	Sleep,1
}
name1.drawImage(1,0,A_ScreenHeight//2-name1.iHeight//2)
Sleep, 300
name1.drawImage(2,name1.pox,name1.poy)
Sleep, 200
name1.drawImage(1,name1.pox,name1.poy)
Sleep, 700
name1.drawImage(2,name1.pox,name1.poy)
Sleep, 1000
;~ move函数的使用
;~ 前两个参数为目标坐标X,Y
;~ 第三个参数为动画持续的时间，单位为秒
name1.move(-name1.iWidth,name1.poy,2)
ExitApp
Return

F5::ExitApp

Exit:
Gdip_Shutdown(pToken)
ExitApp
Return