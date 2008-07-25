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
'______________________________________________________________________________
Global ALL_DIRECTIONS%[] = [ DIRECTION_NORTH, DIRECTION_NORTHEAST, DIRECTION_EAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTH, DIRECTION_SOUTHWEST, DIRECTION_WEST, DIRECTION_NORTHWEST ]
Global cell_size# = 10

Const PATH_PASSABLE% = 1 'indicates normal cost grid cell
Const PATH_BLOCKED% = 0 'indicates entirely impassable grid cell
Global pathing_grid_h% 'number of rows in pathing system
Global pathing_grid_w% 'number of columns in pathing system
Global pathing_grid%[,] 'I am: {passable|blocked}
Global pathing_came_from:CELL[,] 'my parent is: [...]
Global pathing_visited%[,] 'I am visited. {true|false}
Global pathing_h#[,] 'heuristic cost to goal from here
Global pathing_g#[,] 'actual cost to get here from beginning
'______________________________________________________________________________
Function in_bounds%( c:CELL )
	If c <> Null And c.row > 0 And c.row < pathing_grid_h And c.col > 0 And c.col < pathing_grid_w ..
	Then Return True Else Return False
End Function
Function distance#( c1:CELL, c2:CELL )
	Return Sqr( Pow( cell_size*(c2.row - c1.row), 2 ) + Pow( cell_size*(c2.col - c1.col), 2 ))
End Function

Function get_pathing_grid%( c:CELL )
	If in_bounds( c ) Then ..
	Return pathing_grid[c.row,c.col] Else Return PATH_BLOCKED
End Function
Function set_pathing_grid( c:CELL, value% )
	If in_bounds( c ) Then ..
	pathing_grid[c.row,c.col] = value
End Function
Function get_pathing_came_from:CELL( c:CELL )
	If in_bounds( c ) Then ..
	Return pathing_came_from[c.row,c.col] Else Return CELL.Create( -1, -1 )
End Function
Function set_pathing_came_from( c:CELL, value:CELL )
	If in_bounds( c ) Then ..
	pathing_came_from[c.row,c.col] = value.clone()
End Function
Function get_pathing_visited%( c:CELL )
	If in_bounds( c ) Then ..
	Return pathing_visited[c.row,c.col] Else Return True
End Function
Function set_pathing_visited( c:CELL, value% )
	If in_bounds( c ) Then ..
	pathing_visited[c.row,c.col] = value
End Function
Function get_pathing_h#( c:CELL )
	If in_bounds( c ) Then ..
	Return pathing_h[c.row,c.col] Else Return -1.0
