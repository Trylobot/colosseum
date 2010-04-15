Rem
	core_menus.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'This file must be Include'd by core.bmx

'______________________________________________________________________________
Global menu_stack:TList = CreateList()

Function get_current_menu:TUIList()
	If menu_stack.IsEmpty()
		DebugLog( "menu stack is empty :(" )
		DebugStop
		Return Null
	End If
	Return TUIList(menu_stack.Last())
End Function

Function push_menu( menu_list:TUIList )
	menu_stack.AddLast( menu_list )
End Function

Function pop_menu()
	'prevent removal of root menu
	If menu_stack.Count() > 1
		menu_stack.RemoveLast()
	End If
End Function

Type MENU
	Global root:TUIList
	Global pause:TUIList
End Type

'______________________________________________________________________________
Function initialize_menus()
	Local menu_fg_font:BMP_FONT = get_bmp_font( "arcade_21" )
	Local menu_bg_font:BMP_FONT = get_bmp_font( "arcade_21_outline" )
	
	MENU.root = TUIList.Create( ..
		[ "", "", "", "", "" ], ..
		[ "PLAY GAME", "PROFILE", "SETTINGS", "ADVANCED", "QUIT" ], ..
		5, ..
		[ 127, 127, 127 ], ..
		[ 255, 255, 255 ], ..
		[ 0, 0, 0 ], ..
		[ 255, 255, 255 ], ..
		2, ..
		FONT_STYLE.Create( menu_fg_font, menu_bg_font, [255, 255, 255], [0, 0, 0] ), ..
		FONT_STYLE.Create( menu_fg_font, menu_bg_font, [0, 0, 0], [205, 205, 205] ), ..
		10, 50 )
	MENU.root.add_item_clicked_event_handler( 0, cmd_show_menu )
	MENU.root.add_item_clicked_event_handler( 1, cmd_show_menu )
	MENU.root.add_item_clicked_event_handler( 2, cmd_show_menu )
	MENU.root.add_item_clicked_event_handler( 3, cmd_show_menu )
	MENU.root.add_item_clicked_event_handler( 4, cmd_quit_game )
	push_menu( MENU.root )
	
	

End Function

'______________________________________________________________________________
Rem
Global menu_margin% = 8
Global dynamic_subsection_window_size% = 8
Global all_menus:MENU[50]
Global pause_menu:MENU
Global menu_stack%[] = New Int[255]
	menu_stack[0] = MENU_ID.MAIN_MENU
Global current_menu% = 0

Function get_current_menu:MENU()
	Return get_menu( menu_stack[current_menu] )
End Function

Function get_main_menu:MENU()
	Return get_menu( menu_stack[0] )
End Function

Function get_menu:MENU( id% )
	For Local i% = 0 To all_menus.Length - 1
		If all_menus[i] <> Null And all_menus[i].id = id
			Return all_menus[i]
		End If
	Next
	Return Null
End Function

Global array_index%

Function reset_index()
	array_index = 0
End Function

Function postfix_index%( amount% = 1 )
	array_index :+ amount
	Return (array_index - amount)
End Function


'______________________________________________________________________________
Local m:MENU
reset_index()
'special characters ●

