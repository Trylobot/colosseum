Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Generic globals
Const INFINITY% = -1
Global mouse_point:cVEC = New cVEC
'environment objects
Global player_game:ENVIRONMENT 'game in which player participates
Global ai_demo_game:ENVIRONMENT 'menu ai demo environment
Global game:ENVIRONMENT 'current game environment

'game settings flags
Global FLAG_in_menu% = True
Global FLAG_in_shop% = False
Global FLAG_bg_music_on% = False
Global FLAG_draw_help% = False
Global FLAG_console% = False
Global level_intro_time% = 2000
Global level_passed_ts%
Global FLAG_AI_demo% = True

'game state flags
Global FLAG_game_in_progress% = False
Global FLAG_game_over% = False
Global FLAG_player_engine_ignition% = False
Global FLAG_player_engine_running% = False
Global FLAG_player_in_locker% = False
Global FLAG_waiting_for_player_to_enter_arena% = False
Global FLAG_battle_in_progress% = False
Global battle_toggle_ts%
Global arena_lights_fade_time% = 1000
Global FLAG_waiting_for_player_to_exit_arena% = False
Global FLAG_spawn_enemies% = False

'global player stuff
Global player_type% = 0
Global player_input_type% = INPUT_KEYBOARD_MOUSE_HYBRID 
Global player_level% = 0
Global player_cash% = 0
Global player_level_kills%
Global level_enemies_remaining%

Const PICKUP_PROBABILITY# = 0.50 'chance of an enemy dropping a pickup (randomly selected from all pickups)

'______________________________________________________________________________
Function get_player_id%()
	If game.player <> Null
		Return game.player.id
	Else
		Return -1
	End If
End Function

'______________________________________________________________________________
Function reset_game()
	game.clear()	
'	bg_cache = Null
'	
'	particle_list_background.Clear()
'	particle_list_foreground.Clear()
'	retained_particle_list.Clear()
'	retained_particle_list_count = 0
'	projectile_list.Clear()
'	friendly_agent_list.Clear()
'	hostile_agent_list.Clear()
'	pickup_list.Clear()
'	control_brain_list.Clear()
'	
'	player = Null
	player_level = -1
	player_cash = 0
	player_level_kills = 0
	level_enemies_remaining = -1
	
'	pathing = Null
	
	FLAG_game_in_progress = False
	FLAG_game_over = False
	
'	reset_all_doors()
	
	FLAG_waiting_for_player_to_exit_arena = False
	FLAG_player_in_locker = True
	FLAG_spawn_enemies = False
	
End Function
'______________________________________________________________________________
Function init_game()
'	init_pathing_system()
	player_level = -1
	respawn_player( player_type )
	game.load_level( get_next_level() )
End Function

'Placeholder
Function get_next_level:LEVEL()
	Return New LEVEL
	'..?
End Function
'______________________________________________________________________________
Function load_next_level()
'	player_level :+ 1
'	load_level( player_level )
End Function

Function load_level( index% )
'	FLAG_player_in_locker = True
'	FLAG_waiting_for_player_to_enter_arena = True
'	FLAG_battle_in_progress = False
'	FLAG_waiting_for_player_to_exit_arena = False
'	
'	FLAG_dim_bg = True
'	FLAG_retain_particles = True
'	
'	prep_spawner()
'	update_all()
'	level_passed_ts% = now()
'	
'	all_walls.Clear()
'	all_walls.AddLast( common_walls )
'	all_walls.AddLast( get_level_walls( player_level ))
'	
'	clear_pathing_grid_center_walls()
'	init_pathing_grid_from_walls( get_level_walls( player_level ))
End Function

Function load_AI_demo_level()
	
End Function
'______________________________________________________________________________
'Spawning and Respawning
Function respawn_player( archetype_index% )
	
	If game.player <> Null And game.player.managed() Then game.player.unmanage()
	game.player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], ALIGNMENT_FRIENDLY ))
	game.player_brain = Create_and_Manage_CONTROL_BRAIN( game.player, CONTROL_TYPE_HUMAN, player_input_type )
	
	game.player_spawn_point = New POINT'friendly_spawn_points[ Rand( 0, friendly_spawn_points.Length - 1 )]
	game.player.pos_x = game.player_spawn_point.pos_x - 0.5
	game.player.pos_y = game.player_spawn_point.pos_y - 0.5
	game.player.ang = -90
	game.player.snap_all_turrets()
	
	FLAG_player_engine_ignition = False
	FLAG_player_engine_running = False
		
End Function
'______________________________________________________________________________
Function spawn_pickup( x%, y% ) 'request; depends on probability
	Local pkp:PICKUP
	If Rnd( 0.0, 1.0 ) < PICKUP_PROBABILITY
		Local index% = Rand( 0, pickup_archetype.Length - 1 )
		pkp = pickup_archetype[index]
		If pkp <> Null
			pkp = pkp.clone()
			pkp.pos_x = x; pkp.pos_y = y
			pkp.auto_manage()
		End If
	End If
End Function
'______________________________________________________________________________
'Function init_pathing_grid_from_walls( level_walls:TList )
'	If pathing <> Null
'		For Local wall%[] = EachIn level_walls
'			pathing.set_area( containing_cell( wall[1], wall[2] ), containing_cell( wall[1]+wall[3], wall[2]+wall[4] ), wall[0] )
'		Next
'	End If
'End Function
'
'Function clear_pathing_grid_center_walls()
'	If pathing <> Null
'		pathing.set_area( containing_cell( arena_offset, arena_offset ), containing_cell( arena_offset+arena_w-1, arena_offset+arena_h-1 ), PATH_PASSABLE )
'	End If
'End Function
'______________________________________________________________________________
'Quit from anywhere; "instaquit", hold ESC to do it
Global esc_held% = False, esc_press_ts% = now()
Global esc_held_progress_bar_show_time_required% = 200, instaquit_time_required% = 1000

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
	Local alpha_multiplier# = time_alpha_pct( esc_press_ts + esc_held_progress_bar_show_time_required, esc_held_progress_bar_show_time_required )
	
	SetAlpha( 0.5 * alpha_multiplier )
	SetColor( 0, 0, 0 )
	DrawRect( 0,0, window_w,window_h )
	
	SetAlpha( 1.0 * alpha_multiplier )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	draw_percentage_bar( 100,window_h/2-25, window_w-200,50, Float( now() - esc_press_ts ) / Float( instaquit_time_required - 50 ))
	Local str$ = "continue holding ESC to quit"
	SetImageFont( get_font( "consolas_bold_24" ))
	DrawText( str, window_w/2-TextWidth( str )/2, window_h/2+30 )
End Function




