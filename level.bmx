Rem
	level.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "cell.bmx"
Import "unit_factory_data.bmx"
Import "entity_data.bmx"
Import "box.bmx"
Import "vec.bmx"
Import "json.bmx"

'______________________________________________________________________________
Global level_map:TMap = CreateMap()

Function get_level:LEVEL( key$, copy% = True ) 'returns read-only reference
	Local lev:LEVEL = LEVEL( level_map.ValueForKey( Key.toLower() ))
	'If copy Then Return ...
	Return lev
End Function

Const LINE_TYPE_HORIZONTAL% = 1
Const LINE_TYPE_VERTICAL% = 2

'this needs to move to PATHING_REGIONS future object definition
Const PATH_PASSABLE% = False 'empty cell
Const PATH_BLOCKED% = True 'blocked cell

'this needs to move to CELL
Const COORDINATE_INVALID% = -1

Function Create_LEVEL:LEVEL( width%, height% )
	Local lev:LEVEL = New LEVEL
	lev.name = "new level"
	lev.width = width; lev.height = height
	lev.row_count = 1; lev.col_count = 1
	lev.hue = 0.0; lev.saturation = 0.0; lev.luminosity = 0.3
	lev.horizontal_divs = [ 0, lev.height ]
	lev.vertical_divs = [ 0, lev.width ]
	lev.path_regions = New Int[ lev.row_count, lev.col_count ]
	lev.unit_factories = Null
	lev.immediate_units = Null
	lev.props = Null
	Return lev
End Function

