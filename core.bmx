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
Global FLAG_in_shop% = False
Global FLAG_bg_music_on% = False
Global FLAG_no_sound% = False
Global FLAG_draw_help% = False
Global FLAG_console% = False
Global FLAG_ignore_mouse_1% = False

'______________________________________________________________________________
Type PLAYER_PROFILE
	Field profile_name$
	Field inventory%[]
	Field input_method%
	Field current_level$
	Field cash%
	Field kills%

	Field src_path$
	Field selected_inventory_index%
		
	Method New()
		profile_name = "new_profile"
		inventory = Null
		input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
		cash = shop_item_prices[0]
		src_path = ""
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "profile_name", TJSONString.Create( profile_name ))
		this_json.SetByName( "inventory", Create_TJSONArray_from_Int_array( inventory ))
		this_json.SetByName( "input_method", TJSONNumber.Create( input_method ))
		this_json.SetByName( "current_level", TJSONString.Create( current_level ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		this_json.SetByName( "selected_inventory_index", TJSONNumber.Create( selected_inventory_index ))
		Return this_json
	End Method
End Type

Function Create_PLAYER_PROFILE_from_json:PLAYER_PROFILE( json:TJSON )
	Local prof:PLAYER_PROFILE = New PLAYER_PROFILE
	prof.profile_name = json.GetString( "profile_name" )
	prof.inventory = Create_Int_array_from_TJSONArray( json.GetArray( "inventory" ))
	prof.input_method = json.GetNumber( "input_method" )
	prof.current_level = json.GetString( "current_level" )
	prof.cash = json.GetNumber( "cash" )
	prof.kills = json.GetNumber( "kills" )
	prof.selected_inventory_index = json.GetNumber( "selected_inventory_index" )
	Return prof
End Function
'______________________________________________________________________________
Function play_level( level_file_path$, player_archetype% )
	main_game = Create_ENVIRONMENT( True )
	Local success% = main_game.load_level( level_file_path )
	If success
		main_game.game_in_progress = True
		Local player:COMPLEX_AGENT = create_player( player_archetype )
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		main_game.insert_player( player, player_brain )
		main_game.respawn_player()
		FLAG_in_menu = False
		FLAG_in_shop = False
		main_game.player_in_locker = True
		main_game.waiting_for_player_to_enter_arena = True
		MoveMouse( window_w/2 - 30, window_h/2 )
	Else
		main_game = Null
	End If
End Function
'______________________________________________________________________________
Function create_player:COMPLEX_AGENT( archetype% )
	Return COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype], ALIGNMENT_FRIENDLY ))
End Function
'______________________________________________________________________________
Function create_player_brain:CONTROL_BRAIN( avatar:COMPLEX_AGENT )
	Return Create_CONTROL_BRAIN( avatar, CONTROL_BRAIN.CONTROL_TYPE_HUMAN, profile.input_method )
End Function

