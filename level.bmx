Rem
	level.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type SPAWNER
	Global class_GATED_FACTORY% = 1
	Global class_TURRET_ANCHOR% = 2
	
	Field class% '{gated_factory|turret_anchor}
	Field squads%[][] 'grouped references to COMPLEX_AGENT prototypes; to be "baked" at spawn-time; turret anchors ignore all entries beyond the first.
	Field size% 'cached result of count_all_squadmembers()
	Field pos:POINT 'initial state to be conferred on each spawned agent; velocity and acceleration ignored for turret anchors
	Field delay_time%[] 'time delay between squad queueing; ignored for turret anchors
	Field alignment% '{friendly|hostile}
	
	Method New()
		pos = New POINT
	End Method
	
	Method clone:SPAWNER()
		Local sp:SPAWNER = New SPAWNER
		sp.class = class
		sp.squads = New Int[][squads.Length]
		For Local index% = 0 To squads.Length - 1
			sp.squads[index] = squads[index][..]
		Next
		sp.pos = Copy_POINT( pos )
		sp.delay_time = delay_time[..]
		sp.alignment = alignment
		Return sp
	End Method
	
	Method add_new_squad%()
		squads = squads[..squads.Length+1]
		squads[squads.Length-1] = Null
		delay_time = delay_time[..delay_time.Length+1]
		delay_time[delay_time.Length-1] = 0
	End Method
	
	Method remove_squad( squad%[] )
		For Local index% = 0 To squads.Length-1
			Local sq%[] = squads[index]
			If sq = squad
				squads[index] = squads[squads.Length-1]
				squads = squads[..squads.Length-1]
				delay_time[index] = delay_time[delay_time.Length-1]
				delay_time = delay_time[..delay_time.Length-1]
				Exit
			End If
		Next
	End Method
	
	Method add_new_squadmember( squad_index%, archetype% )
		squads[squad_index] = squads[squad_index][..squads[squad_index].Length+1]
		squads[squad_index][squads[squad_index].Length-1] = archetype
		size = count_all_squadmembers()
	End Method
	
	Method remove_last_squadmember( squad_index% )
		If squad_index >= 0 And squad_index < squads.Length And squads[squad_index].Length > 0
			squads[squad_index] = squads[squad_index][..squads[squad_index].Length-1]
		End If
		If squads[squad_index].Length = 0
			remove_squad( squads[squad_index] )
		End If
	End Method
	
	Method set_delay_time( index%, time% )
		If index >= 0 And index < delay_time.Length
			delay_time[index] = time
		End If
	End Method
	
	Method count_squads%()
		If squads = Null ..
		Then Return 0 ..
		Else Return squads.Length
	End Method
	
	Method count_squadmembers%( squad_index% )
		If (squad_index < 0 Or squad_index >= squads.Length) ..
		Or squads[squad_index] = Null ..
		Then Return 0 ..
		Else Return squads[squad_index].Length
	End Method
	
	Method count_all_squadmembers%()
		Local count% = 0
		For Local index% = 0 To count_squads%()-1
			count :+ count_squadmembers( index )
		Next
		Return count
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "class", TJSONNumber.Create( class ))
		this_json.SetByName( "squads", Create_TJSONArray_from_Int_array_array( squads ))
		this_json.SetByName( "pos", pos.to_json() )
		this_json.SetByName( "delay_time", Create_TJSONArray_from_Int_array( delay_time ))
		this_json.SetByName( "alignment", TJSONNumber.Create( alignment ))
		Return this_json
	End Method
End Type

Function Create_SPAWNER_from_json:SPAWNER( json:TJSON )
	Local sp:SPAWNER = New SPAWNER
	sp.class = json.GetNumber( "class" )
	sp.squads = Create_Int_array_array_from_TJSONArray( json.GetArray( "squads" ))
	sp.size = sp.count_all_squadmembers()
	sp.pos = Create_POINT_from_json( TJSON.Create( json.GetObject( "pos" )))
	sp.delay_time = json.GetArrayInt( "delay_time" )
	sp.alignment = json.GetNumber( "alignment" )
	Return sp
End Function

'______________________________________________________________________________
Const LINE_TYPE_HORIZONTAL% = 1
Const LINE_TYPE_VERTICAL% = 2

'this needs to move to PATHING_REGIONS future object definition
Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell

'this needs to move to CELL
Const COORDINATE_INVALID% = -1

