; ref: https://www.autohotkey.com/boards/viewtopic.php?p=17326#p17326

#Include <Gdip>

;do not support gif
CopyImage("dog-kill.gif")

CopyImage(ImageFile) {
	pToken := Gdip_Startup()
	Gdip_SetBitmapToClipboard(pBitmap := Gdip_CreateBitmapFromFile(ImageFile))
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
}