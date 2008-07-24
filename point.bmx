Rem
	point.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type POINT Extends MANAGED_OBJECT
	
	Field pos_x# 'position (x-axis), pixels
	Field pos_y# 'position (y-axis), pixels
	Field vel_x# 'velocity (x-component), pixels per second
	Field vel_y# 'velocity (y-component), pixels per second
	Field acc_x# 'acceleration (x-component), pixels per second per second
	Field acc_y# 'acceleration (y-component), pixels per second per second
	Field ang# 'orientation angle, degrees
	Field ang_vel# 'angular velocity, degrees per second
	Field ang_acc# 'angular acceleration, degrees per second per second
	
	Method New()
	End Method
	
	Method update()
		'velocity
		vel_x :+ acc_x
		vel_y :+ acc_y
		'position
		pos_x :+ vel_x
		pos_y :+ vel_y
		'angular velocity
		ang_vel :+ ang_acc
		'orientation
		ang = ( ang + ang_vel ) Mod 360
	End Method
	
End Type
