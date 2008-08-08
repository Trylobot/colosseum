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
Global level_intro_time% = 2000
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

Function get_player_id%()
	If player <> Null
		Return player.id
	Else
		Return -1
	End If
End Function

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
			toggle_doors( ALIGNMENT_FRIENDLY )
			
	End Select
End Function
'______________________________________________________________________________
Function reset_game()
	bg_cache = Null
	particle_list_background.Clear()
	particle_list_foreground.Clear()
	retained_particle_list.Clear()
	retained_particle_list_count = 0
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
	prep_enemy_spawn_queue()
	update_all()
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
	player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], ALIGNMENT_FRIENDLY ))
	player.pos_x = player_spawn_point.pos_x
	player.pos_y = player_spawn_point.pos_y
	player.ang = -90
	player.snap_turrets()
	Create_and_Manage_CONTROL_BRAIN( player, CONTROL_TYPE_HUMAN, INPUT_KEYBOARD )
End Function
'______________________________________________________________________________
Function prep_enemy_spawn_queue()
	Local squads%[][] = get_level_squads( player_level )
	If squads <> Null
		For Local squad_i%[] = EachIn squads
			queue_squad( squad_i )
		Next
	End If
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


