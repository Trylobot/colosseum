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
	Field argument:Object 'parameter, has meaning only in combination with command_code
	Field visible% 'draw this option? {true|false}
	Field enabled% 'this option can be selected? {true|false}
	
	Field last_x%, last_y% '(private) records last drawn position
	
	Function Create:MENU_OPTION( name$, command_code%, argument:Object = Null, visible% = True, enabled% = True )
		Local opt:MENU_OPTION = New MENU_OPTION
		opt.name = name
		opt.command_code = command_code
		opt.argument = argument
		opt.visible = visible
		opt.enabled = enabled
		Return opt
	End Function
	
	Method clone:MENU_OPTION()
		Return Create( name, command_code, argument, visible, enabled )
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

Type MENU
	Global MENU_TYPE_SELECT_ONE_VERTICAL_LIST% = 10
	'Global MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST% = 11
	Global MENU_TYPE_CHOOSE_FILE% = 20
	Global MENU_TYPE_CREATE_NEW_FILE% = 21
	Global MENU_TYPE_INPUT_DIALOG% = 50
	Global MENU_TYPE_INFORMATION_DIALOG% = 51
	
	Field menu_id% 'unique menu id
	Field menu_type% 'menu class
	
	Field name$ 'menu title string
	Field red%, green%, blue% 'title bar color
	Field margin% 'visual margin (pixels)
	
	Field options:MENU_OPTION[] 'array of options in this menu
	Field focus% 'index of currently focused option
	
	Field path$ 'current directory; this menu will display files from it (if applicable)
	Field preferred_file_extension$ 'files of this type will be more visible to the user (if applicable)
	Field default_command% 'default command to use in the case of a dynamic list (if applicable)
	Field default_argument:Object 'default argument to use in the case of a dynamic list (if applicable)
	Field files:TList 'list of files from the current directory, updated often (if applicable)
	
	Field input_box$ 'user input string (if applicable)
	Field input_listener:CONSOLE 'input controller/listener (if applicable)
	
	Function Create:MENU( ..
	name$, red%, green%, blue%, menu_id%, menu_type%, margin%, focus% = -1, options:MENU_OPTION[] = Null, ..
	path$ = "", preferred_file_extension$ = "", default_command% = -1, default_argument:Object = Null )
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
		m.path = path
		m.preferred_file_extension = preferred_file_extension
		m.default_command = default_command
		m.default_argument = default_argument
		m.input_box = ""
		m.input_listener = New CONSOLE
		Return m
	End Function
	
	Method draw( x%, y%, border% = False )
		Local cx% = x, cy% = y, opt:MENU_OPTION
		
		Local arrow_height% = 20
		Local border_width% = 3
		Local text_height_factor# = 0.70
		Local width% = 0, height% = 0
		
		'determine dimensions of this menu
		Select menu_type
			
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				SetImageFont( get_font( "consolas_bold_24" ))
				For Local opt:MENU_OPTION = EachIn options
					Local opt_name_dynamic$ = resolve_meta_variables( opt.name )
					If (2*margin + TextWidth( opt_name_dynamic ) + 2*border_width) > width
						width = (2*margin + TextWidth( opt_name_dynamic ) + 2*border_width)
					End If
				Next
				If (2*margin + TextWidth( name ) + 2*border_width) > width
					width = (2*margin + TextWidth( name ) + 2*border_width)
				End If
				height = (margin + (1 + options.Length)*(text_height_factor*GetImageFont().Height() + margin) + 2*border_width)
			
