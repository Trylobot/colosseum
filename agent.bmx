Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type AGENT Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field gibs:TImage 'gib image(s)
	Field max_health# 'maximum health
	Field cash_value% 'cash to be awarded player on this agent's death
	Field death_emitters:TList

	Field cur_health# 'current health
	
	Method New()
		force_list = CreateList()
		death_emitters = CreateList()
	End Method
	
	Method dead%()
		Return (cur_health <= 0)
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no overkill
	End Method

	Method self_destruct( other:AGENT )
		'damage
		other.receive_damage( 100 )
		'explosive forces
		Local offset#, offset_ang#
		cartesian_to_polar( pos_x - other.pos_x, pos_y - other.pos_y, offset, offset_ang )
		Local total_force# = 100.0
		other.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - ang ), 100 )))
		other.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - ang ), 100 )))
		'death effects
		die()
	End Method
	
	Method die()
		'spawn halo particle
		Local halo:PARTICLE = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_halo,,,,, LAYER_BACKGROUND, False,,,,,,,, 200, pos_x, pos_y, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 1.0, -0.1000 ))
		halo.auto_manage()
		'spawn gibs
		If gibs <> Null
			For Local i% = 0 To gibs.frames.Length - 1
				Local gib:PARTICLE = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, gibs, i,,,, LAYER_BACKGROUND, True, 0.100,,,,,,, 750 ))
				Local gib_offset#, gib_offset_ang#
				cartesian_to_polar( gib.pos_x, gib.pos_y, gib_offset, gib_offset_ang )
				gib.pos_x = pos_x + gib_offset*Cos( gib_offset_ang + ang )
				gib.pos_y = pos_y + gib_offset*Sin( gib_offset_ang + ang )
				Local gib_vel#, gib_vel_ang#
				gib_vel = RandF( -2.0, 2.0 )
				gib_vel_ang = RandF( 0.0, 359.9999 )
				gib.vel_x = vel_x + gib_vel*Cos( gib_vel_ang + ang )
				gib.vel_y = vel_y + gib_vel*Sin( gib_vel_ang + ang )
				gib.ang = ang
				gib.update()
				gib.created_ts = now()
				gib.auto_manage()
			Next
		End If
		For Local em:EMITTER = EachIn death_emitters
			em.enable( MODE_ENABLED_WITH_COUNTER )
			While em.ready() And em.is_enabled()
				em.update()
				em.emit()
			End While
		Next
		'delete self
		cur_health = 0
		unmanage()
	End Method
	
End Type

