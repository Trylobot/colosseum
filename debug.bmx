Rem
	test.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

?Debug
Global sx%, sy%, h%, px#, py#
'Global maus_x#, maus_y#, speed# = 1, r#, a#
Global wait_ts%, wait_time%, r%, c%, mouse:CELL
Const PATH_UNSET% = 1000
Global path_type% = PATH_UNSET, mouse_path_type%
Global db_path:TList

'______________________________________________________________________________
Function show_db_path()
	If db_path <> Null
		Local v0:cVEC = Null, v1:cVEC = Null
		For Local v1:cVEC = EachIn db_path
			If v0 <> Null
				DrawLine( v0.x+arena_offset,v0.y+arena_offset, v1.x+arena_offset,v1.y+arena_offset )
			Else
				v0 = New cVEC
			End If
			v0.x = v1.x; v0.y = v1.y
		Next
	End If
	'start and goal
	If global_start <> Null
		SetColor( 64, 255, 64 ); SetAlpha( 1 )
		DrawRect( global_start.col*cell_size + 1+arena_offset, global_start.row*cell_size + 1+arena_offset, cell_size - 2, cell_size - 2 )
	End If
	If global_goal <> Null
		SetColor( 64, 64, 255 ); SetAlpha( 1 )
		DrawRect( global_goal.col*cell_size + 1+arena_offset, global_goal.row*cell_size + 1+arena_offset, cell_size - 2, cell_size - 2 )
	End If
End Function

Function debug_ts( message$ )
	Print( String.FromInt( now() ) + ":" + message )
End Function
Function debug_drawtext( message$ )
	DrawText( message, sx, sy )
	sy :+ h
End Function

Function debug_heap( message$ = "" )
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	Return
	
	Local pq:PATH_QUEUE = pathing.potential_paths
	Local tree:CELL[] = pathing.potential_paths.binary_tree

	wait_ts = now()
	'If KeyDown( KEY_F3 ) Then wait_time = 0 Else wait_time = 500
	wait_time = 500

	While ((now() - wait_ts) <= wait_time) And Not KeyHit( KEY_F3 )
		
		If KeyHit( KEY_ESCAPE ) Then End
		If KeyDown( KEY_F4 ) Then wait_ts = now()
		
		Cls
		
		sx = 3; sy = 3
		
		'draw optional message
		SetColor( 127, 127, 255 ); SetAlpha( 1 )
		SetImageFont( consolas_normal_12 )
		DrawText( message, sx, sy ); sy :+ 11

		SetImageFont( consolas_normal_10 )
		If tree[0] = Null Then SetColor( 64, 64, 64 ) ..
		Else                   SetColor( 255, 255, 255 )
		DrawText( heap_info( 0 ), sx, sy )
		draw_heap( 0 )
		
		Flip
		
	End While
End Function
Function draw_heap( i% )
	Local pq:PATH_QUEUE = pathing.potential_paths
	Local tree:CELL[] = pathing.potential_paths.binary_tree
	If i < pq.item_count + 4
		
		If pq.left_child_i( i ) < pq.item_count + 4
			sx :+ 8; sy :+ 9
			If tree[pq.left_child_i( i )] = Null Then                       SetColor( 64, 64, 64 ) ..
			Else If f_less_than( tree[i], tree[pq.left_child_i( i )] ) Then SetColor( 255, 255, 255 ) ..
			Else                                                            SetColor( 255, 127, 127 )
			DrawText( heap_info( pq.left_child_i( i )), sx, sy )
			draw_heap( pq.left_child_i( i ))
			
			If pq.right_child_i( i ) < pq.item_count + 4
				sy :+ 9
				If tree[pq.right_child_i( i )] = Null Then                       SetColor( 64, 64, 64 ) ..
				Else If f_less_than( tree[i], tree[pq.right_child_i( i )] ) Then SetColor( 255, 255, 255 ) ..
				Else                                                             SetColor( 255, 127, 127 )
				DrawText( heap_info( pq.right_child_i( i )), sx, sy )
				draw_heap( pq.right_child_i( i ))
			End If
			
			sx :- 8
			
		End If
		
	End If
