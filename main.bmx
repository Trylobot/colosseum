Rem
	Main.bmx
	This is a COLOSSEUM project BlitzMax source file.
	
	author: Tyler W Cole, aka "Tylerbot"
	email: tylerbot@gmail.com
	description: top-down tank fight
EndRem
SuperStrict

Framework brl.GLMax2D

Import brl.LinkedList
Import brl.Map
Import brl.Max2D
Import brl.Retro
Import pub.Glew
Import brl.FreeTypeFont
Import brl.FreeAudioAudio
Import brl.OGGLoader
Import brl.PNGLoader
Import brl.Random
?Win32
Import pub.Win32
Import "icon/icon.o"
?

Include "agent.bmx"
Include "ai_type.bmx"
Include "audio.bmx"
Include "base_data.bmx"
Include "box.bmx"
Include "bmp_font.bmx"
Include "cell.bmx"
Include "collide.bmx"
Include "color.bmx"
Include "complex_agent.bmx"
Include "console.bmx"
Include "constants.bmx"
Include "control_brain.bmx"
Include "core.bmx"
Include "core_menus.bmx"
Include "core_menu_commands.bmx"
Include "data.bmx"
Include "door.bmx"
Include "draw.bmx"
Include "draw_misc.bmx"
Include "emitter.bmx"
Include "entity_data.bmx"
Include "environment.bmx"
Include "flags.bmx"
Include "force.bmx"
Include "gib_system.bmx"
Include "graffiti_manager.bmx"
Include "graphics_base.bmx"
Include "hud.bmx"
Include "image_atlas_reference.bmx"
Include "image_buffer.bmx"
Include "image_manip.bmx"
Include "input.bmx"
Include "instaquit.bmx"
Include "json.bmx"
Include "level.bmx"
Include "level_editor.bmx"
Include "managed_object.bmx"
Include "misc.bmx"
Include "mouse.bmx"
Include "os-windows.bmx"
Include "particle.bmx"
Include "particle_emitter.bmx"
Include "pathing_structure.bmx"
Include "path_queue.bmx"
Include "physical_object.bmx"
Include "pickup.bmx"
Include "player_profile.bmx"
Include "point.bmx"
Include "projectile.bmx"
Include "projectile_launcher.bmx"
Include "range.bmx"
Include "settings.bmx"
Include "spawn_controller.bmx"
Include "spawn_request.bmx"
Include "steering_wheel.bmx"
Include "tank_track.bmx"
Include "timescale.bmx"
Include "transform_state.bmx"
Include "turret.bmx"
Include "turret_barrel.bmx"
Include "tween.bmx"
Include "ui_image_grid.bmx"
Include "ui_input.bmx"
Include "ui_interface.bmx"
Include "ui_list.bmx"
Include "ui_splash.bmx"
Include "unit_factory_data.bmx"
Include "update.bmx"
Include "vec.bmx"
Include "vehicle_data.bmx"
'Include "vehicle_editor.bmx"
Include "widget.bmx"
Include "debug.bmx"

Local load_start% = now()

Const version_major%    = 0
Const version_minor%    = 5
Const version_revision% = 0

Global colosseum_credits$ = ..
	"COLOSSEUM (c)2011 Tyler W.R. Cole, built with BlitzMax~n" + ..
	"Music by NickPerrin, Yoshi-1up, Fonts by John Alexander, codeman38, Yuji Oshimoto~n" + ..
	"Thanks to Kaze, SniperAceX, A.E.Mac, ZieramsFolly, Firelord88"
Global colosseum_credits_linecount% = line_count( colosseum_credits )

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
'menu_command( COMMAND.NEW_LEVEL )
cmd_new_level_editor_cache()
'autosave/load user profile
Global autosave_profile_path$ = load_autosave_profile_path()
If autosave_profile_path
	'menu_command( COMMAND.load_game, autosave_profile_path )
	cmd_load_profile( autosave_profile_path )
Else
	profile = create_new_user_profile()
	show_info( "new profile created" )
	'menu_command( COMMAND.save_game, [True] )
	cmd_save_profile()
End If

?Debug
debug_pre_load()
?

'window title
AppTitle = "Colosseum " + version_major + "." + version_minor + "." + version_revision
?Debug
AppTitle :+ " DEBUG"
?

'graphical window
init_graphics()

'////////////////////////////////
'LOAD GAME ASSETS; fonts, sounds, images, unit parts, units, props, pickups, levels
load_all_assets()
DebugLog "  All assets loaded at " + elapsed_str(load_start) + " sec. since program start-up"

'complex debug routines (modular)
?Debug
debug_pre_main()
?

DebugLog "  MAIN GAME LOOP started at " + elapsed_str(load_start) + " sec. since program start-up~n"
'////////////////////////////////////////////////////////////////////////////////
'///// main game loop
Repeat
	Cls()
	
	'auto-selects the global environment reference
	select_game()
	'user input
	get_all_input()
	'physics timescale and update throttling
	If frame_time_elapsed()
		calculate_timescale()
		reset_frame_timer()
		'collision detection and resolution
		collide_all_objects()
		'update object positions, emit particles
		update_all_objects()
	End If
	'music and sound
	play_all_audio( (Not FLAG.in_menu) And (main_game <> Null) And main_game.game_in_progress )
	'draw everything
	draw_all_graphics()

	Flip( -1 )
Until AppTerminate()

