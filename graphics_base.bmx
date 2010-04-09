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
	EndGraphics()
	SetGraphicsDriver D3D9Max2DDriver()
	'SetGraphicsDriver D3D7Max2DDriver()
	'SetGraphicsDriver GLMax2DDriver()
	If Not fullscreen
		Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
		?Win32
		set_window( WS_MINIMIZEBOX )
		?
	Else 'fullscreen
		Graphics( window_w, window_h, bit_depth, refresh_rate, GRAPHICS_BACKBUFFER )
	End If
	SetClsColor( 0, 0, 0 )
	Cls()
	SetBlend( ALPHABLEND )
End Function


