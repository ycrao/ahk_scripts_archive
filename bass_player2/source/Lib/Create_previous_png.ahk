﻿; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_previous_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 3784 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAKFklEQVRo3u2Zf4xcVRXHP/e92ZmdnZn91Zbd7raQQmOx3dJqRIQmtKggJbS0hl+hgiREUaPBICBSkCAUKqCBCH80hr+MCGoEWlATEn+E0hrA2Fh+FKitrbvb3XZ/zK+dN/Peu/f4x3uzO7s7szvb8iMm3uS0OzPn3vP9nnPuefeep0SE/+VhfdwA/k/g4wZwqiNyKpMXPfhi5cfTgSuBzwJLgZVANPzNBfYDB4HXgN8CR3vvuvyUCahT2cSLHnyxHbgF2JyMRlYumZegoyVOSzzKvGQMWwUB1mIYzpfIOC6DGYfDw2PkXX8/8BzweO9dl498pAQWbdsVB24Fbv/UotaWpae1MD8VR9k2lmUBCqXUpDmBHcEYg2jNUM7h4PEM/+hNZ4BHgJ/2bt3gfOgEFm3btRHYsbKrpXP14vmkmmJYto1rLAZLhqxnGNNCzhfKSysFqYgiYSuaGyw6YhZRy2C0Jlcose8/Q+zvzwwAN/du3bDzQyHQvW2XDTx8Rlv81p6uds5Y0IxYNkcd4UTRkNeglAUqRFxtiICAiCFpw4JGi9PjCmU0R05kebN/hCOjzuPA9/q2btAfGIHuB3ZFgWdWdKY2X7C0k4ZolN6icHjMoJUVpEsoigrwZSIVNiRgACKICLYYliQsFjUqtOey+/0B3hrIPQdc23f3Bnc2bHWWUdnR05navHZZFzmx2TPicbAgGMtG2RbYFsoKBEtNiCKQiu/G9WwLZVsYy+ZgQdgz4pExNmuXddHTmdoMsuMDiUD3/Ttv/WRH6ifrzu7iUBGOFkFZdgjWmvB4rbSp6ROZiIgxiDGI0SyOwVlx+MuBft4ZzN3Rd8/GR06aQNf9Oy8FXrzuM0vsXhNhyFcoO4Ky7Yl0mSvwKkTKaSVaI9pnfkRYbPv88vXDGrii/56NL82ZQNePXkgCBy5dvrDbjScY8CxUpGGy508V/FQS5Uj4Hp0NhlhxjD+8dawPOLv/h1fkq02daQ/ceU53S3ckmWCgRFDjVZC/Vljnyyl+yqJUsKZlBTZsm4ES2Ikmzulu6Qa21gJZlUDXfS+0I9yypKOVQ3mNsm2UZQeb8IP0fOUop6Slgj1m2xzKG87saAHh2133vdBeNwFBburpSiX/7QhYdpAyam7Ao8abVSemq1RJFT7FLQssm8MO9HSlkoLcVDcBhBtTqQSlMKzBA6o+7yuEFen3+PLxV2nUpZp6n8geZvPw32h1s9OjoBQqTNcSilQqAcKNdRFYeO/zS1OxyPK02GDZiGWBshClAoGaEveLrB18jeuXzeerN1yPpabrRLXLmuNvsOX0Rm7Ych0x25qsE9pBWYFtyyYtNqlYZPnCe59fOhXvtOO0IBe3JqJopbDLhzLF5CdslbHQOc465xDrv7SWjo6OqjodzhBr8u9x2bo1LF68OHT69HUVClGEhUKhlaI1ESVb9C4mOJLXJoCwWiKRIG3Ck+VMaWOJYeXou3yhHS66bBPRaLSqzor0+3yhxWftJRtpampi1qHCGhWmsEQiIKyeNQIgy7DtiZgS5kGVkfQLfG7kn6z/9HJ6enqqLAVJL9C5ZNUyVq1aVX0hqfK50rYAth1gm42ACAtse5ZTJbCocIx13lHWX/Z55s+fX1XnrNJxznH7Z9SpKxIKbNtChAWzR0BIKmvyZq0ctmhWj77DFztiXHjhJhoaGmravnpRlNWrZ9apZqPy+7KooCIkZydQXk4YP/ZWDqMsOs5cxkXnnYU1y2Ph3HPPPTmvj0OR8TvEJGwVw6oyJ+N7GhFBTHCrGv9fwIjipdEGvv/6cYaKM985HntzhIxrZgFZgbNSJtkWAkxkZiUA9PmeH3o+lCox3jdc5Obdx/j7ULEmtt29ab72Sv+MOjMRm7Av+J4P0Dc7AZGDrushxkeMDgSDYEAMlZmZ9TR3vj7IU++mMVVI+tpn1A10fn5gFN/Uke1ixu2N2zc+ruuByMGps6ul0F7HcTFawkuGTEiNcP/qXxm+u3eA445fMz2ePZTlO3sG6Cv4U+1VT59xMRgtOI6LCHvrSCH5U8FxwwgE53PEgJm4eFQbb6dLfP2VfvYM1u6MvJ91ufmVfl7uG6uRNuV7QRiJ8Zuaj+N4gPx1VgInHrpqQPuyt5B3MJ6H0R5Ga4zRwWLhZbya5DzDPW8M8uTbI4z5Bh81TcfxDdv3nWD7viHGfIMrU3SMwRgd2NQexvMo5B183+w98dBV0/ZA1daiwFOZTOH8pkQc0RHE0sFNzFiILShhxofc7w5n2Xkkh69q1/+X+/L8+dgYvopX977W41fMTKaAwFPV1qlxnJans7nSgFMoYjwf4/sYP/CKaMHIzHtCBDw98++TdEy4ppbA874ObHo+TqFINlcaQOTpugkM/fhqB9ieHh1Dey7G99BemEpzIFGXTAWvdWDL99CeS3p0DGB7iKnOCAQRfSKTK+1Lj2QxXgnx3UB0UGIJyysyvbzWJeE8wQRrGT9YO7RjvBLpkSyZXGmfCE/UwjljW2XeHc+uBPYs7GxOJptTWNEYVqQh7E7YE+2V8tEXZr92jtsLNu14O8VoxA88b9wS+WyOYwPZPHDB8MPX7K+13IydueGHr9mPsCWTLuA6DsYtYVwX8VzE9xHPQ3yN6HK5DVojGKkhgY4YE8zxdbiGj3guxnUxbgnXccikCyBsmQn8rBEYj8Ttz25NJRoeaGtLEG2Kh1GIBt0KOxLe2sKW4aRojDt74o+QABKWZO0HEfCDveYWHEZHx8iNeXcPP3LNttmw1d2dbr/tmTvjMfuhlpY4yeZkkEaRCMoKOnXlG1xlo3da6oS1HmOQcqk0fhAB3yOfzZPJODgl/YORR6/dXg+uOb0faL/tmUuB38xriydb25KB9yMNE32jcqfassIAqNDvoY3wQRg8ZcM673uI9kmP5hkedfLAVSOPXvvHejHNiYBSirZbfrEC294Rb4ysaWlupCkZD4iEHYRyGk1qwVT2P0256hhE+xTyDplsEaeod6P9b4w89pW36gZ0MgQINr7d+s0dm1QscX9TIros0RSlqSmG3TC1GVBOn/CfMHW051MolBgruBQK/gFxnbvTT970PGBkjq+M5kqgvEMbgJiVbG9OrP/WJqtt4eVWU/MFjfFoKhqxaYgGnYRogw2A62lEDJ5rcH1N0XGzxsm9arJDO8d+/7PnTOZEDvAA/6MgYBG8Po0DLUA70Ao0N55/5XlWW+fpdstpi7HsmEq0dQLIWPoYRpdM5vhRnR48Utzz671ABhgBRoE8UAwJmLoBnQKBCNAIJEPwLUAKaAq/bwh1bIIE0oAPlEKgeSAbksgAYwTvkvVcCcz1RXf5LGBCQEUgF34uArEp4Mu7wIQkvBBoESiEUgp/K59H5jRO5k19mYBX8dkNvVgGbjP5KV+eo6cQKZU9fzLgT5VA+W8dAimDDkvQtGZqeV55TqVUngbnNP4LzSWLeKh5dtcAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTMtMDctMDRUMDk6NDQ6NDkrMDg6MDA3z4+VAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDExLTAxLTAzVDEyOjQ0OjA4KzA4OjAwUBxWVAAAAABJRU5ErkJggg=="
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