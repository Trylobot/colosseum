Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "settings.bmx"
?Win32
'Import "os-windows.bmx"
?

'______________________________________________________________________________
Function init_graphics()
	If Not fullscreen
		Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
	Else 'fullscreen
		Graphics( window_w, window_h, bit_depth, refresh_rate, GRAPHICS_BACKBUFFER )
	End If
	SetClsColor( 0, 0, 0 )
	'SetClsColor( 127, 127, 127 )
	Cls()
	SetBlend( ALPHABLEND )
	SetMaskColor( 255, 255, 255 )
	?Win32
	set_window( WS_MINIMIZEBOX )
	?
End Function

