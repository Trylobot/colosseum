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
		
		'collisions between {projectiles} and {agents|walls|doors}
		For list = EachIn game.agent_lists
			For ag = EachIn list
				ag.collide( 0, AGENT_COLLISION_LAYER )
			Next
		Next
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
		For Local d:DOOR = EachIn game.doors
			For Local slider:WIDGET = EachIn d.all_sliders
				SetRotation( slider.get_ang() )
				w = slider.img.width()
				h = slider.img.height()
				result = CollideRect( slider.get_x(), slider.get_y(), w, h, PROJECTILE_COLLISION_LAYER, DOOR_COLLISION_LAYER, slider )
				For proj = EachIn result
					'COLLISION! between {projectile} and {door}
					collision_projectile_door( proj, slider )
				Next
			Next
		Next
		
		'collisions between {player} and {pickups}
		If game.human_participation And game.player And Not game.player.dead()
			For pkp = EachIn game.pickup_list
				SetRotation( 0 )
				CollideRect( pkp.pos_x, pkp.pos_y, pkp.img.width(), pkp.img.height(), 0, PICKUP_COLLISION_LAYER, pkp )
			Next
			result = game.player.collide( PICKUP_COLLISION_LAYER, 0 )
			For pkp = EachIn result
				'COLLISION! between {player} and {pkp}
				collision_player_pickup( game.player, pkp )
			Next
		End If
		
	End If
End Function

Function collision_projectile_agent( proj:PROJECTILE, ag:AGENT )
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
	'ag.add_sticky( PARTICLE( PARTICLE.Create( img_stickies, Rand( 0, img_stickies.frames.Length - 1 ), LAYER_FOREGROUND, False, 0.0, 255, 255, 255, INFINITY, 0.0, 0.0, 0.0, 0.0, proj.ang, 0.0, 0.5, 0.0, 1.0, 0.0 ))).attach_at( proj.pos_x - ag.pos_x, proj.pos_y - ag.pos_y )
	'/////////
	'process damage, death, cash and pickups resulting from it
	game.deal_damage( ag, proj.damage )
	'/////////
	'if the player killed an enemy with this projectile, reward player
	If ag.dead() ..
	And profile ..
	And game.human_participation ..
	And proj.source_id = get_player_id() ..
	And COMPLEX_AGENT( ag ) 'ding! cash popup near splodey
		Local p:PARTICLE
		If COMPLEX_AGENT( ag ).alignment <> game.player.alignment
			'killed enemy
			p = get_particle( "cash_positive" )
			record_player_kill( COMPLEX_AGENT( ag ).cash_value )
			p.str = "$" + COMPLEX_AGENT( ag ).cash_value
		Else 'COMPLEX_AGENT( ag ).political_alignment == game.player.alignment
			'killed ally
			p = get_particle( "cash_negative" )
			record_player_friendly_fire_kill( FRIENDLY_FIRE_PUNISHMENT_AMOUNT )
			p.str = "$-" + FRIENDLY_FIRE_PUNISHMENT_AMOUNT
		End If
		p.pos_x = ag.pos_x
		p.pos_y = ag.pos_y - 20.0
		p.manage( game.particle_list_foreground ) 'cash is always a foreground particle
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
End Function

Function collision_projectile_door( proj:PROJECTILE, door:WIDGET )
	proj.impact( ,, proj.snd_impact, game.particle_list_background, game.particle_list_foreground )
End Function

Function collision_projectile_wall( proj:PROJECTILE, wall:BOX )
	proj.impact( ,, proj.snd_impact, game.particle_list_background, game.particle_list_foreground )
End Function

Function collision_player_pickup( cmp_ag:COMPLEX_AGENT, pkp:PICKUP )
	cmp_ag.grant_pickup( pkp ) 'i can has lewts?!
	pkp.play()
	pkp.unmanage()
End Function