End Function
Function heap_info$( i% )
	Local tree:CELL[] = pathing.potential_paths.binary_tree
	If tree[i] <> Null
		Return "[" + i + "]" + " (" + tree[i].row + "," + tree[i].col + ")" + " f:" + Int( pathing.f( tree[i] ))
	Else 'tree[i] == Null
		Return "[" + i + "]" + " null"
	End If
End Function

'______________________________________________________________________________
'F4 to path from player to mouse; hold F4 to pause; hold F3 to fast-forward
Function debug_pathing( message$ = "", done% = False )
	SetOrigin( arena_offset, arena_offset )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	wait_ts = now()
	If KeyDown( KEY_F3 ) Then wait_time = 0 Else wait_time = 500

	While (((now() - wait_ts) <= wait_time) And (Not done)) ..
	Or (done And Not KeyHit( KEY_F2 ))
		
		If KeyHit( KEY_ESCAPE ) Then End
		If KeyDown( KEY_F4 ) Then wait_ts = now()
		
		mouse = containing_cell( MouseX() - arena_offset, MouseY() - arena_offset )
		If KeyDown( KEY_F5 )
			pathing.set_grid( mouse, PATH_BLOCKED )
		Else If KeyDown( KEY_F6 )
			pathing.set_grid( mouse, PATH_PASSABLE )
		End If
		
		Cls
		
		'draw debug help
		SetColor( 127, 127, 255 ); SetAlpha( 1 )
		SetImageFont( consolas_normal_12 )
		DrawText( "set_goal,find_path:F4  pause:F4/faster:F3  block:F5  clear:F6", 3, -26 )
		'draw pathing_grid cell border lines
		SetLineWidth( 1 ); SetColor( 127, 127, 127 ); SetAlpha( 0.75 )
		For r = 0 To pathing_grid_h
			DrawLine( 0, r*cell_size, pathing_grid_w*cell_size, r*cell_size )
		Next
		For c = 0 To pathing_grid_w
			DrawLine( c*cell_size, 0, c*cell_size, pathing_grid_h*cell_size )
		Next
		Local cursor:CELL = New CELL
		For cursor.row = 0 To pathing_grid_h - 1
			For cursor.col = 0 To pathing_grid_w - 1
				'draw pathing_grid contents
				SetColor( 255, 255, 255 ); SetAlpha( 0.85 )
				If pathing.grid( cursor ) = PATH_BLOCKED Then ..
					DrawRect( cursor.col*cell_size + 1, cursor.row*cell_size + 1, cell_size - 2, cell_size - 2 )
			Next
		Next
		For cursor = EachIn pathing.pathing_visited_list
			'draw pathing_came_from
			SetLineWidth( 1 ); SetColor( 255, 255, 255 ); SetAlpha( 0.5 )
			If pathing.came_from( cursor ) <> Null Then ..
				DrawLine( cursor.col*cell_size + cell_size/2, cursor.row*cell_size + cell_size/2, pathing.came_from( cursor ).col*cell_size + cell_size/2, pathing.came_from( cursor ).row*cell_size + cell_size/2 )
			'draw pathing_visited
			SetColor( 255, 212, 212 ); SetAlpha( 0.5 )
			DrawRect( cursor.col*cell_size + 1, cursor.row*cell_size + 1, cell_size - 2, cell_size - 2 )
		Next
		'potential paths header
		SetAlpha( 1 ); SetImageFont( consolas_normal_10 )
		SetColor( 127, 127, 127 )
		DrawText( "potential paths", arena_w + 4, -9 )
		Local f#, pf#, listing_str$
		For Local i% = 0 To pathing.potential_paths.item_count - 1 + 1
			If pathing.potential_paths.binary_tree[i] <> Null
				'draw potential paths
				SetColor( 212, 255, 212 ); SetAlpha( 0.5 )
				DrawRect( pathing.potential_paths.binary_tree[i].col*cell_size + 1, pathing.potential_paths.binary_tree[i].row*cell_size + 1, cell_size - 2, cell_size - 2 )
				'draw came_from for potential paths
				SetLineWidth( 1 ); SetColor( 255, 255, 255 ); SetAlpha( 0.25 )
				If pathing.came_from( pathing.potential_paths.binary_tree[i] ) <> Null Then ..
					DrawLine( pathing.potential_paths.binary_tree[i].col*cell_size + cell_size/2, pathing.potential_paths.binary_tree[i].row*cell_size + cell_size/2, pathing.came_from( pathing.potential_paths.binary_tree[i] ).col*cell_size + cell_size/2, pathing.came_from( pathing.potential_paths.binary_tree[i] ).row*cell_size + cell_size/2 )
				'potential_paths min_heap binary_tree data structure content listing
				f = pathing.f( pathing.potential_paths.binary_tree[i] )
				pf = pathing.f( pathing.potential_paths.binary_tree[pathing.potential_paths.parent_i( i )] )
				If pf > f Then SetColor( 255, 127, 127 ) ..
				Else           SetColor( 127, 127, 127 )
				listing_str = "f:" + Int( f )
			Else
				SetColor( 64, 64, 64 )
				listing_str = "null"
			End If
			sx = arena_w + 4 + 76*(i/55)
			sy = (i Mod 55 )*9
			SetAlpha( 1 ); SetImageFont( consolas_normal_10 )
			DrawText( "[" + i + "] " + listing_str, sx, sy )
		Next
		'start and goal
		If global_start <> Null
			SetColor( 64, 255, 64 ); SetAlpha( 1 )
			DrawRect( global_start.col*cell_size + 1, global_start.row*cell_size + 1, cell_size - 2, cell_size - 2 )
		End If
		If global_goal <> Null
			SetColor( 64, 64, 255 ); SetAlpha( 1 )
			DrawRect( global_goal.col*cell_size + 1, global_goal.row*cell_size + 1, cell_size - 2, cell_size - 2 )
		End If
		'draw optional message
		SetColor( 255, 255, 255 ); SetAlpha( 1 )
		SetImageFont( consolas_normal_12 )
		DrawText( message, 3, -14 )
		
		Flip
		
	End While
