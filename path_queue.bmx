Rem
	path_queue.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "cell.bmx"

'______________________________________________________________________________
Type PATH_QUEUE
	Field row_count%, col_count% 'dimensions
	Field item_count% 'number of items in the queue
	Field registry%[,] 'in queue? {true|false}
	Field open_list:TList 'TList:CELL - list of potential paths

	'TODO: [Tyler W.R. Cole - August 31, 2009 4:20 PM] This needs to be removed
	Field pathing_f#[,] 'actual cost to get here from start + estimated cost to get to goal from here
	
	Method New()
		open_list = CreateList()
	End Method
	
	Function Create:PATH_QUEUE( row_count%, col_count%, pathing_f#[,] )
		Local pq:PATH_QUEUE = New PATH_QUEUE
		pq.row_count = row_count
		pq.col_count = col_count
		pq.item_count = 0
		pq.registry = New Int[ pq.row_count, pq.col_count ]
		
		'this needs to go away
		pq.pathing_f = pathing_f
		
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
	
	'TODO: [Tyler W.R. Cole - August 31, 2009 4:43 PM]
	'copied from level.bmx
	'needs to go away
	Method in_bounds%( c:CELL )
		Return (c.row >= 0 And c.row < Self.row_count And c.col >= 0 And c.col < Self.col_count)
	End Method
	
	Method cost#( c:CELL )
		If Not in_bounds( c ) Then Return CELL.MAXIMUM_COST
		Return pathing_f[c.row,c.col]
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


