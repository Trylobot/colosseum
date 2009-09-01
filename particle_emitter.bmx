Rem
	particle_emitter.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "emitter.bmx"
Import "particle.bmx"
Import "json.bmx"

'______________________________________________________________________________
Global particle_emitter_map:TMap = CreateMap()

Function get_particle_emitter:PARTICLE_EMITTER( Key$, Copy% = True )
	Local em:PARTICLE_EMITTER = PARTICLE_EMITTER( particle_emitter_map.ValueForKey( key.toLower() ))
	If copy And em Then Return Copy_PARTICLE_EMITTER( em )
	Return em
End Function

Function Create_PARTICLE_EMITTER:PARTICLE_EMITTER( emitter_object:PARTICLE )
	'the remaining initialization is performed by initialize_generic_EMITTER()
	Local em:PARTICLE_EMITTER = New PARTICLE_EMITTER
	em.emitter_object = emitter_object
	Return em
End Function

Type PARTICLE_EMITTER Extends EMITTER
	Field emitter_object:PARTICLE 'template for objects to be emitted
	
	Method emit:PARTICLE( background_list:TList = Null, foreground_list:TList = Null )
		If is_enabled() And ready()
			'create a new object (particle/projectile) and set it up
			Local p:PARTICLE = emitter_object.clone( PARTICLE_FRAME_RANDOM )
			'manager
			If p.layer = LAYER_BACKGROUND And background_list
				p.manage( background_list )
			Else If p.layer = LAYER_FOREGROUND And foreground_list
				p.manage( foreground_list )
			Else
				Return Null
			End If
			'position
			Local dist_actual# = dist.get()
			Local dist_ang_actual# = dist_ang.get()
			p.pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang ) + dist_actual * Cos( dist_ang_actual + offset_ang + parent.ang )
			p.pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang ) + dist_actual * Sin( dist_ang_actual + offset_ang + parent.ang )
			'orientation
			If inherit_ang_from_dist_ang
				p.ang = dist_ang_actual + parent.ang
			Else
				p.ang = ang.get() + parent.ang
			End If
			'velocity
			Local vel_actual# = vel.get()
			Local vel_ang_actual#
			If inherit_vel_ang_from_ang
				vel_ang_actual = p.ang
			Else
				vel_ang_actual = vel_ang.get()
			End If
			p.vel_x = ( combine_vel_with_parent_vel*parent.vel_x ) + vel_actual*Cos( vel_ang_actual + ( combine_vel_ang_with_parent_ang*parent.ang ))
			p.vel_y = ( combine_vel_with_parent_vel*parent.vel_y ) + vel_actual*Sin( vel_ang_actual + ( combine_vel_ang_with_parent_ang*parent.ang ))
			'angular velocity
			p.ang_vel = ang_vel.get()
			'acceleration
			Local acc_actual# = acc.get()
			Local acc_ang_actual#
			If inherit_acc_ang_from_vel_ang
				acc_ang_actual = vel_ang_actual
			Else
				acc_ang_actual = acc_ang.get()
			End If
			p.acc_x = acc_actual * Cos( acc_ang_actual + parent.ang )
			p.acc_y = acc_actual * Sin( acc_ang_actual + parent.ang )
			'angular acceleration
			p.ang_acc = ang_acc.get()
			'alpha
			p.alpha = alpha.get()
			p.alpha_delta = alpha_delta.get()
			'scale
			p.scale = scale.get()
			p.scale_delta = scale_delta.get()
			'color
			p.red = red.get(); p.green = green.get(); p.blue = blue.get()
			p.red_delta = red_delta.get(); p.green_delta = green_delta.get(); p.blue_delta = blue_delta.get()
			'life time
			p.created_ts = now()
			p.life_time = life_time.get()
			'emitter state maintenance
			'interval
			last_emit_ts = now()
			interval_cur = interval.get()
			'counter
			count_cur :- 1
			'return emitted particle to caller for chaining
			Return p
		End If
		Return Null
	End Method
	
End Type

Function Copy_PARTICLE_EMITTER:PARTICLE_EMITTER( other_em:PARTICLE_EMITTER, managed_list:TList = Null, new_parent:POINT = Null )
	Local em:PARTICLE_EMITTER = Create_PARTICLE_EMITTER( other_em.emitter_object )
	em = PARTICLE_EMITTER( copy_generic_EMITTER( em, other_em, managed_list, new_parent ))
	Return em
End Function

Function Create_PARTICLE_EMITTER_from_json:PARTICLE_EMITTER( json:TJSON )
	Local e:PARTICLE_EMITTER
	'required fields
	Local emitter_object_key$
	Local emitter_object:PARTICLE
	'read required fields
	If json.TypeOf( "emitter_object_key" ) <> JSON_UNDEFINED Then emitter_object_key = json.GetString( "emitter_object_key" ) Else Return Null
	emitter_object = get_particle( emitter_object_key,, False )
	If Not emitter_object Then Return Null
	'create object with only required fields
	e = Create_PARTICLE_EMITTER( emitter_object )
	'initialize generic emitter fields
	initialize_generic_EMITTER_from_json( e, json )
	Return e
End Function

Function Create_PARTICLE_EMITTER_from_json_reference:PARTICLE_EMITTER( json:TJSON )
	Local e:PARTICLE_EMITTER
	If json.TypeOf( "particle_emitter_key" ) <> JSON_UNDEFINED Then e = get_particle_emitter( json.GetString( "particle_emitter_key" ))
	If Not e Then Return Null
	'initialize generic emitter reference fields
	initialize_generic_EMITTER_from_json_reference( e, json )
	Return e
End Function