'			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
'				SetImageFont( get_font( "consolas_bold_24" ))
'				For Local opt:MENU_OPTION = EachIn options
'					If (4*margin + TextWidth( opt.name ) + 2*arrow_height/2 + 2*border_width) > width
'						width = (4*margin + TextWidth( opt.name ) + 2*arrow_height/2 + 2*border_width)
'					End If
'				Next
'				If (4*margin + TextWidth( name ) + 2*arrow_height/2 + 2*border_width) > width
'					width = (4*margin + TextWidth( name ) + 2*arrow_height/2 + 2*border_width)
'				End If
'				height = (2*margin + 2*(text_height_factor*GetImageFont().Height() + margin) + 2*border_width)
				
		End Select
		
		'draw the borders and backgrounds
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
		
		'draw the options
		Select menu_type
			
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				x :+ margin; y :+ 2*margin + text_height_factor*GetImageFont().Height()
				For Local i% = 0 To options.Length-1
					opt = options[i]
					If opt <> Null
						Local opt_name_dynamic$ = resolve_meta_variables( opt.name )
						If i = focus
							SetColor( 255, 255, 255 )
							DrawText_with_glow( opt_name_dynamic, x, y )
						Else
							If (opt.enabled And opt.visible)
								SetColor( 127, 127, 127 )
							Else If opt.visible
								SetColor( 64, 64, 64 )
							Else
								SetColor( 0, 0, 0 )
							End If
							DrawText( opt_name_dynamic, x, y )
						End If
					End If
					y :+ text_height_factor*GetImageFont().Height() + margin
				Next
			
'			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
'				y :+ 2*margin + text_height_factor*GetImageFont().Height()
'				Local left_color%, right_color%
'				If focus = 0
'					left_color = 96
'					If options.Length > 1
'						right_color = 255
'					Else
'						right_color = 96
'					End If
'				Else If focus = options.Length - 1
'					right_color = 96
'					If options.Length > 1
'						left_color = 255
'					Else
'						left_color = 96
'					End If
'				Else
'					left_color = 255
'					right_color = 255
'				End If
'				SetColor( left_color, left_color, left_color )
'				draw_arrow( ARROW_LEFT, x + margin + arrow_height/2, y + margin, arrow_height )
'				SetColor( right_color, right_color, right_color )
'				draw_arrow( ARROW_RIGHT, x + width - 2*margin - arrow_height/2, y + margin, arrow_height )
'				SetColor( 255, 255, 255 )
'				If options[focus] <> Null	
'					DrawText_with_glow( options[focus].name, x + 2*margin + arrow_height/2, y + margin )
'				End If
				
		End Select
	End Method
	
	Method update()
		Select menu_type
			
			Case MENU_TYPE_CHOOSE_FILE, MENU_TYPE_CREATE_NEW_FILE
				files = find_files( path, preferred_file_extension )
				options = New MENU_OPTION[files.Count() + 1]
				options[0] = MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True )
				Local i% = 1
				For Local file$ = EachIn files
					options[i] = ..
						MENU_OPTION.Create( StripDir( file ), default_command, file, True, True )
					i :+ 1
				Next
				focus = 0
			
		End Select
		
		''special processing for certain menus
		'Local file_list:TList = CreateList()
		'If Not get_current_menu().runtime_options_added
		'	If one_of( command_argument, [MENU_ID_LOAD, MENU_ID_SAVE] )
		'		file_list = find_files( user_path, saved_game_file_ext )
		'	Else If one_of( command_argument, [MENU_ID_SELECT_LEVEL] )
		'		file_list = find_files( data_path, level_file_ext )
		'	End If
		'	get_current_menu().runtime_options_added = True
		'End If
		''dynamic runtime options add
		'If Not file_list.IsEmpty()
		'	Local this_menu:MENU = get_menu( command_argument )
		'	Local new_options:MENU_OPTION[] = New MENU_OPTION[this_menu.options.Length+file_list.Count()]
		'	new_options[0] = this_menu.options[0]
		'	If command_argument = MENU_ID_SAVE
		'		new_options[new_options.Length-1] = this_menu.options[1]
		'	End If
		'	Local i% = 1
		'	Local new_command_code%
		'	Local offset% = 0
		'	If command_argument = MENU_ID_SAVE
		'		new_command_code = COMMAND_SAVE_GAME
		'	Else If command_argument = MENU_ID_LOAD
		'		new_command_code = COMMAND_LOAD_GAME
		'	Else If command_argument = MENU_ID_SELECT_LEVEL
		'		new_command_code = COMMAND_SET_NEXT_LEVEL
		'		'offset = -1
		'	End If
		'	For Local file$ = EachIn file_list
		'		new_options[i] = MENU_OPTION.Create( file, new_command_code, i + offset, True, True )
		'		i :+ 1
		'	Next
		'	this_menu.options = new_options
		'End If
	End Method
	
	Method get_focus:MENU_OPTION()
		'if current menu is normal
			Return options[focus]
		'else if current menu includes a dynamic list
		'then an option will have to be built dynamically to return
		
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
			
