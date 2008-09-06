Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const SPAWN_POINT_OFFSET% = 43 'delete me (please?)

Type ENVIRONMENT
	Field origin:cVEC 'drawing origin
	Field bg_cache:TImage 'background image
	Field fg_cache:TImage 'foreground image

	Field lev:LEVEL 'level object from which to build the environment, read-only
	Field pathing:PATHING_STRUCTURE 'pathfinding object for this level
	Field walls:TList 'TList<BOX> contains all of the wall rectangles of the level
	Field spawn_cursor:CELL[] 'for each spawner, a (row,col) pointer indicating the current agent to be spawned
	Field spawn_ts%[] 'for each spawner, the timestamp of the spawn process start
	
	'Field enemy_spawn_queue:TList 'TList<COMPLEX_AGENT>
	'Field cur_squad:TList 'TList<COMPLEX_AGENT>
	'Field cur_turret_anchor:POINT 'turret spawn point (anchor)
	'Field cur_spawn_point:POINT 'normal spawn point
	'Field last_spawned_enemy:COMPLEX_AGENT 'pointer to last spawned enemy
	'Field squad_begin_spawning_ts% 'timestamp of the first enemy spawned from the most recent squad, for timing purposes
	
	Global DOOR_STATUS_OPEN% = 0
	Global DOOR_STATUS_CLOSED% = 1
	Field friendly_door_list:TList 'TList<WIDGET> list of paired door widgets
	Field friendly_doors_status% 'flag indicating state of all friendly doors
	Field hostile_door_list:TList'TList<WIDGET> list of paired door widgets
	Field hostile_doors_status% 'flag indicating state of all hostile doors
	Field all_door_lists:TList 'list of all door lists
	
	Field particle_list_background:TList 'TList<PARTICLE>
	Field particle_list_foreground:TList 'TList<PARTICLE>
	Field particle_lists:TList 'TList<TList<PARTICLE>>
	Field retained_particle_list:TList 'TList<PARTICLE>
	Field retained_particle_list_count% 'number of particles currently retained, cached for speed
	Field environmental_widget_list:TList
	Field projectile_list:TList 'TList<PROJECTILE>
	Field friendly_agent_list:TList 'TList<COMPLEX_AGENT>
	Field hostile_agent_list:TList 'TList<COMPLEX_AGENT>
	Field agent_lists:TList 'TList<TList<COMPLEX_AGENT>>
	Field pickup_list:TList 'TList<PICKUP>
	Field control_brain_list:TList 'TList<CONTROL_BRAIN>
	
	Field level_enemy_count% 'number of enemies that could possibly be spawned
	Field level_enemies_killed% 'number of enemies that have been killed since being spawned
	
	Field human_participation% 'flag indicating whether any humans will ever participate in this game
	Field game_in_progress% 'flag indicating the game has begun
	Field game_over% 'flag indicating game over state
	Field level_passed_ts%
	Field player_engine_ignition%
	Field player_engine_running%
	Field player_in_locker%
	Field waiting_for_player_to_enter_arena%
	Field battle_in_progress%
	Field battle_state_toggle_ts%
	Field waiting_for_player_to_exit_arena%
	Field spawn_enemies%

	Field player_spawn_point:POINT 'reference to the spawnpoint that will spawn or has spawned that player
	Field player_brain:CONTROL_BRAIN 'reference to that player's brain object
	Field player:COMPLEX_AGENT 'reference to that player object
	
	Method New()
		walls = CreateList()
		particle_list_background = CreateList()
		particle_list_foreground = CreateList()
		particle_lists = CreateList()
			particle_lists.AddLast( particle_list_background )
			particle_lists.AddLast( particle_list_foreground )
		retained_particle_list = CreateList()
		environmental_widget_list = CreateList()
		projectile_list = CreateList()
		friendly_agent_list = CreateList()
		hostile_agent_list = CreateList()
		agent_lists = CreateList()
			agent_lists.AddLast( friendly_agent_list )
			agent_lists.AddLast( hostile_agent_list )
		pickup_list = CreateList()
		control_brain_list = CreateList()
		'enemy_spawn_queue = CreateList()
		friendly_door_list = CreateList()
		friendly_doors_status = DOOR_STATUS_CLOSED
		hostile_door_list = CreateList()
		hostile_doors_status = DOOR_STATUS_CLOSED
		all_door_lists = CreateList()
			all_door_lists.addlast( friendly_door_list )
			all_door_lists.addlast( hostile_door_list )
	End Method
	
	Method clear()
		bg_cache = Null
		fg_cache = Null
		particle_list_background.Clear()
		particle_list_foreground.Clear()
		retained_particle_list.Clear()
		retained_particle_list_count = 0
		environmental_widget_list.Clear()
		projectile_list.Clear()
		friendly_agent_list.Clear()
		hostile_agent_list.Clear()
		pickup_list.Clear()
		control_brain_list.Clear()
		player = Null
	End Method
	
	Method load_level( level_path$ )
		'needs error-checking
		lev = Create_LEVEL_from_json( TJSON.Create( LoadString( level_path )))
		'pathing
		pathing = PATHING_STRUCTURE.Create( lev )
		'images
		bg_cache = generate_sand_image( lev.width, lev.height )
		fg_cache = generate_level_walls_image( lev )
		'doors
		For Local sp:SPAWNER = EachIn lev.spawners
			If sp.class = SPAWNER.class_GATED_FACTORY
				Select sp.alignment
					Case ALIGNMENT_FRIENDLY
						add_door( sp.pos, friendly_door_list )
					Case ALIGNMENT_HOSTILE
						add_door( sp.pos, hostile_door_list )
				End Select
			End If
		Next
		'spawn queues
		spawn_cursor = New CELL[lev.spawners.Length] 'automagically initialized to (0, 0); exactly where it needs to be :)
		spawn_ts = New Int[lev.spawners.Length]
		'flags
		
		level_enemy_count = lev.enemy_count()
		level_enemies_killed = 0
		'..?
	End Method
	
	Method load_next_level()
		load_level( core_get_next_level_id() )
	End Method
	
	Method spawning_system_update()
		'..?
	End Method
	
	Method spawn_player( archetype_index% )
		If player <> Null And player.managed() Then player.unmanage()
		player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], ALIGNMENT_FRIENDLY ))
		player_brain = Create_and_Manage_CONTROL_BRAIN( player, CONTROL_TYPE_HUMAN, player_input_type )
		player_spawn_point = New POINT'friendly_spawn_points[ Rand( 0, friendly_spawn_points.Length - 1 )]
		player.pos_x = player_spawn_point.pos_x - 0.5
		player.pos_y = player_spawn_point.pos_y - 0.5
		player.ang = -90
		player.snap_all_turrets()
		FLAG_player_engine_ignition = False
		FLAG_player_engine_running = False
	End Method
	
	Method spawn_pickup( x%, y% ) 'request; depends on probability
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
	End Method
	
	Method add_door( p:POINT, door_list:TList )
		Local left_door:WIDGET
		Local right_door:WIDGET
		left_door = widget_archetype[WIDGET_INDEX_ARENA_DOOR].clone()
		right_door = widget_archetype[WIDGET_INDEX_ARENA_DOOR].clone()
		left_door.parent = p
		right_door.parent = p
		left_door.attach_at( 25 + 50/3 - widget_archetype[WIDGET_INDEX_ARENA_DOOR].img.height/2 + 1, 0, 90, True )
		right_door.attach_at( 25 + 50/3 - widget_archetype[WIDGET_INDEX_ARENA_DOOR].img.height/2 + 1, 0, -90, True )
		left_door.auto_manage()
		right_door.auto_manage()
		door_list.AddLast( left_door )
		door_list.AddLast( right_door )
	End Method
	
	Method activate_doors( political_alignment% )
		Local political_door_list:TList
		Select political_alignment
			Case ALIGNMENT_FRIENDLY
				political_door_list = friendly_door_list
				friendly_doors_status = Not friendly_doors_status
			Case ALIGNMENT_HOSTILE
				political_door_list = hostile_door_list
				hostile_doors_status = Not hostile_doors_status
		End Select
		For Local door:WIDGET = EachIn political_door_list
			door.queue_transformation( 1 )
		Next
	End Method
	
	Method reset_all_doors()
		For Local door:WIDGET = EachIn friendly_door_list
			door.reset()
		Next
		For Local door:WIDGET = EachIn hostile_door_list
			door.reset()
		Next
		friendly_doors_status = DOOR_STATUS_CLOSED
		hostile_doors_status = DOOR_STATUS_CLOSED
	End Method
	
	Method find_path:TList( start_x#, start_y#, goal_x#, goal_y# )
		Local start_cell:CELL = pathing.containing_cell( start_x, start_y )
		Local goal_cell:CELL = pathing.containing_cell( goal_x, goal_y )
		If pathing.grid( start_cell ) = PATH_BLOCKED Or pathing.grid( goal_cell ) = PATH_BLOCKED
			Return Null
		End If
		
		pathing.reset()
		Local cell_list:TList = pathing.find_CELL_path( start_cell, goal_cell )
	
		Local list:TList = CreateList()
		If cell_list <> Null And Not cell_list.IsEmpty()
			For Local cursor:CELL = EachIn cell_list
				list.AddLast( pathing.lev.get_midpoint( cursor ))
			Next
		End If
		Return list
	End Method

	Method point_inside_arena%( p:POINT )
		
	End Method
	
End Type

'______________________________________________________________________________
'All Spawnpoints
''south
'Global friendly_spawn_points:POINT[] = [ ..
'	Create_POINT( Floor(arena_offset_left + arena_w/2), Floor(arena_offset_top + arena_h + SPAWN_POINT_OFFSET), 270 ) ]
''west, north, east
'Global enemy_spawn_points:POINT[] = [ ..
'	Create_POINT( Floor(arena_offset_left - SPAWN_POINT_OFFSET), Floor(arena_offset_top + arena_h/2), 0 ), ..
'	Create_POINT( Floor(arena_offset_left + arena_w/2), Floor(arena_offset_top - SPAWN_POINT_OFFSET), 90 ), ..
'	Create_POINT( Floor(arena_offset_left + arena_w + SPAWN_POINT_OFFSET), Floor(arena_offset_top + arena_h/2), 180 ) ]
''turret anchor points (12)
'Global enemy_turret_anchors:POINT[] = New POINT[12]
'	enemy_turret_anchors[ 0] = Create_POINT( Floor(arena_offset_left+SPAWN_POINT_OFFSET), Floor(arena_offset_top+SPAWN_POINT_OFFSET), 45 )
'	enemy_turret_anchors[ 1] = Create_POINT( Floor((arena_offset_left+arena_w)-SPAWN_POINT_OFFSET), Floor(arena_offset_top+SPAWN_POINT_OFFSET), 135 )
'	enemy_turret_anchors[ 2] = Create_POINT( Floor(arena_offset_left+SPAWN_POINT_OFFSET), Floor((arena_offset_top+arena_h)-SPAWN_POINT_OFFSET), -45 )
'	enemy_turret_anchors[ 3] = Create_POINT( Floor((arena_offset_left+arena_w)-SPAWN_POINT_OFFSET), Floor((arena_offset_top+arena_h)-SPAWN_POINT_OFFSET), -135 )
'	enemy_turret_anchors[ 4] = enemy_turret_anchors[0].add_pos( SPAWN_POINT_OFFSET, 0 )
'	enemy_turret_anchors[ 5] = enemy_turret_anchors[0].add_pos( 0, SPAWN_POINT_OFFSET )
'	enemy_turret_anchors[ 6] = enemy_turret_anchors[1].add_pos( -SPAWN_POINT_OFFSET, 0 )
'	enemy_turret_anchors[ 7] = enemy_turret_anchors[1].add_pos( 0, SPAWN_POINT_OFFSET )
'	enemy_turret_anchors[ 8] = enemy_turret_anchors[2].add_pos( SPAWN_POINT_OFFSET, 0 )
'	enemy_turret_anchors[ 9] = enemy_turret_anchors[2].add_pos( 0, -SPAWN_POINT_OFFSET )
'	enemy_turret_anchors[10] = enemy_turret_anchors[3].add_pos( -SPAWN_POINT_OFFSET, 0 )
'	enemy_turret_anchors[11] = enemy_turret_anchors[3].add_pos( 0, -SPAWN_POINT_OFFSET )

'Global anchor_deck%[] = New Int[ enemy_turret_anchors.Length ]
'Global anchor_i%
'Function shuffle_anchor_deck()
'	Local i%, j%, swap%
'	For i = 0 To (enemy_turret_anchors.Length - 1)
'		anchor_deck[i] = i
'	Next
'	For i = (enemy_turret_anchors.Length - 1) To 1 Step -1
'		j = Rand( 0, i )
'		swap = anchor_deck[i]
'		anchor_deck[i] = anchor_deck[j]
'		anchor_deck[j] = swap
'	Next
'	anchor_i = 0
'End Function
	
'Serialized Enemy Spawning system, by Squad and Level
'______________________________________________________________________________
'Level Squads
'Function get_level_squads%[][]( i% )
'	If i < level_squads.Length
'		Return level_squads[i]
'	Else
'		Return random_squads()
'	End If
'End Function
'______________________________________________________________________________
'level_squads[level_i][squad_i][enemy_i]
' note: turrets must come first in the level index (for now)
'Global level_squads%[][][] = ..
'	[ ..
'		[ ..
'			[ ENEMY_INDEX_LIGHT_TANK ] ..
'		], ..
'		[	..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ] ..
'		], ..
'		[ ..
'			[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'		], ..
'		[ ..
'			[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'		], ..
'		[ ..
'			[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'		], ..
'		[ ..
'			[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'		], ..
'		[ ..
'			[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT, ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'		], ..
'		[ ..
'			[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT, ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'			[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
'			[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'		] ..
'	]
'
'Function random_squads%[][]()
'	Return ..
'	[	..
'		[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT, ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT, ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT, ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT, ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT ], ..
'		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
'		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
'		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
'		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ] ..
'	]
'End Function

