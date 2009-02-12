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
Global dragging_scrollbar% = False

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
		Local target_valid% = m.select_by_coords( mouse.pos_x, mouse.pos_y )
		If MouseHit( 1 )
			If target_valid
				m.execute_current_option()
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
			'determine the percentage of the scrollbar rect that the inner rect occupies
			'Local filled_pct# = Float(m.dynamic_options_displayed) / Float(m.options.Length - m.static_option_count)
			'Local empty_pct# = 1 - filled_pct
			'Local empty_h# = Float(bar.h) * empty_pct
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
			m.focus = closest_y_val_i + m.static_option_count
			'if the focus is out of the window, increment or decrement it until it is once again in the window
			While m.focus >= m.static_option_count And m.option_above_window( m.focus )
				m.increment_focus()
			End While
			While m.focus < m.options.Length And m.option_below_window( m.focus )
				m.decrement_focus()
			End While
			m.center_scrolling_window()
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
	
	mouse_state_update()
	
	'win/kill_tally
	If game And game.human_participation
		If Not game.game_in_progress And KeyHit( KEY_ENTER )
			game.player_engine_running = False
			tweak_engine_idle()
			If Not game.game_over
				kill_tally( "", screencap() )
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
Global mouse_down_1% = False

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

