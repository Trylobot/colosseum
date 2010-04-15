Rem
	core_menu_commands.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'This file must be Include'd by core.bmx

'______________________________________________________________________________
Global level_editor_requests_resume%
Global campaign_chooser:IMAGE_CHOOSER
Global show_campaign_chooser% = False

'______________________________________________________________________________
Function cmd_show_menu( item:Object = Null )
	If item And TUIList(item) Then MENU.push( TUIList(item) )
End Function

Function cmd_show_previous_menu( item:Object = Null )
	MENU.pop()
End Function

Function cmd_load_game( item:Object = Null )
	If Not item Then Return
	Local saved_game_path$ = String(item)
	If Not saved_game_path Then Return
	profile = load_game( saved_game_path )
	If profile
		save_autosave( profile.src_path )
		show_info( "loaded player data "+profile.name+" from file "+StripAll(profile.src_path) )
	End If
	'menu_command( COMMAND.BACK_TO_PARENT_MENU )
	'get_current_menu().update( True )
End Function

Function cmd_save_game( item:Object = Null )
	If profile
		If save_game( profile.src_path, profile )
			save_autosave( profile.src_path )
			show_info( "saved player data "+profile.name+" to file "+StripAll(profile.src_path) )
		End If
	Else 'Not profile
		save_autosave( Null )
	End If
End Function

Function cmd_play_level( item:Object = Null )
	If Not profile Then Return
	If Not item Then Return
	Local lev_path$ = String(item)
	If Not lev_path Then Return
	
	Local player:COMPLEX_AGENT = get_player_vehicle( profile.vehicle_key )
	If player
		MENU.push( MENU.pause )
		'//////////////////////////////
		play_level( lev_path, player )
		'//////////////////////////////
	Else
		show_info( "critical error: could not find vehicle [" + profile.vehicle_key + "]" )
	End If
End Function

Function cmd_pause_game( item:Object = Null )
	MENU.push( MENU.pause )
	FLAG.in_menu = True
	If main_game <> Null Then main_game.paused = True
	FlushKeys()
	FlushMouse()
End Function

Function cmd_new_level_editor_cache( item:Object = Null )
	level_editor_cache = Create_LEVEL( 300, 300 )
	'menu_command( COMMAND.BACK_TO_PARENT_MENU )
	'show_info( "new level loaded" )
End Function

Function cmd_quit_level( item:Object = Null )
	FLAG.in_menu = True
	main_game = Null
	game = ai_menu_game
	cmd_save_game( item )
	'menu_show_loading_bay()
	If FLAG.playing_multiplayer 
		network_terminate()
	End If
	FLAG.campaign_mode = False
End Function

Function cmd_quit_game( item:Object = Null )
	cmd_quit_level( item )
	End
End Function

'______________________________________________________________________________
'Function menu_show_loading_bay()
'	
'End Function

Function campaign_chooser_callback( selected:CELL )
	'kill the chooser
	show_campaign_chooser = False
	'play level
	FLAG.campaign_mode = True
	Local cpd:CAMPAIGN_DATA = get_campaign_data( campaign_ordering[selected.row] )
	Local lev_path$ = cpd.levels[selected.col]
	profile.vehicle_key = cpd.player_vehicle
	'menu_command( COMMAND.PLAY_LEVEL, lev_path )
	cmd_play_level( lev_path )
End Function

Function load_all_assets()
  loading_progress = 0
	load_texture_atlases()
	load_assets()
	'MENU.load_fonts()
	initialize_menus()
	If show_ai_menu_game
		init_ai_menu_game()
	End If
End Function

Function create_new_user_profile:PLAYER_PROFILE()
	Local p:PLAYER_PROFILE = New PLAYER_PROFILE
	p.name = "new_profile"
	p.input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
	p.cash = 100
	p.vehicle_key = "light_tank"
	p.src_path = p.generate_src_path()
	Return p
End Function

