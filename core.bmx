Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "misc.bmx"
Import "flags.bmx"

'______________________________________________________________________________
'generic
Const PICKUP_PROBABILITY# = 0.25 'chance of an enemy dropping a pickup (randomly selected from all pickups)
Const arena_lights_fade_time% = 1000 'this should be in environment class
Global level_intro_time% = 2000 'this is deprecated
'notificationss
Global info$
Const info_stay_time% = 3000
Const info_fade_time% = 1250
Global info_change_ts% = now()
'player events
Global last_kill_ts%
Const FRIENDLY_FIRE_PUNISHMENT_AMOUNT% = 75
'multiplayer
Global playing_multiplayer% = False

'environmental objects
Global profile:PLAYER_PROFILE
Global level_editor_cache:LEVEL
Global main_game:ENVIRONMENT 'game in which player participates
Global ai_menu_game:ENVIRONMENT 'menu ai demo environment
Global game:ENVIRONMENT 'current game environment
	
'app state flags
'Global FLAG_in_menu% = True
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
		FLAG.engine_ignition = True
		reset_mouse( player.ang )
	Else 'Not main_game.load_level()
		main_game = Null
	End If
End Function
'______________________________________________________________________________
Function create_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA, validate_against_inventory% = True, count_turrets% = True )
	If Not v_dat Then Return Null 'no chassis data
	If v_dat.is_unit
		Return get_unit( v_dat.chassis_key )
	Else 'Not is_unit
		Local at_least_one_turret% = False 'indicates whether this player-constructed chassis specifies at least one turret
		Local required_items:TList = CreateList() 'a laundry list of all the items required to build this chassis
		required_items.AddLast( Create_INVENTORY_DATA( "chassis", v_dat.chassis_key ))
		Local player:COMPLEX_AGENT
		player = get_player_chassis( v_dat.chassis_key )
		If player
			player.political_alignment = ALIGNMENT_FRIENDLY
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
						at_least_one_turret = True
					End If
				Next
			Next
			If count_turrets And Not at_least_one_turret
				show_info( "Your vehicle schematic must specify at least one turret." )
				Return Null 'must have at least one turret
			End If
			If validate_against_inventory
				If Not profile.checklist( required_items )
					show_info( "Your vehicle schematic specifies items that were damaged or sold." )
					Return Null 'not enough items to build player
				End If
			End If
			Return player 'all good!
		Else
			show_info( "Your vehicle schematic is invalid." )
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
Function record_player_friendly_fire_kill( punishment_amount% )
	If profile
		profile.cash :- FRIENDLY_FIRE_PUNISHMENT_AMOUNT
		If profile.cash < 0 Then profile.cash = 0
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
	ai_menu_game.mouse = mouse.to_cvec()
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
		draw_fuzzy( bg )
		
		If animating
			If (now() - transition_ts) > transition_time
				If kills_counted < kills_this_level - 1
					kills_counted :+ 1
					If transition_time > 0 Then transition_time = 2016000.0/(5.0*Float(now() - begin_ts) + 4600.0) - 30.0
					play_sound( get_sound( "mgun_hit" ), 0.1 + transition_time/400.0, 0.3333 )
					transition_ts = now()
				Else 'kills_counted >= kills_this_level
					kills_counted = kills_this_level
					animating = False
				End If
			End If
			If (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ) Or KeyHit( KEY_ESCAPE ) Or MouseHit( 1 ))
				kills_counted = kills_this_level
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
			kills_msg = format_number( kills_counted - 1 )+" kills"
			SetAlpha( time_alpha_pct( begin_ts, transition_time, False ))
			DrawText_with_glow( kills_msg, window_w/2 - TextWidth( kills_msg )/2, 95 )
			SetAlpha( time_alpha_pct( begin_ts - transition_time/2, transition_time, True ))
		Else
			SetAlpha( 1 )
		End If
		kills_msg = format_number( kills_counted )+" kills"
		DrawText_with_glow( kills_msg, window_w/2 - TextWidth( kills_msg )/2, 95 )
		
		If animating
			SetAlpha( time_alpha_pct( begin_ts, transition_time, False ))
			draw_skulls( 20, 140, window_w - 40, kills_counted - 1 )
			SetAlpha( time_alpha_pct( begin_ts - transition_time/2, transition_time, True ))
		Else
			SetAlpha( 1 )
		End If
		draw_skulls( 20, 140, window_w - 40, kills_counted )
		
		SetColor( 212, 64, 64 )
		SetAlpha( 1 )
		SetImageFont( get_font( "consolas_bold_14" ))
		DrawText_with_glow( continue_msg, window_w/2 - TextWidth( continue_msg )/2, window_h - 60 )
		
		Flip()
		
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

