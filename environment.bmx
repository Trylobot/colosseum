Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'All Spawnpoints
'South
Global player_spawn_point:POINT = ..
	Create_POINT( arena_offset + arena_w/2, 1.5*arena_offset + arena_h, -90 )
'West, North, East
Global enemy_spawn_points:POINT[] = [ ..
	Create_POINT( arena_offset/2, arena_offset + arena_h/2, 0 ), ..
	Create_POINT( arena_offset + arena_w/2, arena_offset/2, 90 ), ..
	Create_POINT( 1.5*arena_offset + arena_w, arena_offset + arena_h/2, 180 ) ]

'Serial Enemy Spawning by Squad
Const SPAWN_CLEAR_DIST# = 25.0

Global enemy_spawn_queue:TList = CreateList()
Global cur_squad:TList = Null
Global cur_spawn_point:POINT
Global last_spawned_enemy:COMPLEX_AGENT

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
		'find a spawn point
		If cur_spawn_point = Null
			cur_spawn_point = enemy_spawn_points[ Rand( 0, enemy_spawn_points.Length - 1 )]
		End If
		'if there is no last spawned enemy or the last spawned enemy is clear of the spawn
		If last_spawned_enemy = Null Or cur_spawn_point.dist_to( last_spawned_enemy ) >= SPAWN_CLEAR_DIST
			last_spawned_enemy = COMPLEX_AGENT( cur_squad.First() )
			cur_squad.RemoveFirst()
			last_spawned_enemy.auto_manage( ALIGNMENT_HOSTILE )
			last_spawned_enemy.pos_x = cur_spawn_point.pos_x
			last_spawned_enemy.pos_y = cur_spawn_point.pos_y
			last_spawned_enemy.ang = cur_spawn_point.ang
			Create_and_Manage_CONTROL_BRAIN( last_spawned_enemy, CONTROL_TYPE_AI, UNSPECIFIED, 32, 1000, 1000 )
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
	If i < level_squads.Length - 1
		Return level_squads[i]
	Else
		Return Null
	End If
End Function

'level_squads[player_level][squad_index][enemy_archetype_index]
Global level_squads%[][][] = ..
[ ..
	[	..
		[ ..
			ENEMY_INDEX_MR_THE_BOX, ..
			ENEMY_INDEX_MR_THE_BOX, ..
			ENEMY_INDEX_MR_THE_BOX, ..
			ENEMY_INDEX_MR_THE_BOX ..
		], ..
		[ ..
			ENEMY_INDEX_MOBILE_MINI_BOMB, ..
			ENEMY_INDEX_MOBILE_MINI_BOMB ..
		], ..
		[ ..
			ENEMY_INDEX_MOBILE_MINI_BOMB, ..
			ENEMY_INDEX_MOBILE_MINI_BOMB ..
		] ..
	] ..
]

'______________________________________________________________________________
'Level Walls
'assumes origin of (arena_offset,arena_offset)
'TList:[ WALL_TYPE%, X%, Y%, W%, H% ]
Const WALL_ADD% = PATH_BLOCKED
Const WALL_SUB% = PATH_PASSABLE

Global common_walls:TList = CreateList()
'outer walls: N, E, S, W
common_walls.AddLast([ WALL_ADD, 0,0, arena_offset+arena_w,arena_offset ])
common_walls.AddLast([ WALL_ADD, arena_offset+arena_w,0, arena_offset,arena_offset+arena_h ])
common_walls.AddLast([ WALL_ADD, arena_offset,arena_offset+arena_h, arena_offset+arena_w,arena_offset ])
common_walls.AddLast([ WALL_ADD, 0,arena_offset, arena_offset,arena_offset+arena_h ])
'locker rooms: N, E, S, W
common_walls.AddLast([ WALL_SUB, arena_offset+(arena_w/2)-(arena_offset/2),0, arena_offset,arena_offset ])
common_walls.AddLast([ WALL_SUB, arena_offset+arena_w,arena_offset+(arena_h/2)-(arena_offset/2), arena_offset,arena_offset ])
common_walls.AddLast([ WALL_SUB, arena_offset+(arena_w/2)-(arena_offset/2),arena_offset+arena_h, arena_offset,arena_offset ])
common_walls.AddLast([ WALL_SUB, 0,arena_offset+(arena_h/2)-(arena_offset/2), arena_offset,arena_offset ])

Global level_walls:TList[] = New TList[2]
For Local i% = 0 To level_walls.Length - 1
	level_walls[i] = CreateList()
Next

level_walls[0].AddLast([ WALL_ADD, arena_offset+100,arena_offset+225, 300,50 ])

level_walls[1].AddLast([ WALL_ADD, arena_offset+100,arena_offset+200, 50,100 ])
level_walls[1].AddLast([ WALL_ADD, arena_offset+350,arena_offset+200, 50,100 ])

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
		door.attach_at( -25, -25, -90 )
		door.auto_manage()
		friendly_door_list.AddLast( door )
	door = widget_archetype[WIDGET_ARENA_DOOR].clone()
		door.parent = player_spawn_point
		door.attach_at( -25, 25, 90 )
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

