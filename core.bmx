Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Generic globals
Const INFINITY% = -1
Global mouse_point:cVEC = New cVEC
Global pathing:PATHING_STRUCTURE

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
Global battle_toggle_ts%
Global arena_lights_fade_time% = 1000
Global FLAG_waiting_for_player_to_exit_arena% = False
Global FLAG_spawn_enemies% = False
Global FLAG_retain_particles% = False

'global player stuff
Global player_type% = 0
Global player:COMPLEX_AGENT
Global player_brain:CONTROL_BRAIN
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
	
	FLAG_waiting_for_player_to_exit_arena = False
	FLAG_player_in_locker = True
	FLAG_spawn_enemies = False
	
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

Function singleton_pathing_system_f_value#( inquiry:CELL )
	Return pathing.f( inquiry )
End Function
'______________________________________________________________________________
Function load_next_level()
	player_level :+ 1
	load_level( player_level )
	'FLAG_retain_particles = True
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

	cur_squad = Null
	cur_spawn_point = Null
	last_spawned_enemy = Null
	enemy_spawn_queue.Clear()

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
'Spawning and Respawning
Function respawn_player( archetype_index% )
	
	If player <> Null And player.managed() Then player.remove_me()
	player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], ALIGNMENT_FRIENDLY ))
	player_brain = Create_and_Manage_CONTROL_BRAIN( player, CONTROL_TYPE_HUMAN, INPUT_KEYBOARD_MOUSE_HYBRID )
	
	player_spawn_point = friendly_spawn_points[ Rand( 0, friendly_spawn_points.Length - 1 )]
	player.pos_x = player_spawn_point.pos_x - 0.5
	player.pos_y = player_spawn_point.pos_y - 0.5
	player.ang = -90
	player.snap_turrets()
	
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
'______________________________________________________________________________
Function init_pathing_grid_from_walls( level_walls:TList )
	If pathing <> Null
		For Local wall%[] = EachIn level_walls
			pathing.set_area( containing_cell( wall[1], wall[2] ), containing_cell( wall[1]+wall[3], wall[2]+wall[4] ), wall[0] )
		Next
	End If
End Function

Function clear_pathing_grid_center_walls()
	If pathing <> Null
		pathing.set_area( containing_cell( arena_offset, arena_offset ), containing_cell( arena_offset+arena_w-1, arena_offset+arena_h-1 ), PATH_PASSABLE )
	End If
End Function
'______________________________________________________________________________
Function find_path:TList( start_x#, start_y#, goal_x#, goal_y# )
	Local start_cell:CELL = containing_cell( start_x, start_y )
	Local goal_cell:CELL = containing_cell( goal_x, goal_y )
	If pathing.grid( start_cell ) = PATH_BLOCKED Or pathing.grid( goal_cell ) = PATH_BLOCKED
		Return Null 'no path possible to or from
	End If
	
	pathing.reset()
	Local cell_list:TList = pathing.find_CELL_path( start_cell, goal_cell )

	Local list:TList = CreateList()
	If cell_list <> Null And Not cell_list.IsEmpty()
		For Local cursor:CELL = EachIn cell_list
			list.AddLast( cVEC.Create( cursor.col*cell_size + cell_size/2, cursor.row*cell_size + cell_size/2 ))
		Next
	End If
	Return list
End Function




