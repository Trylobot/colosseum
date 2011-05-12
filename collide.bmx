Rem
	collide.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "core.bmx"
'Import "agent.bmx"
'Import "complex_agent.bmx"
'Import "projectile.bmx"
'Import "pickup.bmx"
'Import "door.bmx"
'Import "widget.bmx"
'Import "box.bmx"

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
Const PROJECTILE_AGENT_ENERGY_COEFFICIENT# = 350.0 'energy multiplier for all collisions involving projectiles and agents
Const PROJECTILE_AGENT_TORQUE_COEFFICIENT# = 0.25 'energy multiplier (torque only) for collisions involving projectiles and agents
Const PROJECTILE_PROJECTILE_ENERGY_COEFFICIENT# = 0.012 'energy multiplier for all projectile-projectile collisions
Const AGENT_AGENT_ENERGY_COEFFICIENT# = 0.05 'energy multiplier for all agent-agent collisions
Const WALL_NUDGE_DIST# = 0.2


Function collide_all_objects()
	
	'collision detection & resolution body
	If game <> Null And Not game.paused
		ResetCollisions()
		
		Local list:TList
		Local ag:AGENT, other:AGENT
		Local proj:PROJECTILE
		Local pkp:PICKUP
		Local wall:BOX
		Local result:Object[]
		Local w#, h#
		
		'collisions between projectiles and {agents|walls}
		SetScale( 1, 1 )
		For list = EachIn game.agent_lists
			For ag = EachIn list
				ag.collide( 0, AGENT_COLLISION_LAYER )
			Next
		Next
		SetRotation( 0 )
		For wall = EachIn game.walls
			CollideRect( wall.x,wall.y, wall.w,wall.h, 0, WALL_COLLISION_LAYER, wall )
		Next
		For proj = EachIn game.projectile_list
			'check for projectile/agent
			result = proj.collide( AGENT_COLLISION_LAYER, 0 )
			For ag = EachIn result
				'do not collide with source
				If proj.source_id <> ag.id
					'COLLISION! between {projectile} & {agent}
					collision_projectile_agent( proj, ag )
					ag.flash = True
				End If
			Next
			'check for projectile/wall
			result = proj.collide( WALL_COLLISION_LAYER, 0 )
			For wall = EachIn result
				'COLLISION! between {projectile} and {wall}
				collision_projectile_wall( proj, wall )
			Next
		Next
		
		'collisions between {player} and {pickups}
		If game.human_participation And game.player And Not game.player.dead()
			For pkp = EachIn game.pickup_list
				SetRotation( 0 )
				CollideImage( pkp.img, pkp.pos_x, pkp.pos_y, 0, 0, PICKUP_COLLISION_LAYER, pkp )
			Next
			result = game.player.collide( PICKUP_COLLISION_LAYER, 0 )
			For pkp = EachIn result
				'COLLISION! between {player} and {pkp}
				collision_player_pickup( game.player, pkp )
			Next
		End If
		
		'collisions between agents and other agents
		For list = EachIn game.agent_lists
			For ag = EachIn list
				result = ag.collide( AGENT_COLLISION_LAYER, SECONDARY_AGENT_COLLISION_LAYER )
				For other = EachIn result
					If ag.id <> other.id 'not colliding with self
						'COLLISION! between {ag} and {other}
						collision_agent_agent( ag, other )
					End If
				Next
			Next
		Next
		
		'collisions between {walls} and {agents}
		For Local wall:BOX = EachIn game.walls
			SetRotation( 0 )
			SetHandle( 0, 0 )
			result = CollideRect( wall.x,wall.y, wall.w,wall.h, AGENT_COLLISION_LAYER, WALL_COLLISION_LAYER, wall )
			For ag = EachIn result
				'COLLISION! between {ag} and {wall}
				collision_agent_wall( ag, wall )
			Next
		Next
		
		'collisions between {doors} and {agents|projectiles}
		For Local d:DOOR = EachIn game.doors
			For Local slider:WIDGET = EachIn d.all_sliders
				SetRotation( slider.get_ang() )
				SetHandle( slider.img.handle_x, slider.img.handle_y )
				w = slider.img.width
				h = slider.img.height
				result = CollideRect( slider.get_x(), slider.get_y(), w, h, AGENT_COLLISION_LAYER, DOOR_COLLISION_LAYER, slider )
				For ag = EachIn result
					'COLLISION! between {ag} and {door}
					collision_agent_door( ag, slider )
				Next
				result = CollideRect( slider.get_x(), slider.get_y(), w, h, PROJECTILE_COLLISION_LAYER, DOOR_COLLISION_LAYER, slider )
				For proj = EachIn result
					'COLLISION! between {proj} and {door}
					collision_projectile_door( proj, slider )
				Next
			Next
		Next
		
		SetRotation( 0 )
		SetHandle( 0, 0 )

	End If
End Function

