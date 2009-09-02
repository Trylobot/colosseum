Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "settings.bmx"
?Win32
Import "win32.bmx"
?

'______________________________________________________________________________
Function init_graphics()
	If Not fullscreen
		Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
	Else 'fullscreen
		Graphics( window_w, window_h, bit_depth, refresh_rate, GRAPHICS_BACKBUFFER )
	End If
	SetClsColor( 0, 0, 0 )
	Cls()
  SetBlend( ALPHABLEND )
	?Win32
	set_window( WS_MINIMIZEBOX )
	?
End Function

