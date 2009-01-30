Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'generic
Const INFINITY% = -1
Const UNSPECIFIED% = -1
Const PICKUP_PROBABILITY# = 0.50 'chance of an enemy dropping a pickup (randomly selected from all pickups)
Const arena_lights_fade_time% = 1000 'this should be in environment class
Global level_intro_time% = 2000 'this is deprecated
'notifications
Global info$
Global info_change_ts%
Const info_stay_time% = 3000
Const info_fade_time% = 1250
'player events
Global last_kill_ts%

'environmental objects
Global mouse:cVEC = New cVEC
Global mouse_delta:cVEC = New cVEC
Global main_game:ENVIRONMENT 'game in which player participates
Global ai_menu_game:ENVIRONMENT 'menu ai demo environment
Global game:ENVIRONMENT 'current game environment
Global profile:PLAYER_PROFILE
Global level_editor_cache:LEVEL
	
'app state flags
Global FLAG_in_menu% = True
Global FLAG_bg_music_on% = False
Global FLAG_no_sound% = False
Global FLAG_draw_help% = False
Global FLAG_console% = False
Global FLAG_ignore_mouse_1% = False 'used for temporary ignore after resuming a paused game.

'______________________________________________________________________________
Function play_level( level_file_path$, player:COMPLEX_AGENT )
	If Not player Then Return
	main_game = Create_ENVIRONMENT( True )
	If main_game.bake_level( level_file_path )
		main_game.game_in_progress = True
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		main_game.insert_player( player, player_brain )
		main_game.respawn_player()
		FLAG_in_menu = False
		main_game.player_in_locker = True
		main_game.waiting_for_player_to_enter_arena = True
		MoveMouse( window_w/2 - 30, window_h/2 )
	Else 'Not main_game.load_level()
		main_game = Null
	End If
End Function
'______________________________________________________________________________
Function create_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA )
	If Not v_dat Then Return Null 'no chassis data
	Local player:COMPLEX_AGENT = get_player_chassis( v_dat.chassis_key )
	If player
		For Local t_dat:TURRET_DATA = EachIn v_dat.turrets
			If Not player.add_turret( get_turret( t_dat.turret_key, False ), t_dat.anchor )
				Return Null 'bad turret data
			End If
		Next
		Return player 'all good
	Else
		Return Null 'bad chassis data
	End If
End Function
'______________________________________________________________________________
Function create_player_brain:CONTROL_BRAIN( avatar:COMPLEX_AGENT )
	Return Create_CONTROL_BRAIN( avatar, CONTROL_BRAIN.CONTROL_TYPE_HUMAN, profile.input_method )
End Function

'______________________________________________________________________________
Function record_player_kill( cash_value% )
	If profile
		last_kill_ts = now()
		profile.kills :+ 1
		profile.cash :+ cash_value
	End If
End Function
'______________________________________________________________________________
Function show_info( str$ )
	info = str
	info_change_ts = now()
End Function

'______________________________________________________________________________
Function init_ai_menu_game( fit_to_window% = True )
	ai_menu_game = Create_ENVIRONMENT()
	Local lev:LEVEL = load_level( level_path + "ai_menu_game.colosseum_level" )
	Local diff%
	If fit_to_window
		If window_w > lev.width
			diff = window_w - lev.width
			lev.set_divider( LINE_TYPE_VERTICAL, 4, diff/2, True )
			lev.set_divider( LINE_TYPE_VERTICAL, 15, diff/2, True )
		End If
		If window_h > lev.height
			diff = window_h - lev.height
			lev.set_divider( LINE_TYPE_HORIZONTAL, 3, diff/2, True )
			lev.set_divider( LINE_TYPE_HORIZONTAL, 11, diff/2, True )
		End If
	Else
		ai_menu_game.drawing_origin = Create_cVEC( window_w/2 - lev.width/2, window_h/2 - lev.height/2 )
	End If
	ai_menu_game.bake_level( lev )
	ai_menu_game.auto_reset_spawners = True
	ai_menu_game.game_in_progress = True
	ai_menu_game.battle_in_progress = True
	ai_menu_game.battle_state_toggle_ts = now()
	ai_menu_game.spawn_enemies = True
	ai_menu_game.mouse = mouse
	ai_menu_game.toggle_doors( ALIGNMENT_FRIENDLY )
	ai_menu_game.toggle_doors( ALIGNMENT_HOSTILE )
	