'______________________________________________________________________________
Function record_player_kill( cash_value% )
	If profile <> Null
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
Function init_ai_menu_game()
	ai_menu_game = Create_ENVIRONMENT()

	ai_menu_game.auto_reset_spawners = True
	ai_menu_game.game_in_progress = True
	ai_menu_game.battle_in_progress = True
	ai_menu_game.battle_state_toggle_ts = now()
	ai_menu_game.spawn_enemies = True
	ai_menu_game.mouse = mouse
	
	Local lev:LEVEL = Create_LEVEL( window_w, window_h )
	Local sp:SPAWNER, squad%

	sp = New SPAWNER
	sp.pos = Create_POINT( window_w/2, 25, 90 )
	sp.class = SPAWNER.class_TURRET_ANCHOR
	sp.alignment = ALIGNMENT_FRIENDLY
	squad = sp.add_new_squad()
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.set_delay_time( squad, 500 )
	lev.add_spawner( sp )

	sp = New SPAWNER
	sp.pos = Create_POINT( window_w/2, window_h - 25, -90 )
	sp.class = SPAWNER.class_TURRET_ANCHOR
	sp.alignment = ALIGNMENT_HOSTILE
	squad = sp.add_new_squad()
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_QUAD )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.add_new_squadmember( squad, ENEMY_INDEX_LIGHT_TANK )
	sp.set_delay_time( squad, 500 )
	lev.add_spawner( sp )

	lev.add_divider( 15, LINE_TYPE_VERTICAL )
	lev.add_divider( window_w - 15, LINE_TYPE_VERTICAL )
	lev.add_divider( window_w/2 - window_w/3,  LINE_TYPE_VERTICAL )
	lev.add_divider( window_w/2 + window_w/3,  LINE_TYPE_VERTICAL )
	lev.add_divider( 15, LINE_TYPE_HORIZONTAL )
	lev.add_divider( window_h - 15, LINE_TYPE_HORIZONTAL )
	lev.add_divider( window_h/2 - window_h/16, LINE_TYPE_HORIZONTAL )
	lev.add_divider( window_h/2 + window_h/16, LINE_TYPE_HORIZONTAL )
	
	lev.set_path_region( CELL.Create( 0, 0 ), True )
	lev.set_path_region( CELL.Create( 0, 1 ), True )
	lev.set_path_region( CELL.Create( 0, 2 ), True )
	lev.set_path_region( CELL.Create( 0, 3 ), True )
	lev.set_path_region( CELL.Create( 0, 4 ), True )
	lev.set_path_region( CELL.Create( 1, 0 ), True )
	lev.set_path_region( CELL.Create( 1, 4 ), True )
	lev.set_path_region( CELL.Create( 2, 0 ), True )
	lev.set_path_region( CELL.Create( 2, 2 ), True )
	lev.set_path_region( CELL.Create( 2, 4 ), True )
	lev.set_path_region( CELL.Create( 3, 0 ), True )
	lev.set_path_region( CELL.Create( 3, 4 ), True )
	lev.set_path_region( CELL.Create( 4, 0 ), True )
	lev.set_path_region( CELL.Create( 4, 1 ), True )
	lev.set_path_region( CELL.Create( 4, 2 ), True )
	lev.set_path_region( CELL.Create( 4, 3 ), True )
	lev.set_path_region( CELL.Create( 4, 4 ), True )
	
	lev.add_divider(  1*window_w/16, LINE_TYPE_VERTICAL )
	lev.add_divider( 15*window_w/16, LINE_TYPE_VERTICAL )
	lev.add_divider( 1*window_w/4, LINE_TYPE_VERTICAL )
	lev.add_divider( 3*window_w/4, LINE_TYPE_VERTICAL )
	lev.add_divider( 1*window_h/4, LINE_TYPE_HORIZONTAL )
	lev.add_divider( 3*window_h/4, LINE_TYPE_HORIZONTAL )
	lev.add_divider( window_w/2 - window_w/8, LINE_TYPE_VERTICAL )
	lev.add_divider( window_w/2 + window_w/8, LINE_TYPE_VERTICAL )
	lev.add_divider( window_w/2 - 2*window_w/8, LINE_TYPE_VERTICAL )
	lev.add_divider( window_w/2 + 2*window_w/8, LINE_TYPE_VERTICAL )

	ai_menu_game.load_level( lev )
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
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_BACK_TO_MAIN_MENU% = 53
Const COMMAND_RESUME% = 100
Const COMMAND_SHOP% = 150
Const COMMAND_NEW_GAME% = 200
Const COMMAND_NEW_LEVEL% = 201
Const COMMAND_LOAD_GAME% = 300
Const COMMAND_LOAD_LEVEL% = 301
Const COMMAND_SAVE_GAME% = 400
Const COMMAND_SAVE_LEVEL% = 401
Const COMMAND_EDIT_LEVEL% = 500
Const COMMAND_MULTIPLAYER_JOIN% = 600
Const COMMAND_MULTIPLAYER_HOST% = 700
Const COMMAND_PLAYER_INPUT_TYPE% = 1000
Const COMMAND_SETTINGS_FULLSCREEN% = 1010
Const COMMAND_SETTINGS_RESOLUTION% = 1020
Const COMMAND_SETTINGS_REFRESH_RATE% = 1030
Const COMMAND_SETTINGS_BIT_DEPTH% = 1040
Const COMMAND_SETTINGS_IP_ADDRESS% = 1050
Const COMMAND_SETTINGS_IP_PORT% = 1060
Const COMMAND_SETTINGS_PARTICLE_LIMIT% = 1070
Const COMMAND_SETTINGS_APPLY_ALL% = 1100
Const COMMAND_PAUSE% = 10000
Const COMMAND_QUIT_LEVEL% = 10010
Const COMMAND_QUIT_GAME% = 65535

