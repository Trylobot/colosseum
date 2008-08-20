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
Const DOOR_COLLISION_LAYER% = $0040
Const PICKUP_COLLISION_LAYER% = $0080

Const PROJECTILE_EXPLOSIVE_FORCE_COEFFICIENT# = 1000.0 'energy multiplier for all explosive forces generated
Const PROJECTILE_AGENT_ENERGY_COEFFICIENT# = 500.0 'energy multiplier for all collisions involving projectiles and agents
Const PROJECTILE_PROJECTILE_ENERGY_COEFFICIENT# = 0.012 'energy multiplier for all projectile-projectile collisions
Const AGENT_AGENT_ENERGY_COEFFICIENT# = 0.010 'energy multiplier for all agent-agent collisions

Const WALL_NUDGE_DIST# = 0.20

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
					collision_projectile_agent( proj, ag )
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
						collision_agent_agent( ag, other )
					End If
				Next
			Next
		Next
		
		'collisions between {walls|doors} and {agents|projectiles}
		For Local cur_wall_list:TList = EachIn all_walls
			For Local wall%[] = EachIn cur_wall_list
				SetRotation( 0 )
				result = CollideRect( wall[1],wall[2], wall[3],wall[4], AGENT_COLLISION_LAYER, WALL_COLLISION_LAYER, wall )
				For ag = EachIn result
					'COLLISION! between {ag} and {wall}
					collision_agent_wall( ag, wall )
				Next
				result = CollideRect( wall[1],wall[2], wall[3],wall[4], PROJECTILE_COLLISION_LAYER, WALL_COLLISION_LAYER, wall )
				For proj = EachIn result
					'COLLISION! between {proj} and {wall}
					collision_projectile_wall( proj, wall )
				Next
			Next
		Next
		For Local cur_door_list:TList = EachIn all_door_lists
			For Local door:WIDGET = EachIn cur_door_list
				SetRotation( door.parent.ang + door.offset_ang + door.state.ang + door.ang_offset )
				Local x#, y#, w#, h#
				x = door.parent.pos_x + door.offset*Cos( door.parent.ang + door.offset_ang ) + door.state.pos_length*Cos( door.parent.ang + door.offset_ang + door.state.ang + door.ang_offset )
				y = door.parent.pos_y + door.offset*Sin( door.parent.ang + door.offset_ang ) + door.state.pos_length*Sin( door.parent.ang + door.offset_ang + door.state.ang + door.ang_offset )
				w = door.img.width
				h = door.img.height
				result = CollideRect( x,y, w,h, AGENT_COLLISION_LAYER, DOOR_COLLISION_LAYER, door )
				For ag = EachIn result
					'COLLISION! between {ag} and {door}
					collision_agent_door( ag, door )
				Next
				result = CollideRect( x,y, w,h, PROJECTILE_COLLISION_LAYER, DOOR_COLLISION_LAYER, door )
				For proj = EachIn result
					'COLLISION! between {proj} and {door}
					collision_projectile_door( proj, door )
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

	End If
End Function

Function collision_projectile_agent( proj:PROJECTILE, ag:COMPLEX_AGENT )
	'activate collision response for affected entity(ies)
	Local offset#, offset_ang#
	cartesian_to_polar( ag.pos_x - proj.pos_x, ag.pos_y - proj.pos_y, offset, offset_ang )
	Local total_force# = proj.mass*PROJECTILE_AGENT_ENERGY_COEFFICIENT*Sqr( Pow(proj.vel_x,2) + Pow(proj.vel_y,2) )
	ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - proj.ang ), 100 )))
	ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - proj.ang ), 100 )))
	'add damage sticky to agent
	'ag.add_sticky( PARTICLE( PARTICLE.Create( img_stickies, Rand( 0, img_stickies.frames.Length - 1 ), LAYER_FOREGROUND, False, 0.0, 255, 255, 255, INFINITY, 0.0, 0.0, 0.0, 0.0, proj.ang, 0.0, 0.5, 0.0, 1.0, 0.0 ))).attach_at( proj.pos_x - ag.pos_x, proj.pos_y - ag.pos_y )
	'add explosive force to nearby agents
	For Local list:TList = EachIn agent_lists
		For Local other:AGENT = EachIn list
			'if this agent is a different agent than the one hit by the projectile
			If ag.id <> other.id
				Local dist# = proj.dist_to( other )
				If dist < proj.radius
					Local ang# = proj.ang_to( other )
					Local total_force# = PROJECTILE_EXPLOSIVE_FORCE_COEFFICIENT*proj.explosive_force_magnitude / Pow( dist, 2 )
					other.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ang, total_force*Cos( ang ), 100 )))
					other.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, dist*total_force*Sin( ang ), 100 )))
				End If
			End If
		Next
	Next
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
		If ag.political_alignment = ALIGNMENT_HOSTILE
			level_enemies_remaining :- 1
		End If
	End If
	'activate projectile impact emitter
	proj.impact( ag )
	'remove projectile
	proj.remove_me()
