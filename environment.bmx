Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "settings.bmx"
Import "constants.bmx"
Import "vec.bmx"
Import "graffiti_manager.bmx"
Import "level.bmx"
Import "pathing_structure.bmx"
Import "box.bmx"
Import "cell.bmx"
Import "complex_agent.bmx"
Import "spawn_controller.bmx"
Import "door.bmx"
Import "particle.bmx"
Import "emitter.bmx"
Import "particle_emitter.bmx"
Import "widget.bmx"
Import "projectile.bmx"
Import "agent.bmx"
Import "pickup.bmx"
Import "control_brain.bmx"
Import "mouse.bmx"
Import "spawn_request.bmx"
Import "prop_data.bmx"

'______________________________________________________________________________
Function Create_ENVIRONMENT:ENVIRONMENT( human_participation% = False )
	Local env:ENVIRONMENT = New ENVIRONMENT
	env.human_participation = human_participation
	Return env
End Function

Type ENVIRONMENT
	'Field game_mouse:cVEC 'moved to mouse.bmx
	Field drawing_origin:cVEC 'drawing origin (either midpoint of local origin and relative mouse, or some constant)
	Field origin_min_x% 'camera constraint
	Field origin_min_y% 'camera constraint
	Field origin_max_x% 'camera constraint
	Field origin_max_y% 'camera constraint
	
	Field background:TImage
	Field graffiti:GRAFFITI_MANAGER
	Field foreground:TImage

	Field lev:LEVEL 'level object from which to build the environment, read-only
	Field pathing:PATHING_STRUCTURE 'pathfinding object for this level
	Field walls:TList 'TList<BOX> contains all of the wall rectangles of the level
	
	Field spawn:SPAWN_CONTROLLER
	Field spawner_door:DOOR[] 'for each spawner, a door (potentially)
	
	Field particle_list_background:TList 'TList<PARTICLE>
	Field particle_list_foreground:TList 'TList<PARTICLE>
	Field particle_lists:TList 'TList<TList<PARTICLE>>
	Field retained_particle_list:TList 'TList<PARTICLE>
	Field retained_particle_count% 'number of particles currently retained, cached for speed
	Field environmental_emitter_list:TList 'TList<PARTICLE_EMITTER>
	Field environmental_widget_list:TList 'TList<WIDGET>
	Field projectile_list:TList 'TList<PROJECTILE>
	Field friendly_agent_list:TList 'TList<COMPLEX_AGENT>
	Field hostile_agent_list:TList 'TList<COMPLEX_AGENT>
	Field complex_agent_lists:TList 'TList<TList<COMPLEX_AGENT>>
	Field prop_list:TList 'TList<AGENT>
	Field agent_lists:TList 'TList<TList<AGENT>>
	Field pickup_list:TList 'TList<PICKUP>
	Field control_brain_list:TList 'TList<CONTROL_BRAIN>
	Field AI_spawners:TList 'TList<CONTROL_BRAIN>
	Field friendly_door_list:TList 'TList<DOOR>
	Field hostile_door_list:TList 'TList<DOOR>
	Field door_lists:TList 'TList<TList<DOOR>>
	
	Field player_kills_at_start% 'kill count at level initialization
	Field paused% 'pause flag
	Field human_participation% 'flag indicating whether any humans will ever participate in this game
	Field game_in_progress% 'flag indicating the game has begun
	Field game_over% 'flag indicating game over state
	Field level_passed_ts%
	Field player_in_locker%
	Field waiting_for_player_to_enter_arena%
	Field battle_in_progress%
	Field battle_state_toggle_ts%
	Field waiting_for_player_to_exit_arena%
	Field spawn_enemies%
	Field auto_reset_spawners%
	Field player_has_munitions_based_turrets%

	Field player_spawn_point:POINT
	Field player_brain:CONTROL_BRAIN
	Field player:COMPLEX_AGENT
	
	Method New()
		game_mouse = Create_cVEC( 0, 0 )
		drawing_origin = Create_cVEC( 0, 0 )
		walls = CreateList()
		particle_list_background = CreateList()
		particle_list_foreground = CreateList()
		particle_lists = CreateList()
			particle_lists.AddLast( particle_list_background )
			particle_lists.AddLast( particle_list_foreground )
		retained_particle_list = CreateList()
		environmental_emitter_list = CreateList()
		environmental_widget_list = CreateList()
		projectile_list = CreateList()
		friendly_agent_list = CreateList()
		hostile_agent_list = CreateList()
		complex_agent_lists = CreateList()
			complex_agent_lists.AddLast( friendly_agent_list )
			complex_agent_lists.AddLast( hostile_agent_list )
		prop_list = CreateList()
		agent_lists = CreateList()
			agent_lists.AddLast( friendly_agent_list )
			agent_lists.AddLast( hostile_agent_list )
			agent_lists.AddLast( prop_list )
		pickup_list = CreateList()
		control_brain_list = CreateList()
		friendly_door_list = CreateList()
		hostile_door_list = CreateList()
		door_lists = CreateList()
			door_lists.addlast( friendly_door_list )
			door_lists.addlast( hostile_door_list )
		AI_spawners = CreateList()
	End Method
	
	Method clear()
		background = Null
		foreground = Null
		particle_list_background.Clear()
		particle_list_foreground.Clear()
		retained_particle_list.Clear()
		retained_particle_count = 0
		environmental_widget_list.Clear()
		projectile_list.Clear()
		friendly_agent_list.Clear()
		hostile_agent_list.Clear()
		prop_list.Clear()
		pickup_list.Clear()
		control_brain_list.Clear()
		friendly_door_list.Clear()
		hostile_door_list.Clear()
		
		battle_in_progress = False
		game_in_progress = False
		FLAG.engine_ignition = False
		FLAG.engine_running = False
		player_spawn_point = Null
		player_brain = Null
		player = Null
	End Method
	
	Method bake_level%( lev:LEVEL, background:TImage, foreground:TImage )
		If lev
			Self.lev = lev 'use given level
		Else
			Return False 'failure by default
		End If
		'background
		Self.background = background
		'foreground
		Self.foreground = foreground
		'camera bounding pre-calc
		calculate_camera_constraints()
		'pathing (AI)
		pathing = PATHING_STRUCTURE.Create( lev )
		'walls (Collisions)
		For Local cursor:CELL = EachIn lev.get_blocking_cells()
			walls.AddLast( lev.get_wall( cursor ))
		Next
		'graffiti
		graffiti = GRAFFITI_MANAGER.Create( background, window_w, window_h )
		'props
		For Local pd:PROP_DATA = EachIn lev.props
			Local prop:AGENT = get_prop( pd.archetype )
			prop.manage( prop_list )
			prop.move_to( pd.pos )
		Next
		'spawning system
		spawn = Create_SPAWN_CONTROLLER( lev.spawners )
		reset_spawners()
		'kill tracker
		If human_participation And profile
			player_kills_at_start = profile.kills
		End If
		'success
		Return True
	End Method
	
	Method calculate_camera_constraints()
		If lev.width <= window_w 'level not as wide as window
			origin_min_x = window_w/2 - lev.width/2
			origin_max_x = origin_min_x
		Else 'lev.width > window_w 'level wider than window
			origin_min_x = -(lev.width + 2*20 - window_w)
			origin_max_x = 20
		End If
		If lev.height <= window_h 'level not as tall as window
			origin_min_y = window_h/2 - lev.height/2
			origin_max_y = origin_min_y
		Else 'lev.height > window_h 'level taller than window
			origin_min_y = -(lev.height + 2*20 - window_h)
			origin_max_y = 20
		End If
	End Method
	
	Method add_door:DOOR( p:POINT, alignment% )
		Local d:DOOR = Create_DOOR( p )
		d.manage( political_door_list( alignment ))
		Return d
	End Method

	'this method needs to be split into two logical chunks
	'  first-time initialization
	'  political-alignment spawner reset
	Method reset_spawners( alignment% = POLITICAL_ALIGNMENT.NONE, omit_turrets% = False )
		If alignment = POLITICAL_ALIGNMENT.NONE
			'gated factory doors
			spawner_door = New DOOR[spawn.size]
			For Local i% = 0 Until spawn.size
				If spawn.spawners[i].class = SPAWNER.class_GATED_FACTORY
					spawner_door[i] = add_door( spawn.spawners[i].pos, spawn.spawners[i].alignment )
				End If
			Next
		Else 'alignment <> POLITICAL_ALIGNMENT.NONE
			'controller
			spawn.reset( alignment, omit_turrets )
		End If
	End Method
	
	Method update_spawning_system()
		'spawn controller update
		spawn.update()
		'spawn request processing
		Local cb:CONTROL_BRAIN
		For Local req:SPAWN_REQUEST = EachIn spawn.spawn_request_list
			cb = spawn_unit_from_request( req )
			'spawn request last-spawned callback update (hack that prevents spawning flash-mobs of baddies)
			'does not apply to enemies spawned from a carrier
			If cb And cb.avatar And req.source_spawner_index >= 0
				spawn.last_spawned[req.source_spawner_index] = cb.avatar
			End If
		Next
		spawn.spawn_request_list.Clear()
		'door activation
		Rem 'currently handled by update_flags() in update.bmx 'ugh!
		For Local d% = 0 Until spawn.active_spawners.Length
			If spawner_door[d]
				If spawn.active_spawners[d] ..
				And spawner_door[d].status = DOOR.DOOR_CLOSED
					'door should be open
					spawner_door[d].open()
				Else If Not spawn.active_spawners[d] ..
				And spawner_door[d].status = DOOR.DOOR_OPEN
					'door should be closed
					'might want to delay this a bit
					spawner_door[d].close()
				End If
			End If
		Next
		End Rem
	End Method
	
	Method active_spawners%( alignment% )
		Local count% = 0
		For Local i% = 0 Until spawn.size
			If spawn.active_spawners[i] And spawn.spawners[i].alignment = alignment
				count :+ 1
			End If
		Next
		Return count
	End Method
	
	Method spawn_unit_from_request:CONTROL_BRAIN( req:SPAWN_REQUEST )
		If Not req Then Return Null
		Return spawn_unit( req.unit_key, req.alignment, req.spawn_point )
	End Method

	Method spawn_unit:CONTROL_BRAIN( unit_key$, alignment%, spawn_point:POINT )
		Local unit:COMPLEX_AGENT = get_unit( unit_key, alignment )
		Local allied_agent_list:TList, rival_agent_list:TList
		Select alignment
			Case POLITICAL_ALIGNMENT.HOSTILE
				allied_agent_list = hostile_agent_list
				rival_agent_list = friendly_agent_list
			Case POLITICAL_ALIGNMENT.FRIENDLY
				allied_agent_list = friendly_agent_list
				rival_agent_list = hostile_agent_list
		End Select
		unit.manage( allied_agent_list )
		unit.spawn_at( spawn_point, 800 )
		unit.snap_all_turrets()
		Local brain:CONTROL_BRAIN = Create_CONTROL_BRAIN( ..
			unit, CONTROL_BRAIN.CONTROL_TYPE_AI, ..
			pathing, allied_agent_list, rival_agent_list, ..
			walls,, 10, 1000, 1000 )
		brain.manage( control_brain_list )
		
		'///////////////////////////////////////////////////////////////////////////
		'the following should come from an emitter event attached to the agent
		Local pt:POINT = Create_POINT( unit.pos_x, unit.pos_y )
		Local em:PARTICLE_EMITTER = get_particle_emitter( "spawner" )
		em.manage( environmental_emitter_list )
		em.parent = pt
		em.attach_at( ,, 30,60, -180,180,,,,, -0.04,-0.08 )
		em.enable( EMITTER.MODE_ENABLED_WITH_TIMER )
		em.time_to_live = 1000
		em.prune_on_disable = True
		Local part:PARTICLE = get_particle( "soft_glow" )
		part.manage( particle_list_foreground )
		part.parent = pt
		'///////////////////////////////////////////////////////////////////////////
		
		Return brain
	End Method
	
	Method deal_damage( ag:AGENT, damage# )
		'actual damage assignment
		ag.receive_damage( damage )
		'potential resulting death
		If ag.dead() 'some agent was killed
			'agent death animations and sounds, and memory cleanup
			ag.die( particle_list_background, particle_list_foreground )
			'shalt we spawneth teh phat lewts?! perhaps! perhaps.
			If human_participation
				spawn_pickup( ag.pos_x, ag.pos_y,, (Not player_has_munitions_based_turrets) )
			End If
		End If
	End Method
	
	Method insert_player( new_player:COMPLEX_AGENT, new_player_brain:CONTROL_BRAIN )
		'if player already exists in this environment, it must be removed
		If player <> Null
			If player.managed()
				player.unmanage()
			End If
			player = Null
		End If
		If player_brain <> Null
			If player_brain.managed()
				player_brain.unmanage()
			End If
			player_brain = Null
		End If
		'add new player
		player = new_player
		player.manage( friendly_agent_list )
		player_brain = new_player_brain
		player_brain.manage( control_brain_list )
		FLAG.engine_ignition = False
		FLAG.engine_running = False
		'pickup spawning switch
		player_has_munitions_based_turrets = False
		For Local t:TURRET = EachIn player.turrets
			If t.class = TURRET.AMMUNITION
				player_has_munitions_based_turrets = True
				Exit
			End If
		Next
	End Method
	
	Method insert_network_player( network_player:COMPLEX_AGENT, network_player_brain:CONTROL_BRAIN )
		'if player already exists in this environment, it must be removed
		network_player.manage( friendly_agent_list )
		network_player_brain.manage( control_brain_list )
	End Method
	
	Method respawn_player()
		If player <> Null And player_brain <> Null And player.managed() And player_brain.managed()
			player_spawn_point = random_spawn_point( POLITICAL_ALIGNMENT.FRIENDLY )
			player.move_to( player_spawn_point )
			player.snap_all_turrets()
		End If
	End Method
	
	Method respawn_network_player( network_player:COMPLEX_AGENT )
		If network_player <> Null And network_player.managed()
			network_player.move_to( random_spawn_point( POLITICAL_ALIGNMENT.FRIENDLY ))
			network_player.snap_all_turrets()
		End If
	End Method
	
	Method spawn_pickup( x%, y%, probability_override# = -1.0, omit_ammunition% = False ) 'request; depends on probability
		Local threshold#
		If probability_override <> -1.0
			threshold = probability_override
		Else
			threshold = PICKUP_PROBABILITY
		End If
		If Rnd( 0.0, 1.0 ) < threshold
			'cache the pickups
			Local pickup_archetype:TList = CreateList()
			For Local key$ = EachIn pickup_map.Keys()
				pickup_archetype.AddLast( get_pickup( key ))
			Next
			'pick an archetype
			Local pickup_class% = Rand( 1, 3 )
			If omit_ammunition And pickup_class = PICKUP.AMMO Then Return
			'count how many pickups are of the correct type
			Local count% = 0
			For Local pkp:PICKUP = EachIn pickup_archetype
				If pkp.pickup_type = pickup_class Then count :+ 1
			Next
			If count = 0 Then Return
			'valid archetypes enumeration
			Local i% = 0, index% = 0
			Local valid_pickup_archetypes%[count]
			For Local pkp:PICKUP = EachIn pickup_archetype
				If pkp.pickup_type = pickup_class
					valid_pickup_archetypes[index] = i
					index :+ 1
				End If
				i :+ 1
			Next
			'deck size is the summation of n for n=1 to n=count
			Local size% = 0
			For Local i% = 1 To count
				size :+ i
			Next
			'populate a deck of "cards"
			'more common cards get multiple copies (to be picked more often statistically)
			Local deck%[size]
			Local n% = count
			For Local i% = 0 To count - 1
				For Local k% = 0 To n - 1
					deck[i+k] = valid_pickup_archetypes[i]
				Next
				n :- 1
			Next
			Local pkp:PICKUP = PICKUP( pickup_archetype.valueAtIndex( deck[Rand( 0, deck.Length - 1 )]))
			If pkp
				pkp = pkp.clone()
				pkp.pos_x = x
				pkp.pos_y = y
				pkp.manage( pickup_list )
			End If
		End If
	End Method
	
	Method random_spawn_point:POINT( alignment% = UNSPECIFIED )
		If alignment <> UNSPECIFIED And lev.spawners.Length > 0
			Local list:TList = CreateList()
			For Local i% = 0 To lev.spawners.Length-1
				Local sp:SPAWNER = lev.spawners[i]
				If sp.alignment = alignment
					list.AddLast( sp.pos )
				End If
			Next
			If Not list.IsEmpty()
				Return POINT( list.ValueAtIndex( Rand( 0, list.Count()-1 )))
			Else
				Return Null
			End If
		Else If lev.spawners.Length > 0 'alignment = UNSPECIFIED
			Return lev.spawners[ Rand( 0, lev.spawners.Length-1 )].pos
		Else 'lev.spawners.Length = 0
			Return Null
		End If
	End Method
	
	Method political_door_list:TList( alignment% )
		Select alignment
			Case POLITICAL_ALIGNMENT.FRIENDLY
				Return friendly_door_list
			Case POLITICAL_ALIGNMENT.HOSTILE
				Return hostile_door_list
		End Select
		Return Null
	End Method

	Method toggle_doors( alignment% )
		For Local d:DOOR = EachIn political_door_list( alignment )
			d.toggle()
		Next
	End Method
	Method open_doors( alignment% )
		For Local d:DOOR = EachIn political_door_list( alignment )
			d.open()
		Next
	End Method
	Method close_doors( alignment% )
		For Local d:DOOR = EachIn political_door_list( alignment )
			d.close()
		Next
	End Method

	Method kill( brain:CONTROL_BRAIN )
		If brain <> Null And Not brain.avatar.dead()
			brain.avatar.die( particle_list_background, particle_list_foreground )
			'this should be part of the complex agent's death emitters
			play_sound( get_sound( "cannon_hit" ), 0.5, 0.25 )
		End If
	End Method
	
	Method near_to:TList( obj:PHYSICAL_OBJECT, radius# )
		'future optimization:
		'  since the drop-off formula for forces and damage use the square of the distance
		'  only calculate the square of the distances; do not bother calculating the actual distances
		'  this will save a "square-root" operation for each physical object in the current game.
		Local proximal:TList = CreateList()
		For Local ag:AGENT = EachIn prop_list
			If obj.dist_to( ag ) <= radius Then proximal.AddLast( ag )
		Next
		For Local list:TList = EachIn complex_agent_lists
			For Local unit:COMPLEX_AGENT = EachIn list
				If obj.dist_to( unit ) <= radius Then proximal.AddLast( unit )
			Next
		Next
		Return proximal
	End Method
	
End Type