End Function

'______________________________________________________________________________
Function get_player_id%()
	If game <> Null And game.player <> Null
		Return game.player.id
	Else
		Return -1
	End If
End Function

'______________________________________________________________________________
Const COMMAND_NULL% = 0
Const COMMAND_LOAD_ASSETS% = 10
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_BACK_TO_MAIN_MENU% = 53
Const COMMAND_PLAY_LEVEL% = 100
Const COMMAND_PAUSE% = 110
Const COMMAND_RESUME% = 120
Const COMMAND_NEW_GAME% = 200
Const COMMAND_NEW_LEVEL% = 210
Const COMMAND_LOAD_GAME% = 300
Const COMMAND_LOAD_LEVEL% = 310
Const COMMAND_SAVE_GAME% = 400
Const COMMAND_SAVE_LEVEL% = 401
Const COMMAND_EDIT_LEVEL% = 500
Const COMMAND_MULTIPLAYER_JOIN% = 600
Const COMMAND_MULTIPLAYER_HOST% = 650
Const COMMAND_PLAYER_PROFILE_NAME% = 700
Const COMMAND_PLAYER_PROFILE_PATH% = 710
Const COMMAND_PLAYER_INPUT_TYPE% = 1000
Const COMMAND_SETTINGS_FULLSCREEN% = 1010
Const COMMAND_SETTINGS_RESOLUTION% = 1011
Const COMMAND_SETTINGS_REFRESH_RATE% = 1012
Const COMMAND_SETTINGS_BIT_DEPTH% = 1013
Const COMMAND_SETTINGS_IP_ADDRESS% = 1020
Const COMMAND_SETTINGS_IP_PORT% = 1021
Const COMMAND_SETTINGS_SHOW_AI_MENU_GAME% = 1025
Const COMMAND_SETTINGS_RETAIN_PARTICLES% = 1030
Const COMMAND_SETTINGS_PARTICLE_LIMIT% = 1031
Const COMMAND_SETTINGS_APPLY_ALL% = 1100
Const COMMAND_QUIT_LEVEL% = 10010
Const COMMAND_QUIT_GAME% = 65535

Const MENU_ID_MAIN_MENU% = 100
Const MENU_ID_LOADING_BAY% = 200
Const MENU_ID_INPUT_PROFILE_NAME% = 205
Const MENU_ID_SELECT_LEVEL% = 270
Const MENU_ID_MULTIPLAYER% = 1000
Const MENU_ID_MULTIPLAYER_JOIN% = 1160
Const MENU_ID_MULTIPLAYER_HOST% = 1170
Const MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS% = 1180
Const MENU_ID_MULTIPLAYER_INPUT_IP_PORT% = 1181
Const MENU_ID_LOAD_GAME% = 300
Const MENU_ID_CONFIRM_LOAD_GAME% = 310
Const MENU_ID_LOAD_LEVEL% = 310
Const MENU_ID_SAVE_GAME% = 400
Const MENU_ID_INPUT_GAME_FILE_NAME% = 410
Const MENU_ID_SAVE_LEVEL% = 450
Const MENU_ID_INPUT_LEVEL_FILE_NAME% = 460
Const MENU_ID_CONFIRM_ERASE_LEVEL% = 470
Const MENU_ID_SETTINGS% = 500
Const MENU_ID_OPTIONS_PERFORMANCE% = 501
Const MENU_ID_PREFERENCES% = 505
Const MENU_ID_OPTIONS_VIDEO% = 510
Const MENU_ID_CHOOSE_RESOLUTION% = 511
Const MENU_ID_INPUT_REFRESH_RATE% = 512
Const MENU_ID_INPUT_BIT_DEPTH% = 513
Const MENU_ID_INPUT_PARTICLE_LIMIT% = 514
Const MENU_ID_OPTIONS_AUDIO% = 520
Const MENU_ID_OPTIONS_CONTROLS% = 530
Const MENU_ID_OPTIONS_GAME% = 540
Const MENU_ID_GAME_DATA% = 600
Const MENU_ID_LEVEL_EDITOR% = 610
Const MENU_ID_PAUSED% = 1000

Global menu_margin% = 8
Global dynamic_subsection_window_size% = 8
Global all_menus:MENU[50]
Global pause_menu:MENU
reset_index()