reset_index()
all_menus[postfix_index()] = MENU.Create( "main menu", "main", 255, 255, 127, MENU_ID.MAIN_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
[	MENU_OPTION.Create( "play game", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LOADING_BAY), True, False ), ..
	MENU_OPTION.Create( "profile", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.PROFILE_MENU), True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SETTINGS), True, True ), ..
	MENU_OPTION.Create( "advanced", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.GAME_DATA), True, True ), ..
	MENU_OPTION.Create( "quit", COMMAND.QUIT_GAME,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "profile", "profile", 255, 96, 127, MENU_ID.PROFILE_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "create new profile", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CONFIRM_NEW_GAME), True, True ), ..
		MENU_OPTION.Create( "save • %%profile.name%%", COMMAND.SAVE_GAME,, True, False ), ..
		MENU_OPTION.Create( "load profile", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LOAD_GAME), True, True ), ..
		MENU_OPTION.Create( "preferences", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.PREFERENCES), True, False ), ..
		MENU_OPTION.Create( "change name", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_PROFILE_NAME), True, True ) ])

	all_menus[postfix_index()] = MENU.Create( "game menu • %%profile.name%%", "game", 255, 96, 64, MENU_ID.LOADING_BAY, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
	[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "continue game", COMMAND.Null,, False, False ), ..
		MENU_OPTION.Create( "play campaign", COMMAND.Null,, False, False ), ..
		MENU_OPTION.Create( "play custom level", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SELECT_LEVEL), True, True ), ..
		MENU_OPTION.Create( "play multiplayer", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.MULTIPLAYER), True, True ), ..
		MENU_OPTION.Create( "buy parts", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.BUY_PARTS), True, True ), ..
		MENU_OPTION.Create( "sell parts", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SELL_PARTS), True, True ), ..
		MENU_OPTION.Create( "customize vehicle", COMMAND.EDIT_VEHICLE,, True, True ), ..
		MENU_OPTION.Create( "hall of glory", COMMAND.FULL_KILL_TALLY,, True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "select level", "level", 96, 255, 127, MENU_ID.SELECT_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.PLAY_LEVEL,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "play multiplayer", "multi", 196, 96, 96, MENU_ID.MULTIPLAYER, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "join game", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.MULTIPLAYER_JOIN_GAME), True, True ), ..
			MENU_OPTION.Create( "create game", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.MULTIPLAYER_CREATE_GAME), True, True ) ])
		
			all_menus[postfix_index()] = MENU.Create( "join game", "multi", 196, 96, 96, MENU_ID.MULTIPLAYER_JOIN_GAME, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
			[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "IP address %%network_ip_address%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_NETWORK_IP_ADDRESS), True, True ), ..
				MENU_OPTION.Create( "port %%network_port%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_NETWORK_PORT), True, True ), ..
				MENU_OPTION.Create( "join", COMMAND.CONNECT_TO_NETWORK_GAME,, True, True ) ])
	
				all_menus[postfix_index()] = MENU.Create( "input IP address", "input", 255, 255, 255, MENU_ID.INPUT_NETWORK_IP_ADDRESS, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.NETWORK_IP_ADDRESS,, 25, "%%network_ip_address%%" )

				all_menus[postfix_index()] = MENU.Create( "input port", "input", 255, 255, 255, MENU_ID.INPUT_NETWORK_PORT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.NETWORK_PORT,, 8, "%%network_port%%" )

			all_menus[postfix_index()] = MENU.Create( "create game", "multi", 196, 96, 96, MENU_ID.MULTIPLAYER_CREATE_GAME, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
			[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "port %%network_port%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_NETWORK_PORT), True, True ), ..
				MENU_OPTION.Create( "level %%network_level%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SELECT_NETWORK_LEVEL), True, True ), ..
				MENU_OPTION.Create( "create", COMMAND.HOST_NETWORK_GAME,, True, True ) ])
				
				all_menus[postfix_index()] = MENU.Create( "select level", "level", 96, 255, 127, MENU_ID.SELECT_NETWORK_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.NETWORK_LEVEL,,,, dynamic_subsection_window_size, ..
				[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "buy parts • $%%profile.cash%%", "buy", 96, 233, 96, MENU_ID.BUY_PARTS, MENU.VERTICAL_LIST_WITH_INVENTORY, menu_margin,, "catalog",, COMMAND.BUY_PART,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])
	
		all_menus[postfix_index()] = MENU.Create( "sell parts • $%%profile.cash%%", "sell", 244, 96, 244, MENU_ID.SELL_PARTS, MENU.VERTICAL_LIST_WITH_INVENTORY, menu_margin,, "inventory",, COMMAND.SELL_PART,,,, dynamic_subsection_window_size, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])

		all_menus[postfix_index()] = MENU.Create( "input profile name", "input", 255, 255, 255, MENU_ID.INPUT_PROFILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.PLAYER_PROFILE_NAME,, 20, "%%profile.name%%" )
		
	all_menus[postfix_index()] = MENU.Create( "unsaved progress, continue?", "confirm", 255, 64, 64, MENU_ID.CONFIRM_NEW_GAME, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND.NEW_GAME )

	all_menus[postfix_index()] = MENU.Create( "load profile", "load", 96, 255, 127, MENU_ID.LOAD_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND.LOAD_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "settings", "settings", 127, 127, 255, MENU_ID.SETTINGS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "video settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_VIDEO), True, True ), ..
		MENU_OPTION.Create( "performance settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_PERFORMANCE), True, True ), ..
		MENU_OPTION.Create( "audio settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_AUDIO), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "video settings", "video", 212, 96, 226, MENU_ID.OPTIONS_VIDEO, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "fullscreen    %%fullscreen%%", COMMAND.SETTINGS_FULLSCREEN,, True, True ), ..
			MENU_OPTION.Create( "resolution    %%window_w%% x %%window_h%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CHOOSE_RESOLUTION), True, True ), ..
			MENU_OPTION.Create( "refresh rate  %%refresh_rate%% Hz", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_REFRESH_RATE), True, True ), ..
			MENU_OPTION.Create( "bit depth     %%bit_depth%% bpp", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_BIT_DEPTH), True, True ), ..
			MENU_OPTION.Create( "apply", COMMAND.SETTINGS_APPLY_ALL,, False, False ) ])
			
			all_menus[postfix_index()] = MENU.Create( "choose resolution", "resolution", 255, 255, 255, MENU_ID.CHOOSE_RESOLUTION, MENU.VERTICAL_LIST_WITH_SUBSECTION, menu_margin,,,,,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])
			Local m:MENU = get_menu(MENU_ID.CHOOSE_RESOLUTION)
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
					m.add_option( MENU_OPTION.Create( "" + modes[i].width + " x " + modes[i].height, COMMAND.SETTINGS_RESOLUTION, [ modes[i].width, modes[i].height ], True, True ))
				End If
			Next
			
			all_menus[postfix_index()] = MENU.Create( "input refresh rate", "input", 255, 255, 255, MENU_ID.INPUT_REFRESH_RATE, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.SETTINGS_REFRESH_RATE,, 10, "%%refresh_rate%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "input bit depth", "input", 255, 255, 255, MENU_ID.INPUT_BIT_DEPTH, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.SETTINGS_BIT_DEPTH,, 10, "%%bit_depth%%"  )
		
		all_menus[postfix_index()] = MENU.Create( "performance settings", "performance", 212, 226, 96, MENU_ID.OPTIONS_PERFORMANCE, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "background AI game     %%show_ai_menu_game%%", COMMAND.SETTINGS_SHOW_AI_MENU_GAME,, True, True ), ..
			MENU_OPTION.Create( "retain particles       %%retain_particles%%", COMMAND.SETTINGS_RETAIN_PARTICLES,, True, True ), ..
			MENU_OPTION.Create( "active particle limit  %%active_particle_limit%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_PARTICLE_LIMIT), True, True ) ])

			all_menus[postfix_index()] = MENU.Create( "input particle limit", "input", 255, 255, 255, MENU_ID.INPUT_PARTICLE_LIMIT, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND.SETTINGS_PARTICLE_LIMIT,, 10, "%%active_particle_limit%%"  )
	
	all_menus[postfix_index()] = MENU.Create( "preferences", "preferences", 64, 64, 212, MENU_ID.PREFERENCES, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "controls", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_CONTROLS), True, True ), ..
		MENU_OPTION.Create( "invert reverse steering %%profile.invert_reverse_steering%%", COMMAND.PLAYER_INVERT_REVERSE_STEERING,, True, True ), ..
		MENU_OPTION.Create( "gameplay", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.OPTIONS_GAME), True, False ) ])
		
		all_menus[postfix_index()] = MENU.Create( "control preferences", "controls", 127, 196, 255, MENU_ID.OPTIONS_CONTROLS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "keyboard only", COMMAND.PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD), True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND.PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND.PLAYER_INPUT_TYPE, INTEGER.Create(CONTROL_BRAIN.INPUT_XBOX_360_CONTROLLER), True, False ) ])
	
	all_menus[postfix_index()] = MENU.Create( "advanced", "advanced", 196, 196, 196, MENU_ID.GAME_DATA, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "level editor", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LEVEL_EDITOR), True, True ), ..
		MENU_OPTION.Create( "reload external data", COMMAND.LOAD_ASSETS,, True, True ) ])
		
		all_menus[postfix_index()] = MENU.Create( "level editor", "editor", 96, 127, 255, MENU_ID.LEVEL_EDITOR, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "edit %%level_editor_cache.name%%", COMMAND.EDIT_LEVEL, level_editor_cache, True, True ), ..
			MENU_OPTION.Create( "save %%level_editor_cache.name%%", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SAVE_LEVEL), True, True ), ..
			MENU_OPTION.Create( "load level", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.LOAD_LEVEL), True, True ), ..
			MENU_OPTION.Create( "create new", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.CONFIRM_ERASE_LEVEL), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "save from level editor", "save", 255, 96, 127, MENU_ID.SAVE_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.SAVE_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "new file", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_LEVEL_FILE_NAME), True, True )])
				
				all_menus[postfix_index()] = MENU.Create( "input filename", "input", 255, 255, 255, MENU_ID.INPUT_LEVEL_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, level_path, level_file_ext, COMMAND.SAVE_LEVEL,, 60, "%%level_editor_cache.name%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "load into level editor", "load", 96, 255, 127, MENU_ID.LOAD_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, level_path, level_file_ext, COMMAND.LOAD_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "« back", COMMAND.BACK_TO_PARENT_MENU,, True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "abandon current level?", "confirm", 255, 64, 64, MENU_ID.CONFIRM_ERASE_LEVEL, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND.NEW_LEVEL )

all_menus[postfix_index()] = MENU.Create( "game paused", "pause", 96, 96, 96, MENU_ID.PAUSED, MENU.VERTICAL_LIST, menu_margin, -1,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND.RESUME,, True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.PREFERENCES), True, True ), ..
	MENU_OPTION.Create( "abandon level", COMMAND.QUIT_LEVEL,, True, True ), ..
	MENU_OPTION.Create( "quit game", COMMAND.QUIT_GAME,, True, True ) ])

