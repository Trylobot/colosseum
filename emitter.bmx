Rem
	emitter.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const EMITTER_TYPE_PARTICLE% = 0
Const EMITTER_TYPE_PROJECTILE% = 1

Type EMITTER extends MANAGED_OBJECT
	
	'Parent entity (optional, null if not applicable)
	Field parent:POINT
	'particle set to use for particle emission
	Field emitter_type%
	Field archetype_index_min%
	Field archetype_index_max%
	'Delay time range between particles
	Field interval_min%
	Field interval_max%
	Field interval_next%
	'Timestamp of last emitted particle
	Field last_emit_ts%
	'Enable-disable time interval
	Field enable_time% 'desired length of time (in milliseconds) until the object is disabled (-1 for infinite)
	Field last_enabled_ts% 'timestamp of last enable
	'Enable-disable particle emission count
	Field count_min%
	Field count_max%
	Field count_cur% 'desired number of particles to be emitted (-1 for infinite)
	
	'Position offset for the emitter, and a local origin for emitted particles (will try to add to parent's position)
	Field offset#
	Field offset_ang#
	'Distance range for emitted particles
	Field dist_min#
	Field dist_max#
	'Angle for distance range for emitted particles
	Field dist_ang_min#
	Field dist_ang_max#
	'Velocity range for emitted particles (projectiles will try to inherit parent's velocity)
	Field vel_min#
	Field vel_max#
	'Velocity angle range for emitted particles
	Field vel_ang_min#
	Field vel_ang_max#
	'Angle range for emitted particles (will try to include parent's angle)
	Field ang_min#
	Field ang_max#
	'Angular Velocity range for emitted particles
	Field ang_vel_min#
	Field ang_vel_max#
	'Life time range for emitted particles
	Field life_time_min%
	Field life_time_max%
	'Alpha range for emitted particles
	Field alpha_min#
	Field alpha_max#
	Field alpha_delta_min#
	Field alpha_delta_max#
	'Scale range for emitted particles
	Field scale_min#
	Field scale_max#
	Field scale_delta_min#
	Field scale_delta_max#
	
	Method New()
	End Method
	
	Method alive%()
		Return ..
			enable_time < 0 Or ..
			(now() - last_enabled_ts) <= enable_time Or ..
			count_cur <> 0
	End Method
	
	Method ready%()
		Return ..
			(now() - last_emit_ts) >= interval_next Or ..
			count_cur <> 0
	End Method
	
	Method enable_timer( new_enable_time% = infinite_life_time )
		enable_time = new_enable_time
		last_enabled_ts = now()
	End Method
	Method enable_counter( limit% = True )
		If limit
			count_cur = Rand( count_min, count_max )
		Else
			count_cur = infinite_count
		End If
	End Method
	
	Method disable()
		enable_time = 0
		count_cur = 0
	End Method
	
	'like the fire() method of the TANK type, this method should be treated like a request.
	'ie, this method will only emit if it's appropriate.
	Method emit()
		If alive() And ready()
			
			'reserve space for particle
			Local p:PARTICLE
			Local index% = Rand( archetype_index_min, archetype_index_max )
			If emitter_type = EMITTER_TYPE_PARTICLE
				p = Copy_PARTICLE( particle_archetype[index] )
			Else If emitter_type = EMITTER_TYPE_PROJECTILE
				p = PARTICLE( Copy_PROJECTILE( projectile_archetype[index] ))
			End If
			
			'particle position components
			Local dist# = RandF( dist_min, dist_max )
			Local dist_ang# = RandF( dist_ang_min, dist_ang_max )
			If parent <> Null
				p.pos_x = parent.pos_x + offset * Cos( parent.ang + offset_ang ) + dist * Cos( parent.ang + dist_ang )
				p.pos_y = parent.pos_y + offset * Sin( parent.ang + offset_ang ) + dist * Sin( parent.ang + dist_ang )
			Else
				p.pos_x = offset * Cos( offset_ang ) + dist * Cos( dist_ang )
				p.pos_y = offset * Sin( offset_ang ) + dist * Sin( dist_ang )
			End If
			
			'particle orientation
			p.ang = RandF( ang_min, ang_max )
			If parent <> Null
				p.ang :+ parent.ang
			End If
			
			'particle angular velocity
			p.ang_vel = RandF( ang_vel_min, ang_vel_max )
			
			'particle velocity components
			Local vel# = RandF( vel_min, vel_max )
			Local vel_ang# = RandF( vel_ang_min, vel_ang_max )
			If parent <> Null
				p.vel_x = vel * Cos( vel_ang + parent.ang )
				p.vel_y = vel * Sin( vel_ang + parent.ang )
			Else
				p.vel_x = vel * Cos( vel_ang )
				p.vel_y = vel * Sin( vel_ang )
			End If
			If emitter_type = EMITTER_TYPE_PROJECTILE And parent <> Null
				p.vel_x :+ parent.vel_x
				p.vel_y :+ parent.vel_y
			End If
			
			'particle alpha
			p.alpha = RandF( alpha_min, alpha_max )
			p.alpha_delta = RandF( alpha_delta_min, alpha_delta_max )
			
			'particle scale
			p.scale = RandF( scale_min, scale_max )
			p.scale_delta = RandF( scale_delta_min, scale_delta_max )
			
			'particle life time
			p.created_ts = now()
			p.life_time = Rand( life_time_min, life_time_max )
			
			'emitter interval
			last_emit_ts = now()
			interval_next = Rand( interval_min, interval_max )
			'emitter counter
			If count_cur > 0 Then count_cur :- 1
			
		End If
	End Method
	
	Method attach_to( ..
	new_parent:POINT, ..
	off_x_new#, off_y_new#, ..
	dist_min_new#, dist_max_new#, ..
	dist_ang_min_new#, dist_ang_max_new#, ..
	vel_min_new#, vel_max_new#, ..
	vel_ang_min_new#, vel_ang_max_new#, ..
	ang_min_new#, ang_max_new#, ..
	ang_vel_min_new#, ang_vel_max_new# )
		parent = new_parent
		offset = Sqr( off_x_new*off_x_new + off_y_new*off_y_new )
		offset_ang = ATan( off_y_new/off_x_new )
		If off_x_new < 0 Then offset_ang :- 180
		dist_min = dist_min_new; dist_max = dist_max_new
		dist_ang_min = dist_ang_min_new; dist_ang_max = dist_ang_max_new
		vel_min = vel_min_new; vel_max = vel_max_new
		vel_ang_min = vel_ang_min_new; vel_ang_max = vel_ang_max_new
		ang_min = ang_min_new; ang_max = ang_max_new
		ang_vel_min = ang_vel_min_new; ang_vel_max = ang_vel_max_new
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_EMITTER:EMITTER( ..
emitter_type%, ..
archetype_index_min%, archetype_index_max%, ..
interval_min%, interval_max%, ..
count_min%, count_max%, ..
life_time_min%, life_time_max%, ..
alpha_min# = 1.0, alpha_max# = 1.0, ..
alpha_delta_min# = 0.0, alpha_delta_max# = 0.0, ..
scale_min# = 1.0, scale_max# = 1.0, ..
scale_delta_min# = 0.0, scale_delta_max# = 0.0 )
	Local em:EMITTER = New EMITTER
	
	'static fields
	'emitter attributes and attribute ranges
	em.emitter_type = emitter_type
	em.archetype_index_min = archetype_index_min; em.archetype_index_max = archetype_index_max 
	em.interval_min = interval_min; em.interval_max = interval_max
	em.interval_next = Rand( em.interval_min, em.interval_max )
	em.last_enabled_ts = now()
	em.count_min = count_min; em.count_max = count_max
	'emitted particle attribute ranges
	em.life_time_min = life_time_min; em.life_time_max = life_time_max
	em.alpha_min = alpha_min; em.alpha_max = alpha_max
	em.alpha_delta_min = alpha_delta_min; em.alpha_delta_max = alpha_delta_max
	em.scale_min = scale_min; em.scale_max = scale_max
	em.scale_delta_min = scale_delta_min; em.scale_delta_max = scale_delta_max
	
	'dynamic fields
	em.parent = Null
	em.offset = 0
	em.offset_ang = 0
	em.dist_min = 0; em.dist_max = 0
	em.dist_ang_min = 0; em.dist_ang_max = 0
	em.vel_min = 0; em.vel_max = 0
	em.vel_ang_min = 0; em.vel_ang_max = 0
	em.ang_min = 0; em.ang_max = 0
	em.ang_vel_min = 0; em.ang_vel_max = 0

	Return em
End Function
'______________________________________________________________________________
Function Copy_EMITTER:EMITTER( other:EMITTER, new_parent:POINT = Null )
	Local em:EMITTER = New EMITTER
	
	'emitter-specific fields
	em.emitter_type = other.emitter_type
	em.archetype_index_min = other.archetype_index_min; em.archetype_index_max = other.archetype_index_max 
	em.interval_min = other.interval_min; em.interval_max = other.interval_max
	em.interval_next = Rand( em.interval_min, em.interval_max )
	em.last_enabled_ts = now()
	em.count_min = other.count_min; em.count_max = other.count_max
	
	'emitted particle-specific fields
	em.life_time_min = other.life_time_min; em.life_time_max = other.life_time_max
	em.alpha_min = other.alpha_min; em.alpha_max = other.alpha_max
	em.alpha_delta_min = other.alpha_delta_min; em.alpha_delta_max = other.alpha_delta_max
	em.scale_min = other.scale_min; em.scale_max = other.scale_max
	em.scale_delta_min = other.scale_delta_min; em.scale_delta_max = other.scale_delta_max
	
	'dynamic fields
	em.parent = new_parent
	em.offset = other.offset
	em.offset_ang = other.offset_ang
	em.dist_min = other.dist_min; em.dist_max = other.dist_max
	em.dist_ang_min = other.dist_ang_min; em.dist_ang_max = other.dist_ang_max
	em.vel_min = other.vel_min; em.vel_max = other.vel_max
	em.vel_ang_min = other.vel_ang_min; em.vel_ang_max = other.vel_ang_max
	em.ang_min = other.ang_min; em.ang_max = other.ang_max
	em.ang_vel_min = other.ang_vel_min; em.ang_vel_max = other.ang_vel_max
	
	em.add_me( emitter_list )
	Return em
End Function


