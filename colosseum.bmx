Rem
	colosseum.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
Rem
	TO DO
	- alpha values for particles, birth & death
	- tread emitter and manager list
	- damage for player and enemies
	- encapsulate turret logic and make a class for it
	- create xml format for levels
	- create a level editor
	- work on collision resolution
	- use acceleration values to smooth out movement (translation, rotation, etc)
	- apply forces for specified amounts of time
	- create arbitrary forces
	- define the center of mass for objects
	- create gibs for enemies
	- make gibs spawn as particles when enemies die
	- create scars
	- create "shells" to be ejected from the ejector port of turret object
	- create blocks for static environments that can be collided with
	- create example arenas
	- create a rudimentary AI
	- create a few enemies with guns
	- create visible damage which "sticks" to agents
	- separate main components into files
EndRem

'Framework BRL.Max2D

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
Function draw_health( cur_health#, max_health#, pos_x_exact#, pos_y_exact# )
	Local pos_x% = Int(pos_x_exact), pos_y% = Int(pos_y_exact)
	SetRotation( 0 )
	DrawImage( img_health_bar, pos_x - 22/2, pos_y - 5 )
	Local threshold# = 0.100
	While threshold <= 1.000 And cur_health > threshold * max_health
		DrawImage( img_health_pip, Int(pos_x) - 22/2 + threshold * 20, Int(pos_y) - 5 )
		threshold :+ 0.100
	End While
End Function

'main subroutines
'______________________________________________________________________________
Function process_input()
	'capture input and update pertinent physical_objects
	'update player velocity
	If KeyDown( KEY_W ) Or KeyDown( KEY_I )
		player.vel_x = player_velocity_max * Cos( player.ang )
		player.vel_y = player_velocity_max * Sin( player.ang )
		'If FLAG_emit_tread
		'	treadlist.AddLast( point.createPoint( px + (-15*Cos(a)), py + (-15*Sin(a)), a ))
		'	FLAG_emit_tread = False
		'EndIf
		player.enable_only_rear_tread_debris_emitters()
		'player.enable_only_rear_tread_print_emitters()
	ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K )
		player.vel_x = -player_velocity_max * Cos( player.ang )
		player.vel_y = -player_velocity_max * Sin( player.ang )
		'If FLAG_emit_tread
		'	treadlist.AddLast( point.createPoint( px + (15*Cos(a)), py + (15*Sin(a)), a ))
		'	FLAG_emit_tread = False
		'EndIf
		player.enable_only_forward_tread_debris_emitters()
		'player.enable_only_forward_tread_print_emitters()
	Else
		player.vel_x = 0
		player.vel_y = 0
		player.disable_all_tread_debris_emitters()
		'player.disable_all_tread_print_emitters()
	EndIf
	
	If KeyDown( KEY_D )
		player.ang_vel = player_angular_velocity_max
	ElseIf KeyDown( KEY_A )
		player.ang_vel = -player_angular_velocity_max
	Else
		player.ang_vel = 0
	EndIf
	
	If KeyDown( KEY_L )
		(player.get_turret( 0 )).ang_vel = player_turret_angular_velocity_max
		(player.get_turret( 1 )).ang_vel = player_turret_angular_velocity_max
	ElseIf KeyDown( KEY_J )
		(player.get_turret( 0 )).ang_vel = -player_turret_angular_velocity_max
		(player.get_turret( 1 )).ang_vel = -player_turret_angular_velocity_max
	Else
		(player.get_turret( 0 )).ang_vel = 0
		(player.get_turret( 1 )).ang_vel = 0
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
	'player
	player.update()
	'enemies
	For Local nme:AGENT = EachIn enemy_list
		nme.update()
	Next
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
					Local explode:PARTICLE = Create_PARTICLE( ..
						proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
					
					'create a "points" particle at position of projectile
					
					
					'activate collision response for affected entity(ies)
					'most basic response: remove enemy
					nme.remove_me()
					
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
	SetColor( 255, 50, 50 )
	'gui
	
	'debug
	draw_misc_debug_info()
	
	SetOrigin( 0, 0 )
	SetRotation( 0 )
	If FLAG_draw_help Then draw_help()
End Function

'______________________________________________________________________________
'open window and initialize graphics
Const window_w% = 550
Const window_h% = 550
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'______________________________________________________________________________
'         ####################################################################
'  MAIN   ####################################################################
'         ####################################################################
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
	Flip( 1 ) 'draw to screen with vsync enabled
Until KeyHit( KEY_ESCAPE ) Or AppTerminate() 'kill app when ESC or close button pressed
'end of file colosseum.bmx
