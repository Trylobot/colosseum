Rem
	cell.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Type CELL
	Const MAXIMUM_COST% = 2147483647
	Const COORDINATE_INVALID% = -1
	Const DIRECTION_NORTH% = 0
	Const DIRECTION_NORTHEAST% = 1
	Const DIRECTION_EAST% = 2
	Const DIRECTION_SOUTHEAST% = 3
	Const DIRECTION_SOUTH% = 4
	Const DIRECTION_SOUTHWEST% = 5
	Const DIRECTION_WEST% = 6
	Const DIRECTION_NORTHWEST% = 7
	Global ALL_DIRECTIONS%[] = [ DIRECTION_NORTH, DIRECTION_NORTHEAST, DIRECTION_EAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTH, DIRECTION_SOUTHWEST, DIRECTION_WEST, DIRECTION_NORTHWEST ]
	Global ALL_CARDINAL_DIRECTIONS%[] = [ DIRECTION_NORTH, DIRECTION_EAST, DIRECTION_SOUTH, DIRECTION_WEST ]
	Global ALL_NON_CARDINAL_DIRECTIONS%[] = [ DIRECTION_NORTHEAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTHWEST, DIRECTION_NORTHWEST ]
	Const CORNER_TOP_LEFT% = 0
	Const CORNER_TOP_RIGHT% = 1
	Const CORNER_BOTTOM_RIGHT% = 2
	Const CORNER_BOTTOM_LEFT% = 3
	Global ALL_CORNERS%[] = [ CORNER_TOP_LEFT, CORNER_TOP_RIGHT, CORNER_BOTTOM_RIGHT, CORNER_BOTTOM_LEFT ] 
	
	Field row%
	Field col%
	
	Method New()
	End Method
	
	Function Create:CELL( row%, col% )
		Local c:CELL = New CELL
		c.row = row; c.col = col
		Return c
	End Function
	
	Function Create_INVALID:CELL()
		Return Create( COORDINATE_INVALID, COORDINATE_INVALID )
	End Function
	
	Method copy( other:CELL )
		row = other.row; col = other.col
	End Method
	
	Method clone:CELL()
		Return CELL.Create( row, col )
	End Method
	
	Method is_valid%()
		Return (row <> COORDINATE_INVALID And col <> COORDINATE_INVALID)
	End Method
	
	Method set( new_row%, new_col% )
		row = new_row; col = new_col
	End Method
	
	Method eq%( other:CELL )
		If row = other.row And col = other.col ..
		Then Return True Else Return False
	End Method
	
	Method add_assign( other:CELL )
		row :+ other.row; col :+ other.col
	End Method
	
	Method add:CELL( other:CELL )
		Return CELL.Create( row + other.row, col + other.col )
	End Method
	
	Method move_assign( dir% )
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
		c.move_assign( dir )
		Return c
	End Method
	
End Type
