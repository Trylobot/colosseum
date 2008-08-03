Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'MAIN
Local before% = 0
Repeat
	If (now() - before) > (1000/60) '60 physics intervals a second
		before = now()
		
		get_all_input()
		collide_all()
		update_all()
		

	EndIf
	Cls	
	
	draw_all()
	play_all()

?Debug
	'debugger
	If KeyHit( KEY_F4 )
		find_path( player.pos_x, player.pos_y, MouseX() - arena_offset, MouseY() - arena_offset )
	End If
?
	
	Flip( 1 ) 'draw to screen with vsync enabled
Until AppTerminate() 'kill app when ESC or close button pressed

