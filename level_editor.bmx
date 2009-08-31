Rem
	level_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "level.bmx"
Import "draw.bmx"
Import "console.bmx"

'______________________________________________________________________________
Const spawn_point_preview_radius% = 10
Const max_level_name_length% = 22

Const EDIT_LEVEL_MODE_NONE% = 0
Const EDIT_LEVEL_MODE_BASIC% = 1
Const EDIT_LEVEL_MODE_DIVIDERS% = 2
Const EDIT_LEVEL_MODE_PATH_REGIONS% = 3
Const EDIT_LEVEL_MODE_SPAWNER_SYSTEM% = 4
Const EDIT_LEVEL_MODE_SPAWNER_DETAILS% = 5
Const EDIT_LEVEL_MODE_PROPS% = 6

Function level_editor( lev:LEVEL )
	
	Local gridsnap_mouse:cVEC = New cVEC
	Local drag_mouse_start:cVEC = New cVEC
	Local drag_pos_start:POINT = New POINT
	Local new_spawner:SPAWNER = New SPAWNER
	new_spawner.class = SPAWNER.class_GATED_FACTORY
	Local closest_sp:SPAWNER = Null
	Local new_prop:PROP_DATA = New PROP_DATA
	Local prop_keys$[] = get_keys( prop_map )
	Local new_prop_archetype% = 0
	new_prop.archetype = prop_keys[new_prop_archetype]
	Local closest_pd:PROP_DATA = Null

	Local nearest_div%
	Local nearest_div_dist%
	Local nearest_div_axis%
	
	Local current_grid_size% = 0
	Local grid_sizes%[] = [ 1, 2, 5, 8, 10, 12, 15, 20, 25 ]
	Local gridsnap% = grid_sizes[current_grid_size]
	Local mode% = EDIT_LEVEL_MODE_BASIC
	Local x% = gridsnap, y% = gridsnap
	Local info_x%, info_y%
	Local mouse_down_1%, mouse_down_2%
	Local control%, alt%, shift%, any_modifiers%
	Local divider_axis% = LINE_TYPE_VERTICAL
	
	Local cursor% = 0
	Local cursor_archetype_index% = 0
	Local unit_keys$[] = get_keys( unit_map )
	Local cursor_archetype$ = unit_keys[cursor_archetype_index]
	Local sp_delay_time$
	
	Local normal_font:TImageFont = get_font( "consolas_12" )
	Local bigger_font:TImageFont = get_font( "consolas_bold_24" )
	Local line_h% = 10
	
	Repeat
		Cls()
		SetImageFont( normal_font )
		
		'modifier keys
		control = KeyDown( KEY_LCONTROL ) | KeyDown( KEY_RCONTROL )
		alt =     KeyDown( KEY_LALT )     | KeyDown( KEY_RALT )
		shift =   KeyDown( KEY_LSHIFT )   | KeyDown( KEY_RSHIFT )
		any_modifiers = control | alt | shift
		
		'save level
		If control And KeyHit( KEY_S )
			menu_command( COMMAND.SHOW_CHILD_MENU, INTEGER.Create( MENU_ID.SAVE_LEVEL ))
			get_current_menu().update( True )
			Return
		End If
		
		mouse.pos_x = MouseX()
		mouse.pos_y = MouseY()
		
		'for instaquit
		escape_key_update()

		SetColor( 255, 255, 255 )
		SetLineWidth( 1 )
		SetAlpha( 0.5 )
		SetRotation( 0 )
		''mouse delta line
		'DrawLine( mouse.pos_x - mouse_delta.x, mouse.pos_y - mouse_delta.y, mouse.pos_x, mouse.pos_y )		
		
		'draw the gridsnap lines
		If gridsnap > 1
			If gridsnap > 2
				SetAlpha( 0.25 )
			Else
				SetAlpha( 0.125 )
			End If
			Local grid_rows% = lev.height / gridsnap
			Local grid_cols% = lev.width / gridsnap
			For Local i% = 0 To grid_rows
				DrawLine( x,y+i*gridsnap, x+grid_cols*gridsnap,y+i*gridsnap )
			Next
			For Local i% = 0 To grid_cols
				DrawLine( x+i*gridsnap,y, x+i*gridsnap,y+grid_rows*gridsnap )
			Next
		End If
		
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
			Select sp.alignment
				Case ALIGNMENT_NONE
					SetColor( 255, 255, 255 )
				Case ALIGNMENT_FRIENDLY
					SetColor( 64, 64, 255 )
				Case ALIGNMENT_HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			SetRotation( 0 )
			Local p:POINT = sp.pos
			SetAlpha( 0.5 )
			DrawOval( x+p.pos_x-spawn_point_preview_radius,y+p.pos_y-spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
			SetLineWidth( 2 )
			SetAlpha( 1 )
			DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x + spawn_point_preview_radius*Cos(p.ang),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang) )
			If sp.class = SPAWNER.class_GATED_FACTORY
				SetAlpha( 0.5 )
				SetRotation( sp.pos.ang )
				DrawImage( get_image( "door_fg" ), x+sp.pos.pos_x, y+sp.pos.pos_y )
			End If
			SetAlpha( 0.666 )
			SetRotation( 0 )
			SetScale( 1, 1 )
			Select sp.alignment
				Case ALIGNMENT_NONE
					SetColor( 255, 255, 255 )
				Case ALIGNMENT_FRIENDLY
					SetColor( 64, 64, 255 )
				Case ALIGNMENT_HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			Local size% = 3, sep% = 1
			For Local r% = 0 To sp.count_squads()-1
				For Local c% = 0 To sp.count_squadmembers( r )-1
					DrawRect( x + sp.pos.pos_x - 10 - c*(size+sep), y + sp.pos.pos_y + 10 + r*(size+sep), size, size )
				Next
			Next
		Next
		SetAlpha( 1 )
		SetRotation( 0 )
		
		'draw the props
		For Local pd:PROP_DATA = EachIn lev.props
			Local prop:AGENT = get_prop( pd.archetype )
			prop.pos_x = pd.pos.pos_x+x
			prop.pos_y = pd.pos.pos_y+y
			prop.ang = pd.pos.ang
			SetColor( 255, 255, 255 )
			SetAlpha( 0.5 )
			prop.draw()
		Next
		
		'change modes detection
		If      KeyHit( KEY_1 ) Then mode = EDIT_LEVEL_MODE_BASIC ..
		Else If KeyHit( KEY_2 ) Then mode = EDIT_LEVEL_MODE_DIVIDERS ..
		Else If KeyHit( KEY_3 ) Then mode = EDIT_LEVEL_MODE_PATH_REGIONS ..
		Else If KeyHit( KEY_4 ) Then mode = EDIT_LEVEL_MODE_SPAWNER_SYSTEM ..
		Else If KeyHit( KEY_5 ) Then mode = EDIT_LEVEL_MODE_SPAWNER_DETAILS ..
		Else If KeyHit( KEY_6 ) Then mode = EDIT_LEVEL_MODE_PROPS
		
		If KeyHit( KEY_NUMADD )
			current_grid_size :+ 1
			If current_grid_size > grid_sizes.Length - 1 Then current_grid_size = 0
			gridsnap = grid_sizes[current_grid_size]
			x = gridsnap
			y = gridsnap
		Else If KeyHit( KEY_NUMSUBTRACT )
			current_grid_size :- 1
			If current_grid_size < 0 Then current_grid_size = grid_sizes.Length - 1
			gridsnap = grid_sizes[current_grid_size]
			x = gridsnap
			y = gridsnap
		End If
		
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
		
		SetImageFont( normal_font )

		'mode help
		DrawText_with_shadow( ""+..
			EDIT_LEVEL_MODE_BASIC+":pan "+..
			EDIT_LEVEL_MODE_DIVIDERS+":split "+..
			EDIT_LEVEL_MODE_PATH_REGIONS+":fill "+..
			EDIT_LEVEL_MODE_SPAWNER_SYSTEM+","+EDIT_LEVEL_MODE_SPAWNER_DETAILS+":spawners "+..
			EDIT_LEVEL_MODE_PROPS+":props ",..
			info_x,info_y ); info_y :+ line_h
		
		'mode help (context-specific)
		Local h% = 0
		Select mode
			Case EDIT_LEVEL_MODE_BASIC
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_BASIC+" -> camera pan", info_x,info_y )
				DrawText_with_shadow( "click and drag to pan", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "enter to edit level name", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
			Case EDIT_LEVEL_MODE_DIVIDERS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_DIVIDERS+" -> dividers", info_x,info_y )
				DrawText_with_shadow( "click to split", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "right-click to toggle axis", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "ctrl+click to drag", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "alt+click to join", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
			Case EDIT_LEVEL_MODE_PATH_REGIONS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PATH_REGIONS+" -> path regions", info_x,info_y )
				DrawText_with_shadow( "click block out area", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "right-click to clear area", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
			Case EDIT_LEVEL_MODE_SPAWNER_SYSTEM
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_SPAWNER_SYSTEM+" -> spawner system", info_x,info_y )
				DrawText_with_shadow( "click to paste brush", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "right-click to clear brush", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "ctrl+click & drag to move", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "ctrl+right-click to copy to brush", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "ctrl+tab to setup cell for gated-spawner", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "shift+click to set angle", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "alt+click to delete", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
			Case EDIT_LEVEL_MODE_SPAWNER_DETAILS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_SPAWNER_DETAILS+" -> spawner details", info_x,info_y )
				DrawText_with_shadow( "hover to edit nearest spawner", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "up/down to select squad", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "left/right to change enemy type", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "insert/delete to add/remove squad member", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "home/end to change class", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "pgup/pgdn to change alignment", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				DrawText_with_shadow( "enter to edit wait time", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
			Case EDIT_LEVEL_MODE_PROPS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PROPS+" -> props", info_x,info_y )
				DrawText_with_shadow( "click to add new", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
				'...
		End Select; info_y :+ line_h
		DrawText_with_shadow( "numpad +/- gridsnap zoom", info_x,info_y ); info_y :+ 2*line_h
		
		'level name/title
		SetImageFont( bigger_font )
		DrawText_with_outline( lev.name, info_x, info_y )
		Local title_y% = info_y
		info_y :+ GetImageFont().Height() - 1
		
		'level info
		SetImageFont( normal_font )
		DrawText_with_shadow( "size: "+lev.width+" x "+lev.height, info_x,info_y ); info_y :+ 1.5*line_h
		DrawText_with_shadow( "pathing regions: "+lev.row_count*lev.col_count, info_x,info_y ); info_y :+ line_h
		DrawText_with_shadow( "spawners: "+lev.spawners.Length, info_x,info_y ); info_y :+ line_h
		
		'mode code (LOL! I rhymed) <-- WTF
		Select mode
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_BASIC
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				'pan
				If MouseDown( 1 )
					If Not mouse_down_1
						drag_mouse_start = Copy_POINT( mouse ).to_cvec()
						drag_pos_start = Create_POINT( x, y )
					Else
						x = round_to_nearest( drag_pos_start.pos_x + (mouse.pos_x - drag_mouse_start.x), gridsnap )
						y = round_to_nearest( drag_pos_start.pos_y + (mouse.pos_y - drag_mouse_start.y), gridsnap )
					End If
				End If
				If KeyHit( KEY_ENTER )
					FlushKeys()
					lev.name = CONSOLE.get_input( lev.name,, info_x, title_y, bigger_font, screencap() )
				End If
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_DIVIDERS
				Local pos_str$ = ""
				SetImageFont( get_font( "consolas_bold_14" ))
				gridsnap_mouse.x = round_to_nearest( mouse.pos_x, gridsnap )
				gridsnap_mouse.y = round_to_nearest( mouse.pos_y, gridsnap )
				SetColor( 255, 255, 255 )
				SetLineWidth( 3 )
				'toggle divider_axis
				If MouseHit( 2 )'mouse_down_2 And Not MouseDown( 2 )
					If divider_axis = LINE_TYPE_VERTICAL
						divider_axis = LINE_TYPE_HORIZONTAL
					Else 'divider_axis <> LINE_TYPE_VERTICAL
						divider_axis = LINE_TYPE_VERTICAL
					End If
				End If
				If alt Or control
					If alt And mouse_down_1 And Not MouseDown( 1 )
						'remove nearest div (do not recalculate)
						lev.remove_divider( nearest_div, nearest_div_axis )
					Else If control And MouseDown( 1 )
						If mouse_down_1
							'drag nearest div, and do not change it while dragging
							If nearest_div_axis = LINE_TYPE_VERTICAL
								lev.set_divider( LINE_TYPE_VERTICAL, nearest_div, gridsnap_mouse.x-x - nearest_div_dist )
							Else If nearest_div_axis = LINE_TYPE_HORIZONTAL
								lev.set_divider( LINE_TYPE_HORIZONTAL, nearest_div, gridsnap_mouse.y-y - nearest_div_dist )
							End If
						End If
					Else
						'search for the nearest div to the mouse
						nearest_div = 0
						nearest_div_dist = CELL.MAXIMUM_COST
						nearest_div_axis = LINE_TYPE_VERTICAL
						For Local i% = 0 To lev.vertical_divs.Length - 1
							Local this_dist% = gridsnap_mouse.x-x - lev.vertical_divs[i]
							If Abs(this_dist) < Abs(nearest_div_dist)
								nearest_div = i
								nearest_div_dist = this_dist
								nearest_div_axis = LINE_TYPE_VERTICAL
							End If
						Next
						For Local i% = 0 To lev.horizontal_divs.Length - 1
							Local this_dist% = gridsnap_mouse.y-y - lev.horizontal_divs[i]
							If Abs(this_dist) < Abs(nearest_div_dist)
								nearest_div = i
								nearest_div_dist = this_dist
								nearest_div_axis = LINE_TYPE_HORIZONTAL
							End If
						Next
					End If
					'draw nearest div
					SetAlpha( 0.25 + 0.25*Sin(now() Mod 360) )
					If nearest_div_axis = LINE_TYPE_VERTICAL
						DrawLine( lev.vertical_divs[nearest_div]+x,y, lev.vertical_divs[nearest_div]+x,y+lev.height )
						DrawLine( gridsnap_mouse.x,gridsnap_mouse.y, lev.vertical_divs[nearest_div]+x,gridsnap_mouse.y )
						pos_str = Int(lev.vertical_divs[nearest_div])
					Else If nearest_div_axis = LINE_TYPE_HORIZONTAL
						DrawLine( x,lev.horizontal_divs[nearest_div]+y, x+lev.width,lev.horizontal_divs[nearest_div]+y )
						DrawLine( gridsnap_mouse.x,gridsnap_mouse.y, gridsnap_mouse.x,lev.horizontal_divs[nearest_div]+y )
						pos_str = Int(lev.horizontal_divs[nearest_div])
					End If
					SetAlpha( 1 )
					DrawText_with_shadow( pos_str, mouse.pos_x + 5, mouse.pos_y - 16 )
				Else
					'insert div
					If mouse_down_1 And Not MouseDown( 1 )
						If divider_axis = LINE_TYPE_VERTICAL
							lev.add_divider( gridsnap_mouse.x-x, LINE_TYPE_VERTICAL )
						Else If divider_axis = LINE_TYPE_HORIZONTAL
							lev.add_divider( gridsnap_mouse.y-y, LINE_TYPE_HORIZONTAL )
						End If
					End If
					'insert div cursor
					If MouseDown( 1 )
						SetAlpha( 0.75 + 0.5*Sin(now() Mod 360) )
					Else
						SetAlpha( 0.25 )
					End If
					If divider_axis = LINE_TYPE_VERTICAL
						DrawLine( gridsnap_mouse.x,y, gridsnap_mouse.x,y+lev.height )
						pos_str = Int(gridsnap_mouse.x-x)
					Else If divider_axis = LINE_TYPE_HORIZONTAL
						DrawLine( x,gridsnap_mouse.y, x+lev.width,gridsnap_mouse.y )
						pos_str = Int(gridsnap_mouse.y-y)
					End If
					SetAlpha( 1 )
					DrawText_with_shadow( pos_str, mouse.pos_x + 5, mouse.pos_y - 16 )
				End If
									
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_PATH_REGIONS
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If MouseDown( 1 )
					lev.set_path_region_from_xy( mouse.pos_x-x,mouse.pos_y-y, PATH_BLOCKED )
				Else If MouseDown( 2 )
					lev.set_path_region_from_xy( mouse.pos_x-x,mouse.pos_y-y, PATH_PASSABLE )
				End If
				
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_SPAWNER_SYSTEM
				gridsnap_mouse.x = round_to_nearest( mouse.pos_x-x, gridsnap )
				gridsnap_mouse.y = round_to_nearest( mouse.pos_y-y, gridsnap )
				new_spawner.pos.pos_x = gridsnap_mouse.x
				new_spawner.pos.pos_y = gridsnap_mouse.y
				Select new_spawner.alignment
					Case ALIGNMENT_NONE
						SetColor( 255, 255, 255 )
					Case ALIGNMENT_FRIENDLY
						SetColor( 64, 64, 255 )
					Case ALIGNMENT_HOSTILE
						SetColor( 255, 64, 64 )
				End Select
				If Not any_modifiers
					If mouse_down_1 And Not MouseDown( 1 )
						closest_sp = new_spawner.clone()
						lev.add_spawner( closest_sp )
					End If
					If MouseDown( 2 )
						new_spawner = New SPAWNER
						new_spawner.class = SPAWNER.class_GATED_FACTORY
					End If
				Else
					If Not MouseDown( 1 )
						closest_sp = Null
					End If
					If closest_sp = Null
						For Local sp:SPAWNER = EachIn lev.spawners
							If closest_sp = Null Or ..
							closest_sp.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y )) > sp.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y ))
								closest_sp = sp
							End If
						Next
					End If
					If closest_sp <> Null
						If MouseDown( 1 )
							SetAlpha( 0.70 )
						Else
							SetAlpha( 0.35 )
						End If
						SetLineWidth( 2 )
						Select closest_sp.alignment
							Case ALIGNMENT_NONE
								SetColor( 255, 255, 255 )
							Case ALIGNMENT_FRIENDLY
								SetColor( 64, 64, 255 )
							Case ALIGNMENT_HOSTILE
								SetColor( 255, 64, 64 )
						End Select
						DrawLine( MouseX(),MouseY(), closest_sp.pos.pos_x+x,closest_sp.pos.pos_y+y )
						If control
							If Not mouse_down_1 And MouseDown( 1 )
								drag_mouse_start = Copy_POINT( mouse ).to_cvec()
								drag_pos_start = Copy_POINT( closest_sp.pos )
							End If
							If MouseDown( 1 )
								closest_sp.pos.pos_x = round_to_nearest( drag_pos_start.pos_x + (mouse.pos_x - drag_mouse_start.x), gridsnap )
								closest_sp.pos.pos_y = round_to_nearest( drag_pos_start.pos_y + (mouse.pos_y - drag_mouse_start.y), gridsnap )
							End If
						Else If alt
							If mouse_down_1 And Not MouseDown( 1 )
								lev.remove_spawner( closest_sp )
							End If
						Else If shift
							If MouseDown( 1 )
								closest_sp.pos.ang = round_to_nearest( ang_wrap( closest_sp.pos.ang_to( mouse )), 45 )
							End If
						End If
						If control And KeyHit( KEY_TAB ) And closest_sp
							'find a spawner in the current cell
							Local sp_cell:CELL = lev.get_cell( closest_sp.pos.pos_x, closest_sp.pos.pos_y )
							'decide what size the cell should be based on orientation of spawner
							Local new_w%, new_h%, new_x%, new_y%, go% = True
							If closest_sp.pos.ang = 0 Or Abs( closest_sp.pos.ang ) = 180 'east/west
								new_w = 70
								new_h = 62
								If closest_sp.pos.ang = 0 'east
									new_x = 28
									new_y = 31
								Else 'west
									new_x = 52 - 10
									new_y = 31
								End If
							Else If Abs( closest_sp.pos.ang ) = 90 'north/south
								new_w = 62
								new_h = 70
								If closest_sp.pos.ang > 0 'south
									new_x = 31
									new_y = 28
								Else 'north
									new_x = 31
									new_y = 52 - 10
								End If
							Else
								go = False
							End If
							If go
								'resize current cell to accomodate it
								lev.resize_cell( sp_cell, new_w, new_h )
								'move the spawner to the correct spot in the cell
								closest_sp.pos.pos_x = lev.vertical_divs[sp_cell.col] + new_x
								closest_sp.pos.pos_y = lev.horizontal_divs[sp_cell.row] + new_y
							End If
						End If
						If MouseDown( 2 ) And Not mouse_down_2
							new_spawner = closest_sp.clone()
						End If
					End If
				End If
				Local alpha_mod#
				If MouseDown( 1 )
					alpha_mod = 1.0
				Else
					alpha_mod = 0.5
				End If
				If Not any_modifiers
					Local p:POINT = new_spawner.pos
					SetAlpha( 0.50*alpha_mod )
					DrawOval( x+p.pos_x-spawn_point_preview_radius,y+p.pos_y-spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
					SetLineWidth( 2 )
					SetAlpha( 1.00*alpha_mod )
					DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x+spawn_point_preview_radius*Cos(p.ang),y+p.pos_y+spawn_point_preview_radius*Sin(p.ang) )
					If new_spawner.class = SPAWNER.class_GATED_FACTORY
						SetAlpha( 0.5*alpha_mod )
						SetRotation( new_spawner.pos.ang )
						DrawImage( get_image( "door_fg" ), x+new_spawner.pos.pos_x, y+new_spawner.pos.pos_y )
					End If
					SetAlpha( 0.666*alpha_mod )
					SetRotation( 0 )
					SetScale( 1, 1 )
					Select new_spawner.alignment
						Case ALIGNMENT_NONE
							SetColor( 255, 255, 255 )
						Case ALIGNMENT_FRIENDLY
							SetColor( 64, 64, 255 )
						Case ALIGNMENT_HOSTILE
							SetColor( 255, 64, 64 )
					End Select
					Local size% = 3, sep% = 1
					For Local r% = 0 To new_spawner.count_squads()-1
						For Local c% = 0 To new_spawner.count_squadmembers( r )-1
							DrawRect( x + p.pos_x - 10 - c*(size+sep), y + p.pos_y + 10 + r*(size+sep), size, size )
						Next
					Next
				End If
				If KeyHit( KEY_LEFT )
					new_spawner.pos.ang = ang_wrap( new_spawner.pos.ang - 45 )
				End If
				If KeyHit( KEY_RIGHT )
					new_spawner.pos.ang = ang_wrap( new_spawner.pos.ang + 45 )
				End If
				
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_SPAWNER_DETAILS
				Local closest_sp:SPAWNER = Null
				For Local sp:SPAWNER = EachIn lev.spawners
					If closest_sp = Null Or ..
					closest_sp.pos.add_pos( x, y ).dist_to( Create_POINT( mouse.pos_x, mouse.pos_y )) > sp.pos.dist_to( Create_POINT( mouse.pos_x, mouse.pos_y ))
						closest_sp = sp
					End If
				Next
				Local sp:SPAWNER = closest_sp
				If sp <> Null
					SetLineWidth( 2 )
					SetAlpha( 0.6 )
					Select sp.alignment
						Case ALIGNMENT_NONE
							SetColor( 255, 255, 255 )
						Case ALIGNMENT_FRIENDLY
							SetColor( 64, 64, 255 )
						Case ALIGNMENT_HOSTILE
							SetColor( 255, 64, 64 )
					End Select
					DrawLine( MouseX(),MouseY(), sp.pos.pos_x+x,sp.pos.pos_y+y )
					
					SetAlpha( 1 )
					SetColor( 255, 255, 255 )
					info_y :+ line_h
					DrawText_with_shadow( "current spawner", info_x,info_y ); info_y :+ line_h
					DrawText_with_shadow( "  class "+class_to_string(sp.class), info_x,info_y ); info_y :+ line_h
					Select sp.alignment
						Case ALIGNMENT_NONE
							SetColor( 255, 255, 255 )
						Case ALIGNMENT_FRIENDLY
							SetColor( 64, 64, 255 )
						Case ALIGNMENT_HOSTILE
							SetColor( 255, 64, 64 )
					End Select
					DrawText_with_shadow( "  alignment "+alignment_to_string(sp.alignment), info_x,info_y ); info_y :+ line_h
					SetColor( 255, 255, 255 )
					DrawText_with_shadow( "  squads "+sp.count_squads(), info_x,info_y ); info_y :+ line_h
					info_y :+ line_h
					Local cell_size% = 15
					If sp.count_squads() <> 0
						For Local r% = 0 To sp.count_squads()-1
							For Local c% = 0 To sp.count_squadmembers( r )-1
								Local ag:COMPLEX_AGENT = get_unit( sp.squads[r][c] )
								ag.political_alignment = sp.alignment
								ag.scale_all( 0.75 )
								ag.pos_x = info_x + cell_size + c*cell_size - cell_size/2
								ag.pos_y = info_y + cell_size + r*cell_size - cell_size/2
								ag.ang = -90
								ag.snap_all_turrets()
								ag.update()
								ag.draw( , 0.75 )
							Next
						Next
						SetRotation( 0 )
						SetScale( 1, 1 )
						SetColor( 255, 255, 255 )
						If cursor > sp.count_squads() Then cursor = sp.count_squads()
					Else
						cursor = 0
					End If
					'draw all delay times except the cursor
					For Local r% = 0 To sp.count_squads()-1
						If r <> cursor
							DrawText_with_shadow( sp.delay_time[r], window_w - 50, info_y + r*cell_size + line_h/3 )
						End If
					Next

					If KeyHit( KEY_ENTER ) And cursor >= 0 And cursor < sp.count_squads()
						FlushKeys()
						sp.delay_time[cursor] = CONSOLE.get_input( sp.delay_time[cursor],, window_w - 50, info_y + cursor*cell_size + line_h/3, normal_font, screencap() ).ToInt()
					End If
					If cursor >= 0 And cursor < sp.count_squads()
						DrawText_with_shadow( String.FromInt( sp.delay_time[cursor] ), window_w - 50, info_y + cursor*cell_size + line_h/3 )
					End If
					Local cursor_squadmembers% = sp.count_squadmembers( cursor )
					Local ag:COMPLEX_AGENT = get_unit( cursor_archetype )
					ag.scale_all( 0.75 )
					ag.pos_x = info_x + cell_size + cursor_squadmembers*cell_size - cell_size/2
					ag.pos_y = info_y + cell_size + cursor*cell_size - cell_size/2
					ag.ang = -90
					ag.snap_all_turrets()
					ag.update()
					ag.draw( 0.5 + Sin(now() Mod 360), 0.75 )
					SetRotation( 0 )
					SetScale( 1, 1 )
					
					If KeyHit( KEY_PAGEUP )
						sp.alignment :- 1
						If sp.alignment < 0 Then sp.alignment = 2
					End If
					If KeyHit( KEY_PAGEDOWN )
						sp.alignment :+ 1
						If sp.alignment > 2 Then sp.alignment = 0
					End If
					If KeyHit( KEY_HOME )
						sp.class = SPAWNER.class_GATED_FACTORY
					End If
					If KeyHit( KEY_END )
						sp.class = SPAWNER.class_TURRET_ANCHOR
					End If
					If KeyHit( KEY_LEFT )
						cursor_archetype_index :- 1
						If cursor_archetype_index < 0 Then cursor_archetype_index = unit_keys.Length-1
						cursor_archetype = unit_keys[cursor_archetype_index]
					End If
					If KeyHit( KEY_RIGHT )
						cursor_archetype_index :+ 1
						If cursor_archetype_index > unit_keys.Length-1 Then cursor_archetype_index = 0
						cursor_archetype = unit_keys[cursor_archetype_index]
					End If
					If KeyHit( KEY_UP )
						cursor :- 1
						If cursor < 0 Then cursor = sp.count_squads()
					End If
					If KeyHit( KEY_DOWN )
						cursor :+ 1
						If cursor > sp.count_squads() Then cursor = 0
					End If
					If KeyHit( KEY_INSERT )
						If cursor >= sp.squads.Length
							sp.add_new_squad()
						End If
						sp.add_new_squadmember( cursor, cursor_archetype )
					End If
					If KeyHit( KEY_DELETE )
						If cursor < sp.squads.Length
							sp.remove_last_squadmember( cursor )
						End If
					End If
				End If
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_PROPS
				gridsnap_mouse.x = round_to_nearest( mouse.pos_x-x, gridsnap )
				gridsnap_mouse.y = round_to_nearest( mouse.pos_y-y, gridsnap )
				new_prop.pos.pos_x = gridsnap_mouse.x
				new_prop.pos.pos_y = gridsnap_mouse.y
				If Not any_modifiers
					If mouse_down_1 And Not MouseDown( 1 )
						lev.add_prop( new_prop )
						new_prop = New PROP_DATA
					End If
					If KeyHit( KEY_LEFT )
						new_prop_archetype :- 1
						If new_prop_archetype < 0 Then new_prop_archetype = prop_keys.Length - 1
						new_prop.archetype = prop_keys[ new_prop_archetype ]
					End If
					If KeyHit( KEY_RIGHT )
						new_prop_archetype :+ 1
						If new_prop_archetype > prop_keys.Length - 1 Then new_prop_archetype = 0
						new_prop.archetype = prop_keys[ new_prop_archetype ]
					End If
					Local prop:AGENT = get_prop( new_prop.archetype )
					If prop
						prop.pos_x = gridsnap_mouse.x+x
						prop.pos_y = gridsnap_mouse.y+y
						SetColor( 255, 255, 255 )
						SetAlpha( 0.33333 )
						prop.draw()
					End If
				Else
					If Not MouseDown( 1 )
						closest_pd = Null
					End If
					If closest_pd = Null
						For Local pd:PROP_DATA = EachIn lev.props
							If closest_pd = Null Or ..
							closest_pd.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y )) > pd.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y ))
								closest_pd = pd
							End If
						Next
					End If
					If closest_pd <> Null
						If MouseDown( 1 )
							SetAlpha( 0.70 )
						Else
							SetAlpha( 0.35 )
						End If
						SetLineWidth( 2 )
						SetColor( 255, 255, 255 )
						DrawLine( MouseX(),MouseY(), closest_pd.pos.pos_x+x,closest_pd.pos.pos_y+y )
						If control
							If Not mouse_down_1 And MouseDown( 1 )
								drag_mouse_start = Copy_POINT( mouse ).to_cvec()
								drag_pos_start = Copy_POINT( closest_pd.pos )
							End If
							If MouseDown( 1 )
								closest_pd.pos.pos_x = round_to_nearest( drag_pos_start.pos_x + (mouse.pos_x - drag_mouse_start.x), gridsnap )
								closest_pd.pos.pos_y = round_to_nearest( drag_pos_start.pos_y + (mouse.pos_y - drag_mouse_start.y), gridsnap )
							End If
						Else If alt
							If mouse_down_1 And Not MouseDown( 1 )
								lev.remove_prop( closest_pd )
							End If
						End If
					End If
				End If
				
		End Select
		
		'mouse states (these have to be updated after they are used, since what I'm really trying to capture is the time diff
		If MouseDown( 1 )
			mouse_down_1 = True
		Else 'Not MouseDown( 1 )
			mouse_down_1 = False
		End If
		If MouseDown( 2 )
			mouse_down_2 = True
		Else 'Not MouseDown( 2 )
			mouse_down_2 = False
		End If
		
		If KeyDown( KEY_ESCAPE ) And esc_held And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
			draw_instaquit_progress()
		End If
	
		Flip( True )
		
		If AppTerminate() Then End
		If escape_key_release() Or KeyDown( KEY_BACKSPACE ) Then Exit
		
	Forever
		
	FlushKeys()
	FlushMouse()