all_menus[postfix_index()] = MENU.Create( "Colosseum", "main", 255, 255, 127, MENU_ID.MAIN_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
[	MENU_OPTION.Create( "play game", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LOADING_BAY), True, False ), ..
	MENU_OPTION.Create( "profile", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.PROFILE_MENU), True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SETTINGS), True, True ), ..
	MENU_OPTION.Create( "advanced", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.GAME_DATA), True, True ), ..
	MENU_OPTION.Create( "quit", COMMAND.QUIT_GAME,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "profile", "profile", 255, 96, 127, MENU_ID.PROFILE_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "create new", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CONFIRM_NEW_GAME), True, True ), ..
		MENU_OPTION.Create( "save ● %%profile.name%%", COMMAND.SAVE_GAME,, True, False ), ..
		MENU_OPTION.Create( "load profile", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LOAD_GAME), True, True ), ..
		MENU_OPTION.Create( "preferences", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.PREFERENCES), True, False ), ..
		MENU_OPTION.Create( "change name", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_PROFILE_NAME), True, True ) ])

	all_menus[postfix_index()] = MENU.Create( "game menu ● %%profile.name%%", "game", 255, 96, 64, MENU_ID.LOADING_BAY, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "continue game", COMMAND.CONTINUE_LAST_CAMPAIGN,, True, False ), ..
		MENU_OPTION.Create( "start campaign", COMMAND.SELECT_CAMPAIGN,, True, True ), ..
		MENU_OPTION.Create( "choose level", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SELECT_LEVEL), True, True ), ..
		MENU_OPTION.Create( "multiplayer", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.MULTIPLAYER), True, True ), ..
		MENU_OPTION.Create( "buy items", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.BUY_PARTS), True, False ), ..
		MENU_OPTION.Create( "sell items", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SELL_PARTS), True, False ) ])
	
		all_menus[postfix_index()] = MENU.Create( "select level", "level", 96, 255, 127, MENU_ID.SELECT_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.PLAY_LEVEL,,,, dynamic_subsection_window_size, ..
		Null )
	
		all_menus[postfix_index()] = MENU.Create( "play multiplayer", "multi", 196, 96, 96, MENU_ID.MULTIPLAYER, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "join server", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.MULTIPLAYER_JOIN_GAME), True, True ), ..
			MENU_OPTION.Create( "create new server", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.MULTIPLAYER_CREATE_GAME), True, True ) ])
		
			all_menus[postfix_index()] = MENU.Create( "join game", "multi", 196, 96, 96, MENU_ID.MULTIPLAYER_JOIN_GAME, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
			[	MENU_OPTION.Create( "IP address ● %%network_ip_address%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_NETWORK_IP_ADDRESS), True, True ), ..
				MENU_OPTION.Create( "port       ● %%network_port%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_NETWORK_PORT), True, True ), ..
				MENU_OPTION.Create( "join", COMMAND.CONNECT_TO_NETWORK_GAME,, True, True ) ])
	
				all_menus[postfix_index()] = MENU.Create( "input IP address", "input", 255, 255, 255, MENU_ID.INPUT_NETWORK_IP_ADDRESS, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.NETWORK_IP_ADDRESS,, 25, "%%network_ip_address%%" )

				all_menus[postfix_index()] = MENU.Create( "input port", "input", 255, 255, 255, MENU_ID.INPUT_NETWORK_PORT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.NETWORK_PORT,, 8, "%%network_port%%" )

			all_menus[postfix_index()] = MENU.Create( "create game", "multi", 196, 96, 96, MENU_ID.MULTIPLAYER_CREATE_GAME, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
			[	MENU_OPTION.Create( "server port ● %%network_port%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_NETWORK_PORT), True, True ), ..
				MENU_OPTION.Create( "level       ● %%network_level%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SELECT_NETWORK_LEVEL), True, True ), ..
				MENU_OPTION.Create( "start", COMMAND.HOST_NETWORK_GAME,, True, True ) ])
				
				all_menus[postfix_index()] = MENU.Create( "select level", "level", 96, 255, 127, MENU_ID.SELECT_NETWORK_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.NETWORK_LEVEL,,,, dynamic_subsection_window_size, ..
				Null )
	
		all_menus[postfix_index()] = MENU.Create( "buy parts ● $%%profile.cash%%", "buy", 96, 233, 96, MENU_ID.BUY_PARTS, MENU.VERTICAL_LIST_WITH_INVENTORY, menu_margin,, "catalog",, COMMAND.BUY_PART,,,, dynamic_subsection_window_size, ..
		Null )
	
		all_menus[postfix_index()] = MENU.Create( "sell parts ● $%%profile.cash%%", "sell", 244, 96, 244, MENU_ID.SELL_PARTS, MENU.VERTICAL_LIST_WITH_INVENTORY, menu_margin,, "inventory",, COMMAND.SELL_PART,,,, dynamic_subsection_window_size, ..
		Null )

		all_menus[postfix_index()] = MENU.Create( "input profile name", "input", 255, 255, 255, MENU_ID.INPUT_PROFILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.PLAYER_PROFILE_NAME,, 20, "%%profile.name%%" )
		
	all_menus[postfix_index()] = MENU.Create( "unsaved progress, continue?", "confirm", 255, 64, 64, MENU_ID.CONFIRM_NEW_GAME, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND.NEW_GAME )

	all_menus[postfix_index()] = MENU.Create( "load profile", "load", 96, 255, 127, MENU_ID.LOAD_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND.LOAD_GAME,,,, dynamic_subsection_window_size, ..
	Null )
	
	all_menus[postfix_index()] = MENU.Create( "settings", "settings", 127, 127, 255, MENU_ID.SETTINGS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "video settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_VIDEO), True, True ), ..
		MENU_OPTION.Create( "audio settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_AUDIO), True, True ), ..
		MENU_OPTION.Create( "performance settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_PERFORMANCE), True, True ) ])

		all_menus[postfix_index()] = MENU.Create( "video settings", "video", 212, 96, 226, MENU_ID.OPTIONS_VIDEO, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "fullscreen   ● %%fullscreen%%", COMMAND.SETTINGS_FULLSCREEN,, True, True ), ..
			MENU_OPTION.Create( "resolution   ● %%window_w%% x %%window_h%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CHOOSE_RESOLUTION), True, True ), ..
			MENU_OPTION.Create( "refresh rate ● %%refresh_rate%% Hz", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_REFRESH_RATE), True, True ), ..
			MENU_OPTION.Create( "bit depth    ● %%bit_depth%% bpp", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_BIT_DEPTH), True, True ), ..
			MENU_OPTION.Create( "apply", COMMAND.SETTINGS_APPLY_ALL,, False, False ) ])
			
			all_menus[postfix_index()] = MENU.Create( "choose resolution", "resolution", 255, 255, 255, MENU_ID.CHOOSE_RESOLUTION, MENU.VERTICAL_LIST_WITH_SUBSECTION, menu_margin,,,,,,,, dynamic_subsection_window_size, ..
			Null )
			m = get_menu(MENU_ID.CHOOSE_RESOLUTION)
			m.static_option_count = 0
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
					m.add_option( MENU_OPTION.Create( "" + modes[i].width + " x " + modes[i].height, COMMAND.SETTINGS_RESOLUTION, [ modes[i].width, modes[i].height ], True, True ))
				End If
			Next
			
			all_menus[postfix_index()] = MENU.Create( "input refresh rate", "input", 255, 255, 255, MENU_ID.INPUT_REFRESH_RATE, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.SETTINGS_REFRESH_RATE,, 10, "%%refresh_rate%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "input bit depth", "input", 255, 255, 255, MENU_ID.INPUT_BIT_DEPTH, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.SETTINGS_BIT_DEPTH,, 10, "%%bit_depth%%"  )
		
		all_menus[postfix_index()] = MENU.Create( "performance settings", "performance", 212, 226, 96, MENU_ID.OPTIONS_PERFORMANCE, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "background menu game  ● %%show_ai_menu_game%%", COMMAND.SETTINGS_SHOW_AI_MENU_GAME,, True, True ), ..
			MENU_OPTION.Create( "active particle limit ● %%active_particle_limit%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_PARTICLE_LIMIT), True, True ) ])

			all_menus[postfix_index()] = MENU.Create( "input particle limit", "input", 255, 255, 255, MENU_ID.INPUT_PARTICLE_LIMIT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.SETTINGS_PARTICLE_LIMIT,, 10, "%%active_particle_limit%%"  )
		
		all_menus[postfix_index()] = MENU.Create( "audio settings", "audio", 212, 96, 226, MENU_ID.OPTIONS_AUDIO, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "audio driver ● %%audio_driver%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CHOOSE_AUDIO_DRIVER), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "choose audio driver", "audio", 255, 255, 255, MENU_ID.CHOOSE_AUDIO_DRIVER, MENU.VERTICAL_LIST_WITH_SUBSECTION, menu_margin,,,,,,,, dynamic_subsection_window_size, ..
			Null )
			m = get_menu(MENU_ID.CHOOSE_AUDIO_DRIVER)
			m.static_option_count = 0
			Local audio_drivers$[] = AudioDrivers()
			For Local i% = 0 Until audio_drivers.Length
				If audio_drivers[i] <> "Null"
					m.add_option( MENU_OPTION.Create( audio_drivers[i], COMMAND.SETTINGS_AUDIO, audio_drivers[i], True, True ))
				End If
			Next
		
	all_menus[postfix_index()] = MENU.Create( "preferences", "preferences", 64, 64, 212, MENU_ID.PREFERENCES, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "controls", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_CONTROLS), True, True ), ..
		MENU_OPTION.Create( "invert reverse steering ● %%profile.invert_reverse_steering%%", COMMAND.PLAYER_INVERT_REVERSE_STEERING,, True, True ), ..
		MENU_OPTION.Create( "gameplay", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_GAME), True, False ) ])
		
		all_menus[postfix_index()] = MENU.Create( "control preferences", "controls", 127, 196, 255, MENU_ID.OPTIONS_CONTROLS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "keyboard only", COMMAND.PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD), True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND.PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND.PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_XBOX_360_CONTROLLER), True, False ) ])
	
	all_menus[postfix_index()] = MENU.Create( "advanced", "advanced", 196, 196, 196, MENU_ID.GAME_DATA, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "level editor", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LEVEL_EDITOR), True, True ), ..
		MENU_OPTION.Create( "unit editor", COMMAND.EDIT_VEHICLE,, True, True ), ..
		MENU_OPTION.Create( "reload external data", COMMAND.LOAD_ASSETS,, True, True ) ])
		
		all_menus[postfix_index()] = MENU.Create( "level editor", "editor", 96, 127, 255, MENU_ID.LEVEL_EDITOR, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "edit ● %%level_editor_cache.name%%", COMMAND.EDIT_LEVEL, level_editor_cache, True, True ), ..
			MENU_OPTION.Create( "save ● %%level_editor_cache.name%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SAVE_LEVEL), True, True ), ..
			MENU_OPTION.Create( "load level", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LOAD_LEVEL), True, True ), ..
			MENU_OPTION.Create( "create new", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CONFIRM_ERASE_LEVEL), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "save from level editor", "save", 255, 96, 127, MENU_ID.SAVE_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.SAVE_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "new file", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_LEVEL_FILE_NAME), True, True )])
				
				all_menus[postfix_index()] = MENU.Create( "input filename", "input", 255, 255, 255, MENU_ID.INPUT_LEVEL_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, level_path, level_file_ext, COMMAND.SAVE_LEVEL,, 60, "%%level_editor_cache.name%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "load into level editor", "load", 96, 255, 127, MENU_ID.LOAD_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.LOAD_LEVEL,,,, dynamic_subsection_window_size, ..
			Null )
			
			all_menus[postfix_index()] = MENU.Create( "abandon current level?", "confirm", 255, 64, 64, MENU_ID.CONFIRM_ERASE_LEVEL, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND.NEW_LEVEL )

all_menus[postfix_index()] = MENU.Create( "game paused", "pause", 96, 96, 96, MENU_ID.PAUSED, MENU.VERTICAL_LIST, menu_margin, -1,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND.RESUME,, True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.PREFERENCES), True, True ), ..
	MENU_OPTION.Create( "abandon level", COMMAND.QUIT_LEVEL,, True, True ), ..
	MENU_OPTION.Create( "quit game", COMMAND.QUIT_GAME,, True, True ) ])

EndRem