'______________________________________________________________________________
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
			If profile And profile.vehicle
				Local player:COMPLEX_AGENT
				player = create_player( profile.vehicle )
				If player
					'put the "paused" menu on top of the menu stack
					If current_menu > 0 Then current_menu :- 1
					current_menu :+ 1
					menu_stack[current_menu] = MENU_ID.PAUSED
					get_current_menu().update( True )
					
					play_level( String(argument), player )
				End If
			End If
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
		'________________________________________
		Case COMMAND.BACK_TO_PARENT_MENU
			If current_menu > 0 Then current_menu :- 1
		'________________________________________
		Case COMMAND.BACK_TO_MAIN_MENU
			FLAG_in_menu = True
			current_menu = 0
		'________________________________________
		Case COMMAND.PAUSE
			FLAG_in_menu = True
			current_menu = 1
			menu_stack[current_menu] = MENU_ID.PAUSED
			If main_game <> Null Then main_game.paused = True
			FlushKeys()
			FlushMouse()
		'________________________________________
		Case COMMAND.RESUME
			FLAG_in_menu = False
			If main_game <> Null Then main_game.paused = False
			If game And game.player Then reset_mouse( game.player.ang )
			FLAG_ignore_mouse_1 = True
		'________________________________________
		Case COMMAND.NEW_GAME
			profile = New PLAYER_PROFILE
			profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
			profile.cash = 250
			profile.add_part( Create_INVENTORY_DATA( "chassis", "light_tank", 1 ))
			profile.add_part( Create_INVENTORY_DATA( "turret", "light_cannon", 1 ))
			profile.add_part( Create_INVENTORY_DATA( "turret", "light_machine_gun", 1 ))
			profile.vehicle = Create_VEHICLE_DATA( "light_tank",, [[ "light_cannon", "light_machine_gun" ]] )
			show_info( "new profile created" )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
			'immediately rename profile
			menu_command( COMMAND.SHOW_CHILD_MENU, INTEGER.Create(MENU_ID.INPUT_PROFILE_NAME) )
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
				show_info( "loaded profile "+profile.name+" from "+profile.src_path )
			End If
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			get_current_menu().update( True )
		'________________________________________
		Case COMMAND.SAVE_GAME
			If profile
				If save_game( profile.src_path, profile )
					save_autosave( profile.src_path )
					show_info( "saved profile "+profile.name+" to "+profile.src_path )
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
			show_info( "loaded level "+level_editor_cache.name+" from "+String(argument) )
			get_menu( MENU_ID.LEVEL_EDITOR ).recalculate_dimensions()
			menu_command( COMMAND.EDIT_LEVEL )
		'________________________________________
		Case COMMAND.SAVE_LEVEL
			save_level( String(argument), level_editor_cache )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			show_info( "saved level "+level_editor_cache.name+" to "+String(argument) )
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
				window = Create_BOX( 0, 0, window_w, window_h )
			menu_command( COMMAND.SETTINGS_APPLY_ALL )
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
			init_ai_menu_game()
			If main_game <> Null Then main_game.calculate_camera_constraints()
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
		Case COMMAND.SETTINGS_SHOW_AI_MENU_GAME
			show_ai_menu_game = Not show_ai_menu_game
			If ai_menu_game And Not show_ai_menu_game
				ai_menu_game = Null
			Else If Not ai_menu_game And show_ai_menu_game
				init_ai_menu_game()
			End If
			save_settings()
		'________________________________________
		Case COMMAND.SETTINGS_RETAIN_PARTICLES
			retain_particles = Not retain_particles
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
			level_editor( level_editor_cache )
		'________________________________________
		Case COMMAND.EDIT_VEHICLE
			If profile
				profile.sort_inventory()
				profile.vehicle = vehicle_editor( profile.vehicle )
				menu_command( COMMAND.SAVE_GAME )
			End If
		'________________________________________
		Case COMMAND.LOAD_ASSETS
			SetImageFont( LoadImageFont( "fonts/consolas.ttf", 4 ))
			If argument Then load_assets( True ) ..
			Else             load_assets( False )
			MENU.load_fonts()
			If show_ai_menu_game
				init_ai_menu_game()
			End If
			show_info( "external data loaded" )
		'________________________________________
		Case COMMAND.FULL_KILL_TALLY
			If profile
				kill_tally( "total kills",, profile.kills )
			End If
		'________________________________________
		Case COMMAND.BUY_PART
			profile.buy_part( INVENTORY_DATA(argument) )
			show_info( "new part purchased" )
			profile.sort_inventory()
			menu_command( COMMAND.SAVE_GAME )
		'________________________________________
		Case COMMAND.SELL_PART
			profile.sell_part( INVENTORY_DATA(argument) )
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
			FLAG_in_menu = True
			main_game = Null
			game = ai_menu_game
			'special circumstance - damaged part as a result of player death
			If damage_incurred
				damage_incurred = False
				If profile And profile.vehicle
					profile.damage_part( profile.vehicle.select_random_part() )
				End If
			End If
			menu_command( COMMAND.SAVE_GAME )
			menu_command( COMMAND.BACK_TO_MAIN_MENU )
			menu_command( COMMAND.SHOW_CHILD_MENU, INTEGER.Create( MENU_ID.LOADING_BAY ))
			If playing_multiplayer 
				playing_multiplayer = False
				network_terminate()
			End If
		'________________________________________
		Case COMMAND.QUIT_GAME
			menu_command( COMMAND.QUIT_LEVEL )
			End
			
	End Select
	Local m:MENU = get_current_menu()
	m.recalculate_dimensions()
	m.update()
	
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
				Case "profile.invert_reverse_steering"
					If profile
						result :+ boolean_to_string( profile.invert_reverse_steering )
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
				Case "network_ip_address"
					result :+ network_ip_address
				Case "network_port"
					result :+ network_port
				Case "network_level"
					result :+ StripAll( network_level )
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
Type COMMAND
	Const NONE% = 0
	Const LOAD_ASSETS% = 10
	Const SHOW_CHILD_MENU% = 50
	Const BACK_TO_PARENT_MENU% = 51
	Const BACK_TO_MAIN_MENU% = 53
	Const PLAY_LEVEL% = 100
	Const FULL_KILL_TALLY% = 110
	Const BUY_PART% = 3000
	Const SELL_PART% = 3010
	Const PAUSE% = 2000
	Const RESUME% = 2010
	Const NEW_GAME% = 200
	Const NEW_LEVEL% = 210
	Const LOAD_GAME% = 300
	Const LOAD_LEVEL% = 310
	Const SAVE_GAME% = 400
	Const SAVE_LEVEL% = 401
	Const EDIT_LEVEL% = 500
	Const EDIT_VEHICLE% = 550
	Const CONNECT_TO_NETWORK_GAME% = 650
	Const HOST_NETWORK_GAME% = 655
	Const PLAYER_PROFILE_NAME% = 700
	Const PLAYER_PROFILE_PATH% = 710
	Const PLAYER_INPUT_TYPE% = 1000
	Const PLAYER_INVERT_REVERSE_STEERING% = 1001
	Const SETTINGS_FULLSCREEN% = 1010
	Const SETTINGS_RESOLUTION% = 1011
	Const SETTINGS_REFRESH_RATE% = 1012
	Const SETTINGS_BIT_DEPTH% = 1013
	Const NETWORK_IP_ADDRESS% = 1020
	Const NETWORK_PORT% = 1021
	Const NETWORK_LEVEL% = 1022
	Const SETTINGS_SHOW_AI_MENU_GAME% = 1025
	Const SETTINGS_RETAIN_PARTICLES% = 1030
	Const SETTINGS_PARTICLE_LIMIT% = 1031
	Const SETTINGS_APPLY_ALL% = 1100
	Const QUIT_LEVEL% = 10010
	Const QUIT_GAME% = 65535
	
	Function decode$( code% )
		Select code
			Case NONE; Return "NONE"
			Case LOAD_ASSETS; Return "LOAD_ASSETS"
			Case SHOW_CHILD_MENU; Return "SHOW_CHILD_MENU"
			Case BACK_TO_PARENT_MENU; Return "BACK_TO_PARENT_MENU"
			Case BACK_TO_MAIN_MENU; Return "BACK_TO_MAIN_MENU"
			Case PLAY_LEVEL; Return "PLAY_LEVEL"
			Case CONNECT_TO_NETWORK_GAME; Return "CONNECT_TO_NETWORK_GAME"
			Case HOST_NETWORK_GAME; Return "HOST_NETWORK_GAME"
			Case FULL_KILL_TALLY; Return "FULL_KILL_TALLY"
			Case BUY_PART; Return "BUY_PART"
			Case SELL_PART; Return "SELL_PART"
			Case PAUSE; Return "PAUSE"
			Case RESUME; Return "RESUME"
			Case NEW_GAME; Return "NEW_GAME"
			Case NEW_LEVEL; Return "NEW_LEVEL"
			Case LOAD_GAME; Return "LOAD_GAME"
			Case LOAD_LEVEL; Return "LOAD_LEVEL"
			Case SAVE_GAME; Return "SAVE_GAME"
			Case SAVE_LEVEL; Return "SAVE_LEVEL"
			Case EDIT_LEVEL; Return "EDIT_LEVEL"
			Case EDIT_VEHICLE; Return "EDIT_VEHICLE"
			Case PLAYER_PROFILE_NAME; Return "PLAYER_PROFILE_NAME"
			Case PLAYER_PROFILE_PATH; Return "PLAYER_PROFILE_PATH"
			Case PLAYER_INPUT_TYPE; Return "PLAYER_INPUT_TYPE"
			Case PLAYER_INVERT_REVERSE_STEERING; Return "PLAYER_INVERT_REVERSE_STEERING"
			Case SETTINGS_FULLSCREEN; Return "SETTINGS_FULLSCREEN"
			Case SETTINGS_RESOLUTION; Return "SETTINGS_RESOLUTION"
			Case SETTINGS_REFRESH_RATE; Return "SETTINGS_REFRESH_RATE"
			Case SETTINGS_BIT_DEPTH; Return "SETTINGS_BIT_DEPTH"
			Case NETWORK_IP_ADDRESS; Return "NETWORK_IP_ADDRESS"
			Case NETWORK_PORT; Return "NETWORK_PORT"
			Case NETWORK_LEVEL; Return "NETWORK_LEVEL"
			Case SETTINGS_SHOW_AI_MENU_GAME; Return "SETTINGS_SHOW_AI_MENU_GAME"
			Case SETTINGS_RETAIN_PARTICLES; Return "SETTINGS_RETAIN_PARTICLES"
			Case SETTINGS_PARTICLE_LIMIT; Return "SETTINGS_PARTICLE_LIMIT"
			Case SETTINGS_APPLY_ALL; Return "SETTINGS_APPLY_ALL"
			Case QUIT_LEVEL; Return "QUIT_LEVEL"
			Case QUIT_GAME; Return "QUIT_GAME"
			Default; Return String.FromInt( code )
		End Select
	End Function
