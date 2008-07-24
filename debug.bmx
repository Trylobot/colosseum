Rem
	test.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem


'______________________________________________________________________________
'Global test_timer:TTimer = CreateTimer( 1.000/0.250 )
Function debug_ts( message$ )
	Print( String.FromInt( now() ) + ":" + message )
End Function

Function debug()

	If KeyHit( KEY_F4 )
		DebugStop
		Return
	End If

'	SetRotation( 0 )
'	SetScale( 1, 1 )
'	SetAlpha( 1 )
'	SetOrigin( arena_offset, arena_offset )
'	
'	Local p:COMPLEX_AGENT = player, t:TURRET = p.turrets[0], em:EMITTER = t.projectile_emitter
'	
'	Local sx# = 4, sy# = 4
'	Local h% = 10
'	
'	SetColor( 220, 30, 30 ); SetImageFont( consolas_normal_12 )
'	DrawText( "particles " + (particle_list_background.Count() + particle_list_foreground.Count()), sx, sy ); sy :+ h
'	DrawText( "retained_particles " + retained_particle_list.Count(), sx, sy ); sy :+ h
'	DrawText( "emitters " + emitter_list.Count(), sx, sy ); sy :+ h
'	DrawText( "projectiles " + (friendly_projectile_list.Count() + hostile_projectile_list.Count()), sx, sy ); sy :+ h
'	DrawText( "enemies " + enemy_list.Count(), sx, sy ); sy :+ h
'	DrawText( "pickups " + pickup_list.Count(), sx, sy ); sy :+ h
'	sy :+ h
'	DrawText( "ammo (main) " + t.cur_ammo + "/" + t.max_ammo, sx, sy); sy :+ h
'	DrawText( "pos ( " + p.pos_x + ", " + p.pos_y + " )", sx, sy ); sy :+ h
'	DrawText( "vel ( " + p.vel_x + ", " + p.vel_y + " )", sx, sy ); sy :+ h
'	DrawText( "ang " + p.ang, sx, sy ); sy :+ h
'	DrawText( "ang_vel " + p.ang_vel, sx, sy ); sy :+ h
'	DrawText( "tur.ang " + t.ang, sx, sy ); sy :+ h
'	DrawText( "tur.proj_em.offset " + em.offset, sx, sy ); sy :+ h
'	DrawText( "tur.proj_em.offset_ang " + em.offset_ang, sx, sy ); sy :+ h
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
'	
	
End Function

