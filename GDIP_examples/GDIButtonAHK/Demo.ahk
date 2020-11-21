#NoEnv 
#Include %A_ScriptDir%
#Include <Base>
#Include <Controls>
;#Warn All
;#Warn, LocalSameAsGlobal, Off

SetBatchLines, -1   ; maximale leistung

controlManager := CustomControlManager.Instance

;-----------------------------------------------------------------------
;GDI+ example
;-----------------------------------------------------------------------
Gui, color, white 
Gui, add, text , x50 y50 ,Da guckst du :D
Gui, add, Slider, x230 y100 w200 vSlider1 gOnSliderChanged +Altsubmit
Gui, show, w500 h600, GDI+ View Demo by IsNull
gui, +lastfound
myhwnd := WinExist("A")   ; eindeutiges Handle auf unser GUI


bar := new GDIProgressBar(myhwnd, 230, 10, 200, 30, 50)
controlManager.AddControl(bar)

bar2 := new GDIProgressBar(myhwnd, 230, 45, 200, 30, 50)
bar2.SplitOffset := 10
controlManager.AddControl(bar2)



; Erster Button
mybutton := new GDIButton(myhwnd, 30, 100, 200, 50, "Click Me!")   ; Änlich wie GUI, add, 
mybutton.ClickEvent.Handler := Func("OnButton_Clicked")    ; Dem ButtonObjekt kann man noch weitere Einstellungen machen (Click Event)
controlManager.AddControl(mybutton) ; Den Button zu den angezeigten Custom Controls hinzufügen

;Zweiter Button, wie erster
mybutton2 := new GDIButton(myhwnd, 30, 160, 200, 50, "Polymorph It!")
mybutton2.ClickEvent.Handler := Func("PolyMorph_OnButton_Clicked")
controlManager.AddControl(mybutton2)


bar3 := new GDIProgressBar(myhwnd, 280, 180, 200, 30, 50)
slider := new GDISlider(myhwnd, 280, 220, 200, 50, 50)
slider.Bind(bar3)
slider.Bind(bar2)

controlManager.AddControl(bar3)
controlManager.AddControl(slider)


;Dritter Button
animator := new GDIButton(myhwnd, 300, 300, 120, 30, "Animate")
animator.ClickEvent.Handler := Func("Animate_Controls")
controlManager.AddControl(animator)

return

/*
   Animiert alle Custom Controls
*/
Animate_Controls(button){
   global controlManager
   button.Enabled := false
   saveState := controlManager.PopulateMouseMoveEvent
   controlManager.PopulateMouseMoveEvent := false
   
   for each, control in controlManager.Controls
   {
      if(control != button){ ; dont animate itself
         control.OnHover()
         Sleep, 200
         control.OnHoverLost()
      }
   }
   button.Enabled := true
   controlManager.PopulateMouseMoveEvent := saveState
}
 
 /*
   Wird aufgerufen wenn auf den 1. Button geklickt wird
 */
OnButton_Clicked(button){
   MsgBox % "Der GDIButton" button.Text "wurde geklickerlt :_D"
}

OnSliderChanged:
   bar.Percent := Slider1
   ;bar2.Percent := Slider1
return


/*
   Wird aufgerufen wenn auf den 2ten und alle hier in dieser Routine erstellten geklickt werden
*/
PolyMorph_OnButton_Clicked(button){
   global myhwnd, controlManager, GDIButton
   if(!button.HasPolymorhped){
      btn := new GDIButton(myhwnd, button.X, button.Y + button.Height + 10 , button.Width, button.Height, "Polymorph It!")
      btn.ClickEvent := button.ClickEvent
      controlManager.AddControl(btn)
      button.HasPolymorhped := true
   }else
      MsgBox Niiicht: Ich hab mich bereits verbreitet :D
}


GuiClose:
ExitApp