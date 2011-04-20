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
Global upscale_buffer_img:TImage
Global upscale_buffer:IMAGE_BUFFER
Global global_scale#

Function init_graphics()
	EndGraphics()
	SetGraphicsDriver GLMax2DDriver()
	If Not SETTINGS_REGISTER.FULL_SCREEN.get()
		
		Graphics( ..
			SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get(), ..
			SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.get(),,, ..
			GRAPHICS_BACKBUFFER )
			
		?Win32
		set_window( WS_MINIMIZEBOX )
		?
	Else 'fullscreen
		
		Graphics( ..
			SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get(), ..
			SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get(), ..
			SETTINGS_REGISTER.BIT_DEPTH.get(), ..
			SETTINGS_REGISTER.REFRESH_RATE.get(), ..
			GRAPHICS_BACKBUFFER )
			
	End If
	
	glewInit() 'GL extension library

	'SetVirtualResolution( ..
	'	SETTINGS_REGISTER.WINDOW_WIDTH.get(), ..
	'	SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
	
	FLAG.upscale = SETTINGS_REGISTER.WINDOW_WIDTH.get() <> SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get() Or SETTINGS_REGISTER.WINDOW_HEIGHT.get() <> SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.get()

	global_scale = Min( ..
		Float(SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get())/Float(SETTINGS_REGISTER.WINDOW_WIDTH.get()), ..
		Float(SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.get())/Float(SETTINGS_REGISTER.WINDOW_HEIGHT.get()) )
	
	If Not FLAG.upscale
		upscale_buffer_img = Null
		upscale_buffer = Null
	Else 'upscale enabled
		upscale_buffer_img = CreateImage( SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get(),, 0 )
		upscale_buffer = IMAGE_BUFFER.CreateFromImage( upscale_buffer_img )
	End If
	
	SetClsColor( 0, 0, 0 )
	SetBlend( ALPHABLEND )
	Cls()
End Function


