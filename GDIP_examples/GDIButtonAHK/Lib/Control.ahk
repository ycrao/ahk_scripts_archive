#Include <Base>
#Include <Gdip>

/********************************************************************
	Control Class
	Base Class for all custom Controls
	by IsNull
*********************************************************************
*/
class Control
{
	
	X := 0
	Y := 0
	Width := 0
	Height := 0
	IsHovered := false
	CanHover := false
	
	ParentHandle := 0
	Manager := 0
	
	Enabled := true
	IsBusy := false
	RePaintOnMouseMove := true
	
	HDC_WINDOW := 0
	FRAME_hbm := 0
	FRAME_HDC := 0
	Graphics := 0
	
	BrushDisabled := 0
	BrushBusy := 0
	
	
	
	/*
		returns true if the mouse is currently over the control
	*/
	IsMouseOver(){
		CoordMode, Mouse, Relative
		MouseGetPos, mx, my,  winhwnd
		
		if(winhwnd == this.ParentHandle){
			return this.Contains(mx,my)
		}else
			return false
	}
	
	OnMouseMove(){
		
	}
	
	SetManager(manager){
		if(!is(manager, "CustomControlManager"))
			throw Exception("ArgumentException: Requieres CustomControlManager Instance",-1)
			
		this.Manager := manager
	}
	
	Contains(x, y){		
		cy := this.Y + this.Height / 2
		return ((x >= this.X && x <= this.X + this.Width) && (y > cy && y < (cy + this.Height)))
	}
	
	OnPaint(){
		if(this.Graphics != 0){
			if(!this.Enabled){
				; TODO: // overdraw with some gray to show not enabled state
			}
			AlphaBlend(this.HDC_WINDOW, this.X, this.Y, this.Width , this.Height, this.FRAME_HDC, 0, 0, this.Width,  this.Height, BLENDFUNCTION := 0x01FF0000) ; thx @ nick
		}
	}
	
	
	SetCenter(x, y){	
		this.X	:= x - (this.Width / 2)
		this.Y	:= y - (this.Height / 2)
	}
	
	/*
		Init the Control
		hwnd = Handle of the Window
	*/
	Init(hwnd){	
		this.ParentHandle := hwnd
		
		this.HDC_WINDOW := GetDC(hwnd)
		this.FRAME_hbm := CreateDIBSection(this.Width, this.Height)

		this.FRAME_HDC := CreateCompatibleDC()
		SelectObject(this.FRAME_HDC, this.FRAME_hbm)
		frame_hdc := this.FRAME_HDC
		g := Gdip_GraphicsFromHDC(frame_hdc)
		this.Graphics := g
		Gdip_SetSmoothingMode(this.Graphics, 4)	
	}
}
