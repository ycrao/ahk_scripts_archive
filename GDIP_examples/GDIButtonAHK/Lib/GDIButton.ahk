#Include <Base>
#Include <Control>
#Include <EventHandler>

;ToDo: CleanUP Resources!!


/********************************************************************
	GDIButton Class
	Custom Button Control
	by IsNull
*********************************************************************
*/
class GDIButton extends Control
{
	; Properties
	Text := "Button"
	Clicked := false
	FontSize := 15
	
	BrushClick := 0
	BrushBkg := 0
	BrushHover := 0
	BrushNoHover := 0
	

	CanHover := true
	RePaintOnMouseMove := true
	
	ClickEvent := 0 			; eventhandler
	PressedDownEvent := 0		; eventhandler
	PressedReleasedEvent := 0	; eventhandler

	
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
	
	OnLBUTTONDOWN(){
		if(this.IsMouseOver()){
			this.Clicked := true
			this.OnPaint()
			this.PressedDownEvent.(this)
		}
	}
	
	OnLBUTTONUP(){
		
		if(this.Clicked && this.Enabled)
			this.PressedReleasedEvent.(this)
		
		if(this.IsMouseOver() && this.Clicked && this.Enabled){					
			this.ClickEvent.(this)
		}
		this.Clicked := false
		this.OnPaint()
	}
	
	OnPaint(){
		graphics := this.Graphics

		Gdip_GraphicsClear(graphics, 0x00FF00FF)

		bgk := (this.Clicked) ? this.BrushClick : this.BrushBkg
		Gdip_FillRoundedRectangle(graphics, bgk, 0, 0, this.Width, this.Height, 10)

		body := (this.IsHovered && this.CanHover) ? this.BrushHover : this.BrushNoHover
		Gdip_FillRoundedRectangle(graphics, body, 5, 5,  this.Width-10, this.Height-10,10) 

		size := this.FontSize
		Options := "x" this.Width / 2 "y" this.Height / 2 - (size/2) "cFFffffff Center s" size
		Gdip_TextToGraphics(graphics, this.Text, Options, "Arial")      ; Schrift zeichnen

		base.OnPaint()
	}

	SetCenter(x, y){
		Gdip_GraphicsClear(this.Graphics, 0x00FF00FF)
		base.SetCenter(x, y)
	}


	/*
		Constructor
		Creates a New GDIButton
	*/
	__New(hwnd, x, y, w, h, text){
		this.BrushClick := Gdip_BrushCreateSolid(0xFF1874CD)
		this.BrushBkg := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFFBCD2EE	, 0xFF607B8B, 1, 1)  ;Gdip_BrushCreateSolid(0xFFBCD2EE)
		this.BrushHover := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFF99CCFF, 0xFFFFFFFF, 1, 1)
		this.BrushNoHover := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFFBCD2EE	, 0xFF607B8B, 1, 1) 
		;// todo -> clean up those resources in destructor
		_GDIButton(this, hwnd, x, y, w, h, text)
	}
}

	_GDIButton(button, hwnd, x, y, w, h, text){
		button.X := x
		button.Y := y
		button.Width := w
		button.Height := h
		button.Text := text
		
		button.ClickEvent := new EventHandler()
		button.PressedDownEvent := new EventHandler()
		button.PressedReleasedEvent := new EventHandler()
		
		button.Init(hwnd)
	}
