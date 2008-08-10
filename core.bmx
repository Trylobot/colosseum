Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Generic globals
Const INFINITY% = -1

'game settings flags
Global FLAG_in_menu% = True
Global FLAG_in_shop% = False
Global FLAG_bg_music_on% = False
Global FLAG_draw_help% = False
Global FLAG_console% = False
Global level_intro_time% = 2000
Global level_passed_ts%
'game state flags
Global FLAG_game_in_progress% = False
Global FLAG_game_over% = False
Global FLAG_player_engine_ignition% = False
Global FLAG_player_engine_running% = False
Global FLAG_player_in_locker% = False
Global FLAG_waiting_for_player_to_enter_arena% = False
Global FLAG_battle_in_progress% = False
Global FLAG_waiting_for_player_to_exit_arena% = False
Global FLAG_spawn_enemies% = False

'global player stuff
Global player_type% = 0
Global player:COMPLEX_AGENT
Global player_spawn_point:POINT
Global player_level% = 0
Global player_cash% = 0
Global player_level_kills%
Global level_enemies_remaining%

Const PICKUP_PROBABILITY# = 0.50 'chance of an enemy dropping a pickup (randomly selected from all pickups)

'______________________________________________________________________________
Function get_player_id%()
	If player <> Null
		Return player.id
	Else
		Return -1
	End If
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
	player_level_kills = 0
	level_enemies_remaining = -1
	
	pathing = Null
	
	FLAG_game_in_progress = False
	FLAG_game_over = False
	
	reset_all_doors()
	
End Function
'______________________________________________________________________________
Function init_game()
	
	init_pathing_system()
	player_level = -1
	respawn_player( player_type )
	load_next_level()
	
End Function
'______________________________________________________________________________
Function init_pathing_system()
	
	pathing_grid_h = (arena_h + 2*arena_offset) / cell_size
	pathing_grid_w = (arena_w + 2*arena_offset) / cell_size
	pathing = PATHING_STRUCTURE.Create( pathing_grid_h, pathing_grid_w )
	init_pathing_grid_from_walls( common_walls )
	
End Function
'______________________________________________________________________________
Function load_next_level()
	player_level :+ 1
	load_level( player_level )
End Function
Function load_level( index% )
	
	FLAG_player_in_locker = True
	FLAG_waiting_for_player_to_enter_arena = True
	FLAG_battle_in_progress = False
	FLAG_waiting_for_player_to_exit_arena = False
	
	dim_bg_cache()
	prep_spawner()
	update_all()
	level_passed_ts% = now()
	
	all_walls.Clear()
	all_walls.AddLast( common_walls )
	all_walls.AddLast( get_level_walls( player_level ))
	
	clear_pathing_grid_center_walls()
	init_pathing_grid_from_walls( get_level_walls( player_level ))
	
End Function
'______________________________________________________________________________
Function prep_spawner()

	Local squads%[][] = get_level_squads( player_level )
	If squads <> Null
		For Local squad_i%[] = EachIn squads
			queue_squad( squad_i )
		Next
		level_enemies_remaining = enemy_count( squads )
	End If

	shuffle_anchor_deck()

End Function
'______________________________________________________________________________
Function enemy_died()
	level_enemies_remaining :- 1
End Function
'______________________________________________________________________________
'Spawning and Respawning
Function respawn_player( archetype_index% )
	
	If player <> Null And player.managed() Then player.remove_me()
	
	player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], ALIGNMENT_FRIENDLY ))
	player_spawn_point = friendly_spawn_points[ Rand( 0, friendly_spawn_points.Length - 1 )]
	player.pos_x = player_spawn_point.pos_x - 0.5
	player.pos_y = player_spawn_point.pos_y - 0.5
	player.ang = -90
	player.snap_turrets()
	
	Create_and_Manage_CONTROL_BRAIN( player, CONTROL_TYPE_HUMAN, INPUT_KEYBOARD )
	
	FLAG_player_engine_ignition = False
	FLAG_player_engine_running = False
	
End Function
'______________________________________________________________________________
Function spawn_pickup( x%, y% ) 'request; depends on probability
	Local pkp:PICKUP
	If RandF( 0.0, 1.0 ) < PICKUP_PROBABILITY
		Local index% = Rand( 0, pickup_archetype.Length - 1 )
		pkp = pickup_archetype[index].clone()
		pkp.pos_x = x; pkp.pos_y = y
		pkp.auto_manage()
	End If
End Function


