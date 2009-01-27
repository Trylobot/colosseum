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

'Multiplayer
Const NETWORK_MODE_SERVER% = 1
Const NETWORK_MODE_CLIENT% = 2
Const network_mode% = NETWORK_MODE_CLIENT
Global ip_address$
Global ip_port%
'Graphics
Global window_w%
Global window_h%
	Global window:BOX
Global fullscreen%
Global bit_depth%
Global refresh_rate%
Global autosave_profile_path$
Global retain_particles%
Global active_particle_limit%

Function apply_default_settings()
	window_w = 640
	window_h = 480
		window = Create_BOX( 0, 0, window_w, window_h )
	fullscreen = False
	bit_depth = 32
	refresh_rate = 60
	retain_particles = True
	active_particle_limit = 500
	ip_address = "127.0.0.1"
	ip_port = 6112
End Function
apply_default_settings()

'external data load
create_dirs()
If Not load_settings()
	save_settings()
End If
load_assets()
MENU.load_fonts()
load_all_archetypes() 'REMOVE this function call by externalizing this data, please.
menu_command( COMMAND_NEW_LEVEL ) 'initialize the level editor data
'autosave profile auto-load on startup
autosave_profile_path = load_autosave()
menu_command( COMMAND_LOAD_GAME, autosave_profile_path )

?Debug
'debug_init()
?

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
	glEnable( GL_BLEND )
	glEnable( GL_LINE_SMOOTH )
	glEnable( GL_POINT_SMOOTH )
	glEnable( GL_POLYGON_SMOOTH )
End Function

init_graphics()

?Debug
'debug_widget()
'debug_spawner()
'debug_dirtyrects()
'debug_doors()
?

'______________________________________________________________________________
'MAIN
Const time_per_frame_min% = 1000 / 60
Local before%
init_ai_menu_game()
info_change_ts = now()

Repeat
	
	'game object to use for this frame
	If FLAG_in_menu Or FLAG_in_shop
		If main_game <> Null
			game = main_game
		Else
			game = ai_menu_game
		End If
	Else
		game = main_game
	End If
	
	'input
	get_all_input()
	
	'simulation speed, never faster than 60 hertz
	If (now() - before) > time_per_frame_min
		before = now()
		
		'collision detection & resolution
		collide_all_objects()
		'physics engine update
		update_all_objects()
		
	EndIf
	
	'clear buffer
	Cls()
	
	'draw to buffer
	draw_all_graphics()
	?Debug
	debug_main()
	?
	
	'show buffer
	Flip( 1 )
	
	'audio
	play_all_audio()
	
Until AppTerminate()

