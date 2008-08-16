Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Keyboard Input
Function get_all_input()
	
	'mouse
	mouse_point.x = MouseX()
	mouse_point.y = MouseY()
	
	If player_brain <> Null And player_brain.input_type = INPUT_KEYBOARD_MOUSE_HYBRID
		HideMouse()
	Else
		ShowMouse()
	End If
	
	'music enable/disable
	If KeyHit( KEY_M ) Then FLAG_bg_music_on = Not FLAG_bg_music_on
	
	'navigate menu and select option
	If FLAG_in_menu
		If KeyHit( KEY_DOWN ) Or KeyHit( KEY_RIGHT )
			get_current_menu().increment_focus()
		Else If KeyHit( KEY_UP ) Or KeyHit( KEY_LEFT )
			get_current_menu().decrement_focus()
		End If
		If KeyHit( KEY_ENTER )
			Local opt:MENU_OPTION = get_current_menu().get_focus()
			menu_command( opt.command_code, opt.command_argument )
		End If
	Else 'show in-game help
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
	End If
	
	If KeyHit( KEY_ESCAPE ) 'show menu
		If Not FLAG_in_menu
			FLAG_in_menu = True
			If FLAG_game_in_progress
				get_menu( MENU_ID_MAIN_MENU ).set_enabled( "resume", True )
				get_menu( MENU_ID_MAIN_MENU ).set_focus( "resume" )
				FLAG_player_engine_running = False
				'clear keystate listeners
				KeyHit( KEY_DOWN )
				KeyHit( KEY_RIGHT )
				KeyHit( KEY_UP )
				KeyHit( KEY_LEFT )
			Else	
				'this could not have happened with the current game logic
			End If
		Else 'FLAG_in_menu
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		End If
	End If
	
	If Not FLAG_battle_in_progress And FLAG_waiting_for_player_to_exit_arena And KeyDown( KEY_R )
		player.pos_x = player_spawn_point.pos_x
		player.pos_y = player_spawn_point.pos_y
		player.ang = player_spawn_point.ang
		player.snap_turrets()
	End If
	
End Function

