Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'All Spawnpoints
'Locker south (player)
Global player_spawn_point:POINT = ..
	Create_POINT( Floor(arena_offset + arena_w/2), Floor(1.5*arena_offset + arena_h), -90 )
'Lockers west, north, east (hostile)
Global enemy_spawn_points:POINT[] = [ ..
	Create_POINT( Floor(arena_offset/2), Floor(arena_offset + arena_h/2), 0 ), ..
	Create_POINT( Floor(arena_offset + arena_w/2), Floor(arena_offset/2), 90 ), ..
	Create_POINT( Floor(1.5*arena_offset + arena_w), Floor(arena_offset + arena_h/2), 180 ) ]

'Turret anchor points (6x)
Global enemy_turret_anchors:POINT[] = [ ..
	Create_POINT( Floor(arena_offset+arena_offset*1), Floor(arena_offset+arena_offset*1), 45 ), ..
	Create_POINT( Floor(arena_offset+arena_offset*2), Floor(arena_offset+arena_offset*1), 45 ), ..
	Create_POINT( Floor(arena_offset+arena_offset*1), Floor(arena_offset+arena_offset*2), 45 ), ..
	Create_POINT( Floor((arena_offset+arena_w)-arena_offset*1), Floor(arena_offset+arena_offset*1), 135 ), ..
	Create_POINT( Floor((arena_offset+arena_w)-arena_offset*2), Floor(arena_offset+arena_offset*1), 135 ), ..
	Create_POINT( Floor((arena_offset+arena_w)-arena_offset*1), Floor(arena_offset+arena_offset*2), 135 ) ]
Global anchor_deck%[] = New Int[ enemy_turret_anchors.Length ]
Function shuffle_anchor_deck()
	Local i%, j%, swap%
	For i = 0 To (enemy_turret_anchors.Length - 1)
		anchor_deck[i] = i
	Next
	For i = (enemy_turret_anchors.Length - 1) To 1 Step -1
		j = Rand( 0, i )
		swap = anchor_deck[i]
		anchor_deck[i] = anchor_deck[j]
		anchor_deck[j] = swap
	Next
End Function
Global anchor_i%
	
'Serialized Enemy Spawning system, by Squad and Level
Const SPAWN_CLEAR_DIST# = 18.0

Global enemy_spawn_queue:TList = CreateList()
Global cur_squad:TList = Null
Global cur_turret_anchor:POINT
Global cur_spawn_point:POINT
Global last_spawned_enemy:COMPLEX_AGENT
Const squad_spawn_delay% = 3000
Global squad_begin_spawning_ts% = now()

Function queue_squad( archetypes%[] )
	Local squad:TList = CreateList()
	For Local i% = EachIn archetypes
		squad.AddLast( COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[i] )))
	Next
	enemy_spawn_queue.AddLast( squad )
	If cur_squad = Null Then cur_squad = squad
End Function

Function spawn_next_enemy%() 'this function should be treated as a request, and might not do anything if conditions are not met.
	'is there a squad ready
	If cur_squad <> Null And Not cur_squad.IsEmpty()
		'find a turret anchor
		If cur_turret_anchor = Null
			cur_turret_anchor = enemy_turret_anchors[anchor_deck[anchor_i]]
			anchor_i :+ 1
		End If
		'find a spawn point
		If cur_spawn_point = Null
			cur_spawn_point = enemy_spawn_points[ Rand( 0, enemy_spawn_points.Length - 1 )]
		End If
		'if there is no last spawned enemy, or the last spawned enemy is clear of the spawn, or the last spawned enemy has died (yeah it can happen.. CAMPER!)
		If (last_spawned_enemy = Null ..
		Or cur_spawn_point.dist_to( last_spawned_enemy ) >= SPAWN_CLEAR_DIST ..
		Or (last_spawned_enemy <> Null And last_spawned_enemy.dead())) ..
		And (now() - squad_begin_spawning_ts >= squad_spawn_delay)
			last_spawned_enemy = COMPLEX_AGENT( cur_squad.First() )
			cur_squad.RemoveFirst()
			last_spawned_enemy.auto_manage( ALIGNMENT_HOSTILE )
			'is this agent a turret
			If last_spawned_enemy.ai_type = AI_BRAIN_TURRET
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
			Create_and_Manage_CONTROL_BRAIN( last_spawned_enemy, CONTROL_TYPE_AI,, 32, 1000, 1000 )
		'else, last_spawned_enemy <> Null And enemy not clear of spawn
		Else
			'do nothing, have to wait :/
			Return False
		End If
	Else 'cur_squad == Null Or cur_squad.IsEmpty()
		'prepare a squad from the list, if there are any
		If Not enemy_spawn_queue.IsEmpty()
			cur_squad = TList( enemy_spawn_queue.First() )
			enemy_spawn_queue.RemoveFirst()
			cur_spawn_point = enemy_spawn_points[ Rand( 0, enemy_spawn_points.Length - 1 )]
			squad_begin_spawning_ts = now()
			Return False
		Else 'enemy_spawn_queue.IsEmpty()
			cur_squad = Null
			cur_spawn_point = Null
			last_spawned_enemy = Null
			Return False
		End If
	End If
End Function

