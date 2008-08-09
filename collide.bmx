Rem
	collide.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Collision Detection and Resolution

Const PLAYER_COLLISION_LAYER% = $0001
Const AGENT_COLLISION_LAYER% = $0002
Const SECONDARY_AGENT_COLLISION_LAYER% = $0004
Const PROJECTILE_COLLISION_LAYER% = $0008
Const SECONDARY_PROJECTILE_COLLISION_LAYER% = $0010
Const WALL_COLLISION_LAYER% = $0020
Const PICKUP_COLLISION_LAYER% = $0040

Const PROJECTILE_AGENT_ENERGY_COEFFICIENT# = 500.0 'energy multiplier for all collisions involving projectiles and agents
Const PROJECTILE_PROJECTILE_ENERGY_COEFFICIENT# = 0.012 'energy multiplier for all projectile-projectile collisions
Const AGENT_AGENT_ENERGY_COEFFICIENT# = 0.010 'energy multiplier for all agent-agent collisions

Const WALL_NUDGE_DIST# = 0.20

Function clamp_ang_to_bifurcate_wall_diagonals#( ang#, wall%[] )
	Local wx# = wall_mid_x( wall ), wy# = wall_mid_y(wall)
	'wall_angle[4] = angle from mid to [ top_left, top_right, bottom_right, bottom_left ].
	Local wall_angle#[] = ..
	[	vector_diff_angle( wx,wy, wall[1],        wall[2] ), ..
		vector_diff_angle( wx,wy, wall[1]+wall[3],wall[2] ), ..
		vector_diff_angle( wx,wy, wall[1]+wall[3],wall[2]+wall[4] ), ..
		vector_diff_angle( wx,wy, wall[1],        wall[2]+wall[4] ) ]
	
	For Local i% = 0 To 3
		If      ang < wall_angle[0] Then Return 180 ..
		Else If ang < wall_angle[1] Then Return 270 ..
		Else If ang < wall_angle[2] Then Return 0 ..
		Else If ang < wall_angle[3] Then Return 90 ..
		Else                             Return 180
	Next
End Function

Function collide_all()
	If ..
	Not FLAG_in_menu And ..
	Not FLAG_in_shop And ..
	Not FLAG_draw_help
	
		Local list:TList
		Local ag:COMPLEX_AGENT, other:COMPLEX_AGENT
		Local proj:PROJECTILE, other_proj:PROJECTILE
		Local pkp:PICKUP
		Local result:Object[], result_obj:Object
		
		ResetCollisions()
		
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
				If proj.source_id <> ag.id
					'COLLISION! between {proj} & {ag}
					'activate impact emitter
					proj.impact()
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
					If ag.dead() 'some agent was killed
						'show the player how much cash they got for killing this enemy, if they killed it
						If proj.source_id = player.id
							player_cash :+ ag.cash_value
						End If
						'perhaps! spawneth teh phat lewts?!
						spawn_pickup( ag.pos_x, ag.pos_y )
						'agent death
						ag.die()
						If player = ag 'player just died? (omgwtf)
							FLAG_game_over = True
						End If
					End If
					'remove projectile
					proj.remove_me()
				End If
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
		
		'collisions between walls and {agents|projectiles}
		For Local cur_wall_list:TList = EachIn all_walls
			For Local wall%[] = EachIn cur_wall_list
				SetRotation( 0 )
				result = CollideRect( wall[1],wall[2], wall[3],wall[4], AGENT_COLLISION_LAYER, WALL_COLLISION_LAYER, wall )
				For ag = EachIn result
					'COLLISION! between {ag} and {wall}
					Local offset#, offset_ang#
					cartesian_to_polar( ag.pos_x - wall_mid_x(wall), ag.pos_y - wall_mid_y(wall), offset, offset_ang )
					Select clamp_ang_to_bifurcate_wall_diagonals( offset_ang, wall )
						Case 0
							ag.pos_x :+ WALL_NUDGE_DIST
							ag.vel_x = 0.0
							ag.acc_x = 0.0
						Case 180
							ag.pos_x :- WALL_NUDGE_DIST
							ag.vel_x = 0.0
							ag.acc_x = 0.0
						Case 90
							ag.pos_y :+ WALL_NUDGE_DIST
							ag.vel_y = 0.0
							ag.acc_y = 0.0
						Case 270
							ag.pos_y :- WALL_NUDGE_DIST
							ag.vel_y = 0.0
							ag.acc_y = 0.0
					End Select
				Next
			Next
			For Local wall%[] = EachIn cur_wall_list
				SetRotation( 0 )
				result = CollideRect( wall[1],wall[2], wall[3],wall[4], PROJECTILE_COLLISION_LAYER, WALL_COLLISION_LAYER, wall )
				For proj = EachIn result
					'COLLISION! between {proj} and {wall}
					proj.impact()
					proj.remove_me()
				Next
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

		'collisions between projectiles and other projectiles (disabled)
		Rem
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
		EndRem
		
	End If
End Function


