Rem
	collide.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Collision Detection and Resolution
Function collide_all()
	If Not FLAG_in_menu And Not FLAG_draw_help
	
		Local list:TList
		Local ag:COMPLEX_AGENT
		Local proj:PROJECTILE
		Local pkp:PICKUP
		Local result:Object[]
		
		'boundary collisions (will be calculated with more generic WALL objects later)
		For list = EachIn agent_lists
			For ag = EachIn list
				If ag.pos_x < 0
					ag.pos_x = 0
					Create_FORCE( PHYSICS_FORCE, 0 - ag.ang, 75.0, 100 ).add_me( ag.force_list )
				Else If ag.pos_x > arena_w
					ag.pos_x = arena_w
					Create_FORCE( PHYSICS_FORCE, 180 - ag.ang, 75.0, 100 ).add_me( ag.force_list )
				End If
				If ag.pos_y < 0
					ag.pos_y = 0
					Create_FORCE( PHYSICS_FORCE, 90 - ag.ang, 75.0, 100 ).add_me( ag.force_list ) ..
				Else If ag.pos_y > arena_w
					ag.pos_y = arena_w
					Create_FORCE( PHYSICS_FORCE, 270 - ag.ang, 75.0, 100 ).add_me( ag.force_list )
				End If
			Next
		Next
		For proj = EachIn projectile_list
			If proj.pos_x < 0 Or proj.pos_x > arena_w Or proj.pos_y < 0 Or  proj.pos_y > arena_w
				'explode
				Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
				explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
				explode.vel_x = 0; explode.vel_y = 0
				explode.ang = Rand( 0, 359 )
				explode.life_time = Rand( 300, 300 )
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
				'proj.exp_img, proj.pos_x, proj.pos_y, 0, 0, Rand( 0, 359 ), 0, 0, projectile_explode_life_time )
				Local explode:PARTICLE = Copy_PARTICLE( particle_archetype[ proj.explosion_particle_index ])
				explode.pos_x = proj.pos_x; explode.pos_y = proj.pos_y
				explode.vel_x = 0; explode.vel_y = 0
				explode.ang = Rand( 0, 359 )
				explode.life_time = Rand( 300, 300 )
				'activate collision response for affected entity(ies)
				Local offset#, offset_ang#
				cartesian_to_polar( ag.pos_x - proj.pos_x, ag.pos_y - proj.pos_y, offset, offset_ang )
				Local total_force# = proj.mass*PROJECTILE_ENERGY_COEFFICIENT*Sqr( proj.vel_x*proj.vel_x + proj.vel_y*proj.vel_y )
				Create_FORCE( PHYSICS_FORCE, offset_ang + 180, total_force*Cos( offset_ang - proj.ang ), 100 ).add_me( ag.force_list )
				Create_FORCE( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - proj.ang ), 100 ).add_me( ag.force_list )
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
					'remove enemy
					ag.remove_me()
				End If
				'remove the original projectile no matter what
				proj.remove_me()
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