'			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
'				For Local f% = focus + 1 To options.Length - 1 Step 1
'					If options[f].visible And options[f].enabled
'						focus = f
'						Return
'					End If
'				Next
				
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
			
'			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
'				For Local f% = focus - 1 To 0 Step -1
'					If options[f].visible And options[f].enabled
'						focus = f
'						Return
'					End If
'				Next
				
		End Select
	End Method
	
	Method execute_current_option()
		Local opt:MENU_OPTION = get_focus()
		menu_command( opt.command_code, opt.argument )
	End Method
	
	Method wrap_focus()
		If focus > (options.Length - 1)
			focus = 0
		Else If focus < 0
			focus = (options.Length - 1)
		End If
	End Method
	
End Type
'______________________________________________________________________________
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_BACK_TO_MAIN_MENU% = 53
Const COMMAND_RESUME% = 100
Const COMMAND_NEW_GAME% = 200
Const COMMAND_NEW_LEVEL% = 201
Const COMMAND_LOAD_GAME% = 300
Const COMMAND_LOAD_LEVEL% = 301
Const COMMAND_SAVE_GAME% = 400
Const COMMAND_SAVE_LEVEL% = 401
Const COMMAND_EDIT_LEVEL% = 500
Const COMMAND_PLAYER_INPUT_TYPE% = 1000
Const COMMAND_PROFILE_SET_PLAYER_TANK% = 2000
Const COMMAND_SET_NEXT_LEVEL% = 5000
Const COMMAND_QUIT_GAME% = 65535

Const MENU_ID_MAIN_MENU% = 10
Const MENU_ID_NEW_GAME% = 20
Const MENU_ID_SELECT_TANK% = 21
Const MENU_ID_SELECT_LEVEL% = 22
Const MENU_ID_LOAD_GAME% = 30
Const MENU_ID_LOAD_LEVEL% = 31
Const MENU_ID_SAVE_GAME% = 40
Const MENU_ID_SAVE_LEVEL% = 41
Const MENU_ID_OPTIONS% = 50
Const MENU_ID_OPTIONS_VIDEO% = 51
Const MENU_ID_OPTIONS_AUDIO% = 52
Const MENU_ID_OPTIONS_CONTROLS% = 53
Const MENU_ID_OPTIONS_GAME% = 54
Const MENU_ID_EDITORS% = 60
Const MENU_ID_LEVEL_EDITOR% = 61

