Rem
	core_menus.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'This file must be Include'd by core.bmx

'______________________________________________________________________________
Type MENU_REGISTER
	Global stack:TList
	
	Global root:TUIObject
	Global level_select:TUIObject
	Global pause:TUIObject
	
	Function push( m:TUIObject )
		If Not stack Then stack = CreateList()
		stack.AddLast( m )
		get_top().on_show()
	End Function
	
	Function pop()
		If stack And stack.Last() <> root
			stack.RemoveLast()
			get_top().on_show()
		End If
	End Function
	
	Function get_top:TUIObject()
		If stack Then Return TUIObject( stack.Last() ) Else Return Null
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
	Local menu_tiny_line_width% = 1
	Local menu_x% = 10, menu_y% = 70
	
	Local splash_screen:TUISplash = New TUISplash
	Local main_menu:TUIList = New TUIList
		Local level_select_menu:TUIImageGrid = New TUIImageGrid
		Local profile_menu:TUIList = New TUIList
		Local settings_menu:TUIList = New TUIList
			Local performance_settings_menu:TUIList = New TUIList
			Local video_settings_menu:TUIList = New TUIList
				Local screen_resolution_menu:TUIList = New TUIList
			Local audio_settings_menu:TUIList = New TUIList
		Local advanced_menu:TUIList = New TUIList
			Local play_custom_level_menu:TUIList = New TUIList
	Local pause_menu:TUIList = New TUIList

	'/////////////////
	
	splash_screen.Construct( ..
		get_image( "col_title" ), ..
		get_sound( "title_intro" ), ..
		cmd_show_menu, level_select_menu )

	main_menu.Construct( ..
		"COLOSSEUM", 5, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		bright_yellow, dark_yellow, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	main_menu.set_item( idx(), "START", cmd_show_menu, level_select_menu )
	main_menu.set_item( idx(), "PROFILE", cmd_show_menu, profile_menu )
	main_menu.set_item( idx(), "SETTINGS", cmd_show_menu, settings_menu )
	main_menu.set_item( idx(), "ADVANCED", cmd_show_menu, advanced_menu )
	main_menu.set_item( idx(), "QUIT GAME", cmd_quit_game )
	
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
		SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
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
	MENU_REGISTER.level_select = level_select_menu
	
	profile_menu.Construct( ..
		"PROFILE", 3, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	profile_menu.set_item( idx(), "SAVE PROFILE", cmd_save_profile,, SETTINGS_REGISTER.PLAYER_PROFILE_NAME )
	profile_menu.set_item( idx(), "CREATE NEW", cmd_create_new_profile )
	profile_menu.set_item( idx(), "SWITCH PROFILES", cmd_load_profile )
	
	settings_menu.Construct( ..
		"SETTINGS", 3, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	settings_menu.set_item( idx(), "GAME PERFORMANCE", cmd_show_menu, performance_settings_menu )
	settings_menu.set_item( idx(), "VIDEO SETTINGS", cmd_show_menu, video_settings_menu )
	settings_menu.set_item( idx(), "AUDIO SETTINGS", cmd_show_menu, audio_settings_menu )
	
	performance_settings_menu.Construct( ..
		"GAME PERFORMANCE", 2, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_small_item_fg_font, menu_small_item_bg_font, ..
		black, white, ..
		menu_x, menu_y )
	idx( True )
	video_settings_menu.set_item( idx(), "AI MENU GAME", cmd_toggle_setting, SETTINGS_REGISTER.SHOW_AI_MENU_GAME, SETTINGS_REGISTER.SHOW_AI_MENU_GAME )
	Local popup:REQUEST_INPUT_FOR_SETTING_POPUP = New REQUEST_INPUT_FOR_SETTING_POPUP
	popup.setting = SETTINGS_REGISTER.ACTIVE_PARTICLE_LIMIT
	popup.font = performance_settings_menu.item_tag_font
	Local b:BOX = performance_settings_menu.get_item_tag_rect( g_idx )
	Local pos:cVEC = b.auto_margin( popup.font.height )
	pos.x :+ performance_settings_menu.margin_x
	popup.x = pos.x
	popup.y = pos.y
	video_settings_menu.set_item( idx(), "MAX PARTICLES", cmd_change_setting_integer, popup, SETTINGS_REGISTER.ACTIVE_PARTICLE_LIMIT )
	
	video_settings_menu.Construct( ..
		"VIDEO SETTINGS", 2, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		menu_small_item_fg_font, menu_small_item_bg_font, ..
		black, white, ..
		menu_x, menu_y )
	idx( True )
	video_settings_menu.set_item( idx(), "FULL-SCREEN", cmd_toggle_setting, SETTINGS_REGISTER.FULL_SCREEN, SETTINGS_REGISTER.FULL_SCREEN )
	video_settings_menu.set_item( idx(), "RESOLUTION", cmd_show_menu, screen_resolution_menu, SETTINGS_REGISTER.GRAPHICS_MODE )
	
	Local modes:TGraphicsMode[] = GraphicsModes()
	Local resolutions:TList = CreateList()
	Local refresh_rates:TList = CreateList()
	Local bit_depths:TList = CreateList()
	Local unique%
	For Local i% = 0 Until modes.Length
		'resolution
		unique = True
		For Local res%[] = EachIn resolutions
			If res[0] = modes[i].width And res[1] = modes[i].height
				unique = False
				Exit
			End If
		Next
		If unique
			resolutions.AddLast( [modes[i].width, modes[i].height] )
		End If
		'refresh rate
		unique = True
		For Local res%[] = EachIn refresh_rates
			If res[0] = modes[i].hertz
				unique = False
				Exit
			End If
		Next
		If unique
			refresh_rates.AddLast( [modes[i].hertz] )
		End If
		'bit depth
		unique = True
		For Local res%[] = EachIn bit_depths
			If res[0] = modes[i].depth
				unique = False
				Exit
			End If
		Next
		If unique
			bit_depths.AddLast( [modes[i].depth] )
		End If
	Next
	screen_resolution_menu.Construct( ..
		"RESOLUTION", resolutions.Count(), ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_small_item_fg_font, menu_small_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	For Local res%[] = EachIn resolutions
		Local res_str$ = "" + res[0] + " x " + res[1]
		screen_resolution_menu.set_item( idx(), res_str, cmd_set_screen_resolution, res )
	Next
	'screen_resolution_menu.set_menu_show_event_handler( cmd_select_current_screen_resolution )

	Rem
	Local modes:TGraphicsMode[] = GraphicsModes()
	screen_resolution_menu.Construct( ..
		"RESOLUTION", modes.Length, ..
		dark_gray, white, black, white, ..
		menu_tiny_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_super_small_item_fg_font, menu_super_small_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	For Local i% = 0 Until modes.Length
		Local mode_str$ = "" + modes[i].width + "x" + modes[i].height + " px, " + modes[i].depth + " bpp, " + modes[i].hertz + " Hz"
		screen_resolution_menu.set_item( i, mode_str, cmd_set_graphics_mode, modes[i] )
	Next
	screen_resolution_menu.set_menu_show_event_handler( cmd_select_current_screen_resolution )
	EndRem
	
	audio_settings_menu.Construct( ..
		"AUDIO SETTINGS", 3, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_small_item_fg_font, menu_small_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	audio_settings_menu.set_item( idx(), "EFFECTS VOLUME" )
	audio_settings_menu.set_item( idx(), "MUSIC VOLUME" )
	audio_settings_menu.set_item( idx(), "AUDIO DRIVER" )
	
	advanced_menu.Construct( ..
		"ADVANCED", 4, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	advanced_menu.set_item( idx(), "LEVEL EDITOR", cmd_enter_level_editor )
	advanced_menu.set_item( idx(), "PLAY LEVEL", cmd_show_menu, play_custom_level_menu )
	advanced_menu.set_item( idx(), "UNIT EDITOR", cmd_enter_unit_editor )
	advanced_menu.set_item( idx(), "GIBS EDITOR", cmd_enter_gibs_editor )
	advanced_menu.set_item( idx(), "RELOAD DATA", cmd_reload_assets )
	
	play_custom_level_menu.Construct( ..
		"PLAY LEVEL", 0, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_small_item_fg_font, menu_small_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	play_custom_level_menu.set_menu_show_event_handler( cmd_refresh_custom_level_list )
	
	pause_menu.Construct( ..
		"PAUSED", 4, ..
		dark_gray, white, black, white, ..
		menu_line_width, ..
		menu_header_fg_font, menu_header_bg_font, ..
		white, black, ..
		menu_item_fg_font, menu_item_bg_font, ..
		white, black, black, light_gray, ..
		,,,, ..
		menu_x, menu_y )
	idx( True )
	pause_menu.set_item( idx(), "RESUME", cmd_unpause_game )
	pause_menu.set_item( idx(), "SETTINGS", cmd_show_menu, settings_menu )
	pause_menu.set_item( idx(), "QUIT LEVEL", cmd_quit_level )
	pause_menu.set_item( idx(), "QUIT GAME", cmd_quit_game )
	MENU_REGISTER.pause = pause_menu
	
	'/////////////////

	MENU_REGISTER.root = splash_screen
	MENU_REGISTER.push( MENU_REGISTER.root )
	MENU_REGISTER.root.on_show()
	last_menu_service_ts = now()

End Function

