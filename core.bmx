Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Basics
SetGraphicsDriver D3D7Max2DDriver()
'SetGraphicsDriver GLGraphicsDriver()
AppTitle = My.Application.AssemblyInfo
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'Settings flags
Global FLAG_in_menu% = True
Global FLAG_game_over% = False
Global FLAG_draw_help% = False
Global FLAG_bg_music_on% = False
Global FLAG_game_in_progress% = False

Const MENU_RESUME% = 0
Const MENU_NEW% = 1
Const MENU_CONTINUE% = 2
Const MENU_LOAD% = 3
Const MENU_SETTINGS% = 4
Const MENU_QUIT% = 5
Const menu_option_count% = 6

Global menu_display_string$[] = [ "resume", "new game", "continue", "load saved", "settings", "quit" ]
Global menu_enabled%[] =        [  False,    True,       False,      False,        False,      True  ]
Global menu_option% = MENU_NEW

Const GENERAL_COLLIDE_LAYER% = $0001
Const PLAYER_COLLIDE_LAYER% = $0002
Const ENEMY_COLLIDE_LAYER% = $0004
Const FRIENDLY_PROJECTILE_COLLIDE_LAYER% = $0008
Const HOSTILE_PROJECTILE_COLLIDE_LAYER% = $0010
Const PICKUP_COLLIDE_LAYER% = $0011
Const SENSOR_COLLIDE_LAYER% = $0012



'______________________________________________________________________________
'Menu Commands
Function menu_command( com% )
	Select com
		Case MENU_RESUME
			FLAG_in_menu = False
		Case MENU_NEW
			reset_game()
			initialize()
			load_next_level()
			FLAG_in_menu = False
		Case MENU_CONTINUE
			'..?
		Case MENU_LOAD
			'..?
		Case MENU_SETTINGS
			'..?
		Case MENU_QUIT
			End
	End Select
End Function
'______________________________________________________________________________
Function reset_game()
	particle_list_background.Clear()
	particle_list_foreground.Clear()
	retained_particle_list.Clear()
	emitter_list.Clear()
	friendly_projectile_list.Clear()
	hostile_projectile_list.Clear()
	enemy_list.Clear()
	pickup_list.Clear()
	control_brain_list.Clear()
	
	player = Null
	player_cash = 0
	player_level = 0
	FLAG_game_in_progress = False
End Function
'______________________________________________________________________________
Function load_next_level()
	player_level :+ 1
	respawn_enemies()
End Function
'______________________________________________________________________________
Function initialize()
	respawn_player()
	FLAG_game_in_progress = True
End Function
'______________________________________________________________________________
'Spawning and Respawning
Function respawn_player()
	
	If player <> Null Then player.remove_me()
	player = Copy_COMPLEX_AGENT( player_archetype[ 0], True )
	player.pos_x = arena_w/2
	player.pos_y = arena_h/2
	player.ang = -90
	player.turrets[0].ang = player.ang
	player.turrets[1].ang = player.ang
	
End Function
'______________________________________________________________________________
Function respawn_enemies()
	If enemy_list.IsEmpty()
		
		'the infamous "mr. the box"
		For Local i% = 1 To (5*player_level)
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 0], True )
			
			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.ang = Rand( 0, 359 )
			
			nme.command_all_motivators( MOVE_FORWARD_DIRECTION, RandF( 0.2, 0.6 ))
			nme.rear_trail_emitters[ 0].enable( MODE_ENABLED_FOREVER )
			
			nme.add_me( enemy_list )
		Next
		
		'the brand spankin' new ROCKET TURRET
		For Local i% = 1 To (1*player_level)
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 1], True )

			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.turrets[ 0].ang = Rand( 0, 359 )

			Local cb:CONTROL_BRAIN = New CONTROL_BRAIN
			cb.avatar = nme
			cb.target = player
			cb.ai_type = AI_TYPE_ROCKET_TURRET
			cb.turret_angular_velocity_max = rocket_turret_angular_velocity_max
			cb.add_me( control_brain_list )
			
			nme.add_me( enemy_list )
		Next
		
	End If