Function Create_LEVEL:LEVEL( width%, height% )
	Local lev:LEVEL = New LEVEL
	lev.name = "new level"
	lev.width = width; lev.height = height
	lev.row_count = 1; lev.col_count = 1
	lev.horizontal_divs = [ 0, lev.height ]
	lev.vertical_divs = [ 0, lev.width ]
	lev.path_regions = New Int[ lev.row_count, lev.col_count ]
	lev.spawners = Null
	Return lev
End Function

Type LEVEL Extends MANAGED_OBJECT
	Field width%, height% 'dimensions in whole pixels
	Field row_count%, col_count% 'number of cells
	Field horizontal_divs%[], vertical_divs%[] 'dividers
	Field path_regions%[,] '{PASSABLE|BLOCKED}[w,h]
	Field spawners:SPAWNER[]
	
	Method resize( new_width%, new_height% )
		width = new_width
		height = new_height
		row_count = 1
		col_count = 1
		horizontal_divs = [ 0, height ]
		vertical_divs = [ 0, width ]
		path_regions = New Int[ row_count, col_count ]
	End Method
	
	Method add_divider( pos%, line_type% )
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				If pos <= 0 Or pos >= height Then Return
				For Local i% = 0 To horizontal_divs.Length - 2
					If pos > horizontal_divs[i] And pos < horizontal_divs[i+1]
						Local old_horizontal_divs%[] = horizontal_divs
						horizontal_divs = New Int[old_horizontal_divs.Length+1]
						'all old divs up to the new one's spot
						For Local j% = 0 To i
							horizontal_divs[j] = old_horizontal_divs[j]
						Next
						'new div
						horizontal_divs[i+1] = pos
						'all old divs after the new one's spot
						For Local j% = i+1 To old_horizontal_divs.Length - 1
							horizontal_divs[j+1] = old_horizontal_divs[j]
						Next
						'row_count :+ 1
						'path_regions = New Int[row_count,col_count]
						path_regions_insert_row( i )
						Return
					End If
				Next
			
			Case LINE_TYPE_VERTICAL
				If pos <= 0 Or pos >= width Then Return
				For Local i% = 0 To vertical_divs.Length - 2
					If pos > vertical_divs[i] And pos < vertical_divs[i+1]
						Local old_vertical_divs%[] = vertical_divs
						vertical_divs = New Int[old_vertical_divs.Length+1]
						'all old divs up to the new one's spot
						For Local j% = 0 To i
							vertical_divs[j] = old_vertical_divs[j]
						Next
						'new div
						vertical_divs[i+1] = pos
						'all old divs after the new one's spot
						For Local j% = i+1 To old_vertical_divs.Length - 1
							vertical_divs[j+1] = old_vertical_divs[j]
						Next
						'col_count :+ 1
						'path_regions = New Int[row_count,col_count]
						path_regions_insert_col( i )
						Return
					End If
				Next
				
		End Select
	End Method
	
	Method remove_divider( pos%, line_type% )
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				If pos <= 0 Or pos >= height Then Return
				For Local i% = 0 To horizontal_divs.Length - 1
					If pos = horizontal_divs[i]
						Local old_horizontal_divs%[] = horizontal_divs
						horizontal_divs = New Int[old_horizontal_divs.Length-1]
						'all old divs up to the removed one's spot
						For Local j% = 0 To i
							horizontal_divs[j] = old_horizontal_divs[j]
						Next
						'all old divs after the removed one's spot
						For Local j% = i+1 To old_horizontal_divs.Length - 1
							horizontal_divs[j-1] = old_horizontal_divs[j]
						Next
						'row_count :- 1
						'path_regions = New Int[row_count,col_count]
						path_regions_remove_row( i )
						Return
					End If
				Next
			
			Case LINE_TYPE_VERTICAL
				If pos <= 0 Or pos >= width Then Return
				For Local i% = 0 To vertical_divs.Length - 1
					If pos = vertical_divs[i]
						Local old_vertical_divs%[] = vertical_divs
						vertical_divs = New Int[old_vertical_divs.Length-1]
						'all old divs up to the removed one's spot
						For Local j% = 0 To i
							vertical_divs[j] = old_vertical_divs[j]
						Next
						'all old divs after the removed one's spot
						For Local j% = i+1 To old_vertical_divs.Length - 1
							vertical_divs[j-1] = old_vertical_divs[j]
						Next
						'col_count :- 1
						'path_regions = New Int[row_count,col_count]
						path_regions_remove_col( i )
						Return
					End If
				Next
			
		End Select
	End Method
	
	Method set_divider( line_type%, index%, value% )
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				Local delta% = value - horizontal_divs[index]
				For local i% = index To horizontal_divs.Length - 1
					horizontal_divs[i] :+ delta
				Next
			
			Case LINE_TYPE_VERTICAL
				Local delta% = value - vertical_divs[index]
				For local i% = index To vertical_divs.Length - 1
					vertical_divs[i] :+ delta
				Next
				
		End Select
	End Method
	
	Method path_regions_insert_row( index% )
		row_count :+ 1
		Local new_path_regions%[,] = New Int[row_count,col_count]
		For Local r% = 0 To row_count - 1
			For Local c% = 0 To col_count - 1
				Local k% = 0
				If r > index Then k = -1
				new_path_regions[r,c] = path_regions[r+k,c]
			Next
		Next
		path_regions = new_path_regions
	End Method
	
	Method path_regions_insert_col( index% )
		col_count :+ 1
		Local new_path_regions%[,] = New Int[row_count,col_count]
		For Local r% = 0 To row_count - 1
			For Local c% = 0 To col_count - 1
				Local k% = 0
				If c > index Then k = -1
				new_path_regions[r,c] = path_regions[r,c+k]
			Next
		Next
		path_regions = new_path_regions
	End Method

	Method path_regions_remove_row( index% )
		row_count :- 1
		Local new_path_regions%[,] = New Int[row_count,col_count]
		For Local r% = 0 To row_count - 1
			For Local c% = 0 To col_count - 1
				Local k% = 0
				If r >= index Then k = 1
				new_path_regions[r,c] = path_regions[r+k,c]
			Next
		Next
		path_regions = new_path_regions
	End Method
	
	Method path_regions_remove_col( index% )
		col_count :- 1
		Local new_path_regions%[,] = New Int[row_count,col_count]
		For Local r% = 0 To row_count - 1
			For Local c% = 0 To col_count - 1
				Local k% = 0
				If c >= index Then k = 1
				new_path_regions[r,c] = path_regions[r,c+k]
			Next
		Next
		path_regions = new_path_regions
	End Method

	Method set_path_region( c:CELL, value% )
		If c.is_valid()
			path_regions[ c.row, c.col ] = value
		End If
	End Method
	
	Method set_path_region_from_xy( x%, y%, value% ) '(x, y) relative to local origin of level. does nothing if not in a valid cell
		set_path_region( get_cell( x, y ), value )
	End Method
	
	Method add_spawner( sp:SPAWNER )
		If spawners = Null
			spawners = New SPAWNER[1]
		Else
			spawners = spawners[..spawners.Length+1]
		End If
		spawners[spawners.Length-1] = sp
	End Method
	
	Method remove_spawner( sp:SPAWNER )
		For Local index% = 0 To spawners.Length
			If spawners[index] = sp
				spawners[index] = spawners[spawners.Length-1]
				spawners = spawners[..spawners.Length-1]
				Exit
			End If
		Next
	End Method
	
	Method get_cell:CELL( x%, y% )
		Local c:CELL = CELL.Create_INVALID()
		For Local i% = 0 To vertical_divs.Length - 2
			If x >= vertical_divs[i] And x <= vertical_divs[i+1]
				c.col = i
				Exit
			End If
		Next
		For Local i% = 0 To horizontal_divs.Length - 2
			If y >= horizontal_divs[i] And y <= horizontal_divs[i+1]
				c.row = i
				Exit
			End If
		Next
		Return c
	End Method
	
	Method in_bounds%( c:CELL )
		Return (c.row >= 0 And c.row < Self.row_count And c.col >= 0 And c.col < Self.col_count)
	End Method
	
	Method get_wall:BOX( c:CELL )
		Local b:BOX = New BOX
		Local tl:cVEC = get_corner( CELL.CORNER_TOP_LEFT, c )
		Local br:cVEC = get_corner( CELL.CORNER_BOTTOM_RIGHT, c )
		b.x = tl.x
		b.y = tl.y
		b.w = br.x - tl.x
		b.h = br.y - tl.y
		Return b
	End Method
	
	Method get_corner:cVEC( corner%, c:CELL )
		If in_bounds( c )
			Select corner
				Case CELL.CORNER_TOP_LEFT
					Return cVEC.Create( vertical_divs[c.col], horizontal_divs[c.row] )
				Case CELL.CORNER_TOP_RIGHT
					Return cVEC.Create( vertical_divs[c.col+1], horizontal_divs[c.row] )
				Case CELL.CORNER_BOTTOM_RIGHT
					Return cVEC.Create( vertical_divs[c.col+1], horizontal_divs[c.row+1] )
				Case CELL.CORNER_BOTTOM_LEFT
					Return cVEC.Create( vertical_divs[c.col], horizontal_divs[c.row+1] )
			End Select
		Else
			Return Null
		End If
	End Method
	
	Method get_midpoint:cVEC( c:CELL )
		If in_bounds( c )
			Local m:cVEC = New cVEC
			m.x = Float(vertical_divs[c.col] + vertical_divs[c.col+1]) / 2.0
			m.y = Float(horizontal_divs[c.row] + horizontal_divs[c.row+1]) / 2.0
			Return m
		Else
			Return Null
		End If
	End Method
	
	Method enemy_count%()
		Local count% = 0
		For Local index% = 0 To spawners.Length-1
			count :+ spawners[index].count_all_squadmembers()
		Next
		Return count
	End Method
	
	Method get_blocking_cells:TList()
		Local list:TList = CreateList()
		For Local r% = 0 To row_count-1
			For Local c% = 0 To col_count-1
				If path_regions[r,c] = PATH_BLOCKED
					list.AddLast( CELL.Create( r, c ))
				End If
			Next
		Next
		Return list
	End Method
	
	Method get_cardinal_blocking_neighbor_info:Int[]( c:CELL )
		If in_bounds( c )
			Local info%[] = New Int[4]
			For Local index% = 0 To CELL.ALL_CARDINAL_DIRECTIONS.Length-1
				Local neighbor:CELL = c.move( CELL.ALL_CARDINAL_DIRECTIONS[index] )
				If (Not in_bounds( neighbor )) Or (path_regions[ neighbor.row, neighbor.col ] = PATH_BLOCKED)
					info[index] = PATH_BLOCKED
				Else
					info[index] = PATH_PASSABLE
				End If
			Next
			Return info
		Else 'Not in_bounds( c )
			Return [ PATH_BLOCKED, PATH_BLOCKED, PATH_BLOCKED, PATH_BLOCKED ]
		End If
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "width", TJSONNumber.Create( width ))
		this_json.SetByName( "height", TJSONNumber.Create( height ))
		this_json.SetByName( "row_count", TJSONNumber.Create( row_count ))
		this_json.SetByName( "col_count", TJSONNumber.Create( col_count ))
		this_json.SetByName( "horizontal_divs", Create_TJSONArray_from_Int_array( horizontal_divs ))
		this_json.SetByName( "vertical_divs", Create_TJSONArray_from_Int_array( vertical_divs ))
		this_json.SetByName( "path_regions", Create_TJSONArray_from_2D_Int_array( path_regions ))
		If spawners <> Null And spawners.Length > 0
			Local spawners_json:TJSONArray = TJSONArray.Create( spawners.Length )
			For Local index% = 0 To spawners.Length - 1
				spawners_json.SetByIndex( index, spawners[index].to_json() )
			Next
			this_json.SetByName( "spawners", spawners_json )
		Else
			this_json.SetByName( "spawners", TJSON.NIL )
		End If
		Return this_json
	End Method
	
End Type

Function Create_LEVEL_from_json:LEVEL( json:TJSON )
	Local lev:LEVEL = New LEVEL
	lev.name = json.GetString( "name" )
	lev.width = json.GetNumber( "width" )
	lev.height = json.GetNumber( "height" )
	lev.row_count = json.GetNumber( "row_count" )
	lev.col_count = json.GetNumber( "col_count" )
	lev.horizontal_divs = json.GetArrayInt( "horizontal_divs" )
	lev.vertical_divs = json.GetArrayInt( "vertical_divs" )
	lev.path_regions = Create_2D_Int_array_from_TJSONArray( json.GetArray( "path_regions" ))
	Local spawners_json:TJSONArray = json.GetArray( "spawners" )
	If spawners_json <> Null And spawners_json.Size() > 0
		lev.spawners = New SPAWNER[spawners_json.Size()]
		For Local index% = 0 To spawners_json.Size() - 1
			lev.spawners[index] = Create_SPAWNER_from_json( TJSON.Create( spawners_json.GetByIndex( index )))
		Next
	End If
	Return lev
End Function



