#Include <Base>
#Include <Delegate>
#Include <Control>
#Include <Collection>



class GDISliderButton extends GDIButton
{
	BrushClick := 0
	BrushBkg := 0
	BrushHover := 0
	BrushNoHover := 0
	RePaintOnMouseMove := false
	

	OnPaint(){
		graphics := this.Graphics

		Gdip_GraphicsClear(graphics, 0x00FF00FF)

		bgk := (this.Clicked) ? this.BrushClick : this.BrushBkg
		Gdip_FillRoundedRectangle(graphics, bgk, 0, 0, this.Width, this.Height, 5)

		body := this.BrushNoHover
		Gdip_FillRoundedRectangle(graphics, body, 2, 2,  this.Width-5, this.Height-5,5) 
		
		AlphaBlend(this.HDC_WINDOW, this.X, this.Y, this.Width , this.Height, this.FRAME_HDC, 0, 0, this.Width,  this.Height, BLENDFUNCTION := 0x01FF0000)
		;base.OnPaint()
	}
	
	__New(hwnd, x, y, w, h){
		
		this.BrushClick := Gdip_BrushCreateSolid(0xFF1874CD)
		this.BrushBkg := Gdip_BrushCreateSolid(0xFFBCD2EE)
		this.BrushHover := Gdip_BrushCreateSolid(0xFF99CCFF)
		this.BrushNoHover := Gdip_BrushCreateSolid(0xFF607B8B) 
		;ToDo: CleanUP Resources!!
		
		_GDIButton(this, hwnd, x, y, w, h, "")
	}
}



/********************************************************************
	GDISlider Class
	Custom Slider Control
	by IsNull
*********************************************************************
*/
class GDISlider extends Control
{
	; Properties
	BrushClick := 0
	BrushBkg := 0
	BrushHover := 0
	BrushNoHover := 0
	
	BarHeight := 5
	
	CanHover := true
	RePaintOnMouseMove := true
	
	DragButton := 0
	_linkedProgressBars := 0
	
	_drag := false
	ClickEventHandler := ""
	Position := 0
	PositionChanged := ""
	

	/*
		Method Implementations
	*/
	
	OnHover(){
		this.IsHovered := true
		this.OnPaint()
	}
	
	OnHoverLost(){
		this.IsHovered := false
		this.OnPaint()
	}
	
	
	Bind(obj){
		if(is(obj, "GDIProgressBar"))
			this._linkedProgressBars.Add(obj)
		else
			throw Exception("ArgumentException: Can't define binding for Type: " typeof(obj), 1)
	}
	
	setManager(manager){
		base.SetManager(manager)
		
		if(IsObject(this.DragButton))
			manager.AddControl(this.DragButton)
	}

	OnPaint(){
		graphics := this.Graphics
		Gdip_GraphicsClear(graphics, 0xFFFFFFFF)

		bgk := (this.Clicked) ? this.BrushClick : this.BrushBkg
		Gdip_FillRoundedRectangle(graphics, bgk, 0, (this.Height / 2) - (this.BarHeight / 2), this.Width, this.BarHeight, 2)
		base.OnPaint()
		
		;if(is(this.DragButton, "Control"))
		this.DragButton.OnPaint()
	}
	
	UpdateDragButton(){
		ctrl := this.DragButton
		
		if(is(this.DragButton, "Control")){
			p := this.getPercent()
			y := this.Y + (this.Height / 2)
			x := this.X + (ctrl.Width / 2) + ((this.Width - (ctrl.Width)) * p / 100)
			ctrl.SetCenter(x,y)
			this.OnPaint()
		}else
			throw Exception("Expected a Subclass from Control for DragButton Property!",-1)
	}
	
	getPercent(){
		return this.Position
	}
	setPosition(n){
		if(n > 100)
			n := 100
		if(n < 0)
			n := 0
		this.Position := n
		this.UpdateDragButton()
		
		for each, pb in this._linkedProgressBars
			pb.Percent := this.Position
	}

	OnDragButtonPressedDown(sender){
		this._drag := true
		MouseGetPos, mx
		this._dragstart := mx
		this._posstart := this.Position
	}
	
	OnDragButtonReleased(sender){
		this._drag := false
	}
	
	OnMouseMove(){
		if(this._drag && GetKeyState("LButton")){
			MouseGetPos, mx
			v := ( 100 / this.Width) * (mx - this._dragstart)
			if(!v)
				return
			this.setPosition(v + this._posstart)
			this.OnPaint()
		}
	}
	

	/*
		Constructor
		Creates a New GDIButton
	*/
	__New(hwnd, x, y, w, h, pos=0){
		this.X := x
		this.Y := y
		this.Width := w
		this.Height := h
		this.Position := pos	
		this.DragButton := new GDISliderButton(hwnd, x, y, 20, 40)
		
		this._linkedProgressBars := new Collection()
		
		
		this.BrushClick := Gdip_BrushCreateSolid(0xFF1874CD)
		this.BrushBkg := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFFBCD2EE	, 0xFF607B8B, 1, 1)  ;Gdip_BrushCreateSolid(0xFFBCD2EE)
		this.BrushHover := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFF99CCFF, 0xFFFFFFFF, 1, 1)
		this.BrushNoHover := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFFBCD2EE	, 0xFF607B8B, 1, 1)
		
		
		this.DragButton.PressedDownEvent.Handler := new Delegate(this, "OnDragButtonPressedDown")
		this.DragButton.PressedReleasedEvent.Handler := new Delegate(this, "OnDragButtonReleased")	
		
		this.setPosition(pos)
		this.Init(hwnd)
	}
}