Type LEVEL Extends MANAGED_OBJECT
	Field width%, height% 'dimensions in whole pixels
	Field row_count%, col_count% 'number of cells
	Field hue#, saturation#, luminosity# 'base color for the walls
	Field horizontal_divs%[], vertical_divs%[] 'dividers
	Field path_regions%[,] '{PASSABLE|BLOCKED}[w,h]
	Field unit_factories:UNIT_FACTORY_DATA[] 'gated unit factories
	Field immediate_units:ENTITY_DATA[] 'units to spawn immediately (like turrets & bosses)
	Field props:ENTITY_DATA[] 'props, like wooden crates and stuff
	
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
	
	Method remove_divider( i%, line_type% )
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				If i > 0 And i < horizontal_divs.Length - 1
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
				End If
			
			Case LINE_TYPE_VERTICAL
				If i > 0 And i < vertical_divs.Length - 1
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
				End If
			
		End Select
	End Method
	
	Method set_divider( line_type%, index%, value%, value_is_delta% = False )
		If index = 0 Then Return 'left- and top-most dividers are anchored to zero
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				Local delta% = value
				If Not value_is_delta Then delta :- horizontal_divs[index]
				height :+ delta
				'unit factories
				For Local uf:UNIT_FACTORY_DATA = EachIn unit_factories
					If uf.pos.pos_y >= horizontal_divs[index]
						uf.pos.pos_y :+ delta
					End If
				Next
				'immediate units
				For Local u:ENTITY_DATA = EachIn immediate_units
					If u.pos.pos_y >= horizontal_divs[index]
						u.pos.pos_y :+ delta
					End If
				Next
				'props
				For Local pd:ENTITY_DATA = EachIn props
					If pd.pos.pos_y >= horizontal_divs[index]
						pd.pos.pos_y :+ delta
					End If
				Next
				'divs
				For Local i% = index To horizontal_divs.Length - 1
					horizontal_divs[i] :+ delta
				Next
			
			Case LINE_TYPE_VERTICAL
				Local delta% = value
				If Not value_is_delta Then delta :- vertical_divs[index]
				width :+ delta
				'unit factories
				For Local uf:UNIT_FACTORY_DATA = EachIn unit_factories
					If uf.pos.pos_x >= vertical_divs[index]
						uf.pos.pos_x :+ delta
					End If
				Next
				'immediate units
				For Local u:ENTITY_DATA = EachIn immediate_units
					If u.pos.pos_x >= vertical_divs[index]
						u.pos.pos_x :+ delta
					End If
				Next
				'props
				For Local pd:ENTITY_DATA = EachIn props
					If pd.pos.pos_x >= vertical_divs[index]
						pd.pos.pos_x :+ delta
					End If
				Next
				'divs
				For Local i% = index To vertical_divs.Length - 1
					vertical_divs[i] :+ delta
				Next
				
		End Select
	End Method
	
	Method resize_cell( c:CELL, w%, h% )
		set_divider( LINE_TYPE_VERTICAL, c.col + 1, vertical_divs[c.col] + w, False )
		set_divider( LINE_TYPE_HORIZONTAL, c.row + 1, horizontal_divs[c.row] + h, False )
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
	
	Method add_unit_factory( uf:UNIT_FACTORY_DATA )
		If unit_factories = Null
			unit_factories = New UNIT_FACTORY_DATA[1]
		Else
			unit_factories = unit_factories[..unit_factories.Length+1]
		End If
		unit_factories[unit_factories.Length-1] = uf
	End Method
	
	Method remove_unit_factory( uf:UNIT_FACTORY_DATA )
		For Local index% = 0 To unit_factories.Length
			If unit_factories[index] = uf
				unit_factories[index] = unit_factories[unit_factories.Length-1]
				unit_factories = unit_factories[..unit_factories.Length-1]
				Exit
			End If
		Next
	End Method
	
	Method unit_factories_aligned:UNIT_FACTORY_DATA[]( align% )
		Local uf:UNIT_FACTORY_DATA[]
		For Local i% = 0 Until unit_factories.Length
			If unit_factories[i].alignment = align
				If uf = Null
					uf = [ unit_factories[i] ]
				Else 'uf <> Null
					uf = uf[..(uf.Length+1)]
					uf[uf.Length-1] = unit_factories[i]
				End If
			End If
		Next
		Return uf
	End Method
	
	Method add_immediate_unit( d:ENTITY_DATA )
		If immediate_units = Null
			immediate_units = New ENTITY_DATA[1]
		Else
			immediate_units = immediate_units[..immediate_units.Length+1]
		End If
		d.entity_type = ENTITY_DATA.UNIT
		immediate_units[immediate_units.Length-1] = d
	End Method
	
	Method remove_immediate_unit( d:ENTITY_DATA )
		For Local index% = 0 To immediate_units.Length
			If immediate_units[index] = d
				immediate_units[index] = immediate_units[immediate_units.Length-1]
				immediate_units = immediate_units[..immediate_units.Length-1]
				Exit
			End If
		Next
	End Method
	
	Method immediate_units_aligned:ENTITY_DATA[]( align% )
		Local u:ENTITY_DATA[]
		For Local i% = 0 Until immediate_units.Length
			If immediate_units[i].alignment = align
				If u = Null
					u = [ immediate_units[i] ]
				Else 'u <> Null
					u = u[..(u.Length+1)]
					u[u.Length-1] = immediate_units[i]
				End If
			End If
		Next
		Return u
	End Method
	
	Method add_prop( d:ENTITY_DATA )
		If props = Null
			props = New ENTITY_DATA[1]
		Else
			props = props[..props.Length+1]
		End If
		d.entity_type = ENTITY_DATA.PROP
		props[props.Length-1] = d
	End Method
	
	Method remove_prop( d:ENTITY_DATA )
		For Local index% = 0 To props.Length
			If props[index] = d
				props[index] = props[props.Length-1]
				props = props[..props.Length-1]
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
					Return Create_cVEC( vertical_divs[c.col], horizontal_divs[c.row] )
				Case CELL.CORNER_TOP_RIGHT
					Return Create_cVEC( vertical_divs[c.col+1], horizontal_divs[c.row] )
				Case CELL.CORNER_BOTTOM_RIGHT
					Return Create_cVEC( vertical_divs[c.col+1], horizontal_divs[c.row+1] )
				Case CELL.CORNER_BOTTOM_LEFT
					Return Create_cVEC( vertical_divs[c.col], horizontal_divs[c.row+1] )
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
	
	Method get_random_contained_point:cVEC( c:CELL )
		'If in_bounds( c )
			Local x_min% = vertical_divs[c.col]
			Local x_max% = vertical_divs[c.col+1]
			Local x_diff_qtr% = 0.30 * (x_max - x_min) 'most recent: 0.20, old: 0.40, older: 0.25
			Local y_min% = horizontal_divs[c.row]
			Local y_max% = horizontal_divs[c.row+1]
			Local y_diff_qtr% = 0.30 * (y_max - y_min) 'same as above
			Return Create_cVEC( ..
				Rand( x_min + x_diff_qtr, x_max - x_diff_qtr ), ..
				Rand( y_min + y_diff_qtr, y_max - y_diff_qtr ))
		'Else
		'	Return Null
		'End If
	End Method
	
	Method enemy_count%()
		Local count% = 0
		For Local index% = 0 To unit_factories.Length-1
			count :+ unit_factories[index].count_all_squadmembers()
		Next
		If immediate_units
			count :+ immediate_units.Length
		End If
		Return count
	End Method
	
	Method get_blocking_cells:TList()
		Local list:TList = CreateList()
		For Local r% = 0 To row_count-1
			For Local c% = 0 To col_count-1
				If path_regions[ r, c ] = PATH_BLOCKED
					list.AddLast( CELL.Create( r, c ))
				End If
			Next
		Next
		Return list
	End Method
	
	Method get_walls:TList()
		Local cells:TList = get_blocking_cells()
		Local walls:TList = CreateList()
		For Local c:CELL = EachIn cells
			walls.AddLast( get_wall( c ))
		Next
		Return walls
	End Method
	
	Method path%( c:CELL )
		If in_bounds( c )
			Return path_regions[ c.row, c.col ]
		Else
			Return PATH_BLOCKED
		End If
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "width", TJSONNumber.Create( width ))
		this_json.SetByName( "height", TJSONNumber.Create( height ))
		this_json.SetByName( "row_count", TJSONNumber.Create( row_count ))
		this_json.SetByName( "col_count", TJSONNumber.Create( col_count ))
		this_json.SetByName( "hue", TJSONNumber.Create( hue ))
		this_json.SetByName( "saturation", TJSONNumber.Create( saturation ))
		this_json.SetByName( "luminosity", TJSONNumber.Create( luminosity ))
		this_json.SetByName( "horizontal_divs", Create_TJSONArray_from_Int_array( horizontal_divs ))
		this_json.SetByName( "vertical_divs", Create_TJSONArray_from_Int_array( vertical_divs ))
		this_json.SetByName( "path_regions", Create_TJSONArray_from_2D_Int_array( path_regions, True ))
		If unit_factories <> Null And unit_factories.Length > 0
			Local unit_factories_json:TJSONArray = TJSONArray.Create( unit_factories.Length )
			For Local index% = 0 Until unit_factories.Length
				unit_factories_json.SetByIndex( index, unit_factories[index].to_json() )
			Next
			this_json.SetByName( "unit_factories", unit_factories_json )
		Else
			this_json.SetByName( "unit_factories", TJSON.NIL )
		End If
		If immediate_units <> Null And immediate_units.Length > 0
			Local immediate_units_json:TJSONArray = TJSONArray.Create( immediate_units.Length )
			For Local index% = 0 Until immediate_units.Length
				immediate_units_json.SetByIndex( index, immediate_units[index].to_json() )
			Next
			this_json.SetByName( "immediate_units", immediate_units_json )
		Else
			this_json.SetByName( "immediate_units", TJSON.NIL )
		End If
		If props <> Null And props.Length > 0
			Local props_json:TJSONArray = TJSONArray.Create( props.Length )
			For Local index% = 0 Until props.Length
				props_json.SetByIndex( index, props[index].to_json() )
			Next
			this_json.SetByName( "props", props_json )
		Else
			this_json.SetByName( "props", TJSON.NIL )
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
	lev.hue = json.GetNumber( "hue" )
	lev.saturation = json.GetNumber( "saturation" )
	lev.luminosity = json.GetNumber( "luminosity" )
	lev.horizontal_divs = json.GetArrayInt( "horizontal_divs" )
	lev.vertical_divs = json.GetArrayInt( "vertical_divs" )
	lev.path_regions = Create_2D_Int_array_from_TJSONArray( json.GetArray( "path_regions" ), True )
	Local unit_factories_json:TJSONArray = json.GetArray( "unit_factories" )
	If unit_factories_json <> Null And unit_factories_json.Size() > 0
		lev.unit_factories = New UNIT_FACTORY_DATA[unit_factories_json.Size()]
		For Local index% = 0 Until unit_factories_json.Size()
			lev.unit_factories[index] = Create_UNIT_FACTORY_DATA_from_json( TJSON.Create( unit_factories_json.GetByIndex( index )))
		Next
	End If
	Local immediate_units_json:TJSONArray = json.GetArray( "immediate_units" )
	If immediate_units_json <> Null And immediate_units_json.Size() > 0
		lev.immediate_units = New ENTITY_DATA[immediate_units_json.Size()]
		For Local index% = 0 Until immediate_units_json.Size()
			lev.immediate_units[index] = Create_ENTITY_DATA_from_json( TJSON.Create( immediate_units_json.GetByIndex( index )))
		Next
	End If
	Local props_json:TJSONArray = json.GetArray( "props" )
	If props_json <> Null And props_json.Size() > 0
		lev.props = New ENTITY_DATA[props_json.Size()]
		For Local index% = 0 Until props_json.Size()
			lev.props[index] = Create_ENTITY_DATA_from_json( TJSON.Create( props_json.GetByIndex( index )))
		Next
	End If
	Return lev
End Function

