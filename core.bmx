Rem
	core.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "level.bmx"
'Import "environment.bmx"
'Import "complex_agent.bmx"
'Import "player_profile.bmx"
'Import "turret.bmx"
'Import "control_brain.bmx"
'Import "player_profile.bmx"
'Import "audio.bmx"
'Import "color.bmx"
'Import "inventory_data.bmx"
'Import "menu.bmx"
'Import "menu_option.bmx"
'Import "data.bmx"
'Import "net.bmx"
'Import "constants.bmx"
'Import "misc.bmx"
'Import "settings.bmx"
'Import "flags.bmx"
'Import "mouse.bmx"
'Import "graphics_base.bmx"
'Import "level_editor.bmx"
''Import "vehicle_editor.bmx"
'Import "image_chooser.bmx"
'Include "core_menus.bmx"
'Include "core_menu_commands.bmx"

'______________________________________________________________________________
'generic
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

'app state flags
'Global FLAG_in_menu% = True
Global FLAG_draw_help% = False
Global FLAG_console% = False

'environmental objects
Global main_game:ENVIRONMENT 'game in which player participates
Global ai_menu_game:ENVIRONMENT 'menu ai demo environment
'current environment reference
Global game:ENVIRONMENT 'current game environment

Global level_editor_cache:LEVEL

Function select_game()
	If FLAG.in_menu
		If main_game = Null
			game = ai_menu_game 'initial condition; show autonomous game
		Else 'main_game <> Null
			game = main_game 'paused after beginning game
		End If
	Else 'Not FLAG_in_menu
		game = main_game 'normal play
	End If
End Function

Function get_active_games:TList()
	Local list:TList = CreateList()
	If main_game    Then list.AddLast( main_game )
	If ai_menu_game Then list.AddLast( ai_menu_game )
	Return list
End Function

'______________________________________________________________________________
Function play_level:ENVIRONMENT( level_reference:Object, player:COMPLEX_AGENT = Null )
	Local lev:LEVEL
	If String( level_reference ) 'level load
		lev = load_level( String( level_reference ))
	Else If LEVEL( level_reference )
		lev = LEVEL( level_reference )
	End If
	If Not player 'player override behavior
		player = get_player_vehicle( lev.player_vehicle_key )
	End If
	Local human_participation% = True
	Local env:ENVIRONMENT = Create_ENVIRONMENT( human_participation )
	Local load_start% = now()
	Local bg:TImage = generate_sand_image( lev.width, lev.height )
	Local fg:TImage = generate_level_walls_image( lev )
	DebugLog "    Level images generated in " + elapsed_str(load_start) + " sec."
	If env.bake_level( lev, bg, fg ) 'bake the level, setup the data structures
		FLAG.in_menu = False
		env.game_in_progress = True
		'player stuff
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		env.insert_player( player, player_brain )
		env.respawn_player()
		env.player_in_locker = True
		env.waiting_for_player_to_enter_arena = True
		FLAG.engine_ignition = True
		reset_mouse( player.ang )
	Else 'Not main_game.load_level()
		env = Null
	End If
	Return env
End Function

'______________________________________________________________________________
Function init_ai_menu_game( fit_to_window% = True )
	If Not SETTINGS_REGISTER.SHOW_AI_MENU_GAME Then Return
	ai_menu_game = Create_ENVIRONMENT()
	Local lev:LEVEL = load_level( level_path + "ai_menu_game" + "." + level_file_ext )
	If lev
		Local diff%
		If fit_to_window
			If SETTINGS_REGISTER.WINDOW_WIDTH.get() > lev.width
				diff = SETTINGS_REGISTER.WINDOW_WIDTH.get() - lev.width
				lev.set_divider( LINE_TYPE_VERTICAL, 4, diff/2, True )
				lev.set_divider( LINE_TYPE_VERTICAL, 15, diff/2, True )
			End If
			If SETTINGS_REGISTER.WINDOW_HEIGHT.get() > lev.height
				diff = SETTINGS_REGISTER.WINDOW_HEIGHT.get() - lev.height
				lev.set_divider( LINE_TYPE_HORIZONTAL, 3, diff/2, True )
				lev.set_divider( LINE_TYPE_HORIZONTAL, 11, diff/2, True )
			End If
		Else
			ai_menu_game.drawing_origin = Create_cVEC( SETTINGS_REGISTER.WINDOW_WIDTH.get()/2 - lev.width/2, SETTINGS_REGISTER.WINDOW_HEIGHT.get()/2 - lev.height/2 )
		End If
		Local load_start% = now()
		Local bg:TImage = generate_sand_image( lev.width, lev.height )
		Local fg:TImage = generate_level_walls_image( lev )
		DebugLog "    Level images generated in " + elapsed_str(load_start) + " sec."
		If ai_menu_game.bake_level( lev, bg, fg )
			ai_menu_game.auto_reset_spawners = True
			ai_menu_game.game_in_progress = True
			ai_menu_game.battle_in_progress = True
			ai_menu_game.battle_state_toggle_ts = now()
			ai_menu_game.spawn_enemies = True
			ai_menu_game.open_doors( POLITICAL_ALIGNMENT.FRIENDLY )
			ai_menu_game.open_doors( POLITICAL_ALIGNMENT.HOSTILE )
			
		Else
			ai_menu_game = Null
		End If
	Else
		ai_menu_game = Null
	End If
