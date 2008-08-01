Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Keyboard Input
Function get_all_input()
	
	'music
	If KeyHit( KEY_M ) Then FLAG_bg_music_on = Not FLAG_bg_music_on
	
	'pause menu
	If KeyHit( KEY_ESCAPE )
		If Not FLAG_in_menu
			FLAG_in_menu = True
			If FLAG_game_in_progress
				menu_enabled[ MENU_RESUME ] = True
				menu_option = MENU_RESUME
			End If
		Else If FLAG_game_in_progress 'And FLAG_in_menu
			menu_command( MENU_RESUME )
		End If
	End If
	
	If FLAG_in_menu
		'navigate the menu
		If KeyHit( KEY_DOWN )
			next_enabled_menu_option()
		Else If KeyHit( KEY_UP )
			prev_enabled_menu_option()
		End If
		'select an option
		If KeyHit( KEY_ENTER )
			menu_command( menu_option )
		End If
		
	Else If FLAG_level_intro
		If KeyHit( KEY_ENTER ) Then FLAG_level_intro = Not FLAG_level_intro
		
	Else
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
		
	End If
End Function

