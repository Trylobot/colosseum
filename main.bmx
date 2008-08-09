Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

?Debug
'	debug_range()
'	End
?

'______________________________________________________________________________
'MAIN
Local before% = 0
Repeat
	If (now() - before) > (1000/60) '60 hertz
		before = now()
		
		get_all_input()
		collide_all()
		update_all()
		
	EndIf
	Cls
	
	draw_all()
	play_all()

?Debug
'	debug_brain_under_mouse()
'	debug_general()
?
	
	Flip( 1 ) 'draw to screen with vsync enabled
Until AppTerminate() 'kill app when ESC or close button pressed

