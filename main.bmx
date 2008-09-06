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

'Window / Arena size
Const stats_panel_w% = 250
Const window_w% = 1024
Const window_h% = 768

'these are here to make the old code work
Const arena_offset% = 50
Const arena_w% = 500
Const arena_h% = 500


'external data load
load_data_files()
	load_all_archetypes() 'this will be in data files, eventually
	'load_environment() 'same here; this will be externalized with LEVEL objects

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
If My.Application.DebugOn Then AppTitle :+ " " + My.Application.Platform + " (Debug)"
SetGraphicsDriver GLMax2DDriver()

'GRAPHICS_BACKBUFFER|GRAPHICS_ALPHABUFFER|GRAPHICS_DEPTHBUFFER|GRAPHICS_STENCILBUFFER|GRAPHICS_ACCUMBUFFER )
Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
'Graphics( 1024, 768, 32, 85, GRAPHICS_BACKBUFFER )
SetClsColor( 0, 0, 0 )
SetBlend( ALPHABLEND )

?Debug
'debug_load_data()
Global last_frame_ts%, time_count%, frame_count%, fps%
'menu_command( COMMAND_EDIT_LEVEL )
'menu_command( COMMAND_NEW_GAME, PLAYER_INDEX_LIGHT_TANK )
game = Create_ENVIRONMENT()
Cls
DrawText( "loading", window_w/2, window_h/2 )
Flip
Local lev:LEVEL = Create_LEVEL_from_json( TJSON.Create( LoadString( "data/test.colosseum_level" )))
Local bg:TImage = generate_sand_image( lev.width, lev.height )
Local fg:TImage = generate_level_walls_image( lev )
Repeat
	Cls
	DrawImage( bg, 0,0 )
	DrawImage( fg, 0,0 )
	Flip
Until KeyHit( KEY_ESCAPE )
?

'______________________________________________________________________________
'MAIN
Local before%
Repeat
	
	If (now() - before) > (1000/60) ' = 60 hertz
		before = now()
		get_all_input()
		'collide_all()
		update_all()
	EndIf
	
	Cls
	draw_all()
	play_all()

?Debug
frame_count :+ 1
time_count :+ (now() - last_frame_ts)
last_frame_ts = now()
If time_count >= 1000
	fps = frame_count
	frame_count = 0
	time_count = 0
End If
'If game.player <> Null Then debug_overlay()
'If KeyHit( KEY_F4 ) And FLAG_game_in_progress
'	find_path( player.pos_x,player.pos_y, mouse_point.x,mouse_point.y )
'End If
?
	check_esc_held()
	
	If KeyHit( KEY_F12 )
		screenshot()
	End If
	
	Flip( 1 )
	
Until AppTerminate()
If AppTerminate() Then End
