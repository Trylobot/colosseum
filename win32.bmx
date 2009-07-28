Rem
	win32.bmx
	This is a COLOSSEUM project BlitzMax source file.
EndRem

Strict

?Win32
Import "icon/icon.o"
Import pub.Win32
Const ICON_BIG = 1
Extern "win32"
	Function FindWindowA(lpClassName$z, lpWindowName$z)
EndExtern
Global hWnd
Function set_window(GWLStyleFlags=0)	
	If TGLMax2DDriver(_max2ddriver)
		hWnd = FindWindowA("BlitzMax GLGraphics", AppTitle$)
	Else
		hWnd = FindWindowA("BBDX7Device Window Class", AppTitle$)
	EndIf	
	SetWindowLongA(hWnd, GWL_STYLE, GetWindowLongA(hWnd, GWL_STYLE) | GWLStyleFlags)
	SendMessageA(hWnd, WM_SETICON, ICON_BIG, LoadIconA(GetModuleHandleA(Null), Byte Ptr(101)))
EndFunction
Function close_message()
	Local msg:Byte Ptr
	GetMessageA( msg,hWnd,WM_CLOSE,WM_CLOSE )
	If msg[0] = WM_CLOSE Then Return True Else Return False
EndFunction
?