End Function

'______________________________________________________________________________
Function generate_sand_image:TImage( w%, h% )
	Local pixmap:TPixmap = CreatePixmap( w,h, PF_RGB888 )
	Local color:TColor
	Local color_cache:TColor[ 50 ]
	'pre-cache the sandy colors
	For Local i% = 0 Until color_cache.Length
		color_cache[i] = TColor.Create_by_HSL( 44 + Rnd( -10, 5 ), 0.34 + Rnd( -0.10, 0.10 ), 0.25 + Rnd( -0.025, 0.025 ), True )
	Next
	'write some random pixels
	For Local px% = 0 To w-1
		For Local py% = 0 To h-1
			color = color_cache[ Rand( 0, color_cache.Length - 1)]
			pixmap.WritePixel( px,py, encode_ARGB( 1.0, color.R,color.G,color.B ))
		Next
	Next
	AutoMidHandle( False )
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function

'______________________________________________________________________________
Function generate_level_walls_image:TImage( lev:LEVEL )
  'TODO: pad this texture with a static "crowd" image
  '      perhaps as a separate image but would be better if not
	Local pixmap:TPixmap = CreatePixmap( lev.width,lev.height, PF_RGBA8888 )
	pixmap.ClearPixels( encode_ARGB( 0.0, 0,0,0 ))
	'variables
	Const wall_size% = 5
	Local c:CELL
	Local blocking_cells:TList = lev.get_blocking_cells()
	Local wall:BOX
	Local adjacent%[,]
	Local nr%, nc%
	Local px%, py%
	Local x#, x_adj%
	Local y#, y_adj%
	Local dist%
	Local color_cache:TColor[,] = New TColor[ 3, 50 ]
	'pre-cache some colors
	For Local i% = 0 To 49 'near to wall, dist = {0, 2, 3}
		color_cache[ 0, i ] = TColor.Create_by_HSL( 0.0, 0.0, 0.42 + Rnd( -0.10, 0.10 ), True )
	Next
	For Local i% = 0 To 49 'near to wall, dist = {1, 4, 5}
		color_cache[ 1, i ] = TColor.Create_by_HSL( 0.0, 0.0, 0.28 + Rnd( -0.05, 0.05 ), True )
	Next
	For Local i% = 0 To 49 'far from wall
		color_cache[ 2, i ] = TColor.Create_by_HSL( lev.hue, lev.saturation, lev.luminosity + Rnd( -0.05, 0.05 ), True )
	Next
	Local color:TColor
	'for: each "blocking" region
	For c = EachIn blocking_cells
		wall = lev.get_wall( c )
		adjacent = New Int[ 3, 3 ]
		For nr = 0 To 2
			For nc = 0 To 2
				adjacent[ nr, nc ] = lev.path( c.add( CELL.Create( nr - 1, nc - 1 )))
			Next
		Next
		'for each pixel of the region to be rendered
		For py = wall.y To wall.y+wall.h-1
			For px = wall.x To wall.x+wall.w-1
				x = CELL.MAXIMUM_COST
				If px <= wall.x+wall_size 'left
					x = px - wall.x
					x_adj = 0
				Else If px >= wall.x+wall.w-1-wall_size 'right
					x = wall.x+wall.w-1 - px
					x_adj = 2
				End If
				y = CELL.MAXIMUM_COST
				If py <= wall.y+wall_size 'top
					y = py - wall.y
					y_adj = 0
				Else If py >= wall.y+wall.h-1-wall_size 'bottom
					y = wall.y+wall.h-1 - py
					y_adj = 2
				End If
				dist = INFINITY
				If x < CELL.MAXIMUM_COST And y = CELL.MAXIMUM_COST And adjacent[ 1, x_adj ] = PATH_PASSABLE
					'left or ride side
					dist = x
				Else If y < CELL.MAXIMUM_COST And x = CELL.MAXIMUM_COST And adjacent[ y_adj, 1 ] = PATH_PASSABLE
					'top or bottom side
					dist = y
				Else If x < CELL.MAXIMUM_COST And y < CELL.MAXIMUM_COST
					'corner space
					If adjacent[ 1, x_adj ] <> adjacent[ y_adj, 1 ]
						'treat as normal side
						If adjacent[ 1, x_adj ] = PATH_PASSABLE
							dist = x
						Else 'adjacent[ y_adj, 1 ] = PATH_PASSABLE
							dist = y
						End If
					Else 'adjacent[ 1, x_adj ] = adjacent[ y_adj, 1 ]
						If adjacent[ 1, x_adj ] = PATH_PASSABLE 'And adjacent[ y_adj, 1 ] = PATH_PASSABLE
							'convex corner
							dist = Min( x, y )
						Else If adjacent[ y_adj, x_adj ] = PATH_PASSABLE 'And adjacent[ 1, x_adj ] = PATH_BLOCKED 'And adjacent[ y_adj, 1 ] = PATH_BLOCKED
							'concave corner
							dist = Max( x, y )
						End If
					End If
				End If
				'color selector
				If dist = 0 Or dist = 2 Or dist = 3
					color = color_cache[ 0, Rand( 0, 49 )]
				Else If dist = 1 Or dist = 4 Or dist = 5
					color = color_cache[ 1, Rand( 0, 49 )]
				Else
					color = color_cache[ 2, Rand( 0, 49 )]
				End If
				'final write
				pixmap.WritePixel( px,py, encode_ARGB( 1.0, color.R,color.G,color.B ))
			Next
		Next
	Next
	AutoMidHandle( False )
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function

