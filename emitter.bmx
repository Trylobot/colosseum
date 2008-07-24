Rem
	emitter.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type EMITTER
	'Parent entity (optional, null if not applicable)
	Field parent:POINT
	'Image set to use for particle emission
	Field images:TImage[]
	'Position offset for emitted particles (from location of parent entity, or origin if no parent)
	Field off_x#
	Field off_y#
	Field offset#
	Field offset_ang#
	'Velocity range for emitted particles
	Field vel_min#
	Field vel_max#
	'Angle range for emitted particles
	Field ang_min#
	Field ang_max#
	'Distance range for emitted particles
	Field dist_min#
	Field dist_max#
	'Time delay range for emitted particles
	Field p_life_min#
	Field p_life_max#
	'Time delay range for emission interval
	Field interval_min%
	Field interval_max%
	'Actual time delay until next particle
	Field interval_next%
	'Timestamp of last emitted particle
	Field last_emit_ts%
	'Enable-disable time interval
	Field enable_time% 'desired length of time (in milliseconds) until the object is disabled (-1 for infinite)
	Field last_enabled_ts% 'timestamp of last enable
	
	Method New()
	End Method
	
	Method set( ..
	images_new:TImage[], ..
	off_x_new#, off_y_new#, ..
	ang_min_new#, ang_max_new#, ..
	dist_min_new#, dist_max_new#, ..
	p_life_min_new#, p_life_max_new#, ..
	interval_min_new%, interval_max_new%, ..
	enable_time_new% = -1 )
		images = images_new
		off_x = off_x_new; off_y = off_y_new
		offset = Sqr( off_x*off_x + off_y*off_y )
		offset_ang = ATan( off_y/off_x )
		If off_x < 0
			offset_ang :- 180
		End If
		ang_min = ang_min_new; ang_max = ang_max_new
		dist_min = dist_min_new; dist_max = dist_max_new
		p_life_min = p_life_min_new; p_life_max = p_life_max_new
		interval_min = interval_min_new; interval_max = interval_max_new
		interval_next = Rand( interval_min_new, interval_max_new )
		last_enabled_ts = now()
	End Method
	
	Method alive%()
		Return enable_time < 0 Or (now() - last_enabled_ts) <= enable_time
	End Method
	
	Method ready%()
		Return (now() - last_emit_ts) >= interval_next
	End Method
	
	Method enable( new_enable_time% = -1 )
		enable_time = new_enable_time
		last_enabled_ts = now()
	End Method
	
	Method disable()
		enable_time = 0
	End Method
	
	'like the fire() method of the TANK type, this method should be treated like a request.
	'ie, this method will emit only if it appropriate to do so.
	Method emit()
		If alive() And ready()
			Local em_part:PARTICLE = New PARTICLE
			em_part.img = images[ Rand( 0, images.Length - 1 )]
			If parent <> Null
				ang_min :+ parent.ang
				ang_max :+ parent.ang
			End If
			em_part.ang = Rand( ang_min, ang_max )
			Local dist# = 0.001 * Rand( 1000 * dist_min, 1000 * dist_max )
			If parent <> Null
				em_part.pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang ) + dist * Cos( em_part.ang )
				em_part.pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang ) + dist * Sin( em_part.ang )
			Else
				em_part.pos_x = off_x + dist * Cos( em_part.ang )
				em_part.pos_y = off_y + dist * Sin( em_part.ang )
			End If
			Local vel# = 0.001 * Rand( vel_min * 1000, vel_max * 1000 )
			em_part.vel_x = vel * Cos( em_part.ang )
			em_part.vel_y = vel * Sin( em_part.ang )
			'If parent <> Null
			'	em_part.vel_x :+ parent.vel_x
			'	em_part.vel_y :+ parent.vel_y
			'End If
			em_part.created_ts = now()
			em_part.life_time = Rand( p_life_min, p_life_max )
	
			em_part.add_me( particle_list )
			
			last_emit_ts = now()
			interval_next = Rand( interval_min, interval_max )
		End If
	End Method
	
End Type
Function Create_EMITTER:EMITTER( ..
images:TImage[], ..
off_x#, off_y#, ..
ang_min#, ang_max#, ..
dist_min#, dist_max#, ..
p_life_min#, p_life_max#, ..
interval_min%, interval_max%, ..
enable_time% = -1 )
	Local em:EMITTER = New EMITTER
	em.set( ..
		images, ..
		off_x, off_y, ..
		ang_min, ang_max, ..
		dist_min, dist_max, ..
		p_life_min, p_life_max, ..
		interval_min, interval_max, ..
		enable_time )
	Return em
End Function