'______________________________________________________________________________
'Level Walls

'Global all_walls:TList = CreateList()

'assumes origin of (arena_offset,arena_offset)
'TList:[ WALL_TYPE%, X%, Y%, W%, H% ]
'Const WALL_ADD% = PATH_BLOCKED
'Const WALL_SUB% = PATH_PASSABLE (no longer used)

'Function wall_mid_x#( wall%[] )
'	Return (2.0*wall[1]+wall[3])/2.0
'End Function
'Function wall_mid_y#( wall%[] )
'	Return (2.0*wall[2]+wall[4])/2.0
'End Function

'[ WALL_TYPE%, X%, Y%, W%, H% ]
'Global common_walls:TList = CreateList()
'common outermost walls: N, E, S, W
'common_walls.AddLast([ WALL_ADD, Int(-(cell_size*2)),Int(-(cell_size*2)),                               Int((arena_offset_left+arena_w+arena_offset_right+(cell_size*4))-1),Int((cell_size*2)-1) ])
'common_walls.AddLast([ WALL_ADD, Int(arena_offset_left+arena_w+arena_offset_right),Int(-(cell_size*2)), Int((cell_size*2)-1),Int((arena_offset_top+arena_h+arena_offset_bottom+(cell_size*4))-1) ])
'common_walls.AddLast([ WALL_ADD, Int(-(cell_size*2)),Int(arena_offset_top+arena_h+arena_offset_bottom), Int((arena_offset_left+arena_w+arena_offset_right+(cell_size*4))-1),Int((cell_size*2)-1) ])
'common_walls.AddLast([ WALL_ADD, Int(-(cell_size*2)),Int(-(cell_size*2)),                               Int((cell_size*2)-1),Int((arena_offset_top+arena_h+arena_offset_bottom+(cell_size*4))-1) ])
'common inner walls: N,N, E,E, S,S, W,W
'common_walls.AddLast([ WALL_ADD, 0,0,                                                            arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
'common_walls.AddLast([ WALL_ADD, arena_offset+(arena_w/2)+(arena_offset/2),0,                    arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
'common_walls.AddLast([ WALL_ADD, arena_offset+arena_w,0,                                         arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])
'common_walls.AddLast([ WALL_ADD, arena_offset+arena_w,arena_offset+(arena_h/2)+(arena_offset/2), arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])
'common_walls.AddLast([ WALL_ADD, 0,arena_offset+arena_h,                                         arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
'common_walls.AddLast([ WALL_ADD, arena_offset+(arena_w/2)+(arena_offset/2),arena_offset+arena_h, arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
'common_walls.AddLast([ WALL_ADD, 0,0,                                                            arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])
'common_walls.AddLast([ WALL_ADD, 0,arena_offset+(arena_h/2)+(arena_offset/2),                    arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])

