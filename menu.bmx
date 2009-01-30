Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const border_width% = 1
Const scrollbar_width% = 20

Type MENU
	Const VERTICAL_LIST% = 10
	Const VERTICAL_LIST_WITH_SUBSECTION% = 11
	Const VERTICAL_LIST_WITH_FILES% = 12
	Const TEXT_INPUT_DIALOG% = 20
	Const CONFIRMATION_DIALOG% = 21
	Const NOTIFICATION_DIALOG% = 22
	
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
	Field width%, height% 'cached dimensions
	Field dimensions_cached% 'flag
	Field red%, green%, blue% 'title bar color
	Field margin% 'visual margin (pixels)
	
	Field options:MENU_OPTION[] 'array of options in this menu
	Field bounding_box:BOX[] 'array of boxes around potentially selectable options
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
	
	Field last_x%, last_y% 'record of last drawn coordinates, for input processing
	
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
		m.default_focus = default_focus
		m.focus = default_focus
		m.dynamic_options_displayed = dynamic_options_displayed
		m.path = path
		m.preferred_file_extension = preferred_file_extension
		m.default_command = default_command
		m.default_argument = default_argument
		m.input_box = ""
		m.input_box_size = input_box_size
		m.input_listener = New CONSOLE
		m.input_initial_value = input_initial_value
		For Local opt:MENU_OPTION = EachIn options
			m.add_option( opt, True )
		Next
		Return m
	End Function
	
	Method execute_current_option()
		Local opt:MENU_OPTION = get_focus()
		menu_command( opt.command_code, opt.argument )
	End Method
	
	Method add_option( opt:MENU_OPTION, is_static% = False )
		If options = Null
			options = New MENU_OPTION[1]
			options[0] = opt
			bounding_box = New BOX[1]
		Else
			options = options[..options.Length+1]
			options[options.Length-1] = opt
			bounding_box = bounding_box[..bounding_box.Length+1]
		End If
		If is_static Then static_option_count :+ 1
	End Method
	
	Method purge_all_options()
		options = Null
		static_option_count = 0
	End Method
	
	Method purge_dynamic_options()
		If options <> Null
			options = options[..static_option_count]
		End If
	End Method
	
	Method draw( x%, y%, border% = True, dark_overlay_alpha# = 0 )
		last_x = x; last_y = y
		Local cx% = x, cy% = y, opt:MENU_OPTION
		Local text_height_factor# = 0.70
		'calculate dimensions
		If Not dimensions_cached
			calculate_dimensions( text_height_factor )
		End If
		'draw the borders, backgrounds and title text
		SetImageFont( title_font )
		If border
			SetAlpha( 1 )
			SetColor( 64, 64, 64 )
			DrawRectLines( cx,cy, width,height )
			SetAlpha( 0.3333 )
			SetColor( 0, 0, 0 )
			DrawRect( cx+border_width,cy+border_width, width-2*border_width,height-2*border_width )
			SetColor( red/4, green/4, blue/4 )
			SetAlpha( 1 )
			DrawRect( cx+border_width,cy+border_width, width-2*border_width,text_height_factor*GetImageFont().Height() + margin )
			SetColor( red, green, blue )
			DrawText_with_outline( name, cx+border_width+margin,cy+border_width+margin/2 )
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
			If opt <> Null And opt.visible And option_is_in_window( i )
				Local name$ = resolve_meta_variables( opt.name )
				opt.draw( name, cx, cy, (focus = i) )
				bounding_box[i] = Create_BOX( last_x, cy, width, TextHeight( name ))
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
					y + 3*margin + (1 + static_option_count)*(text_height_factor*title_font.Height()) + 0, ..
					scrollbar_width, ..
					height - (3*margin + 2*(text_height_factor*title_font.Height())) + 1, ..
					options.Length - static_option_count, ..
					scroll_offset, ..
					dynamic_options_displayed )
			End If
		End If
		'text input stuff
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
	
	Method calculate_dimensions( text_height_factor# = 1.0 )
		dimensions_cached = True
		width = 0
		height = 0
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
	End Method
	
	Method recalculate_dimensions() 'forces a re-calculation of the window dimensions at the next draw step
		Self.dimensions_cached = False
	End Method
	
	Method update( initial_update% = False )
		If initial_update
			focus = default_focus
		End If
		
		If menu_id = MENU_ID_MAIN_MENU
			'profile dependent options
			If profile <> Null 'loaded
				enable_option( "loading bay" )
				enable_option( "save" )
				enable_option( "multiplayer" )
				enable_option( "preferences" )
			Else 'not loaded
				disable_option( "loading bay" )
				disable_option( "save" )
				disable_option( "multiplayer" )
				disable_option( "preferences" )
			End If
			'main_game dependent options
			If main_game <> Null And main_game.game_in_progress 'main_game started
				enable_option( "resume" )
			Else
				disable_option( "resume" )
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
				purge_dynamic_options()
				For Local file$ = EachIn find_files( path, preferred_file_extension )
					add_option( MENU_OPTION.Create( StripDir( file ), default_command, file, True, True ))
				Next
				
			Case TEXT_INPUT_DIALOG
				If initial_update
					add_option( MENU_OPTION.Create( str_repeat( " ", input_box_size ), default_command, input_box, True, True ))
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
					purge_all_options()
					add_option( MENU_OPTION.Create( "OK", default_command, default_argument, True, True ), True )
					add_option( MENU_OPTION.Create( "cancel", COMMAND_BACK_TO_PARENT_MENU,, True, True ), True )
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
	Method enable_option( key$ )
		Local i% = find_option( key )
		If i <> -1 Then options[i].enabled = True
	End Method
	Method disable_option( key$ )
		Local i% = find_option( key )
		If i <> -1 Then options[i].enabled = False
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
	
	Method select_by_coords%( x%, y% )
		Local opt_box:BOX
		For Local i% = 0 To bounding_box.Length - 1
			opt_box = bounding_box[i]
			If opt_box <> Null ..
			And x >= opt_box.x And x <= opt_box.x + opt_box.w ..
			And y >= opt_box.y And y <= opt_box.y + opt_box.h
				If options[i].visible And options[i].enabled And menu_type <> TEXT_INPUT_DIALOG
					focus = i
					Return True
				Else
					Return False
				End If
			End If
		Next
		Return False
	End Method
	
End Type

Function is_scrollable%( menu_type% )
	Return (menu_type = MENU.VERTICAL_LIST_WITH_FILES Or menu_type = MENU.VERTICAL_LIST_WITH_SUBSECTION)
End Function




