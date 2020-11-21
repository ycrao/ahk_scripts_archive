/*
* AHK_L Decompiler / Source Extractor
* Written by IsNull 2012
* the payload method bases on fincs injection example
*
* This Script suports generic resource extraction
*
*
* This version is based upon a dll injection which can extract the resources. This method was discovered by fincs, so credits go to him!
*
*/
global DEBUG := false

global POSSIBLE_RESOURCE_NAMES := [">AHK WITH ICON<", ">AUTOHOTKEY SCRIPT<"]
global PATCHED_RESOURCE_NAMES  := [">UHK WITH ICON<", ">UUTOHOTKEY SCRIPT<"]

global ExtractionDir := A_ScriptDir "\ExtractionTemp"

;EXTERNAL RESOURCES: 
global DecompilerPayload_URL := "http://dl.securityvision.ch/tools/decompiler_payload.dll"
global DecompilerPayload64_URL := "http://dl.securityvision.ch/tools/decompiler_payload_64.dll"

global DecompilerPayload_BIN := A_ScriptDir "\payload.dll"
global DecompilerPayload64_BIN := A_ScriptDir "\payload64.dll"

global CurrentPayload_BIN := ExtractionDir "\winmm.dll"

Gui, new, +Resize
Gui, Color, White
Gui, add, Edit, w800 h20 gExtractNow vAHKExe, [drag your compiled exe here]
Gui, Font,, Consolas
Gui, add, Edit, +ReadOnly vMyLog w800 h200
Gui, add, Edit, +ReadOnly vScriptSource w800 h500 c4A708B
Gui, Font
Gui, show,, AHK_L Decompiler by IsNull

LogLn("<Running on: AHK Version "A_AhkVersion " - " (A_IsUnicode ? "Unicode" : "Ansi") " " (A_PtrSize == 4 ? "32" : "64") "bit>")
return


GuiClose: 
ExitApp

GuiSize:
Anchor("AHKExe","w")
Anchor("MyLog","w")
Anchor("ScriptSource","wh")
return

ExtractNow:
	Gui,submit, nohide

	LogClear()
	GuiCodeSet("")

	if(PrepareFile(AHKExe, preparedFile))
	{
		
		; file was prepared successfull
		if(EnsurePayloadIsPresent())
		{
			LogLn("<Injecting payload...>")

			PlacePayload(preparedFile)

			RunWait, % preparedFile, % ExtractionDir, UseErrorLevel
			if(ErrorLevel == "ERROR")
			{
				LogLn("<The Target could not be started. Is this a valid PE Executable?>")
			}else{
				SplitPath, preparedFile, OutFileName, OutDir, OutExtension, OutNameNoExt
				tmpCodePath := OutDir "\" OutNameNoExt "-uncompiled.ahk"

				try {
					WaitForFile(tmpCodePath, 10000) ; wait maximum 10secs for the file, this should be enough for even very slow harddisks.
				}catch e{
					LogLn("<" e.Message ">")
					LogLn("<Missing: " tmpCodePath ">")
				}

				if(FileExist(tmpCodePath))
				{
					LogLn("<Payload succeeded. Recovering Script.>")
					FileRead, script, % tmpCodePath
					if(!DEBUG)
						FileDelete, % tmpCodePath
					GuiCodeSet(script)
				}else{
					LogLn("<Script could not be extracted.>")
				}
				if(!DEBUG)
					FileDelete, % CurrentPayload_BIN ; remove the winmm.dll as it causes trouble if it get accedintially injected.^^
			}
		}else{
			LogLn("<Missing payload. Aborting now.>")
			return
		}
	}else{
		LogLn("<File seems not to be a valid compiled AHK Script or it uses an unknown protection.>")
	}
	if(!DEBUG)
		FileDelete, % preparedFile

return

GuiDropFiles: 
   GuiControl,,AHKExe, % A_GuiEvent
return

/*
* Waits until the file is present
* can be aborted by the timeout
*
* file	  File-Path to check
* timeout   Timeout in Milliseconds (Max waittime)
*/
WaitForFile(file, timeout=5000){
   start := A_TickCount
   
   while(!FileExist(file))
   {
	  if((A_TickCount - start) > timeout)
		 throw Exception("TimeoutException: File was not present whithin the expected time.")
   }
}

