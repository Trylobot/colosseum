Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	
	author: Tyler W Cole, aka "Tylerbot"
	email: mailto:tylerbot@gmail.com
	site: http://colosseum.devjavu.com
	
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
Global window_w%
Global window_h%
Global fullscreen%
Global bit_depth%
Global refresh_rate%

Function apply_default_settings()
	window_w = 800
	window_h = 600
	fullscreen = False
	bit_depth = 32
	refresh_rate = 60
End Function

apply_default_settings()

'external data load
create_dirs()
If Not load_settings()
	save_settings()
	load_settings()
End If
load_data_files()
MENU.load_fonts()
load_all_archetypes() 'REMOVE this function call by externalizing this data, please.
menu_command( COMMAND_NEW_LEVEL ) 'initialize the level editor's cached level

'Window Initialization and Drawing device
AppTitle = My.Application.AssemblyInfo
If My.Application.DebugOn Then AppTitle :+ " " + My.Application.Platform + " (Debug)"
SetGraphicsDriver GLMax2DDriver()

Function init_graphics()
	If Not fullscreen
		Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
	Else 'fullscreen
		Graphics( window_w, window_h, bit_depth, refresh_rate, GRAPHICS_BACKBUFFER )
	End If
	SetClsColor( 0, 0, 0 )
	SetBlend( ALPHABLEND )
	glEnable( GL_LINE_SMOOTH )
End Function

init_graphics()

'______________________________________________________________________________
'MAIN
Local before%
?Debug
Global fps%, last_frame_ts%, time_count%, frame_count%

'play_level( data_path + "debug" + "." + level_file_ext, 0 )
'menu_command( COMMAND_EDIT_LEVEL )
?
Repeat
	
	'game object
	If FLAG_in_menu
		game = ai_menu_game
	Else If FLAG_in_shop
		game = Null
	Else
		game = main_game
	End If

	get_all_input()
	
	'decouple simulation speed from draw speed
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
		debug_fps()
		'debug_agent_lists()
	End If
	If Not FLAG_in_menu And Not FLAG_in_shop
		If KeyDown( KEY_LEFT )
			debug_origin.x :- 1
		End If
		If KeyDown( KEY_RIGHT )
			debug_origin.x :+ 1
		End If
		If KeyDown( KEY_UP )
			debug_origin.y :- 1
		End If
		If KeyDown( KEY_DOWN )
			debug_origin.y :+ 1
		End If
	End If
?
	check_instaquit()
	
	If KeyHit( KEY_F12 )
		screenshot()
	End If
	
	Flip( 1 )
	
Until AppTerminate()
If AppTerminate() Then End