'______________________________________________________________________________
Function record_player_kill( cash_value% )
	If profile
		last_kill_ts = now()
		profile.kills :+ 1
		profile.cash :+ cash_value
	End If
	If game
		game.player_kills :+ 1
	End If
End Function

Function record_player_friendly_fire_kill( punishment_amount% )
	If profile
		profile.cash :- FRIENDLY_FIRE_PUNISHMENT_AMOUNT
		If profile.cash < 0 Then profile.cash = 0
	End If
End Function

Function record_level_beaten( level_path$ )
	If profile
		If profile.levels_beaten <> Null ..
		And Not contained_in( level_path, profile.levels_beaten )
			profile.levels_beaten = profile.levels_beaten[..profile.levels_beaten.Length+1]
			profile.levels_beaten[profile.levels_beaten.Length-1] = level_path
			'init_campaign_chooser()
		Else 'profile.levels_beaten == Null
			profile.levels_beaten = [ level_path ]
		End If
	End If
End Function

Function show_info( str$ )
	info = str
	info_change_ts = now()
End Function

Function reset_mouse( ang# )
	MoveMouse( SETTINGS_REGISTER.WINDOW_WIDTH.get()/2 + 30 * Cos( ang ), SETTINGS_REGISTER.WINDOW_HEIGHT.get()/2 + 30 * Sin( ang ))
End Function

Function get_player_id%()
	If game <> Null And game.player <> Null
		Return game.player.id
	Else
		Return -1
	End If
End Function

'______________________________________________________________________________
'these need to go away, kind of a hack
Const main_screen_x% = 25
Const main_screen_y% = 15

Const main_screen_menu_y% = 30

'______________________________________________________________________________
Function update_map%( map:TMap, key:Object, value:Object )
	Local changed% = (value <> map.ValueForKey( key ))
	map.Insert( key, value )
	Return changed
End Function

'______________________________________________________________________________
Function populate_menu_with_files( menu:TUIList, target_path$, filter_by_extension$ = Null, item_clicked_event_handler(item:Object), trim_display_string% = False )
	menu.remove_all_items()
	Local level_file_list:TList = find_files( level_path, level_file_ext )
	Local file_display$
	For Local file$ = EachIn level_file_list
		'file_display = file.Replace( level_path, "" ).Replace( "." + level_file_ext, "" )
		file_display = file
		menu.add_new_item( file_display, cmd_play_level, file )
	Next
End Function

