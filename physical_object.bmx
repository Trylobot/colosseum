Rem
	physical_object.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PHYSICAL_OBJECT Extends POINT
	
	Field mass# 'number representing the mass units of this object. center of mass assumed to be at (0,0) with respect to the object's position
	Field forces:TList 'all the forces acting on this object
	Field friction_coef# 'frictional coefficient
	'Field net_force# 'magnitude of net force acting parallel to the center of mass
	'Field net_torque# 'magnitude of net force acting perpendicular to the center of mass (rotational force, torque)
	
	Method New()
	End Method
	
	Method update()
		Local t#, friction_x#, friction_y#, ang_friction#
		'reset acceleration and calculate net force and torque
		acc_x = 0; acc_y = 0; ang_acc = 0
		For Local f:FORCE = EachIn forces
			t = f.offset_ang - f.direction
			acc_x :+   Cos( t )*Cos( f.offset_ang ) / mass
			acc_y :+   Cos( t )*Sin( f.offset_ang )*offset / mass
			ang_acc :+ Sin( t )
		Next
		'add in friction force
		If vel_x <> 0 Then   acc_x :-        vel_x*friction_coef / mass
		If vel_y <> 0 Then   acc_y :-        vel_y*friction_coef / mass
		If ang_vel <> 0 Then ang_friction :- ang_vel*friction_coef / mass
		'velocity
		
		'position
		
		'angular velocity
		
		'orientation
		
	End Method
End Type
