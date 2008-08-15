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
	Field binary_tree:CELL[] 'min-heap binary tree implemented as an array
	Field cost#[] 'cost values of the items in the binary tree
	Field registry%[,] 'a dual-purpose array; detects whether a given CELL ordered pair is present in the queue, and also determines the index of items in the binary_tree by their location
	
	Method New()
	End Method
	
	Function Create:PATH_QUEUE( row_count% = 1, col_count% = 1 )
		Local pq:PATH_QUEUE = New PATH_QUEUE
		pq.row_count = row_count
		pq.col_count = col_count
		pq.max_size = row_count*col_count
		pq.item_count = 0
		pq.binary_tree = New CELL[ pq.max_size ]
		pq.cost = New Float[ pq.max_size ]
		For Local i% = 0 To pq.max_size - 1
			pq.cost[i] = MAXIMUM_COST
		Next
		pq.registry = New Int[ row_count, col_count ]
		For Local r% = 0 To row_count - 1
			For Local c% = 0 To col_count - 1
				pq.registry[r,c] = REGISTRY_NOT_PRESENT
			Next
		Next
		Return pq
	End Function
	
	Method is_empty%()
		Return item_count = 0
	End Method
	
	Method get_cost#( i% )
		Return cost[i]
	End Method
	Method set_cost( i%, cost_value# )
		cost[i] = cost_value
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

	Method swap%( i%, j% )
		If i <> j
			Local swap_cell:CELL = binary_tree[i]
			binary_tree[i] = binary_tree[j]
			binary_tree[j] = swap_cell
			Local swap_cost# = get_cost( i )
			set_cost( i, get_cost( j ))
			set_cost( j, swap_cost )
			Return True
		Else
			Return False
		End If
	End Method
	
	Method insert%( i:CELL, cost_value# )
		If item_count < max_size And Not in_queue( i ) 'if not full and item to be inserted is not already present in the queue
			item_count :+ 1 'maintain size-tracking field
			Local item_i% = item_count - 1 'new item's index is equal to the current size of the heap
			binary_tree[item_i] = i.clone() 'append the new item to the 
			register( i, item_i ) 'maintain uniqueness registry
?Debug
debug_heap( "insert "+item_i+" "+Int(cost_value) )
?	
			set_cost( item_i, cost_value ) 'update cost
			item_i = sift_up( item_i ) 'maintain heap
?Debug
debug_heap( "insert "+heap_info(item_i)+" COMPLETE" )
?	
			Return True 'successful insert
		Else
			Return False 'not enough room, or item to be inserted is not unique
		End If
	End Method
	
	Method pop_root:CELL()
		If item_count > 0 'if not empty
			item_count :- 1 'maintain size-tracking field
			Local item_i% = 0
			Local root:CELL = binary_tree[item_i].clone() 'save the current root; it's always at [0]
			unregister( root ) 'maintain uniqueness registry array
?Debug
debug_heap( "pop root "+heap_info( 0 ))
?
			If Not is_empty() 'if the root was not the only element
				binary_tree[item_i] = binary_tree[item_count - 1] 'set the root to the last element in the heap
				set_cost( item_i, item_count - 1 )
				binary_tree[item_count - 1] = Null 'remove the reference at end of the heap to the new root
				set_cost( item_count - 1, MAXIMUM_COST )
				item_i = sift_down( item_i )
			Else 'item_count == 1
				binary_tree[item_i] = Null
				set_cost( item_i, MAXIMUM_COST )
			End If
?Debug
debug_heap( "pop root "+heap_info( 0 )+" COMPLETE" )
?
			Return root 'extract the root and return it
		Else
			Return Null 'no root to pop
		End If
	End Method
	
	Method sift_up%( item_i% )
?Debug
debug_heap( "sift up "+heap_info(item_i) )
?		
		Local item_parent_i% = parent_i( item_i )
		'While item_i > 1 And Not f_less_than( binary_tree[item_parent_i], binary_tree[item_i] )
		While item_i > 1 And Not (get_cost(item_parent_i) < get_cost(item_i))
?Debug
debug_heap( "swap( "+heap_info(item_parent_i)+", "+heap_info(item_i)+" )" )
?		
			swap( item_i, item_parent_i ) 'swap item with its parent
?Debug
debug_heap( "swap( "+heap_info(item_parent_i)+", "+heap_info(item_i)+" ) COMPLETE" )
?		
			item_i = item_parent_i 'item's new index is its current parent's index
			item_parent_i = parent_i( item_i ) 'calculate item's new parent's index
		End While
?Debug
debug_heap( "sift up "+heap_info(item_i)+" COMPLETE" )
?		
		Return item_i
	End Method
	
	Method sift_down%( item_i% = 0 )
?Debug
debug_heap( "sift down "+heap_info(item_i) )
?		
		Local item_min_child_i%
		While left_child_i( item_i ) < item_count
			If left_child_i( item_i ) = item_count - 1
				item_min_child_i = left_child_i( item_i )
			Else 'left_child_i( item_i ) <> item_count - 1
				'If f_less_than( binary_tree[left_child_i( item_i )], binary_tree[right_child_i( item_i )] )
				If Not (get_cost( item_i ) < get_cost( left_child_i( item_i )))
					item_min_child_i = left_child_i( item_i )
				Else 'Not f_less_than( binary_tree[left_child_i( item_i )], binary_tree[right_child_i( item_i )] )
					item_min_child_i = right_child_i( item_i )
				End If
			End If
			'If Not f_less_than( binary_tree[item_i], binary_tree[item_min_child_i] )
			If Not (get_cost( item_i ) < get_cost( item_min_child_i ))
?Debug
debug_heap( "swap( "+heap_info(item_i)+", "+heap_info(item_min_child_i)+" )" )
?		
				swap( item_i, item_min_child_i )
?Debug
debug_heap( "swap( "+heap_info(item_i)+", "+heap_info(item_min_child_i)+" ) COMPLETE" )
?		
				item_i = item_min_child_i
			Else 'f_less_than( binary_tree[item_i], binary_tree[item_min_child_i] )
				Exit 'done
			End If
		End While
?Debug
debug_heap( "sift down "+heap_info(item_i)+" COMPLETE" )
?		
		Return item_i
	End Method
	
'	'The following method is in theory functionally equivalent to pop_root(), except that it takes longer to execute (linear time), but is guaranteed to be correct.
'	Method extract_min_SLOWER:CELL()
'		If item_count > 0 'if not empty
'			Local root:CELL
'			If item_count >= 2 'if the root is not the only element
'				Local scan%, min_i% = 0
'				For scan = 1 To item_count
'					If f_less_than( binary_tree[scan], binary_tree[min_i] )
'					'If h_less_than( binary_tree[scan], binary_tree[min_i] )
'						min_i = scan
'					End If
'				Next
'				root = binary_tree[min_i].clone() 'save the current root; it's always at [0]
'				unregister( root ) 'maintain uniqueness registry array
'				swap( min_i, item_count - 1 )
'				binary_tree[item_count - 1] = Null
'			Else
'				root = binary_tree[0].clone()
'				binary_tree[0] = Null
'			End If
'			item_count :- 1
'			Return root
'		Else
'			Return Null 'no root to pop
'		End If
'	End Method
	
'	Method update%( c:CELL )
''		debug_heap( "update ("+c.row+", "+c.col+")" )
'		Local item_i% = index_of( c )
'		If item_i <> REGISTRY_NOT_PRESENT
'			unregister( c )
'			If Not is_root( item_i )
'				'heapsort UP (towards root) if not root
'				Local item_parent_i% = parent_i( item_i ) 'pre-cache parent's index
''				debug_heap( "update: sift-up" )
'				
'				While Not is_root( item_i ) ..
'				And Not f_less_than( binary_tree[item_parent_i], binary_tree[item_i] )
'					'while the min-heap property is being violated
''					debug_heap( "update: swap( i:"+item_i+", parent:"+item_parent_i+" )" )
'					swap( item_i, item_parent_i ) 'swap item with its parent
''					debug_heap( "update: swap( i:"+item_i+", parent:"+item_parent_i+" ) success" )
'					item_i = item_parent_i 'item's new index is its current parent's index
'					item_parent_i = parent_i( item_i ) 'calculate item's new parent's index
'				End While
'				
'			Else If Not is_leaf( item_i )
'				'heapsort DOWN (towards leaves) if not a leaf
'				Local child_i% = smallest_child_i( item_i ) 'get the smaller of two children
''				debug_heap( "update: sift-down" )
'				
'				While Not is_leaf( item_i ) ..
'				And Not f_less_than( binary_tree[item_i], binary_tree[child_i] )
''					debug_heap( "update: swap( i:"+item_i+", child:"+child_i+" )" )
'					swap( item_i, child_i ) 'swap item with its smallest child
''					debug_heap( "update: swap( i:"+item_i+", child:"+child_i+" ) success" )
'					item_i = child_i 'set item to its current smallest child
'					child_i = smallest_child_i( item_i ) 'update item's smallest child
'				End While
'				
'			End If
'			register( c, item_i )
''			debug_heap( "update: success" )
'			Return True
'		Else
''			debug_heap( "update: failure" )
'			Return False
'		End If
'	End Method
	
	Method reset()
		For Local i% = 0 To item_count - 1
			unregister( binary_tree[i] )
			binary_tree[i] = Null
		Next
		item_count = 0
	End Method
	
?Debug
	Method unit_test()
'		For Local i% = 1 To item_count - 1
'			If Not f_less_than( binary_tree[parent_i(i)], binary_tree[i] )
'				Local dump$ = "PATHING core dump: ["
'				For Local i% = 0 To item_count - 1
'					dump :+ Int( pathing.f( binary_tree[i] ))+","
'				Next
'				dump = dump[..dump.Length-2] + "]"
'				DebugLog( dump )
'			End If
'		Next
	End Method
?
	
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
	
	Method find_path_cells:TList( start:CELL, goal:CELL )
?Debug
global_start = start
global_goal = goal
?
		set_g( start, 0 )
		set_h( start, distance( start, goal ))
		set_f_implicit( start )
		potential_paths.insert( start, f( start ))
?Debug
potential_paths.unit_test()
?
		While Not potential_paths.is_empty()
?Debug
debug_pathing( "pop root" )
?
			Local cursor:CELL = potential_paths.pop_root()
?Debug
potential_paths.unit_test()
?
			If cursor.eq( goal )
?Debug
debug_pathing( "success", True)
?
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
					potential_paths.insert( neighbor, f( start ))
?Debug
potential_paths.unit_test()
?
					tentative_g_is_better = True
				Else If tentative_g < g( neighbor )
					tentative_g_is_better = True
				End If
				If tentative_g_is_better
					set_came_from( neighbor, cursor )
					set_g( neighbor, tentative_g )
					set_f_implicit( neighbor )
					'potential_paths.update( neighbor )
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
		
		For Local row% = 0 To row_count - 1
			For Local col% = 0 To col_count - 1
				potential_paths.registry[ row, col ] = REGISTRY_NOT_PRESENT
			Next
		Next
		For Local i% = 0 To potential_paths.item_count - 1
			potential_paths.binary_tree[i] = Null
		Next
		potential_paths.item_count = 0
	End Method
	
End Type
