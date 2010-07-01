Rem
	core_menus.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'This file must be Include'd by core.bmx

'______________________________________________________________________________
Type MENU_REGISTER
	Global stack:TList
	
	Global root:TUIList
	Global play_game:TUIList
	Global level_select:TUIImageGrid
	Global pause:TUIList
	
	Function push( m:TUIObject )
		stack.AddLast( m )
	End Function
	
	Function pop()
		If stack.Last() <> root
			stack.RemoveLast()
		End If
	End Function
	
	Function get_top:TUIObject()
		Return TUIObject(stack.Last())
	End Function
	
End Type

'______________________________________________________________________________
Global g_idx% = 0

Function idx%( reset% = False )
	If reset
		g_idx = -1
	Else
		g_idx :+ 1
	End If
	Return g_idx
End Function

'______________________________________________________________________________
Function initialize_menus()
	Local white:TColor           = TColor.Create_by_RGB( 255, 255, 255 )
	Local light_gray:TColor      = TColor.Create_by_RGB( 205, 205, 205 )
	Local dark_gray:TColor       = TColor.Create_by_RGB(  78,  78,  78 )
	Local black:TColor           = TColor.Create_by_RGB(   0,   0,   0 )
	Local bright_yellow:TColor   = TColor.Create_by_RGB( 255, 255, 127 )
	Local dark_yellow:TColor     = TColor.Create_by_RGB( 127, 127,  63 )
	Local cornflower_blue:TColor = TColor.Create_by_RGB( 100, 149, 237 )
	
	Local menu_header_fg_font:BMP_FONT = get_bmp_font( "arcade_28" )
	Local menu_header_bg_font:BMP_FONT = get_bmp_font( "arcade_28_outline" )
	Local menu_item_fg_font:BMP_FONT = get_bmp_font( "arcade_21" )
	Local menu_item_bg_font:BMP_FONT = get_bmp_font( "arcade_21_outline" )
	Local menu_small_item_fg_font:BMP_FONT = get_bmp_font( "arcade_14" )
	Local menu_small_item_bg_font:BMP_FONT = get_bmp_font( "arcade_14_outline" )
	Local menu_super_small_item_fg_font:BMP_FONT = get_bmp_font( "arcade_7" )
	Local menu_super_small_item_bg_font:BMP_FONT = get_bmp_font( "arcade_7_outline" )
	Local menu_line_width% = 3
	Local menu_small_line_width% = 2
	Local menu_x% = 10, menu_y% = 70
	
	MENU_REGISTER.stack = CreateList()
	
	Local pause_menu:TUIList = New TUIList
	Local root_menu:TUIList = New TUIList
		Local level_select_menu:TUIImageGrid = New TUIImageGrid
		Local profile_menu:TUIList = New TUIList
		Local settings_menu:TUIList = New TUIList
			Local video_settings_menu:TUIList = New TUIList
				Local screen_mode_menu:TUIList = New TUIList
				Local screen_resolution_menu:TUIList = New TUIList
				Local screen_refresh_rate_menu:TUIList = New TUIList
				Local screen_bit_depth_menu:TUIList = New TUIList
			Local audio_settings_menu:TUIList = New TUIList
			Local performance_settings_menu:TUIList = New TUIList
		Local advanced_menu:TUIList = New TUIList
	
	'/////////////////
	
	root_menu.Construct( ..
		"COLOSSEUM", 5, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		bright_yellow, dark_yellow, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	root_menu.set_item( idx(), "START", cmd_show_menu, level_select_menu )
	root_menu.set_item( idx(), "PROFILE", cmd_show_menu, profile_menu )
	root_menu.set_item( idx(), "SETTINGS", cmd_show_menu, settings_menu )
	root_menu.set_item( idx(), "ADVANCED", cmd_show_menu, advanced_menu )
	root_menu.set_item( idx(), "QUIT GAME", cmd_quit_game )
	MENU_REGISTER.root = root_menu
	MENU_REGISTER.push( root_menu )
	
	Local level_grid_dimensions%[] = New Int[level_grid.Length]
	For Local d% = 0 Until level_grid_dimensions.Length
		level_grid_dimensions[d] = level_grid[d].Length
	Next
	
	level_select_menu.Construct( ..
		level_grid_dimensions, ..
		dark_gray, white, ..
		menu_line_width, ..
		menu_super_small_item_fg_font, menu_super_small_item_bg_font, ..
		30, 30, ..
		0, 0, ..
		window_w, window_h )
	
	Local level_file_path$, level_object:LEVEL, level_preview_path$, level_preview_img:TImage
	For Local r% = 0 Until level_grid.Length
		For Local c% = 0 Until level_grid[r].Length
			level_file_path = level_grid[r][c]
      level_object = load_level( level_file_path )
			If Not level_object
				DebugLog( " ERROR: level file not found ~q" + level_file_path + "~q" )
				DebugStop
			End If
			level_preview_path = level_preview_path_from_level_path( level_file_path )
			If FileExists( level_preview_path ) And FileTime( level_file_path ) <= FileTime( level_preview_path )
				'preview file exists and is valid; use it
				level_preview_img = LoadImage( level_preview_path, FILTEREDIMAGE )
			Else
				'preview file needs to be generated or re-generated
         DeleteFile( level_preview_path )
         level_preview_img = generate_level_mini_preview( level_object )
         SavePixmapPNG( level_preview_img.pixmaps[0], level_preview_path, 5 )
			End If
			'////
			level_select_menu.set_item( r, c, level_object.name, level_preview_img, cmd_play_level, level_object )
		Next
	Next

	profile_menu.Construct( ..
		"PROFILE", 3, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	profile_menu.set_item( idx(), "CREATE NEW", cmd_create_new_profile )
	profile_menu.set_item( idx(), "SAVE PROFILE", cmd_save_profile )
	profile_menu.set_item( idx(), "SWITCH PROFILES", cmd_load_profile )
		
	settings_menu.Construct( ..
		"SETTINGS", 3, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	settings_menu.set_item( idx(), "GAME PERFORMANCE", cmd_show_menu, video_settings_menu )
	settings_menu.set_item( idx(), "VIDEO SETTINGS", cmd_show_menu, video_settings_menu )
	settings_menu.set_item( idx(), "AUDIO SETTINGS", cmd_show_menu, video_settings_menu )
		
	advanced_menu.Construct( ..
		"ADVANCED", 4, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	advanced_menu.set_item( idx(), "LEVEL EDITOR", cmd_enter_level_editor )
	advanced_menu.set_item( idx(), "UNIT EDITOR", cmd_enter_unit_editor )
	advanced_menu.set_item( idx(), "GIBS EDITOR", cmd_enter_gibs_editor )
	advanced_menu.set_item( idx(), "RELOAD ASSETS", cmd_reload_assets )
		
	video_settings_menu.Construct( ..
		"VIDEO SETTINGS", 4, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	video_settings_menu.set_item( idx(), "FULL SCREEN", cmd_toggle_setting, SETTINGS_REGISTER.FULL_SCREEN )
	video_settings_menu.set_item( idx(), "RESOLUTION", cmd_show_menu, screen_resolution_menu )
	video_settings_menu.set_item( idx(), "REFRESH RATE", cmd_show_menu, screen_refresh_rate_menu )
	video_settings_menu.set_item( idx(), "BIT DEPTH", cmd_show_menu, screen_bit_depth_menu )
	
	
		
	audio_settings_menu.Construct( ..
		"AUDIO SETTINGS", 3, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_small_item_fg_font, menu_small_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	'audio_settings_menu.set_item( idx(), cmd_modify_setting )
	'audio_settings_menu.set_item( idx(), cmd_modify_setting )
	'audio_settings_menu.set_item( idx(), cmd_modify_setting )
	'"EFFECTS VOLUME", "MUSIC VOLUME", "AUDIO DRIVER"
		
	pause_menu.Construct( ..
		"PAUSED", 4, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_x, menu_y )
	idx( True )
	pause_menu.set_item( idx(), "RESUME", cmd_unpause_game )
	pause_menu.set_item( idx(), "SETTINGS", cmd_show_menu, settings_menu )
	pause_menu.set_item( idx(), "QUIT LEVEL", cmd_quit_level )
	pause_menu.set_item( idx(), "QUIT GAME", cmd_quit_game )
	MENU_REGISTER.pause = pause_menu
	
	
	
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

