Rem
	pathing.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PATH_QUEUE
	Field row_count%, col_count% 'dimensions
	Field item_count% 'number of items in the queue
	Field registry%[,] 'in queue? {true|false}
	Field open_list:TList 'TList:CELL - list of potential paths
	Field parent:PATHING_STRUCTURE 'reference to owner for purposes of cost calculation
	
	Method New()
		open_list = CreateList()
	End Method
	
	Function Create:PATH_QUEUE( ps:PATHING_STRUCTURE )
		Local pq:PATH_QUEUE = New PATH_QUEUE
		pq.row_count = ps.row_count; pq.col_count = ps.col_count
		pq.item_count = 0
		pq.registry = New Int[ pq.row_count, pq.col_count ]
		pq.parent = ps
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
			Local best_path:CELL, best_path_cost# = CELL.MAXIMUM_COST
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
		Return parent.f( inquiry )
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
	
End Type
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
		ps.potential_paths = PATH_QUEUE.Create( ps )
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
		For Local dir% = 0 To CELL.ALL_DIRECTIONS.Length - 1
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
	
	Method containing_cell:CELL( x#, y# )
		Return lev.get_cell( x, y )
	End Method
	
	Method distance#( c1:CELL, c2:CELL )
		Local v1:cVEC = lev.midpoint( c1 )
		Local v2:cVEC = lev.midpoint( c2 )
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


