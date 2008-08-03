Rem
	collide.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

Const PLAYER_COLLISION_LAYER% = $0001
Const AGENT_COLLISION_LAYER% = $0002
Const SECONDARY_AGENT_COLLISION_LAYER% = $0004
Const PROJECTILE_COLLISION_LAYER% = $0008
Const SECONDARY_PROJECTILE_COLLISION_LAYER% = $0010
Const PICKUP_COLLISION_LAYER% = $0011

Const PROJECTILE_AGENT_ENERGY_COEFFICIENT# = 750.0 'energy multiplier for all collisions involving projectiles and agents
Const PROJECTILE_PROJECTILE_ENERGY_COEFFICIENT# = 0.012 'energy multiplier for all projectile-projectile collisions
Const AGENT_AGENT_ENERGY_COEFFICIENT# = 0.010 'energy multiplier for all agent-agent collisions

'______________________________________________________________________________
'Collision Detection and Resolution
Function collide_all()
	If ..
	Not FLAG_in_menu And ..
	Not FLAG_in_shop And ..
	Not FLAG_level_intro And ..
	Not FLAG_draw_help
	
		Local list:TList
		Local ag:COMPLEX_AGENT, other:COMPLEX_AGENT
		Local proj:PROJECTILE, other_proj:PROJECTILE
		Local pkp:PICKUP
		Local result:Object[]
		
		'boundary collisions (will be calculated with more generic WALL objects later)
		For list = EachIn agent_lists
			For ag = EachIn list
				If ag.pos_x < 0
					ag.pos_x = 0
					ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, 0, 750.0/ag.mass, 100 )))
				Else If ag.pos_x > arena_w
					ag.pos_x = arena_w
					ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, 180, 750.0/ag.mass, 100 )))
				End If
				If ag.pos_y < 0
					ag.pos_y = 0
					ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, 90, 750.0/ag.mass, 100 )))
				Else If ag.pos_y > arena_w
					ag.pos_y = arena_w
					ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, 270, 750.0/ag.mass, 100 )))
				End If
			Next
		Next
		For proj = EachIn projectile_list
			If proj.pos_x < 0 Or proj.pos_x > arena_w Or proj.pos_y < 0 Or  proj.pos_y > arena_w
				'explode
				Local explode:PARTICLE = particle_archetype[ proj.explosion_particle_index ].clone()
				explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
				explode.vel_x = 0; explode.vel_y = 0
				explode.ang = Rand( 0, 359 )
				explode.life_time = Rand( 300, 300 )
				explode.auto_manage()
				'prune
				proj.remove_me()
			End If
		Next

		ResetCollisions()
		'PLAYER_COLLISION_LAYER
		'AGENT_COLLISION_LAYER
		'PROJECTILE_COLLISION_LAYER
		'PICKUP_COLLISION_LAYER

		'collisions between projectiles and complex_agents
		For list = EachIn agent_lists
			For ag = EachIn list
				SetRotation( ag.ang )
				CollideImage( ag.img, ag.pos_x, ag.pos_y, 0, 0, AGENT_COLLISION_LAYER, ag )
			Next
		Next
		For proj = EachIn projectile_list
			SetRotation( proj.ang )
			result = CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, AGENT_COLLISION_LAYER, PROJECTILE_COLLISION_LAYER, proj )
			For ag = EachIn result
				'examine id's; projectiles will never collide with their owners
				If proj.source_id = ag.id
					'dump out early; this {proj} was fired by {ag}
					Continue
				End If
				'COLLISION! between {proj} & {ag}
				'create explosion particle at position of projectile, with random angle
				Local explode:PARTICLE = particle_archetype[ proj.explosion_particle_index ].clone()
				explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
				explode.vel_x = 0; explode.vel_y = 0
				explode.ang = RandF( 0.0, 359.9999 )
				explode.life_time = 300
				explode.auto_manage()
				'activate collision response for affected entity(ies)
				Local offset#, offset_ang#
				cartesian_to_polar( ag.pos_x - proj.pos_x, ag.pos_y - proj.pos_y, offset, offset_ang )
				Local total_force# = proj.mass*PROJECTILE_AGENT_ENERGY_COEFFICIENT*Sqr( proj.vel_x*proj.vel_x + proj.vel_y*proj.vel_y )
				ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - proj.ang ), 100 )))
				ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - proj.ang ), 100 )))
				'add damage sticky to agent
				'ag.add_sticky( PARTICLE( PARTICLE.Create( img_stickies, Rand( 0, img_stickies.frames.Length - 1 ), LAYER_FOREGROUND, False, 0.0, 255, 255, 255, INFINITY, 0.0, 0.0, 0.0, 0.0, proj.ang, 0.0, 0.5, 0.0, 1.0, 0.0 ))).attach_at( proj.pos_x - ag.pos_x, proj.pos_y - ag.pos_y )
				'process damage, death, cash and pickups resulting from it
				ag.receive_damage( proj.damage )
				If player.dead() 'did the player just die? (omgwtf)
					FLAG_game_over = True
				Else If ag.dead() 'non player agent killed
					'show the player how much cash they got for killing this enemy, if they killed it
					If proj.source_id = player.id
						player_cash :+ ag.cash_value
					End If
					'perhaps! spawneth teh phat lewts?!
					spawn_pickup( ag.pos_x, ag.pos_y )
					'spawn gibs
					If ag.gibs <> Null
						For Local i% = 0 To ag.gibs.frames.Length - 1
							Local gib:PARTICLE = PARTICLE( PARTICLE.Create( ag.gibs, i, LAYER_FOREGROUND, True, 0.100, 255, 255, 255, 750, 0, 0, RandF( -2.0, 2.0 ), RandF( -2.0, 2.0 ), RandF( -25, 25 ), RandF( -2.0, 2.0 ) ))
							gib.created_ts = now()
							gib.auto_manage()
							Local gib_offset#, gib_offset_ang#, gib_vel#, gib_vel_ang#
							cartesian_to_polar( gib.pos_x, gib.pos_y, gib_offset, gib_offset_ang )
							cartesian_to_polar( gib.vel_x, gib.vel_y, gib_vel, gib_vel_ang )
							gib.pos_x = ag.pos_x + gib_offset*Cos( gib_offset_ang + ag.ang )
							gib.pos_y = ag.pos_y + gib_offset*Sin( gib_offset_ang + ag.ang )
							gib.vel_x = ag.vel_x + gib_vel*Cos( gib_vel_ang + ag.ang )
							gib.vel_y = ag.vel_y + gib_vel*Sin( gib_vel_ang + ag.ang )
							gib.ang :+ ag.ang
							gib.ang_vel :+ ag.ang_vel
							gib.update()
						Next
					End If
					'remove enemy
					ag.remove_me()
				End If
				'remove the original projectile no matter what
				proj.remove_me()
			Next
		Next
		
		'collisions between agents and other agents
		For list = EachIn agent_lists
			For ag = EachIn list
				SetRotation( ag.ang )
				result = CollideImage( ag.img, ag.pos_x, ag.pos_y, 0, AGENT_COLLISION_LAYER, SECONDARY_AGENT_COLLISION_LAYER, ag )
				For other = EachIn result
					If ag.id <> other.id 'not colliding with self
						'COLLISION! between {ag} and {other}
						'activate collision response for affected entity(ies)
						Local offset#, offset_ang#
						cartesian_to_polar( ag.pos_x - other.pos_x, ag.pos_y - other.pos_y, offset, offset_ang )
						Local total_force# = other.mass*AGENT_AGENT_ENERGY_COEFFICIENT*Sqr( other.vel_x*other.vel_x + other.vel_y*other.vel_y )
						ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - other.ang ), 100 )))
						ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - other.ang ), 100 )))
					End If
				Next
			Next
		Next
		
		'collisions between projectiles and other projectiles
		For proj = EachIn projectile_list
			'only collide projectile if it does not ignore these types of collisions
			If proj.ignore_other_projectiles = True Then Continue
			SetRotation( proj.ang )
			result = CollideImage( proj.img, proj.pos_x, proj.pos_y, 0, PROJECTILE_COLLISION_LAYER, SECONDARY_PROJECTILE_COLLISION_LAYER, proj )
			For other_proj = EachIn result
				If other_proj.ignore_other_projectiles = True Then Continue
				If proj.id <> other_proj.id And proj.source_id <> other_proj.source_id
					'COLLISON! between {proj} and {other_proj}
					'activate collision response for affect entities
					Local offset#, offset_ang#
					cartesian_to_polar( proj.pos_x - other_proj.pos_x, proj.pos_y - other_proj.pos_y, offset, offset_ang )
					Local total_force# = other_proj.mass*PROJECTILE_PROJECTILE_ENERGY_COEFFICIENT*Sqr( other_proj.vel_x*other_proj.vel_x + other_proj.vel_y*other_proj.vel_y )
					other_proj.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - other_proj.ang ), 100 )))
					other_proj.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - other_proj.ang ), 100 )))
				End If
			Next
		Next 
		
		'collisions between player and pickups
		For pkp = EachIn pickup_list
			SetRotation( 0 )
			CollideImage( pkp.img, pkp.pos_x, pkp.pos_y, 0, 0, PICKUP_COLLISION_LAYER, pkp )
		Next
		SetRotation( player.ang )
		result = CollideImage( player.img, player.pos_x, player.pos_y, 0, PICKUP_COLLISION_LAYER, PLAYER_COLLISION_LAYER, player )
		For pkp = EachIn result
			'COLLISION! between {player} and {pkp}
			'give pickup to player
			player.grant_pickup( pkp ) 'i can has lewts?!
			'dump out early; only the first pickup collided with will be applied this frame
			Exit
		Next
	End If
End Function


