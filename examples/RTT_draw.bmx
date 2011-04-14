SuperStrict
Import "../TImageBuffer.bmx"

Local screen_width% = 640
Local screen_height% = 480


SetGraphicsDriver(GLMax2DDriver())
Graphics screen_width , screen_height
glewInit()
Local dynamic_background_image:TImage = CreateImage( screen_width, screen_height )
Local rtt_buffer:TImageBuffer = TImageBuffer.CreateFromImage( dynamic_background_image )

SetClsColor( 127, 127, 127 )
SetBlend( ALPHABLEND )

Local angle! = 0
Local last_mouse_x% = MouseX(), last_mouse_y% = MouseY(), mouse_x%, mouse_y%


While Not KeyHit(KEY_ESCAPE)
	mouse_x = MouseX()
	mouse_y = MouseY()
	
	rtt_buffer.BindBuffer()
	SetRotation( 0 )
	SetColor( 255, 255, 255 )
	If( 5 <= Sqr( (mouse_x - last_mouse_x)*(mouse_x - last_mouse_x) + (mouse_y - last_mouse_y)*(mouse_y - last_mouse_y) ))
		DrawLine( last_mouse_x, last_mouse_y, mouse_x, mouse_y )
		last_mouse_x = MouseX()
		last_mouse_y = MouseY()
	EndIf
	rtt_buffer.UnBindBuffer()
	
	Cls
	
	DrawImage( dynamic_background_image, 0, 0 )
	
	Flip(1)
	
EndWhile