End Function
'______________________________________________________________________________
Function spawn_pickup( x#, y# )
	Local pkp:PICKUP
	If Rand( 0, 10000 ) < pickup_probability
		Local index% = Rand( 0, pickup_archetype.Length - 1 )
		pkp = Copy_PICKUP( pickup_archetype[index] )
		pkp.pos_x = x; pkp.pos_y = y
	End If
End Function
'______________________________________________________________________________
'Keyboard Input
Function process_input()
	
	'music
	If KeyHit( KEY_M ) Then FLAG_bg_music_on = Not FLAG_bg_music_on
	'pause menu
	If KeyHit( KEY_ESCAPE )
		If Not FLAG_in_menu
			FLAG_in_menu = True
			'set the currently selected option to the first enabled one
			menu_option = MENU_RESUME
			'enable the resume option if there's a game goin on
			If FLAG_game_in_progress
				menu_enabled[ MENU_RESUME ] = True
			End If
		Else If FLAG_game_in_progress 'And FLAG_in_menu
			menu_command( MENU_RESUME )
		End If
	End If
	
	If FLAG_in_menu
		'navigate the menu
		If KeyHit( KEY_DOWN )
			next_enabled_menu_option()
		Else If KeyHit( KEY_UP )
			prev_enabled_menu_option()
		End If
		'select an option
		If KeyHit( KEY_ENTER )
			menu_command( menu_option )
		End If
		
	Else

		'capture input and update pertinent physical_objects
		'update player velocity
		If KeyDown( KEY_W ) Or KeyDown( KEY_I ) Or KeyDown( KEY_UP )
			player.command_all_motivators( MOVE_FORWARD_DIRECTION, player_velocity_max )
		ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K ) Or KeyDown( KEY_DOWN )
			player.command_all_motivators( MOVE_REVERSE_DIRECTION, player_velocity_max )
		Else
			player.command_all_motivators( ALL_STOP )
		EndIf
		
		If KeyDown( KEY_D )
			player.ang_vel = player_angular_velocity_max
		ElseIf KeyDown( KEY_A )
			player.ang_vel = -( player_angular_velocity_max )
		Else
			player.ang_vel = 0
		EndIf
		
		If KeyDown( KEY_L ) Or KeyDown( KEY_RIGHT )
			player.command_all_turrets( ROTATE_CLOCKWISE_DIRECTION,player_turret_angular_velocity_max  )
		ElseIf KeyDown( KEY_J ) Or KeyDown( KEY_LEFT )
			player.command_all_turrets( ROTATE_COUNTER_CLOCKWISE_DIRECTION, player_turret_angular_velocity_max )
		Else
			player.command_all_turrets( ALL_STOP )
		EndIf
		
		If KeyDown( KEY_SPACE )
			player.fire( 0 )
		End If
		
		If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
			player.fire( 1 )
		End If
		
	End If
