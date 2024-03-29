Rem
	physical_object.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "point.bmx"
'Import "box.bmx"
'Import "force.bmx"

'______________________________________________________________________________
Type PHYSICAL_OBJECT Extends POINT
	Field mass# 'number representing the mass units of this object
	Field hitbox_img:TImage
	Field handle:pVEC
	Field force_list:TList 'all the forces acting on this object
	Field frictional_coefficient# 'frictional coefficient
	Field physics_disabled% 'turn off all force-based calculations?
	
	Method New()
		force_list = CreateList()
	End Method
	
	Method move_to( argument:Object, dummy1% = False, dummy2% = False )
		Super.move_to( argument, dummy1, dummy2 )
	End Method
	
	Method update()
		If physics_disabled
			force_list.Clear()
			Return
		End If
		If Not force_list.IsEmpty()
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
			acc_x :+ frictional_coefficient*( -vel_x ) / mass
			acc_y :+ frictional_coefficient*( -vel_y ) / mass
			'angular friction
			ang_acc :+ frictional_coefficient*( -ang_vel ) / mass
		End If
		'update point variables
		Super.update()
	End Method
	
	Method add_force:FORCE( other_f:FORCE, combine_ang_with_parent_ang% = False )
		Local f:FORCE = FORCE( FORCE.Copy( other_f, force_list ))
		'f.parent = Self
		f.combine_ang_with_parent_ang = combine_ang_with_parent_ang
		Return f
	End Method
	
	Method collide:Object[]( collidemask%, writemask% )
		If hitbox_img
			SetRotation( ang )
			Return CollideImage( hitbox_img, pos_x, pos_y, 0, collidemask, writemask, Self )
		Else
			Return Null
		End If
	End Method
	
	Rem
	Method write_state_to_stream( stream:TStream )
		Super.write_state_to_stream( stream )
	End Method
	
	Method read_state_from_stream( stream:TStream )
		Super.read_state_from_stream( stream )
	End Method	
	End Rem
	
End Type

