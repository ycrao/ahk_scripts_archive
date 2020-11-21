
/*
	Controls Namespace Definition
*/

pToken_GDIP := 0
if(!pToken_GDIP){
  If (!pToken_GDIP := Gdip_Startup()){
	 MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system.
	 ExitApp
  }
}

#Include <Gdip>
#Include <GDIHelper>
#Include <CustomControlManager>

#Include <Control>
#Include <GDIButton>
#Include <GDIProgressBar>
#Include <GDISlider>