Global menu_margin% = 8
Global all_menus:MENU[] = ..
[ ..
	MENU.Create( "main menu", 255, 255, 127, MENU_ID_MAIN_MENU, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, False ), ..
			MENU_OPTION.Create( "new", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_NEW_GAME), True, True ), ..
			MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_GAME), True, True ), ..
			MENU_OPTION.Create( "save", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_GAME), True, True ), ..
			MENU_OPTION.Create( "options", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS), True, True ), ..
			MENU_OPTION.Create( "editors", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_EDITORS), True, True ), ..
			MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ]), ..
	MENU.Create( "new game", 255, 255, 255, MENU_ID_NEW_GAME, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin, 3, ..
		[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "select tank", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SELECT_TANK), True, True ), ..
			MENU_OPTION.Create( "select level", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SELECT_LEVEL), True, True ), ..
			MENU_OPTION.Create( "start game", COMMAND_NEW_GAME,, True, True ) ]), ..
		MENU.Create( "select tank", 255, 255, 127, MENU_ID_SELECT_TANK, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin, 1, ..
			[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "light tank", COMMAND_PROFILE_SET_PLAYER_TANK, INTEGER.Create(PLAYER_INDEX_LIGHT_TANK), True, True ), ..
				MENU_OPTION.Create( "laser tank", COMMAND_PROFILE_SET_PLAYER_TANK, INTEGER.Create(PLAYER_INDEX_LASER_TANK), True, True ), ..
				MENU_OPTION.Create( "medium tank", COMMAND_PROFILE_SET_PLAYER_TANK, INTEGER.Create(PLAYER_INDEX_MEDIUM_TANK), True, True ) ]), ..
		MENU.Create( "select level", 255, 127, 127, MENU_ID_SELECT_LEVEL, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin, 1, ..
			[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ]), ..
	MENU.Create( "load game", 255, 196, 196, MENU_ID_LOAD_GAME, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ]), ..
	MENU.Create( "save game", 127, 255, 127, MENU_ID_SAVE_GAME, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ]), ..
	MENU.Create( "options", 127, 127, 255, MENU_ID_OPTIONS, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "video options", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_VIDEO), True, False ), ..
			MENU_OPTION.Create( "audio options", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_AUDIO), True, False ), ..
			MENU_OPTION.Create( "control options", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_CONTROLS), True, True ), ..
			MENU_OPTION.Create( "game options", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_GAME), True, False ) ]), ..
		MENU.Create( "control options", 127, 196, 255, MENU_ID_OPTIONS_CONTROLS, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(INPUT_KEYBOARD), True, True ), ..
				MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
				MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(INPUT_XBOX_360_CONTROLLER), True, False ) ]), ..
	MENU.Create( "editors", 196, 196, 196, MENU_ID_EDITORS, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "level editor", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LEVEL_EDITOR), True, True ) ]), ..
		MENU.Create( "level editor", 96, 127, 255, MENU_ID_LEVEL_EDITOR, MENU.MENU_TYPE_SELECT_ONE_VERTICAL_LIST, menu_margin, 1, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "edit [%%level_editor_cache.name%%]", COMMAND_EDIT_LEVEL, level_editor_cache, True, True ), ..
				MENU_OPTION.Create( "save current", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_LEVEL), True, True ), ..
				MENU_OPTION.Create( "load level", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_LEVEL), True, True ), ..
				MENU_OPTION.Create( "create new", COMMAND_NEW_LEVEL,, True, True ) ]), ..
			MENU.Create( "load level", 96, 127, 255, MENU_ID_LOAD_LEVEL, MENU.MENU_TYPE_CHOOSE_FILE, menu_margin,,, "colosseum_level", COMMAND_LOAD_LEVEL ) ..
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
Function menu_command( command_code%, argument:Object = Null )
	Select command_code
		
		Case COMMAND_SHOW_CHILD_MENU
			current_menu :+ 1
			menu_stack[current_menu] = INTEGER(argument).value
			get_current_menu().update()
			
		Case COMMAND_BACK_TO_PARENT_MENU
			If current_menu > 0 Then current_menu :- 1
			
		Case COMMAND_BACK_TO_MAIN_MENU
			current_menu = 0
			
		Case COMMAND_RESUME
			FLAG_in_menu = false
			
		Case COMMAND_NEW_GAME
			core_begin_new_game()
			
		Case COMMAND_NEW_LEVEL
			level_editor_cache = Create_LEVEL( 300, 300 )
			
		Case COMMAND_LOAD_GAME
			
		Case COMMAND_SAVE_GAME
			
		Case COMMAND_PLAYER_INPUT_TYPE
			profile.input_method = INTEGER(argument).value
			If game.player_brain <> Null
				game.player_brain.input_type = profile.input_method
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			
		Case COMMAND_PROFILE_SET_PLAYER_TANK
			profile.archetype = INTEGER(argument).value
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		
		Case COMMAND_SET_NEXT_LEVEL
			next_level = String(argument)
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			
		Case COMMAND_EDIT_LEVEL
			level_editor( level_editor_cache )
			
		Case COMMAND_QUIT_GAME
			End
			
	End Select
End Function

Type INTEGER
	Field value%
	Function Create:INTEGER( value% )
		Local i:INTEGER = New INTEGER; i.value = value;	Return i
	End Function
End Type

Function resolve_meta_variables$( str$ )
	Local tokens$[] = str.Split( "%%" )
	Local result$ = ""
	For Local i% = 0 To tokens.Length - 1
		If i Mod 2 = 1 'odd (and thus, intended as a variable pseudo-identifier)
			Select tokens[i]
				Case "level_editor_cache.name"
					result :+ level_editor_cache.name
			End Select
		Else 'even (string literal)
			result :+ tokens[i]
		End If
	Next
	Return result
End Function




