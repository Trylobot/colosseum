Rem
	load_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const LINE_TYPE_HORIZONTAL% = 1
Const LINE_TYPE_VERTICAL% = 2

Type DIVIDER_LINE
	Field line_type% '{HORIZONTAL|VERTICAL}
	Field position%
	Function Create:DIVIDER_LINE( line_type%, position% )
		Local dl:DIVIDER_LINE = New DIVIDER_LINE
		dl.line_type = line_type
		dl.position = position
		Return dl
	End Function
End Type
'______________________________________________________________________________
Const SPAWN_POINT_RANDOM% = -1

Type SQUAD
	Field archetypes%[] 'agents to spawn for this squad
	Field spawn_point% 'can be SPAWN_POINT_RANDOM or a spawn point index
	Field wait_time% 'time delay between spawning the first agent of the previous squad and the first agent of this squad
End Type
'______________________________________________________________________________
Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell

Function Create_LEVEL:LEVEL()
	
End Function

Type LEVEL
	Field width%, height% 'size in pixels
	Field dividers:TList 'TList<DIVIDER_LINE>
	Field row_count%, col_count% 'size in pathing cells
	Field pathing%[,] '{PASSABLE|BLOCKED}[w,h]
	Field spawns:TList 'TList<POINT>
	Field squads:TList 'TList<SQUAD>
	
	Field walls:TList 'TList<BOX> cached after level has been completely initialized
	
	Function New()
		dividers = CreateList()
		spawns = CreateList()
		squads = CreateList()
		walls = CreateList()
	End Function
	
	
End Type

Const gridsnap% = 10
'______________________________________________________________________________
Const EDIT_LEVEL_MODE_NONE% = 0
Const EDIT_LEVEL_MODE_HORIZONTAL_DIVIDER% = 1
Const EDIT_LEVEL_MODE_VERTICAL_DIVIDER% = 2
Const EDIT_LEVEL_MODE_PATHING_PASSABLE% = 3
Const EDIT_LEVEL_MODE_PATHING_BLOCKED% = 4
Const EDIT_LEVEL_MODE_SPAWN_POINT% = 5

Function edit_level( lev:LEVEL )
	Local done% = False
	Local mode% = EDIT_LEVEL_MODE_NONE
	
	While Not done
		Cls
		
		'draw the grid
		
		
		'draw the dividers
		
		
		'draw the pathing grid
		
		
		'draw the spawn points
		
		
		'process input
		If KeyHit( KEY_1 ) 'horizontal divider mode
			mode = EDIT_LEVEL_MODE_HORIZONTAL_DIVIDER
		Else If KeyHit( KEY_2 ) 'vertical divider mode
			mode = EDIT_LEVEL_MODE_VERTICAL_DIVIDER
		Else If KeyHit( KEY_3 ) 'pathing passable mode
			mode = EDIT_LEVEL_MODE_HORIZONTAL_DIVIDER
		Else If KeyHit( KEY_4 ) 'pathing blocked mode
			mode = EDIT_LEVEL_MODE_PATHING_PASSABLE
		Else If KeyHit( KEY_5 ) 'spawn point mode
			mode = EDIT_LEVEL_MODE_PATHING_BLOCKED
		Else If KeyHit( KEY_0 ) 'null mode
			mode = EDIT_LEVEL_MODE_NONE
		End If
		
		Local mouse:cVEC = cVEC.Create( MouseX(),MouseY() )
		

		Flip( 1 )
	End While
End Function


