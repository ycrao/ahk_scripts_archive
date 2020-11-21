/*
AutoHotkey 版本: 1.1.3.0(L)
操作系统:    WIN7
作者:        Nigh
网站:
脚本说明：
脚本版本：   Alpha
*/

global gid:=99

class GDI_HUD
{

	static lid:=0
	static transparency:=255
	static width:=0
	static height:=0
	static iwidth:=0
	static iheight:=0
	static pox:=0
	static poy:=0
	static hwnd:=0

	static hbm
	static hdc
	static obm
	static G

	array:=Array()

	__New()
	{
		this.lid:=gid--
		If(this.lid=99)
		If !pToken := Gdip_Startup()
		{
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		}
		Gui, % this.lid ": Default"
		Gui,-Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop +E0x20
		Gui,Show, NA
		this.hwnd:=WinExist()
		}

	__Delete()
	{
		SelectObject(this.hdc, this.obm)
		DeleteObject(this.hbm)
		DeleteDC(this.hdc)
		Gdip_DeleteGraphics(this.G)
		}

	setBitmap(path,n=1)
	{
		If n is Number
		{
		pBitmap_%n% := Gdip_CreateBitmapFromFile(path)
		this.iWidth := this.iWidth<Gdip_GetImageWidth(pBitmap_%n%) ? Gdip_GetImageWidth(pBitmap_%n%) : this.iWidth
		this.iHeight := this.iHeight<Gdip_GetImageHeight(pBitmap_%n%) ? Gdip_GetImageHeight(pBitmap_%n%) : this.iHeight
		}
		Else
		MsgBox, [ERROR]n is not number...
		this.array.Insert(n,pBitmap_%n%)
		Return, pBitmap_%n%
		}

	setTransparency(n=255)
	{
		this.transparency:=n
	}

	setPosition(x=0,y=0)
	{
		this.x:=x
		this.y:=y
		}

	forceSetwidth(w)
	{
		this.width:=w
	}

	forceSetheight(h)
	{
		this.height:=h
	}

	createGraphics()
	{
		If(Width and Height)
		this.hbm := CreateDIBSection(this.Width, this.Height)
		Else
		this.hbm := CreateDIBSection(this.iWidth, this.iHeight)
		this.hdc := CreateCompatibleDC()
		this.obm := SelectObject(this.hdc, this.hbm)
		this.G := Gdip_GraphicsFromHDC(this.hdc)
		Gdip_SetInterpolationMode(this.G, 7)
		Gdip_SetCompositingMode(this.G, 1)
	}

	updateLayer(x=-65535,y=-65535)
	{
		If(x<-65534)
		x:=A_ScreenWidth//2-this.iwidth//2
		If(y<-65534)
		y:=A_ScreenHeight//2-this.iheight//2
		this.pox:=x
		this.poy:=y
		Return, UpdateLayeredWindow(this.hwnd, this.hdc, x, y, this.iWidth, this.iHeight, this.transparency)
	}

	drawImage(n,x=-65535,y=-65535)
	{
		If(this.array[n])
		{
		Gdip_DrawImage(this.G, this.array[n], 0, 0, this.iWidth, this.iHeight, 0, 0, this.iWidth, this.iHeight)
		this.updateLayer(x,y)
		}
	}

	move(dx,dy,time=1)
	{
		tx:=this.pox,ty:=this.poy
		xstep:=(dx-tx)/(time*50)
		ystep:=(dy-ty)/(time*50)

		Loop, % time*50
		{
		this.updateLayer(this.pox+xstep,this.poy+ystep)
		Sleep,20
		}
		this.updateLayer(dx,dy)
	}
}