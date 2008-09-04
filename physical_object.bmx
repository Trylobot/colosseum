Rem
	physical_object.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const PHYSICS_FORCE% = 0
Const PHYSICS_TORQUE% = 1

Type FORCE Extends MANAGED_OBJECT

	Field physics_type% '(torque/force)?
	Field parent:PHYSICAL_OBJECT 'for forces, parent object this force is attached to
	Field combine_ang_with_parent_ang% 'for forces, indicates whether the direction of the force is absolute
	Field direction# 'direction force is pointing
	Field magnitude_max# 'maximum strength of force
	Field life_time% 'time the force should be active (can be infinite)
	
	Field control_pct# 'magnitude multiplier; force therefore yields between [-magnitude,magnitude]
	Field magnitude_cur# 'current net magnitude
	Field created_ts% '(private) timestamp of force creation (for auto-pruning)
	
	Method New()
	End Method
	
	Function Create:Object( ..
	physics_type%, ..
	direction# = 0.0, ..
	magnitude_max#, ..
	life_time% = INFINITY )
		Local f:FORCE = New FORCE
		
		f.physics_type = physics_type
		f.direction = direction
		f.magnitude_max = magnitude_max
		f.life_time = life_time
		
		f.control_pct = 1.0
		f.created_ts = now()
		f.update()
		
		Return f
	End Function
	
	Function Copy:Object( other:FORCE, managed_list:TList )
		Local f:FORCE = New FORCE
		
		f.physics_type = other.physics_type
		f.direction = other.direction
		f.magnitude_max = other.magnitude_max
		f.life_time = other.life_time
		
		f.control_pct = 1.0
		f.created_ts = now()
		f.update()
		
		f.manage( managed_list )
		Return f
	End Function

	Method update()
		If dead()
			unmanage()
		End If
		magnitude_cur = control_pct*magnitude_max
	End Method
	
	Method dead%()
		Return ..
			life_time <> INFINITY And ..
			(now() - created_ts) > life_time
	End Method
	
End Type

'______________________________________________________________________________
Type PHYSICAL_OBJECT Extends POINT
	
	Field mass# 'number representing the mass units of this object
	'this object's center of mass is assumed to be this object's position
	Field force_list:TList 'all the forces acting on this object
	Field frictional_coefficient# 'frictional coefficient
	Field physics_disabled% 'turn off all force-based calculations?
	
	Method New()
		force_list = CreateList()
	End Method
	
	Method update()
		If physics_disabled Then Return
		'reset acceleration and angular acceleration
		acc_x = 0; acc_y = 0; ang_acc = 0
		'net force and torque
		For Local f:FORCE = EachIn force_list
			f.update()
			If f.managed()
				Select f.physics_type
					Case PHYSICS_FORCE
						If f.combine_ang_with_parent_ang
							acc_x :+ f.magnitude_cur*Cos( f.direction + ang ) / mass
							acc_y :+ f.magnitude_cur*Sin( f.direction + ang ) / mass
						Else
							acc_x :+ f.magnitude_cur*Cos( f.direction ) / mass
							acc_y :+ f.magnitude_cur*Sin( f.direction ) / mass
						End If
					Case PHYSICS_TORQUE
						ang_acc :+ f.magnitude_cur / mass
				End Select
			End If
		Next
		'friction
		acc_x :+ frictional_coefficient*( -vel_x ) / mass ..
		acc_y :+ frictional_coefficient*( -vel_y ) / mass ..
		'angular friction
		ang_acc :+ frictional_coefficient*( -ang_vel ) / mass ..
		'update point variables
		Super.update()
	End Method
	
	Method add_force:FORCE( other_f:FORCE, combine_ang_with_parent_ang% = False )
		Local f:FORCE = FORCE( FORCE.Copy( other_f, force_list ))
		f.parent = Self
		f.combine_ang_with_parent_ang = combine_ang_with_parent_ang
		return f
	End Method
	
End Type

