Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Input
Global mouse:POINT = Create_POINT( MouseX(), MouseY() )
Global mouse_delta:cVEC = New cVEC
Global mouse_last_z% = 0

Function get_all_input()
	
	'mouse update
	mouse_delta.x = MouseX() - mouse.pos_x
	mouse_delta.y = MouseY() - mouse.pos_y
	mouse.pos_x = MouseX()
	mouse.pos_y = MouseY()
	If Not FLAG_in_menu And game <> Null And game.human_participation And game.player_brain <> Null And profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
		HideMouse()
	Else
		ShowMouse()
	End If
	If Not MouseDown( 1 )
		FLAG_ignore_mouse_1 = False
	End If
	
	'navigate menu and select option
	If FLAG_in_menu
		Local m:MENU = get_current_menu()
		'text input controls comes before anything else
		If m.menu_type = MENU.TEXT_INPUT_DIALOG
			If KeyHit( KEY_ENTER )
				m.execute_current_option()
			End If
			m.input_box = m.input_listener.update( m.input_box )
			m.update()
		End If
		'menu navigation controls
		If KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_BACKSPACE ) ..
		And (current_menu > 0 And get_current_menu().menu_id <> MENU_ID_PAUSED)
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		End If
		If KeyHit( KEY_DOWN ) Or MouseZ() < mouse_last_z
			m.increment_focus()
		Else If KeyHit( KEY_UP ) Or MouseZ() > mouse_last_z
			m.decrement_focus()
		End If
		If KeyHit( KEY_ENTER )
			m.execute_current_option()
		End If
		'mouseover of menu items
		'Local target_valid% = m.select_by_coords( mouse.x, mouse.y )
		'If MouseHit( 1 ) And target_valid
		m.select_by_coords( mouse.pos_x, mouse.pos_y )
		If MouseHit( 1 ) And get_current_menu().menu_type <> MENU.TEXT_INPUT_DIALOG
			m.execute_current_option()
		End If
	Else 'Not FLAG_in_menu And Not FLAG_in_shop
		'pause game
		If game <> Null And game.human_participation
			'pressed (and released) ESCAPE
			If escape_key_release() 'KeyHit( KEY_ESCAPE )
				If Not game.game_over
					If Not FLAG_in_menu
						FLAG_in_menu = True
						If game.game_in_progress
							menu_command( COMMAND_PAUSE )
						End If
					End If
				Else 'game.game_over
					menu_command( COMMAND_QUIT_LEVEL )
				End If
				'clear unused keystrokes
				FlushKeys()
			End If
		End If
		'help
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
	End If
	
	'win/kill_tally
	If game And game.human_participation
		If Not game.game_in_progress And KeyHit( KEY_R )
			game.player_engine_running = False
			tweak_engine_idle()
			If Not game.game_over
				kill_tally( "LEVEL COMPLETE!", screencap() )
			End If
			menu_command( COMMAND_QUIT_LEVEL )
		End If
	End If
	
	mouse_last_z = MouseZ()
	
	'music enable/disable
	If KeyHit( KEY_M ) Then FLAG_bg_music_on = Not FLAG_bg_music_on
	
	'insta-quit
	escape_key_update()
	
	'screenshot
	If KeyHit( KEY_F12 )
		screenshot()
	End If

End Function

'______________________________________________________________________________
'Instaquit: quit instantly from anywhere, just hold ESC for a few seconds
Global esc_held% = False
Global esc_press_ts% = now()
Global esc_held_progress_bar_show_time_required% = 200
Global instaquit_time_required% = 1000

Function escape_key_release%()
	Return (Not KeyDown( KEY_ESCAPE ) And esc_held)
End Function

Function escape_key_update()
	'instaquit
	If esc_held And (now() - esc_press_ts) >= instaquit_time_required
		menu_command( COMMAND_QUIT_GAME )
	End If
	'escape key state
	If KeyDown( KEY_ESCAPE )
		If Not esc_held
			esc_press_ts = now()
		End If
		esc_held = True
	Else
		esc_held = False
	End If
End Function


'______________________________________________________________________________
Local scrollbar_positions%[]

Function scrollbar_control()
	If get_current_menu().hovering_on_scrollbar( mouse.pos_x, mouse.pos_y )
		If MouseDown( 1 )
			get_current_menu().increment_focus()
		End If
	End If
End Function


