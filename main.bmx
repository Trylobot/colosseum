Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Window / Arena size
Const arena_offset% = 50
Const arena_offset_top% = 10
Const arena_offset_right% = 10
Const arena_offset_bottom% = 100
Const arena_offset_left% = 10
Const arena_w% = 500
Const arena_h% = 500
Const stats_panel_w% = 250
'Const window_w% = arena_w + (2*arena_offset) + (arena_offset+stats_panel_w)
'Const window_h% = arena_h + (2*arena_offset)
Const window_w% = (arena_offset_left + arena_w + arena_offset_right) + (arena_offset + stats_panel_w)
Const window_h% = (arena_offset_top + arena_w + arena_offset_bottom)

'external data load
load_data_files()
	load_all_archetypes() 'this will be in data files, eventually
	load_environment() 'same here; this will be externalized with LEVEL objects
'?Debug
'debug_load_data()
'End
'?

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
If My.Application.DebugOn Then AppTitle :+ " " + My.Application.Platform + " (Debug)"
SetGraphicsDriver GLMax2DDriver()

'GRAPHICS_BACKBUFFER|GRAPHICS_ALPHABUFFER|GRAPHICS_DEPTHBUFFER|GRAPHICS_STENCILBUFFER|GRAPHICS_ACCUMBUFFER )
Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
'Graphics( 1024, 768, 32, 85, GRAPHICS_BACKBUFFER )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

?Debug
Global last_frame_ts%, time_count%, frame_count%, fps%
'menu_command( COMMAND_NEW_GAME, PLAYER_INDEX_LIGHT_TANK )
?

'______________________________________________________________________________
'MAIN
Local before%
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
frame_count :+ 1
time_count :+ (now() - last_frame_ts)
last_frame_ts = now()
If time_count >= 1000
	fps = frame_count
	frame_count = 0
	time_count = 0
End If
If player <> Null Then debug_overlay()
'If KeyHit( KEY_F4 ) And FLAG_game_in_progress
'	find_path( player.pos_x,player.pos_y, mouse_point.x,mouse_point.y )
'End If
?
	check_esc_held()
	
	Flip( 1 )
	
Until AppTerminate()

'______________________________________________________________________________
'Quit from anywhere; "instaquit" by holding ESC
Global esc_held% = False, esc_press_ts% = now()
Global esc_held_progress_bar_show_time_required% = 300, instaquit_time_required% = 1500

Function check_esc_held()
	If KeyDown( KEY_ESCAPE ) And Not esc_held
		esc_press_ts = now()
		esc_held = True
	Else If KeyDown( KEY_ESCAPE ) 'esc_held
		If (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
			draw_instaquit_progress()
		End If
		If (now() - esc_press_ts) >= instaquit_time_required
			End
		End If
	Else
		esc_held = False
	End If
End Function

Function draw_instaquit_progress()
	SetAlpha( 0.5 )
	SetColor( 0, 0, 0 )
	DrawRect( 0,0, window_w,window_h )
	
	SetAlpha( 1 )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	draw_percentage_bar( 100,window_h/2-25, window_w-200,50, Float( now() - esc_press_ts ) / Float( instaquit_time_required ))
	Local str$ = "continue holding ESC to quit"
	SetImageFont( get_font( "consolas_bold_24" ))
	DrawText_with_glow( str, window_w/2-TextWidth( str )/2, window_h/2+30 )
End Function


