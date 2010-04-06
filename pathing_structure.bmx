Rem
	pathing_structure.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "cell.bmx"
'Import "path_queue.bmx"
'Import "level.bmx"

'______________________________________________________________________________
Type PATHING_STRUCTURE
	Field row_count%, col_count% 'dimensions in CELLs
	Field pathing_grid%[,] 'I am: {passable|blocked}
	Field pathing_visited%[,] 'I am visited. {true|false}
	Field pathing_visited_list:TList 'TList<CELL> visited cells
	Field pathing_came_from:CELL[,] 'my parent is: [..]
	Field pathing_g#[,] 'actual cost to get here from start
	Field pathing_h#[,] 'estimated cost to get to goal from here
	Field pathing_f#[,] 'actual cost to get here from start + estimated cost to get to goal from here
	Field potential_paths:PATH_QUEUE 'prioritized list of cells representing end-points of potential paths to be explored (open-list)
	Field lev:LEVEL 'provides information used in movement cost calculation
	
	Function Create:PATHING_STRUCTURE( lev:LEVEL )
		Local ps:PATHING_STRUCTURE = New PATHING_STRUCTURE

		ps.row_count = lev.row_count
		ps.col_count = lev.col_count
		ps.pathing_grid = lev.path_regions 'New Int[ ps.row_count, ps.col_count ]
		ps.pathing_came_from = New CELL[ ps.row_count, ps.col_count ]
		For Local row% = 0 To ps.row_count - 1
			For Local col% = 0 To ps.col_count - 1
				ps.pathing_came_from[ row, col ] = CELL.Create( row, col )
			Next
		Next
		ps.pathing_visited = New Int[ ps.row_count, ps.col_count ]
		ps.pathing_visited_list = CreateList()
		ps.pathing_g = New Float[ ps.row_count, ps.col_count ]
		ps.pathing_h = New Float[ ps.row_count, ps.col_count ]
		ps.pathing_f = New Float[ ps.row_count, ps.col_count ]
		ps.potential_paths = PATH_QUEUE.Create( ps.row_count, ps.col_count, ps.pathing_f )
		ps.lev = lev

		Return ps
	End Function
	
	Method in_bounds%( c:CELL )
		If c <> Null And c.row >= 0 And c.row < row_count And c.col >= 0 And c.col < col_count ..
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
		If Not in_bounds( c ) Then Return CELL.MAXIMUM_COST
		Return pathing_g[c.row,c.col]
	End Method
	Method set_g( c:CELL, value# )
		If Not in_bounds( c ) Then Return
		pathing_g[c.row,c.col] = value
	End Method
	Method h#( c:CELL )
		If Not in_bounds( c ) Then Return CELL.MAXIMUM_COST
		Return pathing_h[c.row,c.col]
	End Method
	Method set_h( c:CELL, value# )
		If Not in_bounds( c ) Then Return
		pathing_h[c.row,c.col] = value
	End Method
	Method f#( c:CELL )
		If Not in_bounds( c ) Then Return CELL.MAXIMUM_COST
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
		For Local i% = 0 Until CELL.ALL_DIRECTIONS.Length
			Local c_dir:CELL = c.move( CELL.ALL_DIRECTIONS[i] )
			If in_bounds( c_dir ) ..
			And grid( c_dir ) = PATH_PASSABLE ..
			And Not visited( c_dir )
				If Not one_of( CELL.ALL_DIRECTIONS[i], CELL.ALL_NON_CARDINAL_DIRECTIONS )
					list.AddLast( c_dir )
				Else 'direction is diagonal
					If grid( CELL.Create( c.row, c_dir.col )) = PATH_PASSABLE ..
					And grid( CELL.Create( c_dir.row, c.col )) = PATH_PASSABLE
						list.AddLast( c_dir )
					End If
				End If
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
		'list.AddFirst( start.clone() ) 'omit starting cell
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
	
	Method containing_cell:CELL( x#, y# )
		Return lev.get_cell( x, y )
	End Method
	
	Method distance#( c1:CELL, c2:CELL )
		Local v1:cVEC = lev.get_midpoint( c1 )
		Local v2:cVEC = lev.get_midpoint( c2 )
		Return Sqr( Pow( v1.x - v2.x, 2 ) + Pow( v1.y - v2.y, 2 ))
	End Method
	
	Method reset()
		For Local c:CELL = EachIn pathing_visited_list
			pathing_visited[c.row,c.col] = False
		Next
		pathing_visited_list = CreateList()
		potential_paths.reset()
	End Method
	
End Type
