﻿; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_stop_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 6720 << !!A_IsUnicode)
B64 := "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"
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
DllCall("Gdiplus.dll\GdipCreateHICONFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}