End Function

'______________________________________________________________________________
Function get_input$( initial_value$, initial_cursor_pos% = INFINITY, x%, y%, font:TImageFont, bg:TImage ) 'returns user input
		Local con:CONSOLE = new CONSOLE
		Local str$ = initial_value
		SetImageFont( font )
		Local cursor% = str.Length
		Local selection% = 0
		Local char_width% = TextWidth( "W" )
		Repeat
			Cls()
			If bg
				draw_fuzzy( bg )
			End If
			'instaquit
			escape_key_update()
			
			'cursor/selection move
			If KeyHit( KEY_LEFT )
				cursor :- 1
				If cursor < 0 Then cursor = 0
			Else If KeyHit( KEY_RIGHT )
				cursor :+ 1
				If cursor > str.Length Then cursor = str.Length
			Else If KeyHit( KEY_HOME )
				cursor = 0
			Else If KeyHit( KEY_END )
				cursor = str.Length
			End If
			
			'erase character immediately before the cursor, and decrement the cursor
			If KeyHit( KEY_BACKSPACE )
				str = str[..cursor-1] + str[cursor..]
				cursor :- 1
				If cursor < 0 Then cursor = 0
			Else If KeyHit( KEY_DELETE )
				str = str[..cursor] + str[cursor+1..]
			End If

			str = con.update( str )
			
			DrawText_with_outline( str, x, y )
			SetAlpha( 0.5 + Sin(now() Mod 360) )
			DrawText( "|", x + char_width*cursor - 4, y )
			
			'instaquit
			If KeyDown( KEY_ESCAPE ) And esc_held And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
				draw_instaquit_progress()
			End If

			Flip( 1 )
			If AppTerminate() Then End
		Until escape_key_release() Or KeyHit( KEY_ENTER )

		Return str
End Function
	
'______________________________________________________________________________
Function class_to_string$( class% )
	Select class
		Case SPAWNER.class_GATED_FACTORY
			Return "{gated_factory}"
		Case SPAWNER.class_TURRET_ANCHOR
			Return "{turret_anchor}"
	End Select
End Function

Function alignment_to_string$( alignment% )
	Select alignment
		Case ALIGNMENT_NONE
			Return "{none}"
		Case ALIGNMENT_FRIENDLY
			Return "{friendly}"
		Case ALIGNMENT_HOSTILE
			Return "{hostile}"
	End Select
End Function
