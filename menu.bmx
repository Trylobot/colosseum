Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type MENU_OPTION
	Field name$ 'display this to user
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
	
	Method draw( display_name$, x%, y%, glow% = False, red% = 255, green% = 255, blue% = 255 )
		'last_x = x; last_y = y
		SetColor( red, green, blue )
		If glow
			DrawText_with_glow( display_name, x, y )
		Else
			DrawText( display_name, x, y )
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
Const ARROW_UP% = 0
Const ARROW_RIGHT% = 1
Const ARROW_DOWN% = 2
Const ARROW_LEFT% = 3
Function draw_arrow( arrow_type%, x#, y#, height% )
	Select arrow_type
		Case ARROW_UP
			DrawPoly( [ x,y, x,y+height, x+height/2,y+height/2 ])
		Case ARROW_RIGHT
			DrawPoly( [ x,y, x,y+height, x+height/2,y+height/2 ])
		Case ARROW_DOWN
			DrawPoly( [ x,y, x,y+height, x-height/2,y+height/2 ])
		Case ARROW_LEFT
			DrawPoly( [ x,y, x,y+height, x-height/2,y+height/2 ])
	End Select
End Function
'______________________________________________________________________________
Const border_width% = 3
Const scrollbar_width% = 20

Type MENU
	Global VERTICAL_LIST% = 10
	Global VERTICAL_LIST_WITH_SUBSECTION% = 11
	Global VERTICAL_LIST_WITH_FILES% = 12
	Global TEXT_INPUT_DIALOG% = 20
	Global CONFIRMATION_DIALOG% = 21
	Global NOTIFICATION_DIALOG% = 22
	
	Global title_font:TImagefont
	Global menu_font:TImageFont
	Global menu_font_small:TImageFont
	
	Function load_fonts()
		title_font = get_font( "consolas_bold_24" )
		menu_font = get_font( "consolas_bold_24" )
		menu_font_small = get_font( "consolas_bold_18" )
	End Function

	Field menu_id% 'unique menu id
	Field menu_type% 'menu class
	
	Field name$ 'menu title string
	Field red%, green%, blue% 'title bar color
	Field margin% 'visual margin (pixels)
	
	Field options:MENU_OPTION[] 'array of options in this menu
	Field static_option_count% 'number of static options (applicable for menus with dynamic lists, such as file chooser)
	Field default_focus% 'index of default option
	Field focus% 'index of currently focused option
	Field scroll_offset% 'index of element at top of dynamic scroll window (if applicable)
	Field dynamic_options_displayed% 'size of dynamic scroll window
	
	Field path$ 'current directory; this menu will display files from it (if applicable)
	Field preferred_file_extension$ 'files of this type will be more visible to the user (if applicable)
	Field default_command% 'default command to use in the case of a dynamic list (if applicable)
	Field default_argument:Object 'default argument to use in the case of a dynamic list (if applicable)
	Field files:TList 'list of files from the current directory, updated often (if applicable)
	
	Field input_box$ 'user input string (if applicable)
	Field input_box_size% 'size of user input box
	Field input_listener:CONSOLE 'input controller/listener (if applicable)
	Field input_initial_value$ 'automatic suffix to append to input, such as in the case of filename extensions
	
	Method New()
		files = CreateList()
	End Method
	
	Function Create:MENU( ..
	name$, ..
	red%, green%, blue%, ..
	menu_id%, menu_type%, ..
	margin%, default_focus% = -1, ..
	path$ = "", preferred_file_extension$ = "", default_command% = -1, default_argument:Object = Null, ..
	input_box_size% = 0, input_initial_value$ = "", ..
	dynamic_options_displayed% = 1, ..
	options:MENU_OPTION[] = Null )
		Local m:MENU = New MENU
		m.name = name
		m.red = red; m.green = green; m.blue = blue
		m.menu_id = menu_id
		m.menu_type = menu_type
		m.margin = margin
		m.focus = default_focus
		m.dynamic_options_displayed = dynamic_options_displayed
		m.static_option_count = options.Length
		m.path = path
		m.preferred_file_extension = preferred_file_extension
		m.default_command = default_command
		m.default_argument = default_argument
		m.input_box = ""
		m.input_box_size = input_box_size
		m.input_listener = New CONSOLE
		m.input_initial_value = input_initial_value
		m.options = options[..]
		Return m
	End Function
	
	Method execute_current_option()
		Local opt:MENU_OPTION = get_focus()
		menu_command( opt.command_code, opt.argument )
	End Method
	
	Method add_option( opt:MENU_OPTION )
		options = options[..options.Length+1]
		options[options.Length-1] = opt
	End Method
	
	Method draw( x%, y%, border% = True, dark_overlay_alpha# = 0 )
		Local cx% = x, cy% = y, opt:MENU_OPTION
		
		Local text_height_factor# = 0.70
		Local width% = 0, height% = 0
		
		'calculate dimensions
		Local i% = 0
		For Local opt:MENU_OPTION = EachIn options
			If is_scrollable( menu_type ) And i >= static_option_count
				SetImageFont( menu_font_small )
				If i = static_option_count
					height :+ 0.5*( text_height_factor*GetImageFont().Height() + margin )
				End If
			Else
				SetImageFont( menu_font )
			End If
			Local opt_name_dynamic$ = resolve_meta_variables( opt.name )
			If (2*margin + TextWidth( opt_name_dynamic ) + 2*border_width) > width
				width = (2*margin + TextWidth( opt_name_dynamic ) + 2*border_width)
			End If
			If opt.visible And option_is_in_window( i )
				height :+ (text_height_factor*GetImageFont().Height() + margin)
			End If
			i :+ 1
		Next
		SetImageFont( menu_font )
		If (2*margin + TextWidth( name ) + 2*border_width) > width
			width = (2*margin + TextWidth( name ) + 2*border_width)
		End If
		If is_scrollable( menu_type )
			width :+ scrollbar_width
		End If
		height :+ (margin + (text_height_factor*GetImageFont().Height() + margin) + 2*border_width)

		'draw the borders, backgrounds and title text
		SetImageFont( title_font )
		If border
			SetColor( 64, 64, 64 )
			DrawRect( cx,cy, width,height )
			SetColor( 0, 0, 0 )
			DrawRect( cx+border_width,cy+border_width, width-2*border_width,height-2*border_width )
			SetColor( red/4, green/4, blue/4 )
			DrawRect( cx+border_width,cy+border_width, width-2*border_width,text_height_factor*GetImageFont().Height() + margin )
			SetColor( red, green, blue )
			DrawText( name, cx+border_width+margin,cy+border_width+margin/2 )
		End If
		
		'draw each option
		SetImageFont( menu_font )
		cx :+ border_width + margin; cy :+ border_width + 2*margin + text_height_factor*GetImageFont().Height()
		For Local i% = 0 To options.Length-1
			'set font for option
			If is_scrollable( menu_type ) And i >= static_option_count
				SetImageFont( menu_font_small )
				If i = static_option_count
					SetColor( 64, 64, 64 )
					SetLineWidth( border_width )
					DrawLine( cx - border_width - margin, cy, cx - 2*border_width - margin + width, cy )
					cy :+ 0.5*( text_height_factor*GetImageFont().Height() + margin )
				End If
			Else
				SetImageFont( menu_font )
			End If
			opt = options[i]
			If opt.visible And option_is_in_window( i )
				If opt <> Null
					Local rgb_val%, glow% = False
					If i = focus
						rgb_val = 255
						glow = True
					Else If opt.enabled And opt.visible
						rgb_val = 127
					Else If opt.visible
						rgb_val = 64
					End If
					'draw the option
					opt.draw( resolve_meta_variables( opt.name ), cx,cy, glow, rgb_val,rgb_val,rgb_val ) 
				End If
				cy :+ text_height_factor*GetImageFont().Height() + margin
			End If
		Next
		
		'draw scrollable subsection visual cues
		If is_scrollable( menu_type )
			Local all_options_in_window% = True
			For Local i% = 0 To options.Length
				If Not option_is_in_window( i )
					all_options_in_window = False
					Exit
				End If
			Next
			If Not all_options_in_window
				draw_scrollbar( ..
					x + width - scrollbar_width, ..
					y + 3*margin + (1 + static_option_count)*(text_height_factor*title_font.Height()) + 1, ..
					scrollbar_width, ..
					height - (3*margin + 2*(text_height_factor*title_font.Height())), ..
					options.Length - static_option_count, ..
					scroll_offset, ..
					dynamic_options_displayed )
			End If
		End If
		
		If menu_type = TEXT_INPUT_DIALOG
			cx = x + margin
			cy = y + 2*margin + text_height_factor*title_font.Height()
			'draw input box contents
			SetColor( 255, 255, 255 )
			DrawText( input_box, cx, cy )
			cx :+ TextWidth( input_box )
			'draw implicit filename extension
			If preferred_file_extension.Length > 0
				SetColor( 127, 127, 127 )
				DrawText( "." + preferred_file_extension, cx, cy )
			End If
			'draw input cursor
			SetColor( 255, 255, 255 )
			SetAlpha( 0.5 + Sin(now() Mod 360) )
			DrawText( "|", cx - Int(TextWidth( "|" )/3), cy )
		End If
		
		'fade-out (used for menus which are "in the background")
		SetAlpha( dark_overlay_alpha )
		SetColor( 0, 0, 0 )
		DrawRect( x-border_width,y-border_width, width,height )

	End Method
	
	Method update( initial_update% = False )
		If initial_update
			focus = default_focus
		End If
		
		If menu_id = MENU_ID_MAIN_MENU
			'profile dependent options
			If profile <> Null 'loaded
				set_enabled( "loading bay", True )
				set_enabled( "save", True )
				set_enabled( "preferences", True )
			Else 'not loaded
				set_enabled( "loading bay", False )
				set_enabled( "save", False )
				set_enabled( "preferences", False )
			End If
			'main_game dependent options
			If main_game <> Null And main_game.game_in_progress 'main_game started
				set_enabled( "resume", True )
				set_enabled( "loading bay", False )
			Else
				set_enabled( "resume", False )
				'option "loading bay" setting unchanged
			End If
		End If

		If Not focus_is_valid()
			focus = default_focus
			If Not focus_is_valid()
				increment_focus()
			End If
		End If

		Select menu_type
			
			Case VERTICAL_LIST_WITH_FILES
				files = find_files( path, preferred_file_extension )
				Local new_options:MENU_OPTION[] = New MENU_OPTION[static_option_count + files.Count()]
				Local i%
				For i = 0 To static_option_count - 1
					new_options[i] = options[i]
				Next
				i = static_option_count
				For Local file$ = EachIn files
					new_options[i] = ..
						MENU_OPTION.Create( StripDir( file ), default_command, file, True, True )
					i :+ 1
				Next
				options = new_options
				
			Case TEXT_INPUT_DIALOG
				If initial_update
					options = [ MENU_OPTION.Create( str_repeat( " ", input_box_size ), default_command, input_box, True, True )]
					input_box = resolve_meta_variables( input_initial_value )
					FlushKeys()
				End If
				If preferred_file_extension.Length > 0
					options[0].argument = path + enforce_suffix( input_box, "." + preferred_file_extension )
				Else
					options[0].argument = path + input_box
				End If
				
			Case CONFIRMATION_DIALOG
				If initial_update
					options = ..
						[	MENU_OPTION.Create( "OK", default_command, default_argument, True, True ), ..
							MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True )]
					focus = 1
				End If
			
		End Select
	End Method
	
	Method focus_is_valid%()
		Local f_opt:MENU_OPTION = get_focus()
		Return f_opt <> Null And f_opt.visible And f_opt.enabled
	End Method
	Method get_focus:MENU_OPTION()
		If focus >= 0 And focus < options.Length
			Return options[focus]
		Else
			Return Null
		End If
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
	
	Method option_is_in_window%( index% )
		Return Not option_above_window( index ) And Not option_below_window( index )
	End Method
	Method option_above_window%( index% )
		Return index >= static_option_count And index < static_option_count + scroll_offset
	End Method
	Method option_below_window%( index% )
		Return index > static_option_count + scroll_offset + dynamic_options_displayed-1
	End Method
	
	Method increment_focus()
		move_focus( 1 )
	End Method
	Method decrement_focus()
		move_focus( -1 )
	End Method
	Method move_focus( direction% = 0 )
		'focused element (skip + wrap)
		Local count% = 0
		Repeat
			focus :+ Sgn( direction )
			wrap_focus()
			count :+ 1
		Until count >= options.Length Or focus_is_valid()
		'scrollable, dynamic window auto-scroll with focus change
		While option_below_window( focus )
			scroll_offset :+ 1
		End While
		While option_above_window( focus )
			scroll_offset :- 1
		End While
	End Method
	Method wrap_focus()
		If focus > (options.Length - 1)
			focus = 0
		Else If focus < 0
			focus = (options.Length - 1)
		End If
	End Method
	
End Type

Function is_scrollable%( menu_type% )
	Return (menu_type = MENU.VERTICAL_LIST_WITH_FILES Or menu_type = MENU.VERTICAL_LIST_WITH_SUBSECTION)
End Function

'______________________________________________________________________________
Const COMMAND_NULL% = 0
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_BACK_TO_MAIN_MENU% = 53
Const COMMAND_RESUME% = 100
Const COMMAND_SHOP% = 150
Const COMMAND_NEW_GAME% = 200
Const COMMAND_NEW_LEVEL% = 201
Const COMMAND_LOAD_GAME% = 300
Const COMMAND_LOAD_LEVEL% = 301
Const COMMAND_SAVE_GAME% = 400
Const COMMAND_SAVE_LEVEL% = 401
Const COMMAND_EDIT_LEVEL% = 500
Const COMMAND_PLAYER_INPUT_TYPE% = 1000
Const COMMAND_SETTINGS_FULLSCREEN% = 1010
Const COMMAND_SETTINGS_RESOLUTION% = 1020
Const COMMAND_SETTINGS_REFRESH_RATE% = 1030
Const COMMAND_SETTINGS_BIT_DEPTH% = 1040
Const COMMAND_SETTINGS_APPLY_ALL% = 1100
Const COMMAND_QUIT_GAME% = 65535

Const MENU_ID_MAIN_MENU% = 100
Const MENU_ID_NEW_GAME% = 200
Const MENU_ID_LOAD_GAME% = 300
Const MENU_ID_CONFIRM_LOAD_GAME% = 310
Const MENU_ID_LOAD_LEVEL% = 310
Const MENU_ID_SAVE_GAME% = 400
Const MENU_ID_INPUT_GAME_FILE_NAME% = 410
Const MENU_ID_SAVE_LEVEL% = 450
Const MENU_ID_INPUT_LEVEL_FILE_NAME% = 460
Const MENU_ID_CONFIRM_ERASE_LEVEL% = 470
Const MENU_ID_SETTINGS% = 500
Const MENU_ID_PREFERENCES% = 505
Const MENU_ID_OPTIONS_VIDEO% = 510
Const MENU_ID_CHOOSE_RESOLUTION% = 511
Const MENU_ID_INPUT_REFRESH_RATE% = 512
Const MENU_ID_INPUT_BIT_DEPTH% = 513
Const MENU_ID_OPTIONS_AUDIO% = 520
Const MENU_ID_OPTIONS_CONTROLS% = 530
Const MENU_ID_OPTIONS_GAME% = 540
Const MENU_ID_EDITORS% = 600
Const MENU_ID_LEVEL_EDITOR% = 610

Global menu_margin% = 8
Global dynamic_subsection_window_size% = 8
Global all_menus:MENU[50]
reset_index()

all_menus[postfix_index()] = MENU.Create( "main menu", 255, 255, 127, MENU_ID_MAIN_MENU, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, False ), ..
	MENU_OPTION.Create( "loading bay", COMMAND_SHOP,, True, False ), ..
	MENU_OPTION.Create( "new", COMMAND_NEW_GAME,, True, True ), ..
	MENU_OPTION.Create( "save", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_GAME), True, False ), ..
	MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_GAME), True, True ), ..
	MENU_OPTION.Create( "settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SETTINGS), True, True ), ..
	MENU_OPTION.Create( "preferences", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_PREFERENCES), True, False ), ..
	MENU_OPTION.Create( "editors", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_EDITORS), True, True ), ..
	MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ])
	
	all_menus[postfix_index()] = MENU.Create( "save game", 255, 96, 127, MENU_ID_SAVE_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND_SAVE_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "new file", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_GAME_FILE_NAME), True, True )])

		all_menus[postfix_index()] = MENU.Create( "input filename", 255, 255, 255, MENU_ID_INPUT_GAME_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, user_path, saved_game_file_ext, COMMAND_SAVE_GAME,, 60, "%%profile.profile_name%%"  )
	
	all_menus[postfix_index()] = MENU.Create( "load game", 96, 255, 127, MENU_ID_LOAD_GAME, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, user_path, saved_game_file_ext, COMMAND_LOAD_GAME,,,, dynamic_subsection_window_size, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])

		'all_menus[postfix_index()] = MENU.Create( "abandon current game?", 255, 64, 64, MENU_ID_CONFIRM_LOAD_GAME, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,,, COMMAND_LOAD_GAME )

	all_menus[postfix_index()] = MENU.Create( "settings", 127, 127, 255, MENU_ID_SETTINGS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "video settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_VIDEO), True, True ), ..
		MENU_OPTION.Create( "audio settings", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_AUDIO), True, False ) ])

	all_menus[postfix_index()] = MENU.Create( "preferences", 64, 64, 212, MENU_ID_PREFERENCES, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "controls", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_CONTROLS), True, True ), ..
		MENU_OPTION.Create( "gameplay", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_OPTIONS_GAME), True, False ) ])

		all_menus[postfix_index()] = MENU.Create( "video settings", 212, 96, 226, MENU_ID_OPTIONS_VIDEO, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "fullscreen    %%fullscreen%%", COMMAND_SETTINGS_FULLSCREEN,, True, True ), ..
			MENU_OPTION.Create( "resolution    %%window_w%% x %%window_h%%", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CHOOSE_RESOLUTION), True, True ), ..
			MENU_OPTION.Create( "refresh rate  %%refresh_rate%% Hz", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_REFRESH_RATE), True, True ), ..
			MENU_OPTION.Create( "bit depth     %%bit_depth%% bpp", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_BIT_DEPTH), True, True ), ..
			MENU_OPTION.Create( "apply", COMMAND_SETTINGS_APPLY_ALL,, False, False ) ])
			
			all_menus[postfix_index()] = MENU.Create( "choose resolution", 255, 255, 255, MENU_ID_CHOOSE_RESOLUTION, MENU.VERTICAL_LIST_WITH_SUBSECTION, menu_margin,,,,,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
			Local m:MENU = get_menu(MENU_ID_CHOOSE_RESOLUTION)
			m.static_option_count = 1
			Local modes:TGraphicsMode[] = GraphicsModes()
			For Local i% = 0 To modes.Length-1
				Local unique% = True
				For Local j% = 0 To m.options.Length-1
					Local opt:MENU_OPTION = m.options[j]
					If i > 0
						Local arg%[]
						If Int[](opt.argument)
							arg = Int[](opt.argument)
							If arg[0] = modes[i].width And arg[1] = modes[i].height
								unique = False
								Exit
							End If
						End If
					End If
				Next
				If i = 0 Or unique
					m.add_option( MENU_OPTION.Create( "" + modes[i].width + " x " + modes[i].height, COMMAND_SETTINGS_RESOLUTION, [ modes[i].width, modes[i].height ], True, True ))
				End If
			Next
			
			all_menus[postfix_index()] = MENU.Create( "input refresh rate", 255, 255, 255, MENU_ID_INPUT_REFRESH_RATE, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_REFRESH_RATE,, 10, "%%refresh_rate%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "input bit depth", 255, 255, 255, MENU_ID_INPUT_BIT_DEPTH, MENU.TEXT_INPUT_DIALOG, menu_margin,,,, COMMAND_SETTINGS_BIT_DEPTH,, 10, "%%bit_depth%%"  )
		
		all_menus[postfix_index()] = MENU.Create( "control options", 127, 196, 255, MENU_ID_OPTIONS_CONTROLS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(INPUT_KEYBOARD), True, True ), ..
			MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(INPUT_KEYBOARD_MOUSE_HYBRID), True, True ), ..
			MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INTEGER.Create(INPUT_XBOX_360_CONTROLLER), True, False ) ])
	
	all_menus[postfix_index()] = MENU.Create( "editors", 196, 196, 196, MENU_ID_EDITORS, MENU.VERTICAL_LIST, menu_margin,,,,,,,,, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "level editor", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LEVEL_EDITOR), True, True ) ])
		
		all_menus[postfix_index()] = MENU.Create( "level editor", 96, 127, 255, MENU_ID_LEVEL_EDITOR, MENU.VERTICAL_LIST, menu_margin, 1,,,,,,,, ..
		[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
			MENU_OPTION.Create( "edit %%level_editor_cache.name%%", COMMAND_EDIT_LEVEL, level_editor_cache, True, True ), ..
			MENU_OPTION.Create( "save", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_SAVE_LEVEL), True, True ), ..
			MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_LOAD_LEVEL), True, True ), ..
			MENU_OPTION.Create( "new", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_CONFIRM_ERASE_LEVEL), True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "save level", 255, 96, 127, MENU_ID_SAVE_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, data_path, level_file_ext, COMMAND_SAVE_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
				MENU_OPTION.Create( "new file", COMMAND_SHOW_CHILD_MENU, INTEGER.Create(MENU_ID_INPUT_LEVEL_FILE_NAME), True, True )])
				
				all_menus[postfix_index()] = MENU.Create( "input filename", 255, 255, 255, MENU_ID_INPUT_LEVEL_FILE_NAME, MENU.TEXT_INPUT_DIALOG, menu_margin,, data_path, level_file_ext, COMMAND_SAVE_LEVEL,, 60, "%%level_editor_cache.name%%"  )
			
			all_menus[postfix_index()] = MENU.Create( "load level", 96, 255, 127, MENU_ID_LOAD_LEVEL, MENU.VERTICAL_LIST_WITH_FILES, menu_margin,, data_path, level_file_ext, COMMAND_LOAD_LEVEL,,,, dynamic_subsection_window_size, ..
			[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ) ])
			
			all_menus[postfix_index()] = MENU.Create( "abandon current level?", 255, 64, 64, MENU_ID_CONFIRM_ERASE_LEVEL, MENU.CONFIRMATION_DIALOG, menu_margin, 1,,, COMMAND_NEW_LEVEL )
