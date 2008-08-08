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
Global player_spawn_point:POINT = ..
	Create_POINT( arena_offset + arena_w/2, 1.5*arena_offset + arena_h, -90 )
'West, North, East
Global enemy_spawn_points:POINT[] = [ ..
	Create_POINT( arena_offset/2, arena_offset + arena_h/2, 0 ), ..
	Create_POINT( arena_offset + arena_w/2, arena_offset/2, 90 ), ..
	Create_POINT( 1.5*arena_offset + arena_w, arena_offset + arena_h/2, 180 ) ]

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

'______________________________________________________________________________
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

'______________________________________________________________________________
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

