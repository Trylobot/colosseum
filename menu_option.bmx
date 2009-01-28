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
	Field red%, green%, blue% 'color
	Field always_bright% 'drawing cue
	
	Function Create:MENU_OPTION( ..
	name$, ..
	command_code% = 0, ..
	argument:Object = Null, ..
	visible% = True, ..
	enabled% = True, ..
	red% = 255, green% = 255, blue% = 255, ..
	always_bright% = False )
		Local opt:MENU_OPTION = New MENU_OPTION
		opt.name = name
		opt.command_code = command_code
		opt.argument = argument
		opt.visible = visible
		opt.enabled = enabled
		opt.red = red; opt.green = green; opt.blue = blue
		opt.always_bright = always_bright
		Return opt
	End Function
	
	Method clone:MENU_OPTION()
		Return Create( name, command_code, argument, visible, enabled )
	End Method
	
	Method draw( resolved_name$, x%, y%, focused% = False )
		Local mult# = 1.0, glow% = False
		If Not always_bright
			If focused
				glow = True
			Else If enabled And visible 'Not focused
				mult = 0.5
			Else If visible 'Not enabled And Not focused
				mult = 0.25
			End If
		End If
		'draw the option
		SetColor( red*mult, green*mult, blue*mult )
		If glow
			DrawText_with_glow( resolved_name, x, y )
		Else
			DrawText_with_outline( resolved_name, x, y )
		End If
	End Method
	
	Method width%()
		
	End Method
	Method height%()
		
	End Method
	
End Type

