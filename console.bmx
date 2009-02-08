Rem
	console.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type CONSOLE
	'Field cursor_index%
	
	Function get_input$( initial_value$, initial_cursor_pos% = INFINITY, x%, y%, font:TImageFont ) 'returns user input
		Local bg:TImage = screencap()
		Local str$ = initial_value
		SetImageFont( font )
		Local cursor% = str.Length
		Local char_width% = TextWidth( "W" )
		Repeat
			Cls()
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
			SetRotation( 0 )
			SetScale( 1, 1 )
			DrawImage( bg, 0, 0 )
			SetAlpha( 0.333333 )
			SetBlend( LIGHTBLEND )
			DrawImage( bg, 2, 0 )
			DrawImage( bg, 0, 2 )
			DrawImage( bg, 0, -2 )
			DrawImage( bg, -2, 0 )
			SetAlpha( 0.666666 )
			SetBlend( ALPHABLEND )
			SetColor( 0, 0, 0 )
			DrawRect( 0, 0, window_w, window_h )
			SetAlpha( 1 )
			SetColor( 255, 255, 255 )
			'instaquit
			escape_key_update()
			
			'cursor move
			If KeyHit( KEY_LEFT )
				cursor :- 1
				If cursor < 0 Then cursor = 0
			Else If KeyHit( KEY_RIGHT )
				cursor :+ 1
				If cursor > str.Length Then cursor = str.Length
			End If
			
			'erase character immediately before the cursor, and decrement the cursor
			If KeyHit( KEY_BACKSPACE )
				str = str[..cursor] + str[cursor+1..]
			End If

			'normal input
			Local char$ = get_char()
			If char <> ""
				str :+ char
				'cursor_index :+ 1
			End If
			
			DrawText_with_outline( str, x, y )
			SetAlpha( 0.5 + Sin(now() Mod 360) )
			DrawText( "|", x + char_width*cursor - 4, y )
			
			'instaquit
			If KeyDown( KEY_ESCAPE ) And esc_held And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
				draw_instaquit_progress()
			End If

			Flip( 1 )
			If AppTerminate() Then End
		Until escape_key_release() Or KeyHit( KEY_ENTER )

		Return str
	End Function
	
	Method update$( str$, max_size% = INFINITY, reset_cursor% = False )
		'cursor reset (why is this even necessary?!)
		'If reset_cursor Then cursor_index = str.Length
		'arrow keys + backspace/delete
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
	
	Function get_char$() 'returns "" if none, or a string representing the character of the key pressed
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
	End Function

End Type

