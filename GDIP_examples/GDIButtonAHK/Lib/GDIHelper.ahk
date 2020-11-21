
AlphaBlend(hdcDest, xoriginDest, yoriginDest, wDest, hDest, hdcSrc, xoriginSrc, yoriginSrc, wSrc,  hSrc, byref BLENDFUNCTION){
   res := DllCall("Msimg32\AlphaBlend"
   , "uint", hdcDest
   , "int", xoriginDest
   , "int", yoriginDest
   , "int", wDest
   , "int", hDest
   , "uint", hdcSrc
   , "int", xoriginSrc
   , "int", yoriginSrc
   , "int", wSrc
   , "int", hSrc
   , "uint", BLENDFUNCTION)
   
   return res
}


/*
	TransparentBlt
	Same as BitBlp but makes a specific color transparent (simple color mask)
*/
TransparentBlt(hdc, xoriginDest, yoriginDest, wDest, hDest, hdcSrc, xoriginSrc, yoriginSrc, wSrc,  hSrc, crTransparent = 0x00000000){
   res := DllCall("Msimg32\TransparentBlt"
   , "uint", hdc
   , "int", xoriginDest
   , "int", yoriginDest
   , "int", wDest
   , "int", hDest
   , "uint", hdcSrc
   , "int", xoriginSrc
   , "int", yoriginSrc
   , "int", wSrc
   , "int", hSrc
   , "uint", crTransparent)
   return res
}