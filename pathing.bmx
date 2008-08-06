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

Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell
Global pathing_grid_h% 'number of rows in pathing system
Global pathing_grid_w% 'number of columns in pathing system

Function containing_cell:CELL( x#, y# )
	If cell_size = 0 Then Return CELL.Create( -1, -1 )
	Return CELL.Create( Floor( y/cell_size ), Floor( x/cell_size ))
End Function
Function distance#( c1:CELL, c2:CELL )
	If cell_size = 0 Then Return -1.0
	Return Sqr( Pow( cell_size*(c2.row - c1.row), 2 ) + Pow( cell_size*(c2.col - c1.col), 2 ))
End Function
'______________________________________________________________________________
Const REGISTRY_NOT_PRESENT% = -1

Type PATH_QUEUE
	Field row_count%, col_count% 'dimensions
	Field max_size% '(private) row_count*col_count
	Field item_count% 'number of items in this data structure
	Field binary_tree:CELL[] 'min-heap binary tree implemented as an arry
	Field registry%[,] 'a dual-purpose array; detects whether a given CELL ordered pair is present in the queue, and also determines the index of items the binary_tree by their location
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
		For Local r% = 0 To row_count - 1
			For Local c% = 0 To col_count - 1
				pq.registry[r,c] = REGISTRY_NOT_PRESENT
			Next
		Next
		Return pq
	End Function
	Method is_root%( i% )
		Return ( i = 0 )
	End Method
	Method is_leaf%( i% )
		Return ( left_child_i( i ) >= item_count )
	End Method
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
	
	Method is_empty%()
		Return item_count = 0
	End Method
	Method in_queue%( c:CELL )
		Return (registry[c.row,c.col] <> REGISTRY_NOT_PRESENT)
	End Method
	Method index_of%( c:CELL )
		If Not in_queue( c ) Then Return REGISTRY_NOT_PRESENT Else ..
		Return registry[c.row,c.col]
	End Method
	Method register( c:CELL, index% )
		registry[c.row,c.col] = index
	End Method
	Method unregister( c:CELL )
		registry[c.row,c.col] = REGISTRY_NOT_PRESENT
	End Method
	Method reset()
		For Local i% = 0 To item_count - 1
			unregister( binary_tree[i] )
			binary_tree[i] = Null
		Next
		item_count = 0
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
'		debug_heap( "insert: (" + i.row + "," + i.col + ")" + " f:" + Int( pathing.f( i )) )  
		If item_count < max_size And Not in_queue( i ) 'if not full and item to be inserted is not already present in the queue
			Local item_i% = item_count 'new item's index is equal to the current size of the heap
			binary_tree[item_count] = i.clone() 'insert a deep-copy of the argument into the next available slot
			If Not is_empty()
				Local item_parent_i% = parent_i( item_i ) 'pre-cache parent's index
'				debug_heap( "insert: up-sift" )  
				
				While Not is_root( item_i ) ..
				And Not f_less_than( binary_tree[item_parent_i], binary_tree[item_i] )
					'while the min-heap property is being violated
'					debug_heap( "insert: swap( i:"+item_i+", parent:"+item_parent_i+" )" ) 
					swap( item_i, item_parent_i ) 'swap item with its parent
'					debug_heap( "insert: swap( i:"+item_i+", parent:"+item_parent_i+" ) success" ) 
					item_i = item_parent_i 'item's new index is its current parent's index
					item_parent_i = parent_i( item_i ) 'calculate item's new parent's index
				End While
				
			End If
			register( i, item_i ) 'maintain uniqueness registry array
			item_count :+ 1 'maintain size-tracking field
'			debug_heap( "insert: success" )  
			Return True 'successful insert
		Else
'			debug_heap( "insert: failure" )  
			Return False 'not enough room, or item to be inserted is not unique
		End If
	End Method
	
	Method pop_root:CELL()
'		debug_heap( "pop_root" )
		If item_count > 0 'if not empty
			Local root:CELL = binary_tree[0].clone() 'save the current root; it's always at [0]
			unregister( root ) 'maintain uniqueness registry array
			If item_count >= 2 'if the root is not the only element
'				debug_heap( "pop_root: down-sift" )  
				binary_tree[0] = binary_tree[item_count - 1] 'set the root to the last element in the heap
				binary_tree[item_count - 1] = Null 'remove the reference at end of the heap to the new root
				Local item_i% = 0 'index is root index
				Local child_i% = smallest_child_i( item_i ) 'get the smaller of two children
				
				While Not is_leaf( item_i ) ..
				And Not f_less_than( binary_tree[item_i], binary_tree[child_i] )
					'while the heap property is being violated
'					debug_heap( "pop_root: swap( i:"+item_i+", child:"+child_i+" )" )  
					swap( item_i, child_i ) 'swap item with its smallest child
'					debug_heap( "pop_root: swap( i:"+item_i+", child:"+child_i+" ) success" )  
					item_i = child_i 'set item to its current smallest child
					child_i = smallest_child_i( item_i ) 'update item's smallest child
				End While
				
			Else 'item_count == 1
				binary_tree[0] = Null
			End If
			item_count :- 1 'maintain size-tracking field
'			debug_heap( "pop_root: success" )  
			Return root 'extract the root and return it
		Else
'			debug_heap( "pop_root: failure" )  
			Return Null 'no root to pop
		End If
	End Method
	
	'The following method is in theory functionally equivalent to pop_root(), except that it takes longer to execute (linear time), but is guaranteed to be correct.
	Method extract_min_SLOWER:CELL()
		If item_count > 0 'if not empty
			Local root:CELL
			If item_count >= 2 'if the root is not the only element
				Local scan%, min_i% = 0
				For scan = 1 To item_count
					If f_less_than( binary_tree[scan], binary_tree[min_i] )
					'If h_less_than( binary_tree[scan], binary_tree[min_i] )
						min_i = scan
					End If
				Next
				root = binary_tree[min_i].clone() 'save the current root; it's always at [0]
				unregister( root ) 'maintain uniqueness registry array
				swap( min_i, item_count - 1 )
				binary_tree[item_count - 1] = Null
			Else
				root = binary_tree[0].clone()
				binary_tree[0] = Null
			End If
			item_count :- 1
			Return root
		Else
			Return Null 'no root to pop
		End If
	End Method
	
	Method update%( c:CELL )
'		debug_heap( "update ("+c.row+", "+c.col+")" )
		Local item_i% = index_of( c )
		If item_i <> REGISTRY_NOT_PRESENT
			unregister( c )
			If Not is_root( item_i )
				'heapsort UP (towards root) if not root
				Local item_parent_i% = parent_i( item_i ) 'pre-cache parent's index
'				debug_heap( "update: sift-up" )
				
				While Not is_root( item_i ) ..
				And Not f_less_than( binary_tree[item_parent_i], binary_tree[item_i] )
					'while the min-heap property is being violated
'					debug_heap( "update: swap( i:"+item_i+", parent:"+item_parent_i+" )" )
					swap( item_i, item_parent_i ) 'swap item with its parent
'					debug_heap( "update: swap( i:"+item_i+", parent:"+item_parent_i+" ) success" )
					item_i = item_parent_i 'item's new index is its current parent's index
					item_parent_i = parent_i( item_i ) 'calculate item's new parent's index
				End While
				
			Else If Not is_leaf( item_i )
				'heapsort DOWN (towards leaves) if not a leaf
				Local child_i% = smallest_child_i( item_i ) 'get the smaller of two children
'				debug_heap( "update: sift-down" )
				
				While Not is_leaf( item_i ) ..
				And Not f_less_than( binary_tree[item_i], binary_tree[child_i] )
'					debug_heap( "update: swap( i:"+item_i+", child:"+child_i+" )" )
					swap( item_i, child_i ) 'swap item with its smallest child
'					debug_heap( "update: swap( i:"+item_i+", child:"+child_i+" ) success" )
					item_i = child_i 'set item to its current smallest child
					child_i = smallest_child_i( item_i ) 'update item's smallest child
				End While
				
			End If
			register( c, item_i )
'			debug_heap( "update: success" )
			Return True
		Else
'			debug_heap( "update: failure" )
			Return False
		End If
	End Method
	
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
	Method New()
	End Method
	
	Function Create:PATHING_STRUCTURE( row_count% = 1, col_count% = 1 )
		Local ps:PATHING_STRUCTURE = New PATHING_STRUCTURE
		ps.row_count = row_count; ps.col_count = col_count
		ps.pathing_grid = New Int[ row_count, pathing_grid_w ]
		ps.pathing_came_from = New CELL[ row_count, col_count ]
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
	
	Method find_path_cells:TList( start:CELL, goal:CELL )
		global_start = start
		global_goal = goal
		set_g( start, 0 )
		set_h( start, distance( start, goal ))
		set_f_implicit( start )
		potential_paths.insert( start )
		While Not potential_paths.is_empty()
'			debug_pathing( "cursor = potential_paths.pop_root()" )
			'Local cursor:CELL = potential_paths.pop_root()
			Local cursor:CELL = potential_paths.extract_min_SLOWER()
			If cursor.eq( goal )
'				debug_pathing( "path found; F2 to continue", True )
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
					potential_paths.update( neighbor )
				End If
			Next
		End While
		Return Null
	End Method
	
	Method set_area( top_left:CELL, bottom_right:CELL, value% )
		Local cursor:CELL = New CELL
		For cursor.row = top_left.row To bottom_right.row
			For cursor.col = top_left.col To bottom_right.col
				set_grid( cursor, value% )
			Next
		Next
	End Method
	
	Method reset()
		For Local c:CELL = EachIn pathing_visited_list
			pathing_visited[c.row,c.col] = False
		Next
		pathing_visited_list = CreateList()
		potential_paths.reset()
	End Method
	
End Type
'______________________________________________________________________________
Global pathing:PATHING_STRUCTURE
Global global_start:CELL, global_goal:CELL

Function g_less_than%( i:CELL, j:CELL ) 'g(i) < g(j)
	Return pathing.g( i ) <= pathing.g( j )
End Function
Function h_less_than%( i:CELL, j:CELL ) 'h(i) < h(j)
	Return pathing.h( i ) <= pathing.h( j )
End Function
Function f_less_than%( i:CELL, j:CELL ) 'f(i) < f(j)
	Return pathing.f( i ) <= pathing.f( j )
End Function
'______________________________________________________________________________
Function init_pathing_system()
	pathing_grid_h = arena_h / cell_size
	pathing_grid_w = arena_w / cell_size
	pathing = PATHING_STRUCTURE.Create( pathing_grid_h, pathing_grid_w )
End Function
'______________________________________________________________________________
Function init_pathing_grid_from_walls( level_walls:TList )
	For Local wall%[] = EachIn level_walls
		pathing.set_area( containing_cell( wall[1], wall[2] ), containing_cell( wall[1]+wall[3], wall[2]+wall[4] ), wall[0] )
	Next
End Function
'______________________________________________________________________________
Function find_path:TList( start_x#, start_y#, goal_x#, goal_y# )
	If      start_x < 0        Then start_x = 0 ..
	Else If start_x >= arena_w Then start_x = arena_w - 1
	If      start_y < 0        Then start_y = 0 ..
	Else If start_y >= arena_h Then start_y = arena_h - 1
	If      goal_x < 0         Then goal_x = 0 ..
	Else If goal_x >= arena_w  Then goal_x = arena_w - 1
	If      goal_y < 0         Then goal_y = 0 ..
	Else If goal_y >= arena_h  Then goal_y = arena_h - 1

	pathing.reset()
	Local cell_list:TList = pathing.find_path_cells( containing_cell( start_x, start_y ), containing_cell( goal_x, goal_y ))

	Local list:TList = CreateList()
	If cell_list <> Null And Not cell_list.IsEmpty()
		For Local cursor:CELL = EachIn cell_list
			list.AddLast( cVEC.Create( cursor.col*cell_size + cell_size/2, cursor.row*cell_size + cell_size/2 ))
		Next
	End If
	Return list
End Function
'______________________________________________________________________________




