Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Input
Global mouse_last_z% = 0
Function get_all_input()
	
	'mouse update
	mouse_delta.x = MouseX() - mouse.x
	mouse_delta.y = MouseY() - mouse.y
	mouse.x = MouseX()
	mouse.y = MouseY()
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
		m.select_by_coords( mouse.x, mouse.y )
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
Type CONSOLE
	'Field cursor_index%
	
	Method update$( str$, max_size% = INFINITY, reset_cursor% = False )
		'cursor reset (why is this even necessary?!)
		'If reset_cursor Then cursor_index = str.Length
		'arrow keys + backspace/delete
		'If KeyHit( KEY_LEFT ) 'move cursor left
		'	cursor_index :- 1
		'	If cursor_index < 0 Then cursor_index = 0
		'Else If KeyHit( KEY_RIGHT ) 'move cursor right
		'	cursor_index :+ 1
		'	If cursor_index > str.Length-1 Then cursor_index = str.Length-1
		'End If
		If KeyHit( KEY_BACKSPACE ) '.. 'erase character left of cursor and move cursor left
			str = str[..(str.Length-1)]
		'Else If KeyHit( KEY_DELETE ) '.. 'erase character right of cursor
		End If
		'normal input
		If max_size = INFINITY Or str.Length < max_size
			Local char$ = get_char()
			If char <> ""
				str :+ char
				'cursor_index :+ 1
			End If
		End If

		Return str
	End Method
	

	Global chars_Ucase$[] = [ ..
		")", "!", "@", "#", "$", "%", "^", "&", "*", "(", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", ..
		"~~", "_", "+", "{", "}", "|", ".", "+", "-", "*", "/", ":", "~q", "<", ">", "?", " " ]
		
	Global chars_Lcase$[] = [ ..
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", ..
		"`",  "-", "=", "[", "]", "\", ".", "+", "-", "*", "/", ";", "'",  ",", ".", "/", " " ]
		
	Global keys%[] = [ ..
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_NUM0, KEY_NUM1, KEY_NUM2, KEY_NUM3, KEY_NUM4, KEY_NUM5, KEY_NUM6, KEY_NUM7, KEY_NUM8, KEY_NUM9, ..
		KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, ..
		KEY_TILDE, KEY_MINUS, KEY_EQUALS, KEY_OPENBRACKET, KEY_CLOSEBRACKET, KEY_BACKSLASH, KEY_NUMDECIMAL, KEY_NUMADD, KEY_NUMSUBTRACT, KEY_NUMMULTIPLY, KEY_NUMDIVIDE, KEY_SEMICOLON, KEY_QUOTES, KEY_COMMA, KEY_PERIOD, KEY_SLASH, KEY_SPACE ]
	
	Method get_char$() 'returns "" if none, or a string representing the character of the key pressed
		Local upper_case% = False
		If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT ) Then upper_case = True
		
		For Local index% = 0 To keys.Length-1
			If KeyHit( keys[index] )
				If upper_case
					Return chars_Ucase[index]
				Else
					Return chars_Lcase[index]
				End If
			End If
		Next
		Return "" 'nothing
	End Method

End Type

'______________________________________________________________________________
Local scrollbar_positions%[]

Function scrollbar_control()
	If get_current_menu().hovering_on_scrollbar( mouse.x, mouse.y )
		If MouseDown( 1 )
			get_current_menu().increment_focus()
		End If
	End If
End Function


