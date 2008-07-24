Rem
	colosseum.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem


'misc utility functions
'______________________________________________________________________________
Function draw_help()
	DrawImage( img_help, 5, 5 )
End Function
'______________________________________________________________________________
Function draw_arena()
	DrawImage( img_arena_bg, 0, 0 )
End Function
'______________________________________________________________________________
Function draw_score()
	'...?
End Function
'______________________________________________________________________________
'Function draw_health( cur_health#, max_health#, pos_x_exact#, pos_y_exact# )
'	Local pos_x% = Int(pos_x_exact), pos_y% = Int(pos_y_exact)
'	SetRotation( 0 )
'	DrawImage( img_health_bar, pos_x - 22/2, pos_y - 5 )
'	Local threshold# = 0.100
'	While threshold <= 1.000 And cur_health > threshold * max_health
'		DrawImage( img_health_pip, Int(pos_x) - 22/2 + threshold * 20, Int(pos_y) - 5 )
'		threshold :+ 0.100
'	End While
'End Function


'main subroutines
'______________________________________________________________________________
Function process_input()
	'capture input and update pertinent physical_objects
	'update player velocity
	If KeyDown( KEY_W ) Or KeyDown( KEY_I )
		player.vel_x = player_velocity_max * Cos( player.ang )
		player.vel_y = player_velocity_max * Sin( player.ang )
		player.enable_only_rear_emitters()
	ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K )
		player.vel_x = -player_velocity_max * Cos( player.ang )
		player.vel_y = -player_velocity_max * Sin( player.ang )
		player.enable_only_forward_emitters()
	Else
		player.vel_x = 0
		player.vel_y = 0
		player.disable_all_emitters()
	EndIf
	
	If KeyDown( KEY_D )
		player.ang_vel = player_angular_velocity_max
	ElseIf KeyDown( KEY_A )
		player.ang_vel = -player_angular_velocity_max
	Else
		player.ang_vel = 0
	EndIf
	
	If KeyDown( KEY_L )
		player.turrets[0].ang_vel = player_turret_angular_velocity_max
		player.turrets[1].ang_vel = player_turret_angular_velocity_max
	ElseIf KeyDown( KEY_J )
		player.turrets[0].ang_vel = -player_turret_angular_velocity_max
		player.turrets[1].ang_vel = -player_turret_angular_velocity_max
	Else
		player.turrets[0].ang_vel = 0
		player.turrets[1].ang_vel = 0
	EndIf
	
	If KeyDown( KEY_SPACE )
		player.fire( 0 )
	End If
	
	If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
		player.fire( 1 )
	End If
	
	If KeyHit( KEY_F1 )
		FLAG_draw_help = Not FLAG_draw_help
	End If
	
End Function
'______________________________________________________________________________
Function update_objects()
	'emitters
	For Local em:EMITTER = EachIn emitter_list
		em.emit()
	Next
	'projectiles
	For Local proj:PROJECTILE = EachIn projectile_list
		proj.update()
	Next	
	'particles
	For Local part:PARTICLE = EachIn particle_list
		part.update()
	Next
	SetAlpha( 1.000 )
	SetScale( 1.000, 1.000 )

	'player
	player.update()

	'enemies
	For Local nme:AGENT = EachIn enemy_list
		nme.update()
	Next

End Function
'______________________________________________________________________________
Const GENERIC_COLLIDE_LAYER% = 1
Const PLAYER_COLLIDE_LAYER% = 2
Const ENEMY_COLLIDE_LAYER% = 4
Const ENEMY_COLLIDE_DETAIL_LAYER% = 8
Const PROJECTILE_COLLIDE_LAYER% = 16
Const STATIC_COLLIDE_LAYER% = 32

Function collide()
	Local nme:AGENT, proj:PROJECTILE
	
	ResetCollisions()
	For nme = EachIn enemy_list
		SetRotation( nme.ang )
		CollideImage( nme.img, nme.pos_x, nme.pos_y, 0, 0, ENEMY_COLLIDE_LAYER )
	Next
	
	For proj = EachIn projectile_list
		ResetCollisions( PROJECTILE_COLLIDE_LAYER )
		SetRotation( proj.ang )
		If CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, ENEMY_COLLIDE_LAYER, PROJECTILE_COLLIDE_LAYER )
			'a collision occurred between {proj} and ENEMY_COLLIDE_LAYER
			ResetCollisions( ENEMY_COLLIDE_DETAIL_LAYER )
			For nme = EachIn enemy_list
				SetRotation( nme.ang )
				If CollideImage( nme.img, nme.pos_x, nme.pos_y, 0, PROJECTILE_COLLIDE_LAYER, ENEMY_COLLIDE_DETAIL_LAYER )
					
					'create explosion particle at position of projectile, with random angle
					'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
					Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
					explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
					explode.vel_x = 0; explode.vel_y = 0
					explode.ang = Rand( 0, 359 )
					explode.life_time = Rand( 300, 400 )
					
					'activate collision response for affected entity(ies)
					'most basic response: remove enemy
					nme.receive_damage( proj.damage )
					
					'show the player how much cash they got for killing this enemy, if they killed it
					
					'remove original projectile
					proj.remove_me()
					
				End If
			Next
		End If
	Next
	
End Function
'______________________________________________________________________________
Function draw()
	
	SetOrigin( arena_offset, arena_offset )
	SetViewport( arena_offset, arena_offset, arena_w, arena_h )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	'arena & environment
	draw_arena()
	'player
	player.draw()
	'enemies
	For Local nme:AGENT = EachIn enemy_list
		nme.draw()
	Next
	'projectile particles
	For Local proj:PARTICLE = EachIn projectile_list
		proj.draw()
	Next
	'generic particles
	For Local part:PARTICLE = EachIn particle_list
		part.draw()
	Next
	
	SetViewport( 0, 0, window_w, window_h )
	SetColor( 255, 255, 255 )
	'gui
	
	SetOrigin( 0, 0 )
	SetRotation( 0 )
	If FLAG_draw_help Then draw_help()
End Function


'______________________________________________________________________________
'initialize temporary testing entities
'enemy tanks
For Local i% = 1 To 10
	Local e:AGENT = Create_AGENT()
	e.img = img_box
	e.pos_x = Rand( 10, arena_w - 10 )
	e.pos_y = Rand( 10, arena_h - 10 )
	e.ang = Rand( 0, 359 )
	Local vel# = 0.001 * Double( Rand( 200, 500 ))
	e.vel_x = vel * Cos( e.ang )
	e.vel_y = vel * Sin( e.ang )
	e.add_me( enemy_list )
Next
'player
Global player:COMPLEX_AGENT
player = Copy_COMPLEX_AGENT( player_archetype[ 0] )
player.pos_x = arena_w/2
player.pos_y = arena_h/2
'player.ang = -90
'player.turrets[0].ang = player.ang
'player.turrets[1].ang = player.ang


'______________________________________________________________________________
'         ####################################################################
'  MAIN   ####################################################################
'         ####################################################################
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

Local before% = 0
Repeat
	
	If now() - before > (1000/60) '60 physics intervals a second
		before = now()
		
		process_input()
		update_objects()
		collide()
	EndIf
	
	Cls	
	draw()
	draw_misc_debug_info() 'debug screen printer
	Flip( 1 ) 'draw to screen with vsync enabled
	
Until KeyHit( KEY_ESCAPE ) Or AppTerminate() 'kill app when ESC or close button pressed

