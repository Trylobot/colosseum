Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Generic globals
Const INFINITY% = -1

'Window / Arena size
Const arena_offset% = 50
Const arena_w% = 500
Const arena_h% = 500
Const stats_panel_w% = 250
Const window_w% = arena_w + 2*arena_offset + stats_panel_w
Const window_h% = arena_h + 2*arena_offset

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
SetGraphicsDriver GLMax2DDriver()
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'Settings flags
Global FLAG_in_menu% = True
Global FLAG_in_shop% = False
Global FLAG_level_intro% = False
Global level_intro_freeze_time% = 500
Global level_passed_ts%
Global FLAG_game_in_progress% = False
Global FLAG_game_over% = False
Global FLAG_bg_music_on% = False
Global FLAG_draw_help% = False
Global FLAG_player_engine_ignition% = False
Global FLAG_player_engine_running% = False

Const MENU_RESUME% = 0
Const MENU_NEW% = 1
Const MENU_LOAD% = 2
Const MENU_SETTINGS% = 3
Const MENU_QUIT% = 4
'light tank = 5
'laser tank = 6
'medium tank = 7
Const menu_option_count% = 8

Global menu_display_string$[] = [ "resume", "new game", "load saved", "settings", "quit", "light tank", "laser tank", "medium tank" ]
Global menu_enabled%[] =        [  False,    True,       False,        False,      True,   False,        False,        False ]
Global menu_option% = MENU_NEW

Const PICKUP_PROBABILITY% = 5000 'chance in 10,000 of an enemy dropping a pickup (randomly selected from all pickups)

'global player stuff
Global player_type% = 0
Global player:COMPLEX_AGENT
Global player_level% = 0
Global player_cash% = 0
Global player_kills% = 0

'______________________________________________________________________________
'Menu Commands
Function menu_command( command_index% )
	Select command_index
		
		Case MENU_RESUME
			FLAG_in_menu = False
			FLAG_player_engine_running = True
		
		Case MENU_NEW
			menu_enabled[MENU_NEW] = False
			menu_enabled[5] = True
			menu_enabled[6] = True
			menu_enabled[7] = True
			menu_option = 5
			
		Case MENU_LOAD
			'..?
		
		Case MENU_SETTINGS
			'..?
		
		Case MENU_QUIT
			End 'quit now
			
		Default
			player_type = command_index - 5
			FLAG_in_menu = False
			reset_game()
			initialize_game()
			FLAG_game_in_progress = True
			menu_enabled[MENU_NEW] = True
			menu_enabled[5] = False
			menu_enabled[6] = False
			menu_enabled[7] = False
			FLAG_player_engine_ignition = True
			
	End Select
End Function
'______________________________________________________________________________
Function reset_game()
	bg_cache = Null
	particle_list_background.Clear()
	particle_list_foreground.Clear()
	retained_particle_list.Clear()
	projectile_list.Clear()
	friendly_agent_list.Clear()
	hostile_agent_list.Clear()
	pickup_list.Clear()
	control_brain_list.Clear()
	player = Null
	player_level = -1
	player_cash = 0
	player_kills = 0
	FLAG_game_in_progress = False
	FLAG_game_over = False
End Function
'______________________________________________________________________________
Function initialize_game()
	player_level = -1
	respawn_player( player_type )
	load_next_level()
End Function
'______________________________________________________________________________
Function load_next_level()
	dim_bg_cache()
	player_level :+ 1
	respawn_enemies()
	update_all()
	FLAG_level_intro = True
	level_passed_ts% = now()
	player_kills = 0
	init_pathing_system()
	init_pathing_grid_from_walls( common_walls )
	If player_level < level_walls.Length Then init_pathing_grid_from_walls( level_walls[player_level] )
End Function
'______________________________________________________________________________
Function init_pathing_system()
	pathing_grid_h = (arena_h + 2*arena_offset) / cell_size
	pathing_grid_w = (arena_w + 2*arena_offset) / cell_size
	pathing = PATHING_STRUCTURE.Create( pathing_grid_h, pathing_grid_w )
End Function
'______________________________________________________________________________
Function next_enabled_menu_option()
	menu_option :+ 1
	If menu_option >= menu_option_count Then menu_option = 0
	While Not menu_enabled[ menu_option ]
		menu_option :+ 1
		If menu_option >= menu_option_count Then menu_option = 0
	End While
End Function
Function prev_enabled_menu_option()
	menu_option :- 1
	If menu_option < 0 Then menu_option = menu_option_count - 1
	While Not menu_enabled[ menu_option ]
		menu_option :- 1
		If menu_option < 0 Then menu_option = menu_option_count - 1
	End While
End Function
'______________________________________________________________________________
'Spawning and Respawning
Function respawn_player( archetype_index% )
	If player <> Null And player.managed() Then player.remove_me()
	player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( player_archetype[archetype_index], ALIGNMENT_FRIENDLY ))
	player.pos_x = player_spawn_point.x
	player.pos_y = player_spawn_point.y
	player.ang = -90
	player.snap_turrets()
	Create_and_Manage_CONTROL_BRAIN( player, Null, CONTROL_TYPE_HUMAN, INPUT_KEYBOARD, UNSPECIFIED )
End Function
'______________________________________________________________________________
Function spawn_enemy:COMPLEX_AGENT( archetype_index% )
	Local nme:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( enemy_archetype[archetype_index], ALIGNMENT_HOSTILE ))
	If nme.motivator_count = 0 'turret
		If Rand( 0, 1 ) = 1 Then nme.pos_x = arena_offset + RandF( 0, 0.25*arena_w ) ..
		Else                     nme.pos_x = arena_offset + RandF( 0.75*arena_w, arena_w )
		If Rand( 0, 1 ) = 1 Then nme.pos_y = arena_offset + RandF( 0, 0.25*arena_h ) ..
		Else                     nme.pos_y = arena_offset + RandF( 0.75*arena_h, arena_h )
		nme.ang = Rand( 0, 359 )
	Else
		Local spawn_i% = Rand( 0, enemy_spawn_points.Length - 1 )
		nme.pos_x = enemy_spawn_points[spawn_i].x
		nme.pos_y = enemy_spawn_points[spawn_i].y
		nme.ang = spawn_i * 90
	End If
	nme.snap_turrets()
	Return nme
End Function
'______________________________________________________________________________
Function respawn_enemies()
	For Local i% = 1 To (3 + player_level)
'		Local selector# = RandF( 0.000, 1.000 )
'		If      selector < 0.400 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MR_THE_BOX), Null, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_MR_THE_BOX, 2000 ) ..
'		Else If selector < 0.600 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MOBILE_MINI_BOMB), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_SEEKER, 20 ) ..
'		Else If selector < 0.800 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_TURRET, 50 ) ..
'		Else If selector < 0.900 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_TURRET, 50 ) ..
'		Else If selector < 1.000 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_TURRET, 50 )
		Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MR_THE_BOX), Null, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_MR_THE_BOX, 2000 )
	Next
End Function
'______________________________________________________________________________
Function spawn_pickup( x#, y# )
	Local pkp:PICKUP
	If Rand( 0, 10000 ) < PICKUP_PROBABILITY
		Local index% = Rand( 0, pickup_archetype.Length - 1 )
		pkp = pickup_archetype[index].clone()
		pkp.pos_x = x; pkp.pos_y = y
		pkp.auto_manage()
	End If
End Function


