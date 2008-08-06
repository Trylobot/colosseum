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
common_walls.AddLast([ WALL_ADD, -arena_offset,-arena_offset, arena_offset+arena_w,0 ])
common_walls.AddLast([ WALL_ADD, arena_w,-arena_offset, 0,arena_offset+arena_h ])
common_walls.AddLast([ WALL_ADD, -arena_offset,arena_h, arena_offset+arena_w,0 ])
common_walls.AddLast([ WALL_ADD, -arena_offset,-arena_offset, 0,arena_offset+arena_h ])
'locker rooms: N, E, S, W
common_walls.AddLast([ WALL_SUB, (arena_w/2)-(arena_offset/2),-arena_offset, 0,0 ])
common_walls.AddLast([ WALL_SUB, arena_w,(arena_h/2)-(arena_offset/2)-arena_offset, 0,0 ])
common_walls.AddLast([ WALL_SUB, (arena_w/2)-(arena_offset/2)-arena_offset,arena_h, 0,0 ])
common_walls.AddLast([ WALL_SUB, -arena_offset,(arena_h/2)-(arena_offset/2), 0,0 ])

Global level_walls:TList[] = New TList[3]
For Local i% = 0 To level_walls.Length - 1
	level_walls[i] = CreateList()
Next

level_walls[0].AddLast([ WALL_ADD, 100,200, 300,100 ])

level_walls[1].AddLast([ WALL_ADD, 100,200, 50,100 ])
level_walls[1].AddLast([ WALL_ADD, 350,200, 50,100 ])

