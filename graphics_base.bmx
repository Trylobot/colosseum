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
	If Not SETTINGS_REGISTER.FULL_SCREEN.get()
		
		Graphics( ..
			SETTINGS_REGISTER.WINDOW_WIDTH.get(), ..
			SETTINGS_REGISTER.WINDOW_HEIGHT.get(),,, ..
			GRAPHICS_BACKBUFFER )
			
		?Win32
		set_window( WS_MINIMIZEBOX )
		?
	Else 'fullscreen
		
		Graphics( ..
			SETTINGS_REGISTER.WINDOW_WIDTH.get(), ..
			SETTINGS_REGISTER.WINDOW_HEIGHT.get(), ..
			SETTINGS_REGISTER.BIT_DEPTH.get(), ..
			SETTINGS_REGISTER.REFRESH_RATE.get(), ..
			GRAPHICS_BACKBUFFER )
			
	End If
	SetClsColor( 0, 0, 0 )
	Cls()
	SetBlend( ALPHABLEND )
End Function