Const MENU_ID_MAIN_MENU% = 100
Const MENU_ID_NEW_GAME% = 200
Const MENU_ID_MULTIPLAYER% = 250
Const MENU_ID_MULTIPLAYER_JOIN% = 260
Const MENU_ID_MULTIPLAYER_HOST% = 270
Const MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS% = 280
Const MENU_ID_MULTIPLAYER_INPUT_IP_PORT% = 281
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
Const MENU_ID_EDITORS% = 600
Const MENU_ID_LEVEL_EDITOR% = 610
Const MENU_ID_PAUSED% = 1000

Global menu_margin% = 8
Global dynamic_subsection_window_size% = 8
Global all_menus:MENU[50]
Global pause_menu:MENU
reset_index()

all_menus[postfix_index()] = MENU.Create( "main menu", 255, 255, 127, MENU_ID_MAIN_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, False ), ..
	MENU_OPTION.Create( "loading bay", COMMAND_SHOP,, True, False ), ..
	MENU_OPTION.Create( "new", COMMAND_NEW_GAME,, True, True ), ..
	MENU_OPTION.Create( "save", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_GAME), True, False ), ..
	MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_GAME), True, True ), ..
	MENU_OPTION.Create( "multiplayer", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_MULTIPLAYER), False, False ), ..
	MENU_OPTION.Create( "settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PREFERENCES), True, False ), ..
	MENU_OPTION.Create( "editors", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_EDITORS), True, True ), ..
	MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "save game", 255, 96, 127, MENU_ID_SAVE_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND_SAVE_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "new file", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_GAME_FILE_NAME), True, True )])

		all_menus[postfix_index()] = MENU.Create( "input filename", 255, 255, 255, MENU_ID_INPUT_GAME_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, user_path, saved_game_file_ext, COMMAND_SAVE_GAME,, 60, "%%profile.profile_name%%"  )
	
	all_menus[postfix_index()] = MENU.Create( "load game", 96, 255, 127, MENU_ID_LOAD_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND_LOAD_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])

		'all_menus[postfix_index()] = MENU.Create( "abandon current game?", 255, 64, 64, MENU_ID_CONFIRM_LOAD_GAME, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,,, COMMAND_LOAD_GAME )

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
			MENU_OPTION.Create( "particle limit  %%retained_particle_count_limit%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_PARTICLE_LIMIT), True, True ) ])

			all_menus[postfix_index()] = MENU.Create( "input particle limit", 255, 255, 255, MENU_ID_INPUT_PARTICLE_LIMIT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_PARTICLE_LIMIT,, 10, "%%retained_particle_count_limit%%"  )
	
	all_menus[postfix_index()] = MENU.Create( "preferences", 64, 64, 212, MENU_ID_PREFERENCES, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "controls", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_CONTROLS), True, True ), ..
		MENU_OPTION.Create( "gameplay", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_GAME), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "control preferences", 127, 196, 255, MENU_ID_OPTIONS_CONTROLS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD), True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_XBOX_360_CONTROLLER), True, False ) ])
	
	all_menus[postfix_index()] = MENU.Create( "editors", 196, 196, 196, MENU_ID_EDITORS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "level editor", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LEVEL_EDITOR), True, True ) ])
		
		all_menus[postfix_index()] = MENU.Create( "level editor", 96, 127, 255, MENU_ID_LEVEL_EDITOR, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "edit %%level_editor_cache.name%%", COMMAND_EDIT_LEVEL, level_editor_cache, True, True ), ..
			MENU_OPTION.Create( "save", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_LEVEL), True, True ), ..
			MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_LEVEL), True, True ), ..
			MENU_OPTION.Create( "new", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CONFIRM_ERASE_LEVEL), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "save from level editor", 255, 96, 127, MENU_ID_SAVE_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, data_path, level_file_ext, COMMAND_SAVE_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "new file", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_LEVEL_FILE_NAME), True, True )])
				
				all_menus[postfix_index()] = MENU.Create( "input filename", 255, 255, 255, MENU_ID_INPUT_LEVEL_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, data_path, level_file_ext, COMMAND_SAVE_LEVEL,, 60, "%%level_editor_cache.name%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "load into level editor", 96, 255, 127, MENU_ID_LOAD_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, data_path, level_file_ext, COMMAND_LOAD_LEVEL,,,, dynamic_subsection_window_size, ..
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
			FLAG_in_shop = False
			current_menu = 0
			get_current_menu().update()
		'________________________________________
		Case COMMAND_PAUSE
			FLAG_in_menu = True
			FLAG_in_shop = False
			current_menu = 1
			menu_stack[1] = MENU_ID_PAUSED
			If main_game <> Null Then main_game.paused = True
			get_current_menu().update()
		'________________________________________
		Case COMMAND_RESUME
			FLAG_in_menu = False
			If main_game <> Null Then main_game.paused = False
			MoveMouse( window_w/2 - 30, window_h/2 )
			FLAG_ignore_mouse_1 = True
		'________________________________________
		Case COMMAND_SHOP
			FLAG_in_menu = False
			FLAG_in_shop = True
		'________________________________________
		Case COMMAND_NEW_GAME
			profile = New PLAYER_PROFILE
			show_info( "new profile loaded" )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_LOAD_GAME
			profile = load_game( String(argument) )
			If profile
				save_autosave( profile.src_path )
				show_info( "loaded profile "+profile.profile_name+" from "+profile.src_path )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_SAVE_GAME
			If save_game( String(argument), profile )
				save_autosave( profile.src_path )
				show_info( "saved profile "+profile.profile_name+" to "+profile.src_path )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		''________________________________________
		'Case COMMAND_MULTIPLAYER_JOIN
		'	join_game()
		''________________________________________
		'Case COMMAND_MULTIPLAYER_HOST
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
			get_menu( MENU_ID_SETTINGS ).recalculate_dimensions()
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
			get_menu( MENU_ID_SETTINGS ).recalculate_dimensions()
		'________________________________________
		Case COMMAND_SETTINGS_REFRESH_RATE
			Local new_refresh_rate% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, bit_depth, new_refresh_rate )
				refresh_rate = new_refresh_rate
				menu_command( COMMAND_SETTINGS_APPLY_ALL )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "refresh rate "+refresh_rate+" Hz" )
			get_menu( MENU_ID_SETTINGS ).recalculate_dimensions()
		'________________________________________
		Case COMMAND_SETTINGS_BIT_DEPTH
			Local new_bit_depth% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, new_bit_depth, refresh_rate )
				bit_depth = new_bit_depth
				menu_command( COMMAND_SETTINGS_APPLY_ALL )
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			show_info( "bit depth "+bit_depth+" bpp" )
			get_menu( MENU_ID_SETTINGS ).recalculate_dimensions()
		'________________________________________
		Case COMMAND_SETTINGS_IP_ADDRESS
			ip_address = String(argument)
			save_settings()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			get_menu( MENU_ID_SETTINGS ).recalculate_dimensions()
		'________________________________________
		Case COMMAND_SETTINGS_IP_PORT
			ip_port = String(argument).ToInt()
			save_settings()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			get_menu( MENU_ID_SETTINGS ).recalculate_dimensions()
		'________________________________________
		Case COMMAND_SETTINGS_PARTICLE_LIMIT
			retained_particle_count_limit = String(argument).ToInt()
			save_settings()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			get_menu( MENU_ID_OPTIONS_PERFORMANCE ).recalculate_dimensions()
		'________________________________________
		Case COMMAND_SETTINGS_APPLY_ALL
			save_settings()
			init_graphics()
			show_info( "video settings changed" )
		'________________________________________
		Case COMMAND_EDIT_LEVEL
			level_editor( level_editor_cache )
		'________________________________________
		Case COMMAND_QUIT_LEVEL
			menu_command( COMMAND_SHOP )
			menu_command( COMMAND_SAVE_GAME, profile.src_path )
			main_game = Null
			game = ai_menu_game
		'________________________________________
		Case COMMAND_QUIT_GAME
			menu_command( COMMAND_QUIT_LEVEL )
			End
			
	End Select
End Function

Type INTEGER
	Field value%
	Function Create:INTEGER( value% )
		Local i:INTEGER = New INTEGER; i.value = value;	Return i
	End Function
End Type

Function resolve_meta_variables$( str$ )
	Local tokens$[] = str.Split( "%%" )
	Local result$ = ""
	For Local i% = 0 To tokens.Length - 1
		If i Mod 2 = 1 'odd (and thus, intended as a variable pseudo-identifier)
			Select tokens[i]
				Case "level_editor_cache.name"
					result :+ level_editor_cache.name
				Case "profile.profile_name"
					result :+ profile.profile_name
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
				Case "retained_particle_count_limit"
					result :+ retained_particle_count_limit
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