'______________________________________________________________________________
Global menu_stack%[] = New Int[255]
	menu_stack[0] = MENU_ID_MAIN_MENU
Global current_menu% = 0

Function get_current_menu:MENU()
	Return get_menu( menu_stack[current_menu] )
End Function

Function get_main_menu:MENU()
	Return get_menu( menu_stack[0] )
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
			get_current_menu().update( True )
			
		Case COMMAND_BACK_TO_PARENT_MENU
			If current_menu > 0 Then current_menu :- 1
			get_current_menu().update()
			
		Case COMMAND_BACK_TO_MAIN_MENU
			current_menu = 0
			get_main_menu().update()
			
		
		Case COMMAND_RESUME
			FLAG_in_menu = False
			
		Case COMMAND_SHOP
			FLAG_in_menu = False
			FLAG_in_shop = True
		
		Case COMMAND_NEW_GAME
			profile = New PLAYER_PROFILE
			get_main_menu().update()
			
		Case COMMAND_LOAD_GAME
			profile = load_game( String(argument) )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			get_main_menu().update()
				
		Case COMMAND_SAVE_GAME
			save_game( String(argument), profile )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		
		
		Case COMMAND_NEW_LEVEL
			level_editor_cache = Create_LEVEL( 300, 300 )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )

		Case COMMAND_LOAD_LEVEL
			level_editor_cache = load_level( String(argument) )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			
		Case COMMAND_SAVE_LEVEL
			save_level( String(argument), level_editor_cache )
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			
		
		Case COMMAND_PLAYER_INPUT_TYPE
			If profile <> Null
				profile.input_method = INTEGER(argument).value
			End If
			If game <> Null And game.player_brain <> Null
				game.player_brain.input_type = profile.input_method
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		
		
		Case COMMAND_SETTINGS_FULLSCREEN
			fullscreen = Not fullscreen
			save_settings()
			init_graphics()
			
		Case COMMAND_SETTINGS_RESOLUTION
			window_w = Int[](argument)[0]
			window_h = Int[](argument)[1]
			save_settings()
			init_graphics()
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		
		Case COMMAND_SETTINGS_REFRESH_RATE
			Local new_refresh_rate% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, bit_depth, new_refresh_rate )
				refresh_rate = new_refresh_rate
				save_settings()
				init_graphics()
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
		
		Case COMMAND_SETTINGS_BIT_DEPTH
			Local new_bit_depth% = String(argument).ToInt()
			If GraphicsModeExists( window_w, window_h, new_bit_depth, refresh_rate )
				bit_depth = new_bit_depth
				save_settings()
				init_graphics()
			End If
			menu_command( COMMAND_BACK_TO_PARENT_MENU )
			
		Case COMMAND_SETTINGS_APPLY_ALL
			save_settings()
			init_graphics()
		
		
		Case COMMAND_EDIT_LEVEL
			level_editor( level_editor_cache )
			
		
		Case COMMAND_QUIT_GAME
			End
			
	End Select
End Function

Function status( msg$ )
	
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
				Case "profile.profile_name"
					result :+ profile.profile_name
				Case "fullscreen"
					result :+ boolean_to_string( fullscreen )
				Case "window_w"
					result :+ window_w
				Case "window_h"
					result :+ window_h
				Case "refresh_rate"
					result :+ refresh_rate
				Case "bit_depth"
					result :+ bit_depth
			End Select
		Else 'even (string literal)
			result :+ tokens[i]
		End If
	Next
	Return result
End Function