all_menus[postfix_index()] = MENU.Create( "main menu", 255, 255, 127, MENU_ID_MAIN_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, False ), ..
	MENU_OPTION.Create( "loading bay", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOADING_BAY), True, False ), ..
	MENU_OPTION.Create( "new", COMMAND_NEW_GAME,, True, True ), ..
	MENU_OPTION.Create( "save", COMMAND_SAVE_GAME,, True, False ), ..
	MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_GAME), True, True ), ..
	MENU_OPTION.Create( "multiplayer", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER), False, False ), ..
	MENU_OPTION.Create( "settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PREFERENCES), True, False ), ..
	MENU_OPTION.Create( "game data", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_GAME_DATA), True, True ), ..
	MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "loading bay", 255, 96, 64, MENU_ID_LOADING_BAY, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "continue game", COMMAND_NULL,, True, True ), ..
		MENU_OPTION.Create( "profile %%profile.name%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_PROFILE_NAME), True, True ), ..
		MENU_OPTION.Create( "  $%%profile.cash%%", COMMAND_NULL,, True, False, 96, 255, 96, True ), ..
		MENU_OPTION.Create( "  kills %%profile.kills%%", COMMAND_NULL,, True, False, 255, 96, 96, True ), ..
		MENU_OPTION.Create( "play campaign", COMMAND_NULL,, True, False ), ..
		MENU_OPTION.Create( "inventory", COMMAND_NULL,, True, False ), ..
		MENU_OPTION.Create( "buy parts", COMMAND_NULL,, True, False ), ..
		MENU_OPTION.Create( "play custom level", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SELECT_LEVEL), True, True )])
	
		all_menus[postfix_index()] = MENU.Create( "input profile name", 255, 255, 255, MENU_ID_INPUT_PROFILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_PLAYER_PROFILE_NAME,, 20, "%%profile.name%%" )
		
		all_menus[postfix_index()] = MENU.Create( "select level", 96, 255, 127, MENU_ID_SELECT_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND_PLAY_LEVEL,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "load game", 96, 255, 127, MENU_ID_LOAD_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND_LOAD_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
	
	Rem
	all_menus[postfix_index()] = MENU.Create( "multiplayer", 78, 78, 255, MENU_ID_MULTIPLAYER, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "join game", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER_JOIN), True, True ), ..
		MENU_OPTION.Create( "host game", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER_HOST), True, False )	])
		
		all_menus[postfix_index()] = MENU.Create( "join game", 122, 122, 255, MENU_ID_MULTIPLAYER_JOIN, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "ip address  %%ip_address%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS), True, True ), ..
			MENU_OPTION.Create( "port        %%ip_port%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER_INPUT_IP_PORT), True, True ), ..
			MENU_OPTION.Create( "connect to game", COMMAND_MULTIPLAYER_JOIN,, True, True ) ])

		all_menus[postfix_index()] = MENU.Create( "host game", 56, 56, 196, MENU_ID_MULTIPLAYER_HOST, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "port  %%ip_port%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER_INPUT_IP_PORT), True, True ), ..
			MENU_OPTION.Create( "start game", COMMAND_MULTIPLAYER_HOST,, True, True ) ])
	
			all_menus[postfix_index()] = MENU.Create( "input ip address", 255, 255, 255, MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_IP_ADDRESS,, 17, "%%ip_address%%"  )

			all_menus[postfix_index()] = MENU.Create( "input port number", 255, 255, 255, MENU_ID_MULTIPLAYER_INPUT_IP_PORT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_IP_PORT,, 17, "%%ip_port%%"  )
	EndRem
	
	all_menus[postfix_index()] = MENU.Create( "settings", 127, 127, 255, MENU_ID_SETTINGS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "video settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_VIDEO), True, True ), ..
		MENU_OPTION.Create( "performance settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_PERFORMANCE), True, True ), ..
		MENU_OPTION.Create( "audio settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_AUDIO), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "video settings", 212, 96, 226, MENU_ID_OPTIONS_VIDEO, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "fullscreen    %%fullscreen%%", COMMAND_SETTINGS_FULLSCREEN,, True, True ), ..
			MENU_OPTION.Create( "resolution    %%window_w%% x %%window_h%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CHOOSE_RESOLUTION), True, True ), ..
			MENU_OPTION.Create( "refresh rate  %%refresh_rate%% Hz", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_REFRESH_RATE), True, True ), ..
			MENU_OPTION.Create( "bit depth     %%bit_depth%% bpp", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_BIT_DEPTH), True, True ), ..
			MENU_OPTION.Create( "apply", COMMAND_SETTINGS_APPLY_ALL,, False, False ) ])
			
			all_menus[postfix_index()] = MENU.Create( "choose resolution", 255, 255, 255, MENU_ID_CHOOSE_RESOLUTION, MENU.VERTICAL_LIST_WITH_SUBSECTION, menu_margin,,,,,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
			Local m:MENU = get_menu(MENU_ID_CHOOSE_RESOLUTION)
			m.static_option_count = 1
			Local modes:TGraphicsMode[] = GraphicsModes()
			For Local i% = 0 To modes.Length-1
				Local unique% = True
				For Local j% = 0 To m.options.Length-1
					Local opt:MENU_OPTION = m.options[j]
					If i > 0
						Local arg%[]
						If Int[](opt.argument)
							arg = Int[](opt.argument)
							If arg[0] = modes[i].width And arg[1] = modes[i].height
								unique = False
								Exit
							End If
						End If
					End If
				Next
				If i = 0 Or unique
					m.add_option( MENU_OPTION.Create( "" + modes[i].width + " x " + modes[i].height, COMMAND_SETTINGS_RESOLUTION, [ modes[i].width, modes[i].height ], True, True ))
				End If
			Next
			
			all_menus[postfix_index()] = MENU.Create( "input refresh rate", 255, 255, 255, MENU_ID_INPUT_REFRESH_RATE, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_REFRESH_RATE,, 10, "%%refresh_rate%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "input bit depth", 255, 255, 255, MENU_ID_INPUT_BIT_DEPTH, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_BIT_DEPTH,, 10, "%%bit_depth%%"  )
		
		all_menus[postfix_index()] = MENU.Create( "performance settings", 212, 226, 96, MENU_ID_OPTIONS_PERFORMANCE, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "background AI game     %%show_ai_menu_game%%", COMMAND_SETTINGS_SHOW_AI_MENU_GAME,, True, True ), ..
			MENU_OPTION.Create( "retain particles       %%retain_particles%%", COMMAND_SETTINGS_RETAIN_PARTICLES,, True, True ), ..
			MENU_OPTION.Create( "active particle limit  %%active_particle_limit%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_PARTICLE_LIMIT), True, True ) ])

			all_menus[postfix_index()] = MENU.Create( "input particle limit", 255, 255, 255, MENU_ID_INPUT_PARTICLE_LIMIT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_PARTICLE_LIMIT,, 10, "%%active_particle_limit%%"  )
	
	all_menus[postfix_index()] = MENU.Create( "preferences", 64, 64, 212, MENU_ID_PREFERENCES, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "controls", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_CONTROLS), True, True ), ..
		MENU_OPTION.Create( "gameplay", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_GAME), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "control preferences", 127, 196, 255, MENU_ID_OPTIONS_CONTROLS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD), True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_XBOX_360_CONTROLLER), True, False ) ])
	
	all_menus[postfix_index()] = MENU.Create( "game data", 196, 196, 196, MENU_ID_GAME_DATA, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "level editor", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LEVEL_EDITOR), True, True ), ..
		MENU_OPTION.Create( "reload external data", COMMAND_LOAD_ASSETS,, True, True ) ])
		
		all_menus[postfix_index()] = MENU.Create( "level editor", 96, 127, 255, MENU_ID_LEVEL_EDITOR, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "edit %%level_editor_cache.name%%", COMMAND_EDIT_LEVEL, level_editor_cache, True, True ), ..
			MENU_OPTION.Create( "save %%level_editor_cache.name%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_LEVEL), True, True ), ..
			MENU_OPTION.Create( "load level", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_LEVEL), True, True ), ..
			MENU_OPTION.Create( "create new", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CONFIRM_ERASE_LEVEL), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "save from level editor", 255, 96, 127, MENU_ID_SAVE_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND_SAVE_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "new file", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_LEVEL_FILE_NAME), True, True )])
				
				all_menus[postfix_index()] = MENU.Create( "input filename", 255, 255, 255, MENU_ID_INPUT_LEVEL_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, level_path, level_file_ext, COMMAND_SAVE_LEVEL,, 60, "%%level_editor_cache.name%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "load into level editor", 96, 255, 127, MENU_ID_LOAD_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND_LOAD_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "abandon current level?", 255, 64, 64, MENU_ID_CONFIRM_ERASE_LEVEL, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND_NEW_LEVEL )

all_menus[postfix_index()] = MENU.Create( "game paused", 96, 96, 96, MENU_ID_PAUSED, MENU.VERTICAL_LIST, menu_margin, -1,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PREFERENCES), True, True ), ..
	MENU_OPTION.Create( "abandon level", COMMAND_QUIT_LEVEL,, True, True ), ..
	MENU_OPTION.Create( "quit game", COMMAND_QUIT_GAME,, True, True ) ])