'______________________________________________________________________________
Rem
'command_argument should be an object;
'  the object gets cast to an appropriate type automatically, a container type with all the information necessary
'  if the cast fails, the argument is invalid
Function menu_command( command_code%, argument:Object = Null )
	Local cmd$ = COMMAND.decode( command_code ).ToLower()
	Local arg$
	If INTEGER(argument) 'child menu
		arg = MENU_ID.decode( INTEGER(argument).value ).ToLower()
	Else If INVENTORY_DATA(argument) 'items
		arg = INVENTORY_DATA(argument).to_string()
	Else If Int[](argument) 'resolution
		arg = Int[](argument)[0] + " x " + Int[](argument)[1]
	Else 'string (path, value, etc)
		arg = String(argument)
	End If
	DebugLog( " " + cmd + " " + arg )
	
	Select command_code
		'________________________________________
		Case COMMAND.PLAY_LEVEL
			If profile
				'put the "paused" menu on top of the menu stack
				Local player:COMPLEX_AGENT = get_player_vehicle( profile.vehicle_key )
				If player
					'place the paused menu on the stack, forcibly
					If current_menu > 0 Then current_menu :- 1
					current_menu :+ 1
					menu_stack[current_menu] = MENU_ID.PAUSED
					get_current_menu().update( True )
					'//////////////////////////////////////
					play_level( String(argument), player )
					'//////////////////////////////////////
				Else 'player == Null
					show_info( "critical error: could not find vehicle [" + profile.vehicle_key + "]" )
				End If
			End If
		'________________________________________
		Case COMMAND.SELECT_CAMPAIGN
			If profile
				show_campaign_chooser = True
			End If
		'________________________________________
		Case COMMAND.CONTINUE_LAST_CAMPAIGN
			
		'________________________________________
		Case COMMAND.HOST_NETWORK_GAME
			network_game_listen()
			menu_command( COMMAND.play_level, network_level )
		'________________________________________
		Case COMMAND.CONNECT_TO_NETWORK_GAME
			network_game_connect()
			'TODO: for the local ENVIRONMENT object (game), disable automatic spawning.
			'      instead, agents will be spawned via messages from the network
			menu_command( COMMAND.play_level, network_level )
		'________________________________________
		Case COMMAND.SHOW_CHILD_MENU
			current_menu :+ 1
			menu_stack[current_menu] = INTEGER(argument).value
			get_current_menu().update( True )
			If get_current_menu().id = MENU_ID.SAVE_LEVEL
				get_current_menu().set_focus( level_editor_cache.name )
			End If
		'________________________________________
		Case COMMAND.BACK_TO_PARENT_MENU
			If Not show_campaign_chooser	
				If current_menu > 0 Then current_menu :- 1
			Else 'show_campaign_chooser
				show_campaign_chooser = False
			End If
		'________________________________________
		Case COMMAND.BACK_TO_MAIN_MENU
			FLAG.in_menu = True
			current_menu = 0
		'________________________________________
		Case COMMAND.PAUSE
			FLAG.in_menu = True
			current_menu = 1
			menu_stack[current_menu] = MENU_ID.PAUSED
			If main_game <> Null Then main_game.paused = True
			FlushKeys()
			FlushMouse()
		'________________________________________
		Case COMMAND.RESUME
			FLAG.in_menu = False
			If main_game <> Null Then main_game.paused = False
			If game And game.player Then reset_mouse( game.player.ang )
			FLAG.ignore_mouse_1 = True
		'________________________________________
		Case COMMAND.NEW_GAME
			'create the profile
			profile = create_new_user_profile()
			show_info( "new profile created" )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
			'immediately prompt for a rename
			menu_command( COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_PROFILE_NAME) )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND.PLAYER_PROFILE_NAME
			profile.name = String(argument)
			profile.src_path = profile.generate_src_path()
			menu_command( COMMAND.SAVE_GAME )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND.LOAD_GAME
			profile = load_game( String(argument) )
			If profile
				save_autosave( profile.src_path )
				show_info( "loaded player data "+profile.name+" from file "+StripAll(profile.src_path) )
			End If
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND.SAVE_GAME
			If profile
				If save_game( profile.src_path, profile )
					save_autosave( profile.src_path )
					If argument And (Int[](argument)[0] = True) 'suppress save message
						show_info( "saved player data "+profile.name+" to file "+StripAll(profile.src_path) )
					End If
				End If
			Else 'Not profile
				save_autosave( Null )
			End If
			'menu_command( COMMAND.BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND.NEW_LEVEL
			level_editor_cache = Create_LEVEL( 300, 300 )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "new level loaded" )
		'________________________________________
		Case COMMAND.LOAD_LEVEL
			level_editor_cache = load_level( String(argument) )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "loaded level data "+level_editor_cache.name+" into editor from file "+String(argument).Replace("." + level_file_ext,"") )
			get_menu( MENU_ID.LEVEL_EDITOR ).recalculate_dimensions()
			menu_command( COMMAND.EDIT_LEVEL )
		'________________________________________
		Case COMMAND.SAVE_LEVEL
			save_level( String(argument), level_editor_cache )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "saved level data "+level_editor_cache.name+" from editor as file "+String(argument).Replace("." + level_file_ext,"") )
			If level_editor_requests_resume
				menu_command( COMMAND.EDIT_LEVEL )
			End If
		'________________________________________
		Case COMMAND.PLAYER_INPUT_TYPE
			If profile
				profile.input_method = INTEGER(argument).value
			End If
			If game And game.player_brain
				game.player_brain.input_type = profile.input_method
			End If
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "player input method changed" )
		'________________________________________
		Case COMMAND.PLAYER_INVERT_REVERSE_STEERING
			If profile
				profile.invert_reverse_steering = Not profile.invert_reverse_steering
			End If
			show_info( "player input method changed" )
		'________________________________________
		Case COMMAND.SETTINGS_FULLSCREEN
			fullscreen = Not fullscreen
			menu_command( COMMAND.SETTINGS_APPLY_ALL )
			If fullscreen
				show_info( "fullscreen mode" )
			Else
				show_info( "windowed mode" )
			End If
		'________________________________________
		Case COMMAND.SETTINGS_RESOLUTION
			window_w = Int[](argument)[0]
			window_h = Int[](argument)[1]
			menu_command( COMMAND.SETTINGS_APPLY_ALL )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			init_ai_menu_game()
			If main_game
				main_game.calculate_camera_constraints()
			End If
			If game And game.graffiti
				game.graffiti.resize_backbuffer( window_w, window_h )
			End If
			show_info( "resolution "+window_w+" x "+window_h )
		'________________________________________
		Case COMMAND.SETTINGS_REFRESH_RATE
			Local new_refresh_rate% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, bit_depth, new_refresh_rate )
				refresh_rate = new_refresh_rate
				menu_command( COMMAND.SETTINGS_APPLY_ALL )
			End If
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "refresh rate "+refresh_rate+" Hz" )
		'________________________________________
		Case COMMAND.SETTINGS_BIT_DEPTH
			Local new_bit_depth% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, new_bit_depth, refresh_rate )
				bit_depth = new_bit_depth
				menu_command( COMMAND.SETTINGS_APPLY_ALL )
			End If
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "bit depth "+bit_depth+" bpp" )
		'________________________________________
		Case COMMAND.SETTINGS_AUDIO
			Local new_audio_driver$ = String(argument)
			If AudioDriverExists( new_audio_driver )
				audio_driver = new_audio_driver
				SetAudioDriver( audio_driver )
				save_settings()
				show_info( "audio driver set to "+audio_driver )
				'force all persistent channels to re-allocate
				bg_music = Null
				engine_start = Null
				engine_idle = Null
			End If
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND.SETTINGS_SHOW_AI_MENU_GAME
			show_ai_menu_game = Not show_ai_menu_game
			If ai_menu_game And Not show_ai_menu_game
				ai_menu_game = Null
			Else If Not ai_menu_game And show_ai_menu_game
				init_ai_menu_game()
			End If
			save_settings()
		'________________________________________
		Case COMMAND.SETTINGS_PARTICLE_LIMIT
			active_particle_limit = String(argument).ToInt()
			save_settings()
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND.SETTINGS_APPLY_ALL
			save_settings()
			init_graphics()
			show_info( "video settings changed" )
		'________________________________________
		Case COMMAND.EDIT_LEVEL
			Local return_code% = level_editor( level_editor_cache )
			If return_code = LEVEL_EDITOR_REQUESTS_SAVE
				menu_command( COMMAND.SHOW_CHILD_MENU, INTEGER.Create( MENU_ID.SAVE_LEVEL ))
				level_editor_requests_resume = True
			Else
				level_editor_requests_resume = False
			End If
			get_current_menu().update( True )
			If get_current_menu().id = MENU_ID.SAVE_LEVEL
				get_current_menu().set_focus( level_editor_cache.name )
			End If
		'________________________________________
		Case COMMAND.EDIT_VEHICLE
			'If profile
			'	profile.sort_inventory()
			'	profile.vehicle = vehicle_editor( profile.vehicle )
			'	menu_command( COMMAND.SAVE_GAME )
			'End If
		'________________________________________
		Case COMMAND.LOAD_ASSETS
			load_all_assets()
			show_info( "loading complete" )
		'________________________________________
		Case COMMAND.BUY_PART
			profile.buy_item( INVENTORY_DATA(argument) )
			show_info( "new part purchased" )
			profile.sort_inventory()
			menu_command( COMMAND.SAVE_GAME )
		'________________________________________
		Case COMMAND.SELL_PART
			profile.sell_item( INVENTORY_DATA(argument) )
			get_current_menu().update()
			show_info( "part sold" )
			menu_command( COMMAND.SAVE_GAME )
		'________________________________________
		Case COMMAND.NETWORK_IP_ADDRESS
			network_ip_address = String(argument)
			save_settings()
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND.NETWORK_PORT
			network_port = String(argument).ToInt()
			save_settings()
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND.NETWORK_LEVEL
			network_level = String(argument)
			save_settings()
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
		'________________________________________
		Case COMMAND.QUIT_LEVEL
			FLAG.in_menu = True
			main_game = Null
			game = ai_menu_game
			menu_command( COMMAND.SAVE_GAME )
			menu_command( COMMAND.BACK_TO_MAIN_MENU )
			menu_command( COMMAND.SHOW_CHILD_MENU, INTEGER.Create( MENU_ID.LOADING_BAY ))
			If FLAG.playing_multiplayer 
				network_terminate()
			End If
			FLAG.campaign_mode = False
		'________________________________________
		Case COMMAND.QUIT_GAME
			menu_command( COMMAND.QUIT_LEVEL )
			End
			
	End Select
	Local m:MENU = get_current_menu()
	m.recalculate_dimensions()
	m.update()
	
End Function
EndRem

