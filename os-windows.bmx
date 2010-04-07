Rem
	os-windows.bmx
	This is a COLOSSEUM project BlitzMax source file.
EndRem
'SuperStrict

'Import pub.Win32
'Import "icon/icon.o"

?Win32

Extern "win32"
	Function FindWindowA( lpClassName$z, lpWindowName$z )
EndExtern

Global hWnd%
Const ICON_BIG% = 1
Function set_window( GWLStyleFlags% = 0 )	
	If TGLMax2DDriver(_max2ddriver)
		hWnd = FindWindowA("BlitzMax GLGraphics", AppTitle$)
	Else
		hWnd = FindWindowA("BBDX7Device Window Class", AppTitle$)
	EndIf	
	SetWindowLongA(hWnd, GWL_STYLE, GetWindowLongA(hWnd, GWL_STYLE) | GWLStyleFlags)
	SendMessageA(hWnd, WM_SETICON, ICON_BIG, LoadIconA(GetModuleHandleA(Null), Byte Ptr(101)))
EndFunction

?