PlacePayload(preparedFile){
   success := false
   SplitPath, preparedFile, OutFileName, OutDir
   
   if(Is64BitAssembly(preparedFile))
   {
	  LogLn("<Target Application is 64bit.>")
	  payloadSrc := DecompilerPayload64_BIN 
   }else{
	  LogLn("<Target Application is 32bit.>")
	  payloadSrc := DecompilerPayload_BIN
   }
   
   if(FileExist(payloadSrc))
   {
	  FileCopy, % payloadSrc, % CurrentPayload_BIN, 1
	  success := true
   }
   return success
}

Is64BitAssembly(appName){
   static GetBinaryType := "GetBinaryType" (A_IsUnicode ? "W" : "A")
   static SCS_32BIT_BINARY := 0
   static SCS_64BIT_BINARY := 6

   ret := DllCall(GetBinaryType
	  ,"Str", appName
	  ,"int*", binaryType)
   
   return binaryType == SCS_64BIT_BINARY
}

EnsurePayloadIsPresent(){
   if(!FileExist(DecompilerPayload_BIN))
   {
	  URLDownloadToFile, % DecompilerPayload_URL, % DecompilerPayload_BIN
	  LogLn("<" DecompilerPayload_BIN " downloaded.>")
   }
   if(!FileExist(DecompilerPayload64_BIN))
   {
	  URLDownloadToFile, % DecompilerPayload64_URL, % DecompilerPayload64_BIN
	  LogLn("<" DecompilerPayload64_BIN " downloaded.>")
   }
   
   return FileExist(DecompilerPayload_BIN)
}

PrepareFile(fileToPrepare, byref preparedFile){
   
   success := false
   
   if(!FileExist(ExtractionDir))
	  FileCreateDir, % ExtractionDir
   
   if(FileExist(fileToPrepare))
   {
	  
	  LogLn("<Recover Source for " fileToPrepare ">")
   
	  
	  binaryTarget := ExtractionDir "\patched.exe"
	  preparedFile := binaryTarget
	  FileCopy, % fileToPrepare, % binaryTarget, 1
	  LogLn("<Starting file analysis...>")
	  ;##########
	  
	  ofile := FileOpen(binaryTarget, "rw")
	  VarSetCapacity(buffer, ofile.Length) 
	  bytesRead := ofile.RawRead(buffer, ofile.Length)
	  
	  LogLn("<Readed " bytesRead " bytes from file.>")
	  
	  
	  if(HasPEHeaderMagic(buffer))
	  {
		 LogLn("<Seems to be a valid PE File.>")
		 
		 
		 for i, resName in POSSIBLE_RESOURCE_NAMES
		 {
			ahkResourceName := StringToUTFByteArray(POSSIBLE_RESOURCE_NAMES[i])
			patch := StringToUTFByteArray(PATCHED_RESOURCE_NAMES[i])

			LogLn("<Searching for " ByteArrayToHex(ahkResourceName) " in " bytesRead "bytes.>")
			
			if(pos := FindMagic(buffer, bytesRead, ahkResourceName))
			{
				if(PatchBinary(ofile, pos, patch)){
				   LogLn("<Patched successfull>")
				   success := true
				   break
				}
			}
		 }
		 
		 ofile.Close() ; Flush
	  }else{
		 LogLn("<Whatever you dragged here, this is NOT a valid PE file.>")
	  }
	  
	  ;##########
	  
   }else{
	  LogLn("<File Not Found!>")
   }
   
   return success
}

HasPEHeaderMagic(ByRef buffer){
   return (NumGet(buffer,0,"UChar") == 77 && (NumGet(buffer,1,"UChar") == (A_IsUnicode ? 90 : 82)))
}

PatchBinary(targetfile, pos, byteArrayReplacement){
   
   written := false
   
   if(!IsObject(targetfile)){
	  throw "targetfile: must be a valid file instance"
   }

   if(pos != -1)
   {
	  LogLn("<Found Resource-Name @" pos ">")
	  LogLn("<Patching Resource-Name...>")
	  
	  targetfile.Seek(pos)   
	  size := ByteArrayToBuffer(byteArrayReplacement, patched)
	  written := targetfile.RawWrite(patched, size)
	  
	  LogLn("<PatchBinary: Written " written " bytes.>")
   }else{
	  LogLn("<Could not find pattern: " ByteArrayToHex(arr) ">")
   }
   
   return written
}


global mylogData := ""
LogLn(line){
   global
   mylogData .= line "`n"
   GuiControl,,MyLog, % mylogData
}
LogClear(){
   global
   mylogData := ""
   GuiControl,,MyLog, % mylogData
}