End Function
'______________________________________________________________________________
'Physics and Timing Update
Function update_objects()
	If Not FLAG_in_menu
		
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.update()
		Next
		'projectiles
		For Local proj:PROJECTILE = EachIn friendly_projectile_list
			proj.update()
			'out-of-bounds kill
			If proj.pos_x > arena_w Then proj.remove_me()
			If proj.pos_x < 0       Then proj.remove_me()
			If proj.pos_y > arena_h Then proj.remove_me()
			If proj.pos_y < 0       Then proj.remove_me()
		Next	
		For Local proj:PROJECTILE = EachIn hostile_projectile_list
			proj.update()
			'out-of-bounds kill
			If proj.pos_x > arena_w Then proj.remove_me()
			If proj.pos_x < 0       Then proj.remove_me()
			If proj.pos_y > arena_h Then proj.remove_me()
			If proj.pos_y < 0       Then proj.remove_me()
		Next	
		'particles
		For Local list:TList = EachIn particle_lists
			For Local part:PARTICLE = EachIn list
				part.update()
				part.prune()
			Next
		Next
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
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
			If nme.pos_x > arena_w
				nme.vel_x = -nme.vel_x
				nme.ang = 180 - nme.ang
			Else If nme.pos_x < 0
				nme.vel_x = -nme.vel_x
				nme.ang = 180 - nme.ang
			End If
			If nme.pos_y > arena_h
				nme.vel_y = -nme.vel_y
				nme.ang = 180 - nme.ang
			Else If nme.pos_y < 0
				nme.vel_y = -nme.vel_y
				nme.ang = 180 - nme.ang
			End If
		Next
		
		SetOrigin( arena_offset, arena_offset )
		SetRotation( 0 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		'control brains
		For Local cb:CONTROL_BRAIN = EachIn control_brain_list
			cb.think_and_act()
			cb.prune()
		Next
		
		'level
		If enemy_list.IsEmpty()
			load_next_level()
		End If
		
	End If
End Function
'______________________________________________________________________________
'Drawing to Screen
Function draw()
	
	If FLAG_in_menu
		'main menu
		draw_menu()
	Else
	
		SetOrigin( arena_offset, arena_offset )
		SetViewport( arena_offset, arena_offset, arena_w + 1, arena_h + 1 )
		
		'arena & environment
		draw_arena()
		'background generic particles
		For Local part:PARTICLE = EachIn particle_list_background
			part.draw()
		Next
		
		'projectiles
		For Local proj:PROJECTILE = EachIn friendly_projectile_list
			proj.draw()
		Next
		For Local proj:PROJECTILE = EachIn hostile_projectile_list
			proj.draw()
		Next
	
		'enemies
		For Local nme:COMPLEX_AGENT = EachIn enemy_list
			nme.draw()
		Next
		'player
		player.draw()
		
		'foreground generic particles
		For Local part:PARTICLE = EachIn particle_list_foreground
			part.draw()
		Next
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.draw()
		Next
		
		SetOrigin( 0, 0 )
		SetViewport( 0, 0, window_w, window_h )
		
		'interface
		draw_stats_panel()
		
	End If
	
End Function
'______________________________________________________________________________
'Collision Detection and Resolution
Function collide()
	If Not FLAG_in_menu
	
		Local nme:COMPLEX_AGENT
		Local proj:PROJECTILE
		Local pkp:PICKUP
		Local result:Object[]
		
		ResetCollisions()
		
		'collisions between friendly projectiles and enemies
		For nme = EachIn enemy_list
			SetRotation( nme.ang )
			CollideImage( nme.img, nme.pos_x, nme.pos_y, 0, 0, ENEMY_COLLIDE_LAYER, nme )
		Next
		For proj = EachIn friendly_projectile_list
			SetRotation( proj.ang )
			result = CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, ENEMY_COLLIDE_LAYER, FRIENDLY_PROJECTILE_COLLIDE_LAYER, proj )
			For nme = EachIn result	
				'COLLISION! between {proj} & {nme}
				
				'create explosion particle at position of projectile, with random angle
				'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
				Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
				explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
				explode.vel_x = 0; explode.vel_y = 0
				explode.ang = Rand( 0, 359 )
				explode.life_time = Rand( 300, 300 )
				
				'activate collision response for affected entity(ies)
				'most basic response: remove enemy
				nme.receive_damage( proj.damage )
				If nme.dead()
					player_cash :+ nme.cash_value
					spawn_pickup( nme.pos_x, nme.pos_y )
					nme.remove_me()
				End If
				
				'show the player how much cash they got for killing this enemy, if they killed it
				
				'remove original projectile
				proj.remove_me()
				
				'dump out early, this projectile is no longer valid
				Exit
				
			Next
		Next
		
		'collisions between player and hostile projectiles
		For proj = EachIn hostile_projectile_list
			SetRotation( proj.ang )
			CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, 0, HOSTILE_PROJECTILE_COLLIDE_LAYER, proj )
		Next
		SetRotation( player.ang )
		result = CollideImage( player.img, player.pos_x, player.pos_y, 0, HOSTILE_PROJECTILE_COLLIDE_LAYER, PLAYER_COLLIDE_LAYER, player )
		For proj = EachIn result
			'COLLISION! between {player} and {proj}
			
			'create explosion particle at position of projectile, with random angle
			'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
			Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
			explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
			explode.vel_x = 0; explode.vel_y = 0
			explode.ang = Rand( 0, 359 )
			explode.life_time = Rand( 300, 300 )
			
			'activate collision response for affected entity(ies)
			player.receive_damage( proj.damage )
			If player.dead()
				FLAG_game_over = True
			End If
			
			'remove original projectile
			proj.remove_me()
			
		Next
		
		'collisions between player and pickups
		For pkp = EachIn pickup_list
			SetRotation( 0 )
			CollideImage( pkp.img, pkp.pos_x, pkp.pos_y, 0, 0, PICKUP_COLLIDE_LAYER, pkp )
		Next
		SetRotation( player.ang )
		result = CollideImage( player.img, player.pos_x, player.pos_y, 0, PICKUP_COLLIDE_LAYER, PLAYER_COLLIDE_LAYER, player )
		For pkp = EachIn result
			'COLLISION! between {player} and {pkp}
			
			'give pickup to player
			player.grant_pickup( pkp )
			
			'dump out early; only the first pickup collided with will be applied this frame
			Exit
			
		Next
	End If
