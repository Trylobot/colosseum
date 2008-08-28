Rem
	load_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type SPAWNER
	Field squads%[][] 'grouped references to COMPLEX_AGENT prototypes; to be "baked" at spawn-time
	Field spawn_point:POINT 'initial state to be conferred on each spawned agent
	Field spawn_delay%[] 'time delay for each squad
	Field political_alignment% '{friendly|hostile}
	
	Method New()
		spawn_point = New POINT
	End Method
	
	Method clone:SPAWNER()
		Local sp:SPAWNER = New SPAWNER
		sp.squads = New Int[][squads.Length]
		For Local index% = 0 To squads.Length - 1
			sp.squads[index] = squads[index][..]
		Next
		sp.spawn_point = Copy_POINT( spawn_point )
		sp.spawn_delay = spawn_delay[..]
		sp.political_alignment = political_alignment
		Return sp
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "squads", Create_TJSONArray_from_Int_array_array( squads ))
		this_json.SetByName( "spawn_point", spawn_point.to_json() )
		this_json.SetByName( "spawn_delay", Create_TJSONArray_from_Int_array( spawn_delay ))
		this_json.SetByName( "political_alignment", TJSONNumber.Create( political_alignment ))
		Return this_json
	End Method
End Type

Function Create_SPAWNER_from_json:SPAWNER( json:TJSON )
	Local sp:SPAWNER = New SPAWNER
	sp.squads = Create_Int_array_array_from_TJSONArray( json.GetArray( "squads" ))
	sp.spawn_point = Create_POINT_from_json( TJSON.Create( json.GetObject( "spawn_point" )))
	sp.spawn_delay = json.GetArrayInt( "spawn_delay" )
	sp.political_alignment = json.GetNumber( "political_alignment" )
	Return sp
End Function

'______________________________________________________________________________
Const LINE_TYPE_HORIZONTAL% = 1
Const LINE_TYPE_VERTICAL% = 2

Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell

Const COORDINATE_INVALID% = -1

Function Create_LEVEL:LEVEL( width%, height% )
	Local lev:LEVEL = New LEVEL
	lev.name = "unsaved level"
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
						row_count :+ 1
						path_regions = New Int[row_count,col_count]
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
						col_count :+ 1
						path_regions = New Int[row_count,col_count]
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
						row_count :- 1
						path_regions = New Int[row_count,col_count]
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
						col_count :- 1
						path_regions = New Int[row_count,col_count]
						Return
					End If
				Next
			
		End Select
	End Method
	
	Method set_path_region( x%, y%, value% )
		Local c:CELL = get_cell( x, y )
		If c.row <> COORDINATE_INVALID And c.col <> COORDINATE_INVALID
			path_regions[ c.row, c.col ] = value
		End If
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
		Local c:CELL = CELL.Create( COORDINATE_INVALID, COORDINATE_INVALID )
		For Local i% = 0 To vertical_divs.Length - 2
			If x > vertical_divs[i] And x < vertical_divs[i+1]
				c.col = i
				Exit
			End If
		Next
		For Local i% = 0 To horizontal_divs.Length - 2
			If y > horizontal_divs[i] And y < horizontal_divs[i+1]
				c.row = i
				Exit
			End If
		Next
		Return c
	End Method
	
	Method enemy_count%()
'		Local count% = 0
'		For Local this_squad:SQUAD = EachIn squads
'			count :+ this_squad.archetypes.Length
'		Next
'		Return count
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

'______________________________________________________________________________
Const spawn_point_preview_radius% = 8
Const max_level_name_length% = 22

Const EDIT_LEVEL_MODE_NONE% = 0
Const EDIT_LEVEL_MODE_PAN% = 1
Const EDIT_LEVEL_MODE_DIVIDER% = 2
Const EDIT_LEVEL_MODE_PATHING% = 3
Const EDIT_LEVEL_MODE_SPAWNER_NEW% = 4
Const EDIT_LEVEL_MODE_SPAWNER_EDIT% = 5

