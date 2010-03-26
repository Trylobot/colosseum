Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	
	author: Tyler W Cole, aka "Tylerbot"
	email: tylerbot@gmail.com
	description: top-down tank fight
EndRem
SuperStrict
Framework brl.D3D7Max2D
'Framework brl.GLMax2D
Import "settings.bmx"
Import "image_atlas.bmx"
Import "data.bmx"
Import "core.bmx"
Import "constants.bmx"
Import "graphics_base.bmx"
Import "environment.bmx"
Import "input.bmx"
Import "net.bmx"
Import "timescale.bmx"
Import "collide.bmx"
Import "update.bmx"
Import "draw.bmx"
Import "audio.bmx"
Import "instaquit.bmx"
?Debug
Include "debug.bmx"
?

Const version_major%    = 0
Const version_minor%    = 4
Const version_revision% = 0

SetGraphicsDriver D3D7Max2DDriver()
'SetGraphicsDriver GLMax2DDriver()

'defaults
apply_default_settings()
FLAG.in_menu = True

'create directories if not present
create_dirs()
'settings
If Not load_settings()
	save_settings()
End If
'level editor cache 
menu_command( COMMAND.NEW_LEVEL )
'autosave/load user profile
Global autosave_profile_path$ = load_autosave()
If autosave_profile_path
	menu_command( COMMAND.load_game, autosave_profile_path )
Else
	menu_command( COMMAND.new_game )
	menu_command( COMMAND.save_game )
End If

'window title
AppTitle = "Colosseum " + version_major + "." + version_minor + "." + version_revision
?Debug
AppTitle :+ " DEBUG"
debug_init()
debug_no_graphics()
?

'graphical window
init_graphics()
'assets
'menu_command( COMMAND_LOAD_ASSETS, INTEGER.Create( 1 ))
?Debug
DebugStop
?
menu_command( COMMAND.LOAD_ASSETS )
'background automaton-powered menu game
init_ai_menu_game() 'does nothing if applicable performance setting is disabled
init_campaign_chooser()

?Debug 'debug routines requiring graphics
debug_with_graphics()
?

?Not Debug
'////////////////////////////////////////////////////////////////////////////////
'MAIN
Repeat
	Cls()
	select_game()
	
	'menu input and misc
	get_all_input()
	'multiplayer
	update_network()
	'physics timescale and update throttling
	If frame_time_elapsed()
		calculate_timescale()
		reset_frame_timer()
		'collision detection and resolution
		collide_all_objects()
		'resolve forces and emit particles, and capture player vehicle input
		update_all_objects()
	End If
	'music and sound
	play_all_audio( (Not FLAG.in_menu) And (main_game <> Null) And main_game.game_in_progress )
	'draw everything
	draw_all_graphics()

	'insta-quit
	If esc_held And KeyDown( KEY_ESCAPE ) ..
	And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
		draw_instaquit_progress()
	End If
	'screenshot
	If KeyHit( KEY_F12 )
		screenshot()
	End If
	
	Flip( 1 )
Until AppTerminate()
'////////////////////////////////////////////////////////////////////////////////



?Debug
'////////////////////////////////////////////////////////////////////////////////
'MAIN +debug_overlay +timer_profiling
Repeat
	Cls()
	select_game()
	
	'menu input and misc
	profiler( True ) 'begin new profiling cycle
	get_all_input()
	
	'multiplayer
	profiler() 'record current accumulator and begin another
	update_network()
	
	'physics timescale and update throttling
	If frame_time_elapsed()
		calculate_timescale()
		reset_frame_timer()
		
		'collision detection and resolution
		profiler()
		collide_all_objects()
		
		'resolve forces and emit particles, and capture player vehicle input
		profiler()
		update_all_objects()
		
	End If
	
	'music and sound
	profiler()
	play_all_audio( (Not FLAG.in_menu) And (main_game <> Null) And main_game.game_in_progress )
	
	'draw everything
	profiler()
	draw_all_graphics()
	
	'end profiling
	profiler()
	
	'debug
	debug_main()
	'insta-quit
	If esc_held And KeyDown( KEY_ESCAPE ) ..
	And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
		draw_instaquit_progress()
	End If
	'screenshot
	If KeyHit( KEY_F12 )
		screenshot()
	End If
	
	Flip( 1 )
Until AppTerminate()
'////////////////////////////////////////////////////////////////////////////////
?

