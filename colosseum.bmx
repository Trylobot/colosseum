Rem
	colosseum.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'##############################################################################
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

Local before% = 0
Repeat
	If (now() - before) > (1000/60) '60 physics intervals a second
		before = now()
		
		process_input()
		update_objects()
		collide()
		
	EndIf
	Cls	
	
	draw()
	
	'debug()
	Flip( 1 ) 'draw to screen with vsync enabled
Until KeyHit( KEY_ESCAPE ) Or AppTerminate() 'kill app when ESC or close button pressed

