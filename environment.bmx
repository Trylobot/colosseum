Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const DOOR_STATUS_OPEN% = 0
Const DOOR_STATUS_CLOSED% = 1

Const SPAWN_POINT_OFFSET% = 43

Function Create_ENVIRONMENT:ENVIRONMENT()
	Local e:ENVIRONMENT = New ENVIRONMENT
	
	Return e
End Function

Type ENVIRONMENT
	Field origin:cVEC '(x, y) of the origin of this level
	Field zoom# 'zoom level
	Field bg_cache:TImage 'background image
	Field fg_cache:TImage 'foreground image

	Field lev:LEVEL 'level object from which to build the environment, read-only
	Field walls:TList 'TList<BOX> contains all of the wall rectangles of the level
	Field pathing:PATHING_STRUCTURE 'pathfinding object for this level
	Field spawn_cursor:CELL[] 'for each spawner, a (row,col) pointer indicating the current agent to be spawned
	
	Field enemy_spawn_queue:TList 'TList<COMPLEX_AGENT>
	Field cur_squad:TList 'TList<COMPLEX_AGENT>
	Field cur_turret_anchor:POINT 'turret spawn point (anchor)
	Field cur_spawn_point:POINT 'normal spawn point
	Field last_spawned_enemy:COMPLEX_AGENT 'pointer to last spawned enemy
	Field squad_begin_spawning_ts% 'timestamp of the first enemy spawned from the most recent squad, for timing purposes
	
	Field friendly_door_list:TList 'TList<WIDGET>
	Field friendly_doors_status%
	Field hostile_door_list:TList'TList<WIDGET>
	Field hostile_doors_status%
	Field all_door_lists:TList
	
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
	
	Field player:COMPLEX_AGENT
	Field player_brain:CONTROL_BRAIN
	Field player_spawn_point:POINT
	
	Field game_in_progress%
	Field game_over%
	
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
		enemy_spawn_queue = CreateList()
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
	
	Method load_level( new_lev:LEVEL )
		lev = new_lev
		'pathing
		pathing = PATHING_STRUCTURE.Create( lev )
		'walls - create polygons from the blocked out regions of the pathing
		'..?
	End Method
	
'	Method queue_squad( this_squad:SQUAD )
'		Local this_squad_baked:TList = CreateList()
'		For Local archetype_index% = EachIn this_squad.archetypes
'			this_squad_baked.AddLast( COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index] )))
'		Next
'		enemy_spawn_queue.AddLast( this_squad_baked )
'		If cur_squad = Null Then cur_squad = this_squad_baked
'	End Method
	
	Method spawning_system_update()
'		'is there a squad ready
'		If cur_squad <> Null And Not cur_squad.IsEmpty()
'			'find a turret anchor
'			If cur_turret_anchor = Null And anchor_i < anchor_deck.Length
'				cur_turret_anchor = enemy_turret_anchors[anchor_deck[anchor_i]]
'				anchor_i :+ 1
'			End If
'			'find a spawn point
'			If cur_spawn_point = Null
'				cur_spawn_point = enemy_spawn_points[ Rand( 0, enemy_spawn_points.Length - 1 )]
'			End If
'			'if there is no last spawned enemy, or the last spawned enemy is clear of the spawn, or the last spawned enemy has died (yeah it can happen.. CAMPER!)
'			If (last_spawned_enemy = Null ..
'			Or point_inside_arena( last_spawned_enemy ) ..
'			Or (last_spawned_enemy <> Null And last_spawned_enemy.dead())) ..
'			And (now() - squad_begin_spawning_ts >= squad_spawn_delay)
'				spawn_from_squad( cur_squad )
'			'else, last_spawned_enemy <> Null And enemy not clear of spawn
'			End If
'		Else 'cur_squad == Null Or cur_squad.IsEmpty()
'			'prepare a squad from the list, if there are any
'			If Not enemy_spawn_queue.IsEmpty()
'				cur_squad = TList( enemy_spawn_queue.First() )
'				enemy_spawn_queue.RemoveFirst()
'				cur_spawn_point = enemy_spawn_points[ Rand( 0, enemy_spawn_points.Length - 1 )]
'				squad_begin_spawning_ts = now()
'			Else 'enemy_spawn_queue.IsEmpty()
'				cur_squad = Null
'				cur_spawn_point = Null
'				last_spawned_enemy = Null
'			End If
'		End If
	End Method
	
	Method spawn_from_squad( this_squad:TList ) 'this function should be treated as a request, and might not do anything if conditions are not met.
		last_spawned_enemy = COMPLEX_AGENT( this_squad.First() )
		this_squad.RemoveFirst()
		last_spawned_enemy.auto_manage( ALIGNMENT_HOSTILE )
		'is this agent a turret
		If last_spawned_enemy.ai_type = AI_BRAIN_TURRET And cur_turret_anchor <> Null
			last_spawned_enemy.pos_x = cur_turret_anchor.pos_x
			last_spawned_enemy.pos_y = cur_turret_anchor.pos_y
			last_spawned_enemy.ang = cur_turret_anchor.ang
			cur_turret_anchor = Null
		'not a turret
		Else 'last_spawned_enemy.ai_type <> AI_BRAIN_TURRET
			last_spawned_enemy.pos_x = cur_spawn_point.pos_x
			last_spawned_enemy.pos_y = cur_spawn_point.pos_y
			last_spawned_enemy.ang = cur_spawn_point.ang
		End If
		last_spawned_enemy.snap_all_turrets()
		Create_and_Manage_CONTROL_BRAIN( last_spawned_enemy, CONTROL_TYPE_AI,, 10, 1000, 1000 )
	End Method
		
	Method attach_door( p:POINT, political_door_list:TList )
		Local door:WIDGET
		'left side
		door = widget_archetype[WIDGET_INDEX_ARENA_DOOR].clone()
		door.parent = p
		door.attach_at( 25 + 50/3 - door.img.height/2 + 1, 0, 90, True )
		door.auto_manage()
		political_door_list.AddLast( door )
		'right side
		door = widget_archetype[WIDGET_INDEX_ARENA_DOOR].clone()
		door.parent = p
		door.attach_at( 25 + 50/3 - door.img.height/2 + 1, 0, -90, True )
		door.auto_manage()
		political_door_list.AddLast( door )
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
		Local start_cell:CELL = containing_cell( start_x, start_y )
		Local goal_cell:CELL = containing_cell( goal_x, goal_y )
		If pathing.grid( start_cell ) = PATH_BLOCKED Or pathing.grid( goal_cell ) = PATH_BLOCKED
			Return Null
		End If
		
		pathing.reset()
		Local cell_list:TList = pathing.find_CELL_path( start_cell, goal_cell )
	
		Local list:TList = CreateList()
		If cell_list <> Null And Not cell_list.IsEmpty()
			For Local cursor:CELL = EachIn cell_list
				list.AddLast( cVEC.Create( cursor.col*cell_size + cell_size/2 + pathing_grid_origin.x, cursor.row*cell_size + cell_size/2 + pathing_grid_origin.y ))
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









