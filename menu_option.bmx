Rem
	menu_option.bmx
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
	
	Function Create:MENU_OPTION( name$, command_code% = 0, argument:Object = Null, visible% = True, enabled% = True )
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
			DrawText_with_outline( display_name, x, y )
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

