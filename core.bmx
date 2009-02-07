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
'notificationss
Global info$
Const info_stay_time% = 3000
Const info_fade_time% = 1250
Global info_change_ts% = now()
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
Function create_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA, validate_against_inventory% = True )
	If Not v_dat Then Return Null 'no chassis data
	If v_dat.is_unit
		Return get_unit( v_dat.chassis_key )
	Else 'Not is_unit
		Local required_items:TList = CreateList()
		required_items.AddLast( Create_INVENTORY_DATA( "chassis", v_dat.chassis_key ))
		Local player:COMPLEX_AGENT
		player = get_player_chassis( v_dat.chassis_key )
		If player
			For Local anchor% = 0 Until v_dat.turret_keys.Length
				For Local t% = 0 Until v_dat.turret_keys[anchor].Length
					'search the required items list for instances of this turret
					Local exists% = False
					For Local item:INVENTORY_DATA = EachIn required_items
						If item.key = v_dat.turret_keys[anchor][t]
							item.count :+ 1
							exists = True
							Exit
						End If
					Next
					If Not exists
						required_items.AddLast( Create_INVENTORY_DATA( "turret", v_dat.turret_keys[anchor][t] ))
					End If
					Local player_turret:TURRET = get_turret( v_dat.turret_keys[anchor][t] )
					If player_turret
						player.add_turret( player_turret, anchor )
					End If
				Next
			Next
			If validate_against_inventory
				If Not profile.checklist( required_items )
					show_info( "Your vehicle requires items you no longer have." )
					Return Null 'not enough items to build player
				End If
			End If
			Return player 'all good!
		Else
			Return Null 'bad chassis data
		End If
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
	If Not show_ai_menu_game Then Return
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
Function kill_tally( title$, bg:TImage = Null, kill_total_override% = -1 )
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	
	Local kills_this_level%
	If kill_total_override <> -1
		kills_this_level = kill_total_override
	Else
		kills_this_level = profile.kills - game.player_kills_at_start
	End If
	Local continue_msg$ = "press enter to continue"
	Local kills_msg$
	
	Local kills_counted% = 0
	Local begin_ts% = now(), transition_ts% = begin_ts
	Local transition_time# = 400
	Local animating% = True
	Local kill_signal% = False

	FlushKeys()
	FlushMouse()

	play_sound( get_sound( "mgun_hit" ), 1.0 )
	
	Repeat
		Cls()
		
		If bg
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
			DrawImage( bg, 0, 0 )
			SetAlpha( 0.9 )
			SetColor( 0, 0, 0 )
			DrawRect( 0, 0, window_w, window_h )
		End If
		
		If animating
			If (now() - transition_ts) > transition_time
				If kills_counted < kills_this_level - 1
					kills_counted :+ 1
					transition_time = 2016000.0/(5.0*(now() - begin_ts) + 4600.0) - 30.0
					play_sound( get_sound( "mgun_hit" ), 0.1 + transition_time/400.0, 0.3333 )
					transition_ts = now()
				Else 'kills_counted >= kills_this_level
					animating = False
				End If
			End If
			If (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ) Or KeyHit( KEY_ESCAPE ) Or MouseHit( 1 ))
				kills_counted = kills_this_level - 1
				animating = False
			End If
		End If
		
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetImageFont( get_font( "consolas_bold_50" ))
		DrawText_with_glow( title, window_w/2 - TextWidth( title )/2, 20 )
		
		SetColor( 212, 64, 64 )
		SetImageFont( get_font( "consolas_bold_24" ))
		If animating
			kills_msg = format_number( kills_counted )+" kills"
			SetAlpha( time_alpha_pct( begin_ts, transition_time, False ))
			DrawText_with_glow( kills_msg, window_w/2 - TextWidth( kills_msg )/2, 90 )
			kills_msg = format_number( kills_counted + 1 )+" kills"
			SetAlpha( time_alpha_pct( begin_ts - transition_time/2, transition_time, True ))
		Else
			SetAlpha( 1 )
		End If
		DrawText_with_glow( kills_msg, window_w/2 - TextWidth( kills_msg )/2, 90 )
		
		If animating
			SetAlpha( time_alpha_pct( begin_ts, transition_time, False ))
			draw_skulls( 20, 120, window_w - 40, kills_counted )
			SetAlpha( time_alpha_pct( begin_ts - transition_time/2, transition_time, True ))
		Else
			SetAlpha( 1 )
		End If
		draw_skulls( 20, 120, window_w - 40, kills_counted + 1 )
		
		SetColor( 212, 64, 64 )
		SetAlpha( 1 )
		SetImageFont( get_font( "consolas_bold_14" ))
		DrawText_with_glow( continue_msg, window_w/2 - TextWidth( continue_msg )/2, window_h - 40 )
		
		Flip( 1 )
		
		kill_signal = AppTerminate()
	Until (Not animating And (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ) Or KeyHit( KEY_ESCAPE ) Or MouseHit( 1 ))) Or kill_signal
	If kill_signal Then End
	
	FlushKeys()
	FlushMouse()
