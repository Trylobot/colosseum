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
'multiplayer
Global playing_multiplayer% = False

'app state flags
'Global FLAG_in_menu% = True
Global FLAG_draw_help% = False
Global FLAG_console% = False

'environmental objects
Global main_game:ENVIRONMENT 'game in which player participates
Global ai_menu_game:ENVIRONMENT 'menu ai demo environment
'current environment reference
Global game:ENVIRONMENT 'current game environment

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

'______________________________________________________________________________
Function play_level( level_reference:Object, player:COMPLEX_AGENT )
	If Not level_reference
		DebugStop
	End If
	If Not player
		DebugStop
	End If
	main_game = Create_ENVIRONMENT( True )
	Local lev:LEVEL
	If String( level_reference )
		lev = load_level( String( level_reference ))
	Else If LEVEL( level_reference )
		lev = LEVEL( level_reference )
	End If
	Local bg:TImage = generate_sand_image( lev.width, lev.height )
	Local fg:TImage = generate_level_walls_image( lev )
	
	If main_game.bake_level( lev, bg, fg )
		main_game.game_in_progress = True
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		main_game.insert_player( player, player_brain )
		main_game.respawn_player()
		FLAG.in_menu = False
		main_game.player_in_locker = True
		main_game.waiting_for_player_to_enter_arena = True
		FLAG.engine_ignition = True
		reset_mouse( player.ang )
		
	Else 'Not main_game.load_level()
		main_game = Null
	End If
End Function

'______________________________________________________________________________
Function init_ai_menu_game( fit_to_window% = True )
	If Not show_ai_menu_game Then Return
	ai_menu_game = Create_ENVIRONMENT()
	Local lev:LEVEL = load_level( level_path + "menu/" + "ai_menu_game" + "." + level_file_ext )
	If lev
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
		Local bg:TImage = generate_sand_image( lev.width, lev.height )
		Local fg:TImage = generate_level_walls_image( lev )
		
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
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function

'______________________________________________________________________________
Function generate_level_walls_image:TImage( lev:LEVEL )
  'TODO: pad this texture with a static "crowd" image
  '      perhaps as a separate image but would be better if not
	Const wall_size% = 5
	Local pixmap:TPixmap = CreatePixmap( lev.width,lev.height, PF_RGBA8888 )
	pixmap.ClearPixels( encode_ARGB( 0.0, 0,0,0 ))
	'variables
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
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function

'______________________________________________________________________________
Function generate_level_mini_preview:TImage( lev:LEVEL )
	Local pixmap:TPixmap = CreatePixmap( lev.width, lev.height, PF_I8 )'PF_RGBA8888 )
	pixmap.ClearPixels( encode_ARGB( 1.0, 64,64,64 ))
	For Local w:BOX = EachIn lev.get_walls()
		pixmap.Window( w.x, w.y, w.w, w.h ).ClearPixels( encode_ARGB( 1.0, 127,127,127 ))
	Next
	Return LoadImage( pixmap, FILTEREDIMAGE )
End Function

'______________________________________________________________________________
Function init_campaign_chooser()
	'prepare data for campaign chooser
	Local image:TImage[][]
	If campaign_chooser
		image = campaign_chooser.image
	Else
		image = New TImage[][campaign_ordering.Length]
	End If
	Local image_label$[][] = New String[][campaign_ordering.Length]
	Local group_label$[] = New String[campaign_ordering.Length]
	Local lock%[][] = New Int[][campaign_ordering.Length]
	Local callback( selected:CELL ) = campaign_chooser_callback
	
	For Local c% = 0 Until campaign_ordering.Length
		Local cpd:CAMPAIGN_DATA = get_campaign_data( campaign_ordering[c] )
		If cpd
			image[c] = New TImage[cpd.levels.Length]
			image_label[c] = New String[cpd.levels.Length]
			group_label[c] = cpd.name
			lock[c] = New Int[cpd.levels.Length]
			For Local L% = 0 Until cpd.levels.Length
				Local lev_path$ = cpd.levels[L]
				Local lev_preview_path$ = level_preview_path_from_level_path( lev_path )
        If FileExists( lev_preview_path ) And FileTime( lev_path ) <= FileTime( lev_preview_path )
          image[c][L] = LoadImage( lev_preview_path, FILTEREDIMAGE )
        Else 'preview does not exist, or level file is newer than its preview (needs to be generated from scratch)
          Local lev:LEVEL = load_level( lev_path )
          If lev
            DeleteFile( lev_preview_path )
            image[c][L] = generate_level_mini_preview( lev )
            SavePixmapPNG( image[c][L].pixmaps[0], lev_preview_path, 5 )
          Else
            DebugLog( " ERROR: level file not found ~q" + lev_path + "~q" )
            DebugStop
          End If
        End If
        image_label[c][L] = "" 'lev.name
        lock[c][L] = Not contained_in( lev_path, profile.levels_beaten )
			Next
		End If
	Next
	'begin updating & drawing the campaign chooser until it calls the given callback
	campaign_chooser = Create_IMAGE_CHOOSER( image, image_label, group_label, lock, callback )
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
			init_campaign_chooser()
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
	MoveMouse( window_w/2 + 30 * Cos( ang ), window_h/2 + 30 * Sin( ang ))
End Function

Function get_player_id%()
	If game <> Null And game.player <> Null
		Return game.player.id
	Else
		Return -1
	End If
End Function

Function bake_item:Object( item:INVENTORY_DATA )
	If item
		Select item.item_type
			Case "player_vehicle"
				Return get_player_vehicle( item.key )
			Case "unit"
				Return get_unit( item.key )
			Case "turret"
				Return get_turret( item.key )
		End Select
	End If
	Return Null
End Function



