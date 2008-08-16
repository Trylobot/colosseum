Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const COMMAND_SHOW_CHILD_MENU% = 50
Const COMMAND_BACK_TO_PARENT_MENU% = 51
Const COMMAND_RESUME% = 100
Const COMMAND_NEW_GAME% = 101
Const COMMAND_LOAD_GAME% = 102
Const COMMAND_QUIT% = 400

Const COMMAND_ARGUMENT_NULL% = 0

Function menu_command( command_code%, command_argument% = COMMAND_ARGUMENT_NULL )
	Select command_code
		
		Case COMMAND_SHOW_CHILD_MENU
			
		Case COMMAND_BACK_TO_PARENT_MENU
			
		Case COMMAND_RESUME
			FLAG_in_menu = False
			FLAG_player_engine_running = True
			
		Case COMMAND_NEW_GAME
			player_type = PLAYER_INDEX_START + (command_index - 5)
			FLAG_in_menu = False
			reset_game()
			init_game()
			FLAG_game_in_progress = True
			
		Case COMMAND_LOAD_GAME
			
		Case COMMAND_QUIT_GAME
			End
			
	End Select
End Function
'______________________________________________________________________________
Global menu_font:TImageFont = get_font( "consolas_24" )

Type MENU_OPTION
	Field name$ 'display to user
	Field command_code% 'command to execute
	Field command_argument% 'integer parameter, has meaning in combination with command
	Field visible% 'draw this option? {true|false}
	Field enabled% 'can this option be selected? {true|false}
	
	Function Create:MENU_OPTION( name$, command_code%, command_argument% = COMMAND_ARGUMENT_NULL, visible% = True, enabled% = True )
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
	
	Method draw( x%, y% )
		DrawText( name, x, y )
	End Method
End Type
'______________________________________________________________________________
Const ARROW_LEFT% = 1
Const ARROW_RIGHT% = 2

Function draw_arrow( arrow_type%, x%, y% )
	Select arrow_type
		Case ARROW_LEFT
			DrawPoly([ x,y, x,y+24, x+12,y+12 ])
		Case ARROW_RIGHT
			DrawPoly([ x,y, x,y+24, x-12,y+12 ])
	End Select
End Function
'______________________________________________________________________________
Const MENU_TYPE_SELECT_ONE_VERTICAL_LIST% = 1
Const MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST% = 2

Type MENU
	Field name$ 'display to user
	Field menu_id% 'handle
	Field menu_type% 'controls display and input
	Field margin% 'visual margin
	Field options:MENU_OPTION[] 'array of possible options
	Field children%[] 'array of handles, can be 0 (no child)
	Field focus% 'index into options[]
	Field width% '(private) width of entire menu with margins
	Field height% '(private) height of entire menu with margins
	
	Function Create:MENU( name$, menu_id%, menu_type%, margin%, options:MENU_OPTION[] )
		Local m:MENU = New MENU
		m.name = name
		m.menu_id = menu_id
		m.menu_type = menu_type
		m.options = options[..]
		m.margin = margin
		m.width = 0
		For Local opt:MENU_OPTION = EachIn options
			opt = opt.clone()
			SetImageFont( menu_font )
			If (2*margin + TextWidth( opt.name )) > m.width
				m.width = (2*margin + TextWidth( opt.name )) 
			End If
		Next
		Select menu_type
			Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
				m.height = (2*margin + options.Length*(TextHeight(options[0].name) + margin))
			Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
				m.height = (2*margin + TextHeight(options[0].name))
		End Select
		Return m
	End Function
	
	Method draw( x%, y%, border% = False )
		Local cx% = x, cy% = y, opt:MENU_OPTION
		If border
			
		End If
		x :+ margin; y :+ margin
		For Local opt:MENU_OPTION = EachIn options
			Select menu_type
				
				Case MENU_TYPE_SELECT_ONE_VERTICAL_LIST
					For Local i% = 0 To options.Length - 1
						opt = options[i]
						If i = focus
							SetColor( 224, 224, 255 )
						Else
							If (opt.enabled And opt.visible)
								SetColor( 127, 127, 127 )
							Else If opt.visible
								SetColor( 64, 64, 64 )
							Else
								SetColor( 0, 0, 0 )
							End If
						End If
						opt.draw
						y :+ margin
					Next
					
				Case MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST
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
					draw_arrow( ARROW_LEFT, x, y + margin )
					SetColor( right_color, right_color, right_color )
					draw_arrow( ARROW_RIGHT, x + 2*margin + width, y + margin )
					SetColor( 224, 224, 255 )
					options[focus].draw( x + margin, y + margin )
					
			End Select
		Next
	End Method
	
	Method increment_focus()
		Local last_focus% = focus
		focus :+ 1; wrap_focus()
		While focus <> last_focus And Not options[focus].enabled
			focus :+ 1; wrap_focus()
		End While
	End Method
	
	Method decrement_focus()
		Local last_focus% = focus
		focus :- 1; wrap_focus()
		While focus <> last_focus And Not options[focus].enabled
			focus :- 1; wrap_focus()
		End While
	End Method
	
	Method wrap_focus()
		If      focus > (options.Length - 1) Then focus = 0 ..
		Else If focus < 0                    Then focus = (options.Length - 1)
	End Method
End Type
'______________________________________________________________________________
Global menu_stack%[10]
Global current_menu_stack_index% = 0

Const MENU_ID_NONE% = 0

Const MENU_ID_MAIN_MENU% = 10
Const MENU_ID_NEW% = 20
Const MENU_ID_LOAD% = 30
Const MENU_ID_OPTIONS% = 40
Const MENU_ID_OPTIONS_VIDEO% = 41
Const MENU_ID_OPTIONS_AUDIO% = 42
Const MENU_ID_OPTIONS_CONTROLS% = 43
Const MENU_ID_OPTIONS_GAME% = 44

