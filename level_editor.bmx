Rem
	level_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "mouse.bmx"
'Import "level.bmx"
'Import "vec.bmx"
'Import "point.bmx"
'Import "complex_agent.bmx"
'Import "unit_factory_data.bmx"
'Import "entity_data.bmx"
'Import "base_data.bmx"
'Import "console.bmx"
'Import "draw_misc.bmx"
'Import "misc.bmx"
'Import "instaquit.bmx"

'______________________________________________________________________________
Const spawn_point_preview_radius% = 10
Const max_level_name_length% = 22

Const EDIT_LEVEL_MODE_NONE% = 0
Const EDIT_LEVEL_MODE_BASIC% = 1
Const EDIT_LEVEL_MODE_DIVIDERS% = 2
Const EDIT_LEVEL_MODE_PATH_REGIONS% = 3
Const EDIT_LEVEL_MODE_UNIT_FACTORY_SYSTEM% = 4
Const EDIT_LEVEL_MODE_UNIT_FACTORY_DETAILS% = 5
Const EDIT_LEVEL_MODE_IMMEDIATES% = 6
Const EDIT_LEVEL_MODE_PROPS% = 7

Global wait_for_user_select_option% = False

Function level_editor()
	
	Local lev:LEVEL
	Local gridsnap_mouse:cVEC = New cVEC
	Local drag_mouse_start:cVEC = New cVEC
	Local drag_pos_start:POINT = New POINT
	Local new_unit_factory:UNIT_FACTORY_DATA = New UNIT_FACTORY_DATA
	Local closest_uf:UNIT_FACTORY_DATA = Null
	Local new_prop:ENTITY_DATA = New ENTITY_DATA
	Local prop_keys$[] = get_map_keys( prop_map )
	Local new_prop_archetype% = 0
	Local closest_pd:ENTITY_DATA = Null
	
	Local keys$[]
	Local data:ENTITY_DATA[]

	Local nearest_div%
	Local nearest_div_dist%
	Local nearest_div_axis%
	
	Local mode% = EDIT_LEVEL_MODE_BASIC
	Local current_grid_size% = 0
	Local grid_sizes%[] = [ 1, 2, 5, 8, 10, 12, 15, 20, 25 ]
	Local gridsnap% = grid_sizes[current_grid_size]
	Local x% = gridsnap, y% = gridsnap
	Local info_x%, info_y%
	Local control%, alt%, shift%, any_modifiers%
	Local divider_axis% = LINE_TYPE_VERTICAL
	
	Local cursor% = 0
	Local cursor_archetype_index% = 0
	Local unit_keys$[] = get_map_keys( unit_map )
	Local cursor_archetype$ = unit_keys[cursor_archetype_index]
	Local sp_delay_time$
	
	Local normal_font:TImageFont = get_font( "consolas_12" )
	Local bigger_font:TImageFont = get_font( "consolas_bold_24" )
	Local line_h% = 10
	
	Local choose_level_file_menu:TUIList = New TUIList
	choose_level_file_menu.Construct( ..
		"LOAD LEVEL", 0, ..
		[ 78,  78,  78 ], [ 255, 255, 255 ], [   0,   0,   0 ], [ 255, 255, 255 ], ..
		1, ..
		"arcade_14", "arcade_14_outline", ..
		[ 255, 255, 255 ], [   0,   0,   0 ], ..
		"arcade_7", "arcade_7_outline", ..
		[ 255, 255, 255 ], [   0,   0,   0 ], [   0,   0,   0 ], [ 205, 205, 205 ], ..
		,,,, ..
		10, 30 )
	
	Local input_font:FONT_STYLE = FONT_STYLE.Create( ..
		"arcade_14", "arcade_14_outline", ..
		[ 255, 255, 255 ], [ 64, 64, 64 ] )
	
	Local input_font_big:FONT_STYLE = FONT_STYLE.Create( ..
		"arcade_21", "arcade_21_outline", ..
		[ 255, 255, 255 ], [ 64, 64, 64 ] )
	
	Repeat
		Cls()
		SetImageFont( normal_font )
		
		lev = level_editor_cache
		
		'modifier keys
		control = KeyDown( KEY_LCONTROL ) | KeyDown( KEY_RCONTROL )
		alt =     KeyDown( KEY_LALT )     | KeyDown( KEY_RALT )
		shift =   KeyDown( KEY_LSHIFT )   | KeyDown( KEY_RSHIFT )
		any_modifiers = control | alt | shift
		
		'save level
		If control And KeyHit( KEY_S )
			Local suggested_path$ = level_path + file_system_string_filter( lev.name )
			Local cursor_pos% = suggested_path.Length - 1
			suggested_path :+ "." + level_file_ext
			Local path$ = get_input( suggested_path, cursor_pos, 10, 30, input_font, screencap() )
			If path
				save_level( path, lev )
			End If
		End If
		
		'request load level
		If control And KeyHit( KEY_O )
			wait_for_user_select_option = True
			
			populate_menu_with_files( ..
				choose_level_file_menu, ..
				level_path, level_file_ext, ..
				cmdex_load_level_editor_cache, ..
				False )
		End If
		
		'mouse position
		get_mouse_position()
		
		SetColor( 255, 255, 255 )
		SetScale( 1, 1 )
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
		SetAlpha( 0.15 )
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
		For Local uf:UNIT_FACTORY_DATA = EachIn lev.unit_factories
			Select uf.alignment
				Case POLITICAL_ALIGNMENT.NONE
					SetColor( 255, 255, 255 )
				Case POLITICAL_ALIGNMENT.FRIENDLY
					SetColor( 64, 64, 255 )
				Case POLITICAL_ALIGNMENT.HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			SetRotation( 0 )
			Local p:POINT = uf.pos
			SetAlpha( 0.5 )
			DrawOval( x+p.pos_x-spawn_point_preview_radius,y+p.pos_y-spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
			SetLineWidth( 2 )
			SetAlpha( 1 )
			DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x + spawn_point_preview_radius*Cos(p.ang),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang) )
			SetAlpha( 0.5 )
			SetRotation( uf.pos.ang )
			DrawImageRef( get_image( "door_fg" ), x+uf.pos.pos_x, y+uf.pos.pos_y )
			SetAlpha( 0.666 )
			SetRotation( 0 )
			SetScale( 1, 1 )
			Select uf.alignment
				Case POLITICAL_ALIGNMENT.NONE
					SetColor( 255, 255, 255 )
				Case POLITICAL_ALIGNMENT.FRIENDLY
					SetColor( 64, 64, 255 )
				Case POLITICAL_ALIGNMENT.HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			Local size% = 3, sep% = 1
			For Local r% = 0 To uf.count_squads()-1
				For Local c% = 0 To uf.count_squadmembers( r )-1
					DrawRect( x + uf.pos.pos_x - 10 - c*(size+sep), y + uf.pos.pos_y + 10 + r*(size+sep), size, size )
				Next
			Next
		Next
		SetAlpha( 1 )
		SetRotation( 0 )
		
		'draw the "immediate units"
		For Local u:ENTITY_DATA = EachIn lev.immediate_units
			reset_draw_state()
			Local unit:COMPLEX_AGENT = get_unit( u.archetype )
			unit.alignment = u.alignment
			unit.pos_x = u.pos.pos_x+x
			unit.pos_y = u.pos.pos_y+y
			unit.ang = u.pos.ang
			Select unit.alignment
				Case POLITICAL_ALIGNMENT.NONE
					SetColor( 255, 255, 255 )
				Case POLITICAL_ALIGNMENT.FRIENDLY
					SetColor( 64, 64, 255 )
				Case POLITICAL_ALIGNMENT.HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			unit.snap_all_turrets()
			unit.update()
			unit.draw( 0.5 )
		Next
		reset_draw_state()
		
		'draw the props
		For Local pd:ENTITY_DATA = EachIn lev.props
			Local prop:AGENT = get_prop( pd.archetype )
			prop.pos_x = pd.pos.pos_x+x
			prop.pos_y = pd.pos.pos_y+y
			prop.ang = pd.pos.ang
			SetColor( 255, 255, 255 )
			SetAlpha( 0.5 )
			prop.draw()
		Next
		reset_draw_state()
		
		'change modes detection
		If      KeyHit( KEY_1 ) Then mode = EDIT_LEVEL_MODE_BASIC ..
		Else If KeyHit( KEY_2 ) Then mode = EDIT_LEVEL_MODE_DIVIDERS ..
		Else If KeyHit( KEY_3 ) Then mode = EDIT_LEVEL_MODE_PATH_REGIONS ..
		Else If KeyHit( KEY_4 ) Then mode = EDIT_LEVEL_MODE_UNIT_FACTORY_SYSTEM ..
		Else If KeyHit( KEY_5 ) Then mode = EDIT_LEVEL_MODE_UNIT_FACTORY_DETAILS ..
		Else If KeyHit( KEY_6 ) Then mode = EDIT_LEVEL_MODE_IMMEDIATES ..
		Else If KeyHit( KEY_7 ) Then mode = EDIT_LEVEL_MODE_PROPS
		
		'If KeyHit( KEY_NUMADD )
		'	current_grid_size :+ 1
		'	If current_grid_size > grid_sizes.Length - 1 Then current_grid_size = 0
		'	gridsnap = grid_sizes[current_grid_size]
		'	x = gridsnap
		'	y = gridsnap
		'Else If KeyHit( KEY_NUMSUBTRACT )
		'	current_grid_size :- 1
		'	If current_grid_size < 0 Then current_grid_size = grid_sizes.Length - 1
		'	gridsnap = grid_sizes[current_grid_size]
		'	x = gridsnap
		'	y = gridsnap
		'End If
		
		'unconditionally draw level info panel and editor help
		info_x = round_to_nearest( SETTINGS_REGISTER.WINDOW_WIDTH.get(), gridsnap ) - 300; info_y = 0;
		SetAlpha( 0.75 )
		SetColor( 32, 32, 32 )
		DrawRect( info_x,info_y, 300,SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
		SetAlpha( 1 )
		SetColor( 196, 196, 196 )
		DrawLine( info_x,info_y, info_x,SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
		SetColor( 255, 255, 255 )
		info_x :+ 8; info_y :+ 10
		
		SetImageFont( normal_font )

		'mode help
		DrawText_with_shadow( ""+..
			EDIT_LEVEL_MODE_BASIC+":pan "+..
			EDIT_LEVEL_MODE_DIVIDERS+":split "+..
			EDIT_LEVEL_MODE_PATH_REGIONS+":fill "+..
			EDIT_LEVEL_MODE_UNIT_FACTORY_SYSTEM+","+EDIT_LEVEL_MODE_UNIT_FACTORY_DETAILS+":unit factories",..
			info_x,info_y ); info_y :+ line_h
		DrawText_with_shadow( ""+..
			EDIT_LEVEL_MODE_IMMEDIATES+":single units "+..
			EDIT_LEVEL_MODE_PROPS+":props",..
			info_x,info_y ); info_y :+ line_h 
		DrawText_with_shadow( "numpad +/- gridsnap zoom", info_x,info_y ); info_y :+ 2*line_h
		
		Select mode
			Case EDIT_LEVEL_MODE_BASIC
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_BASIC+" -> camera pan", info_x,info_y )
			Case EDIT_LEVEL_MODE_DIVIDERS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_DIVIDERS+" -> dividers", info_x,info_y )
			Case EDIT_LEVEL_MODE_PATH_REGIONS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PATH_REGIONS+" -> path regions", info_x,info_y )
			Case EDIT_LEVEL_MODE_UNIT_FACTORY_SYSTEM
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_UNIT_FACTORY_SYSTEM+" -> unit factory placement", info_x,info_y )
			Case EDIT_LEVEL_MODE_UNIT_FACTORY_DETAILS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_UNIT_FACTORY_DETAILS+" -> unit factory load-out", info_x,info_y )
			Case EDIT_LEVEL_MODE_IMMEDIATES
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PROPS+" -> immediate units", info_x,info_y )
			Case EDIT_LEVEL_MODE_PROPS
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PROPS+" -> props", info_x,info_y )
		End Select; info_y :+ 1.5*line_h
		
		'level name/title
		SetImageFont( bigger_font )
		DrawText_with_outline( lev.name, info_x, info_y )
		Local title_y% = info_y
		info_y :+ GetImageFont().Height() - 1
		
		'level info
		SetImageFont( normal_font )
		DrawText_with_shadow( "size: "+lev.width+" x "+lev.height, info_x,info_y ); info_y :+ 1.5*line_h
		DrawText_with_shadow( "pathing regions: "+lev.row_count*lev.col_count, info_x,info_y ); info_y :+ line_h
		DrawText_with_shadow( "unit factories: "+lev.unit_factories.Length, info_x,info_y ); info_y :+ line_h
		DrawText_with_shadow( "single units: "+lev.immediate_units.Length, info_x,info_y ); info_y :+ line_h
		
		If wait_for_user_select_option
			'/////////////////////////////////////
			'UI menu pop-up mode
			Local current_menu:TUIObject = choose_level_file_menu
			'keyboard input
			If KeyHit( KEY_UP ) Then current_menu.on_keyboard_up()
			If KeyHit( KEY_DOWN ) Then current_menu.on_keyboard_down()
			If KeyHit( KEY_LEFT ) Then current_menu.on_keyboard_left()
			If KeyHit( KEY_RIGHT ) Then current_menu.on_keyboard_right()
			If KeyHit( KEY_ENTER ) Then current_menu.on_keyboard_enter()
			If KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_BACKSPACE )
				wait_for_user_select_option = False
			End If
			'mouse input
			If Not mouse_idle Then current_menu.on_mouse_move( mouse.pos_x, mouse.pos_y )
			If mouse_clicked_1()
				Local action% = current_menu.on_mouse_click( mouse.pos_x, mouse.pos_y )
				If Not action Then wait_for_user_select_option = False
			End If
			If mouse_clicked_2() Then wait_for_user_select_option = False
			
			'draw
			current_menu.draw()
			
		Else
			'/////////////////////////////////////
			'normal input operation modes
			Local h% = 0
			'mode code (LOL! I rhymed) <-- WTF
			Select mode
				
				'____________________________________________________________________________________________________
				Case EDIT_LEVEL_MODE_BASIC
					DrawText_with_shadow( "click and drag to pan", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "enter to edit level name", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
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
						lev.name = get_input( lev.name,, info_x, title_y, input_font_big, screencap() )
					End If
				
				'____________________________________________________________________________________________________
				Case EDIT_LEVEL_MODE_DIVIDERS
					DrawText_with_shadow( "click to split", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "right-click to toggle axis", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "ctrl+click to drag", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "alt+click to join", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
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
					DrawText_with_shadow( "click block out area", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "right-click to clear area", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					SetColor( 255, 255, 255 )
					SetAlpha( 1 )
					If MouseDown( 1 )
						lev.set_path_region_from_xy( mouse.pos_x-x,mouse.pos_y-y, PATH_BLOCKED )
					Else If MouseDown( 2 )
						lev.set_path_region_from_xy( mouse.pos_x-x,mouse.pos_y-y, PATH_PASSABLE )
					End If
					
				'____________________________________________________________________________________________________
				Case EDIT_LEVEL_MODE_UNIT_FACTORY_SYSTEM
					DrawText_with_shadow( "click to create a factory", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "up/down to rotate", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "right-click to reset clipboard", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "ctrl+click & drag to move", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "ctrl+right-click to copy", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "ctrl+tab to auto-size cell", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "shift+click to set angle", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "alt+click to delete", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					gridsnap_mouse.x = round_to_nearest( mouse.pos_x-x, gridsnap )
					gridsnap_mouse.y = round_to_nearest( mouse.pos_y-y, gridsnap )
					new_unit_factory.pos.pos_x = gridsnap_mouse.x
					new_unit_factory.pos.pos_y = gridsnap_mouse.y
					Select new_unit_factory.alignment
						Case POLITICAL_ALIGNMENT.NONE
							SetColor( 255, 255, 255 )
						Case POLITICAL_ALIGNMENT.FRIENDLY
							SetColor( 64, 64, 255 )
						Case POLITICAL_ALIGNMENT.HOSTILE
							SetColor( 255, 64, 64 )
					End Select
					If Not any_modifiers
						If mouse_down_1 And Not MouseDown( 1 )
							closest_uf = new_unit_factory.clone()
							lev.add_unit_factory( closest_uf )
						End If
						If MouseDown( 2 )
							new_unit_factory = New UNIT_FACTORY_DATA
						End If
						If KeyHit( KEY_UP )
							new_unit_factory.pos.ang = ang_wrap( new_unit_factory.pos.ang + 45 )
						End If
						If KeyHit( KEY_DOWN )
							new_unit_factory.pos.ang = ang_wrap( new_unit_factory.pos.ang - 45 )
						End If
					Else
						If Not MouseDown( 1 )
							closest_uf = Null
						End If
						If closest_uf = Null
							For Local uf:UNIT_FACTORY_DATA = EachIn lev.unit_factories
								If closest_uf = Null Or ..
								closest_uf.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y )) > uf.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y ))
									closest_uf = uf
								End If
							Next
						End If
						If closest_uf <> Null
							If MouseDown( 1 )
								SetAlpha( 0.70 )
							Else
								SetAlpha( 0.35 )
							End If
							SetLineWidth( 2 )
							Select closest_uf.alignment
								Case POLITICAL_ALIGNMENT.NONE
									SetColor( 255, 255, 255 )
								Case POLITICAL_ALIGNMENT.FRIENDLY
									SetColor( 64, 64, 255 )
								Case POLITICAL_ALIGNMENT.HOSTILE
									SetColor( 255, 64, 64 )
							End Select
							DrawLine( MouseX(),MouseY(), closest_uf.pos.pos_x+x,closest_uf.pos.pos_y+y )
							If control
								If Not mouse_down_1 And MouseDown( 1 )
									drag_mouse_start = Copy_POINT( mouse ).to_cvec()
									drag_pos_start = Copy_POINT( closest_uf.pos )
								End If
								If MouseDown( 1 )
									closest_uf.pos.pos_x = round_to_nearest( drag_pos_start.pos_x + (mouse.pos_x - drag_mouse_start.x), gridsnap )
									closest_uf.pos.pos_y = round_to_nearest( drag_pos_start.pos_y + (mouse.pos_y - drag_mouse_start.y), gridsnap )
								End If
							Else If alt
								If mouse_down_1 And Not MouseDown( 1 )
									lev.remove_unit_factory( closest_uf )
								End If
							Else If shift
								If MouseDown( 1 )
									closest_uf.pos.ang = round_to_nearest( ang_wrap( closest_uf.pos.add_pos( x, y ).ang_to( mouse )), 45 )
								End If
							End If
							If control And KeyHit( KEY_TAB ) And closest_uf
								'find a spawner in the current cell
								Local uf_cell:CELL = lev.get_cell( closest_uf.pos.pos_x, closest_uf.pos.pos_y )
								'decide what size the cell should be based on orientation of spawner
								Local new_w%, new_h%, new_x%, new_y%, go% = True
								If closest_uf.pos.ang = 0 Or Abs( closest_uf.pos.ang ) = 180 'east/west
									new_w = 70
									new_h = 62
									If closest_uf.pos.ang = 0 'east
										new_x = 28
										new_y = 31
									Else 'west
										new_x = 52 - 10
										new_y = 31
									End If
								Else If Abs( closest_uf.pos.ang ) = 90 'north/south
									new_w = 62
									new_h = 70
									If closest_uf.pos.ang > 0 'south
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
									lev.resize_cell( uf_cell, new_w, new_h )
									'move the spawner to the correct spot in the cell
									closest_uf.pos.pos_x = lev.vertical_divs[uf_cell.col] + new_x
									closest_uf.pos.pos_y = lev.horizontal_divs[uf_cell.row] + new_y
								End If
							End If
							If MouseDown( 2 ) And Not mouse_down_2
								new_unit_factory = closest_uf.clone()
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
						Local p:POINT = new_unit_factory.pos
						SetAlpha( 0.50*alpha_mod )
						DrawOval( x+p.pos_x-spawn_point_preview_radius,y+p.pos_y-spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
						SetLineWidth( 2 )
						SetAlpha( 1.00*alpha_mod )
						DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x+spawn_point_preview_radius*Cos(p.ang),y+p.pos_y+spawn_point_preview_radius*Sin(p.ang) )
						SetAlpha( 0.5*alpha_mod )
						SetRotation( new_unit_factory.pos.ang )
						DrawImageRef( get_image( "door_fg" ), x+new_unit_factory.pos.pos_x, y+new_unit_factory.pos.pos_y )
						SetAlpha( 0.666*alpha_mod )
						SetRotation( 0 )
						SetScale( 1, 1 )
						Select new_unit_factory.alignment
							Case POLITICAL_ALIGNMENT.NONE
								SetColor( 255, 255, 255 )
							Case POLITICAL_ALIGNMENT.FRIENDLY
								SetColor( 64, 64, 255 )
							Case POLITICAL_ALIGNMENT.HOSTILE
								SetColor( 255, 64, 64 )
						End Select
						Local size% = 3, sep% = 1
						For Local r% = 0 To new_unit_factory.count_squads()-1
							For Local c% = 0 To new_unit_factory.count_squadmembers( r )-1
								DrawRect( x + p.pos_x - 10 - c*(size+sep), y + p.pos_y + 10 + r*(size+sep), size, size )
							Next
						Next
					End If
					If KeyHit( KEY_LEFT )
						new_unit_factory.pos.ang = ang_wrap( new_unit_factory.pos.ang - 45 )
					End If
					If KeyHit( KEY_RIGHT )
						new_unit_factory.pos.ang = ang_wrap( new_unit_factory.pos.ang + 45 )
					End If
					
				'____________________________________________________________________________________________________
				Case EDIT_LEVEL_MODE_UNIT_FACTORY_DETAILS
					DrawText_with_shadow( "hover to edit nearest", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "up/down to pick squad", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "left/right to select next unit", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "insert to add a new squad member", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "delete to remove a squad member", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "pgup/pgdn to change alignment", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "+/- to change wave (cascades)", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					DrawText_with_shadow( "enter to edit squad wait time", mouse.pos_x+10,mouse.pos_y+h ); h :+ line_h
					Local closest_uf:UNIT_FACTORY_DATA = Null
					For Local uf:UNIT_FACTORY_DATA = EachIn lev.unit_factories
						If closest_uf = Null Or ..
						closest_uf.pos.add_pos( x, y ).dist_to( Create_POINT( mouse.pos_x, mouse.pos_y )) > uf.pos.dist_to( Create_POINT( mouse.pos_x, mouse.pos_y ))
							closest_uf = uf
						End If
					Next
					Local uf:UNIT_FACTORY_DATA = closest_uf
					If uf <> Null
						SetLineWidth( 2 )
						SetAlpha( 0.6 )
						Select uf.alignment
							Case POLITICAL_ALIGNMENT.NONE
								SetColor( 255, 255, 255 )
							Case POLITICAL_ALIGNMENT.FRIENDLY
								SetColor( 64, 64, 255 )
							Case POLITICAL_ALIGNMENT.HOSTILE
								SetColor( 255, 64, 64 )
						End Select
						DrawLine( MouseX(),MouseY(), uf.pos.pos_x+x,uf.pos.pos_y+y )
						
						SetAlpha( 1 )
						SetColor( 255, 255, 255 )
						info_y :+ line_h
						DrawText_with_shadow( "current spawner", info_x,info_y ); info_y :+ line_h
						Select uf.alignment
							Case POLITICAL_ALIGNMENT.NONE
								SetColor( 255, 255, 255 )
							Case POLITICAL_ALIGNMENT.FRIENDLY
								SetColor( 64, 64, 255 )
							Case POLITICAL_ALIGNMENT.HOSTILE
								SetColor( 255, 64, 64 )
						End Select
						DrawText_with_shadow( "  alignment "+alignment_to_string(uf.alignment), info_x,info_y ); info_y :+ line_h
						SetColor( 255, 255, 255 )
						DrawText_with_shadow( "  squads "+uf.count_squads(), info_x,info_y ); info_y :+ line_h
						info_y :+ line_h
						Local cell_size% = 15
						If uf.count_squads() <> 0
							For Local r% = 0 To uf.count_squads()-1
								For Local c% = 0 To uf.count_squadmembers( r )-1
									Local ag:COMPLEX_AGENT = get_unit( uf.squads[r][c] )
									ag.alignment = uf.alignment
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
							If cursor > uf.count_squads() Then cursor = uf.count_squads()
						Else
							cursor = 0
						End If
						For Local r% = 0 To uf.count_squads()-1
							'wave index
							SetColor( 255, 255, 255 )
							DrawText_with_shadow( uf.wave_index[r], SETTINGS_REGISTER.WINDOW_WIDTH.get() - 68, info_y + r*cell_size + line_h/3 )
							'draw all delay times except the cursor
							If r <> cursor
								SetColor( 127, 127, 127 )
								DrawText_with_shadow( uf.delay_time[r], SETTINGS_REGISTER.WINDOW_WIDTH.get() - 50, info_y + r*cell_size + line_h/3 )
							End If
						Next
	
						If KeyHit( KEY_ENTER ) And cursor >= 0 And cursor < uf.count_squads()
							FlushKeys()
							uf.delay_time[cursor] = get_input( uf.delay_time[cursor],, SETTINGS_REGISTER.WINDOW_WIDTH.get() - 50, info_y + cursor*cell_size + line_h/3, input_font, screencap() ).ToInt()
						End If
						If cursor >= 0 And cursor < uf.count_squads()
							SetColor( 127, 127, 127 )
							DrawText_with_shadow( String.FromInt( uf.delay_time[cursor] ), SETTINGS_REGISTER.WINDOW_WIDTH.get() - 50, info_y + cursor*cell_size + line_h/3 )
						End If
						Local cursor_squadmembers% = uf.count_squadmembers( cursor )
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
							uf.alignment :- 1
							If uf.alignment < 0 Then uf.alignment = 2
						End If
						If KeyHit( KEY_PAGEDOWN )
							uf.alignment :+ 1
							If uf.alignment > 2 Then uf.alignment = 0
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
							If cursor < 0 Then cursor = uf.count_squads()
						End If
						If KeyHit( KEY_DOWN )
							cursor :+ 1
							If cursor > uf.count_squads() Then cursor = 0
						End If
						If KeyHit( KEY_INSERT )
							If cursor >= uf.squads.Length
								uf.add_new_squad()
							End If
							uf.add_new_squadmember( cursor, cursor_archetype )
						End If
						If KeyHit( KEY_DELETE )
							If cursor < uf.squads.Length
								uf.remove_last_squadmember( cursor )
							End If
						End If
						If KeyHit( KEY_EQUALS ) Or KeyHit( KEY_NUMADD )
							uf.wave_index[cursor] :+ 1
							For Local c% = cursor + 1 Until uf.wave_index.Length
								If uf.wave_index[c] < uf.wave_index[cursor]
									uf.wave_index[c] :+ 1
								Else
									Exit
								End If
							Next
						End If
						If (KeyHit( KEY_MINUS ) Or KeyHit( KEY_NUMSUBTRACT )) And uf.wave_index[cursor] > 0
							uf.wave_index[cursor] :- 1
							For Local c% = cursor - 1 To 0 Step -1
								If uf.wave_index[c] > uf.wave_index[cursor]
									uf.wave_index[c] :- 1
								Else
									Exit
								End If
							Next
						End If
					End If
				
				'____________________________________________________________________________________________________
				Case EDIT_LEVEL_MODE_IMMEDIATES, ..
				     EDIT_LEVEL_MODE_PROPS
					If mode = EDIT_LEVEL_MODE_PROPS
						DrawText_with_shadow( "click to add new", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_witH_shadow( "ctrl+click & drag to move", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_with_shadow( "alt+click to delete", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
					Else
						DrawText_with_shadow( "left/right to select unit", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_with_shadow( "up/down to rotate", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_with_shadow( "click to add new", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_witH_shadow( "ctrl+click & drag to move", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_with_shadow( "shift+click to set angle", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_with_shadow( "alt+click to delete", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
						DrawText_with_shadow( "[ctrl+]pgup/pgdn to change alignment", mouse.pos_x,mouse.pos_y+30+h ); h :+ line_h
					End If
					gridsnap_mouse.x = round_to_nearest( mouse.pos_x-x, gridsnap )
					gridsnap_mouse.y = round_to_nearest( mouse.pos_y-y, gridsnap )
					new_prop.pos.pos_x = gridsnap_mouse.x
					new_prop.pos.pos_y = gridsnap_mouse.y
					Select new_prop.alignment
						Case POLITICAL_ALIGNMENT.NONE
							SetColor( 255, 255, 255 )
						Case POLITICAL_ALIGNMENT.FRIENDLY
							SetColor( 64, 64, 255 )
						Case POLITICAL_ALIGNMENT.HOSTILE
							SetColor( 255, 64, 64 )
					End Select
					Drawtext_with_shadow( new_prop.archetype, mouse.pos_x, mouse.pos_y - 40 )
					If mode = EDIT_LEVEL_MODE_IMMEDIATES
						keys = unit_keys
						data = lev.immediate_units
					Else If mode = EDIT_LEVEL_MODE_PROPS
						keys = prop_keys
						data = lev.props
					End If
					'bounds correction due to shared indices (sigh)
					If new_prop_archetype < 0 Then new_prop_archetype = keys.Length - 1
					If new_prop_archetype > keys.Length - 1 Then new_prop_archetype = 0
					new_prop.archetype = keys[ new_prop_archetype ]
					'input
					If Not any_modifiers
						If mouse_down_1 And Not MouseDown( 1 )
							If mode = EDIT_LEVEL_MODE_IMMEDIATES
								lev.add_immediate_unit( new_prop )
							Else If mode = EDIT_LEVEL_MODE_PROPS
								lev.add_prop( new_prop )
							End If
							new_prop = New ENTITY_DATA
						End If
						If KeyHit( KEY_LEFT )
							new_prop_archetype :- 1
							If new_prop_archetype < 0 Then new_prop_archetype = keys.Length - 1
							new_prop.archetype = keys[ new_prop_archetype ]
						End If
						If KeyHit( KEY_RIGHT )
							new_prop_archetype :+ 1
							If new_prop_archetype > keys.Length - 1 Then new_prop_archetype = 0
							new_prop.archetype = keys[ new_prop_archetype ]
						End If
						If KeyDown( KEY_UP )
							new_prop.pos.ang = ang_wrap( new_prop.pos.ang + 2 )
						End If
						If KeyDown( KEY_DOWN )
							new_prop.pos.ang = ang_wrap( new_prop.pos.ang - 2 )
						End If
						If KeyHit( KEY_PAGEUP )
							new_prop.alignment :- 1
							If new_prop.alignment < 0 Then new_prop.alignment = 2
						End If
						If KeyHit( KEY_PAGEDOWN )
							new_prop.alignment :+ 1
							If new_prop.alignment > 2 Then new_prop.alignment = 0
						End If
						If mode = EDIT_LEVEL_MODE_IMMEDIATES
							Local unit:COMPLEX_AGENT = get_unit( new_prop.archetype )
							If unit
								unit.alignment = new_prop.alignment
								unit.pos_x = gridsnap_mouse.x+x
								unit.pos_y = gridsnap_mouse.y+y
								unit.ang = new_prop.pos.ang
								Select unit.alignment
									Case POLITICAL_ALIGNMENT.NONE
										SetColor( 255, 255, 255 )
									Case POLITICAL_ALIGNMENT.FRIENDLY
										SetColor( 64, 64, 255 )
									Case POLITICAL_ALIGNMENT.HOSTILE
										SetColor( 255, 64, 64 )
								End Select
								unit.scale_all( 2.0 )
								unit.snap_all_turrets()
								unit.update()
								unit.draw( 0.33333, 2.0 )
							End If
						Else If mode = EDIT_LEVEL_MODE_PROPS
							Local prop:AGENT = get_prop( new_prop.archetype )
							If prop
								prop.pos_x = gridsnap_mouse.x+x
								prop.pos_y = gridsnap_mouse.y+y
								SetColor( 255, 255, 255 )
								SetAlpha( 0.33333 )
								prop.draw()
							End If
						End If
					Else
						If Not MouseDown( 1 )
							closest_pd = Null
						End If
						If closest_pd = Null
							For Local pd:ENTITY_DATA = EachIn data
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
								If KeyHit( KEY_PAGEUP )
									closest_pd.alignment :- 1
									If closest_pd.alignment < 0 Then closest_pd.alignment = 2
								End If
								If KeyHit( KEY_PAGEDOWN )
									closest_pd.alignment :+ 1
									If closest_pd.alignment > 2 Then closest_pd.alignment = 0
								End If
							Else If alt
								If mouse_down_1 And Not MouseDown( 1 )
									If mode = EDIT_LEVEL_MODE_IMMEDIATES
										lev.remove_immediate_unit( closest_pd )
									Else If mode = EDIT_LEVEL_MODE_PROPS
										lev.remove_prop( closest_pd )
									End If
								End If
							Else If shift
								If MouseDown( 1 )
									closest_pd.pos.ang = closest_pd.pos.ang_to( mouse.add_pos( x, y ))
									new_prop.pos.ang = closest_pd.pos.ang
								End If
							End If
						End If
					End If
					
			End Select
		
		End If
		
		'mouse buttons
		mouse_state_update()
		
		'instaquit
		escape_key_update()
		draw_instaquit_progress()
		
		Flip( 1 )
	Until escape_key_release() Or KeyHit( KEY_BACKSPACE )
		
	FlushKeys()
	FlushMouse()
End Function

'______________________________________________________________________________
Function alignment_to_string$( alignment% )
	Select alignment
		Case POLITICAL_ALIGNMENT.NONE
			Return "{none}"
		Case POLITICAL_ALIGNMENT.FRIENDLY
			Return "{friendly}"
		Case POLITICAL_ALIGNMENT.HOSTILE
			Return "{hostile}"
	End Select
End Function

'______________________________________________________________________________
Function cmdex_load_level_editor_cache( item:Object )
	Local path$ = String(item)	
	If path
		wait_for_user_select_option = False
		level_editor_cache = load_level( path )
	End If
End Function





