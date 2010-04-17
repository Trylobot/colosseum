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
	
	Field body:TBody
	Field geom:TGeom
	
	Field hitbox:BOX 'collision rectangle
	Field mass# 'number representing the mass units of this object
	'this object's center of mass is assumed to be this object's position
	Field force_list:TList 'all the forces acting on this object
	Field frictional_coefficient# 'frictional coefficient
	Field physics_disabled% 'turn off all force-based calculations?
	
	Method New()
		force_list = CreateList()
	End Method
	
	Const mass_mod# = 0.01
	Const linear_friction_mod# = 0.45
	Const angular_friction_mod# = 200.0
	Const force_mod# = 12.5
	Const torque_mod# = 100.0
	Const rotationOffset# = 0.0
	
	Method setup_physics( physics:TPhysicsSimulator, offset:Vector2 )
		If Not hitbox Then Return
		offset = Null
		body = New TBody
		body.SetMass( mass * mass_mod )
		Local momentOfInertia# = TBodyFactory.MOIForRectangle( hitbox.w, hitbox.h, mass * mass_mod )
		body.SetMomentOfInertia( momentOfInertia )
		body.SetPosition( Vector2.Create( pos_x, pos_y ))
		body.SetRotation( MathHelper.ToRadians( ang ))
		body.SetLinearDragCoefficient( frictional_coefficient * linear_friction_mod )
		body.SetRotationalDragCoefficient( frictional_coefficient * angular_friction_mod )
		body.SetStatic( physics_disabled )
		Local verts:TVertices = TVertices.CreateRectangle( hitbox.w, hitbox.h )
		Local collisionGridCellSize# = TGeomFactory.CalculateGridCellSizeFromAABB( verts )
		geom = TGeom.Create( body, verts, collisionGridCellSize, offset, rotationOffset )
		physics.AddBody( body )
		physics.AddGeom( geom )
	End Method
	
	Method collide:Object[]( collidemask%, writemask% )
		Return Null
		Rem
		If hitbox
			SetRotation( ang )
			SetHandle( hitbox.x, hitbox.y )
			Return CollideRect( pos_x, pos_y, hitbox.w, hitbox.h, collidemask, writemask, Self )
		Else
			Return Null
		End If
		EndRem
	End Method
	
	Method move_to( argument:Object, dummy1% = False, dummy2% = False )
		Super.move_to( argument, dummy1, dummy2 )
		If body
			body.SetPosition( Vector2.Create( pos_x, pos_y ))
			body.SetRotation( MathHelper.ToRadians( ang ))
		End If
	End Method
	
	Method update()
		If body
			pos_x = body._position.X
			pos_y = body._position.Y
			ang = MathHelper.ToDegrees( body._rotation )
			vel_x = body._bodyLinearvelocity.X / 30.0
			vel_y = body._bodyLinearvelocity.Y / 30.0
			ang_vel = MathHelper.ToDegrees( body._angularVelocity ) / 100.0
			
			If Not force_list.IsEmpty()
				For Local f:FORCE = EachIn force_list
					f.update()
					If f.managed()
						Select f.physics_type
							Case PHYSICS_FORCE
								Local fv:Vector2 = Vector2.Zero()
								If f.combine_ang_with_parent_ang
									fv.X = f.magnitude_cur*Cos( f.direction + ang ) * force_mod
									fv.Y = f.magnitude_cur*Sin( f.direction + ang ) * force_mod
								Else
									fv.X = f.magnitude_cur*Cos( f.direction ) * force_mod
									fv.Y = f.magnitude_cur*Sin( f.direction ) * force_mod
								End If
								body.ApplyForce( fv )
							Case PHYSICS_TORQUE
								body.ApplyTorque( f.magnitude_cur * torque_mod )
						End Select
					End If
				Next
			End If
		End If
		Rem
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
		EndRem
	End Method
	
	Method add_force:FORCE( other_f:FORCE, combine_ang_with_parent_ang% = False )
		Local f:FORCE = FORCE( FORCE.Copy( other_f, force_list ))
		'f.parent = Self
		f.combine_ang_with_parent_ang = combine_ang_with_parent_ang
		return f
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

