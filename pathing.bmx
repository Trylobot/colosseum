Rem
	pathing.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const DIRECTION_NORTH% = 0
Const DIRECTION_NORTHEAST% = 1
Const DIRECTION_EAST% = 2
Const DIRECTION_SOUTHEAST% = 3
Const DIRECTION_SOUTH% = 4
Const DIRECTION_SOUTHWEST% = 5
Const DIRECTION_WEST% = 6
Const DIRECTION_NORTHWEST% = 7
Global DIRECTIONS%[] = [ DIRECTION_NORTH, DIRECTION_NORTHEAST, DIRECTION_EAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTH, DIRECTION_SOUTHWEST, DIRECTION_WEST, DIRECTION_NORTHWEST ]

Const PATH_PASSABLE% = 0
Const PATH_BLOCKED% = 1
Global cell_size# = 15
Global pathing_grid_w%
Global pathing_grid_h%
Global pathing_grid%[][]
Global pathing_cost_estimate#[][]
Global pathing_cost_actual#[][]
Global pathing_grid_parent:CELL[][]

'______________________________________________________________________________
Type CELL
	Field row%
	Field col%
	Method New()
	End Method
	Function Create:CELL( row%, col% )
		Local c:CELL = New CELL
		c.row = row; c.col = col
		Return c
	End Function
	Method copy( other:CELL )
		row = other.row; col = other.col
	End Method
	Method clone:CELL()
		Return CELL.Create( row, col )
	End Method
	Method set( new_row%, new_col% )
		row = new_row; col = new_col
	End Method
	Method add_assign( other:CELL )
		row :+ other.row; col :+ other.col
	End Method
	Method add:CELL( other:CELL )
		Return CELL.Create( row + other.row, col + other.col )
	End Method
	Method move_and_assign( dir% )
		Select dir
			Case DIRECTION_NORTH
				row :- 1
			Case DIRECTION_NORTHEAST
				row :- 1; col :+ 1
			Case DIRECTION_EAST
									col :+ 1
			Case DIRECTION_SOUTHEAST
				row :+ 1; col :+ 1
			Case DIRECTION_SOUTH
				row :+ 1
			Case DIRECTION_SOUTHWEST
				row :+ 1; col :- 1
			Case DIRECTION_WEST
									col :- 1
			Case DIRECTION_NORTHWEST
				row :- 1; col :- 1
		End Select
	End Method
	Method move:CELL( dir% )
		Local c:CELL = clone()
		c.move_and_assign( dir )
		Return c
	End Method
End Type
'______________________________________________________________________________
Function path_get%( c:CELL )
	If c.row < 0 Or c.row >= pathing_grid_height Or c.col < 0 Or c.col >= pathing_grid_width
		Return PATH_BLOCKED
	Else
		Return pathing_grid[c.row][c.col]
	End If
End Function
Function get_passable_neighbors:TList( c:CELL )
	Local list:TList = CreateList()
	For Local dir% = 0 To DIRECTIONS.Length - 1
		Local c_dir:CELL = c.move( dir )
		If path_get( c_dir ) = PATH_PASSABLE
			list.AddLast( c_dir )
		End If
	Next
	Return list
End Function
Function path_cost_estimate#( c1:CELL, c2:CELL )
	Return Sqr( Pow( cell_size*(c2.row - c1.row), 2 ) + Pow( cell_size*(c2.col - c1.col), 2 ))
End Function
Function init_pathing_grid()
	
End Function
'______________________________________________________________________________

