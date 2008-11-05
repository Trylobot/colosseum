Rem
	level_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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
	Local new_prop:PROP_DATA = New PROP_DATA

	Local nearest_div%
	Local nearest_div_dist%
	Local nearest_div_axis%
	
	Local gridsnap% = 5
	Local mode% = EDIT_LEVEL_MODE_BASIC
	Local FLAG_text_mode%
	Local x% = gridsnap, y% = gridsnap
	Local info_x%, info_y%
	Local mouse_down_1%, mouse_down_2%
	Local control%, alt%, shift%, any_modifiers%
	Local divider_axis% = LINE_TYPE_VERTICAL
	
	Local line_h% = GetImageFont().Height() - 1
	Local cursor% = 0
	Local cursor_archetype% = enemy_index_start
	Local kb_handler:CONSOLE = New CONSOLE
	Local sp_delay_time$
	
	Local normal_font:TImageFont = get_font( "consolas_12" )
	Local bigger_font:TImageFont = get_font( "consolas_bold_24" )
	SetImageFont( normal_font )
	
	Repeat
		Cls
		
		'copied from input.bmx
		mouse.x = MouseX()
		mouse.y = MouseY()

		SetColor( 255, 255, 255 )
		SetLineWidth( 1 )
		SetAlpha( 0.5 )
		'mouse delta line
		DrawLine( mouse.x - mouse_delta.x, mouse.y - mouse_delta.y, mouse.x, mouse.y )		
		
		'draw the gridsnap lines
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
			Select sp.alignment
				Case ALIGNMENT_NONE
					SetColor( 255, 255, 255 )
				Case ALIGNMENT_FRIENDLY
					SetColor( 64, 64, 255 )
				Case ALIGNMENT_HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			Local p:POINT = sp.pos
			SetAlpha( 0.50 )
			DrawOval( x+p.pos_x-spawn_point_preview_radius,y+p.pos_y-spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
			SetLineWidth( 2 )
			SetAlpha( 1 )
			DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x + spawn_point_preview_radius*Cos(p.ang),y+p.pos_y + spawn_point_preview_radius*Sin(p.ang) )
		Next
		
		'draw the props
		For Local pd:PROP_DATA = EachIn lev.props
			Local prop:AGENT = get_prop( pd.archetype )
			prop.pos_x = pd.pos.pos_x
			prop.pos_y = pd.pos.pos_y
			prop.ang = pd.pos.ang
			SetAlpha( 0.35 )
			prop.draw()
		Next
		
		'change modes detection
		If Not FLAG_text_mode
			If      KeyHit( KEY_1 ) Then mode = EDIT_LEVEL_MODE_BASIC ..
			Else If KeyHit( KEY_2 ) Then mode = EDIT_LEVEL_MODE_DIVIDERS ..
			Else If KeyHit( KEY_3 ) Then mode = EDIT_LEVEL_MODE_PATH_REGIONS ..
			Else If KeyHit( KEY_4 ) Then mode = EDIT_LEVEL_MODE_SPAWNER_SYSTEM ..
			Else If KeyHit( KEY_5 ) Then mode = EDIT_LEVEL_MODE_SPAWNER_DETAILS
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
		
		'mode help
		DrawText( ""+..
			EDIT_LEVEL_MODE_BASIC+":pan "+..
			EDIT_LEVEL_MODE_DIVIDERS+":split "+..
			EDIT_LEVEL_MODE_PATH_REGIONS+":fill "+..
			EDIT_LEVEL_MODE_SPAWNER_SYSTEM+","+EDIT_LEVEL_MODE_SPAWNER_DETAILS+":spawners"+..
			EDIT_LEVEL_MODE_PROPS+":props",..
			info_x,info_y ); info_y :+ line_h
		
		'mode help (context-specific)
		Select mode
			Case EDIT_LEVEL_MODE_BASIC
				DrawText( "mode "+EDIT_LEVEL_MODE_BASIC+" -> camera pan", info_x,info_y )
				DrawText( "click and drag to pan", mouse.x+10,mouse.y )
				DrawText( "enter to edit level name", mouse.x+10,mouse.y+10 )
			Case EDIT_LEVEL_MODE_DIVIDERS
				DrawText( "mode "+EDIT_LEVEL_MODE_DIVIDERS+" -> dividers", info_x,info_y )
				DrawText( "click to split", mouse.x+10,mouse.y )
				DrawText( "right-click to toggle axis", mouse.x+10,mouse.y+10 )
				DrawText( "ctrl+click to drag", mouse.x+10,mouse.y+20 )
				DrawText( "alt+click to join", mouse.x+10,mouse.y+30 )
			Case EDIT_LEVEL_MODE_PATH_REGIONS
				DrawText( "mode "+EDIT_LEVEL_MODE_PATH_REGIONS+" -> path regions", info_x,info_y )
				DrawText( "click block out area", mouse.x+10,mouse.y )
				DrawText( "right-click to clear area", mouse.x+10,mouse.y+10 )
			Case EDIT_LEVEL_MODE_SPAWNER_SYSTEM
				DrawText( "mode "+EDIT_LEVEL_MODE_SPAWNER_SYSTEM+" -> spawner system", info_x,info_y )
				DrawText( "click to add new", mouse.x+10,mouse.y )
				DrawText( "ctrl+click & drag to move", mouse.x+10,mouse.y+10 )
				DrawText( "alt+click to delete", mouse.x+10,mouse.y+20 )
				DrawText( "shift+click to set angle", mouse.x+10,mouse.y+30 )
			Case EDIT_LEVEL_MODE_SPAWNER_DETAILS
				DrawText( "mode "+EDIT_LEVEL_MODE_SPAWNER_DETAILS+" -> spawner details", info_x,info_y )
				DrawText( "hover to edit nearest spawner", mouse.x+10,mouse.y )
				DrawText( "up/down to select squad", mouse.x+10,mouse.y+10 )
				DrawText( "left/right to change enemy type", mouse.x+10,mouse.y+20 )
				DrawText( "insert/delete to add/remove squad member", mouse.x+10,mouse.y+30 )
				DrawText( "home/end to change class", mouse.x+10,mouse.y+40 )
				DrawText( "pgup/pgdn to change alignment", mouse.x+10,mouse.y+50 )
				DrawText( "enter to edit wait time", mouse.x+10,mouse.y+60 )
			Case EDIT_LEVEL_MODE_PROPS
				DrawText( "mode "+EDIT_LEVEL_MODE_PROPS+" -> props", info_x,info_y )
				DrawText( "click to add new", mouse.x+10,mouse.y )
				'...
		End Select; info_y :+ line_h
		DrawText( "numpad +/- gridsnap zoom", info_x,info_y ); info_y :+ 2*line_h
		
		'level name/title
		SetImageFont( bigger_font )
		DrawText_with_glow( lev.name, info_x, info_y )
		Local title_y% = info_y
		info_y :+ GetImageFont().Height() - 1
		
		'level info
		SetImageFont( normal_font )
		DrawText( "pathing regions: "+lev.row_count*lev.col_count, info_x,info_y ); info_y :+ line_h
		DrawText( "spawners: "+lev.spawners.Length, info_x,info_y ); info_y :+ line_h
		
		'modifier keys
		control = KeyDown( KEY_LCONTROL ) | KeyDown( KEY_RCONTROL )
		alt =     KeyDown( KEY_LALT )     | KeyDown( KEY_RALT )
		shift =   KeyDown( KEY_LSHIFT )   | KeyDown( KEY_RSHIFT )
		any_modifiers = control | alt | shift
		
		'mode code (LOL! I rhymed) <-- WTF
		Select mode
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_BASIC
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				'pan
				If MouseDown( 1 )
					If Not mouse_down_1
						drag_mouse_start = mouse.clone()
						drag_pos_start = Create_POINT( x, y )
					Else
						x = round_to_nearest( drag_pos_start.pos_x + (mouse.x - drag_mouse_start.x), gridsnap )
						y = round_to_nearest( drag_pos_start.pos_y + (mouse.y - drag_mouse_start.y), gridsnap )
					End If
				End If
				If KeyHit( KEY_ENTER )
					FLAG_text_mode = Not FLAG_text_mode
					FlushKeys()
				End If
				If FLAG_text_mode
					lev.name = kb_handler.update( lev.name, max_level_name_length )
					SetAlpha( 0.5 + Sin(now() Mod 360) )
					SetImageFont( bigger_font )
					DrawText( "|", info_x + TextWidth( lev.name ) - 2, title_y )
					SetImageFont( normal_font )
					SetAlpha( 1 )
				End If
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_DIVIDERS
				gridsnap_mouse.x = round_to_nearest( mouse.x, gridsnap )
				gridsnap_mouse.y = round_to_nearest( mouse.y, gridsnap )
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
						If Not mouse_down_1
							'no need to record this event
						Else
							'drag nearest div (do not recalculate)
							If nearest_div_axis = LINE_TYPE_VERTICAL
								lev.set_divider( LINE_TYPE_VERTICAL, nearest_div, gridsnap_mouse.x-x - nearest_div_dist )
							Else If nearest_div_axis = LINE_TYPE_HORIZONTAL
								lev.set_divider( LINE_TYPE_HORIZONTAL, nearest_div, gridsnap_mouse.y-y - nearest_div_dist )
							End If
						End If
					Else
						'recalculate nearest div
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
					Else If nearest_div_axis = LINE_TYPE_HORIZONTAL
						DrawLine( x,lev.horizontal_divs[nearest_div]+y, x+lev.width,lev.horizontal_divs[nearest_div]+y )
						DrawLine( gridsnap_mouse.x,gridsnap_mouse.y, gridsnap_mouse.x,lev.horizontal_divs[nearest_div]+y )
					End If
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
					Else If divider_axis = LINE_TYPE_HORIZONTAL
						DrawLine( x,gridsnap_mouse.y, x+lev.width,gridsnap_mouse.y )
					End If
				End If
									
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_PATH_REGIONS
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If MouseDown( 1 )
					lev.set_path_region_from_xy( mouse.x-x,mouse.y-y, PATH_BLOCKED )
				Else If MouseDown( 2 )
					lev.set_path_region_from_xy( mouse.x-x,mouse.y-y, PATH_PASSABLE )
				End If
				
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_SPAWNER_SYSTEM
				gridsnap_mouse.x = round_to_nearest( mouse.x-x, gridsnap )
				gridsnap_mouse.y = round_to_nearest( mouse.y-y, gridsnap )
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
						lev.add_spawner( new_spawner.clone() )
					End If
				Else
					Local closest_sp:SPAWNER = Null
					For Local sp:SPAWNER = EachIn lev.spawners
						If closest_sp = Null Or ..
						closest_sp.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y )) > sp.pos.dist_to( Create_POINT( gridsnap_mouse.x, gridsnap_mouse.y ))
							closest_sp = sp
						End If
					Next
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
								drag_mouse_start = mouse.clone()
								drag_pos_start = Copy_POINT( closest_sp.pos )
							End If
							If MouseDown( 1 )
								closest_sp.pos.pos_x = round_to_nearest( drag_pos_start.pos_x + (mouse.x - drag_mouse_start.x), gridsnap )
								closest_sp.pos.pos_y = round_to_nearest( drag_pos_start.pos_y + (mouse.y - drag_mouse_start.y), gridsnap )
							End If
						Else If alt
							If mouse_down_1 And Not MouseDown( 1 )
								lev.remove_spawner( closest_sp )
							End If
						Else If shift
							If MouseDown( 1 )
								closest_sp.pos.ang = round_to_nearest( ang_wrap( closest_sp.pos.ang_to_cVEC( mouse )), 45 )
							End If
						End If
					End If
				End If
				Local alpha_mod#
				If MouseDown( 1 )
					alpha_mod = 1.0
				Else
					alpha_mod = 0.50
				End If
				If Not any_modifiers
					Local p:POINT = new_spawner.pos
					SetAlpha( 0.50*alpha_mod )
					DrawOval( x+p.pos_x-spawn_point_preview_radius,y+p.pos_y-spawn_point_preview_radius, 2*spawn_point_preview_radius,2*spawn_point_preview_radius )
					SetLineWidth( 2 )
					SetAlpha( 1.00*alpha_mod )
					DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x+spawn_point_preview_radius*Cos(p.ang),y+p.pos_y+spawn_point_preview_radius*Sin(p.ang) )
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
					closest_sp.pos.dist_to( Create_POINT( mouse.x, mouse.y )) > sp.pos.dist_to( Create_POINT( mouse.x, mouse.y ))
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
					DrawText( "current spawner", info_x,info_y ); info_y :+ line_h
					DrawText( "  class "+class_to_string(sp.class), info_x,info_y ); info_y :+ line_h
					DrawText( "  alignment "+alignment_to_string(sp.alignment), info_x,info_y ); info_y :+ line_h
					DrawText( "  squads "+sp.count_squads(), info_x,info_y ); info_y :+ line_h
					info_y :+ line_h
					Local cell_size% = 15
					If sp.count_squads() <> 0
						For Local r% = 0 To sp.count_squads()-1
							For Local c% = 0 To sp.count_squadmembers( r )-1
								Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[sp.squads[r][c]] ))
								ag.pos_x = info_x + cell_size + c*cell_size - cell_size/2
								ag.pos_y = info_y + cell_size + r*cell_size - cell_size/2
								ag.ang = -90
								ag.snap_all_turrets()
								ag.update()
								ag.draw( ,,,, 0.75, True )
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
							DrawText( sp.delay_time[r], window_w - 50, info_y + r*cell_size + line_h/3 )
						End If
					Next

					If KeyHit( KEY_ENTER ) And cursor >= 0 And cursor < sp.count_squads()
						FLAG_text_mode = Not FLAG_text_mode
						FlushKeys()
						If FLAG_text_mode
							sp_delay_time = "" 'String.FromInt( sp.delay_time[cursor] )
						Else 'Not FLAG_text_mode
							sp.delay_time[cursor] = sp_delay_time.ToInt()
						End If
					End If
					If FLAG_text_mode And cursor >= 0 And cursor < sp.count_squads()
						sp_delay_time = kb_handler.update( sp_delay_time )
						DrawText( sp_delay_time, window_w - 50, info_y + cursor*cell_size + line_h/3 )
						SetAlpha( 0.5 + Sin(now() Mod 360) )
						DrawText( "|", window_w - 50 + TextWidth( sp_delay_time ) - 2, info_y + cursor*cell_size + line_h/3 )
						SetAlpha( 1 )
					Else 'Not FLAG_text_mode
						If cursor >= 0 And cursor < sp.count_squads()
							DrawText( String.FromInt( sp.delay_time[cursor] ), window_w - 50, info_y + cursor*cell_size + line_h/3 )
						End If
						Local cursor_squadmembers% = sp.count_squadmembers( cursor )
						Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[cursor_archetype] ))
						ag.pos_x = info_x + cell_size + cursor_squadmembers*cell_size - cell_size/2
						ag.pos_y = info_y + cell_size + cursor*cell_size - cell_size/2
						ag.ang = -90
						ag.snap_all_turrets()
						ag.update()
						ag.draw( ,,, 0.5 + Sin(now() Mod 360), 0.75, True )
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
							cursor_archetype :- 1
							If cursor_archetype < enemy_index_start Then cursor_archetype = complex_agent_archetype.Length-1
						End If
						If KeyHit( KEY_RIGHT )
							cursor_archetype :+ 1
							If cursor_archetype > complex_agent_archetype.Length-1 Then cursor_archetype = enemy_index_start
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
				End If
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_PROPS
				gridsnap_mouse.x = round_to_nearest( mouse.x-x, gridsnap )
				gridsnap_mouse.y = round_to_nearest( mouse.y-y, gridsnap )
				new_prop.pos.pos_x = gridsnap_mouse.x
				new_prop.pos.pos_y = gridsnap_mouse.y
				
				
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

		Flip( 1 )
	Until KeyHit( KEY_ESCAPE )
	
End Function

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