Function collision_projectile_agent( proj:PROJECTILE, ag:AGENT )
	'DebugLog( "projectile("+proj.id+") agent("+ag.id+")" )
	'activate collision response for affected entity(ies)
	Local offset#, offset_ang#
	cartesian_to_polar( ag.pos_x - proj.pos_x, ag.pos_y - proj.pos_y, offset, offset_ang )
	Local total_force# = proj.mass*PROJECTILE_AGENT_ENERGY_COEFFICIENT*Sqr( Pow(proj.vel_x,2) + Pow(proj.vel_y,2) )
	ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - proj.ang ), 100 )))
	ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, PROJECTILE_AGENT_TORQUE_COEFFICIENT*offset*total_force*Sin( offset_ang - proj.ang ), 100 )))
	'add explosive force to nearby agents
	For Local list:TList = EachIn game.agent_lists
		For Local other:AGENT = EachIn list
			'if this agent is a different agent than the one hit by the projectile
			If ag.id <> other.id
				Local dist# = proj.dist_to( other )
				If dist < proj.radius
					Local ang# = proj.ang_to( other )
					Local total_force# = PROJECTILE_EXPLOSIVE_FORCE_COEFFICIENT*proj.explosive_force_magnitude / Pow( dist, 2 )
					other.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ang, total_force*Cos( ang ), 100 )))
					other.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, PROJECTILE_AGENT_TORQUE_COEFFICIENT*dist*total_force*Sin( ang ), 100 )))
				End If
			End If
		Next
	Next
	''add damage sticky to agent
	'ag.add_sticky( ? )
	'/////////
	'process damage, death, cash and pickups resulting from it
	game.deal_damage( ag, proj.damage )
	'/////////
	'show cash particle and update meter
	If ag.dead() ..
	And game.human_participation ..
	And proj.source_id = get_player_id() ..
	And COMPLEX_AGENT( ag ) 'ding! cash popup near splodey
		If COMPLEX_AGENT( ag ).alignment <> game.player.alignment
			record_player_kill( COMPLEX_AGENT( ag ).cash_value )
			cash_appear( ag, COMPLEX_AGENT( ag ).cash_value, game )
		Else 'COMPLEX_AGENT( ag ).political_alignment == game.player.alignment
			record_player_friendly_fire_kill( FRIENDLY_FIRE_PUNISHMENT_AMOUNT )
			cash_appear( ag, -FRIENDLY_FIRE_PUNISHMENT_AMOUNT, game )
		End If
	End If
	'activate projectile impact emitter
	Local impact_sound:TSound
	If Not COMPLEX_AGENT( ag ) 'prop; assume wooden crate? (VERY BAD FORM)
		impact_sound = get_sound( "wood_hit" ) 
	Else
		impact_sound = proj.snd_impact
	End If
	proj.impact( ..
		ag, (ag.id = get_player_id()), ..
		impact_sound, .. 
		game.particle_list_background, game.particle_list_foreground )
	'remove projectile
	'proj.free()
End Function

Function collision_agent_agent( ag:AGENT, other:AGENT )
	'register the collision (for self-destruct agents)
	ag.last_collided_agent_id = other.id
	If ag.destruct_on_contact And COMPLEX_AGENT( other )
		'this extra parameter to the following call is appropriate only for wooden crates and other non-volatile objects.
		ag.die( game.particle_list_background, game.particle_list_foreground, False, True, False )
		'this sound also applies only to crates
		play_sound( get_sound( "wood_hit" ), 0.5, 0.25 )
	Else If Not ag.physics_disabled And COMPLEX_AGENT( other ) 'this second condition is also only applicable to crates and such, really. it gives the impression that the crate had such little mass, that the total force of the collision went into deforming the object (shattering), and so the complex_agent does not even get affected by the collision.
		Local dist# = other.dist_to( ag )
		Local ang# = other.ang_to( ag )
		'nudge
		ag.pos_x :+ WALL_NUDGE_DIST*Cos( ang )
		ag.pos_y :+ WALL_NUDGE_DIST*Sin( ang )
		'velocity cancellation
		Local vel:cVEC = Create_cVEC( ag.vel_x, ag.vel_y )
		Local vel_projection# = vel.r()*Cos( ang - vel.a() )
		ag.vel_x :- vel_projection*Cos( ang )
		ag.vel_y :- vel_projection*Sin( ang )
		'acceleration cancellation
		Local acc:cVEC = Create_cVEC( ag.acc_x, ag.acc_y )
		Local acc_projection# = acc.r()*Cos( ang - acc.a() )
		ag.acc_x :- acc_projection*Cos( ang )
		ag.acc_y :- acc_projection*Sin( ang )
		''collision force/torque
		'Local collision_force_mag# = other.mass*AGENT_AGENT_ENERGY_COEFFICIENT*vel.r()
		'ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ang, collision_force_mag*Cos( ang ), 50 )))
		'ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE,, dist*(collision_force_mag/30.0)*Sin( ang - other.ang ), 50 )))
	End If