'______________________________________________________________________________
'Level Squads
Function get_level_squads%[][]( i% )
	If i < level_squads.Length
		Return level_squads[i]
	Else
		Return random_squads()
	End If
End Function
'______________________________________________________________________________
Function enemy_count%( squads%[][] )
	Local count% = 0
	For Local squad%[] = EachIn squads
		count :+ squad.Length
	Next
	Return count
End Function

'level_squads[level_i][squad_i][enemy_i]
' note: turrets must come first in the level index (for now)
Global level_squads%[][][] = ..
[ ..
	[	..
		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ] ..
	], ..
	[ ..
		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ] ..
	] ..
]

Function random_squads%[][]()
	Return ..
	[	..
		[ ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT, ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT ], ..
		[ ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT ], ..
		[ ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT ], ..
		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
		[ ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX, ENEMY_INDEX_MR_THE_BOX ], ..
		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
		[ ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB, ENEMY_INDEX_MOBILE_MINI_BOMB ], ..
		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ], ..
		[ ENEMY_INDEX_LIGHT_QUAD, ENEMY_INDEX_LIGHT_QUAD ] ..
	]
End Function

'______________________________________________________________________________
'Level Walls

Global all_walls:TList = CreateList()

'assumes origin of (arena_offset,arena_offset)
'TList:[ WALL_TYPE%, X%, Y%, W%, H% ]
Const WALL_ADD% = PATH_BLOCKED
'Const WALL_SUB% = PATH_PASSABLE (no longer used)

Global common_walls:TList = CreateList()
'common outermost walls: N, E, S, W
common_walls.AddLast([ WALL_ADD, -50,-50,                    (arena_offset*2+arena_w+100),50 ])
common_walls.AddLast([ WALL_ADD, arena_offset*2+arena_w,-50, 50,(arena_offset*2+arena_h+100) ])
common_walls.AddLast([ WALL_ADD, -50,arena_offset*2+arena_h, (arena_offset*2+arena_w+100),50 ])
common_walls.AddLast([ WALL_ADD, -50,-50,                    50,(arena_offset*2+arena_h+100) ])
'common inner walls: N,N, E,E, S,S, W,W
common_walls.AddLast([ WALL_ADD, 0,0,                                                            arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
common_walls.AddLast([ WALL_ADD, arena_offset+(arena_w/2)+(arena_offset/2),0,                    arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
common_walls.AddLast([ WALL_ADD, arena_offset+arena_w,0,                                         arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])
common_walls.AddLast([ WALL_ADD, arena_offset+arena_w,arena_offset+(arena_h/2)+(arena_offset/2), arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])
common_walls.AddLast([ WALL_ADD, 0,arena_offset+arena_h,                                         arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
common_walls.AddLast([ WALL_ADD, arena_offset+(arena_w/2)+(arena_offset/2),arena_offset+arena_h, arena_offset+(arena_w/2)-(arena_offset/2)-1,arena_offset-1 ])
common_walls.AddLast([ WALL_ADD, 0,0,                                                            arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])
common_walls.AddLast([ WALL_ADD, 0,arena_offset+(arena_h/2)+(arena_offset/2),                    arena_offset-1,arena_offset+(arena_h/2)-(arena_offset/2)-1 ])

Global level_walls:TList[] = New TList[10]
For Local i% = 0 To level_walls.Length - 1
	level_walls[i] = CreateList()
Next

level_walls[0].AddLast([ WALL_ADD, arena_offset+100,arena_offset+225, 300-1,50-1 ])
level_walls[0].AddLast([ WALL_ADD, arena_offset+100,arena_offset+225, 300-1,50-1 ])

level_walls[1].AddLast([ WALL_ADD, arena_offset+100,arena_offset+200, 50-1,100-1 ])
level_walls[1].AddLast([ WALL_ADD, arena_offset+350,arena_offset+200, 50-1,100-1 ])

Function get_level_walls:TList( i% )
	If i < level_walls.Length
		Return level_walls[i]
	Else
		Return CreateList()
	End If
End Function

Function wall_mid_x#( wall%[] )
	Return (2.0*wall[1]+wall[3])/2.0
End Function
Function wall_mid_y#( wall%[] )
	Return (2.0*wall[2]+wall[4])/2.0
End Function
'______________________________________________________________________________
'Doors
Local door:WIDGET
Global friendly_door_list:TList = CreateList() 'TList:WIDGET
	door = widget_archetype[WIDGET_ARENA_DOOR].clone()
		door.parent = player_spawn_point
		door.attach_at( -25, -25, 0 )
		door.auto_manage()
		friendly_door_list.AddLast( door )
	door = widget_archetype[WIDGET_ARENA_DOOR].clone()
		door.parent = player_spawn_point
		door.attach_at( 25, -25, 180 )
		door.auto_manage()
		friendly_door_list.AddLast( door )
Global hostile_door_list:TList = CreateList() 'TList:WIDGET

Function toggle_doors( political_alignment% )
	Local door:WIDGET
	Select political_alignment
		Case ALIGNMENT_FRIENDLY
			For door = EachIn friendly_door_list
				door.begin_transformation( 1 )
			Next
		Case ALIGNMENT_HOSTILE
			For door = EachIn hostile_door_list
				door.begin_transformation( 1 )
			Next
	End Select
End Function

