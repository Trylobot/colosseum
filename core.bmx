Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Generic globals
Const INFINITY% = -1

'Window / Arena size
Const arena_offset% = 25
Const arena_w% = 500
Const arena_h% = 500
Const stats_panel_w% = 250
Const window_w% = arena_w + 2*arena_offset + stats_panel_w
Const window_h% = arena_h + 2*arena_offset

'Window and Drawing device
SetGraphicsDriver D3D7Max2DDriver()
'SetGraphicsDriver GLGraphicsDriver()
AppTitle = My.Application.AssemblyInfo
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'Background cached texture
Global bg_cache:TPixmap

'Settings flags
Global FLAG_in_menu% = True
Global FLAG_game_in_progress% = False
Global FLAG_game_over% = False
Global FLAG_draw_help% = False
Global FLAG_bg_music_on% = False

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

Const AGENT_COLLISION_LAYER% = $0001
Const PROJECTILE_COLLISION_LAYER% = $0002
Const PICKUP_COLLISION_LAYER% = $0004

'special player constants
'Const player_velocity_max# = 1.100
'Const player_angular_velocity_max# = 1.500
Const player_turret_angular_velocity_max# = 1.000
'special enemy constants
Const rocket_turret_angular_velocity_max# = 0.900
'environment
Const pickup_probability% = 3333 'chance in 10,000 of an enemy dropping a pickup (randomly selected from all pickups)
Const global_driving_roundoff_threshold# = 0
Const global_turning_roundoff_threshold# = 0

'global player stuff
Global player:COMPLEX_AGENT
Global player_cash% = 0
Global player_level% = 0


'______________________________________________________________________________
'Menu Commands
Function menu_command( com% )
	Select com
		
		Case MENU_RESUME
			FLAG_in_menu = False
		
		Case MENU_NEW
			reset_game()
			initialize_game()
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
	
	bg_cache = Null
	
	particle_list_background.Clear()
	particle_list_foreground.Clear()
	retained_particle_list.Clear()
	projectile_list.Clear()
	friendly_agent_list.Clear()
	hostile_agent_list.Clear()
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
Function initialize_game()
	
	FLAG_game_in_progress = True
	respawn_player()
	
End Function
'______________________________________________________________________________
'Spawning and Respawning
Function respawn_player()
	
	If player <> Null Then player.remove_me()
	player = Copy_COMPLEX_AGENT( player_archetype[ 0], ALIGNMENT_FRIENDLY )
	player.pos_x = arena_w/2
	player.pos_y = arena_h/2
	player.ang = -90
	player.turrets[0].ang = player.ang
	player.turrets[1].ang = player.ang
	
	player.add_me( friendly_agent_list )

	Local cb:CONTROL_BRAIN = New CONTROL_BRAIN
	cb.avatar = player
	cb.control_type = CONTROL_TYPE_HUMAN
	cb.ai_type = INPUT_KEYBOARD
	cb.turret_angular_velocity_max = player_turret_angular_velocity_max
	
	cb.add_me( control_brain_list )

End Function
'______________________________________________________________________________
Function respawn_enemies()
	If hostile_agent_list.IsEmpty()
		
		'the infamous "mr. the box"
		For Local i% = 1 To (5*player_level)
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 0], ALIGNMENT_HOSTILE )
			
			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.ang = Rand( 0, 359 )
			
			nme.drive( RandF( 0.5, 1.0 ))
			nme.rear_trail_emitters[ 0].enable( MODE_ENABLED_FOREVER )
			
			nme.add_me( hostile_agent_list )
		Next
		
		'the brand spankin' new ROCKET TURRET
		For Local i% = 1 To (2*player_level)
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 1], ALIGNMENT_HOSTILE )

			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.turrets[ 0].ang = Rand( 0, 359 )

			nme.add_me( hostile_agent_list )

			Local cb:CONTROL_BRAIN = New CONTROL_BRAIN
			cb.avatar = nme
			cb.target = player
			cb.control_type = CONTROL_TYPE_AI
			cb.ai_type = AI_BRAIN_ROCKET_TURRET
			cb.turret_angular_velocity_max = rocket_turret_angular_velocity_max
			
			cb.add_me( control_brain_list )
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
Function get_input()
	
	'music
	If KeyHit( KEY_M ) Then FLAG_bg_music_on = Not FLAG_bg_music_on
	'pause menu
	If KeyHit( KEY_ESCAPE )
		If Not FLAG_in_menu
			FLAG_in_menu = True
			If FLAG_game_in_progress
				menu_enabled[ MENU_RESUME ] = True
				menu_option = MENU_RESUME
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
		'do nothing; rest is handled automagically
	
	End If