'______________________________________________________________________________
Global menu_stack%[] = New Int[255]
	menu_stack[0] = MENU_ID_MAIN_MENU
Global current_menu% = 0

Function get_current_menu:MENU()
	Return get_menu( menu_stack[current_menu] )
End Function

Function get_main_menu:MENU()
	Return get_menu( menu_stack[0] )
End Function

Function get_menu:MENU( menu_id% )
	For Local i% = 0 To all_menus.Length - 1
		If all_menus[i] <> Null And all_menus[i].menu_id = menu_id
			Return all_menus[i]
		End If
	Next
	Return Null
End Function

'command_argument should be an object;
'  the object gets cast to an appropriate type automatically, a container type with all the information necessary
'  if the cast fails, the argument is invalid
Function menu_command( command_code%, argument:Object = Null )
	?Debug
		Local arg$ = ""
		If String(argument) Then arg = String(argument)
		If INTEGER(argument) Then arg = menu_id_to_string( INTEGER(argument).value )[8..].ToLower()
		DebugLog( " "+pad( command_code_to_string( command_code )[8..].ToLower(), 26 )+"  "+arg )
	?
	
	Select command_code
		'________________________________________
		Case COMMAND_SHOW_CHILD_MENU
			current_menu :+ 1
			menu_stack[current_menu] = INTEGER(argument).value
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_BACK_TO_PARENT_MENU
			If current_menu > 0 Then current_menu :- 1
			get_current_menu().update()
		'________________________________________
		Case COMMAND_BACK_TO_MAIN_MENU
			FLAG_in_menu = True
			current_menu = 0
			get_current_menu().update()
		'________________________________________
		Case COMMAND_PAUSE
			FLAG_in_menu = True
			current_menu = 1
			menu_stack[current_menu] = MENU_ID_PAUSED
			If main_game <> Null Then main_game.paused = True
			get_current_menu().update()
		'________________________________________
		Case COMMAND_RESUME
			FLAG_in_menu = False
			If main_game <> Null Then main_game.paused = False
			MoveMouse( window_w/2 - 30, window_h/2 )
			FLAG_ignore_mouse_1 = True
		'________________________________________
		Case COMMAND_PLAY_LEVEL
			If profile And profile.vehicle
				play_level( String(argument), create_player( profile.vehicle ))
			End If
		'________________________________________
		Case COMMAND_NEW_GAME
			profile = New PLAYER_PROFILE
			show_info( "new profile loaded" )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_PLAYER_PROFILE_NAME
			profile.name = String(argument)
			profile.src_path = profile.generate_src_path()
			menu_command( COMMAND_SAVE_GAME )
			'menu_command( COMMAND_BACK_TO_PARENT_MENU ) 'save game command does this implicitly
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_LOAD_GAME
			profile = load_game( String(argument) )
			If profile
				save_autosave( profile.src_path )
				show_info( "loaded profile "+profile.name+" from "+profile.src_path )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_SAVE_GAME
			Return
			Return
			Return
			If profile
				If save_game( profile.src_path, profile )
					save_autosave( profile.src_path )
					show_info( "saved profile "+profile.name+" to "+profile.src_path )
				End If
			Else 'Not profile
				save_autosave( Null )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND_MULTIPLAYER_JOIN
		'________________________________________
		Case COMMAND_MULTIPLAYER_HOST
		'________________________________________
		Case COMMAND_NEW_LEVEL
			level_editor_cache = Create_LEVEL( 300, 300 )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "new level loaded" )
		'________________________________________
		Case COMMAND_LOAD_LEVEL
			level_editor_cache = load_level( String(argument) )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "loaded level "+level_editor_cache.name+" from "+String(argument) )
			get_menu( MENU_ID_LEVEL_EDITOR ).recalculate_dimensions() 
		'________________________________________
		Case COMMAND_SAVE_LEVEL
			save_level( String(argument), level_editor_cache )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "saved level "+level_editor_cache.name+" to "+String(argument) )
		'________________________________________
		Case COMMAND_PLAYER_INPUT_TYPE
			If profile <> Null
				profile.input_method = INTEGER(argument).value
			End If
			If game <> Null And game.player_brain <> Null
				game.player_brain.input_type = profile.input_method
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "player input method changed" )
		'________________________________________
		Case COMMAND_SETTINGS_FULLSCREEN
			fullscreen = Not fullscreen
			menu_command( COMMAND_SETTINGS_APPLY_ALL )
			If fullscreen
				show_info( "fullscreen mode" )
			Else
				show_info( "windowed mode" )
			End If
		'________________________________________
		Case COMMAND_SETTINGS_RESOLUTION
			window_w = Int[](argument)[0]
			window_h = Int[](argument)[1]
				window = Create_BOX( 0, 0, window_w, window_h )
			menu_command( COMMAND_SETTINGS_APPLY_ALL )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			init_ai_menu_game()
			If main_game <> Null Then main_game.calculate_camera_constraints()
			show_info( "resolution "+window_w+" x "+window_h )
		'________________________________________
		Case COMMAND_SETTINGS_REFRESH_RATE
			Local new_refresh_rate% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, bit_depth, new_refresh_rate )
				refresh_rate = new_refresh_rate
				menu_command( COMMAND_SETTINGS_APPLY_ALL )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "refresh rate "+refresh_rate+" Hz" )
		'________________________________________
		Case COMMAND_SETTINGS_BIT_DEPTH
			Local new_bit_depth% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, new_bit_depth, refresh_rate )
				bit_depth = new_bit_depth
				menu_command( COMMAND_SETTINGS_APPLY_ALL )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "bit depth "+bit_depth+" bpp" )
		'________________________________________
		Case COMMAND_SETTINGS_IP_ADDRESS
			ip_address = String(argument)
			save_settings()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND_SETTINGS_IP_PORT
			ip_port = String(argument).ToInt()
			save_settings()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND_SETTINGS_SHOW_AI_MENU_GAME
			show_ai_menu_game = Not show_ai_menu_game
			If ai_menu_game And Not show_ai_menu_game
				ai_menu_game = Null
			Else If Not ai_menu_game And show_ai_menu_game
				init_ai_menu_game()
			End If
			save_settings()
		'________________________________________
		Case COMMAND_SETTINGS_RETAIN_PARTICLES
			retain_particles = Not retain_particles
			save_settings()
		'________________________________________
		Case COMMAND_SETTINGS_PARTICLE_LIMIT
			active_particle_limit = String(argument).ToInt()
			save_settings()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND_SETTINGS_APPLY_ALL
			save_settings()
			init_graphics()
			show_info( "video settings changed" )
		'________________________________________
		Case COMMAND_EDIT_LEVEL
			level_editor( level_editor_cache )
		'________________________________________
		Case COMMAND_LOAD_ASSETS
			load_assets()
			MENU.load_fonts()
			load_all_archetypes()
			If show_ai_menu_game
				init_ai_menu_game()
			End If
			show_info( "external data loaded" )
		'________________________________________
		Case COMMAND_QUIT_LEVEL
			FLAG_in_menu = True
			menu_command( COMMAND_SAVE_GAME )
			main_game = Null
			game = ai_menu_game
		'________________________________________
		Case COMMAND_QUIT_GAME
			menu_command( COMMAND_QUIT_LEVEL )
			End
			
	End Select
	get_current_menu().recalculate_dimensions()
	