GuiCodeSet(scriptcode){
   global
   GuiControl,,ScriptSource, % scriptcode
}

StringToUTFByteArray(str){
   bufSize := StringToUTFBUffer(str, buf)
   return BufferToByteArray(buf, bufSize)
}

StringToUTFBUffer(str, byref buf){
   ;size := StrPut(str, "UTF-16") ; seems the size is not calculated correctly for UTF-16 Strings...
   size := (StrPut(str, "UTF-16") - 1) * 2
   VarSetCapacity( buf, size, 0x00)
   StrPut(str, &buf, size, "UTF-16")
   return size
}

BufferToHex( ptr, size )
{
   myhexdmp := ""
   SetFormat, integer, hex
   Loop, % size
   {
	  byte := NumGet(ptr+0, A_index-1,"UChar") + 0
	  myhexdmp .= byte
   }
   return myhexdmp
}

ByteArrayToHex(arr){
   s := ""
   SetFormat, integer, hex
   for each, byte in arr
   {
	  byte += 0
	  s .= (StrLen(x := SubStr(byte, 3)) < 2 ? "0" x : x ) " "
   }
   SetFormat, integer, dez
   StringUpper, s, s
   return s
}

PrintArr(obj) { 
	str := ""
   for i, val in obj
	  str .= "[" i "] -> " val  "`n"
   return str
}
PrintArrAsStr(obj) { 
	str := ""
   for each, val in obj
	  str .= val "(" (val != 0 ? chr(val) : "null") ")"  "`n"
   return str
}

ToByteArray(str){
   bytes := []
   Loop, parse, str
	  bytes[A_index] := asc(A_LoopField)
   return bytes
}

ByteArrayToBuffer(byteArray, byref buf){
   bufferSize := byteArray.MaxIndex()
   VarSetCapacity(buf, bufferSize, 0x00)
   for each, byte in byteArray
	  NumPut(byte, buf, A_Index-1, "uchar")
   return bufferSize
}

BufferToByteArray(byref buffer, size){
   arr := []
   loop, % size
	  arr[A_index] := NumGet(buffer, A_Index-1, "UChar")
   return arr
}

/************************************************
* FindMagic
*
* Search in binary data for a given byte-Pattern
*
* buffer   binary data
* size	  size of the buffer
* magic	  Byte-Array of the pattern to search
* offset   start offset to skip
*
* returns the position where the found magic starts
*		 -1 indicates that no match was found
*************************************************
*/
FindMagic(byref buffer, size, magic, offset=0){
   magicLen := ByteArrayToBuffer(magic, magicBuffer)
   magicByte := magic[1]
   searchPtr := &buffer + offset
   searchEnd := &buffer + size - magicLen + 1  ; First byte must precede searchEnd.
   if(searchPtr >= searchEnd)
	  return -1
   while searchPtr := DllCall("msvcrt\memchr", "ptr", searchPtr, "int", magicByte
							  , "ptr", searchEnd - searchPtr, "ptr"){
	  if !DllCall("msvcrt\memcmp", "ptr", searchPtr, "ptr", &magicBuffer, "ptr", magicLen)
		 return searchPtr - &buffer  ; I think this is what the script expects...
	  ++searchPtr  ; Resume search at the next byte.
   }
   return -1
}




/*
   Function: Anchor by Polyethene
	  Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.
   See http://www.autohotkey.com/community/viewtopic.php?t=4348
*/
Anchor(i, a = "", r = false) {
   static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
   If z = 0
	  VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
   If (!WinExist("ahk_id" . i)) {
	  GuiControlGet, t, Hwnd, %i%
	  If ErrorLevel = 0
		 i := t
	  Else ControlGet, i, Hwnd, , %i%
   }
   VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
	  , giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
   If (gp != gpi) {
	  gpi := gp
	  Loop, %gl%
		 If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
			gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
			Break
		 }
	  If (!gf)
		 NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
   }
   ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
   Loop, %cl%
	  If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
		 If a =
		 {
			cf = 1
			Break
		 }
		 giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
			, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
		 Loop, Parse, a, xywh
			If A_Index > 1
			   av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
				  , d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
		 DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
			, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
		 If r != 0
			DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
		 Return
	  }
   If cf != 1
	  cb := cl, cl += cs
   bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
   If cf = 1
	  dw -= giw - gw, dh -= gih - gh
   NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
	  , NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
   Return, true
}