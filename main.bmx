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
	After making it past the initial few levels, you unlock Veteran difficulty. This allows you to play larger randomly-generated levels and unlocks the most powerful items.
	Because of the persistent elements, you may save and load your progress to/from files on disk; these files are not encoded or encrypted.

EndRem

?Debug
Global FLAG_debug_overlay% = False
'debug_format_number()
?

'Window / Arena size
Global window_w% = 640
Global window_h% = 480
Global fullscreen% = False
Global bit_depth% = 32
Global refresh_rate% = 60

'external data load
If Not load_settings()
	save_settings()
	load_settings()
End If
load_data_files()
load_all_archetypes() 'this will be in data files, eventually

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
If My.Application.DebugOn Then AppTitle :+ " " + My.Application.Platform + " (Debug)"
SetGraphicsDriver GLMax2DDriver()
If Not fullscreen
	Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
Else 'fullscreen
	Graphics( window_w, window_h, bit_depth, refresh_rate, GRAPHICS_BACKBUFFER )
End If
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )
glEnable( GL_LINE_SMOOTH )

'______________________________________________________________________________
'MAIN
Local before%
?Debug
Global last_frame_ts%, time_count%, frame_count%, fps%

profile.archetype = PLAYER_INDEX_MEDIUM_TANK
next_level = "data/debug.colosseum_level"
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
