/**************************************
	base classes
***************************************
*/

global null := 0




/*
	Check for same (base) Type
*/
is(obj, type){
	
	if(IsObject(type))
		type := typeof(type)
	
	while(IsObject(obj)){
		
		if(obj.__Class == type){
			return true
		}
		obj := obj.base
	}
	return false
}

typeof(obj){
	return, obj.__Class
}



;Base
{
	; // "".base.__Call := "Default__Warn"
	"".base.__Set  := "Default__Warn"
	"".base.__Get  := "Default__Warn"

	Default__Warn(nonobj, p1="", p2="", p3="", p4="")
	{
		ListLines
		MsgBox A non-object value was improperly invoked.`n`nSpecifically: %nonobj%
	}
}