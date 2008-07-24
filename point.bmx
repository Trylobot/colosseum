Rem
	point.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type POINT
	'Position
	Field pos_x#
	Field pos_y#
	'Velocity
	Field vel_x#
	Field vel_y#
	'Rotation
	Field ang#
	'List Manager info
	Field link:TLink
	
	Method New()
	End Method
	
	Method add_me( list:TList )
		link = ( list.AddLast( Self ))
	End Method
	Method remove_me()
		link.Remove()
	End Method
	
End Type