Function edit_level:LEVEL( lev:LEVEL )
	
	Local gridsnap% = 5
	Local mode% = EDIT_LEVEL_MODE_PAN
	Local FLAG_text_mode% = False
	Local x% = gridsnap, y% = gridsnap
	Local info_x%, info_y%
	Local mouse_down_1% = False, mouse_down_2% = False
	Local new_spawner:SPAWNER = New SPAWNER
	Local kb_handler:CONSOLE = New CONSOLE
	
	Local normal_font:TImageFont = get_font( "consolas_12" )
	Local bigger_font:TImageFont = get_font( "consolas_bold_24" )
	
	SetImageFont( normal_font )
	Local line_h% = GetImageFont().Height() - 1
	
	Repeat
		Cls
		
		'draw the gridsnap lines
		SetColor( 255, 255, 255 )
		SetLineWidth( 1 )
		SetAlpha( 0.25 )
		Local grid_rows% = lev.height / gridsnap
		Local grid_cols% = lev.width / gridsnap
		For Local i% = 0 To grid_rows
			DrawLine( x,y+i*gridsnap, x+grid_cols*gridsnap,y+i*gridsnap )
		Next
		For Local i% = 0 To grid_cols
			DrawLine( x+i*gridsnap,y, x+i*gridsnap,y+grid_rows*gridsnap )
		Next
		
		'draw the dividers
		SetAlpha( 0.50 )
		For Local i% = 0 To lev.horizontal_divs.length - 1
			DrawLine( x,y+lev.horizontal_divs[i], x+lev.width,y+lev.horizontal_divs[i] )
		Next
		For Local i% = 0 To lev.vertical_divs.length - 1
			DrawLine( x+lev.vertical_divs[i],y, x+lev.vertical_divs[i],y+lev.height )
		Next
		
		'draw the pathing grid
		SetColor( 127, 127, 127 )
		SetAlpha( 0.50 )
		For Local r% = 0 To lev.row_count - 1 'lev.horizontal_divs.Length - 2
			For Local c% = 0 To lev.col_count - 1 'lev.vertical_divs.Length - 2
				If lev.path_regions[r,c] = PATH_BLOCKED
					DrawRect( x+lev.vertical_divs[c],y+lev.horizontal_divs[r], lev.vertical_divs[c+1]-lev.vertical_divs[c],lev.horizontal_divs[r+1]-lev.horizontal_divs[r] )
				End If
			Next
		Next
		
		'draw the spawn points
		For Local sp:SPAWNER = EachIn lev.spawners
			Select sp.political_alignment
				Case ALIGNMENT_NONE
					SetColor( 255, 255, 255 )
				Case ALIGNMENT_FRIENDLY
					SetColor( 212, 212, 255 )
				Case ALIGNMENT_HOSTILE
					SetColor( 255, 212, 212 )
			End Select
			Local p:POINT = sp.spawn_point
			SetAlpha( 0.50 )
			DrawOval( x+p.pos_x - spawn_point_preview_radius,y+p.pos_y - spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
			SetLineWidth( 2 )
			SetAlpha( 1 )
			'DrawLine( x+p.pos_x + spawn_point_preview_radius*Cos(p.ang-90),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang-90), x+p.pos_x + spawn_point_preview_radius*Cos(p.ang+90),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang+90) )
			DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x + spawn_point_preview_radius*Cos(p.ang),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang) )
		Next
		
		'change modes detection
		If KeyHit( KEY_ENTER )
			FLAG_text_mode = Not FLAG_text_mode
			FlushKeys()
		End If
		If FLAG_text_mode
			lev.name = kb_handler.update( lev.name, max_level_name_length )
		Else 'Not FLAG_text_mode
			If      KeyHit( KEY_1 ) Then mode = EDIT_LEVEL_MODE_PAN ..
			Else If KeyHit( KEY_2 ) Then mode = EDIT_LEVEL_MODE_DIVIDER ..
			Else If KeyHit( KEY_3 ) Then mode = EDIT_LEVEL_MODE_PATHING ..
			Else If KeyHit( KEY_4 ) Then mode = EDIT_LEVEL_MODE_SPAWNER_NEW ..
			Else If KeyHit( KEY_5 ) Then mode = EDIT_LEVEL_MODE_SPAWNER_EDIT
			
			If KeyHit( KEY_NUMADD )
				gridsnap :+ 5
				x = gridsnap
				y = gridsnap
			Else If KeyHit( KEY_NUMSUBTRACT )
				If gridsnap > 5 Then gridsnap :- 5
				x = gridsnap
				y = gridsnap
			End If
		End If
		
		'mouse init
		Local mouse:cVEC = cVEC( cVEC.Create( MouseX(),MouseY() ))
		
		'behavioral switch based on current mode
		Select mode
			
			Case EDIT_LEVEL_MODE_PAN
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If MouseDown( 1 )
					x = round_to_nearest( mouse.x + gridsnap - lev.width/2, gridsnap )
					y = round_to_nearest( mouse.y + gridsnap - lev.height/2, gridsnap )
				End If
				If MouseDown( 2 )
					x = gridsnap
					y = gridsnap
				End If
			
			Case EDIT_LEVEL_MODE_DIVIDER
				mouse.x = round_to_nearest( mouse.x, gridsnap )
				mouse.y = round_to_nearest( mouse.y, gridsnap )
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If mouse_down_1 And Not MouseDown( 1 )
					If Not KeyDown( KEY_LCONTROL ) And Not KeyDown( KEY_RCONTROL )
						lev.add_divider( mouse.x-x, LINE_TYPE_VERTICAL )
					Else 
						lev.remove_divider( mouse.x-x, LINE_TYPE_VERTICAL )
					End If
				End If
				If mouse_down_2 And Not MouseDown( 2 )
					If Not KeyDown( KEY_LCONTROL ) And Not KeyDown( KEY_RCONTROL )
						lev.add_divider( mouse.y-y, LINE_TYPE_HORIZONTAL )
					Else 
						lev.remove_divider( mouse.y-y, LINE_TYPE_HORIZONTAL )
					End If
				End If
				SetAlpha( 0.60 )
				If MouseDown( 1 )
					mouse_down_1 = True
					SetLineWidth( 3 )
					DrawLine( mouse.x,y, mouse.x,y+lev.height )
					SetLineWidth( 1 )
					DrawLine( mouse.x,y, mouse.x,y+lev.height )
				Else
					mouse_down_1 = False
				End If
				If MouseDown( 2 )
					mouse_down_2 = True
					SetLineWidth( 3 )
					DrawLine( x,mouse.y, x+lev.width,mouse.y )
					SetLineWidth( 1 )
					DrawLine( x,mouse.y, x+lev.width,mouse.y )
				Else
					mouse_down_2 = False
				End If
									
			Case EDIT_LEVEL_MODE_PATHING
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If MouseDown( 1 )
					lev.set_path_region( mouse.x-x,mouse.y-y, PATH_BLOCKED )
				Else If MouseDown( 2 )
					lev.set_path_region( mouse.x-x,mouse.y-y, PATH_PASSABLE )
				End If
				
			Case EDIT_LEVEL_MODE_SPAWNER_NEW
				mouse.x = round_to_nearest( mouse.x, gridsnap )
				mouse.y = round_to_nearest( mouse.y, gridsnap )
				new_spawner.spawn_point.pos_x = mouse.x
				new_spawner.spawn_point.pos_y = mouse.y
				Select new_spawner.political_alignment
					Case ALIGNMENT_NONE
						SetColor( 255, 255, 255 )
					Case ALIGNMENT_FRIENDLY
						SetColor( 64, 64, 255 )
					Case ALIGNMENT_HOSTILE
						SetColor( 255, 64, 64 )
				End Select
				If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
					Local closest_sp:SPAWNER = Null
					For Local sp:SPAWNER = EachIn lev.spawners
						If closest_sp = Null Or ..
						closest_sp.spawn_point.dist_to( Create_POINT( mouse.x, mouse.y )) > sp.spawn_point.dist_to( Create_POINT( mouse.x, mouse.y ))
							closest_sp = sp
						End If
					Next
					If closest_sp <> Null
						SetLineWidth( 2 )
						SetAlpha( 0.6 )
						Select closest_sp.political_alignment
							Case ALIGNMENT_NONE
								SetColor( 255, 255, 255 )
							Case ALIGNMENT_FRIENDLY
								SetColor( 64, 64, 255 )
							Case ALIGNMENT_HOSTILE
								SetColor( 255, 64, 64 )
						End Select
						DrawLine( mouse.x,mouse.y, closest_sp.spawn_point.pos_x+x,closest_sp.spawn_point.pos_y+y )
						If mouse_down_1 And Not MouseDown( 1 )
							lev.remove_spawner( closest_sp )
						End If
					End If
				Else
					If mouse_down_1 And Not MouseDown( 1 )
						lev.add_spawner( new_spawner )
						new_spawner = new_spawner.clone()
					End If
				End If
				If MouseDown( 1 )
					mouse_down_1 = True
					If Not (KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL ))
						Local p:POINT = new_spawner.spawn_point
						SetAlpha( 0.50 )
						DrawOval( x+p.pos_x - spawn_point_preview_radius,y+p.pos_y - spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
						SetLineWidth( 2 )
						SetAlpha( 1 )
						'DrawLine( x+p.pos_x + spawn_point_preview_radius*Cos(p.ang-90),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang-90), x+p.pos_x + spawn_point_preview_radius*Cos(p.ang+90),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang+90) )
						DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x + spawn_point_preview_radius*Cos(p.ang),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang) )
					End If
				Else
					mouse_down_1 = False
				End If
				If KeyHit( KEY_LEFT )
					new_spawner.spawn_point.ang = ang_wrap( new_spawner.spawn_point.ang - 45 )
				End If
				If KeyHit( KEY_RIGHT )
					new_spawner.spawn_point.ang = ang_wrap( new_spawner.spawn_point.ang + 45 )
				End If
				If KeyHit( KEY_UP )
					new_spawner.political_alignment :+ 1
					If new_spawner.political_alignment > 2 Then new_spawner.political_alignment = 0
				End If
				If KeyHit( KEY_DOWN )
					new_spawner.political_alignment :- 1
					If new_spawner.political_alignment < 0 Then new_spawner.political_alignment = 2
				End If
				
			Case EDIT_LEVEL_MODE_SPAWNER_EDIT
				
				
		End Select
		
		'unconditionally draw level info panel and editor help
		info_x = round_to_nearest( window_w, gridsnap ) - 300; info_y = 0;
		SetAlpha( 0.75 )
		SetColor( 32, 32, 32 )
		DrawRect( info_x,info_y, 300,window_h )
		SetAlpha( 1 )
		SetColor( 196, 196, 196 )
		DrawLine( info_x,info_y, info_x,window_h )
		SetColor( 255, 255, 255 )
		info_x :+ 6; info_y :+ 3
		DrawText( ""+EDIT_LEVEL_MODE_PAN+":pan  "+..
								 EDIT_LEVEL_MODE_DIVIDER+":div  "+..
								 EDIT_LEVEL_MODE_PATHING+":paths  "+..
								 EDIT_LEVEL_MODE_SPAWNER_NEW+","+EDIT_LEVEL_MODE_SPAWNER_EDIT+":spawners  ", info_x,info_y ); info_y :+ line_h
		Select mode
			Case EDIT_LEVEL_MODE_PAN
				DrawText( "mode "+EDIT_LEVEL_MODE_PAN+" -> camera pan", info_x,info_y )
			Case EDIT_LEVEL_MODE_DIVIDER
				DrawText( "mode "+EDIT_LEVEL_MODE_DIVIDER+" -> dividers vertical/horizontal", info_x,info_y )
			Case EDIT_LEVEL_MODE_PATHING
				DrawText( "mode "+EDIT_LEVEL_MODE_PATHING+" -> pathing blocked/passable", info_x,info_y )
			Case EDIT_LEVEL_MODE_SPAWNER_NEW
				DrawText( "mode "+EDIT_LEVEL_MODE_SPAWNER_NEW+" -> spawners add/remove", info_x,info_y )
			Case EDIT_LEVEL_MODE_SPAWNER_EDIT
				DrawText( "mode "+EDIT_LEVEL_MODE_SPAWNER_EDIT+" -> spawners edit", info_x,info_y )
		End Select; info_y :+ 2*line_h
		SetImageFont( bigger_font )
		DrawText_with_glow( lev.name, info_x,info_y )
		If FLAG_text_mode
			SetAlpha( 0.5 + Sin( Float(now() Mod cursor_blink) / Float(cursor_blink) ) )
			DrawText_with_glow( "|", info_x + TextWidth( lev.name ) - 2,info_y )
			SetAlpha( 1 )
		End If
		info_y :+ GetImageFont().Height() - 1
		SetImageFont( normal_font )
		DrawText( "pathing regions: "+lev.row_count*lev.col_count, info_x,info_y ); info_y :+ line_h
		DrawText( "spawners: "+lev.spawners.Length, info_x,info_y ); info_y :+ line_h
		
		Flip( 1 )
	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
	
	Return lev
End Function


