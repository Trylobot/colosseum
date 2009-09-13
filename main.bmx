Rem
	main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	
	author: Tyler W Cole, aka "Tylerbot"
	email: mailto:tylerbot@gmail.com
	site: none
	description: retro overhead tank warfare
EndRem
SuperStrict
Framework brl.GLMax2D
Import "settings.bmx"
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
?Debug
Include "debug.bmx"
?
'////////////////////////////
'application versioning
Const version_major%    = 0
Const version_minor%    = 4
Const version_revision% = 0
'////////////////////////////
SetGraphicsDriver GLMax2DDriver()
SetAudioDriver( "FreeAudio DirectSound" )

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

'window title
AppTitle = "Colosseum " + version_major + "." + version_minor + "." + version_revision
?Debug
AppTitle :+ " DEBUG"; debug_init(); debug_no_graphics()
?

'graphical window
init_graphics()
'assets
'menu_command( COMMAND_LOAD_ASSETS, INTEGER.Create( 1 ))
menu_command( COMMAND.LOAD_ASSETS )
'background automaton-powered menu game
init_ai_menu_game() 'does nothing if applicable performance setting is disabled

?Debug 'debug routines requiring graphics
debug_with_graphics()
?

FLAG.in_menu = True
'////////////////////////////////////////////////////////////////////////////////
'MAIN
Repeat
	Cls()
	select_game()
	get_all_input()
	update_network()
	If frame_time_elapsed()
		calculate_timescale()
		reset_frame_timer()
		
		collide_all_objects()
		update_all_objects()
	End If
	play_all_audio()
	draw_all_graphics()
	?Debug
	debug_main()
	?
	Flip( 1 )
Until AppTerminate()
'////////////////////////////////////////////////////////////////////////////////

