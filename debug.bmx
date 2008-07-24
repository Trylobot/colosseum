Rem
	test.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

Global sx%, sy%, h%, px#, py#, maus_x#, maus_y#, speed# = 1, r#, a#

'______________________________________________________________________________
'Global test_timer:TTimer = CreateTimer( 1.000/0.250 )
Function debug_ts( message$ )
	Print( String.FromInt( now() ) + ":" + message )
End Function

Function debug_drawtext( message$ )
	DrawText( message, sx, sy )
	sy :+ h
End Function

Function debug()
	SetOrigin( arena_offset, arena_offset )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	Local p:COMPLEX_AGENT = player, t:TURRET = p.turrets[0]
	sx = 4; sy = 4
	h = 10
	
	debug_drawtext( "agents " + friendly_agent_list.Count() + hostile_agent_list.Count() )


'	For Local c:COMPLEX_AGENT = EachIn friendly_agent_list
'		SetLineWidth( 2 )
'		Local length# = 40
'		SetColor( 127, 64, 64 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + c.vel_x*length, c.pos_y + c.vel_y*length )
'		SetColor( 64, 127, 64 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + c.acc_x*length, c.pos_y + c.acc_y*length )
'		SetColor( 64, 64, 127 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + Cos(c.ang)*length, c.pos_y + Sin(c.ang)*length )
'		SetColor( 255, 127, 127 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + length*c.driving_force.control_pct*Cos(c.driving_force.direction + c.ang), c.pos_y + length*c.driving_force.control_pct*Sin(c.driving_force.direction + c.ang) )
'		SetColor( 127, 255, 127 ); DrawLine( c.pos_x, c.pos_y, c.pos_x + length*c.turning_force.control_pct*Cos(c.ang + 90),                             c.pos_y + length*c.turning_force.control_pct*Sin(c.ang + 90) )
'	Next
'	
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
	
	If KeyHit( KEY_F4 )
		DebugStop
		Return
	End If

End Function