End Function
Function set_pathing_h( c:CELL, value# )
	If in_bounds( c ) Then ..
	pathing_h[c.row,c.col] = value
End Function
Function get_pathing_g#( c:CELL )
	If in_bounds( c ) Then ..
	Return pathing_g[c.row,c.col] Else Return -1.0
End Function
Function set_pathing_g( c:CELL, value# )
	If in_bounds( c ) Then ..
	pathing_g[c.row,c.col] = value
End Function
Function get_pathing_f#( c:CELL )
	If in_bounds( c )
		Local g# = pathing_g[c.row,c.col]
		Local h# = pathing_h[c.row,c.col]
		If h = -1.0 'h has never been calculated for this cell
			h = distance( c, global_goal )
			set_pathing_h( c, h )
		End If
		Return (g + h)
	Else
		Return -1.0
	End If
End Function
'______________________________________________________________________________
Type PATH_QUEUE
	Field row_count% 'number of rows in the pathing grid
	Field col_count% 'number of columns in the pathing grid
	Field max_size% '(private) row_count * col_count
	Field item_count% 'number of items in this data structure
	Field binary_tree:CELL[] 'min-heap binary tree implemented as an arry
	Field registry%[,] 'a registry to keep items unique; present in queue? {true|false}
	Method New()
	End Method
	
	Function Create:PATH_QUEUE( row_count% = 1, col_count% = 1 )
		Local pq:PATH_QUEUE = New PATH_QUEUE
		pq.row_count = row_count
		pq.col_count = col_count
		pq.max_size = row_count*col_count
		pq.item_count = 0
		pq.binary_tree = New CELL[ row_count*col_count ]
		pq.registry = New Int[ row_count, col_count ]
		Return pq
	End Function
	Method parent_i%( i% )
		Return ( i - 1 ) / 2
	End Method
	Method left_child_i%( i% )
		Return ( 2 * i ) + 1
	End Method
	Method right_child_i%( i% )
		Return ( 2 * i ) + 2
	End Method
	Method smallest_child_i%( i% )
		Local left_c% = left_child_i( i )
		Local right_c% = right_child_i( i )
		If( f_less_than( binary_tree[left_c], binary_tree[right_c] )) Then ..
		Return left_c Else Return right_c
	End Method
	Method swap%( i%, j% )
		If i <> j
			Local swap_cell:CELL = binary_tree[i]
			binary_tree[i] = binary_tree[j]
			binary_tree[j] = swap_cell
			Return True
		Else
			Return False
		End If
	End Method
	Method insert%( i:CELL )
		If item_count < max_size And Not in_queue( i ) 'if not full and item to be inserted is not already present in the queue
			binary_tree[item_count] = i.clone() 'insert a deep-copy of the argument into the next available slot
			If Not is_empty()
				Local item_i% = item_count 'new item's index is equal to the current size of the heap
				Local item_parent_i% = parent_i( item_i ) 'pre-cache parent's index
				While Not f_less_than( binary_tree[item_parent_i], binary_tree[item_i] ) ..
				And Not item_i = 0
					'while the min-heap property is being violated
					swap( item_i, item_parent_i ) 'swap item with its parent
					item_i = item_parent_i 'item's new index is its current parent's index
					item_parent_i = parent_i( item_i ) 'calculate item's new parent's index
				End While
			End If
			register( i ) 'maintain uniqueness registry array
			item_count :+ 1 'maintain size-tracking field
			Return True 'successful insert
		Else
			Return False 'not enough room or item to be inserted is not unique
		End If
	End Method
	Method pop_root:CELL()
		If item_count > 0 'if not empty
			Local root:CELL = binary_tree[0] 'save the current root; it's always at [0]
			If item_count > 1 'if the root is not the only element
				binary_tree[0] = binary_tree[item_count - 1] 'set the root to the last element in the heap
				binary_tree[item_count - 1] = Null 'remove the reference at end of the heap to the new root
				Local item_i% = 0 'index is root index
				Local child_i% = smallest_child_i( item_i ) 'get the smaller of two children
				While Not f_less_than( binary_tree[item_i], binary_tree[child_i] )
				And Not item_i = item_count - 1
					'while the heap property is being violated
					swap( item_i, child_i ) 'swap item with its smallest child
					item_i = child_i 'set item to its current smallest child
					child_i = smallest_child_i( item_i ) 'update item's smallest child
				End While
			Else
				binary_tree[0] = Null
			End If
			unregister( root ) 'maintain uniqueness registry array
			item_count :- 1 'maintain size-tracking field
			Return root 'return the root, secure in the knowledge that this is still a min-heap
		Else
			Return Null 'the min-heap is empty; it doesn't even have a root
		End If
	End Method
	Method is_empty%()
		Return item_count = 0
	End Method
	Method in_queue%( c:CELL )
		Return registry[c.row,c.col]
	End Method
	Method register( c:CELL )
		registry[c.row,c.col] = True
	End Method
	Method unregister( c:CELL )
		registry[c.row,c.col] = False
	End Method
End Type
Function f_less_than%( i:CELL, j:CELL ) 'uses the f() function to determine if {i} < {j}
	Return get_pathing_f( i ) < get_pathing_f( j )
End Function

Global potential_paths:PATH_QUEUE 'prioritized list of cells representing end-points of potential paths to be explored (open-list)
'______________________________________________________________________________
Function get_passable_unvisited_neighbors:TList( c:CELL )
	Local list:TList = CreateList()
	For Local dir% = 0 To ALL_DIRECTIONS.Length - 1
		Local c_dir:CELL = c.move( dir )
		If in_bounds( c_dir ) ..
		And get_pathing_grid( c_dir ) = PATH_PASSABLE ..
		And Not get_pathing_visited( c_dir )
			list.AddLast( c_dir )
		End If
	Next
	Return list
End Function
Function backtrace_path:TList( start:CELL, c:CELL )
	Local list:TList = CreateList()
	list.AddFirst( c.clone() )
	While Not CELL(list.First()).eq( start )
		list.AddFirst( get_pathing_came_from( CELL(list.First()) ))
	End While
	Return list
End Function
'______________________________________________________________________________
Function init_pathing_system()
	pathing_grid_h = arena_h / cell_size
	pathing_grid_w = arena_w / cell_size
	init_pathing_structures()
	'init_pathing_grid_from_obstacles()
End Function
Function init_pathing_structures()
	pathing_grid = New Int[ pathing_grid_h, pathing_grid_w ]
	pathing_came_from = New CELL[ pathing_grid_h, pathing_grid_w ]
	pathing_visited = New Int[ pathing_grid_h, pathing_grid_w ]
	pathing_h = New Float[ pathing_grid_h, pathing_grid_w ]
	pathing_g = New Float[ pathing_grid_h, pathing_grid_w ]
	potential_paths = PATH_QUEUE.Create( pathing_grid_h, pathing_grid_w )
	For Local r% = 0 To pathing_grid_h - 1
		For Local c% = 0 To pathing_grid_w - 1
			pathing_grid[r,c] = PATH_PASSABLE
			pathing_came_from[r,c] = CELL.Create( r, c )
			pathing_visited[r,c] = False
			pathing_h[r,c] = 0
			pathing_g[r,c] = 0
		Next
	Next
End Function
Function init_pathing_grid_from_obstacles( obstacles:TList )
	'for each obstacle
	'  using collide, somehow change correct pathing_grid[,] entries to PATH_BLOCKED
End Function
'______________________________________________________________________________
Function find_path:TList( start_x#, start_y#, goal_x#, goal_y# )
	Local cell_list:TList = find_path_given_cells( ..
		CELL.Create( Floor( start_y/cell_size ), Floor( start_x/cell_size )), ..
		CELL.Create( Floor( goal_y/cell_size ), Floor( goal_x/cell_size )))
	
	Local list:TList = CreateList()
	For Local cursor:CELL = EachIn cell_list
		list.AddLast( cVEC.Create( cursor.col*cell_size + cell_size/2, cursor.row*cell_size + cell_size/2 ))
	Next
	Return list
End Function
'______________________________________________________________________________
Global global_start:CELL, global_goal:CELL
Function find_path_given_cells:TList( start:CELL, goal:CELL )
	global_start = start
	global_goal = goal
																				debug_pathing( "pathing_visited[*,*] = False" )
	For Local r% = 0 To pathing_grid_h - 1
		For Local c% = 0 To pathing_grid_w - 1
			pathing_visited[r,c] = False
		Next
	Next
																				debug_pathing( "set_pathing_g( start, 0 )" )
	set_pathing_g( start, 0 )
																				debug_pathing( "set_pathing_h( start, distance( start, goal ))" )
	set_pathing_h( start, distance( start, goal ))
																				debug_pathing( "potential_paths.insert( start )" )
	potential_paths.insert( start )
																				debug_pathing( "While Not potential_paths.is_empty()" )
	While Not potential_paths.is_empty()
																				debug_pathing( "cursor = potential_paths.pop_root()" )
		Local cursor:CELL = potential_paths.pop_root()
																				debug_pathing( "If cursor.eq( goal )" )
		If cursor.eq( goal )
																				debug_pathing( "Return backtrace_path( start, goal )" )
			Return backtrace_path( start, goal )
		End If
																				debug_pathing( "set_pathing_visited( cursor, True )" )
		set_pathing_visited( cursor, True )
																				debug_pathing( "For neighbor = EachIn get_passable_unvisited_neighbors( cursor )" )
		For Local neighbor:CELL = EachIn get_passable_unvisited_neighbors( cursor )
																				debug_pathing( "neighbor_g = get_pathing_g( neighbor ) + distance( cursor, neighbor )" )
			Local neighbor_g# = get_pathing_g( cursor ) + distance( cursor, neighbor )
																				debug_pathing( "neighbor_g_is_better = False" )
			Local neighbor_g_is_better% = False
																				debug_pathing( "If potential_paths.insert( neighbor )" )
			If potential_paths.insert( neighbor )
																				debug_pathing( "set_pathing_h( neighbor, distance( neighbor, goal ))" )
				set_pathing_h( neighbor, distance( neighbor, goal ))
																				debug_pathing( "neighbor_g_is_better = True" )
				neighbor_g_is_better = True
																				debug_pathing( "Else If neighbor_g < get_pathing_g( neighbor )" )
			Else If neighbor_g < get_pathing_g( neighbor )
																				debug_pathing( "neighbor_g_is_better = True" )
				neighbor_g_is_better = True
			End If
																				debug_pathing( "If neighbor_g_is_better" )
			If neighbor_g_is_better
																				debug_pathing( "set_pathing_came_from( neighbor, cursor )" )
				set_pathing_came_from( neighbor, cursor )
																				debug_pathing( "set_pathing_g( neighbor, neighbor_g )" )
				set_pathing_g( neighbor, neighbor_g )
			End If
		Next
	End While
																				debug_pathing( "FAIL" )
	Return Null
End Function



