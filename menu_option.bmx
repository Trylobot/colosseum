Rem
	menu_option.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Type MENU_OPTION
	Field name$ 'display this to user
	Field command_code% 'command to execute when this option is selected
	Field argument:Object 'parameter, has meaning only in combination with command_code
	Field visible% 'draw this option? {true|false}
	Field enabled% 'this option can be selected? {true|false}
	Field red%, green%, blue% 'color
	Field always_bright% 'drawing cue
	Field img:TImage '(optional) only used in menus of type GROUPED_LEVEL_PREVIEW_LIST
	
	Function Create:MENU_OPTION( ..
	name$, command_code% = 0, argument:Object = Null, ..
	visible% = True, enabled% = True, ..
	red% = 255, green% = 255, blue% = 255, ..
	always_bright% = False, ..
	img:TImage = Null )
		Local opt:MENU_OPTION = New MENU_OPTION
		opt.name = name
		opt.command_code = command_code
		opt.argument = argument
		opt.visible = visible
		opt.enabled = enabled
		opt.red = red; opt.green = green; opt.blue = blue
		opt.always_bright = always_bright
		opt.img = img
		Return opt
	End Function
	
	Method clone:MENU_OPTION()
		Return Create( ..
			name, command_code, argument, ..
			visible, enabled, ..
			red, green, blue, ..
			always_bright, ..
			img )
	End Method
	
End Type

