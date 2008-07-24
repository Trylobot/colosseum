Rem
	emitter.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global emitter_list:TList = CreateList()

Const EMITS_PARTICLES% = 0
Const EMITS_PROJECTILES% = 1

Const MODE_DISABLED% = 0
Const MODE_ENABLED_WITH_COUNTER% = 1
Const MODE_ENABLED_WITH_TIMER% = 2
Const MODE_ENABLED_FOREVER% = 3

Type EMITTER extends MANAGED_OBJECT
	
	Field parent:POINT 'parent point object (optional)
	Field emitter_type% 'emitter type (particle/projectile)
	Field archetype_index_min% 'particle archetype range - lower bound
	Field archetype_index_max% 'particle archetype range - upper bound
	Field mode% 'emitter mode (off/counter/timer)
	Field interval_min% 'delay between particles - lower bound
	Field interval_max% 'delay between particles - upper bound
	Field interval% '(private) delay between particles - pre-calculated
	Field last_emit_ts% '(private) timestamp of last emitted particle
	Field time_to_live% 'time until this emitter is disabled
	Field last_enable_ts% '(private) timestamp of the last time this emitter was enabled
	Field count_min% 'number of particles to emit - lower bound
	Field count_max% 'number of particles to emit - upper bound
	Field count_cur% '(private) number of particles remaining to emit - pre-calculated and tracked
	Field combine_vel_with_parent_vel% 'setting - whether to add the parent's velocity to the emitted particle's velocity
	Field combine_vel_ang_with_parent_ang% 'setting - whether to add the parent's orientation to the emitted particle's direction of travel
	Field inherit_ang_from_dist_ang% 'setting - whether to set the angle to the already-determined "dist_ang" or a new angle
	Field inherit_vel_ang_from_ang% 'setting - whether to set the velocity angle to the already-determined "ang" or a new angle
	Field inherit_acc_ang_from_vel_ang% 'setting - whether to set the acceleration angle to the already-determined "vel_ang" or a new angle
	
	Field offset# 'offset vector magnitude (added to parent's position)
	Field offset_ang# 'offset vector angle (added to parent's position)
	Field dist_min# 'distance vector magnitude (added to offset) - lower bound
	Field dist_max# 'distance vector magnitude (added to offset) - upper bound
	Field dist_ang_min# 'distance vector angle (added to offset) - lower bound
	Field dist_ang_max# 'distance vector angle (added to offset) - upper bound
	Field vel_min# 'velocity vector magnitude - lower bound
	Field vel_max# 'velocity vector magnitude - upper bound
	Field vel_ang_min# 'velocity vector angle - lower bound
	Field vel_ang_max# 'velocity vector angle - upper bound
	Field acc_min# 'acceleration vector magnitude - lower bound
	Field acc_max# 'acceleration vector magnitude - upper bound
	Field acc_ang_min# 'acceleration vector angle - lower bound
	Field acc_ang_max# 'acceleration vector angle - upper bound
	Field ang_min# 'orientation - lower bound
	Field ang_max# 'orientation - upper bound
	Field ang_vel_min# 'angular velocity - lower bound
	Field ang_vel_max# 'angular velocity - upper bound
	Field ang_acc_min# 'angular acceleration - lower bound
	Field ang_acc_max# 'angular acceleration - upper bound
	Field life_time_min% 'life time - lower bound
	Field life_time_max% 'life time - upper bound
	Field alpha_min# 'initial alpha value - lower bound
	Field alpha_max# 'initial alpha value - upper bound
	Field alpha_delta_min# 'alpha rate of change - lower bound
	Field alpha_delta_max# 'alpha rate of change - upper bound
	Field scale_min# 'initial scale value - lower bound
	Field scale_max# 'initial scale value - upper bound
	Field scale_delta_min# 'scale rate of change - lower bound
	Field scale_delta_max# 'scale rate of change - upper bound
	
	Method New()
	End Method
	
	Method update()
		Select mode
			Case MODE_ENABLED_WITH_COUNTER
				If count_cur <= 0 Then disable()
			Case MODE_ENABLED_WITH_TIMER
				If (now() - last_enable_ts) >= time_to_live Then disable()
		End Select
	End Method
	
	Method ready%()
		Return ..
			(Not (mode = MODE_DISABLED)) And ..
			(now() - last_emit_ts) >= interval
	End Method
	
	Method enable( new_mode% = MODE_ENABLED_FOREVER )
		mode = new_mode
		Select mode
			Case MODE_ENABLED_WITH_COUNTER
				count_cur = Rand( count_min, count_max )
			Case MODE_ENABLED_WITH_TIMER
				last_enable_ts = now()
		End Select
	End Method

	Method disable()
		mode = MODE_DISABLED
	End Method
	
	'like the fire() method of the TANK type, this method should be treated like a request.
	'ie, this method will only emit if it's appropriate.
	Method emit( alignment% = ALIGNMENT_NOT_APPLICABLE )
		If ready()
			
			'reserve space for particle, and add it to the correct managed list
			Local p:PARTICLE
			Local index% = Rand( archetype_index_min, archetype_index_max )
			If emitter_type = EMITS_PARTICLES
				p = Copy_PARTICLE( particle_archetype[index] )
			Else If emitter_type = EMITS_PROJECTILES
				Local list:TList = Null
				If      alignment = ALIGNMENT_FRIENDLY Then list = friendly_projectile_list ..
				Else If alignment = ALIGNMENT_HOSTILE  Then list = hostile_projectile_list
				p = PARTICLE( Copy_PROJECTILE( projectile_archetype[index], list ))
			End If
			
			'particle position components
			Local dist# = RandF( dist_min, dist_max )
			Local dist_ang# = RandF( dist_ang_min, dist_ang_max )
			If parent <> Null
				p.pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang ) + dist * Cos( dist_ang + parent.ang )
				p.pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang ) + dist * Sin( dist_ang + parent.ang )
			Else
				p.pos_x = offset * Cos( offset_ang ) + dist * Cos( dist_ang )
				p.pos_y = offset * Sin( offset_ang ) + dist * Sin( dist_ang )
			End If
			
			'particle orientation
			If inherit_ang_from_dist_ang
				p.ang = dist_ang
			Else
				p.ang = RandF( ang_min, ang_max )
			End If
			If parent <> Null
				p.ang :+ parent.ang
			End If

			'particle angular velocity
			p.ang_vel = RandF( ang_vel_min, ang_vel_max )
			
			'particle angular acceleration
			p.ang_acc = RandF( ang_acc_min, ang_acc_max )
			
			'particle velocity components
			Local vel# = RandF( vel_min, vel_max )
			Local vel_ang#
			If inherit_vel_ang_from_ang
				vel_ang = p.ang
			Else
				vel_ang = RandF( vel_ang_min, vel_ang_max )
			End If
			If parent <> Null
				p.vel_x = vel * Cos( vel_ang + ( combine_vel_ang_with_parent_ang*parent.ang )) + ( combine_vel_with_parent_vel*parent.vel_x )
				p.vel_y = vel * Sin( vel_ang + ( combine_vel_ang_with_parent_ang*parent.ang )) + ( combine_vel_with_parent_vel*parent.vel_y )
			Else
				p.vel_x = vel * Cos( vel_ang )
				p.vel_y = vel * Sin( vel_ang )
			End If
			
			'particle acceleration components
			Local acc# = RandF( acc_min, acc_max )
			Local acc_ang#
			If inherit_acc_ang_from_vel_ang
				acc_ang = vel_ang
			Else
				acc_ang = RandF( acc_ang_min, acc_ang_max )
			End If
			If parent <> Null
				p.acc_x = acc * Cos( acc_ang + parent.ang )
				p.acc_y = acc * Sin( acc_ang + parent.ang )
			Else
				p.acc_x = acc * Cos( acc_ang )
				p.acc_y = acc * Sin( acc_ang )
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
			interval = Rand( interval_min, interval_max )
			'emitter counter
			count_cur :- 1
			
		End If
	End Method
	
	Method attach_to( ..
	new_parent:POINT, ..
	off_x_new#, off_y_new#, ..
	dist_min_new#, dist_max_new#, ..
	dist_ang_min_new#, dist_ang_max_new#, ..
	vel_min_new#, vel_max_new#, ..
	vel_ang_min_new#, vel_ang_max_new#, ..
	acc_min_new#, acc_max_new#, ..
	acc_ang_min_new#, acc_ang_max_new#, ..
	ang_min_new#, ang_max_new#, ..
	ang_vel_min_new#, ang_vel_max_new#, ..
	ang_acc_min_new#, ang_acc_max_new# )
		parent = new_parent
		cartesian_to_polar( off_x_new, off_y_new, offset, offset_ang )
		dist_min = dist_min_new; dist_max = dist_max_new
		dist_ang_min = dist_ang_min_new; dist_ang_max = dist_ang_max_new
		vel_min = vel_min_new; vel_max = vel_max_new
		vel_ang_min = vel_ang_min_new; vel_ang_max = vel_ang_max_new
		acc_min = acc_min_new; acc_max = acc_max_new
		acc_ang_min = acc_ang_min_new; acc_ang_max = acc_ang_max_new
		ang_min = ang_min_new; ang_max = ang_max_new
		ang_vel_min = ang_vel_min_new; ang_vel_max = ang_vel_max_new
		ang_acc_min = ang_acc_min_new; ang_acc_max = ang_acc_max_new
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_EMITTER:EMITTER( ..
emitter_type%, ..
archetype_index_min%, archetype_index_max%, ..
mode%, ..
combine_vel_with_parent_vel%, ..
combine_vel_ang_with_parent_ang%, ..
inherit_ang_from_dist_ang%, ..
inherit_vel_ang_from_ang%, ..
inherit_acc_ang_from_vel_ang%, ..
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
	em.mode = mode
	em.combine_vel_with_parent_vel = combine_vel_with_parent_vel
	em.combine_vel_ang_with_parent_ang = combine_vel_ang_with_parent_ang
	em.inherit_ang_from_dist_ang = inherit_ang_from_dist_ang
	em.inherit_vel_ang_from_ang = inherit_vel_ang_from_ang
	em.inherit_acc_ang_from_vel_ang = inherit_acc_ang_from_vel_ang
	em.interval_min = interval_min; em.interval_max = interval_max
	em.interval = Rand( em.interval_min, em.interval_max )
	em.last_enable_ts = now()
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
	em.acc_min = 0; em.acc_max = 0
	em.acc_ang_min = 0; em.acc_ang_max = 0
	em.ang_min = 0; em.ang_max = 0
	em.ang_vel_min = 0; em.ang_vel_max = 0
	em.ang_acc_min = 0; em.ang_acc_max = 0

	Return em
End Function
'______________________________________________________________________________
Function Copy_EMITTER:EMITTER( other:EMITTER, manage% = False, new_parent:POINT = Null )
	Local em:EMITTER = New EMITTER
	If other = Null Then Return em
	
	'emitter-specific fields
	em.emitter_type = other.emitter_type
	em.archetype_index_min = other.archetype_index_min; em.archetype_index_max = other.archetype_index_max
	em.mode = other.mode
	em.combine_vel_with_parent_vel = other.combine_vel_with_parent_vel
	em.combine_vel_ang_with_parent_ang = other.combine_vel_ang_with_parent_ang
	em.inherit_ang_from_dist_ang = other.inherit_ang_from_dist_ang
	em.inherit_vel_ang_from_ang = other.inherit_vel_ang_from_ang
	em.inherit_acc_ang_from_vel_ang = other.inherit_acc_ang_from_vel_ang
	em.interval_min = other.interval_min; em.interval_max = other.interval_max
	em.interval = Rand( em.interval_min, em.interval_max )
	em.last_enable_ts = now()
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
	em.acc_min = other.acc_min; em.acc_max = other.acc_max
	em.acc_ang_min = other.acc_ang_min; em.acc_ang_max = other.acc_ang_max
	em.ang_min = other.ang_min; em.ang_max = other.ang_max
	em.ang_vel_min = other.ang_vel_min; em.ang_vel_max = other.ang_vel_max
	em.ang_acc_min = other.ang_acc_min; em.ang_acc_max = other.ang_acc_max
	
	If manage Then em.add_me( emitter_list )
	Return em
End Function


