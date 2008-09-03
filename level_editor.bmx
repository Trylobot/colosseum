Rem
	level_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const spawn_point_preview_radius% = 10
Const max_level_name_length% = 22

Const EDIT_LEVEL_MODE_NONE% = 0
Const EDIT_LEVEL_MODE_RESIZE% = 1
Const EDIT_LEVEL_MODE_DIVIDER% = 2
Const EDIT_LEVEL_MODE_PATHING% = 3
Const EDIT_LEVEL_MODE_SPAWNER_NEW% = 4
Const EDIT_LEVEL_MODE_SPAWNER_EDIT% = 5

Function edit_level:LEVEL( lev:LEVEL )
	
	Local gridsnap% = 5
	Local mode% = EDIT_LEVEL_MODE_RESIZE
	Local FLAG_text_mode% = False
	Local x% = gridsnap, y% = gridsnap
	Local info_x%, info_y%
	Local mouse_down_1% = False, mouse_down_2% = False
	Local new_spawner:SPAWNER = New SPAWNER
	Local cursor% = 0
	Local cursor_archetype% = enemy_index_start
	Local kb_handler:CONSOLE = New CONSOLE
	Local sp_delay_time$
	
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
		
		'change modes detection
		If Not FLAG_text_mode
			If      KeyHit( KEY_1 ) Then mode = EDIT_LEVEL_MODE_RESIZE ..
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
		
		DrawText( ""+..
			EDIT_LEVEL_MODE_RESIZE+":resize/pan "+..
			EDIT_LEVEL_MODE_DIVIDER+":split "+..
			EDIT_LEVEL_MODE_PATHING+":block "+..
			EDIT_LEVEL_MODE_SPAWNER_NEW+","+EDIT_LEVEL_MODE_SPAWNER_EDIT+":spawners",..
			info_x,info_y ); info_y :+ line_h
		
		Select mode
			Case EDIT_LEVEL_MODE_RESIZE
				DrawText( "mode "+EDIT_LEVEL_MODE_RESIZE+" -> camera pan", info_x,info_y )
				DrawText( "click and drag to resize", mouse.x+10,mouse.y )
				DrawText( "right-click and drag to pan", mouse.x+10,mouse.y+10 )
				DrawText( "enter to edit level title", mouse.x+10,mouse.y+20 )
			Case EDIT_LEVEL_MODE_DIVIDER
				DrawText( "mode "+EDIT_LEVEL_MODE_DIVIDER+" -> dividers vertical/horizontal", info_x,info_y )
				DrawText( "click to split vertically", mouse.x+10,mouse.y )
				DrawText( "right-click to split horizontally", mouse.x+10,mouse.y+10 )
				DrawText( "(+ctrl) to un-split", mouse.x+10,mouse.y+20 )
			Case EDIT_LEVEL_MODE_PATHING
				DrawText( "mode "+EDIT_LEVEL_MODE_PATHING+" -> pathing blocked/passable", info_x,info_y )
				DrawText( "click block out area", mouse.x+10,mouse.y )
				DrawText( "right-click to clear area", mouse.x+10,mouse.y+10 )
			Case EDIT_LEVEL_MODE_SPAWNER_NEW
				DrawText( "mode "+EDIT_LEVEL_MODE_SPAWNER_NEW+" -> spawners add/remove", info_x,info_y )
				DrawText( "click to add spawner", mouse.x+10,mouse.y )
				DrawText( "(+ctrl) to delete", mouse.x+10,mouse.y+10 )
				DrawText( "left/right to change angle", mouse.x+10,mouse.y+20 )
			Case EDIT_LEVEL_MODE_SPAWNER_EDIT
				DrawText( "mode "+EDIT_LEVEL_MODE_SPAWNER_EDIT+" -> spawners edit", info_x,info_y )
				DrawText( "hover to edit nearest spawner", mouse.x+10,mouse.y )
				DrawText( "up/down to select squad", mouse.x+10,mouse.y+10 )
				DrawText( "left/right to change enemy type", mouse.x+10,mouse.y+20 )
				DrawText( "insert/delete to add/remove squad member", mouse.x+10,mouse.y+30 )
				DrawText( "home/end to change class", mouse.x+10,mouse.y+40 )
				DrawText( "pgup/pgdn to change alignment", mouse.x+10,mouse.y+50 )
				DrawText( "enter to edit wait time", mouse.x+10,mouse.y+60 )
		End Select; info_y :+ line_h
		DrawText( "numpad +/- to change grid size", info_x,info_y ); info_y :+ 2*line_h
		
		SetImageFont( bigger_font )
		DrawText_with_glow( lev.name, info_x, info_y )
		Local title_y% = info_y
		info_y :+ GetImageFont().Height() - 1
		
		SetImageFont( normal_font )
		DrawText( "pathing regions: "+lev.row_count*lev.col_count, info_x,info_y ); info_y :+ line_h
		DrawText( "spawners: "+lev.spawners.Length, info_x,info_y ); info_y :+ line_h
		
		'____________________________________________
		'behavioral switch based on current mode
		Select mode
			
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_RESIZE
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If MouseDown( 2 )
					'pan
					x = round_to_nearest( mouse.x - lev.width, gridsnap )
					y = round_to_nearest( mouse.y - lev.height, gridsnap )
				Else If MouseDown( 1 )
					'resize
					lev.resize( round_to_nearest( mouse.x - x, gridsnap ), round_to_nearest( mouse.y - y, gridsnap )) 
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
									
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_PATHING
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				If MouseDown( 1 )
					lev.set_path_region( mouse.x-x,mouse.y-y, PATH_BLOCKED )
				Else If MouseDown( 2 )
					lev.set_path_region( mouse.x-x,mouse.y-y, PATH_PASSABLE )
				End If
				
			'____________________________________________________________________________________________________
			Case EDIT_LEVEL_MODE_SPAWNER_NEW
				mouse.x = round_to_nearest( mouse.x-x, gridsnap )
				mouse.y = round_to_nearest( mouse.y-y, gridsnap )
				new_spawner.pos.pos_x = mouse.x
				new_spawner.pos.pos_y = mouse.y
				Select new_spawner.alignment
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
						closest_sp.pos.dist_to( Create_POINT( mouse.x, mouse.y )) > sp.pos.dist_to( Create_POINT( mouse.x, mouse.y ))
							closest_sp = sp
						End If
					Next
					If closest_sp <> Null
						SetLineWidth( 2 )
						SetAlpha( 0.6 )
						Select closest_sp.alignment
							Case ALIGNMENT_NONE
								SetColor( 255, 255, 255 )
							Case ALIGNMENT_FRIENDLY
								SetColor( 64, 64, 255 )
							Case ALIGNMENT_HOSTILE
								SetColor( 255, 64, 64 )
						End Select
						DrawLine( MouseX(),MouseY(), closest_sp.pos.pos_x+x,closest_sp.pos.pos_y+y )
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
				Local alpha_mod#
				If MouseDown( 1 )
					mouse_down_1 = True
					alpha_mod = 1.0
				Else
					mouse_down_1 = False
					alpha_mod = 0.50
				End If
				If Not (KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL ))
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
			Case EDIT_LEVEL_MODE_SPAWNER_EDIT
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
								ag.draw( ,,,, 0.75 )
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
						ag.draw( ,,, 0.5 + Sin(now() Mod 360), 0.75 )
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
				
		End Select
		
		Flip( 1 )
	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
	
	Return lev
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