End Type

'______________________________________________________________________________
Type MENU_ID
	Const MAIN_MENU% = 100
	Const PAUSED% = 105
	Const PROFILE_MENU% = 155
	Const LOADING_BAY% = 200
	Const INPUT_PROFILE_NAME% = 205
	Const SELECT_LEVEL% = 270
	Const CONFIRM_NEW_GAME% = 299
	Const LOAD_GAME% = 300
	Const CONFIRM_LOAD_GAME% = 310
	Const LOAD_LEVEL% = 315
	Const SAVE_GAME% = 400
	Const INPUT_GAME_FILE_NAME% = 410
	Const SAVE_LEVEL% = 450
	Const INPUT_LEVEL_FILE_NAME% = 460
	Const CONFIRM_ERASE_LEVEL% = 470
	Const SETTINGS% = 500
	Const OPTIONS_PERFORMANCE% = 501
	Const PREFERENCES% = 505
	Const OPTIONS_VIDEO% = 510
	Const CHOOSE_RESOLUTION% = 511
	Const INPUT_REFRESH_RATE% = 512
	Const INPUT_BIT_DEPTH% = 513
	Const INPUT_PARTICLE_LIMIT% = 514
	Const OPTIONS_AUDIO% = 520
	Const OPTIONS_CONTROLS% = 530
	Const OPTIONS_GAME% = 540
	Const GAME_DATA% = 600
	Const LEVEL_EDITOR% = 610
	Const CASH_TOTAL% = 700
	Const PARTS_CATALOG% = 710
	Const BUY_PARTS% = 720
	Const SELL_PARTS% = 730
	Const MULTIPLAYER% = 800
	Const MULTIPLAYER_JOIN_GAME% = 810
	Const MULTIPLAYER_CREATE_GAME% = 811
	Const INPUT_NETWORK_IP_ADDRESS% = 820
	Const INPUT_NETWORK_PORT% = 821
	Const SELECT_NETWORK_LEVEL% = 822
	
	Function decode$( code% )
		Select code
			Case MAIN_MENU; Return "MAIN_MENU"
			Case LOADING_BAY; Return "LOADING_BAY"
			Case INPUT_PROFILE_NAME; Return "INPUT_PROFILE_NAME"
			Case SELECT_LEVEL; Return "SELECT_LEVEL"
			Case CASH_TOTAL; Return "CASH_TOTAL"
			Case PARTS_CATALOG; Return "PARTS_CATALOG"
			Case BUY_PARTS; Return "BUY_PARTS"
			Case SELL_PARTS; Return "SELL_PARTS"
			Case MULTIPLAYER; Return "MULTIPLAYER"
			Case MULTIPLAYER_JOIN_GAME; Return "MULTIPLAYER_JOIN_GAME"
			Case MULTIPLAYER_CREATE_GAME; Return "MULTIPLAYER_CREATE_GAME"
			Case INPUT_NETWORK_IP_ADDRESS; Return "INPUT_NETWORK_IP_ADDRESS"
			Case INPUT_NETWORK_PORT; Return "INPUT_NETWORK_PORT"
			Case SELECT_NETWORK_LEVEL; Return "SELECT_NETWORK_LEVEL"
			Case LOAD_GAME; Return "LOAD_GAME"
			Case CONFIRM_LOAD_GAME; Return "CONFIRM_LOAD_GAME"
			Case LOAD_LEVEL; Return "LOAD_LEVEL"
			Case SAVE_GAME; Return "SAVE_GAME"
			Case INPUT_GAME_FILE_NAME; Return "INPUT_GAME_FILE_NAME"
			Case SAVE_LEVEL; Return "SAVE_LEVEL"
			Case INPUT_LEVEL_FILE_NAME; Return "INPUT_LEVEL_FILE_NAME"
			Case CONFIRM_ERASE_LEVEL; Return "CONFIRM_ERASE_LEVEL"
			Case SETTINGS; Return "SETTINGS"
			Case OPTIONS_PERFORMANCE; Return "OPTIONS_PERFORMANCE"
			Case PREFERENCES; Return "PREFERENCES"
			Case OPTIONS_VIDEO; Return "OPTIONS_VIDEO"
			Case CHOOSE_RESOLUTION; Return "CHOOSE_RESOLUTION"
			Case INPUT_REFRESH_RATE; Return "INPUT_REFRESH_RATE"
			Case INPUT_BIT_DEPTH; Return "INPUT_BIT_DEPTH"
			Case INPUT_PARTICLE_LIMIT; Return "INPUT_PARTICLE_LIMIT"
			Case OPTIONS_AUDIO; Return "OPTIONS_AUDIO"
			Case OPTIONS_CONTROLS; Return "OPTIONS_CONTROLS"
			Case OPTIONS_GAME; Return "OPTIONS_GAME"
			Case GAME_DATA; Return "GAME_DATA"
			Case LEVEL_EDITOR; Return "LEVEL_EDITOR"
			Case PAUSED; Return "PAUSED"
			Case CONFIRM_NEW_GAME; Return "CONFIRM_NEW_GAME"
			Case PROFILE_MENU; Return "PROFILE_MENU"
			Default; Return String.FromInt( code )
		End Select
	End Function
End Type

