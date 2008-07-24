Rem
	physical_object.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PHYSICAL_OBJECT Extends POINT
	
	Field mass# 'number representing the mass units of this object
	'this object's center of mass is assumed to be this object's position
	Field force_list:TList 'all the forces acting on this object
	Field frictional_coefficient# 'frictional coefficient
	
	Method New()
		force_list = CreateList()
	End Method
	
	Method update()
		'reset acceleration and angular acceleration
		acc_x = 0; acc_y = 0; ang_acc = 0
		'net force and torque
		For Local f:FORCE = EachIn force_list
			f.update()
			If f.managed()
				Select f.physics_type
					Case PHYSICS_FORCE
						acc_x :+ f.magnitude_cur*Cos( f.direction + ang ) / mass
						acc_y :+ f.magnitude_cur*Sin( f.direction + ang ) / mass
					Case PHYSICS_TORQUE
						ang_acc :+ f.magnitude_cur / mass
				End Select
			End If
		Next
		'friction
		If Abs( vel_x ) > global_driving_roundoff_threshold Then acc_x :+ frictional_coefficient*( -vel_x ) / mass ..
		Else acc_x :+ -vel_x
		If Abs( vel_y ) > global_driving_roundoff_threshold Then acc_y :+ frictional_coefficient*( -vel_y ) / mass ..
		Else acc_y :+ -vel_y
		'angular friction
		If Abs( ang_vel ) > global_driving_roundoff_threshold Then ang_acc :+ frictional_coefficient*( -ang_vel ) / mass ..
		Else ang_acc :+ -ang_vel
		'update point variables
		Super.update()
	End Method
	
End Type

