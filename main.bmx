Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Window / Arena size
Const arena_offset% = 50
Const arena_offset_top% = 12
Const arena_offset_right% = 12
Const arena_offset_bottom% = 100
Const arena_offset_left% = 12
Const arena_w% = 500
Const arena_h% = 500
Const stats_panel_w% = 250
Const window_w% = arena_w + (2*arena_offset) + (arena_offset+stats_panel_w)
Const window_h% = arena_h + (2*arena_offset)
'Const window_w% = arena_offset_left + arena_w + arena_offset_right  + (arena_offset+stats_panel_w)
'Const window_h% = arena_offset_top + arena_w + arena_offset_bottom

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
If My.Application.DebugOn Then AppTitle :+ " " + My.Application.Platform + " (Debug)"
SetGraphicsDriver GLMax2DDriver()

Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

load_data_files()
load_all_archetypes()
load_environment()
'?Debug
'debug_load_data()
'End
'?

'______________________________________________________________________________
'MAIN
Local before% = 0
Repeat
	
	If (now() - before) > (1000/60) ' = 60 hertz
		before = now()
		get_all_input()
		collide_all()
		update_all()
	EndIf
	
	Cls
	draw_all()
	play_all()
?Debug
If player <> Null Then debug_overlay()
'If KeyHit( KEY_F4 ) And FLAG_game_in_progress
'	find_path( player.pos_x,player.pos_y, mouse_point.x,mouse_point.y )
'End If
?
	Flip( 1 )
	
Until AppTerminate()






