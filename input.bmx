Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Keyboard Input
Function get_all_input()
	
	'mouse
	mouse_point.pos_x = MouseX()
	mouse_point.pos_y = MouseY()
	If player <> Null And player.turrets.Length > 0 And player.turrets[0] <> Null
		mouse_point.ang = mouse_point.ang_to( player.turrets[0] )
	End If
	
	If player_brain <> Null And player_brain.input_type = INPUT_KEYBOARD_MOUSE_HYBRID
		HideMouse()
	Else
		ShowMouse()
	End If
	
	'music enable/disable
	If KeyHit( KEY_M ) Then FLAG_bg_music_on = Not FLAG_bg_music_on
	
	'show menu
	If KeyHit( KEY_ESCAPE )
		If Not FLAG_in_menu
			FLAG_in_menu = True
			If FLAG_game_in_progress
				menu_enabled[ MENU_RESUME ] = True
				menu_option = MENU_RESUME
				FLAG_player_engine_running = False
				menu_enabled[MENU_NEW] = True
				menu_enabled[5] = False
				menu_enabled[6] = False
				menu_enabled[7] = False
				'clear keystate listeners
				KeyHit( KEY_DOWN )
				KeyHit( KEY_UP )
			End If
		Else If FLAG_game_in_progress 'And FLAG_in_menu
			menu_command( MENU_RESUME )
			FLAG_player_engine_running = True
		End If
	End If
	
	'navigate menu and select option
	If FLAG_in_menu
		If KeyHit( KEY_DOWN )
			next_enabled_menu_option()
		Else If KeyHit( KEY_UP )
			prev_enabled_menu_option()
		End If
		If KeyHit( KEY_ENTER )
			menu_command( menu_option )
		End If
		
	'show in-game help
	Else
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
		
	End If
	
	If Not FLAG_battle_in_progress And FLAG_waiting_for_player_to_exit_arena And KeyDown( KEY_R )
		player.pos_x = player_spawn_point.pos_x
		player.pos_y = player_spawn_point.pos_y
		player.ang = player_spawn_point.ang
		player.snap_turrets()
	End If
	
End Function

