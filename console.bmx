Rem
	console.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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