End Function

'______________________________________________________________________________
Function resolve_meta_variables$( str$ )
	Local tokens$[] = str.Split( "%%" )
	Local result$ = ""
	For Local i% = 0 To tokens.Length - 1
		If i Mod 2 = 1 'odd (and thus, intended as a variable pseudo-identifier)
			Select tokens[i]
				Case "profile.name"
					result :+ profile.name
				Case "profile.cash"
					result :+ format_number( profile.cash )
				Case "profile.kills"
					result :+ format_number( profile.kills )
				Case "level_editor_cache.name"
					result :+ level_editor_cache.name
				Case "fullscreen"
					result :+ boolean_to_string( fullscreen )
				Case "window_w"
					result :+ window_w
				Case "window_h"
					result :+ window_h
				Case "refresh_rate"
					result :+ refresh_rate
				Case "bit_depth"
					result :+ bit_depth
				Case "show_ai_menu_game"
					result :+ boolean_to_string( show_ai_menu_game )
				Case "retain_particles"
					result :+ boolean_to_string( retain_particles )
				Case "active_particle_limit"
					result :+ active_particle_limit
				Case "ip_address"
					result :+ ip_address
				Case "ip_port"
					result :+ ip_port
			End Select
		Else 'even (string literal)
			result :+ tokens[i]
		End If
	Next
	Return result
