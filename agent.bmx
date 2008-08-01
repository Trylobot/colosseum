Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type AGENT Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field max_health# 'maximum health
	Field cash_value% 'cash to be awarded player on this agent's death

	Field cur_health# 'current health
	
	Method New()
		force_list = CreateList()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
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
		'explosion effect
		Local explode:PARTICLE = particle_archetype[PARTICLE_INDEX_CANNON_EXPLOSION].clone()
		explode.pos_x = pos_x; explode.pos_y = pos_y
		explode.vel_x = 0; explode.vel_y = 0
		explode.ang = Rand( 0, 359 )
		explode.life_time = Rand( 300, 300 )
		explode.auto_manage()
		'explosive forces
		Local offset#, offset_ang#
		cartesian_to_polar( pos_x - other.pos_x, pos_y - other.pos_y, offset, offset_ang )
		Local total_force# = 100.0
		other.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - ang ), 100 )))
		other.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - ang ), 100 )))
		'delete self
		cur_health = 0
		remove_me()
	End Method
	
End Type

