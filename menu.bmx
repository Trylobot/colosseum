Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const MENU_OPTION_CLASS_LABEL% = 1
Const MENU_OPTION_CLASS_HORIZONTAL_SELECT_ONE% = 2
Const MENU_OPTION_CLASS_VERTICAL_SELECT_ONE% = 3
Const MENU_OPTION_CLASS_INPUT% = 4
Const MENU_OPTION_CLASS_SLIDER% = 5

Type MENU_OPTION
	Field name$ 'display this to user
	Field class% 'option class
	Field command_code% 'command to execute when this option is selected
	Field command_argument% 'integer parameter, has meaning in combination with command_code
	Field visible% 'draw this option? {true|false}
	Field enabled% 'this option can be selected? {true|false}
	
	Field last_x%, last_y% '(private) records last drawn position
	
	Function Create:MENU_OPTION( name$, command_code%, command_argument% = 0, visible% = True, enabled% = True )
		Local opt:MENU_OPTION = New MENU_OPTION
		opt.name = name
		opt.command_code = command_code
		opt.command_argument = command_argument
		opt.visible = visible
		opt.enabled = enabled
		Return opt
	End Function
	
	Method clone:MENU_OPTION()
		Return Create( name, command_code, visible, enabled )
	End Method
	
	Method draw( x%,y%, glow% = False, red% = 255, green% = 255, blue% = 255 )
		last_x = x; last_y = y
		SetColor( red, green, blue )
		If glow
			
		Else
			
		End If
	End Method
	
	Method mouse_hover%( x%, y% )
		'called every frame with the mouse coordinates
		If x >= last_x And x <= x + width() And y >= last_y And y <= y + height()
			Return True
		Else
			Return False
		End If
	End Method
	
	Method mouse_click%( x%, y% )
		'called whenever the mouse is clicked
		'..?
	End Method
	
	Method width%()
		
	End Method
	Method height%()
		
	End Method
	
End Type
'______________________________________________________________________________
Const ARROW_RIGHT% = 1
Const ARROW_LEFT% = 2

