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
SuperStrict
Framework brl.GLMax2D
'Framework brl.GLGraphics
'Framework brl.D3D7Max2D
?Win32
Import "win32.bmx"
?
Import brl.FreeTypeFont
Import brl.FreeAudioAudio
Import brl.OGGLoader
Import brl.PNGLoader
Import brl.Random
Import brl.Map
Import vertex.bnetex

Const version_major%    = 0
Const version_minor%    = 4
Const version_revision% = 0

Include "misc.bmx"
Include "json.bmx"
Include "inventory_data.bmx"
Include "vehicle_data.bmx"
Include "progress_data.bmx"
Include "compatibility_data.bmx"
Include "player_profile.bmx"
Include "data.bmx"
Include "managed_object.bmx"
Include "point.bmx"
Include "box.bmx"
Include "vec.bmx"
Include "range.bmx"
Include "cell.bmx"
Include "color.bmx"
Include "particle.bmx"
Include "pickup.bmx"
Include "transform_state.bmx"
Include "widget.bmx"
Include "force.bmx"
Include "physical_object.bmx"
Include "audio.bmx"
Include "emitter.bmx"
Include "agent.bmx"
Include "projectile.bmx"
Include "turret_barrel.bmx"
Include "turret.bmx"
Include "complex_agent.bmx"
Include "vehicle_editor.bmx"
Include "ai_type.bmx"
Include "control_brain.bmx"
Include "spawner.bmx"
Include "prop_data.bmx"
Include "level.bmx"
Include "level_editor.bmx"
Include "path_queue.bmx"
Include "pathing_structure.bmx"
Include "door.bmx"
Include "environment.bmx"
Include "update.bmx"
Include "draw.bmx"
Include "collide.bmx"
Include "console.bmx"
Include "input.bmx"
Include "menu_option.bmx"
Include "menu.bmx"
Include "net.bmx"
Include "graffiti_manager.bmx"
Include "debug.bmx"
Include "core.bmx"

'Graphics
Global window_w%
Global window_h%
Global window:BOX 'I don't like having both this and the (_w,_h) constants
Global fullscreen%
Global bit_depth%
Global refresh_rate%
Global show_ai_menu_game%
Global retain_particles%
Global active_particle_limit%

Function apply_default_settings()
	window_w = 640
	window_h = 480
	window = Create_BOX( 0, 0, window_w, window_h )
	fullscreen = False
	bit_depth = 32
	refresh_rate = 60
	show_ai_menu_game = True
	retain_particles = True
	active_particle_limit = 500
	
	network_ip_address = "127.0.0.1"
	network_port = 6112
End Function
'defaults
apply_default_settings()

'data directory enforce
create_dirs()
'settings
If Not load_settings()
	save_settings()
End If
'level editor cache 
menu_command( COMMAND.NEW_LEVEL )
'autosave/load user profile
Global autosave_profile_path$ = load_autosave()
menu_command( COMMAND.LOAD_GAME, autosave_profile_path )
?Debug
debug_init()
?

'Window Initialization and Drawing device
AppTitle = "Colosseum " + version_major + "." + version_minor + "." + version_revision
?Debug
AppTitle :+ " DEBUG"
?
SetGraphicsDriver GLMax2DDriver()
'SetGraphicsDriver GLGraphicsDriver()
'SetGraphicsDriver D3D7Max2DDriver() 

'process_command_line_arguments()

Function init_graphics()
	If Not fullscreen
		Graphics( window_w, window_h,,, GRAPHICS_BACKBUFFER )
	Else 'fullscreen
		Graphics( window_w, window_h, bit_depth, refresh_rate, GRAPHICS_BACKBUFFER )
	End If
	SetClsColor( 0, 0, 0 )
	Cls()
  SetBlend( ALPHABLEND )
	?Win32
	set_window( WS_MINIMIZEBOX )
	?
End Function

'graphical window
init_graphics()
'assets
'menu_command( COMMAND_LOAD_ASSETS, INTEGER.Create( 1 ))
menu_command( COMMAND.LOAD_ASSETS )
'background automaton-powered menu game
init_ai_menu_game() 'does nothing if applicable performance setting is disabled

?Debug
'debug_generate_level_mini_preview()
'debug_widget()
'debug_spawner()
'debug_dirtyrects()
'debug_doors()
'debug_kill_tally()
'menu_command( COMMAND_EDIT_VEHICLE )
'menu_command( COMMAND_EDIT_LEVEL )
'menu_command( COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CHOOSE_RESOLUTION) )
'Repeat
'	DebugLog " ~q" + CONSOLE.get_input( "",, window_w/4, window_h/2, get_font( "consolas_bold_24" )) + "~q"
'Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
'menu_command( COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_LEVEL) )
?

'______________________________________________________________________________
'main game loop
Repeat
	'game object to use for this frame
	If FLAG.in_menu
		If main_game = Null
			game = ai_menu_game 'initial condition; show autonomous game
		Else 'main_game <> Null
			game = main_game 'paused after beginning game
		End If
	Else 'Not FLAG_in_menu
		game = main_game 'normal play
	End If
	'input
	get_all_input() 'excludes player-agent input
	'network
	update_network()
	'timing & physics
	If frame_time_elapsed()
		'next timescale calculate and reset
		calculate_timescale()
		reset_frame_timer()
		'collision detection & resolution
		collide_all_objects()
		'physics engine and control brain update (includes player-agent input)
		update_all_objects()
	End If
	'clear graphics buffer
	Cls()
	'draw to buffer
	draw_all_graphics()
	?Debug
	debug_main()
	?
	'show buffer
	Flip( 1 )
	'audio
	last_known_player_speed = Sqr( Pow(game.player.vel_x,2) + Pow(game.player.vel_y,2) )
	play_all_audio()
Until AppTerminate()

'______________________________________________________________________________
Rem
Function process_command_line_arguments()
	If AppArgs.Length >= 2
		For Local arg$ = EachIn AppArgs[1..]
			Select arg.ToLower()
				Case "-host"
					network_host = True
					AppTitle :+ " [NETWORK HOST]"
			End Select
		Next
	End If
End Function
End Rem