End Function

Function bake_item:Object( item:INVENTORY_DATA )
	If item
		Select item.item_type
			Case "chassis"
				Return get_player_chassis( item.key )
			Case "unit"
				Return get_unit( item.key )
			Case "turret"
				Return get_turret( item.key )
		End Select
	End If
	Return Null
End Function

'______________________________________________________________________________
Global menu_margin% = 8
Global dynamic_subsection_window_size% = 8
Global all_menus:MENU[50]
Global pause_menu:MENU
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

reset_index()
all_menus[postfix_index()] = MENU.Create( "main menu", "main", 255, 255, 127, MENU_ID_MAIN_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
[	MENU_OPTION.Create( "loading bay", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOADING_BAY), True, False ), ..
	MENU_OPTION.Create( "save %%profile.name%%", COMMAND_SAVE_GAME,, True, False ), ..
	MENU_OPTION.Create( "load game", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_GAME), True, True ), ..
	MENU_OPTION.Create( "new game", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CONFIRM_NEW_GAME), True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PREFERENCES), True, False ), ..
	MENU_OPTION.Create( "advanced", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_GAME_DATA), True, True ), ..
	MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ])
	
all_menus[postfix_index()] = MENU.Create( "game paused", "pause", 96, 96, 96, MENU_ID_PAUSED, MENU.VERTICAL_LIST, menu_margin, -1,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PREFERENCES), True, True ), ..
	MENU_OPTION.Create( "abandon level", COMMAND_QUIT_LEVEL,, True, True ), ..
	MENU_OPTION.Create( "quit game", COMMAND_QUIT_GAME,, True, True ) ])

	all_menus[postfix_index()] = MENU.Create( "loading bay • %%profile.name%%", "loading bay", 255, 96, 64, MENU_ID_LOADING_BAY, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "continue game", COMMAND_NULL,, False, False ), ..
		MENU_OPTION.Create( "play campaign", COMMAND_NULL,, False, False ), ..
		MENU_OPTION.Create( "play custom level", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SELECT_LEVEL), True, True ), ..
		MENU_OPTION.Create( "buy parts", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_BUY_PARTS), True, True ), ..
		MENU_OPTION.Create( "sell parts", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SELL_PARTS), True, True ), ..
		MENU_OPTION.Create( "customize vehicle", COMMAND_EDIT_VEHICLE,, True, True ), ..
		MENU_OPTION.Create( "hall of glory", COMMAND_FULL_KILL_TALLY,, True, True ), ..
		MENU_OPTION.Create( "change name", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_PROFILE_NAME), True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "select level", "level", 96, 255, 127, MENU_ID_SELECT_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND_PLAY_LEVEL,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "buy parts • $%%profile.cash%%", "buy", 96, 233, 96, MENU_ID_BUY_PARTS, MENU.VERTICAL_LIST_WITH_INVENTORY, menu_margin,, "catalog",, COMMAND_BUY_PART,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "sell parts • $%%profile.cash%%", "sell", 244, 96, 244, MENU_ID_SELL_PARTS, MENU.VERTICAL_LIST_WITH_INVENTORY, menu_margin,, "inventory",, COMMAND_SELL_PART,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])

		all_menus[postfix_index()] = MENU.Create( "input profile name", "input", 255, 255, 255, MENU_ID_INPUT_PROFILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_PLAYER_PROFILE_NAME,, 20, "%%profile.name%%" )
		
	all_menus[postfix_index()] = MENU.Create( "unsaved progress, continue?", "confirm", 255, 64, 64, MENU_ID_CONFIRM_NEW_GAME, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND_NEW_GAME )

	all_menus[postfix_index()] = MENU.Create( "load game", "load", 96, 255, 127, MENU_ID_LOAD_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND_LOAD_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "settings", "settings", 127, 127, 255, MENU_ID_SETTINGS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "video settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_VIDEO), True, True ), ..
		MENU_OPTION.Create( "performance settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_PERFORMANCE), True, True ), ..
		MENU_OPTION.Create( "audio settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_AUDIO), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "video settings", "video", 212, 96, 226, MENU_ID_OPTIONS_VIDEO, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "fullscreen    %%fullscreen%%", COMMAND_SETTINGS_FULLSCREEN,, True, True ), ..
			MENU_OPTION.Create( "resolution    %%window_w%% x %%window_h%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CHOOSE_RESOLUTION), True, True ), ..
			MENU_OPTION.Create( "refresh rate  %%refresh_rate%% Hz", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_REFRESH_RATE), True, True ), ..
			MENU_OPTION.Create( "bit depth     %%bit_depth%% bpp", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_BIT_DEPTH), True, True ), ..
			MENU_OPTION.Create( "apply", COMMAND_SETTINGS_APPLY_ALL,, False, False ) ])
			
			all_menus[postfix_index()] = MENU.Create( "choose resolution", "resolution", 255, 255, 255, MENU_ID_CHOOSE_RESOLUTION, MENU.VERTICAL_LIST_WITH_SUBSECTION, menu_margin,,,,,,,, dynamic_subsection_window_size, ..
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
			
			all_menus[postfix_index()] = MENU.Create( "input refresh rate", "input", 255, 255, 255, MENU_ID_INPUT_REFRESH_RATE, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_REFRESH_RATE,, 10, "%%refresh_rate%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "input bit depth", "input", 255, 255, 255, MENU_ID_INPUT_BIT_DEPTH, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_BIT_DEPTH,, 10, "%%bit_depth%%"  )
		
		all_menus[postfix_index()] = MENU.Create( "performance settings", "performance", 212, 226, 96, MENU_ID_OPTIONS_PERFORMANCE, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "background AI game     %%show_ai_menu_game%%", COMMAND_SETTINGS_SHOW_AI_MENU_GAME,, True, True ), ..
			MENU_OPTION.Create( "retain particles       %%retain_particles%%", COMMAND_SETTINGS_RETAIN_PARTICLES,, True, True ), ..
			MENU_OPTION.Create( "active particle limit  %%active_particle_limit%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_PARTICLE_LIMIT), True, True ) ])

			all_menus[postfix_index()] = MENU.Create( "input particle limit", "input", 255, 255, 255, MENU_ID_INPUT_PARTICLE_LIMIT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_PARTICLE_LIMIT,, 10, "%%active_particle_limit%%"  )
	
	all_menus[postfix_index()] = MENU.Create( "preferences", "preferences", 64, 64, 212, MENU_ID_PREFERENCES, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "controls", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_CONTROLS), True, True ), ..
		MENU_OPTION.Create( "gameplay", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_GAME), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "control preferences", "controls", 127, 196, 255, MENU_ID_OPTIONS_CONTROLS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD), True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_XBOX_360_CONTROLLER), True, False ) ])
	
	all_menus[postfix_index()] = MENU.Create( "game data", "data", 196, 196, 196, MENU_ID_GAME_DATA, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "level editor", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LEVEL_EDITOR), True, True ), ..
		MENU_OPTION.Create( "reload external data", COMMAND_LOAD_ASSETS,, True, True ) ])
		
		all_menus[postfix_index()] = MENU.Create( "level editor", "editor", 96, 127, 255, MENU_ID_LEVEL_EDITOR, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "edit %%level_editor_cache.name%%", COMMAND_EDIT_LEVEL, level_editor_cache, True, True ), ..
			MENU_OPTION.Create( "save %%level_editor_cache.name%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_LEVEL), True, True ), ..
			MENU_OPTION.Create( "load level", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_LEVEL), True, True ), ..
			MENU_OPTION.Create( "create new", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CONFIRM_ERASE_LEVEL), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "save from level editor", "save", 255, 96, 127, MENU_ID_SAVE_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND_SAVE_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "new file", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_LEVEL_FILE_NAME), True, True )])
				
				all_menus[postfix_index()] = MENU.Create( "input filename", "input", 255, 255, 255, MENU_ID_INPUT_LEVEL_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, level_path, level_file_ext, COMMAND_SAVE_LEVEL,, 60, "%%level_editor_cache.name%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "load into level editor", "load", 96, 255, 127, MENU_ID_LOAD_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND_LOAD_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "abandon current level?", "confirm", 255, 64, 64, MENU_ID_CONFIRM_ERASE_LEVEL, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND_NEW_LEVEL )

'______________________________________________________________________________
'command_argument should be an object;
'  the object gets cast to an appropriate type automatically, a container type with all the information necessary
'  if the cast fails, the argument is invalid
Function menu_command( command_code%, argument:Object = Null )
	Local arg$ = ""
	If String(argument) Then arg = String(argument)
	If INTEGER(argument) Then arg = menu_id_to_string( INTEGER(argument).value ).ToLower()
	If INVENTORY_DATA(argument) Then arg = INVENTORY_DATA(argument).to_string()
	DebugLog( " "+pad( command_code_to_string( command_code ).ToLower(), 34 )+"  "+arg )
	
	Select command_code
		'________________________________________
		Case COMMAND_SHOW_CHILD_MENU
			current_menu :+ 1
			menu_stack[current_menu] = INTEGER(argument).value
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND_BACK_TO_PARENT_MENU
			If current_menu > 0 Then current_menu :- 1
		'________________________________________
		Case COMMAND_BACK_TO_MAIN_MENU
			FLAG_in_menu = True
			current_menu = 0
		'________________________________________
		Case COMMAND_PAUSE
			FLAG_in_menu = True
			current_menu = 1
			menu_stack[current_menu] = MENU_ID_PAUSED
			If main_game <> Null Then main_game.paused = True
			FlushKeys()
			FlushMouse()
		'________________________________________
		Case COMMAND_RESUME
			FLAG_in_menu = False
			If main_game <> Null Then main_game.paused = False
			MoveMouse( window_w/2 - 30, window_h/2 )
			FLAG_ignore_mouse_1 = True
		'________________________________________
		Case COMMAND_PLAY_LEVEL
			If profile And profile.vehicle
				Local player:COMPLEX_AGENT
				player = create_player( profile.vehicle )
				If player
					menu_command( COMMAND_BACK_TO_PARENT_MENU )
					menu_command( COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PAUSED) )
					play_level( String(argument), player )
				End If
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
		Case COMMAND_EDIT_VEHICLE
			profile.vehicle = vehicle_editor( profile.vehicle )
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
		Case COMMAND_FULL_KILL_TALLY
			If profile
				kill_tally( "kills so far", screencap(), profile.kills )
			End If
		'________________________________________
		Case COMMAND_BUY_PART
			profile.buy_part( INVENTORY_DATA(argument) )
			show_info( "new part purchased" )
		'________________________________________
		Case COMMAND_SELL_PART
			profile.sell_part( INVENTORY_DATA(argument) )
			get_current_menu().update()
			show_info( "part sold" )
		'________________________________________
		Case COMMAND_QUIT_LEVEL
			FLAG_in_menu = True
			'special circumstance - damaged part as a result of player death
			If damage_incurred
				damage_incurred = False
				If profile And profile.vehicle
					profile.damage_part( profile.vehicle.select_random_part() )
				End If
			End If
			menu_command( COMMAND_SAVE_GAME )
			main_game = Null
			game = ai_menu_game
		'________________________________________
		Case COMMAND_QUIT_GAME
			menu_command( COMMAND_QUIT_LEVEL )
			End
			
	End Select
	get_current_menu().recalculate_dimensions()
	get_current_menu().update()
	
