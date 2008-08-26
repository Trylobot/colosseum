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
	
	If game.player_brain <> Null And player_input_type = INPUT_KEYBOARD_MOUSE_HYBRID ..
	And Not FLAG_in_menu
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
				menu_command( COMMAND_BACK_TO_MAIN_MENU )
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
		game.player.pos_x = game.player_spawn_point.pos_x
		game.player.pos_y = game.player_spawn_point.pos_y
		game.player.ang = game.player_spawn_point.ang
		game.player.snap_all_turrets()
	End If
	
End Function
'______________________________________________________________________________
'Text handler
Const key_press_time% = 1000
Const key_repeat_delay% = 100
Const cursor_blink% = 500

Type CONSOLE
	Field cursor_index%
	Field last_char$
	Field key_press_ts%
	Field repeat_ts%
	
	Method update$( str$, max_size% )
		If str.Length < max_size
			Local this_char$ = GetChar_normal()
			If this_char <> "" And this_char <> last_char
				key_press_ts = now()
				last_char = this_char
				str :+ this_char
				cursor_index :+ 1
			Else If this_char <> "" 'this_char = last_char
				If (now() - key_press_ts) >= key_press_time 'big delay is done
					If (now() - repeat_ts) >= key_repeat_delay 'small delay is done
						repeat_ts = now()
						str :+ this_char
						cursor_index :+ 1
					End If
				Else 'big delay is not done
					repeat_ts = now()
				End If
			Else
				last_char = ""
			End If
		End If
		
		If KeyHit( KEY_LEFT ) 'move cursor left
			cursor_index :- 1
			If cursor_index < 0 Then cursor_index = 0
		Else If KeyHit( KEY_RIGHT ) 'move cursor right
			cursor_index :+ 1
			If cursor_index > str.Length-1 Then cursor_index = str.Length-1
		End If
		If KeyHit( KEY_BACKSPACE ) '.. 'erase character left of cursor and move cursor left
		'And cursor_index > 0
			'this should use the cursor position
			str = str[..(str.Length-1)]
			'cursor_index :- 1
			'If cursor_index < 0 Then cursor_index = 0
		Else If KeyHit( KEY_DELETE ) '.. 'erase character right of cursor
		'And cursor_index < str.Length-1
			'use cursor position
		End If
		'FlushKeys()
		Return str
	End Method
	
	Function cursor_alpha#()
		Return (0.5 + Sin( Float(now() Mod cursor_blink) / Float(cursor_blink) ))
	End Function
	
	Function GetChar_normal$() 'returns "" if none, or a string representing the character of the key pressed
		Local normal_index% = KeyDown_normal()
		If normal_index <> -1
			If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT ) 'upper case
				Return normal_chars_ucase[normal_index]
			Else 'lower case
				Return normal_chars_lcase[normal_index]
			End If
		Else
			Return "" 'nothing
		End If
	End Function

	Function KeyDown_normal%() 'returns -1 if none, or the key code of the key hit
		For Local normal_index% = 0 To normal_keys.Length - 1
			If KeyDown( normal_keys[normal_index] )
				Return normal_index
			End If
		Next
		Return -1
	End Function
	
	Global normal_chars_ucase$[] = [ ..
		")", "!", "@", "#", "$", "%", "^", "&", "*", "(", ..
		"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", ..
		"A", "S", "D", "F", "G", "H", "J", "K", "L", ..
		"Z", "X", "C", "V", "B", "N", "M", ..
		"~~", "_", "+", "{", "}", "|", ..
		":", "~q", "<", ">", "?", " " ]
		
	Global normal_chars_lcase$[] = [ ..
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", ..
		"a", "s", "d", "f", "g", "h", "j", "k", "l", ..
		"z", "x", "c", "v", "b", "n", "m", ..
		"`", "-", "=", "[", "]", "\", ..
		";", "'", ",", ".", "/", " " ]
		
	Global normal_keys%[] = [ ..
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, ..
		KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, ..
		KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, ..
		KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, ..
		KEY_TILDE, KEY_MINUS, KEY_EQUALS, KEY_OPENBRACKET, KEY_CLOSEBRACKET, KEY_BACKSLASH, ..
		KEY_SEMICOLON, KEY_QUOTES, KEY_COMMA, KEY_PERIOD, KEY_SLASH, KEY_SPACE ]
	
End Type


