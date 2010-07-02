Rem
	mouse.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "point.bmx"
'Import "vec.bmx"

'______________________________________________________________________________
Global mouse:POINT = Create_POINT( MouseX(), MouseY() ) 'mouse position relative to window top-left
Global game_mouse:cVEC = New cVEC 'mouse position relative to an ENVIRONMENT's origin
Global mouse_delta:cVEC = New cVEC 'mouse per-frame movement
Global mouse_last_z% = 0 'middle mouse tracking
Global dragging_scrollbar% = False 'menu hack
Global mouse_down_1% = False 'menu button state tracking
Global mouse_down_2% = False 'same