End Function
'______________________________________________________________________________
'Physics and Timing Update
Function update_all()
	If Not FLAG_in_menu
		
		'control brains (human + ai)
		For Local cb:CONTROL_BRAIN = EachIn control_brain_list
			cb.update()
			cb.prune()
		Next
		
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.update()
		Next
		'projectiles
		For Local proj:PROJECTILE = EachIn projectile_list
			proj.update()
			'out-of-bounds kill (should be done with collisions)
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

		'friendlies
		For Local friendly:COMPLEX_AGENT = EachIn friendly_agent_list
			friendly.update()
		Next
		'player boundary enforce (should be done with collisions)
		If player.pos_x > arena_w Then player.pos_x = arena_w
		If player.pos_x < 0       Then player.pos_x = 0
		If player.pos_y > arena_h Then player.pos_y = arena_h
		If player.pos_y < 0       Then player.pos_y = 0

		'hostiles
		For Local hostile:COMPLEX_AGENT = EachIn hostile_agent_list
			hostile.update()
			'bounce (should be done with collisions)
			If hostile.pos_x > arena_w
				hostile.vel_x = -hostile.vel_x
				hostile.ang = 180 - hostile.ang
			Else If hostile.pos_x < 0
				hostile.vel_x = -hostile.vel_x
				hostile.ang = 180 - hostile.ang
			End If
			If hostile.pos_y > arena_h
				hostile.vel_y = -hostile.vel_y
				hostile.ang = 180 - hostile.ang
			Else If hostile.pos_y < 0
				hostile.vel_y = -hostile.vel_y
				hostile.ang = 180 - hostile.ang
			End If
		Next
		
		'level
		If hostile_agent_list.IsEmpty()
			load_next_level()
		End If
		
	End If