End Function

'______________________________________________________________________________
Function command_code_to_string$( code% )
	Select code
		Case COMMAND_NULL
			Return "COMMAND_NULL"
		Case COMMAND_LOAD_ASSETS
			Return "COMMAND_LOAD_ASSETS"
		Case COMMAND_SHOW_CHILD_MENU
			Return "COMMAND_SHOW_CHILD_MENU"
		Case COMMAND_BACK_TO_PARENT_MENU
			Return "COMMAND_BACK_TO_PARENT_MENU"
		Case COMMAND_BACK_TO_MAIN_MENU
			Return "COMMAND_BACK_TO_MAIN_MENU"
		Case COMMAND_PLAY_LEVEL
			Return "COMMAND_PLAY_LEVEL"
		Case COMMAND_PAUSE
			Return "COMMAND_PAUSE"
		Case COMMAND_RESUME
			Return "COMMAND_RESUME"
		Case COMMAND_NEW_GAME
			Return "COMMAND_NEW_GAME"
		Case COMMAND_NEW_LEVEL
			Return "COMMAND_NEW_LEVEL"
		Case COMMAND_LOAD_GAME
			Return "COMMAND_LOAD_GAME"
		Case COMMAND_LOAD_LEVEL
			Return "COMMAND_LOAD_LEVEL"
		Case COMMAND_SAVE_GAME
			Return "COMMAND_SAVE_GAME"
		Case COMMAND_SAVE_LEVEL
			Return "COMMAND_SAVE_LEVEL"
		Case COMMAND_EDIT_LEVEL
			Return "COMMAND_EDIT_LEVEL"
		Case COMMAND_MULTIPLAYER_JOIN
			Return "COMMAND_MULTIPLAYER_JOIN"
		Case COMMAND_MULTIPLAYER_HOST
			Return "COMMAND_MULTIPLAYER_HOST"
		Case COMMAND_PLAYER_PROFILE_NAME
			Return "COMMAND_PLAYER_PROFILE_NAME"
		Case COMMAND_PLAYER_PROFILE_PATH
			Return "COMMAND_PLAYER_PROFILE_PATH"
		Case COMMAND_PLAYER_INPUT_TYPE
			Return "COMMAND_PLAYER_INPUT_TYPE"
		Case COMMAND_SETTINGS_FULLSCREEN
			Return "COMMAND_SETTINGS_FULLSCREEN"
		Case COMMAND_SETTINGS_RESOLUTION
			Return "COMMAND_SETTINGS_RESOLUTION"
		Case COMMAND_SETTINGS_REFRESH_RATE
			Return "COMMAND_SETTINGS_REFRESH_RATE"
		Case COMMAND_SETTINGS_BIT_DEPTH
			Return "COMMAND_SETTINGS_BIT_DEPTH"
		Case COMMAND_SETTINGS_IP_ADDRESS
			Return "COMMAND_SETTINGS_IP_ADDRESS"
		Case COMMAND_SETTINGS_IP_PORT
			Return "COMMAND_SETTINGS_IP_PORT"
		Case COMMAND_SETTINGS_SHOW_AI_MENU_GAME
			Return "COMMAND_SETTINGS_SHOW_AI_MENU_GAME"
		Case COMMAND_SETTINGS_RETAIN_PARTICLES
			Return "COMMAND_SETTINGS_RETAIN_PARTICLES"
		Case COMMAND_SETTINGS_PARTICLE_LIMIT
			Return "COMMAND_SETTINGS_PARTICLE_LIMIT"
		Case COMMAND_SETTINGS_APPLY_ALL
			Return "COMMAND_SETTINGS_APPLY_ALL"
		Case COMMAND_QUIT_LEVEL
			Return "COMMAND_QUIT_LEVEL"
		Case COMMAND_QUIT_GAME
			Return "COMMAND_QUIT_GAME"
		Default
			Return String.FromInt( code )
	End Select