Global main_menu:MENU = MENU.Create( "main menu", MENU_ID_MAIN_MENU, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, 15, ..
	[	MENU_OPTION.Create( "resume", COMMAND_RESUME,, True, False ), ..
		MENU_OPTION.Create( "new", COMMAND_SHOW_CHILD_MENU, MENU_ID_NEW, True, True ), ..
		MENU_OPTION.Create( "load", COMMAND_SHOW_CHILD_MENU, MENU_ID_LOAD, True, True ), ..
		MENU_OPTION.Create( "options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS, True, True ), ..
		MENU_OPTION.Create( "quit", COMMAND_QUIT_GAME,, True, True ) ])
Global new_game_menu:MENU = MENU.Create( "select a vehicle", MENU_ID_NEW, MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST, 15, ..
	[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "light tank", COMMAND_NEW_GAME, PLAYER_INDEX_LIGHT_TANK, True, True ), ..
		MENU_OPTION.Create( "laser tank", COMMAND_NEW_GAME, PLAYER_INDEX_LASER_TANK, True, True ), ..
		MENU_OPTION.Create( "medium tank", COMMAND_NEW_GAME, PLAYER_INDEX_MED_TANK, True, True ) ])
Global load_game_menu:MENU = MENU.Create( "select a saved game slot", MENU_ID_LOAD, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, 15, ..
	[ MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "slot 1", COMMAND_LOAD_GAME, 0, True, False ), ..
		MENU_OPTION.Create( "slot 2", COMMAND_LOAD_GAME, 1, True, False ), ..
		MENU_OPTION.Create( "slot 3", COMMAND_LOAD_GAME, 2, True, False ), ..
		MENU_OPTION.Create( "slot 4", COMMAND_LOAD_GAME, 3, True, False ), ..
		MENU_OPTION.Create( "slot 5", COMMAND_LOAD_GAME, 4, True, False ) ])
Global options_menu:MENU = MENU.Create( "options", MENU_ID_OPTIONS, MENU_TYPE_SELECT_ONE_VERTICAL_LIST, 15, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "video options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_VIDEO, True, False ), ..
		MENU_OPTION.Create( "audio options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_AUDIO, True, False ), ..
		MENU_OPTION.Create( "control options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_CONTROLS, True, True ), ..
		MENU_OPTION.Create( "game options", COMMAND_SHOW_CHILD_MENU, MENU_ID_OPTIONS_GAME, True, False ) ])
'Global options_video_menu:MENU
'Global options_audio_menu:MENU
Global options_controls_menu:MENU = menu.Create( "control options", MENU_ID_OPTIONS_CONTROLS, MENU_TYPE_SELECT_ONE_HORIZONTAL_ROTATING_LIST, 15, ..
	[	MENU_OPTION.Create( "back", COMMAND_BACK_TO_PARENT_MENU,, True, True ), ..
		MENU_OPTION.Create( "keyboard only", COMMAND_PLAYER_INPUT_TYPE, INPUT_KEYBOARD, True, True ), ..
		MENU_OPTION.Create( "keyboard and mouse", COMMAND_PLAYER_INPUT_TYPE, INPUT_KEYBOARD_MOUSE_HYBRID, True, True ), ..
		MENU_OPTION.Create( "xbox 360 controller", COMMAND_PLAYER_INPUT_TYPE, INPUT_XBOX_360_CONTROLLER, True, False ) ])
'Global options_game_menu:MENU


'______________________________________________________________________________
'old code
'Global menu_option_count% = 8
'Const MENU_RESUME% = 0
'Const MENU_NEW% = 1
'Const MENU_LOAD% = 2
'Const MENU_SETTINGS% = 3
'Const MENU_QUIT% = 4
''light tank = 5
''laser tank = 6
''medium tank = 7
''AI_DEMO
''LEVEL_EDITOR
'
'Global menu_display_string$[] = [ "resume", "new game", "load saved", "settings", "quit", "light tank", "laser tank", "medium tank" ]
'Global menu_enabled%[] =        [  False,    True,       False,        False,      True,   False,        False,        False ]
'Global menu_option% = MENU_NEW
'
''______________________________________________________________________________
'Function next_enabled_menu_option()
'	menu_option :+ 1
'	If menu_option >= menu_option_count Then menu_option = 0
'	While Not menu_enabled[ menu_option ]
'		menu_option :+ 1
'		If menu_option >= menu_option_count Then menu_option = 0
'	End While
'End Function
'Function prev_enabled_menu_option()
'	menu_option :- 1
'	If menu_option < 0 Then menu_option = menu_option_count - 1
'	While Not menu_enabled[ menu_option ]
'		menu_option :- 1
'		If menu_option < 0 Then menu_option = menu_option_count - 1
'	End While
'End Function
'______________________________________________________________________________
'Menu Commands
'Function menu_command( command_index% )
'	Select command_index
'		
		Case MENU_RESUME
		
		Case MENU_NEW
			menu_enabled[MENU_NEW] = False
			menu_enabled[5] = True
			menu_enabled[6] = True
			menu_enabled[7] = True
			menu_option = 5
			
		Case MENU_LOAD
			'..?
		
		Case MENU_SETTINGS
			'..?
		
		Case MENU_QUIT
			End 'quit now
			
		Case 5, 6, 7 'tank selection (part of NEW)
			menu_enabled[MENU_NEW] = True
			menu_enabled[5] = False
			menu_enabled[6] = False
			menu_enabled[7] = False
'			
'	End Select
'End Function


