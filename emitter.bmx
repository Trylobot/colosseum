Rem
	emitter.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const EMITTER_TYPE_PARTICLE% = 0
Const EMITTER_TYPE_PROJECTILE% = 1

Const MODE_DISABLED% = 0
Const MODE_ENABLED_WITH_COUNTER% = 1
Const MODE_ENABLED_WITH_TIMER% = 2
Const MODE_ENABLED_FOREVER% = 3

Type EMITTER extends MANAGED_OBJECT
	
	Field parent:POINT 'parent object (for position and angle offsets)
	Field emitter_type% 'emitter type (particle/projectile)
	Field archetype_index% 'particle archetype
	Field mode% 'emitter mode (off/counter/timer)
	Field interval:RANGE_Int 'delay between particles
	Field interval_cur% '(private) delay between particles - pre-calculated
	Field last_emit_ts% '(private) timestamp of last emitted particle
	Field time_to_live% 'time until this emitter is disabled
	Field last_enable_ts% '(private) timestamp of the last time this emitter was enabled
	Field count:RANGE_Int 'number of particles to emit - upper bound
	Field count_cur% '(private) number of particles remaining to emit - pre-calculated and tracked
	Field combine_vel_with_parent_vel% 'setting - whether to add the parent's velocity to the emitted particle's velocity
	Field combine_vel_ang_with_parent_ang% 'setting - whether to add the parent's orientation to the emitted particle's direction of travel
	Field inherit_ang_from_dist_ang% 'setting - whether to set the angle to the already-determined "dist_ang" or a new angle
	Field inherit_vel_ang_from_ang% 'setting - whether to set the velocity angle to the already-determined "ang" or a new angle
	Field inherit_acc_ang_from_vel_ang% 'setting - whether to set the acceleration angle to the already-determined "vel_ang" or a new angle
	Field source_id% '(optional) emitter source (for projectile no_collides)
	Field offset# 'offset vector magnitude (added to parent's position)
	Field offset_ang# 'offset vector angle (added to parent's position)
	
	Field dist:RANGE 'additional emitted particle offset magnitude
	Field dist_ang:RANGE 'direction of additional emitted particle  offset
	Field vel:RANGE 'velocity of emitted particle
	Field vel_ang:RANGE 'direction of velocity of emitted particle 
	Field acc:RANGE 'acceleration of emitted particle 
	Field acc_ang:RANGE 'direction of acceleration emitted particle 
	Field ang:RANGE 'orientation of emitted particle 
	Field ang_vel:RANGE 'angular velocity of emitted particle 
	Field ang_acc:RANGE 'angular acceleration of emitted particle 
	Field life_time:RANGE_Int 'life time of emitted particle 
	Field alpha:RANGE 'initial alpha value of emitted particle 
	Field alpha_delta:RANGE 'alpha rate of change of emitted particle 
	Field scale:RANGE 'initial scale value of emitted particle 
	Field scale_delta:RANGE 'scale rate of change of emitted particle 
	Field red:RANGE, green:RANGE, blue:RANGE 'color of emitted particle
	Field red_delta:RANGE, green_delta:RANGE, blue_delta:RANGE 'emitted particle's change in color over time
	
	Method New()
		interval = New RANGE_Int
		count = New RANGE_Int
		
		dist = New RANGE; dist_ang = New RANGE
		vel = New RANGE; vel_ang = New RANGE
		acc = New RANGE; acc_ang = New RANGE
		ang = New RANGE
		ang_vel = New RANGE
		ang_acc = New RANGE
		life_time = New RANGE_Int
		alpha = New RANGE; alpha_delta = New RANGE
		scale = New RANGE; scale_delta = New RANGE
		red = New RANGE; green = New RANGE; blue = New RANGE 
		red_delta = New RANGE; green_delta = New RANGE; blue_delta = New RANGE 
	End Method
	
	Method update()
		Select mode
			Case MODE_ENABLED_WITH_COUNTER
				If (count_cur <= 0) Then disable()
			Case MODE_ENABLED_WITH_TIMER
				If (now() - last_enable_ts) >= time_to_live Then disable()
		End Select
	End Method
	
	Method enable( new_mode% = MODE_ENABLED_FOREVER )
		mode = new_mode
		Select mode
			Case MODE_ENABLED_WITH_COUNTER
				count_cur = count.get()
			Case MODE_ENABLED_WITH_TIMER
				last_enable_ts = now()
		End Select
	End Method

	Method disable()
		mode = MODE_DISABLED
	End Method
	
	Method is_enabled%()
		Return (parent <> Null) And (Not (mode = MODE_DISABLED))
	End Method
	
	Method ready%()
		Return (now() - last_emit_ts > interval_cur)
	End Method
	
	'like the fire() method of the TANK type, this method should be treated like a request.
	'ie, this method will only emit if it's appropriate.
	Method emit() '( alignment% = ALIGNMENT_NOT_APPLICABLE )
		If is_enabled() And ready()
			'create a new object (particle/projectile) and set it up
			Select emitter_type
				Case EMITTER_TYPE_PARTICLE
					emit_particle( particle_archetype[archetype_index].clone( Rand( 0, particle_archetype[archetype_index].img.frames.Length - 1 )))
				Case EMITTER_TYPE_PROJECTILE
					emit_projectile( projectile_archetype[archetype_index].clone( source_id ))
			End Select
			
			'interval
			last_emit_ts = now()
			interval_cur = interval.get()
			'counter
			count_cur :- 1
			
		End If
	End Method
	Method emit_particle( p:PARTICLE ) '(private)
		
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
		
		'management
		p.auto_manage()
			
	End Method
	Method emit_projectile( p:PROJECTILE ) '(private)
		
		'position
		Local dist_actual# = dist.get()
		Local dist_ang_actual# = dist_ang.get()
		p.pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang ) + dist_actual * Cos( dist_ang_actual + parent.ang )
		p.pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang ) + dist_actual * Sin( dist_ang_actual + parent.ang )
		
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
		p.vel_x = vel_actual * Cos( vel_ang_actual + ( combine_vel_ang_with_parent_ang*parent.ang )) + ( combine_vel_with_parent_vel*parent.vel_x )
		p.vel_y = vel_actual * Sin( vel_ang_actual + ( combine_vel_ang_with_parent_ang*parent.ang )) + ( combine_vel_with_parent_vel*parent.vel_y )
		
		'angular velocity
		p.ang_vel = ang_vel.get()
		
		'forces
		p.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, 0, acc.get())), True )
		
		'management
		p.auto_manage()
	
	End Method
		
	Method attach_at( ..
	off_x_new# = 0.0, off_y_new# = 0.0, ..
	dist_min_new# = 0.0, dist_max_new# = 0.0, ..
	dist_ang_min_new# = 0.0, dist_ang_max_new# = 0.0, ..
	vel_min_new# = 0.0, vel_max_new# = 0.0, ..
	vel_ang_min_new# = 0.0, vel_ang_max_new# = 0.0, ..
	acc_min_new# = 0.0, acc_max_new# = 0.0, ..
	acc_ang_min_new# = 0.0, acc_ang_max_new# = 0.0, ..
	ang_min_new# = 0.0, ang_max_new# = 0.0, ..
	ang_vel_min_new# = 0.0, ang_vel_max_new# = 0.0, ..
	ang_acc_min_new# = 0.0, ang_acc_max_new# = 0.0 )
		cartesian_to_polar( off_x_new, off_y_new, offset, offset_ang )
		dist.set( dist_min_new, dist_max_new )
		dist_ang.set( dist_ang_min_new, dist_ang_max_new )
		vel.set( vel_min_new, vel_max_new )
		vel_ang.set( vel_ang_min_new, vel_ang_max_new )
		acc.set( acc_min_new, acc_max_new )
		acc_ang.set( acc_ang_min_new, acc_ang_max_new )
		ang.set( ang_min_new, ang_max_new )
		ang_vel.set( ang_vel_min_new, ang_vel_max_new )
		ang_acc.set( ang_acc_min_new, ang_acc_max_new )
	End Method
	
	Function Archetype:Object( ..
	emitter_type%, ..
	archetype_index%, ..
	mode% = MODE_DISABLED, ..
	combine_vel_with_parent_vel%, ..
	combine_vel_ang_with_parent_ang%, ..
	inherit_ang_from_dist_ang%, ..
	inherit_vel_ang_from_ang%, ..
	inherit_acc_ang_from_vel_ang%, ..
	interval_min% = 0, interval_max% = 0, ..
	count_min% = 1, count_max% = 1, ..
	life_time_min% = INFINITY, life_time_max% = INFINITY, ..
	alpha_min# = 1.0, alpha_max# = 1.0, ..
	alpha_delta_min# = 0.0, alpha_delta_max# = 0.0, ..
	scale_min# = 1.0, scale_max# = 1.0, ..
	scale_delta_min# = 0.0, scale_delta_max# = 0.0, ..
	red_min# = 255, red_max# = 255, green_min# = 255, green_max# = 255, blue_min# = 255, blue_max# = 255, ..
	red_delta_min# = 0.0, red_delta_max# = 0.0, green_delta_min# = 0.0, green_delta_max# = 0.0, blue_delta_min# = 0.0, blue_delta_max# = 0.0 )
		Local em:EMITTER = New EMITTER
		
		'static fields
		em.emitter_type = emitter_type
		em.archetype_index = archetype_index
		em.mode = mode
		em.combine_vel_with_parent_vel = combine_vel_with_parent_vel
		em.combine_vel_ang_with_parent_ang = combine_vel_ang_with_parent_ang
		em.inherit_ang_from_dist_ang = inherit_ang_from_dist_ang
		em.inherit_vel_ang_from_ang = inherit_vel_ang_from_ang
		em.inherit_acc_ang_from_vel_ang = inherit_acc_ang_from_vel_ang
		em.interval.set( interval_min, interval_max )
		em.count.set( count_min, count_max )
		
		'emitter attributes and attribute ranges
		em.parent = Null
		em.interval_cur = em.interval.get()
		em.count_cur = em.count.get()
		em.life_time.set( life_time_min, life_time_max )
		em.alpha.set( alpha_min, alpha_max )
		em.alpha_delta.set( alpha_delta_min, alpha_delta_max )
		em.scale.set( scale_min, scale_max )
		em.scale_delta.set( scale_delta_min, scale_delta_max )
		em.red.set( red_min, red_max ); em.green.set( green_min, green_max); em.blue.set( blue_min, blue_max )
		em.red_delta.set( red_delta_min, red_delta_max ); em.green_delta.set( green_delta_min, green_delta_max ); em.blue_delta.set( blue_delta_min, blue_delta_max )
		em.last_enable_ts = now()
		
		Return em
	End Function

	Function Copy:Object( other:EMITTER, managed_list:TList = Null, new_parent:POINT = Null, source_id% = NULL_ID )
		Local em:EMITTER = New EMITTER
		If other = Null Then Return em
		
		'argument fields
		em.parent = new_parent
		em.source_id = source_id

		'emitter-specific fields
		em.emitter_type = other.emitter_type
		em.archetype_index = other.archetype_index
		em.mode = other.mode
		em.combine_vel_with_parent_vel = other.combine_vel_with_parent_vel
		em.combine_vel_ang_with_parent_ang = other.combine_vel_ang_with_parent_ang
		em.inherit_ang_from_dist_ang = other.inherit_ang_from_dist_ang
		em.inherit_vel_ang_from_ang = other.inherit_vel_ang_from_ang
		em.inherit_acc_ang_from_vel_ang = other.inherit_acc_ang_from_vel_ang
		em.interval = other.interval.clone()
		em.interval_cur = em.interval.get()
		em.count = other.count.clone()
		em.count_cur = em.count.get()
		em.last_enable_ts = now()
		
		'emitted particle-specific fields
		em.life_time = other.life_time.clone()
		em.alpha = other.alpha.clone()
		em.alpha_delta = other.alpha_delta.clone()
		em.scale = other.scale.clone()
		em.scale_delta = other.scale_delta.clone()
		
		'dynamic fields
		em.offset = other.offset
		em.offset_ang = other.offset_ang
		em.dist = other.dist.clone(); em.dist_ang = other.dist_ang.clone()
		em.vel = other.vel.clone(); em.vel_ang = other.vel_ang.clone()
		em.acc = other.acc.clone(); em.acc_ang = other.acc_ang.clone()
		em.ang = other.ang.clone()
		em.ang_vel = other.ang_vel.clone()
		em.ang_acc = other.ang_acc.clone()
		em.life_time = other.life_time.clone()
		em.alpha = other.alpha.clone(); em.alpha_delta = other.alpha_delta.clone()
		em.scale = other.scale.clone(); em.scale_delta = other.scale_delta.clone()
		em.red = other.red.clone(); em.green = other.green.clone(); em.blue = other.blue.clone()
		em.red_delta = other.red_delta.clone(); em.green_delta = other.green_delta.clone(); em.blue_delta = other.blue_delta.clone()
		
		If managed_list <> Null Then em.add_me( managed_list )
		Return em
	End Function
	
End Type

	