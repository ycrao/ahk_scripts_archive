#Include <Base>
/*
   Simple Collection impl
*/
class Collection
{

	Add(obj){
		this.Insert(obj)
	}
	
	AddRange(objs){
		if(IsObject(objs)){
			for each, item in objs
				this.Insert(item)
		} else
			throw Exception("ArgumentException: Must submit Object!",-1)
	}
	
	IndexOf(obj){
		for i, item in this
		{
			if(item == obj)
				return i
		}
	}

	Remove(obj){
		this.Remove(this.IndexOf(obj))
	}
	
	Clear(){
		this.Remove(this.MinIndex(), this.MaxIndex())
	}
	
	Count(){
		i := 0
		for e in this
			i++
		return i
	}

	/*
		Constructor
	*/
	__New(){ 
	} 
}