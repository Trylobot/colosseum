Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "menu_option.bmx"
'Import "player_profile.bmx"
'Import "box.bmx"
'Import "console.bmx"
'Import "inventory_data.bmx"
'Import "constants.bmx"
'Import "misc.bmx"
'Import "draw_misc.bmx"

'______________________________________________________________________________
Const border_width% = 1
Const scrollbar_width% = 20
Const text_height_factor# = 0.70
Const breadcrumb_h% = 14

'these need to go away, kind of a hack
Const main_screen_x% = 25
Const main_screen_y% = 15

Const main_screen_menu_y% = 30

Type MENU
	Const VERTICAL_LIST% = 10
	Const VERTICAL_LIST_WITH_SUBSECTION% = 11
	Const VERTICAL_LIST_WITH_FILES% = 12
	Const VERTICAL_LIST_WITH_INVENTORY% = 13
	Const TEXT_INPUT_DIALOG% = 20
	Const CONFIRMATION_DIALOG% = 21
	Const NOTIFICATION_DIALOG% = 22
	
	Global title_font:BMP_FONT
	Global menu_font:BMP_FONT
	Global menu_font_small:BMP_FONT
	Global title_font_bg:BMP_FONT
	Global menu_font_bg:BMP_FONT
	Global menu_font_small_bg:BMP_FONT

	Field id% 'unique menu id
	Field menu_type% 'menu class
	
	Field name$ 'menu title string
	Field short_name$
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
	Field autoscroll% 'whether to automatically scroll the scrollbar
	
	Field last_x%, last_y% 'record of last drawn coordinates, for input processing
	
	Method New()
		files = CreateList()
	End Method
	
	'___________________________________________
	Function Create:MENU( ..
	name$, short_name$, ..
	red%, green%, blue%, ..
	id%, menu_type%, ..
	margin%, default_focus% = -1, ..
	path$ = "", preferred_file_extension$ = "", default_command% = -1, default_argument:Object = Null, ..
	input_box_size% = 0, input_initial_value$ = "", ..
	dynamic_options_displayed% = 1, ..
	options:MENU_OPTION[] = Null )
		Local m:MENU = New MENU
		m.name = name; m.short_name = short_name
		m.red = red; m.green = green; m.blue = blue
		m.id = id
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
		m.autoscroll = False
		Return m
	End Function
	
	'___________________________________________
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
	
	'___________________________________________
	Method purge_all_options()
		options = Null
		static_option_count = 0
	End Method
	
	'___________________________________________
	Method purge_dynamic_options()
		If options <> Null
			options = options[..static_option_count]
		End If
	End Method
	
	'___________________________________________
	Method draw( mouse:POINT, dragging_scrollbar%, border% = True, dark_overlay_alpha# = 0, blink% = True, hide_selection% = False )
		Local cx% = main_screen_x
		Local cy% = main_screen_menu_y + breadcrumb_h - 1
		last_x = cx
		last_y = cy
		Local opt:MENU_OPTION
		'calculate dimensions
		If Not dimensions_cached
			calculate_dimensions()
		End If
		'draw the borders, backgrounds and title text
		'SetImageFont( title_font )
		If border
			SetAlpha( 1 )
			SetColor( 127, 127, 127 )
			DrawRectLines( cx,cy, width,height )
			SetAlpha( 0.3333 )
			SetColor( 0, 0, 0 )
			DrawRect( cx+border_width,cy+border_width, width-2*border_width,height-2*border_width )
			SetColor( red/4, green/4, blue/4 )
			SetAlpha( 1 )
			DrawRect( cx+border_width,cy+border_width, width-2*border_width,text_height_factor*title_font.height + margin )
			'SetColor( red, green, blue )
			Local dynamic_name$ = resolve_meta_variables( name )
			'DrawText_with_outline( dynamic_name, cx+border_width+margin,cy+border_width+margin/2 )
			Local bg% = 0
			draw_layered_string( dynamic_name, cx+border_width+margin,cy+border_width+margin/2, title_font, title_font_bg, red,green,blue, bg,bg,bg )
		End If
		'draw each option
		'SetImageFont( menu_font )
		cx :+ border_width + margin
		cy :+ border_width + 2*margin + text_height_factor*menu_font.height
		Local focused%
		For Local i% = 0 To options.Length-1
			'set font for option
			Local f:BMP_FONT, normal_size%
			If is_scrollable( menu_type ) And i >= static_option_count
				f = menu_font_small
				normal_size = False
				'SetImageFont( menu_font_small )
				If i = static_option_count And static_option_count > 0
					SetColor( 64, 64, 64 )
					SetLineWidth( border_width )
					DrawLine( cx - margin, cy, cx - 4*border_width - margin + width, cy )
					cy :+ margin
				End If
			Else
				f = menu_font
				normal_size = True
				'SetImageFont( menu_font )
			End If
			opt = options[i]
			If opt <> Null And opt.visible And option_is_in_window( i )
				Local name$ = resolve_meta_variables( opt.name, opt.argument )
				focused = (focus = i And Not hide_selection)
				'////////////////////////////////////////////////////
				draw_option( opt, normal_size, name, cx, cy, focused, blink )
				'////////////////////////////////////////////////////
				SetAlpha( 1 )
				cy :+ text_height_factor*f.height + margin
			End If
		Next
		'draw scrollable subsection visual cues
		If is_scrollable( menu_type ) And Not all_options_in_window()
			If KeyDown( KEY_F4 ) DebugStop
			Local scrollbar_rect:BOX = get_scrollbar_rect( last_x, last_y )
			Local color% = 127
			If dragging_scrollbar ..
			Or (mouse.pos_x >= scrollbar_rect.x And mouse.pos_x <= scrollbar_rect.x + scrollbar_rect.w ..
			And mouse.pos_y >= scrollbar_rect.y And mouse.pos_y <= scrollbar_rect.y + scrollbar_rect.h)
				color = 220
			End If
			draw_scrollbar( ..
				scrollbar_rect.x, scrollbar_rect.y, ..
				scrollbar_rect.w, scrollbar_rect.h, ..
				options.Length - static_option_count, ..
				scroll_offset, ..
				dynamic_options_displayed, ..
				color, color, color )
		End If
		'text input stuff
		If menu_type = TEXT_INPUT_DIALOG
			cx = last_x + margin
			cy = last_y + 2*margin + text_height_factor*title_font.height
			'draw input box contents
			'SetColor( 255, 255, 255 )
			'DrawText( input_box, cx, cy )
			Local fg% = 255, bg% = 0
			draw_layered_string( input_box, cx, cy, menu_font, menu_font_bg, fg,fg,fg, bg,bg,bg )
			cx :+ menu_font.width( input_box )
			'draw implicit filename extension
			If preferred_file_extension.Length > 0
				'SetColor( 127, 127, 127 )
				'DrawText( "." + preferred_file_extension, cx, cy )
				fg = 127
				draw_layered_string( "." + preferred_file_extension, cx, cy, menu_font, menu_font_bg, fg,fg,fg, bg,bg,bg )
			End If
			'draw input cursor
			'SetColor( 255, 255, 255 )
			fg = 255
			SetAlpha( 0.5 + Sin(now() Mod 360) )
			'DrawText( "|", cx - Int(TextWidth( "|" )/3), cy )
			draw_layered_string( "|", cx - Int(TextWidth( "|" )/3), cy, menu_font, menu_font_bg, fg,fg,fg, bg,bg,bg )
		End If
		'fade-out (used for menus which are "in the background")
		SetAlpha( dark_overlay_alpha )
		SetColor( 0, 0, 0 )
		DrawRect( last_x-border_width,last_y-border_width, width+1,height+1 )
	End Method
	
	Method draw_option( opt:MENU_OPTION, normal_size%, resolved_name$, x%, y%, focused% = False, blink% = True )
		Local mult# = 1.0, glow% = False
		SetAlpha( 1 )
		If Not opt.always_bright
			If focused
				glow = True
				If blink Then SetAlpha( 0.75 + 0.25 * Sin( now() Mod 1000 ))
			Else If opt.enabled And opt.visible 'Not focused
				mult = 0.5
			Else If opt.visible 'Not enabled And Not focused
				mult = 0.25
			End If
		End If
		'draw the option
		'SetColor( opt.red*mult, opt.green*mult, opt.blue*mult )
		Local bg%
		If glow
			'DrawText_with_glow( resolved_name, x, y )
			bg = 100
		Else
			'DrawText_with_outline( resolved_name, x, y )
			bg = 32
		End If
		Local fg_font:BMP_FONT
		Local bg_font:BMP_FONT
		If normal_size
			fg_font = menu_font
			bg_font = menu_font_bg
		Else
			fg_font = menu_font_small
			bg_font = menu_font_small_bg
		End If
		draw_layered_string( resolved_name, x, y, fg_font, bg_font, opt.red*mult, opt.green*mult, opt.blue*mult, bg,bg,bg )
	End Method
	
	'___________________________________________
	Method calculate_bounding_boxes()
		Local cx% = main_screen_x
		Local cy% = main_screen_menu_y + breadcrumb_h - 1
		last_x = cx
		last_y = cy
		Local opt:MENU_OPTION
		If Not dimensions_cached
			calculate_dimensions()
		End If
		'SetImageFont( menu_font )
		cx :+ border_width + margin
		cy :+ border_width + 2*margin + text_height_factor*menu_font.height
		For Local i% = 0 To options.Length-1
			'set font for option
			Local f:BMP_FONT
			If is_scrollable( menu_type ) And i >= static_option_count
				'SetImageFont( menu_font_small )
				f = menu_font_small
				If i = static_option_count And static_option_count > 0
					cy :+ margin
				End If
			Else
				'SetImageFont( menu_font )
				f = menu_font
			End If
			opt = options[i]
			If opt <> Null And opt.visible And option_is_in_window( i )
				Local name$ = resolve_meta_variables( opt.name, opt.argument )
				bounding_box[i] = Create_BOX( last_x, cy, width, f.height)
				cy :+ text_height_factor*f.height + margin
			End If
		Next
	End Method
	
	'___________________________________________
	Method header_height%()
		Return text_height_factor*title_font.height + margin
	End Method
	
	Method static_option_height%()
		Return text_height_factor*menu_font.height + margin 
	End Method
	
	Method dynamic_option_height%()
		Return text_height_factor*menu_font_small.height + margin 
	End Method
	
	Method calculate_dimensions()
		dimensions_cached = True
		width = 0
		height = 0
		Local i% = 0
		For Local opt:MENU_OPTION = EachIn options
			Local f:BMP_FONT
			If is_scrollable( menu_type ) And i >= static_option_count
				'SetImageFont( menu_font_small )
				f = menu_font_small
				If i = static_option_count And static_option_count > 0
					height :+ margin
				End If
			Else
				f = menu_font
				'SetImageFont( menu_font )
			End If
			Local opt_name_dynamic$ = resolve_meta_variables( opt.name, opt.argument )
			If (2*margin + f.width( opt_name_dynamic ) + 2*border_width) > width
				width = (2*margin + f.width( opt_name_dynamic ) + 2*border_width)
			End If
			If opt <> Null And opt.visible And option_is_in_window( i )
				height :+ (text_height_factor*f.height + margin)
			End If
			i :+ 1
		Next
		'SetImageFont( menu_font )
		Local dynamic_name$ = resolve_meta_variables( name )
		If (2*margin + menu_font.width( dynamic_name ) + 2*border_width) > width
			width = (2*margin + menu_font.width( dynamic_name ) + 2*border_width)
		End If
		If is_scrollable( menu_type )
			width :+ scrollbar_width
		End If
		height :+ (margin + (text_height_factor*menu_font.height + margin) + 2*border_width)
		dynamic_options_displayed = (window_h - 2*main_screen_menu_y - main_screen_y - (text_height_factor*menu_font.height + margin)*(static_option_count + 1)) / (text_height_factor*menu_font_small.height + margin)
	End Method
	
	'___________________________________________
	Method recalculate_dimensions() 'forces a re-calculation of the window dimensions at the next draw step
		Self.dimensions_cached = False
	End Method
	
	'___________________________________________
	Method update( initial_update% = False )
		If initial_update
			focus = default_focus
		End If
		
		If id = MENU_ID.MAIN_MENU
			If profile
				enable_option( "play game" )
			Else
				disable_option( "play game" )
			End If
		Else If id = MENU_ID.PROFILE_MENU
			If profile
				set_command( "create new profile", COMMAND.SHOW_CHILD_MENU )
				enable_option( "save" )
				set_name( "save", "save • %%profile.name%%" )
				enable_option( "preferences" )
			Else
				set_command( "create new profile", COMMAND.NEW_GAME )
				disable_option( "save" )
				set_name( "save", "save" )
				disable_option( "preferences" )
			End If
		End If
		
		Select menu_type
			
			Case VERTICAL_LIST_WITH_FILES
				purge_dynamic_options()
				For Local file$ = EachIn find_files( path, preferred_file_extension )
					add_option( MENU_OPTION.Create( file, default_command, file, True, True ))
				Next
				recalculate_dimensions()
			
			Case VERTICAL_LIST_WITH_INVENTORY
				purge_dynamic_options()
				Local items:TList = CreateList()
				'create a list of inventory items using the path to indicate the source
				Select path
					Case "catalog"
						'For Local item:INVENTORY_DATA = Eachin map_keys( item_map )
						'	items.AddLast( item )
						'Next
					Case "inventory"
						For Local item:INVENTORY_DATA = EachIn profile.inventory
							items.AddLast( item )
						Next
				End Select
				'build the menu options from the list
				For Local item:INVENTORY_DATA = EachIn items
					Local enabled%
					Select path
						Case "catalog"
							enabled = profile.can_buy( item )
						Case "inventory"
							enabled = True
					End Select
					Local r% = 255, g% = 255, b% = 255
					'Select item.item_type
						
					'End Select
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
					add_option( MENU_OPTION.Create( "cancel", COMMAND.BACK_TO_PARENT_MENU,, True, True ), True )
					focus = 1
				End If
				
			Case NOTIFICATION_DIALOG
				If initial_update
					purge_all_options()
					add_option( MENU_OPTION.Create( "OK", default_command, default_argument, True, True ), True )
					focus = 0
				End If
			
		End Select
		
		'invalid focus
		If Not focus_is_valid()
			focus = default_focus
			If Not focus_is_valid()
				increment_focus()
			End If
		End If
		
		'check if scroll window is too far down
		While (static_option_count + scroll_offset + dynamic_options_displayed) > options.Length
			scroll_offset :- 1
		End While
		If scroll_offset < 0 Then scroll_offset = 0
		If autoscroll Then center_scrolling_window()
		
	End Method
	
	'___________________________________________
	Method get_focus_offset%()
		Local focus_offset% = 0
		'title
		focus_offset :+ margin + (text_height_factor*menu_font.height + margin) + 2*border_width
		'each option
		For Local i% = 0 Until focus 'skip the last option
			If options[i].visible And option_is_in_window( i )
				If i < static_option_count
					focus_offset :+ text_height_factor*menu_font.height + margin
				Else
					focus_offset :+ text_height_factor*menu_font_small.height + margin
				End If
			End If
		Next
		Return focus_offset
	End Method
	
	'___________________________________________
	Method focus_is_valid%()
		Local f_opt:MENU_OPTION = get_focus()
		Return (f_opt And f_opt.visible And f_opt.enabled)
	End Method
	'___________________________________________
	Method get_focus:MENU_OPTION()
		If focus >= 0 And focus < options.Length
			Return options[focus]
		Else
			Return Null
		End If
	End Method
	'___________________________________________
	Method set_focus( key$ )
		Local i% = find_option( key )
		If i <> -1 Then focus = i
	End Method
	'___________________________________________
	Method enable_option( key$ )
		Local i% = find_option( key )
		If i <> -1 Then options[i].enabled = True
	End Method
	'___________________________________________
	Method disable_option( key$ )
		Local i% = find_option( key )
		If i <> -1 Then options[i].enabled = False
	End Method
	'___________________________________________
	Method find_option%( key$ )
		key = key.ToLower()
		For Local i% = 0 To options.Length - 1
			If options[i].name.ToLower().Find( key ) <> -1 'key found
				Return i
			End If
		Next
		Return -1
	End Method
	
	'___________________________________________
	Method set_command( key$, new_command_code% )
		Local index% = find_option( key )
		If index >= 0 Then options[index].command_code = new_command_code
	End Method
	'___________________________________________
	Method set_name( key$, new_name$ )
		Local index% = find_option( key )
		If index >= 0 Then options[index].name = new_name
	End Method
	
	'___________________________________________
	Method all_options_in_window%()
		For Local i% = 0 Until options.Length
			If Not option_is_in_window( i )
				Return False
			End If
		Next
		Return True
	End Method
	'___________________________________________
	Method option_is_in_window%( index% )
		Return index < static_option_count Or ..
			(index >= static_option_count + scroll_offset And ..
			index < static_option_count + scroll_offset + dynamic_options_displayed)
	End Method
	'___________________________________________
	Method option_above_window%( index% )
		Return index >= static_option_count And index < static_option_count + scroll_offset
	End Method
	'___________________________________________
	Method option_below_window%( index% )
		Return index > static_option_count + scroll_offset + dynamic_options_displayed - 1
	End Method
	
	'___________________________________________
	Method increment_focus( wrap% = True )
		move_focus( 1, wrap )
	End Method
	'___________________________________________
	Method decrement_focus( wrap% = True )
		move_focus( -1, wrap )
	End Method
	'___________________________________________
	Method move_focus( direction% = 0, wrap% = True )
		'focused element (skip + wrap)
		Local count% = 0
		Repeat
			focus :+ Sgn( direction )
			wrap_focus()
			count :+ 1
		Until count >= options.Length Or focus_is_valid()
		center_scrolling_window()
	End Method
	'___________________________________________
	Method wrap_focus()
		If focus > (options.Length - 1)
			focus = 0
		Else If focus < 0
			focus = (options.Length - 1)
		End If
	End Method
	'___________________________________________
	Method center_scrolling_window()
		scroll_offset = focus - static_option_count - Float(dynamic_options_displayed)/2.0
		If scroll_offset < 0 Then scroll_offset = 0
		If scroll_offset > (options.Length - static_option_count - dynamic_options_displayed) Then scroll_offset = (options.Length - static_option_count - dynamic_options_displayed)
	End Method
	'___________________________________________
	Method set_focus_by_index( new_focus%, enable_autoscroll% = True )
		If new_focus >= 0 And new_focus < options.Length
			focus = new_focus
			'new focus is not visible or not enabled?
			If Not options[focus].visible Or Not options[focus].enabled
				Local max_focus% = options.Length - 1
				Local fd% = focus, fi% = focus 'feeler_increasing, feeler_decreasing
				While fd > 0 Or fi < max_focus
					'search outward from new focus
					If fd > 0
						fd :- 1
					End If
					If fi < max_focus
						fi :+ 1
					End If
					'new valid option found?
					If options[fd].visible And options[fd].enabled
						focus = fd
						Exit
					End If
					If options[fi].visible And options[fi].enabled
						focus = fi
						Exit
					End If
				End While
			End If
		End If
		If enable_autoscroll Then autoscroll = True
	End Method
	
	'___________________________________________
	Method select_by_coords%( x%, y%, disable_autoscroll% = True )
		Local opt_box:BOX
		For Local i% = 0 Until bounding_box.Length
			opt_box = bounding_box[i]
			If opt_box
				opt_box = opt_box.clone()
				If is_scrollable( menu_type ) And Not all_options_in_window()
					opt_box.w :- scrollbar_width
				End If
				If  x >= opt_box.x And x <= opt_box.x + opt_box.w ..
				And y >= opt_box.y And y <= opt_box.y + opt_box.h
					If i < options.Length And options[i].visible And options[i].enabled And menu_type <> TEXT_INPUT_DIALOG
						focus = i
						If disable_autoscroll Then autoscroll = False
						'DebugLog( " "+MENU_ID.decode( id ).ToLower()+" --> "+options[i].name )
						Return True
					Else
						Return False
					End If
				End If
			End If
		Next
		Return False
	End Method
	
	'___________________________________________
	Method hovering_on_scrollbar%( x%, y% )
		If is_scrollable( menu_type ) And Not all_options_in_window()
			Local scrollbar_rect:BOX = get_scrollbar_rect( last_x, last_y )
			If  x >= scrollbar_rect.x And x <= scrollbar_rect.x + scrollbar_rect.w ..
			And y >= scrollbar_rect.y And y <= scrollbar_rect.y + scrollbar_rect.h
				Return True
			End If
		End If
		Return False
	End Method
	
	'___________________________________________
	Method get_scrollbar_rect:BOX( menu_x%, menu_y% )
		Local x% = menu_x + width - scrollbar_width
		Local y% = menu_y + border_width + header_height() + static_option_count*static_option_height() + (static_option_count > 0)*margin
		Local w% = scrollbar_width
		Local scroll_item_count% =Min(dynamic_options_displayed, options.Length - static_option_count) 
		Local h% = scroll_item_count*dynamic_option_height() + margin + border_width
		Return Create_BOX( x, y, w, h )
	End Method
	
	'___________________________________________
	Function is_scrollable%( menu_type% )
		Return ..
			menu_type = MENU.VERTICAL_LIST_WITH_FILES Or ..
			menu_type = MENU.VERTICAL_LIST_WITH_SUBSECTION Or ..
			menu_type = MENU.VERTICAL_LIST_WITH_INVENTORY
	End Function
	
	Function is_popup%( menu_type% )
		Select menu_type
			Case TEXT_INPUT_DIALOG
				Return True
			Case CONFIRMATION_DIALOG
				Return True
			Case NOTIFICATION_DIALOG
				Return True
		End Select
		Return False
	End Function
	
	Function load_fonts()
		title_font = get_bmp_font( "arcade_21" )
		menu_font = get_bmp_font( "arcade_14" )
		menu_font_small = get_bmp_font( "arcade_7" )
		title_font_bg = get_bmp_font( "arcade_outline_21" )
		menu_font_bg = get_bmp_font( "arcade_outline_14" )
		menu_font_small_bg = get_bmp_font( "arcade_outline_7" )
	End Function

End Type

'______________________________________________________________________________
Function draw_scrollbar( x%, y%, w%, h%, total_size%, window_offset%, window_size%, r% = 64, g% = 64, b% = 64 )
	SetLineWidth( 1 )
	Local offset# = (h-2*border_width)*Float(window_offset)/Float(total_size)
	Local size# = (h-2*border_width)*Float(window_size)/Float(total_size)
	SetColor( r, g, b )
	SetAlpha( 1 )
	DrawRectLines( x, y, w, h )
	SetAlpha( 0.5 )
	SetColor( 0, 0, 0 )
	DrawRect( ..
		x+border_width, y+border_width, ..
		w-2*border_width, h-2*border_width )
	SetColor( r, g, b )
	SetAlpha( 1 )
	DrawRect( ..
		x+border_width + 1, y+border_width + offset + 1, ..
		w-2*border_width - 2, size - 2 )
End Function

'______________________________________________________________________________
Global meta_variable_cache:TMap

Function resolve_meta_variables$( str$, argument:Object = Null )
	Local tokens$[] = str.Split( "%%" )
	Local result$ = ""
	For Local i% = 0 To tokens.Length - 1
		If i Mod 2 = 0 'even; string literal
			result :+ tokens[i]
		Else If meta_variable_cache 'odd; inside a meta-variable identifier
			Local meta_var$ = String( meta_variable_cache.ValueForKey( tokens[i] ))
			If meta_var
				result :+ meta_var
			Else If tokens[i] = "profile.count_inventory(this)" And profile
				'This should not exist, really
				result :+ "x "+format_number( profile.count_inventory( INVENTORY_DATA(argument) ))
			End If
		End If
	Next
	Return result
End Function

