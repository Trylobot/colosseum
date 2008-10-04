Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Keyboard Input
Function get_all_input()
	
	'mouse
	mouse.x = MouseX()
	mouse.y = MouseY()
'	If game <> Null
'		If game.human_participation And game.player_brain <> Null And profile.input_method = INPUT_KEYBOARD_MOUSE_HYBRID
'			HideMouse()
'		Else
'			ShowMouse()
'		End If
'	End If
	
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
			get_current_menu().execute_current_option()
		End If
	Else 'show in-game help
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
	End If
	
	'game-specific input
	If game <> Null

		If KeyHit( KEY_ESCAPE ) 'show menu
			If Not FLAG_in_menu
				FLAG_in_menu = True
				If engine_idle <> Null
					SetChannelVolume( engine_idle, 0 )
				End If
				If game.game_in_progress
					menu_command( COMMAND_BACK_TO_MAIN_MENU )
					get_menu( MENU_ID_MAIN_MENU ).set_enabled( "resume", True )
					get_menu( MENU_ID_MAIN_MENU ).set_focus( "resume" )
					'clear keystate listeners
					KeyHit( KEY_DOWN )
					KeyHit( KEY_RIGHT )
					KeyHit( KEY_UP )
					KeyHit( KEY_LEFT )
				Else	
					'this branch cannot be reached with the current game logic.. I think
					'it would imply the user is not in a menu and not in a game.
					'if that's the case.. then where is the user? limbo? idk
				End If
			Else 'FLAG_in_menu
				menu_command( COMMAND_BACK_TO_PARENT_MENU )
			End If
		End If

		If Not game.battle_in_progress And game.waiting_for_player_to_exit_arena And KeyDown( KEY_R )
			game.player.pos_x = game.player_spawn_point.pos_x
			game.player.pos_y = game.player_spawn_point.pos_y
			game.player.ang = game.player_spawn_point.ang
			game.player.snap_all_turrets()
		End If

	End If
	
End Function
'______________________________________________________________________________
Type CONSOLE
	Global key_press_time% = 1000
	Global key_repeat_delay% = 100
	
	Field upper_case%
	Field cursor_index%
	Field last_char$
	Field key_press_ts%
	Field repeat_ts%
	
	Method update$( str$, max_size% = INFINITY, reset_cursor% = False )
		If reset_cursor Then cursor_index = str.Length
		If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
			upper_case = True
		Else
			upper_case = False
		End If
		
		If max_size = INFINITY Or str.Length < max_size
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
		FlushKeys()
		Return str
	End Method
	
	Global normal_chars_ucase$[] = [ ..
		")", "!", "@", "#", "$", "%", "^", "&", "*", "(", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", ..
		"~~", "_", "+", "{", "}", "|", ".", "+", "-", "*", "/", ":", "~q", "<", ">", "?", " " ]
		
	Global normal_chars_lcase$[] = [ ..
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", ..
		"`",  "-", "=", "[", "]", "\", ".", "+", "-", "*", "/", ";", "'",  ",", ".", "/", " " ]
		
	Global normal_keys%[] = [ ..
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_NUM0, KEY_NUM1, KEY_NUM2, KEY_NUM3, KEY_NUM4, KEY_NUM5, KEY_NUM6, KEY_NUM7, KEY_NUM8, KEY_NUM9, ..
		KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, ..
		KEY_TILDE, KEY_MINUS, KEY_EQUALS, KEY_OPENBRACKET, KEY_CLOSEBRACKET, KEY_BACKSLASH, KEY_NUMDECIMAL, KEY_NUMADD, KEY_NUMSUBTRACT, KEY_NUMMULTIPLY, KEY_NUMDIVIDE, KEY_SEMICOLON, KEY_QUOTES, KEY_COMMA, KEY_PERIOD, KEY_SLASH, KEY_SPACE ]
	
	Method GetChar_normal$() 'returns "" if none, or a string representing the character of the key pressed
		Local key_index% = INFINITY
		For Local index% = 0 To normal_keys.Length-1
			If KeyDown( normal_keys[index] )
				key_index = index
				Exit
			End If
		Next
		If key_index <> INFINITY
			If upper_case
				Return normal_chars_ucase[key_index]
			Else 'lower case
				Return normal_chars_lcase[key_index]
			End If
		Else
			Return "" 'nothing
		End If
	End Method

End Type


