Rem
	input.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "point.bmx"
Import "vec.bmx"
Import "console.bmx"
Import "mouse.bmx"
Import "flags.bmx"
Import "instaquit.bmx"
Import "core.bmx"
Import "player_profile.bmx"
Import "constants.bmx"
Import "audio.bmx"
Import "draw_misc.bmx"
Import "data.bmx"

'______________________________________________________________________________
Global chat_input_listener:CONSOLE = New CONSOLE
Global chat$

Function get_all_input()
		
	get_chat_input()

	'mouse update
	mouse_delta.x = MouseX() - mouse.pos_x
	mouse_delta.y = MouseY() - mouse.pos_y
	mouse.pos_x = MouseX()
	mouse.pos_y = MouseY()
	If Not FLAG.in_menu And game <> Null And game.human_participation And game.player_brain <> Null And profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
		HideMouse()
	Else
		ShowMouse()
	End If
	If Not MouseDown( 1 )
		FLAG.ignore_mouse_1 = False
	End If
	
	'navigate menu and select option
	If FLAG.in_menu
		Local m:MENU = get_current_menu()
		'text input controls comes before anything else
		If m.menu_type = MENU.TEXT_INPUT_DIALOG
			If KeyHit( KEY_ENTER )
				'm.execute_current_option()
				execute_option( m.get_focus() )
			Else
				m.input_box = m.input_listener.update( m.input_box )
				m.update()
			End If
		End If
		'menu navigation controls
		If KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_BACKSPACE ) ..
		And (current_menu > 0 And get_current_menu().id <> MENU_ID.PAUSED)
			menu_command( COMMAND.BACK_TO_PARENT_MENU )
		End If
		If KeyHit( KEY_DOWN )' Or MouseZ() < mouse_last_z
			m.increment_focus()
		Else If KeyHit( KEY_UP )' Or MouseZ() > mouse_last_z
			m.decrement_focus()
		End If
		If KeyHit( KEY_ENTER )
			'm.execute_current_option()
			execute_option( m.get_focus() )
		End If
		'mouseover of menu items
		If mouse_delta.x <> 0 Or mouse_delta.y <> 0
			m.calculate_bounding_boxes()
			m.select_by_coords( mouse.pos_x, mouse.pos_y )
		End If
		'select option under mouse cursor, if there be one
		If MouseHit( 1 )
			m.calculate_bounding_boxes()
			If m.select_by_coords( mouse.pos_x, mouse.pos_y )
				execute_option( m.get_focus() )
				m = get_current_menu()
				m.calculate_bounding_boxes()
				m.select_by_coords( mouse.pos_x, mouse.pos_y )
			Else If (current_menu > 0 And get_current_menu().id <> MENU_ID.PAUSED) ..
			And mouse_hovering_on_back_button()
				menu_command( COMMAND.BACK_TO_PARENT_MENU )
			End If
		End If
		'dragging of scrollbar
		If mouse_clicked_1() And m.hovering_on_scrollbar( mouse.pos_x, mouse.pos_y )
			dragging_scrollbar = True
		Else If mouse_released_1()
			dragging_scrollbar = False
		End If
		If dragging_scrollbar
			'mouse position is already known ... get the scrollbar's bounding box
			Local bar:BOX = m.get_scrollbar_rect( m.last_x, m.last_y )
			'determine the number of scrollbar positions
			Local positions% = m.options.Length - m.static_option_count
			'determine the y-value for each of the scrollbar positions
			Local y_val#[] = New Float[positions]
			For Local i% = 0 Until y_val.Length
				y_val[i] = Float(i)/Float(positions) * Float(bar.h)
			Next
			'compare each of these y-values to the y-value of the mouse (relative to the top of the scrollbar's bounding box)
			Local mouse_relative_y% = mouse.pos_y - bar.y
			Local closest_y_val_i% = 0
			If mouse_relative_y >= 0
				Local dist_from_mouse_to_closest_y_val# = INFINITY
				For Local i% = 0 Until y_val.Length
					If dist_from_mouse_to_closest_y_val = INFINITY ..
					Or Abs( mouse_relative_y - y_val[i] ) < dist_from_mouse_to_closest_y_val
						dist_from_mouse_to_closest_y_val = Abs( mouse_relative_y - y_val[i] )
						closest_y_val_i = i
					End If
				Next
			End If
			'change the scrollbar offset to the offset corresponding to the nearest y-value with respect to the mouse
			m.set_focus_by_index( closest_y_val_i + m.static_option_count )
			'if the focus is out of the window, increment or decrement it until it is once again in the window
			While m.focus >= m.static_option_count And m.option_above_window( m.focus )
				m.increment_focus()
			End While
			While m.focus < m.options.Length And m.option_below_window( m.focus )
				m.decrement_focus()
			End While
			m.center_scrolling_window()
		End If
		'select campaign menu
		If show_campaign_chooser
			campaign_chooser.upate()
		End If
	Else 'Not FLAG_in_menu
		If game And game.human_participation
			'pause game
			If escape_key_release() 'KeyHit( KEY_ESCAPE )
				If Not game.paused
					menu_command( COMMAND.PAUSE )
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
	
	'win
	If game And game.human_participation
		If game.win ..
		And (KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE ))
			FLAG.engine_running = False
			menu_command( COMMAND.QUIT_LEVEL )
			'automatically continue to next campaign level in sequence, if there be one
		End If
	End If
	
	mouse_last_z = MouseZ()
	
	'music enable/disable
	If KeyHit( KEY_M )
		bg_music_enabled = Not bg_music_enabled
		save_settings()
	End If
	
	'insta-quit
	escape_key_update()
	
End Function

Function execute_option( opt:MENU_OPTION )
	If opt Then menu_command( opt.command_code, opt.argument )
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

Function mouse_state_update()
	If MouseDown( 1 )
		mouse_down_1 = True
	Else
		mouse_down_1 = False
	End If
End Function

'______________________________________________________________________________
Function screenshot()
	SetOrigin( 0, 0 )
	save_pixmap_to_file( GrabPixmap( 0, 0, window_w, window_h ))
End Function

'______________________________________________________________________________
Function mouse_hovering_on_back_button%()
	Return (mouse.pos_x >= 0 And mouse.pos_x <= main_screen_x ..
	    And mouse.pos_y >= main_screen_menu_y + breadcrumb_h And mouse.pos_y <= main_screen_menu_y + breadcrumb_h + get_current_menu().height)
End Function