End Function
'______________________________________________________________________________
Function debug_core()
	SetOrigin( arena_offset, arena_offset )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	sx = 4; sy = 4
	h = 10
	
	SetImageFont( consolas_normal_12 )
	debug_drawtext( "player.stickies " + player.stickies.Count() )
	
'	Local length# = 30
'	SetLineWidth( 2 )
'	SetColor( 64, 127, 64 )
'	For Local p:PROJECTILE = EachIn projectile_list
'		For Local f:FORCE = EachIn p.force_list
'			DrawLine( p.pos_x, p.pos_y, p.pos_x + length*f.magnitude_cur*Cos( p.ang + f.direction ), p.pos_y + length*f.magnitude_cur*Sin( p.ang + f.direction ) )
'		Next
'	Next

'	debug_drawtext( "friendly agents " + friendly_agent_list.Count() )
'	debug_drawtext( "hostile agents " + hostile_agent_list.Count() )


'	SetColor( 127, 64, 64 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + c.vel_x*length, c.pos_y + c.vel_y*length )
'	SetColor( 64, 127, 64 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + c.acc_x*length, c.pos_y + c.acc_y*length )
'	SetColor( 64, 64, 127 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + Cos(c.ang)*length, c.pos_y + Sin(c.ang)*length )
'	SetColor( 255, 127, 127 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + length*c.driving_force.control_pct*Cos(c.driving_force.direction + c.ang), c.pos_y + length*c.driving_force.control_pct*Sin(c.driving_force.direction + c.ang) )
'	SetColor( 127, 255, 127 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + length*c.turning_force.control_pct*Cos(c.ang + 90),                        c.pos_y + length*c.turning_force.control_pct*Sin(c.ang + 90) )
'	px :+ speed * KeyDown( KEY_RIGHT ) - speed * KeyDown( KEY_LEFT )
'	py :+ speed * KeyDown( KEY_DOWN ) - speed * KeyDown( KEY_UP )
'	maus_x = MouseX() - arena_offset
'	maus_y = MouseY() - arena_offset
'	
'	a = vector_diff_angle( px, py, maus_x, maus_y )
'	r = vector_diff_length( px, py, maus_x, maus_y )
'	
'	SetLineWidth( 1 )
'	SetColor( 127, 255, 127 ); DrawLine( px, py, px + r*Cos(a), py + r*Sin(a) )
'
'	SetColor( 255, 127, 127 ); DrawLine( px, py, px + 30*Cos(avatar.turrets[0].ang), avatar.pos_y + 30*Sin(avatar.turrets[0].ang) )
'	SetColor( 255, 127, 127 ); DrawLine( avatar.pos_x, avatar.pos_y, avatar.pos_x + 30*Cos(avatar.turrets[0].ang), avatar.pos_y + 30*Sin(avatar.turrets[0].ang) )
'	SetColor( 127, 255, 127 ); DrawLine( avatar.pos_x, avatar.pos_y, avatar.pos_x + dist_to_target*Cos(dist_to_target), avatar.pos_y + dist_to_target*Sin(dist_to_target) )
'
'	SetColor( 255, 255, 255 )

	
'	Local p:COMPLEX_AGENT = player, t:TURRET = p.turrets[0]
'	DrawText( "tur.proj_em.offset " + em.offset, sx, sy ); sy :+ h
'	DrawText( "tur.proj_em.offset_ang " + em.offset_ang, sx, sy ); sy :+ h
'	DrawText( "ammo (main) " + t.cur_ammo + "/" + t.max_ammo, sx, sy); sy :+ h
'	sy :+ h
'	SetColor( 220, 30, 30 ); SetImageFont( consolas_normal_12 )
'	DrawText( "particles " + (particle_list_background.Count() + particle_list_foreground.Count()), sx, sy ); sy :+ h
'	DrawText( "retained_particles " + retained_particle_list.Count(), sx, sy ); sy :+ h
'	DrawText( "emitters " + emitter_list.Count(), sx, sy ); sy :+ h
'	DrawText( "projectiles " + (friendly_projectile_list.Count() + hostile_projectile_list.Count()), sx, sy ); sy :+ h
'	DrawText( "enemies " + enemy_list.Count(), sx, sy ); sy :+ h
'	DrawText( "pickups " + pickup_list.Count(), sx, sy ); sy :+ h
'	sy :+ h
	