End Function
'______________________________________________________________________________
'Drawing to Screen
Function draw_all()
	
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	
	If FLAG_in_menu
		'main menu
		draw_menu()
	Else
	
		SetOrigin( arena_offset, arena_offset )
		SetViewport( arena_offset, arena_offset, arena_w + 1, arena_h + 1 )
		
		'arena & environment
		draw_arena()
		'background particles
		For Local part:PARTICLE = EachIn particle_list_background
			part.draw()
		Next
		SetAlpha( 1 )
		SetScale( 1, 1 )
		
		'projectiles
		For Local proj:PROJECTILE = EachIn projectile_list
			proj.draw()
		Next
		'hostile agents
		For Local hostile:COMPLEX_AGENT = EachIn hostile_agent_list
			hostile.draw()
		Next
		'friendly agents
		For Local friendly:COMPLEX_AGENT = EachIn friendly_agent_list
			friendly.draw()
		Next
		
		'foreground particles
		For Local part:PARTICLE = EachIn particle_list_foreground
			part.draw()
		Next
		SetRotation( 0 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.draw()
		Next
		
		SetOrigin( 0, 0 )
		SetViewport( 0, 0, window_w, window_h )
		
		'interface
		draw_stats_panel()
		
		'######################
		'debug() '#######
		'############
		
	End If
	
End Function
'______________________________________________________________________________
'Collision Detection and Resolution
Function collide_all()
	If Not FLAG_in_menu
	
		Local ag:COMPLEX_AGENT
		Local proj:PROJECTILE
		Local pkp:PICKUP
		Local result:Object[]
		
		ResetCollisions()
		'AGENT_COLLISION_LAYER
		'PROJECTILE_COLLISION_LAYER
		'PICKUP_COLLISION_LAYER

		'collisions between projectiles and complex_agents
		For ag = EachIn hostile_agent_list
			SetRotation( ag.ang )
			CollideImage( ag.img, ag.pos_x, ag.pos_y, 0, 0, AGENT_COLLISION_LAYER, ag )
		Next
		For ag = EachIn friendly_agent_list
			SetRotation( ag.ang )
			CollideImage( ag.img, ag.pos_x, ag.pos_y, 0, 0, AGENT_COLLISION_LAYER, ag )
		Next
		
		For proj = EachIn projectile_list
			SetRotation( proj.ang )
			result = CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, AGENT_COLLISION_LAYER, PROJECTILE_COLLISION_LAYER, proj )
			For hostile = EachIn result	
				'COLLISION! between {proj} & {agent}
				
				'create explosion particle at position of projectile, with random angle
				'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
				Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
				explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
				explode.vel_x = 0; explode.vel_y = 0
				explode.ang = Rand( 0, 359 )
				explode.life_time = Rand( 300, 300 )
				
				'activate collision response for affected entity(ies)
				'most basic response: remove enemy
				hostile.receive_damage( proj.damage )
				If hostile.dead()
					player_cash :+ hostile.cash_value
					spawn_pickup( hostile.pos_x, hostile.pos_y )
					hostile.remove_me()
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
Function draw_arena()

	If bg_cache <> Null And retained_particle_list.IsEmpty()
		DrawPixmap( bg_cache, 0, 0 )
	Else 'either bg_cache has never been initialized, or there are new particles to be retained.
		'arena
		SetLineWidth( 2 ); SetColor( 127, 127, 127 )
		DrawLine( 0, 0, arena_w, 0 )
		DrawLine( arena_w, 0, arena_w, arena_h )
		DrawLine( arena_w, arena_h, 0, arena_h )
		DrawLine( 0, arena_h, 0, 0 )
	  'retained particles
		For Local part:PARTICLE = EachIn retained_particle_list
			part.draw()
		Next
		'update cache
		bg_cache = GrabPixmap( 0, 0, arena_w + 1, arena_h + 1 )
	End If
		
End Function
'______________________________________________________________________________
Function draw_menu()
	SetOrigin( 0, 0 )
	Local x%, y%
	
	'title
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
		DrawText( My.Application.AssemblyInfo, 25, 75 )
	
	'menu options
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
		DrawText( menu_display_string[ option ], 50, 125 + option*36 )
	Next
	
	'help
	SetColor( 255, 255, 255 )
	DrawImage( img_help, 300, 125 )
		
	'pause indicator
	If FLAG_game_in_progress
		SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_24 )
		DrawText( "- game paused -", 25, 25 )
	End If
	
	'copyright stuff
	x = 300; y = 300
	SetColor( 157, 157, 157 ); SetImageFont( consolas_normal_10 )
	DrawText( "Colosseum (c) 2008 Tyler W Cole", x, y ); y :+ 10
	y :+ 10
	DrawText( "written in 100% BlitzMax", x, y ); y :+ 10
	DrawText( "  http://www.blitzmax.com", x, y ); y :+ 10
	y :+ 10
	DrawText( "music by 'NickPerrin'", x, y ); y :+ 10
	DrawText( "  Victory! (8-bit Chiptune)", x, y ); y :+ 10
	DrawText( "  http://www.newgrounds.com", x, y ); y :+ 10
	
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
Function draw_game_over()

	
End Function