End Function

Function collision_agent_agent( ag:AGENT, other:COMPLEX_AGENT )
	'activate collision response for affected entity(ies)
	'Local offset#, offset_ang#
	'cartesian_to_polar( ag.pos_x - other.pos_x, ag.pos_y - other.pos_y, offset, offset_ang )
	'Local total_force# = other.mass*AGENT_AGENT_ENERGY_COEFFICIENT*Sqr( Pow(other.vel_x,2) + Pow(other.vel_y,2) )
	'ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - other.ang ), 100 )))
	'ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*(total_force/3.0)*Sin( offset_ang - other.ang ), 100 )))
	
	Local dist# = other.dist_to( ag )
	Local ang# = other.ang_to( ag )
	Local ag_force_magnitude# = ag.mass*AGENT_AGENT_ENERGY_COEFFICIENT*Sqr( Pow(ag.vel_x,2) + Pow(ag.vel_y,2) )
	'nudge
	
	
End Function

Function collision_agent_wall( ag:AGENT, wall%[] )
	Local offset#, offset_ang#
	cartesian_to_polar( ag.pos_x - wall_mid_x(wall), ag.pos_y - wall_mid_y(wall), offset, offset_ang )
	Local ang# = clamp_ang_to_bifurcate_wall_diagonals( offset_ang, wall )
	''nudge
	'ag.pos_x :+ WALL_NUDGE_DIST*Cos( ang )
	'ag.pos_y :+ WALL_NUDGE_DIST*Sin( ang )
	''cancellation of (the scalar projection of (the agent's {velocity|acceleration} onto the direction of (the collision response force)))
	'Local vel:cVEC = Create_cVEC( ag.vel_x, ag.vel_y )
	'ag.vel_x :- vel.r() * Cos( ang - vel.a() )
	'Local acc:cVEC = Create_cVEC( ag.acc_x, ag.acc_y )
	'ag.acc_x :- acc.r() * Cos( ang - acc.a() )
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
End Function

Function collision_agent_door( ag:COMPLEX_AGENT, door:WIDGET )
	
End Function

Function collision_projectile_door( proj:PROJECTILE, door:WIDGET )
	
End Function

Function collision_projectile_wall( proj:PROJECTILE, wall%[] )
	'add explosive force to nearby agents
	For Local list:TList = EachIn agent_lists
		For Local other:AGENT = EachIn list
			Local dist# = proj.dist_to( other )
			If dist < proj.radius
				Local ang# = proj.ang_to( other )
				Local total_force# = PROJECTILE_EXPLOSIVE_FORCE_COEFFICIENT*proj.explosive_force_magnitude / Pow( dist, 2 )
				other.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ang, total_force*Cos( ang ), 100 )))
				other.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, dist*total_force*Sin( ang ), 100 )))
			End If
		Next
	Next
	proj.impact()
	proj.remove_me()
End Function

Function clamp_ang_to_bifurcate_wall_diagonals#( ang#, wall%[] )
	Local wx# = wall_mid_x( wall ), wy# = wall_mid_y(wall)
	'wall_angle[4] = angle from mid to [ top_left, top_right, bottom_right, bottom_left ].
	Local wall_angle#[] = ..
	[	vector_diff_angle( wx,wy, wall[1],        wall[2] ), ..
		vector_diff_angle( wx,wy, wall[1]+wall[3],wall[2] ), ..
		vector_diff_angle( wx,wy, wall[1]+wall[3],wall[2]+wall[4] ), ..
		vector_diff_angle( wx,wy, wall[1],        wall[2]+wall[4] ) ]
	If      ang < wall_angle[0] Then Return 180 ..
	Else If ang < wall_angle[1] Then Return 270 ..
	Else If ang < wall_angle[2] Then Return 0 ..
	Else If ang < wall_angle[3] Then Return 90 ..
	Else                             Return 180
End Function

Function clamp_ang_to_bifurcate_door_diagonals#( ang#, wall%[] )
	Local wx# = wall_mid_x( wall ), wy# = wall_mid_y(wall)
	'wall_angle[4] = angle from mid to [ top_left, top_right, bottom_right, bottom_left ].
	Local angles#[] = ..
	[	vector_diff_angle( wx,wy, wall[1],        wall[2] ), ..
		vector_diff_angle( wx,wy, wall[1]+wall[3],wall[2] ), ..
		vector_diff_angle( wx,wy, wall[1]+wall[3],wall[2]+wall[4] ), ..
		vector_diff_angle( wx,wy, wall[1],        wall[2]+wall[4] ) ]
	For Local i% = 1 To angles.Length - 1
		If ang < angles[i-1] Then Return avg( angles[i-1], angles[i] )
	Next
	Return avg( angles[3], angles[0] )
End Function




