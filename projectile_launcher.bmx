Rem
	projectile_launcher.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "emitter.bmx"
'Import "projectile.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global projectile_launcher_map:TMap = CreateMap()

Function get_projectile_launcher:PROJECTILE_LAUNCHER( Key$, Copy% = True )
	Local lchr:PROJECTILE_LAUNCHER = PROJECTILE_LAUNCHER( projectile_launcher_map.ValueForKey( key.toLower() ))
	If copy And lchr Then Return Copy_PROJECTILE_LAUNCHER( lchr )
	Return lchr
End Function

Function Create_PROJECTILE_LAUNCHER:PROJECTILE_LAUNCHER( emitter_object:PROJECTILE, source_id% = NULL_ID )
	'the remaining initialization is performed by initialize_generic_EMITTER()
	Local lchr:PROJECTILE_LAUNCHER = New PROJECTILE_LAUNCHER
	lchr.emitter_object = emitter_object
	lchr.source_id = source_id
	Return lchr
End Function

Type PROJECTILE_LAUNCHER Extends EMITTER
	Field emitter_object:PROJECTILE 'template for objects to be emitted
	Field source_id% 'to prevent collisions between emitted projectiles and the emitter parent
	
	Method emit:PROJECTILE( list:TList, physics:TPhysicsSimulator )
		If is_enabled() And ready()
			'create a new object (particle/projectile) and set it up
			Local p:PROJECTILE = emitter_object.clone( source_id )
			'managers
			If list
				p.manage( list )
			Else
				Return Null
			End If
			'If physics
			'	p.setup_physics( physics, Vector2.Create( p.img.handle_x, p.img.handle_y ))
			'	p.geom.SetCollisionEnabled( False )
			'Else
			'	Return Null
			'End If
			'position
			Local dist_actual# = dist.get()
			Local dist_ang_actual# = dist_ang.get()
			p.pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang ) + dist_actual * Cos( dist_ang_actual + parent.ang )
			p.pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang ) + dist_actual * Sin( dist_ang_actual + parent.ang )
			'p.body.SetPosition( Vector2.Create( p.pos_x, p.pos_y ))
			'orientation
			If inherit_ang_from_dist_ang
				p.ang = dist_ang_actual + parent.ang
			Else
				p.ang = ang.get() + parent.ang
			End If
			'p.body.SetRotation( MathHelper.ToRadians( p.ang ))
			'velocity
			Local vel_actual# = vel.get()' * 25.0
			Local vel_ang_actual#
			If inherit_vel_ang_from_ang
				vel_ang_actual = p.ang
			Else
				vel_ang_actual = vel_ang.get()
			End If
			p.vel_x = vel_actual * Cos( vel_ang_actual + ( combine_vel_ang_with_parent_ang*parent.ang )) + ( combine_vel_with_parent_vel*parent.vel_x )
			p.vel_y = vel_actual * Sin( vel_ang_actual + ( combine_vel_ang_with_parent_ang*parent.ang )) + ( combine_vel_with_parent_vel*parent.vel_y )
			'p.body.SetLinearVelocity( Vector2.Create( p.vel_x, p.vel_y ))
			'angular velocity
			p.ang_vel = ang_vel.get()
			'p.body.SetAngularVelocity( p.ang_vel )
			'p.body.Set
			'forces
			p.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, 0, acc.get())), True )
			'emitter state maintenance
			'interval
			last_emit_ts = now()
			interval_cur = interval.get()
			'counter
			count_cur :- 1
			Return p
		End If
		Return Null
	End Method
End Type

Function Copy_PROJECTILE_LAUNCHER:PROJECTILE_LAUNCHER( other_lchr:PROJECTILE_LAUNCHER, managed_list:TList = Null, new_parent:POINT = Null, source_id% = NULL_ID )
	Local lchr:PROJECTILE_LAUNCHER = Create_PROJECTILE_LAUNCHER( other_lchr.emitter_object, other_lchr.source_id )
	lchr = PROJECTILE_LAUNCHER( copy_generic_EMITTER( lchr, other_lchr, managed_list, new_parent ))
	Return lchr
End Function

Function Create_PROJECTILE_LAUNCHER_from_json:PROJECTILE_LAUNCHER( json:TJSON )
	Local e:PROJECTILE_LAUNCHER
	'required fields
	Local emitter_object_key$
	Local emitter_object:PROJECTILE
	'read required fields
	If json.TypeOf( "emitter_object_key" ) <> JSON_UNDEFINED Then emitter_object_key = json.GetString( "emitter_object_key" ) Else Return Null
	emitter_object = get_projectile( emitter_object_key,, False )
	If Not emitter_object Then Return Null
	'create object with only required fields
	e = Create_PROJECTILE_LAUNCHER( emitter_object )
	'and don't forget the default initialization from the base class
	initialize_generic_EMITTER( e )
	'initialize generic emitter fields
	initialize_generic_EMITTER_from_json( e, json )
	Return e
End Function

Function Create_PROJECTILE_LAUNCHER_from_json_reference:PROJECTILE_LAUNCHER( json:TJSON )
	Local e:PROJECTILE_LAUNCHER
	If json.TypeOf( "projectile_launcher_key" ) <> JSON_UNDEFINED Then e = get_projectile_launcher( json.GetString( "projectile_launcher_key" ))
	If Not e Then Return Null
	'initialize generic emitter reference fields
	initialize_generic_EMITTER_from_json_reference( e, json )
	Return e
End Function