End Function
'______________________________________________________________________________
Function draw_stats_panel()
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	
	Local x%, y%
	
	'level
	x = arena_w + (arena_offset * 2)
	y = arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	DrawText( "level", x, y ); y :+ 12
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
	DrawText( player_level, x, y ); y :+ 50
	
	'player cash
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	'ToDo: put some code here to comma-separate the displayed cash value
	DrawText( "cash", x, y ); y :+ 12
	SetColor( 50, 220, 50 ); SetImageFont( consolas_bold_50 )
	DrawText( "$" + player_cash, x, y ); y :+ 50
		
	'player health		
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	DrawText( "health", x, y ); y :+ 12
	Local w% = 150, h% = 15
	SetColor( 255, 255, 255 )
	DrawRect( x, y, w, h )
	SetColor( 16, 16, 16 )
	DrawRect( x + 1, y + 1, w - 2, h - 2 )
	SetColor( 255, 255, 255 )
	DrawRect( x + 2, y + 2, (Double(w) - 4.0) * (player.cur_health / player.max_health) , h - 4 )
	y :+ h
	
	'player ammo
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	DrawText( "heavy cannon", x, y ); y :+ 12
	Local temp_x%, temp_y%
	temp_x = x; temp_y = y
	For Local i% = 0 To player.turrets[0].cur_ammo - 1
		If ((i Mod 20) = 0) And (i > 0)
			temp_x = x
			temp_y :+ img_icon_player_cannon_ammo.height
		End If
		DrawImage( img_icon_player_cannon_ammo, temp_x, temp_y )
		temp_x :+ img_icon_player_cannon_ammo.width
	Next; y :+ 12 + (player.turrets[0].max_ammo / 20)* img_icon_player_cannon_ammo.height
	DrawText( "co-axial machine gun", x, y ); y :+ 12
	DrawImage( img_icon_infinity, x, y ); y :+ img_icon_infinity.height + 12
	
	'copyright stuff
	y = window_h - arena_offset - 20
	SetColor( 157, 157, 157 ); SetImageFont( consolas_normal_10 )
	DrawText( "programming by Tyler W Cole", x, y ); y :+ 10
	DrawText( "music by NickPerrin", x, y ); y :+ 10
	
End Function
'______________________________________________________________________________
'Audio
Function play_bg_music()
	If FLAG_bg_music_on And Not ChannelPlaying( bg_music )
		ResumeChannel( bg_music )
	Else If Not FLAG_bg_music_on
		PauseChannel( bg_music )
	End If
End Function
'______________________________________________________________________________
'Menu and GUI
Function draw_menu()
	SetOrigin( 0, 0 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	Local x%, y%
	
	If FLAG_game_in_progress
		SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_24 )
		DrawText( "- game paused -", 150, 100 )
	End If
	
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
		DrawText( My.Application.AssemblyInfo, 150, 200 )
	
	SetImageFont( consolas_normal_24 )
	For Local option% = 0 To menu_option_count - 1
		If menu_enabled[ option ]
			If option = menu_option
				SetColor( 255, 255, 255 ) ..
			Else
				SetColor( 127, 127, 127 )
			End If
		Else
			SetColor( 64, 64, 64 )
		End If
		DrawText( menu_display_string[ option ], 250, 300 + option*48 )
	Next
	
	'copyright stuff
	x = 500; y = 600
	SetColor( 157, 157, 157 ); SetImageFont( consolas_normal_10 )
	DrawText( "Colosseum (c) 2008 Tyler W Cole", x, y ); y :+ 10
	y :+ 10
	DrawText( "written in 100% BlitzMax", x, y ); y :+ 10
	DrawText( "  http://www.blitzmax.com", x, y ); y :+ 10
	y :+ 10
	DrawText( "music by 'NickPerrin'", x, y ); y :+ 10
	DrawText( "  Victory! (8-bit Chiptune)", x, y ); y :+ 10
	DrawText( "  http://www.newgrounds.com", x, y ); y :+ 10
	
	SetColor( 255, 255, 255 )
	DrawImage( img_help, 500, 300 )
		
End Function
'______________________________________________________________________________
Function next_enabled_menu_option()
	menu_option :+ 1
	If menu_option >= menu_option_count Then menu_option = 0
	While Not menu_enabled[ menu_option ]
		menu_option :+ 1
		If menu_option >= menu_option_count Then menu_option = 0
	End While
End Function
Function prev_enabled_menu_option()
	menu_option :- 1
	If menu_option < 0 Then menu_option = menu_option_count - 1
	While Not menu_enabled[ menu_option ]
		menu_option :- 1
		If menu_option < 0 Then menu_option = menu_option_count - 1
	End While
End Function
'______________________________________________________________________________
Function draw_arena()
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )

	'DrawImage( img_arena_bg, 0, 0 )

	DrawLine( 0, 0, arena_w, 0 )
	DrawLine( arena_w, 0, arena_w, arena_h )
	DrawLine( arena_w, arena_h, 0, arena_h )
	DrawLine( 0, arena_h, 0, 0 )
	
  'RETAINED particles (eventually this loop will be eliminated and handled automatically with the use of a dynamic pixmap background texture
	For Local part:PARTICLE = EachIn retained_particle_list
		part.draw()
	Next
End Function
'______________________________________________________________________________
Function draw_game_over()
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )

	
End Function

