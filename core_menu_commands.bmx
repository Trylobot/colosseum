Rem
	core_menu_commands.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'This file must be Include'd by core.bmx

'______________________________________________________________________________
Global level_editor_requests_resume%
'Global campaign_chooser:IMAGE_CHOOSER
'Global show_campaign_chooser% = False

'______________________________________________________________________________
Function cmd_show_menu( item:Object = Null )
	Local m:TUIObject = TUIObject(item)
	If m
		MENU_REGISTER.push( m )
		MENU_REGISTER.get_top().on_show()
	End If
End Function

Function cmd_show_previous_menu( item:Object = Null )
	MENU_REGISTER.pop()
	MENU_REGISTER.get_top().on_show()
End Function

Function cmd_play_level( item:Object )
	main_game = play_level( item )
End Function

Function cmd_create_new_profile( item:Object = Null )
	profile = create_new_user_profile()
	show_info( "new profile created" )
End Function

Function cmd_load_profile( item:Object )
	If Not item Then Return
	Local saved_game_path$ = String(item)
	If Not saved_game_path Then Return
	profile = load_game( saved_game_path )
	If profile
		save_autosave( profile.src_path )
		show_info( "loaded player data "+profile.name+" from file "+StripAll(profile.src_path) )
	End If
End Function

Function cmd_save_profile( item:Object = Null )
	If profile
		If save_game( profile.src_path, profile )
			save_autosave( profile.src_path )
			show_info( "saved player data "+profile.name+" to file "+StripAll(profile.src_path) )
		End If
	Else 'Not profile
		save_autosave( Null )
	End If
End Function

Function cmd_toggle_setting( item:Object )
	Local setting:GLOBAL_SETTING_BOOLEAN = GLOBAL_SETTING_BOOLEAN( item )
	If setting
		setting.toggle()
	End If
End Function

Function cmd_change_setting_integer( item:Object )
	Local popup:REQUEST_INPUT_FOR_SETTING_POPUP = REQUEST_INPUT_FOR_SETTING_POPUP(item)
	If popup
		Local setting:GLOBAL_SETTING_INTEGER = GLOBAL_SETTING_INTEGER(popup.setting)
		If setting
			Local setting_value$ = popup.setting.ToString()
			Local raw_input$ = get_input( setting_value,, popup.x, popup.y, popup.font, screencap() )
			setting.set( raw_input.ToInt() )
		End If
	End If
End Function

Function cmd_set_screen_resolution( item:Object )
	Local mode:TGraphicsMode = TGraphicsMode( item )
	If mode
		SETTINGS_REGISTER.WINDOW_WIDTH.set( mode.width )
		SETTINGS_REGISTER.WINDOW_HEIGHT.set( mode.height )
		SETTINGS_REGISTER.BIT_DEPTH.set( mode.depth )
		SETTINGS_REGISTER.REFRESH_RATE.set( mode.hertz )
		SETTINGS_REGISTER.GRAPHICS_MODE.resolve()
		save_settings()
		'////
		init_graphics()
		'////
	End If
End Function

Rem
Function cmd_select_current_screen_resolution( item:Object )
	Local menu:TUIList = TUIList( item )
	If menu
		Local mode:TGraphicsMode
		For Local i% = 0 Until menu.get_item_count()
			mode = TGraphicsMode( menu.get_item( i ))
			If mode
				If  mode.width = GraphicsWidth() ..
				And mode.height = GraphicsHeight() ..
				And mode.depth = GraphicsDepth() ..
				And mode.hertz = GraphicsHertz()
					menu.select_item( i )
					Exit
				End If
			End If
		Next
	End If
End Function
EndRem

Function cmd_refresh_custom_level_list( item:Object )
	Local menu:TUIList = TUIList( item )
	If menu
		populate_menu_with_files( menu, level_path, level_file_ext, cmd_play_level, False )
	End If
End Function

Function cmd_pause_game( item:Object = Null )
	FLAG.paused = True
	FLAG.in_menu = True
	If main_game Then main_game.paused = True
	FlushKeys()
	FlushMouse()
End Function

Function cmd_unpause_game( item:Object = Null )
	FLAG.paused = False
	FLAG.in_menu = False
	If main_game Then main_game.paused = False
	FlushKeys()
	FlushMouse()
End Function

Function cmd_new_level_editor_cache( item:Object = Null )
	level_editor_cache = Create_LEVEL( 300, 300 )
End Function

Function cmd_enter_level_editor( item:Object = Null )
	level_editor()
End Function

Function cmd_enter_unit_editor( item:Object = Null )
	'unit editor()
End Function

Function cmd_enter_gibs_editor( item:Object = Null )
	'gibs_editor()
End Function

Function cmd_reload_assets( item:Object = Null )
	load_all_assets()
End Function

Function cmd_quit_level( item:Object = Null )
	FLAG.in_menu = True
	FLAG.paused = False
	main_game = Null
	game = ai_menu_game
	cmd_save_profile( item )
	FLAG.campaign_mode = False
End Function

Function cmd_quit_game( item:Object = Null )
	cmd_quit_level( item )
	End
End Function

Function load_all_assets()
  loading_progress = 0
	'/////
	load_texture_atlases()
	load_assets()
	load_level_grid()
	'/////
	initialize_menus()
	'/////
	If SETTINGS_REGISTER.SHOW_AI_MENU_GAME.get()
		init_ai_menu_game()
	End If
End Function

Function create_new_user_profile:PLAYER_PROFILE()
	Local p:PLAYER_PROFILE = New PLAYER_PROFILE
	Local num% = 1
	Repeat
		p.name = "player" + num
		p.src_path = p.generate_src_path()
		num :+ 1
	Until Not FileExists( p.src_path )
	Return p
End Function

