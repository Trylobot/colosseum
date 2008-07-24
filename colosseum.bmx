Rem
	colosseum.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'MAIN
Local before% = 0
Repeat
	If (now() - before) > (1000/60) '60 physics intervals a second
		before = now()
		
		get_input()
		update_all()
		collide_all()

	EndIf
	Cls	
	
	draw_all()
	play_bg_music()
	
	Flip( 1 ) 'draw to screen with vsync enabled
Until AppTerminate() 'kill app when ESC or close button pressed

