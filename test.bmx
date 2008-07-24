Rem
	test.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
'temporary testing entities
'player tank
Global player:COMPLEX_AGENT = Create_COMPLEX_AGENT()
player.img = img_player_tank_chassis
player.pos_x = arena_w/2
player.pos_y = arena_h/2
player.ang = 270
player.max_health = 100
player.cur_health = player.max_health
'player tank's turret
Global player_turret:TURRET = Create_TURRET()
player_turret.img = img_player_tank_turret
player_turret.muz_img = img_muzzle_flash
player_turret.proj_img = img_projectile
player_turret.hit_img = img_hit
player_turret.offset = -5
player_turret.muz_offset = 20
'player_turret.muz_off_x = 20
'player_turret.muz_off_y = 0
player_turret.muz_vel = player_turret_projectile_muzzle_velocity
player_turret.reload_time = player_turret_reload_time
player.add_turret( player_turret )
'player tank's mgun
Global player_mgun:TURRET = Create_TURRET()
player_mgun.img = img_player_mgun_turret
player_mgun.muz_img = img_mgun_muzzle_flash
player_mgun.proj_img = img_mgun
player_mgun.hit_img = img_mgun_hit
player_mgun.offset = -5
player_mgun.muz_offset = 14
'player_mgun.muz_off_x = 14
'player_mgun.muz_off_y = 2
player_mgun.muz_vel = player_turret_mgun_muzzle_velocity
player_mgun.reload_time = player_mgun_reload_time
player.add_turret( player_mgun )
'player tank's emitters
player.tread_debris_emitter[0].set( imglib_debris_tiny, 12, -7, -90, 90, 1, 4.5, 100, 250, 20, 50, -1 )
player.tread_debris_emitter[1].set( imglib_debris_tiny, 12, 7, -90, 90, 1, 4.5, 100, 250, 20, 50, -1 )
player.tread_debris_emitter[2].set( imglib_debris_tiny, -12, 7, 90, 270, 1, 4.5, 100, 250, 20, 50, -1 )
player.tread_debris_emitter[3].set( imglib_debris_tiny, -12, -7, 90, 270, 1, 4.5, 100, 250, 20, 50, -1 )
'enemy tanks
For Local i% = 1 To 10
	Local e:AGENT = Create_AGENT()
	e.img = img_enemy_agent
	e.pos_x = Rand( 10, arena_w - 10 )
	e.pos_y = Rand( 10, arena_h - 10 )
	e.ang = Rand( 0, 359 )
	Local vel# = 0.001 * Double( Rand( 200, 500 ))
	e.vel_x = vel * Cos( e.ang )
	e.vel_y = vel * Sin( e.ang )
	e.add_me( enemy_list )
Next

'______________________________________________________________________________
Global test_timer:TTimer = CreateTimer( 1.000/0.250 )
Function draw_misc_debug_info()
	SetRotation( 0 )
	Local offset% = 1
	Local line% = 0
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
'	SetLineWidth(2)
'	Local p:COMPLEX_AGENT = player
'	Local t:TURRET = p.get_turret( 0 )
'	DrawLine( p.pos_x, p.pos_y, p.pos_x + t.off_x, p.pos_y + t.off_y )
'	DrawLine( p.pos_x + t.off_x, p.pos_y + t.off_y, p.pos_x + t.off_x + t.muz_off_x, p.pos_y + t.off_y + t.muz_off_y )
End Function
