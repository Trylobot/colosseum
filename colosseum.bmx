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
		
		process_input()
		update_objects()
		collide()

	EndIf
	Cls	
	
	draw()
	play_bg_music()
	
'#####################################################################
'#####################################################################
'debugging
debug()
'SetOrigin( arena_offset, arena_offset )
'SetRotation( 0 )
'SetAlpha( 1 )
'SetScale( 1, 1 )
'For Local cb:CONTROL_BRAIN = EachIn control_brain_list
'	cb.debug()
'Next
'#####################################################################
'#####################################################################
	Flip( 1 ) 'draw to screen with vsync enabled
Until AppTerminate() 'kill app when ESC or close button pressed

