Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	
	author: Tyler W Cole, aka "Tylerbot"
	email: mailto:tylerbot@gmail.com
	site: http://colosseum.devjav.com
	
	-- project description --
	This is a retro-style video game with a few modern elements, in the genre of Asteroids.
	You play a hero driving a tank, fighting for your life in a futuristic Colosseum setting.
	Enemy robots come at you in waves, which you must destroy before advancing.
	Between levels, you may visit the shop for repairs and to buy new items with cash gained from kills.
	After making it past the initial few levels, you unlock "Veteran" difficulty, which allows you to play difficult randomly-generated levels and to unlock for purchase the most prestigious and powerful of the shop items.
	Because of the persistent elements, you may save and load your progress to/from files on disk; these files are not encrypted.

EndRem

?Debug
Global FLAG_debug_overlay% = False
'debug_format_number()
?

'Window / Arena size
Global window_w% = 1024
Global window_w_half% = window_w/2
Global window_h% = 768
Global window_h_half% = window_h/2
Global fullscreen% = False

'these are here to make the old code work (before levels were data-driven)
'Const arena_offset% = 50
'Const arena_w% = 500
'Const arena_h% = 500

'external data load
load_data_files()
load_all_archetypes() 'this will be in data files, eventually

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
If My.Application.DebugOn Then AppTitle :+ " " + My.Application.Platform + " (Debug)"
SetGraphicsDriver GLMax2DDriver()
If Not fullscreen
	Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
Else 'fullscreen
	Graphics( window_w, window_h, 32, 85, GRAPHICS_BACKBUFFER )
End If
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

'______________________________________________________________________________
'MAIN
Local before%
?Debug
	Global last_frame_ts%, time_count%, frame_count%, fps%
	profile.archetype = PLAYER_INDEX_LIGHT_TANK
	next_level = "data/test.colosseum_level"
	menu_command( COMMAND_NEW_GAME )
	'debug_draw_walls()
	'debug_load_data()
	'menu_command( COMMAND_EDIT_LEVEL )
	'menu_command( COMMAND_NEW_GAME, PLAYER_INDEX_LIGHT_TANK )
	'Cls
	'DrawText( "loading", window_w/2, window_h/2 )
	'Flip
	'Local lev:LEVEL = Create_LEVEL_from_json( TJSON.Create( LoadString( "data/test.colosseum_level" )))
	'Local bg:TImage = generate_sand_image( lev.width, lev.height )
	'Local fg:TImage = generate_level_walls_image( lev )
	'Repeat
	'	Cls
	'	DrawImage( bg, 0,0 )
	'	DrawImage( fg, 0,0 )
	'	Flip
	'Until KeyHit( KEY_ESCAPE )
?
Repeat
	
	get_all_input()
	
	'game object
	If FLAG_in_menu
		game = ai_menu_game
	Else
		game = main_game
	End If

	'physics update speed throttle
	If (now() - before) > (1000/60) ' = 60 hertz
		before = now()
		
		collide_all_objects()
		update_all_objects()
		
	EndIf
	
	Cls
	
	draw_all_graphics()
	play_all_audio()

?Debug
		frame_count :+ 1
		time_count :+ (now() - last_frame_ts)
		last_frame_ts = now()
		If time_count >= 1000
			fps = frame_count
			frame_count = 0
			time_count = 0
		End If
		If KeyHit( KEY_TILDE )
			FLAG_debug_overlay = Not FLAG_debug_overlay
		End If
		If game <> Null And game.player <> Null And FLAG_debug_overlay And Not FLAG_in_menu
			debug_overlay()
			'debug_coordinate_overlay()
		End If
?
	check_esc_held()
	
	If KeyHit( KEY_F12 )
		screenshot()
	End If
	
	Flip( 1 )
	
Until AppTerminate()
If AppTerminate() Then End
