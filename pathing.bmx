Rem
	pathing.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const MAXIMUM_COST# = 2147483647

Const DIRECTION_NORTH% = 0
Const DIRECTION_NORTHEAST% = 1
Const DIRECTION_EAST% = 2
Const DIRECTION_SOUTHEAST% = 3
Const DIRECTION_SOUTH% = 4
Const DIRECTION_SOUTHWEST% = 5
Const DIRECTION_WEST% = 6
Const DIRECTION_NORTHWEST% = 7
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
				          col :+ 1
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
'______________________________________________________________________________
Global ALL_DIRECTIONS%[] = [ DIRECTION_NORTH, DIRECTION_NORTHEAST, DIRECTION_EAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTH, DIRECTION_SOUTHWEST, DIRECTION_WEST, DIRECTION_NORTHWEST ]
'Const cell_size# = 6
'Const cell_size# = 8
'Const cell_size# = 10
'Const cell_size# = 20
Const cell_size# = 25
Global pathing_grid_origin:cVEC = Create_Cvec( -40, -40 )

'Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
'Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell
Global pathing_grid_h% 'number of rows in pathing system
Global pathing_grid_w% 'number of columns in pathing system

Function containing_cell:CELL( x#, y# )
	x :- pathing_grid_origin.x
	y :- pathing_grid_origin.y
	If cell_size = 0 Then Return CELL.Create( -1, -1 )
	Return CELL.Create( Floor( y/cell_size ), Floor( x/cell_size ))
End Function
Function distance#( c1:CELL, c2:CELL )
	If cell_size = 0 Then Return -1.0
	Return Sqr( Pow( cell_size*(c2.row - c1.row), 2 ) + Pow( cell_size*(c2.col - c1.col), 2 ))
End Function
'______________________________________________________________________________
Type PATH_QUEUE
	Field row_count%, col_count% 'dimensions
	Field item_count% 'number of items in the queue
	Field registry%[,] 'in queue? {true|false}
	Field open_list:TList 'TList:CELL - list of potential paths
	
	Method New()
		open_list = CreateList()
	End Method
	
	Function Create:PATH_QUEUE( row_count%, col_count% )
		Local pq:PATH_QUEUE = New PATH_QUEUE
		pq.row_count = row_count
		pq.col_count = col_count
		pq.item_count = 0
		pq.registry = New Int[ row_count, col_count ]
		Return pq
	End Function
	
	Method is_empty%()
		Return (item_count = 0)
	End Method
	
	Method in_queue%( inquiry:CELL )
		Return registry[ inquiry.row, inquiry.col ]
	End Method
	
	Method insert( new_potential_path:CELL )
		If Not in_queue( new_potential_path )
			item_count :+ 1
			open_list.AddLast( new_potential_path.clone() )
			register( new_potential_path )
		End If
	End Method
	
	Method pop_root:CELL()
		If Not is_empty()
			item_count :- 1
			Local best_path:CELL, best_path_cost# = MAXIMUM_COST
			For Local c:CELL = EachIn open_list
				If cost( c ) < best_path_cost
					best_path = c
					best_path_cost = cost( c )
				End If
			Next
			open_list.Remove( best_path )
			unregister( best_path )
			Return best_path
		End If
	End Method
	
	Method cost#( inquiry:CELL )
		Return game.pathing_system_f_value( inquiry )
	End Method
	
	Method register( new_item:CELL )
		registry[ new_item.row, new_item.col ] = True 
	End Method
	Method unregister( garbage:CELL )
		registry[ garbage.row, garbage.col ] = False
	End Method
	
	Method reset()
		For Local c:CELL = EachIn open_list
			unregister( c )
		Next
		open_list = CreateList()
	End Method
	
'?Debug
'	Method unit_test( message$ )
'		DebugLog " PATH_QUEUE/unit test "+message
'		DebugLog "   item_count        -> "+item_count
'		DebugLog "   open_list.Count() -> "+open_list.Count()
'		DebugLog "   open_list ..."
'		Local open_list_dump$ = "   "
'		For Local c:CELL = EachIn open_list
'			open_list_dump :+ "("+c.row+","+c.col+"):"+Int(cost( c ))+", "
'		Next
'		DebugLog open_list_dump+"END"
'	End Method
'?
End Type
'______________________________________________________________________________
Type PATHING_STRUCTURE
	Field row_count%, col_count% 'dimensions
	Field pathing_grid%[,] 'I am: {passable|blocked}
	Field pathing_visited%[,] 'I am visited. {true|false}
	Field pathing_visited_list:TList
	Field pathing_came_from:CELL[,] 'my parent is: [...]
	Field pathing_g#[,] 'actual cost to get here from start
	Field pathing_h#[,] 'estimated cost to get to goal from here
	Field pathing_f#[,] 'actual cost to get here from start + estimated cost to get to goal from here
	Field potential_paths:PATH_QUEUE 'prioritized list of cells representing end-points of potential paths to be explored (open-list)
	
	Function Create:PATHING_STRUCTURE( row_count%, col_count% )
		Local ps:PATHING_STRUCTURE = New PATHING_STRUCTURE

		ps.row_count = row_count; ps.col_count = col_count
		ps.pathing_grid = New Int[ row_count, pathing_grid_w ]
		ps.pathing_came_from = New CELL[ row_count, col_count ]
		For Local row% = 0 To row_count - 1
			For Local col% = 0 To col_count - 1
				ps.pathing_came_from[ row, col ] = CELL.Create( row, col )
			Next
		Next
		ps.pathing_visited = New Int[ row_count, col_count ]
		ps.pathing_visited_list = CreateList()
		ps.pathing_g = New Float[ row_count, col_count ]
		ps.pathing_h = New Float[ row_count, col_count ]
		ps.pathing_f = New Float[ row_count, col_count ]
		ps.potential_paths = PATH_QUEUE.Create( row_count, col_count )

		Return ps
	End Function
	
	Method in_bounds%( c:CELL )
		If c <> Null And c.row >= 0 And c.row < pathing_grid_h And c.col >= 0 And c.col < pathing_grid_w ..
		Then Return True Else Return False
	End Method
	
	Method grid%( c:CELL )
		If Not in_bounds( c ) Then Return PATH_BLOCKED
		Return pathing_grid[c.row,c.col]
	End Method
	Method set_grid( c:CELL, value% )
		If Not in_bounds( c ) Then Return
		pathing_grid[c.row,c.col] = value
	End Method
	Method set_area( top_left:CELL, bottom_right:CELL, value% )
		Local cursor:CELL = New CELL
		For cursor.row = top_left.row To bottom_right.row
			For cursor.col = top_left.col To bottom_right.col
				set_grid( cursor, value% )
			Next
		Next
	End Method
		
	Method visited%( c:CELL )
		If Not in_bounds( c ) Then Return True
		Return pathing_visited[c.row,c.col]
	End Method
	Method visit( c:CELL )
		If Not in_bounds( c ) Then Return
		pathing_visited[c.row,c.col] = True
		pathing_visited_list.addlast( c.clone() )
	End Method
	
	Method came_from:CELL( c:CELL )
		If Not in_bounds( c ) Then Return CELL.Create( -1, -1 )
		Return pathing_came_from[c.row,c.col]
	End Method
	Method set_came_from( c:CELL, value:CELL )
		If Not in_bounds( c ) Then Return
		pathing_came_from[c.row,c.col] = value.clone()
	End Method
	
	Method g#( c:CELL )
		If Not in_bounds( c ) Then Return MAXIMUM_COST
		Return pathing_g[c.row,c.col]
	End Method
	Method set_g( c:CELL, value# )
		If Not in_bounds( c ) Then Return
		pathing_g[c.row,c.col] = value
	End Method
	Method h#( c:CELL )
		If Not in_bounds( c ) Then Return MAXIMUM_COST
		Return pathing_h[c.row,c.col]
	End Method
	Method set_h( c:CELL, value# )
		If Not in_bounds( c ) Then Return
		pathing_h[c.row,c.col] = value
	End Method
	Method f#( c:CELL )
		If Not in_bounds( c ) Then Return MAXIMUM_COST
		Return pathing_f[c.row,c.col]
	End Method
	Method set_f( c:CELL, value# )
		If Not in_bounds( c ) Then Return
		pathing_f[c.row,c.col] = value
	End Method
	Method set_f_implicit( c:CELL )
		If Not in_bounds( c ) Then Return
		pathing_f[c.row,c.col] = pathing_g[c.row,c.col] + pathing_h[c.row,c.col]
	End Method
		
	Method get_passable_unvisited_neighbors:TList( c:CELL )
		Local list:TList = CreateList()
		For Local dir% = 0 To ALL_DIRECTIONS.Length - 1
			Local c_dir:CELL = c.move( dir )
			If in_bounds( c_dir ) ..
			And grid( c_dir ) = PATH_PASSABLE ..
			And Not visited( c_dir )
				list.AddLast( c_dir )
			End If
		Next
		Return list
	End Method
	
	Method backtrace_path:TList( c:CELL, start:CELL )
		Local list:TList = CreateList()
		list.AddFirst( c.clone() )
		While Not CELL(list.First()).eq( start )
			list.AddFirst( came_from( CELL(list.First()) ))
		End While
		Return list
	End Method
	
	Method find_CELL_path:TList( start:CELL, goal:CELL )
		set_g( start, 0 )
		set_h( start, distance( start, goal ))
		set_f_implicit( start )
		potential_paths.insert( start )
				
		While Not potential_paths.is_empty()
			Local cursor:CELL = potential_paths.pop_root()
			If cursor.eq( goal )
				Return backtrace_path( goal, start )
			End If
			visit( cursor )
			
			For Local neighbor:CELL = EachIn get_passable_unvisited_neighbors( cursor )
				Local tentative_g# = g( cursor ) + distance( cursor, neighbor )
				Local tentative_g_is_better% = False
				set_g( neighbor, g( cursor ) + distance( cursor, neighbor ))
				set_h( neighbor, distance( neighbor, goal ))
				set_f_implicit( neighbor )
				
				If Not potential_paths.in_queue( neighbor )
					potential_paths.insert( neighbor )
					tentative_g_is_better = True
				Else If tentative_g < g( neighbor )
					tentative_g_is_better = True
				End If
				
				If tentative_g_is_better
					set_came_from( neighbor, cursor )
					set_g( neighbor, tentative_g )
					set_f_implicit( neighbor )
				End If
			Next
			
		End While
		
		Return Null
	End Method
	
	Method reset()
		For Local c:CELL = EachIn pathing_visited_list
			pathing_visited[c.row,c.col] = False
		Next
		pathing_visited_list = CreateList()
		potential_paths.reset()
	End Method
	
End Type


