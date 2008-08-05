Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Keyboard Input
Function get_all_input()
	
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
		
	Else If FLAG_level_intro And (now() - level_passed_ts) >= level_intro_freeze_time
		If KeyHit( KEY_ENTER ) Then FLAG_level_intro = Not FLAG_level_intro
		
	'show in-game help
	Else
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
		
	End If
End Function