'Global level_walls:TList[] = New TList[6]
'For Local i% = 0 To level_walls.Length - 1
'	level_walls[i] = CreateList()
'Next
''[ WALL_TYPE%, X%, Y%, W%, H% ]
''level 1
'level_walls[0].AddLast([ WALL_ADD, arena_offset_left+100,arena_offset_top+225, 300-1,50-1 ])
'level_walls[0].AddLast([ WALL_ADD, arena_offset_left+225,arena_offset_top+100, 50-1,300-1 ])
''level 2
'level_walls[1].AddLast([ WALL_ADD, arena_offset_left+100,arena_offset_top+200, 50-1,100-1 ])
'level_walls[1].AddLast([ WALL_ADD, arena_offset_left+350,arena_offset_top+200, 50-1,100-1 ])
'level_walls[1].AddLast([ WALL_ADD, arena_offset_left+200,arena_offset_top+100, 100-1,50-1 ])
'level_walls[1].AddLast([ WALL_ADD, arena_offset_left+200,arena_offset_top+350, 100-1,50-1 ])
''level 3
'level_walls[2].AddLast([ WALL_ADD, arena_offset_left+100,arena_offset_top+225, 300-1,50-1 ])
'level_walls[2].AddLast([ WALL_ADD, arena_offset_left+225,arena_offset_top+100, 50-1,300-1 ])
'level_walls[2].AddLast([ WALL_ADD, arena_offset_left+100,arena_offset_top+200, 50-1,100-1 ])
'level_walls[2].AddLast([ WALL_ADD, arena_offset_left+350,arena_offset_top+200, 50-1,100-1 ])
'level_walls[2].AddLast([ WALL_ADD, arena_offset_left+200,arena_offset_top+100, 100-1,50-1 ])
'level_walls[2].AddLast([ WALL_ADD, arena_offset_left+200,arena_offset_top+350, 100-1,50-1 ])
'
'Function get_level_walls:TList( i% )
'	If i < level_walls.Length
'		Return level_walls[i]
'	Else
'		Return random_level_walls()
'	End If
'End Function
'
'Function random_level_walls:TList()
'	Local walls:TList = CreateList()
'	walls.AddLast([ WALL_ADD, arena_offset+100,arena_offset+225, 300-1,50-1 ])
'	walls.AddLast([ WALL_ADD, arena_offset+225,arena_offset+100, 50-1,300-1 ])
'	walls.AddLast([ WALL_ADD, arena_offset+100,arena_offset+200, 50-1,100-1 ])
'	walls.AddLast([ WALL_ADD, arena_offset+350,arena_offset+200, 50-1,100-1 ])
'	walls.AddLast([ WALL_ADD, arena_offset+200,arena_offset+100, 100-1,50-1 ])
'	walls.AddLast([ WALL_ADD, arena_offset+200,arena_offset+350, 100-1,50-1 ])
'	Return walls
'End Function

'______________________________________________________________________________