Function draw_arrow( arrow_type%, x#, y#, height% )
	Select arrow_type
		Case ARROW_RIGHT
			DrawPoly( [ x,y, x,y+height, x+height/2,y+height/2 ])
		Case ARROW_LEFT
			DrawPoly( [ x,y, x,y+height, x-height/2,y+height/2 ])
	End Select
End Function
'______________________________________________________________________________
Global menu_font:TImageFont = get_font( "consolas_24" )

Const MENU_TYPE_SELECT_ONE_VERTICAL_LIST% = 1
Const MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST% = 2
Const MENU_TYPE_FILE_SELECTOR% = 3

Type MENU
	Field name$ 'display to user
	Field red%, green%, blue% 'title bar color
	Field menu_id% 'handle
	Field menu_type% 'controls display and input
	Field margin% 'visual margin
	Field options:MENU_OPTION[] 'array of possible options
	Field children%[] 'array of handles, can be 0 (no child)
	Field focus% 'index into options[]
	
	Function Create:MENU( name$, red%, green%, blue%, menu_id%, menu_type%, margin%, focus% = -1, options:MENU_OPTION[] )
		Local m:MENU = New MENU
		m.name = name
		m.red = red; m.green = green; m.blue = blue
		m.menu_id = menu_id
		m.menu_type = menu_type
		m.margin = margin
		m.focus = focus
		m.options = options[..]
		If m.focus = -1
			m.increment_focus()
		End If
		Return m
	End Function
	
	Method draw( x%, y%, border% = False )
		Local cx% = x, cy% = y, opt:MENU_OPTION
		
		Local arrow_height% = 20
		Local border_width% = 3
		Local text_height_factor# = 0.70
		Local width% = 0, height% = 0
		
		SetImageFont( get_font( "consolas_bold_24" ))
		
		Select menu_type
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				For Local opt:MENU_OPTION = EachIn options
					opt = opt.clone()
					If (2*margin + TextWidth( opt.name ) + 2*border_width) > width
						width = (2*margin + TextWidth( opt.name ) + 2*border_width)
					End If
				Next
				If (2*margin + TextWidth( name ) + 2*border_width) > width
					width = (2*margin + TextWidth( name ) + 2*border_width)
				End If
				height = (margin + (1 + options.Length)*(text_height_factor*GetImageFont().Height() + margin) + 2*border_width)
			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
				For Local opt:MENU_OPTION = EachIn options
					opt = opt.clone()
					If (4*margin + TextWidth( opt.name ) + 2*arrow_height/2 + 2*border_width) > width
						width = (4*margin + TextWidth( opt.name ) + 2*arrow_height/2 + 2*border_width)
					End If
				Next
				If (4*margin + TextWidth( name ) + 2*arrow_height/2 + 2*border_width) > width
					width = (4*margin + TextWidth( name ) + 2*arrow_height/2 + 2*border_width)
				End If
				height = (2*margin + 2*(text_height_factor*GetImageFont().Height() + margin) + 2*border_width)
		End Select
		
		If border
			SetColor( 64, 64, 64 )
			DrawRect( x-border_width,y-border_width, width,height )
			SetColor( 0, 0, 0 )
			DrawRect( x,y, width-2*border_width,height-2*border_width )
			SetColor( red/4, green/4, blue/4 )
			DrawRect( x,y, width-2*border_width,text_height_factor*GetImageFont().Height() + margin )
			SetColor( red, green, blue )
			DrawText( name, x+margin,y+margin/2 )
		End If
		
		Select menu_type
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				x :+ margin; y :+ 2*margin + text_height_factor*GetImageFont().Height()
				For Local i% = 0 To options.Length - 1
					opt = options[i]
					If i = focus
						SetColor( 255, 255, 255 )
						DrawText_with_glow( opt.name, x, y )
					Else
						If (opt.enabled And opt.visible)
							SetColor( 127, 127, 127 )
						Else If opt.visible
							SetColor( 64, 64, 64 )
						Else
							SetColor( 0, 0, 0 )
						End If
						DrawText( opt.name, x, y )
					End If
					
					y :+ text_height_factor*GetImageFont().Height() + margin
				Next
			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
				y :+ 2*margin + text_height_factor*GetImageFont().Height()
				Local left_color%, right_color%
				If focus = 0
					left_color = 96
					If options.Length > 1
						right_color = 255
					Else
						right_color = 96
					End If
				Else If focus = options.Length - 1
					right_color = 96
					If options.Length > 1
						left_color = 255
					Else
						left_color = 96
					End If
				Else
					left_color = 255
					right_color = 255
				End If
				SetColor( left_color, left_color, left_color )
				draw_arrow( ARROW_LEFT, x + margin + arrow_height/2, y + margin, arrow_height )
				SetColor( right_color, right_color, right_color )
				draw_arrow( ARROW_RIGHT, x + width - 2*margin - arrow_height/2, y + margin, arrow_height )
				SetColor( 255, 255, 255 )
				DrawText_with_glow( options[focus].name, x + 2*margin + arrow_height/2, y + margin )
		End Select
		
	End Method
	
	Method get_focus:MENU_OPTION()
		Return options[focus]
	End Method
	
	Method set_focus( key$ )
		Local i% = find_option( key )
		If i <> -1 Then focus = i
	End Method
	
	Method set_enabled( key$, value% )
		Local i% = find_option( key )
		If i <> -1 Then options[i].enabled = value
	End Method
	
	Method find_option%( key$ )
		key = key.ToLower()
		For Local i% = 0 To options.Length - 1
			If key = options[i].name.ToLower()
				Return i
			End If
		Next
		Return -1
	End Method
	
	Method increment_focus()
		Select menu_type
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				Local last_focus% = focus
				focus :+ 1; wrap_focus()
				While focus <> last_focus And Not options[focus].enabled
					focus :+ 1; wrap_focus()
				End While
			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
				For Local f% = focus + 1 To options.Length - 1 Step 1
					If options[f].visible And options[f].enabled
						focus = f
						Return
					End If
				Next
		End Select
	End Method
	
	Method decrement_focus()
		Select menu_type
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				Local last_focus% = focus
				focus :- 1; wrap_focus()
				While focus <> last_focus And Not options[focus].enabled
					focus :- 1; wrap_focus()
				End While
			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
				For Local f% = focus - 1 To 0 Step -1
					If options[f].visible And options[f].enabled
						focus = f
						Return
					End If
				Next
		End Select
	End Method
	
	Method execute_current_option()
		Local opt:MENU_OPTION = get_focus()
		menu_command( opt.command_code, opt.command_argument )
	End Method
	
	Method wrap_focus()
		If      focus > (options.Length - 1) Then focus = 0 ..
		Else If focus < 0                    Then focus = (options.Length - 1)
	End Method
	
End Type
'______________________________________________________________________________
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_BACK_TO_MAIN_MENU% = 53
Const COMMAND_RESUME% = 100
Const COMMAND_NEW_GAME% = 101
Const COMMAND_LOAD_GAME% = 102
Const COMMAND_SAVE_GAME% = 103
Const COMMAND_EDIT_LEVEL% = 200
Const COMMAND_PLAYER_INPUT_TYPE% = 1000
Const COMMAND_QUIT_GAME% = 10000

Const COMMAND_ARGUMENT_NULL% = 0
Const COMMAND_ARGUMENT_CREATE_NEW_SAVED_GAME% = -1

Const MENU_ID_MAIN_MENU% = 10
Const MENU_ID_NEW% = 20
Const MENU_ID_LOAD% = 30
Const MENU_ID_SAVE% = 40
Const MENU_ID_OPTIONS% = 50
Const MENU_ID_OPTIONS_VIDEO% = 51
Const MENU_ID_OPTIONS_AUDIO% = 52
Const MENU_ID_OPTIONS_CONTROLS% = 53
Const MENU_ID_OPTIONS_GAME% = 54
Const MENU_ID_EDITORS% = 60

Global menu_margin% = 8
Global all_menus:MENU[] = ..
[ ..
	MENU.Create( "main menu", 255, 255, 127, MENU_ID_MAIN_MENU, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, False ), ..
			MENU_OPTION.Create( "new", COMMAND_SHOW_CHILD_MENU, MENU_ID_NEW, True, True ), ..
			MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, MENU_ID_LOAD, True, True ), ..
			MENU_OPTION.Create( "save", COMMAND_SHOW_CHILD_MENU, MENU_ID_SAVE, True, True ), ..
			MENU_OPTION.Create( "options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS, True, True ), ..
			MENU_OPTION.Create( "editors", COMMAND_SHOW_CHILD_MENU, MENU_ID_EDITORS, True, True ), ..
			MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ]), ..
	MENU.Create( "new game", 255, 255, 127, MENU_ID_NEW, MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST, menu_margin, 1, ..
		[ MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "light tank", COMMAND_NEW_GAME, PLAYER_INDEX_LIGHT_TANK, True, True ), ..
			MENU_OPTION.Create( "laser tank", COMMAND_NEW_GAME, PLAYER_INDEX_LASER_TANK, True, True ), ..
			MENU_OPTION.Create( "medium tank", COMMAND_NEW_GAME, PLAYER_INDEX_MED_TANK, True, True ) ]), ..
	MENU.Create( "load game", 255, 196, 196, MENU_ID_LOAD, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[ MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ]), ..
	MENU.Create( "save game", 127, 255, 127, MENU_ID_SAVE, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[ MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "create new", COMMAND_SAVE_GAME, COMMAND_ARGUMENT_CREATE_NEW_SAVED_GAME, True, True ) ]), ..
	MENU.Create( "options", 127, 127, 255, MENU_ID_OPTIONS, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "video options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_VIDEO, True, False ), ..
			MENU_OPTION.Create( "audio options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_AUDIO, True, False ), ..
			MENU_OPTION.Create( "control options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_CONTROLS, True, True ), ..
			MENU_OPTION.Create( "game options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_GAME, True, False ) ]), ..
	MENU.Create( "editors", 196, 196, 196, MENU_ID_EDITORS, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "level editor", COMMAND_EDIT_LEVEL,, True, True ) ]), ..
	MENU.Create( "control options", 127, 196, 255, MENU_ID_OPTIONS_CONTROLS, MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INPUT_KEYBOARD, True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INPUT_KEYBOARD_MOUSE_HYBRID, True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INPUT_XBOX_360_CONTROLLER, True, False ) ]) ..
]

