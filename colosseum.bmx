Rem
	colosseum.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'temporary testing entities
'player
Global player:COMPLEX_AGENT
player = Copy_COMPLEX_AGENT( player_archetype[ 0], True )
player.pos_x = arena_w/2
player.pos_y = arena_h/2
player.ang = -90
player.turrets[0].ang = player.ang
player.turrets[1].ang = player.ang


'##############################################################################
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

Local before% = 0
Repeat
	If (now() - before) > (1000/60) '60 physics intervals a second
		before = now()
		
		respawn_enemies()
		process_input()
		update_objects()
		collide()
		
	EndIf
	Cls	
	
	draw()
	
	debug()
	Flip( 1 ) 'draw to screen with vsync enabled
Until KeyHit( KEY_ESCAPE ) Or AppTerminate() 'kill app when ESC or close button pressed

