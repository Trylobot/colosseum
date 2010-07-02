Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "point.bmx"
'Import "vec.bmx"
'Import "console.bmx"
'Import "mouse.bmx"
'Import "flags.bmx"
'Import "instaquit.bmx"
'Import "core.bmx"
'Import "player_profile.bmx"
'Import "constants.bmx"
'Import "audio.bmx"
'Import "draw_misc.bmx"
'Import "data.bmx"

'______________________________________________________________________________
Global chat_input_listener:CONSOLE = New CONSOLE
Global chat$
Global mouse_idle%

Function get_all_input()
		
	get_chat_input()

	'mouse update
	mouse_delta.x = MouseX() - mouse.pos_x
	mouse_delta.y = MouseY() - mouse.pos_y
	If mouse_delta.x = 0 And mouse_delta.y = 0
		mouse_idle = True
	Else
		mouse_idle = False
	End If
	mouse.pos_x = MouseX()
	mouse.pos_y = MouseY()
	If Not FLAG.in_menu And game <> Null And game.human_participation And game.player_brain <> Null
		HideMouse()
	Else
		ShowMouse()
	End If
	If Not MouseDown( 1 )
		FLAG.ignore_mouse_1 = False
	End If
	
	'menu mode
	If FLAG.in_menu
		'current menu
		Local current_menu:TUIObject
		If Not FLAG.paused
			current_menu = MENU_REGISTER.get_top()
		Else 'paused
			current_menu = MENU_REGISTER.pause
		End If
		'keyboard input
		If KeyHit( KEY_UP )
			current_menu.on_keyboard_up()
		End If
		If KeyHit( KEY_DOWN )
			current_menu.on_keyboard_down()
		End If
		If KeyHit( KEY_LEFT )
			current_menu.on_keyboard_left()
		End If
		If KeyHit( KEY_RIGHT )
			current_menu.on_keyboard_right()
		End If
		If KeyHit( KEY_ENTER )
			current_menu.on_keyboard_enter()
		End If
		If KeyHit( KEY_ESCAPE )|KeyHit( KEY_BACKSPACE )
			If Not FLAG.paused
				cmd_show_previous_menu()
			Else 'paused
				cmd_unpause_game()
			End If
		End If
		'mouse input
		If Not mouse_idle
			current_menu.on_mouse_move( mouse.pos_x, mouse.pos_y )
		End If
		If mouse_clicked_1()
			Local action% = current_menu.on_mouse_click( mouse.pos_x, mouse.pos_y )
			If action
				If Not FLAG.paused And current_menu <> MENU_REGISTER.get_top()
					MENU_REGISTER.get_top().on_mouse_move( mouse.pos_x, mouse.pos_y )
				End If
			Else
				cmd_show_previous_menu()
			End If
		End If
		If mouse_clicked_2()
			cmd_show_previous_menu()
		End If
	'non-menu input mode (game mode)
	Else 'Not FLAG_in_menu
		If game And game.human_participation
			If FLAG.chat_mode
				game.player_brain.human_input_blocked_update()
			Else
				'in-game player input forwarded to brain object
				'/////////////////////////
				game.player_brain.update()
				'/////////////////////////
			End If
			'pause game
			If escape_key_release() 'KeyHit( KEY_ESCAPE )
				If Not game.paused
					'menu_command( COMMAND.PAUSE )
					cmd_pause_game()
				End If
				FlushKeys()
			End If
		End If
		'help
		If KeyHit( KEY_F1 )
			FLAG_draw_help = Not FLAG_draw_help
		End If
	End If
	
	mouse_state_update()
	mouse_last_z = MouseZ()
	
	'win
	'TODO: this needs to go someplace else
	If game And game.human_participation
		If game.win ..
		And (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ))
			FLAG.engine_running = False
			If FLAG.campaign_mode
				'menu_command( COMMAND.play_level, "levels/debug.level.json" )
				cmd_play_level( level_path + "debug" + "." + level_file_ext )
			Else
				'menu_command( COMMAND.QUIT_LEVEL )
				cmd_quit_level
			End If
		Else If game.game_over ..
		And (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ))
			'menu_command( COMMAND.PLAY_LEVEL, "" )
			cmd_play_level( "" )
		End If
	End If
	
	'music enable/disable
	If KeyHit( KEY_M )
		bg_music_enabled = Not bg_music_enabled
		save_settings()
	End If
	
	'insta-quit
	escape_key_update()

End Function

'______________________________________________________________________________
Function get_chat_input()
	If Not FLAG.in_menu And game And game.human_participation And FLAG.playing_multiplayer
		If Not FLAG.chat_mode
			If KeyHit( KEY_ENTER )
				FLAG.chat_mode = True
				chat = ""
				chat_input_listener.flush_all()
			End If
		Else 'FLAG.chat_mode
			If Not KeyHit( KEY_ENTER )
				chat = chat_input_listener.update( chat )
			Else 'KeyHit( KEY_ENTER )
				FLAG.chat_mode = False
				If chat.Length > 0
					send_chat( chat )
				End If
			End If
		End If
	End If
End Function

'______________________________________________________________________________
Function mouse_clicked_1%()
	Return (Not mouse_down_1 And MouseDown( 1 ))
End Function

Function mouse_released_1%()
	Return (mouse_down_1 And Not MouseDown( 1 ))
End Function

Function mouse_clicked_2%()
	Return (Not mouse_down_2 And MouseDown( 2 ))
End Function

Function mouse_released_2%()
	Return (mouse_down_2 And Not MouseDown( 2 ))
End Function

Function mouse_state_update()
	If MouseDown( 1 )
		mouse_down_1 = True
	Else
		mouse_down_1 = False
	End If
	If MouseDown( 2 )
		mouse_down_2 = True
	Else
		mouse_down_2 = False
	End If
End Function

'______________________________________________________________________________
Function screenshot()
	SetOrigin( 0, 0 )
	save_pixmap_to_file( GrabPixmap( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() ))
End Function

'______________________________________________________________________________
Rem
Function mouse_hovering_on_back_button%()
	Return (mouse.pos_x >= 0 And mouse.pos_x <= main_screen_x ..
	    And mouse.pos_y >= main_screen_menu_y + breadcrumb_h And mouse.pos_y <= main_screen_menu_y + breadcrumb_h + get_current_menu().height)
End Function
EndRem
