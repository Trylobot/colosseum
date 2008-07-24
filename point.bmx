Rem
	point.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type POINT Extends MANAGED_OBJECT
	
	'Position
	Field pos_x#
	Field pos_y#
	'Velocity
	Field vel_x#
	Field vel_y#
	'Orientation
	Field ang#
	'Angular Velocity
	Field ang_vel#
	
	Method New()
	End Method
	
	Method debug()
		Super.debug()
		Print "POINT______________"
		Print "pos " + pos_x + ", " + pos_y
		Print "vel " + vel_x + ", " + vel_y
		Print "ang " + ang
		Print "ang_vel " + ang_vel
	End Method

End Type