'______________________________________________________________________________
Global menu_stack%[] = New Int[25]
	menu_stack[0] = MENU_ID_MAIN_MENU
Global current_menu% = 0

Function get_current_menu:MENU()
	Return get_menu( menu_stack[current_menu] )
End Function

Function get_menu:MENU( menu_id% )
	For Local i% = 0 To all_menus.Length - 1
		If all_menus[i].menu_id = menu_id
			Return all_menus[i]
		End If
	Next
	Return Null
End Function

'command_argument should be an object;
'  the object gets cast to an appropriate type automatically, a container type with all the information necessary
'  if the cast fails, the argument is invalid
Function menu_command( command_code%, command_argument% = COMMAND_ARGUMENT_NULL )
	Select command_code
		
		Case COMMAND_SHOW_CHILD_MENU
			current_menu :+ 1
			menu_stack[current_menu] = command_argument
			'special processing
			If one_of( command_argument, [MENU_ID_LOAD, MENU_ID_SAVE] )
				Local file_list:TList = find_files( user_path, saved_game_file_ext )
				If Not file_list.IsEmpty()
					Local this_menu:MENU = get_menu( command_argument )
					Local new_options:MENU_OPTION[] = New MENU_OPTION[this_menu.options.Length+file_list.Count()]
					new_options[0] = this_menu.options[0]
					If command_argument = MENU_ID_SAVE
						new_options[new_options.Length-1] = this_menu.options[1]
					End If
					Local i% = 1
					Local new_command_code%
					If command_argument = MENU_ID_SAVE Then new_command_code = COMMAND_SAVE_GAME Else new_command_code = COMMAND_LOAD_GAME
					For Local file$ = EachIn file_list
						new_options[i] = MENU_OPTION.Create( file, new_command_code, i, True, True )
						i :+ 1
					Next
					this_menu.options = new_options
				End If
			End If
			
		Case COMMAND_BACK_TO_PARENT_MENU
			If current_menu > 0 Then current_menu :- 1
			
		Case COMMAND_BACK_TO_MAIN_MENU
			current_menu = 0
			
		Case COMMAND_RESUME
			core_resume_game()
			
		Case COMMAND_NEW_GAME
			core_begin_new_game( command_argument )
			
		Case COMMAND_LOAD_GAME
			'load_game_by_slot( command_argument )
			
		Case COMMAND_SAVE_GAME
			If command_argument = COMMAND_ARGUMENT_CREATE_NEW_SAVED_GAME
				'get input from user using kb_handler -> filename for saved game
				
				'confirm overwrite if there exists a file already
				
			Else 'command_argument <> COMMAND_ARGUMENT_CREATE_NEW_SAVED_GAME
				'confirm overwrite for selecting this option (an existing file)
				
			End If
			
		Case COMMAND_PLAYER_INPUT_TYPE
			profile.input_method = command_argument
			If game.player_brain <> Null
				game.player_brain.input_type = profile.input_method
			End If
			
		Case COMMAND_EDIT_LEVEL
			edit_level_file()
			
		Case COMMAND_QUIT_GAME
			End
			
	End Select
End Function


