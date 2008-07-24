Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function process_input()
	
	'capture input and update pertinent physical_objects
	'update player velocity
	If KeyDown( KEY_W ) Or KeyDown( KEY_I ) Or KeyDown( KEY_UP )
		player.vel_x = player_velocity_max * Cos( player.ang )
		player.vel_y = player_velocity_max * Sin( player.ang )
		player.enable_only_rear_emitters()
	ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K ) Or KeyDown( KEY_DOWN )
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
	
	If KeyDown( KEY_L ) Or KeyDown( KEY_RIGHT )
		player.rotate_all_turrets( CLOCKWISE_DIRECTION )
	ElseIf KeyDown( KEY_J ) Or KeyDown( KEY_LEFT )
		player.rotate_all_turrets( COUNTER_CLOCKWISE_DIRECTION )
	Else
		player.rotate_all_turrets( ALL_STOP )
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
	
	If KeyHit( KEY_P )' Or KeyHit( KEY_PAUSE ) 'why doesn't this one work? wtf? it's in the docs for chrissake
		FLAG_paused = Not FLAG_paused
	End If
	
End Function
'______________________________________________________________________________
Function update_objects()
	If Not FLAG_paused
		
		'projectiles
		For Local proj:PROJECTILE = EachIn projectile_list
			'normal update
			proj.update()
			'out-of-bounds kill
			If proj.pos_x > arena_w Then proj.remove_me()
			If proj.pos_x < 0       Then proj.remove_me()
			If proj.pos_y > arena_h Then proj.remove_me()
			If proj.pos_y < 0       Then proj.remove_me()
		Next	
		'particles
		For Local part:PARTICLE = EachIn particle_list
			'normal update
			part.update()
			'prune
			part.prune()
		Next
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			'emit
			em.emit()
			'prune
		Next
		
		'player
		player.update()
		'boundary enforce
		If player.pos_x > arena_w Then player.pos_x = arena_w
		If player.pos_x < 0       Then player.pos_x = 0
		If player.pos_y > arena_h Then player.pos_y = arena_h
		If player.pos_y < 0       Then player.pos_y = 0

		'enemies
		For Local nme:COMPLEX_AGENT = EachIn enemy_list
			nme.update()
			'bounce
			If nme.pos_x > arena_w Then nme.vel_x = -nme.vel_x
			If nme.pos_x < 0       Then nme.vel_x = -nme.vel_x
			If nme.pos_y > arena_h Then nme.vel_y = -nme.vel_y
			If nme.pos_y < 0       Then nme.vel_y = -nme.vel_y
		Next
		
	End If
End Function
'______________________________________________________________________________
Const GENERIC_COLLIDE_LAYER% = 1
Const PLAYER_COLLIDE_LAYER% = 2
Const ENEMY_COLLIDE_LAYER% = 4
Const PROJECTILE_COLLIDE_LAYER% = 8

Function collide()
	Local nme:COMPLEX_AGENT, proj:PROJECTILE
	Local result:Object[]
	
	ResetCollisions()
	
	For nme = EachIn enemy_list
		SetRotation( nme.ang )
		CollideImage( nme.img, nme.pos_x, nme.pos_y, 0, 0, ENEMY_COLLIDE_LAYER, nme )
	Next
	
	For proj = EachIn projectile_list
		SetRotation( proj.ang )
		result = CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, ENEMY_COLLIDE_LAYER, PROJECTILE_COLLIDE_LAYER, proj )
		
		'For Local i% = 0 To result.Length - 1
			'nme = COMPLEX_AGENT( result[i] )
		For nme = EachIn result	
			'collision between {proj} & {nme}
			
			'create explosion particle at position of projectile, with random angle
			'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
			Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
			explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
			explode.vel_x = 0; explode.vel_y = 0
			explode.ang = Rand( 0, 359 )
			explode.life_time = Rand( 300, 400 )
			
			'activate collision response for affected entity(ies)
			'most basic response: remove enemy
			Local nme_killed% = nme.receive_damage( proj.damage )
			If nme_killed
				player_cash :+ nme.cash_value
			End If
			
			'show the player how much cash they got for killing this enemy, if they killed it
			
			'remove original projectile
			proj.remove_me()
			
		Next
	Next
	