End Function

Function collision_agent_wall( ag:AGENT, wall:BOX )
	Local offset#, offset_ang#
	cartesian_to_polar( ag.pos_x - average([wall.x,wall.x+wall.w]), ag.pos_y - average([wall.y,wall.y+wall.h]), offset, offset_ang )
	Local ang# = clamp_ang_to_bifurcate_wall_diagonals( offset_ang, wall )
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

Function collision_agent_door( ag:AGENT, door:WIDGET )
	If Not ag.physics_disabled
		Local door_pos:POINT = POINT( Create_POINT( door.get_x(), door.get_y(), door.get_ang() ))
		Local dist# = ag.dist_to( door_pos )
		Local ang# = ag.ang_to( door_pos )
		'nudge
		ag.pos_x :- WALL_NUDGE_DIST*Cos( ang )
		ag.pos_y :- WALL_NUDGE_DIST*Sin( ang )
		'velocity cancellation
		Local vel:cVEC = Create_cVEC( ag.vel_x, ag.vel_y )
		Local vel_projection# = vel.r()*Cos( ang - vel.a() )
		ag.vel_x :- vel_projection*Cos( ang )
		ag.vel_y :- vel_projection*Sin( ang )
		'acceleration cancellation
		Local acc:cVEC = Create_cVEC( ag.acc_x, ag.acc_y )
		Local acc_projection# = acc.r()*Cos( ang - acc.a() )
		ag.acc_x :- acc_projection*Cos( ang )
		ag.acc_y :- acc_projection*Sin( ang )
		'collision force/torque
		Local door_mass# = 800.0
		Local collision_force_mag# = door_mass*AGENT_AGENT_ENERGY_COEFFICIENT*vel.r()
		ag.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ang, collision_force_mag*Cos( ang - door_pos.ang ), 50 )))
		ag.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE,, dist*(collision_force_mag/60.0)*Sin( ang - door_pos.ang ), 50 )))
	End If
End Function

Function collision_projectile_door( proj:PROJECTILE, door:WIDGET )
	'DebugLog( "projectile("+proj.id+") door("+door.id+")" )
	proj.impact( ,, proj.snd_impact, game.particle_list_background, game.particle_list_foreground )
	'proj.free()
End Function

Function collision_projectile_wall( proj:PROJECTILE, wall:BOX )
	'DebugLog( "projectile("+proj.id+") wall()" )
	proj.impact( ,, proj.snd_impact, game.particle_list_background, game.particle_list_foreground )
	?Debug
	debug_wall_flashes.AddLast( wall )
	?
End Function

Function collision_player_pickup( cmp_ag:COMPLEX_AGENT, pkp:PICKUP )
	'DebugLog( "player pickup("+pkp.id+")" )
	cmp_ag.grant_pickup( pkp ) 'i can has lewts?!
	pkp.play()
	pkp.unmanage()
End Function

Function clamp_ang_to_bifurcate_wall_diagonals#( ang#, wall:BOX )
	Local wx# = average([wall.x,wall.x+wall.w]), wy# = average([wall.y,wall.y+wall.h])
	'wall_angle[4] = angle from mid to [ top_left, top_right, bottom_right, bottom_left ].
	Local wall_angle#[] = ..
	[	vector_diff_angle( wx,wy, wall.x,        wall.y ), ..
		vector_diff_angle( wx,wy, wall.x+wall.w,wall.y ), ..
		vector_diff_angle( wx,wy, wall.x+wall.w,wall.y+wall.h ), ..
		vector_diff_angle( wx,wy, wall.x,        wall.y+wall.h ) ]
	If      ang < wall_angle[0] Then Return 180 ..
	Else If ang < wall_angle[1] Then Return 270 ..
	Else If ang < wall_angle[2] Then Return 0 ..
	Else If ang < wall_angle[3] Then Return 90 ..
	Else                             Return 180
End Function

Function clamp_ang_to_bifurcate_door_diagonals#( ang#, wall:BOX )
	Local wx# = average([wall.x,wall.x+wall.w]), wy# = average([wall.y,wall.y+wall.h])
	'wall_angle[4] = angle from mid to [ top_left, top_right, bottom_right, bottom_left ].
	Local angles#[] = ..
	[	vector_diff_angle( wx,wy, wall.x,        wall.y ), ..
		vector_diff_angle( wx,wy, wall.x+wall.w,wall.y ), ..
		vector_diff_angle( wx,wy, wall.x+wall.w,wall.y+wall.h ), ..
		vector_diff_angle( wx,wy, wall.x,        wall.y+wall.h ) ]
	For Local i% = 1 To angles.Length - 1
		If ang < angles[i-1] Then Return average([angles[i-1],angles[i]])
	Next
	Return average([angles[3],angles[0]])
End Function

