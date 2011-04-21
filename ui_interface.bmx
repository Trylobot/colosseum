Rem
	ui_interface.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Type TUIObject Abstract
	Method set_position( x%, y% ) End Method
	Method draw() End Method
	Method on_keydown( keycode% ) End Method
	Method on_keyup( keycode% ) End Method
	Method on_mouse_move%( mx%, my% ) End Method
	Method on_mouse_click%( mx%, my% ) End Method
	Method on_keyboard_up() End Method
	Method on_keyboard_down() End Method
	Method on_keyboard_left() End Method
	Method on_keyboard_right() End Method
	Method on_keyboard_enter() End Method
	Method on_show() End Method
	Method service( time_elapsed! ) End Method
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
		If event_handler
			event_handler( item )
		End If
	End Method
End Type

