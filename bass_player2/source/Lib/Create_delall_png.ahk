﻿; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_delall_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 1432 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAEnQAABJ0BfDRroQAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAAIdEVYdFRpdGxlAE5vQDalzgAAABN0RVh0QXV0aG9yAEZsb3JpYW4gSGFhZ8tp13UAAAAYdEVYdENyZWF0aW9uIFRpbWUAMjAxMC0wMi0wMoMQbbcAAANWSURBVDiNTVFdSJtXGH7fc75j/BIzP+JPYrWLdUiQSEgkjctWJx3sZrC1F+tFkWawn2LZzWBj7Gq7tBfbWClsbLqxG+uE1lK6S4sdCEWntSDUdbmYUn+qifkxSZsTzznvbszwgYf36nne93kfICIAAFwZGRlduHjxWigU8gIAJyI4TgBgt/r6fvixp+fjZDJpAwASEViIiCup1GhXIjHGOfeMlUonvxLiCiJmiUgDACAim4lEJrpbW1Mv5XLP39re7jKDg98iYslaSaUuB4eHx9w+X7Mql+HVoaFzX0oprgJ8hIhZAKA7AwPj3YFAiknJW10ub0KIL2qbm1YhFLrKtGWFhcfjIaWAtAbb7WZDp0+//VlLy3g4HG67Ozj48yvB4PsCkZNSQEqBm8ilAM7ath3gj4RY7NjeHjjR0dHDAdBICZwI/R5Pb/jg4N1Qd/ebFhE3UoKREoqVCsxImbvnOJPGmCUeCATU7LNn8yey2Vin3/8yJ0JdN3GcVlSKmWoVTLUKxVIJZkql3FxT0y/GmJtSyg0kIojH44KIgp+2tf06nEicaQBAVS7Dceb29+Hm3l5+1rbHjTE3pJR/p9NpyQAAlpaWDhFx47vd3Q8fLS5ukNZwnEZrmN/bq83a9iQiTlcqlSfpdFoCADA4wvLysv6+s/PzaDTaRVpD/WHmaL7mOOK9g4M+Y0xmfX39sK6zjnrG+fPnr5+KRj/gRJYql//fXL+iiXN8o7HxLGYy11gkMoqI+0SkLUTEBxcuXD8Vj18+Li4Wi/Dn48eHr/v9QhyZeBBZkrFz6ulTgkjkCiJm+V8jI9/0JJOfCM4tIyWYahUK2SxMra7mpwGm3Pk86+Lczw4P0VSrwGo1bH3xImQXCsFcb+89tlMsbhQymVo9d7FQgKnV1fxdrSeMMT9NNTRcup/JPHheq1E9Uo4I1r1eH2Osnf/j9T5p3N112m07pqVkkwsL+TtSThDRjUqlsmZZVnbN7b7vyeXiHVp3bVWrdNtx/l3z+X4joocIADwcDrddcpyviejM75XKbaXUrXrPAAD9/f0NQojgO1tb42mXy1praZkmoj+EEJtIRICIPBaL+bTWJxljuXK5vFMX1xGPx4VSqt0YE7Asa6e5uXlvbm5O/Qc/dvF291C+YAAAAABJRU5ErkJggg=="
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}