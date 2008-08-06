Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Environment Initialization

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

'South
Global player_spawn_point:cVEC = ..
	cVEC( cVEC.Create( arena_offset + arena_w/2, 1.5*arena_offset + arena_h ))
'West, North, East
Global enemy_spawn_points:cVEC[] = [ ..
	cVEC( cVEC.Create( arena_offset/2, 1.5*arena_offset + arena_h/2 )), ..
	cVEC( cVEC.Create( arena_offset + arena_w/2, arena_offset/2 )), ..
	cVEC( cVEC.Create( 1.5*arena_offset + arena_w, 1.5*arena_offset + arena_h/2 )) ]


Global level_walls:TList[] = New TList[3]
For Local i% = 0 To level_walls.Length - 1
	level_walls[i] = CreateList()
Next

level_walls[0].AddLast([ WALL_ADD, arena_offset+100,arena_offset+225, 300,50 ])

level_walls[1].AddLast([ WALL_ADD, arena_offset+100,arena_offset+200, 50,100 ])
level_walls[1].AddLast([ WALL_ADD, arena_offset+350,arena_offset+200, 50,100 ])

