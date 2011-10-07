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

	FLAG.upscale = SETTINGS_REGISTER.WINDOW_WIDTH.get() <> SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get() Or SETTINGS_REGISTER.WINDOW_HEIGHT.get() <> SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.get()

	global_scale = Min( ..
		Float(SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH.get())/Float(SETTINGS_REGISTER.WINDOW_WIDTH.get()), ..
		Float(SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT.get())/Float(SETTINGS_REGISTER.WINDOW_HEIGHT.get()) )
	
	init_viewport( global_scale )
	
	SetClsColor( 0, 0, 0 )
	SetBlend( ALPHABLEND )
	Cls()
End Function

Function init_viewport( Scale# )
	Local OrigX%, OrigY%, OrigW%, OrigH%
	GetViewport(OrigX,OrigY,OrigW,OrigH)
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT , 0)
	glMatrixMode GL_PROJECTION
	glLoadIdentity
	glOrtho 0,(Float(OrigW) / scale),(Float(OrigH) / scale),0,-1,1
	glMatrixMode GL_MODELVIEW 
	glViewport(0 , 0 , OrigW, OrigH)
	glScissor 0,0, OrigW ,OrigH
End Function

