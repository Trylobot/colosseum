Rem
	menu.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Menus and options

Type MENU
	
	
	
End Type

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
			toggle_doors( ALIGNMENT_FRIENDLY )
			
	End Select
End Function