'	SetColor( 255, 20, 20 )
'	SetLineWidth(2)
'	Local x#[3], y#[3], i%
'	
'	x[0] = em.parent.pos_x
'	x[1] = em.parent.pos_x + em.offset * Cos( em.parent.ang + em.offset_ang )
'	x[2] = em.parent.pos_x + em.offset * Cos( em.parent.ang + em.offset_ang )
'	
'	y[0] = em.parent.pos_y
'	y[1] = em.parent.pos_y + em.offset * Sin( em.parent.ang + em.offset_ang )
'	y[2] = em.parent.pos_y + em.offset * Sin( em.parent.ang + em.offset_ang )
'	
'	For i = 0 To x.Length - 2
'		DrawLine( x[i], y[i], x[i+1], y[i+1] )
'	Next



'	DrawText( "projectiles " + projectile_list.Count(), offset, offset + 10*line ); line :+ 1
'	DrawText( "particles " + particle_list.Count(), offset, offset + 10*line ); line :+ 1
'	DrawText( DEBUG_COUNTER, offset, offset + 10*line ); line :+ 1
'	DrawText( test_timer.Ticks(), offset, offset + 10*line ); line :+ 1
'	If Not particle_list.IsEmpty()
'		Local p:PARTICLE = PARTICLE(particle_list.Last())
'		DrawText( "--- latest particle ---", offset, offset + 10*line ); line :+ 1
'		Local L% = p.life_time
'		DrawText( "life_time       L = " + L, offset, offset + 10*line ); line :+ 1
'		Local C% = now()
'		DrawText( "clock           C = " + C, offset, offset + 10*line ); line :+ 1
'		Local T% = p.created_ts
'		DrawText( "created_ts      T = " + T, offset, offset + 10*line ); line :+ 1
'		
'		DrawText( "              C-T = " + (C-T), offset, offset + 10*line ); line :+ 1
'		DrawText( "          C-T > L = " + ((C-T) > L), offset, offset + 10*line ); line :+ 1
'	End If
'	DrawText( display_name + ".pos_x       " + pos_x, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".pos_y       " + pos_y, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".vel_x       " + vel_x, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".vel_y       " + vel_y, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".ang         " + ang, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".ang_vel     " + ang_vel, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".tur_ang     " + tur_ang, x, line*10 + y ); line :+ 1
'	DrawText( display_name + ".tur_ang_vel " + tur_ang_vel, x, line*10 + y ); line :+ 1
'	SetLineWidth(2)
'	For Local i% = 0 To 3
'		If player.tread_debris_emitter[i].alive()
'			DrawText( "emitter " + i + " active", offset, i * 10 + offset )
'			DrawLine( player.pos_x, player.pos_y, player.pos_x + player.tread_debris_emitter[i].offset * Cos( player.tread_debris_emitter[i].offset_ang + player.ang ), player.pos_y + player.tread_debris_emitter[i].offset * Sin( player.tread_debris_emitter[i].offset_ang + player.ang ))
'		End If
'	Next
'	
'	SetLineWidth(2)
'	Local x#[3], y#[3], i%
'	
'	x[0] = p.pos_x
'	x[1] = p.pos_x + t.offset * Cos( t.offset_ang + p.ang )
'	x[2] = p.pos_x + t.offset * Cos( t.offset_ang + p.ang ) + t.muz_offset * Cos( t.muz_offset_ang + p.ang + t.ang )
'	
'	y[0] = p.pos_y
'	y[1] = p.pos_y + t.offset * Sin( t.offset_ang + p.ang )
'	y[2] = p.pos_y + t.offset * Sin( t.offset_ang + p.ang ) + t.muz_offset * Sin( t.muz_offset_ang + p.ang + t.ang )
'	
'	For i = 0 To x.Length - 2
'		DrawLine( x[i], y[i], x[i+1], y[i+1] )
'	Next
'	For i = 0 To x.Length - 1
'		DrawText( "x" + i + " = " + x[i], offset, offset + 10*line ); line :+ 1
'		DrawText( "y" + i + " = " + y[i], offset, offset + 10*line ); line :+ 1
'	Next
	
