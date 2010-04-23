Rem
	ui_interface.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Type TUIObject Abstract
	Method set_position( x%, y% ) Abstract
	Method draw() Abstract
	Method on_mouse_move%( mx%, my% ) Abstract
	Method on_mouse_click%( mx%, my% ) Abstract
	Method on_keyboard_up() Abstract
	Method on_keyboard_down() Abstract
	Method on_keyboard_left() Abstract
	Method on_keyboard_right() Abstract
	Method on_keyboard_enter() Abstract
	Method on_show() Abstract
End Type

'______________________________________________________________________________
Type TUIEventHandler
	'private fields
	Field event_handler(item:Object)
	'factory
	Function Create:TUIEventHandler( event_handler(item:Object) )
		Local h:TUIEventHandler = New TUIEventHandler
		h.event_handler = event_handler
		Return h
	End Function
	'handler invocation
	Method invoke( item:Object = Null )
		event_handler( item )
	End Method
End Type

