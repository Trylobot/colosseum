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
		
		'update forces; calculate net force and torque
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
		
		'friction is ever-present and calculated based on velocity
		If vel_x <> 0 Then   acc_x :-   frictional_coefficient*vel_x / mass
		If vel_y <> 0 Then   acc_y :-   frictional_coefficient*vel_y / mass
		If ang_vel <> 0 Then ang_acc :- frictional_coefficient*ang_vel / mass
		
		'update point variables
		Super.update()
		
	End Method
	
End Type