'	Print "0 Mod 360 = " + 0 Mod 360 + "; should be 0"
'	Print "90 Mod 360 = " + 90 Mod 360 + "; should be 90"
'	Print "180 Mod 360 = " + 180 Mod 360 + "; should be 180"
'	Print "270 Mod 360 = " + 270 Mod 360 + "; should be 270"
'	Print "359 Mod 360 = " + 359 Mod 360 + "; should be 359"
'	Print "360 Mod 360 = " + 360 Mod 360 + "; should be 0"
'	Print "540 Mod 360 = " + 540 Mod 360 + "; should be 180"
'	Print "720 Mod 360 = " + 720 Mod 360 + "; should be 0"
'	Print "-90 Mod 360 = " + (-90) Mod 360 + "; should be 270"
'	Print "-180 Mod 360 = " + (-180) Mod 360 + "; should be 180"
'	Print "-270 Mod 360 = " + (-270) Mod 360 + "; should be 90"
'	Print "-359 Mod 360 = " + (-359) Mod 360 + "; should be 1"
'	Print "-360 Mod 360 = " + (-360) Mod 360 + "; should be 0"
'	Print "-540 Mod 360 = " + (-540) Mod 360 + "; should be 180"
'	Print "-720 Mod 360 = " + (-720) Mod 360 + "; should be 0"

End Function
?