End Function
'______________________________________________________________________________
Function menu_id_to_string$( menu_id% )
	Select menu_id
		Case MENU_ID_MAIN_MENU
			Return "MENU_ID_MAIN_MENU"
		Case MENU_ID_LOADING_BAY
			Return "MENU_ID_LOADING_BAY"
		Case MENU_ID_INPUT_PROFILE_NAME
			Return "MENU_ID_INPUT_PROFILE_NAME"
		Case MENU_ID_SELECT_LEVEL
			Return "MENU_ID_SELECT_LEVEL"
		Case MENU_ID_MULTIPLAYER
			Return "MENU_ID_MULTIPLAYER"
		Case MENU_ID_MULTIPLAYER_JOIN
			Return "MENU_ID_MULTIPLAYER_JOIN"
		Case MENU_ID_MULTIPLAYER_HOST
			Return "MENU_ID_MULTIPLAYER_HOST"
		Case MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS
			Return "MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS"
		Case MENU_ID_MULTIPLAYER_INPUT_IP_PORT
			Return "MENU_ID_MULTIPLAYER_INPUT_IP_PORT"
		Case MENU_ID_LOAD_GAME
			Return "MENU_ID_LOAD_GAME"
		Case MENU_ID_CONFIRM_LOAD_GAME
			Return "MENU_ID_CONFIRM_LOAD_GAME"
		Case MENU_ID_LOAD_LEVEL
			Return "MENU_ID_LOAD_LEVEL"
		Case MENU_ID_SAVE_GAME
			Return "MENU_ID_SAVE_GAME"
		Case MENU_ID_INPUT_GAME_FILE_NAME
			Return "MENU_ID_INPUT_GAME_FILE_NAME"
		Case MENU_ID_SAVE_LEVEL
			Return "MENU_ID_SAVE_LEVEL"
		Case MENU_ID_INPUT_LEVEL_FILE_NAME
			Return "MENU_ID_INPUT_LEVEL_FILE_NAME"
		Case MENU_ID_CONFIRM_ERASE_LEVEL
			Return "MENU_ID_CONFIRM_ERASE_LEVEL"
		Case MENU_ID_SETTINGS
			Return "MENU_ID_SETTINGS"
		Case MENU_ID_OPTIONS_PERFORMANCE
			Return "MENU_ID_OPTIONS_PERFORMANCE"
		Case MENU_ID_PREFERENCES
			Return "MENU_ID_PREFERENCES"
		Case MENU_ID_OPTIONS_VIDEO
			Return "MENU_ID_OPTIONS_VIDEO"
		Case MENU_ID_CHOOSE_RESOLUTION
			Return "MENU_ID_CHOOSE_RESOLUTION"
		Case MENU_ID_INPUT_REFRESH_RATE
			Return "MENU_ID_INPUT_REFRESH_RATE"
		Case MENU_ID_INPUT_BIT_DEPTH
			Return "MENU_ID_INPUT_BIT_DEPTH"
		Case MENU_ID_INPUT_PARTICLE_LIMIT
			Return "MENU_ID_INPUT_PARTICLE_LIMIT"
		Case MENU_ID_OPTIONS_AUDIO
			Return "MENU_ID_OPTIONS_AUDIO"
		Case MENU_ID_OPTIONS_CONTROLS
			Return "MENU_ID_OPTIONS_CONTROLS"
		Case MENU_ID_OPTIONS_GAME
			Return "MENU_ID_OPTIONS_GAME"
		Case MENU_ID_GAME_DATA
			Return "MENU_ID_GAME_DATA"
		Case MENU_ID_LEVEL_EDITOR
			Return "MENU_ID_LEVEL_EDITOR"
		Case MENU_ID_PAUSED
			Return "MENU_ID_PAUSED"
		Default
			Return String.FromInt( menu_id )
	End Select
End Function

