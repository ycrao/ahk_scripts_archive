﻿; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_mute_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 1448 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAPOSURBVHjaYtTRMWK4d+8ug7S0PAMrKwfD////wZidnZ1BQECITVpaarKIiGjY8+cvun/9+tXGyMjIgAwAAoiJAQf48+cP0AD+Ujk5uTR9fS0BSUnx4p8/fyqCxJExQAAx4dLMzc0d4uXlViUszMvAx8fNoKqqKAR0gcePHz8YkDFAAIENALqYgZmZieH37+8MHz++Y2BiYjRJTo6fpqmpzPXnz1cGMTEBoBclgGoYVT99+sDw5fMnhk9fvzB8+P6dASCAUFzw798/hq9fv0l7errNTkqKEr1z5xbDr18/geHBxiAiIgR0Fac00BuMP/7/Y2D59I5B+PEdBoAAYgEFGFAQiH8wfP/+Q9DGxrKvoCDf4OPHH8DAvQ/0zk8GFhZWBlYWFmAgswh8/vaNjff715+yD68zsAP1AAQQy9+/f2XFxMTUJCQkXZSUlJ0KCnLNPn78xfDlyxtgIIoxPLh/j+Hrt28M4hIyDMAIYPv++xebyfO7P7mAmn8CXQ0QQCw+Pt673Nw8NNjYeIF+ZGN49eorw4cPrxjU1WUZ5ORUGDh5+Blu37nDICohxfCHhYWR/9O7vzxAzd8YGOSBEfoQIAAAQQC+/wRLS0seKCgvANbW3QDe3uIA6+vsABISDwD5+fsA6uzwAOro7QAQzrsA38TFAOrm5PQc8u32EAD/cygZGVrX7OyGAojp2pUbX969/wSOElAggjS+e/cZFJgMn75/Y/i8fw9DgI0Ng5m5KYPNuRNion9+tnn7+rYVLV9uZKWtPQMggJiOHjt0n4Odg0FYWBgY2qzgAP30GeSNbwxfv7xi+M79j+Hd4ycMIlraDLnxsaY5BgaVTllZbO+vX2d49urVVYAAAEEAvv8D6uvqBO/v7znOzsvzycnC6OPh3AYHCAwGDw8RAAgF+gALIx0A/ggKAPKmpwAqMTEAHTc3AOnHxwCQiIi/0+7uWQKI5fXrV/M2b157gIGB8d/3719/ffnyWfrajYudX7++tXZysmVg+veB4R/nX4avjx4yMCxdCkmpb98yfP3z5zMw/X0GCCBmVla2v+Likm+A9FugIR++fv3y+PPnD2uuXDnHxMUvpCfx5y+7yokjDA5AL76/eZPh3u3bDCoSEgyqKirqD79+VQUIIGZmZhYGQUFhsMm/f/8GJqZvwOhkAQbF9z33nj2+xH7ntnGKro4IC1Bu7pUrZzf9+rVZlovLRFtVleHZ9+8KAAGEYcC3b18ZQFkWxOYWELr96eH9gyJv3+hef/z49/HXr2M+MjDMe/zzp9CLjx/VTzx9WgkQYADl4bxqBvZTHwAAAABJRU5ErkJggg=="
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