End Function
'______________________________________________________________________________
Function draw()
	
	SetOrigin( arena_offset, arena_offset )
	SetViewport( arena_offset, arena_offset, arena_w + 1, arena_h + 1 )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'arena & environment
	draw_arena()
	'player
	player.draw()
	'enemies
	For Local nme:COMPLEX_AGENT = EachIn enemy_list
		nme.draw()
	Next
	'projectile particles
	For Local proj:PROJECTILE = EachIn projectile_list
		proj.draw()
	Next
	'generic particles
	For Local part:PARTICLE = EachIn particle_list
		part.draw()
	Next
	
	SetOrigin( 0, 0 )
	SetViewport( 0, 0, window_w, window_h )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'interface
	draw_score()
	
	If FLAG_draw_help Then draw_help()
	
	draw_misc_debug_info() 'debug screen printer
	
End Function
'______________________________________________________________________________
Function draw_help()
	DrawImage( img_help, 5, 5 )
End Function
'______________________________________________________________________________
Function draw_arena()
	'DrawImage( img_arena_bg, 0, 0 )
	SetColor( 255, 255, 255 )
	DrawLine( 0, 0, arena_w, 0 )
	DrawLine( arena_w, 0, arena_w, arena_h )
	DrawLine( arena_w, arena_h, 0, arena_h )
	DrawLine( 0, arena_h, 0, 0 )
	
  'RETAINED particles (eventually this loop will be eliminated and handled automatically with the use of a dynamic pixmap background texture
	For Local part:PARTICLE = EachIn retained_particle_list
		part.draw()
	Next
	
	SetScale( 1, 1 )
	SetAlpha( 1 )

End Function
'______________________________________________________________________________
Function draw_score()
	Local x%, y%
	SetOrigin( 0, 0 )
	
	x = arena_w + (arena_offset * 2)
	y = arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
		DrawText( "cash", x, y ); y :+ 12
	SetColor( 50, 220, 50 ); SetImageFont( consolas_bold_50 )
		DrawText( "$" + player_cash, x, y ); y :+ 50
		
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
		DrawText( "ammo", x, y ); y :+ 12
		DrawText( "· main cannon", x, y ); y :+ 12
		DrawText( "· co-ax m.gun", x, y ); y :+ 12
	
	y = window_h - arena_offset - 30
	SetColor( 157, 157, 157 ); SetImageFont( consolas_normal_10 )
		DrawText( "copyright 2008 Tyler W Cole", x, y ); y :+ 10
		DrawText( "written in 100% BlitzMax", x, y ); y :+ 10
		DrawText( "http://www.blitzmax.com", x, y ); y :+ 10
	
End Function
'______________________________________________________________________________
Const MENU_START_CONTINUE% = 0
Const MENU_LOAD% = 1
Const MENU_SETTINGS% = 2
Const MENU_QUIT% = 3
Global menu_option% = MENU_START_CONTINUE

Function draw_menu()
	
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
'______________________________________________________________________________
Function respawn_enemies()
	If enemy_list.Count() <= 0
		For Local i% = 1 To 10
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 0] ) 
			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.ang = Rand( 0, 359 )
			Local vel# = RandF( 0.2, 0.5 )
			nme.vel_x = vel * Cos( nme.ang )
			nme.vel_y = vel * Sin( nme.ang )
			nme.add_me( enemy_list )
			Local nme_trail:EMITTER = Copy_EMITTER( particle_emitter_archetype[10], nme )
			nme_trail.attach_to( nme, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
			nme_trail.enable_counter( False )
		Next
	End If
End Function


