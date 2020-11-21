/*

;DEMO start

#Warn

mycar := new Car("hamburch")
mycar.DoorClosedEvent.Handler := Func("HanderlMethod")
mycar.DoorClosedEvent.Handler := Func("AnotherHanderlMethod")
mycar.Action()

exitapp


HanderlMethod(sender){
	msgbox % "Handerl Method " sender.Name
}

AnotherHanderlMethod(sender){
	msgbox % "Antother Handerl Method " sender.Name
}


class Car
{
	var Name := ""
	var DoorClosedEvent := new EventHandler()
	
	Action(){
		this.DoorClosedEvent.(this)
	}
	
	__New(num){
		this.Name := num	
	}
}

;DEMO END
*/

class EventHandler
{
	registeredHandlers := []
	
	Register(handler){
		this.registeredHandlers.Insert(handler)
	}
	
	UnRegister(handler){
		for k, h in this.registeredHandlers
		{
			if(h == handler)
				this.registeredHandlers.Remove(k)
		}
	}
	
	Clear(){
		registeredHandlers := []
	}
	
	__Call(target, params*)
    {
		if(target == ""){
			for each, handler in this.registeredHandlers
			{
				handler.(params*)
			}
		}
    }
	
	__Set(name, value){
		if(name){
			if(name = "Handler"){
				this.Register(value)
				return ""
			}
		}
	}

	__New(){
		this.registeredHandlers := []
	}
}