End Function

'______________________________________________________________________________
Function resolve_meta_variables$( str$, argument:Object = Null )
	Local tokens$[] = str.Split( "%%" )
	Local result$ = ""
	For Local i% = 0 To tokens.Length - 1
		If i Mod 2 = 1 'inside a meta-variable identifier
			Select tokens[i]
				Case "profile.name"
					If profile
						result :+ profile.name
					End If
				Case "profile.cash"
					If profile
						result :+ format_number( profile.cash )
					End If
				Case "profile.kills"
					If profile
						result :+ format_number( profile.kills )
					End If
				Case "level_editor_cache.name"
					If level_editor_cache
						result :+ level_editor_cache.name
					End If
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
				Case "profile.count_inventory(this)"
					If profile
						result :+ "(x "+format_number( profile.count_inventory( INVENTORY_DATA(argument) ))+")"
					End If
			End Select
		Else 'outside a meta-variable (string literal)
			result :+ tokens[i]
		End If
	Next
	Return result
End Function

'______________________________________________________________________________
Const COMMAND_NULL% = 0
Const COMMAND_LOAD_ASSETS% = 10
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_BACK_TO_MAIN_MENU% = 53
Const COMMAND_PLAY_LEVEL% = 100
Const COMMAND_FULL_KILL_TALLY% = 110
Const COMMAND_BUY_PART% = 3000
Const COMMAND_SELL_PART% = 3010
Const COMMAND_PAUSE% = 2000
Const COMMAND_RESUME% = 2010
Const COMMAND_NEW_GAME% = 200
Const COMMAND_NEW_LEVEL% = 210
Const COMMAND_LOAD_GAME% = 300
Const COMMAND_LOAD_LEVEL% = 310
Const COMMAND_SAVE_GAME% = 400
Const COMMAND_SAVE_LEVEL% = 401
Const COMMAND_EDIT_LEVEL% = 500
Const COMMAND_EDIT_VEHICLE% = 550
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
		Case COMMAND_FULL_KILL_TALLY
			Return "COMMAND_FULL_KILL_TALLY"
		Case COMMAND_BUY_PART
			Return "COMMAND_BUY_PART"
		Case COMMAND_SELL_PART
			Return "COMMAND_SELL_PART"
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
		Case COMMAND_EDIT_VEHICLE
			Return "COMMAND_EDIT_VEHICLE"
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
Const MENU_ID_MAIN_MENU% = 100
Const MENU_ID_LOADING_BAY% = 200
Const MENU_ID_INPUT_PROFILE_NAME% = 205
Const MENU_ID_SELECT_LEVEL% = 270
Const MENU_ID_CASH_TOTAL% = 700
Const MENU_ID_PARTS_CATALOG% = 710
Const MENU_ID_BUY_PARTS% = 720
Const MENU_ID_SELL_PARTS% = 730
Const MENU_ID_MULTIPLAYER% = 1000
Const MENU_ID_MULTIPLAYER_JOIN% = 1160
Const MENU_ID_MULTIPLAYER_HOST% = 1170
Const MENU_ID_MULTIPLAYER_INPUT_IP_ADDRESS% = 1180
Const MENU_ID_MULTIPLAYER_INPUT_IP_PORT% = 1181
Const MENU_ID_CONFIRM_NEW_GAME% = 299
Const MENU_ID_LOAD_GAME% = 300
Const MENU_ID_CONFIRM_LOAD_GAME% = 310
Const MENU_ID_LOAD_LEVEL% = 315
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
		Case MENU_ID_CASH_TOTAL
			Return "MENU_ID_CASH_TOTAL"
		Case MENU_ID_PARTS_CATALOG
			Return "MENU_ID_PARTS_CATALOG"
		Case MENU_ID_BUY_PARTS
			Return "MENU_ID_BUY_PARTS"
		Case MENU_ID_SELL_PARTS
			Return "MENU_ID_SELL_PARTS"
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
		Case MENU_ID_CONFIRM_NEW_GAME
			Return "MENU_ID_CONFIRM_NEW_GAME"
		Default
			Return String.FromInt( menu_id )
	End Select
End Function

