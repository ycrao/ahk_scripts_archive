
#Include <Base>
#Include <Control>

;ToDo: CleanUP Resources!!

/********************************************************************
   GDIProgressbar Class
   Custom Progressbar Control
   initially written by RaptorOne, adapted by IsNull
*********************************************************************
*/
class GDIProgressBar extends Control
{
   _percent := 50
   RePaintOnMouseMove := false
   
   BrushBgk := 0 
   BrushBgk2 := 0
   BrushProgress := 0
   
   SplitOffset := 0
   DistOffset := 5
      
   __Set(key, value){
      if(key = "Percent"){
         this._percent := value
         this.OnPaint()
         return this._percent
      }
   }
   
   __Get(key){
      if(key = "Percent"){
         return this._percent
      }
   }
   
   
   OnPaint(){
      graphics := this.Graphics
      Gdip_GraphicsClear(graphics, 0x00000000)

      
      if(!this.SplitOffset){
         ;--- Draw Background
         half := this.Height / 2
         Gdip_FillRectangle(graphics, this.BrushBgk, 0, 0, this.Width, half)
         Gdip_FillRectangle(graphics, this.BrushBgk2, 0, half, this.Width, half)
         
         ;---Draw Progress
         Gdip_FillRectangle(graphics, this.BrushProgress, 0, 0, this.Width * (this.Percent / 100), this.Height)
      } else {
         half := this.Height / 2
         offset := 0
         pieces := this.Width / this.SplitOffset
         piecesToFill := pieces * (this.Percent / 100)
         barWidth := this.SplitOffset - this.DistOffset
         Loop, % pieces
         {
            ;--- Draw Background
            
            Gdip_FillRectangle(graphics, this.BrushBgk, offset, 0, barWidth, half)
            Gdip_FillRectangle(graphics, this.BrushBgk2, offset, half, barWidth, half)
            
            ;---Draw Progress
            if(piecesToFill < a_index){
               Gdip_FillRectangle(graphics, this.BrushProgress, offset, 0, barWidth, this.Height)
            }
            offset += this.SplitOffset
         }
      }
	  base.OnPaint()
   }
   
   /*
      Constructor
      Creates a New GDIProgressBar
   */
   __New(hwnd, x, y, w, h, percent=50){
      this.X := x
      this.Y := y
      this.Width := w
      this.Height := h
      this._percent := percent
      
      this.BrushBgk := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFF6495ED, 0xAA3A5FCD, 1, 1) 
      this.BrushBgk2 := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xFF003366, 0xAA3A5FCD, 1, 1) 
      this.BrushProgress := Gdip_CreateLineBrushFromRect(0, 0, 50, 50, 0xCC87CEFA, 0x10E0FFFF, 1, 1)
      
      
      this.Init(hwnd)
   }
}
