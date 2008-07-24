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

'Settings flags
Global FLAG_in_menu% = True
Global FLAG_game_in_progress% = False
Global FLAG_game_over% = False
Global FLAG_draw_help% = False
Global FLAG_bg_music_on% = False

Const MENU_RESUME% = 0
Const MENU_NEW% = 1
Const MENU_LOAD% = 2
Const MENU_SETTINGS% = 3
Const MENU_QUIT% = 4
Const menu_option_count% = 5

Global menu_display_string$[] = [ "resume", "new game", "load saved", "settings", "quit" ]
Global menu_enabled%[] =        [  False,    True,       False,        False,      True  ]
Global menu_option% = MENU_NEW

Const PLAYER_COLLISION_LAYER% = $0001
Const AGENT_COLLISION_LAYER% = $0002
Const PROJECTILE_COLLISION_LAYER% = $0004
Const PICKUP_COLLISION_LAYER% = $0008

'environmental constants
Const PICKUP_PROBABILITY% = 5000 'chance in 10,000 of an enemy dropping a pickup (randomly selected from all pickups)
Const PROJECTILE_ENERGY_COEFFICIENT# = 750.0 'energy multiplier for all collisions involving projectiles

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
	FLAG_game_over = False
	
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
	player = Copy_COMPLEX_AGENT( player_archetype[ 0], ALIGNMENT_FRIENDLY )
	'player = Copy_COMPLEX_AGENT( enemy_archetype[ 1], ALIGNMENT_FRIENDLY )
	player.pos_x = arena_w/2
	player.pos_y = arena_h/2
	player.ang = -90
	player.snap_turrets()
	Create_and_Manage_CONTROL_BRAIN( player, Null, CONTROL_TYPE_HUMAN, INPUT_KEYBOARD, UNSPECIFIED )

End Function
'______________________________________________________________________________
Function respawn_enemies()
	If hostile_agent_list.IsEmpty()
		
		'mr. the box
		For Local i% = 1 To (3*player_level)
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 0], ALIGNMENT_HOSTILE )
			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.ang = Rand( 0, 359 )
			Create_and_Manage_CONTROL_BRAIN( nme, Null, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_MR_THE_BOX, 1000 )
		Next
		
		'rocket turret
		For Local i% = 1 To (1*player_level)
			Local nme:COMPLEX_AGENT = Copy_COMPLEX_AGENT( enemy_archetype[ 1], ALIGNMENT_HOSTILE )
			nme.pos_x = Rand( 10, arena_w - 10 )
			nme.pos_y = Rand( 10, arena_h - 10 )
			nme.turrets[ 0].ang = Rand( 0, 359 )
			Create_and_Manage_CONTROL_BRAIN( nme, player, CONTROL_TYPE_AI, UNSPECIFIED, AI_BRAIN_ROCKET_TURRET, 50 )
		Next
		
	End If
End Function
'______________________________________________________________________________
Function spawn_pickup( x#, y# )
	Local pkp:PICKUP
	If Rand( 0, 10000 ) < PICKUP_PROBABILITY
		Local index% = Rand( 0, pickup_archetype.Length - 1 )
		pkp = Copy_PICKUP( pickup_archetype[index] )
		pkp.pos_x = x; pkp.pos_y = y
	End If
End Function


