#Include <Base>
#Include <Collection>


/*
	CustomControlManager (Singleton)
	Access this Object throug CustomControlManager.Instance
*/
class CustomControlManager
{
	; Fields
	Controls := new Collection()
	
	PopulatePaintEvent := true
	PopulateMouseMoveEvent := true
	PopulateMouseClickEvent := true
	
	static Instance := null
	
	/*
		Method Implementations
	*/
	
	Init(){
		static WM_PAINT 		:= 0x0F
		static WM_MOUSEMOVE 	:= 0x200
		static WM_LBUTTONDOWN 	:= 0x201
		static WM_LBUTTONUP 	:= 0x202

		OnMessage(WM_PAINT, "CustomControlManager_OnPaint")
		OnMessage(WM_MOUSEMOVE, "CustomControlManager_OnMOUSEMOVE")
		OnMessage(WM_LBUTTONDOWN, "CustomControlManager_OnLBUTTONDOWN")
		OnMessage(WM_LBUTTONUP, "CustomControlManager_OnLBUTTONUP")
	}
	
	AddControl(control){
		if(!IsObject(control))
			throw Exception("ArgumentException: Object expected!", -1)
		
		if(!is(control, "Control"))
			throw Exception("ArgumentException: Subclass of Control expected!", -1)
			
		this.Controls.Add(control)
		control.setManager(this)
		control.OnPaint()
	}
	
	
	GetCollidedControls(){
		collidedControls := new Collection()
		
		CoordMode, Mouse, Relative
		MouseGetPos, currentX, currentY
		for each, control in this.Controls
		{
			if(control.Contains(currentX, currentY)){
				collidedControls.Add(control)
			}
		}
		return collidedControls
	}

	/*
		Singleton Constructor
	*/
	__New() {
		if(IsObject(CustomControlManager.Instance))
			throw Exception("You try to create a instance of an Object who is actually a singleton. Use the Instance-Property instead of 'new'.",-1)
		this.Init()
	}
}
CustomControlManager.Instance := new CustomControlManager() ; Singleton Instance Access



/*************************************************
Global Event Handlers
**************************************************
*/
	/*
	   Occurs when the window should repaint itself
	   Notifies all CustomControls that they should repaint itself
	*/
	CustomControlManager_OnPaint(wparam=0, lparam=0, msg=0, hwnd=0){
	global
		manager := CustomControlManager.Instance
		if(manager.PopulatePaintEvent){
			for each, c in manager.Controls
				c.OnPaint()
		}
	}

	/*
	   Occurs when the Mouse moves
	   Perform Collision Check with all CustomControls
	*/
	CustomControlManager_OnMOUSEMOVE(wparam=0, lparam=0, msg=0, hwnd=0){
	global
		manager := CustomControlManager.Instance
		if(manager.PopulateMouseMoveEvent){
			CoordMode, Mouse, Relative
			MouseGetPos, currentX, currentY
			for each, control in manager.Controls
			{
				if(control.CanHover){
					if(control.Contains(currentX, currentY)){
						if(!control.IsHovered){
							control.OnHover()
						}
					} else if(control.IsHovered){
						control.OnHoverLost()
					}
					if(control.OnMouseMove){
						control.OnMouseMove()	
					}
				}
			}
		}
	}

	/*
	   Occurs when the Left Mousebutton is down
	*/
	CustomControlManager_OnLBUTTONDOWN(wparam=0, lparam=0, msg=0, hwnd=0){
	global
		manager := CustomControlManager.Instance
		if(manager.PopulateMouseClickEvent){
			for each, control in manager.GetCollidedControls()
				control.OnLBUTTONDOWN()
		}
	}
	
	/*
	   Occurs when the MouseButton is released
	*/
	CustomControlManager_OnLBUTTONUP(wparam=0, lparam=0, msg=0, hwnd=0){
	global
		manager := CustomControlManager.Instance
		if(manager.PopulateMouseClickEvent){
			for each, control in manager.Controls
				control.OnLBUTTONUP()
		}
	}