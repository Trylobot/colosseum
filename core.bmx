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

'Window Initialization and Drawing device
'SetGraphicsDriver D3D7Max2DDriver()
'SetGraphicsDriver GLGraphicsDriver()
AppTitle = My.Application.AssemblyInfo
Graphics( window_w, window_h )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'Settings flags
Global FLAG_in_menu% = True
Global FLAG_in_shop% = False
Global FLAG_level_intro% = False
Global FLAG_game_in_progress% = False
Global FLAG_game_over% = False
Global FLAG_bg_music_on% = False
Global FLAG_draw_help% = False

Const MENU_RESUME% = 0
Const MENU_NEW% = 1
Const MENU_LOAD% = 2
Const MENU_SETTINGS% = 3
Const MENU_QUIT% = 4
Const menu_option_count% = 5

Global menu_display_string$[] = [ "resume", "new game", "load saved", "settings", "quit" ]
Global menu_enabled%[] =        [  False,    True,       False,        False,      True  ]
Global menu_option% = MENU_NEW

Const PICKUP_PROBABILITY% = 5000 'chance in 10,000 of an enemy dropping a pickup (randomly selected from all pickups)

'global player stuff
Global player:COMPLEX_AGENT
Global player_cash% = 0
Global player_level% = 0
Global player_kills% = 0

'______________________________________________________________________________
'Menu Commands
Function menu_command( com% )
	Select com
		
		Case MENU_RESUME
			FLAG_in_menu = False
		
		Case MENU_NEW
			FLAG_in_menu = False
			reset_game()
			initialize_game()
			FLAG_game_in_progress = True
		
		Case MENU_LOAD
			'..?
		
		Case MENU_SETTINGS
			'..?
		
		Case MENU_QUIT
			End 'quit now
		
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
	player_kills = 0
	FLAG_game_in_progress = False
	FLAG_game_over = False
	
End Function
'______________________________________________________________________________
Function load_next_level()
	player_level :+ 1
	FLAG_level_intro = True
	player_kills = 0
	respawn_enemies()
	dim_bg_cache() 'fade the messy bg
End Function
'______________________________________________________________________________
Function initialize_game()
	player_level = 1
	respawn_player()
	respawn_enemies()
	init_pathing_system()
	'initial update, for graphical reasons
	update_all()
	FLAG_level_intro = True
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
'Spawning and Respawning
Function respawn_player()
	
	If player <> Null And player.managed() Then player.remove_me()
	player = COMPLEX_AGENT( COMPLEX_AGENT.Copy( player_archetype[ 0], ALIGNMENT_FRIENDLY ))
	'player = Copy_COMPLEX_AGENT( enemy_archetype[ 1], ALIGNMENT_FRIENDLY )
	player.pos_x = arena_w/2
	player.pos_y = arena_h*3/4
	player.ang = -90
	player.snap_turrets()
	Create_and_Manage_CONTROL_BRAIN( player, Null, CONTROL_TYPE_HUMAN, INPUT_KEYBOARD, UNSPECIFIED )

End Function
'______________________________________________________________________________
Function respawn_enemies()
	If hostile_agent_list.IsEmpty()
		For Local i% = 1 To 3*player_level
			Local selector# = RandF( 0.000, 1.000 )
			If      selector < 0.400 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MR_THE_BOX), Null, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_MR_THE_BOX, 2000 ) ..
			Else If selector < 0.600 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MOBILE_MINI_BOMB), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_SEEKER, 20 ) ..
			Else If selector < 0.800 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_MACHINE_GUN_TURRET_EMPLACEMENT), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_TURRET, 40 ) ..
			Else If selector < 0.900 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_ROCKET_TURRET_EMPLACEMENT), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_TURRET, 40 ) ..
			Else If selector < 1.000 Then Create_and_Manage_CONTROL_BRAIN( spawn_enemy(ENEMY_INDEX_CANNON_TURRET_EMPLACEMENT), player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_TURRET, 40 )
		Next
	End If
End Function
'______________________________________________________________________________
Function spawn_enemy:COMPLEX_AGENT( archetype_index% )
	Local nme:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( enemy_archetype[archetype_index], ALIGNMENT_HOSTILE ))
	If Rand( 0, 1 ) = 1 Then nme.pos_x = RandF( 0, 0.25*arena_w ) ..
	Else                     nme.pos_x = RandF( 0.75*arena_w, arena_w )
	If Rand( 0, 1 ) = 1 Then nme.pos_y = RandF( 0, 0.25*arena_h ) ..
	Else                     nme.pos_y = RandF( 0.75*arena_h, arena_h )
	nme.ang = Rand( 0, 359 )
	nme.snap_turrets()
	Return nme
End Function
'______________________________________________________________________________
Function spawn_pickup( x#, y# )
	Local pkp:PICKUP
	If Rand( 0, 10000 ) < PICKUP_PROBABILITY
		Local index% = Rand( 0, pickup_archetype.Length - 1 )
		pkp = PICKUP( PICKUP.Copy( pickup_archetype[index] ))
		pkp.pos_x = x; pkp.pos_y = y
	End If
End Function


