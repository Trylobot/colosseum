Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global menu_font:TImageFont = get_font( "consolas_24" )

Type MENU_OPTION
	Field name$ 'display to user
	Field value% 'return to system
	Field visible% 'draw this option? {true|false}
	Field enabled% 'can this option be selected? {true|false}
	
	Function Create:MENU_OPTION( name$, value%, visible%, enabled% )
		Local opt:MENU_OPTION = New MENU_OPTION
		opt.name = name
		opt.value = value
		opt.visible = visible
		opt.enabled = enabled
		Return opt
	End Function
	
	Method draw( x%, y% )
		DrawText( name, x, y )
	End Method
End Type
'______________________________________________________________________________
Const MENU_TYPE_SELECT_ONE_VERTICAL_WRAP_LIST
Const MENU_TYPE_SELECT_ONE_HORIZONTAL_CYCLIC_LIST

Type MENU
	Field name$ 'display to user
	Field menu_type% 'controls display and input
	Field options:MENU_OPTION[] 'array of possible options
	Field margin% 'visual margin
	Field focus% 'index into options[]
	Field width% '(private) width of entire menu with margins
	Field height% '(private) height of entire menu with margins
	
	Function Create:MENU( name$, menu_type%, options:MENU_OPTION[], margin% )
		Local m:MENU = New MENU
		m.name = name
		m.menu_type = menu_type
		m.options = options
		m.margin = margin
		m.width = 0
		m.height = 0
		For Local opt:MENU_OPTION = EachIn options
			SetImageFont( menu_font )
			If (2*margin + TextWidth( opt.name )) > m.width
				m.width =(2*margin + TextWidth( opt.name )) 
		Next
		Return m
	End Function
	
	Method draw( x%, y% )
		
	End Method
End Type



'______________________________________________________________________________
'old code
Global menu_option_count% = 8
Const MENU_RESUME% = 0
Const MENU_NEW% = 1
Const MENU_LOAD% = 2
Const MENU_SETTINGS% = 3
Const MENU_QUIT% = 4
'light tank = 5
'laser tank = 6
'medium tank = 7
'AI_DEMO
'LEVEL_EDITOR

Global menu_display_string$[] = [ "resume", "new game", "load saved", "settings", "quit", "light tank", "laser tank", "medium tank" ]
Global menu_enabled%[] =        [  False,    True,       False,        False,      True,   False,        False,        False ]
Global menu_option% = MENU_NEW

'______________________________________________________________________________
Function next_enabled_menu_option()
	menu_option :+ 1
	If menu_option >= menu_option_count Then menu_option = 0
	While Not menu_enabled[ menu_option ]
		menu_option :+ 1
		If menu_option >= menu_option_count Then menu_option = 0
	End While
End Function
Function prev_enabled_menu_option()
	menu_option :- 1
	If menu_option < 0 Then menu_option = menu_option_count - 1
	While Not menu_enabled[ menu_option ]
		menu_option :- 1
		If menu_option < 0 Then menu_option = menu_option_count - 1
	End While
End Function
'______________________________________________________________________________
'Menu Commands
Function menu_command( command_index% )
	Select command_index
		
		Case MENU_RESUME
			FLAG_in_menu = False
			FLAG_player_engine_running = True
		
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
			player_type = PLAYER_INDEX_START + (command_index - 5)
			FLAG_in_menu = False
			reset_game()
			init_game()
			FLAG_game_in_progress = True
			menu_enabled[MENU_NEW] = True
			menu_enabled[5] = False
			menu_enabled[6] = False
			menu_enabled[7] = False
			
	End Select
End Function


