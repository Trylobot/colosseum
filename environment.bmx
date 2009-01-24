Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const SPAWN_POINT_POLITE_DISTANCE% = 35.0 'delete me (please?)

Function Create_ENVIRONMENT:ENVIRONMENT( human_participation% = False )
	Local env:ENVIRONMENT = New ENVIRONMENT
	env.human_participation = human_participation
	Return env
End Function

Type ENVIRONMENT
	Field mouse:cVEC 'mouse position relative to local origin
	Field drawing_origin:cVEC 'drawing origin (either midpoint of local origin and relative mouse, or some constant)
'	Field origin_min_x% 'constraint
'	Field origin_min_y% 'constraint
'	Field origin_max_x% 'constraint
'	Field origin_max_y% 'constraint
	
	Field background_clean:TImage
	Field background_dynamic:TImage
	Field foreground:TImage

	Field lev:LEVEL 'level object from which to build the environment, read-only
	Field pathing:PATHING_STRUCTURE 'pathfinding object for this level
	Field walls:TList 'TList<BOX> contains all of the wall rectangles of the level
	Field spawn_cursor:CELL[] 'for each spawner, a (row,col) pointer indicating the current agent to be spawned
	Field spawn_ts%[] 'for each spawner, the timestamp of the spawn process start
	Field last_spawned:COMPLEX_AGENT[] 'for each spawner, a reference to the last spawned enemy (so they don't overlap)
	Field spawn_counter%[] 'for each spawner, a count of how many enemies have been spawned so far
	
	Global DOOR_STATUS_OPEN% = 0
	Global DOOR_STATUS_CLOSED% = 1
	Field friendly_door_list:TList 'TList<WIDGET> list of paired door widgets
	Field friendly_doors_status% 'flag indicating state of all friendly doors
	Field hostile_door_list:TList'TList<WIDGET> list of paired door widgets
	Field hostile_doors_status% 'flag indicating state of all hostile doors
	Field all_door_lists:TList 'list of all door lists
	
	Field particle_list_background:TList 'TList<PARTICLE>
	Field particle_list_foreground:TList 'TList<PARTICLE>
	Field particle_lists:TList 'TList<TList<PARTICLE>>
	Field retained_particle_list:TList 'TList<PARTICLE>
	Field retained_particle_list_count% 'number of particles currently retained, cached for speed
	Field environmental_emitter_list:TList 'TList<EMITTER>
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
	
	Field level_enemy_count% 'number of enemies that could possibly be spawned
	Field level_enemies_killed% 'number of enemies that have been killed since being spawned
	Field active_friendly_spawners%
	Field active_friendly_units%
	Field active_hostile_spawners%
	Field active_hostile_units%
	
	Field paused% 'pause flag
	Field human_participation% 'flag indicating whether any humans will ever participate in this game
	Field game_in_progress% 'flag indicating the game has begun
	Field game_over% 'flag indicating game over state
	Field level_passed_ts%
	Field player_engine_ignition%
	Field player_engine_running%
	Field player_in_locker%
	Field waiting_for_player_to_enter_arena%
	Field battle_in_progress%
	Field battle_state_toggle_ts%
	Field waiting_for_player_to_exit_arena%
	Field spawn_enemies%
	Field auto_reset_spawners%

	Field player_spawn_point:POINT 'reference to the spawnpoint that will spawn or has spawned that player
	Field player_brain:CONTROL_BRAIN 'reference to that player's brain object
	Field player:COMPLEX_AGENT 'reference to that player object
	
	Method New()
		mouse = Create_cVEC( 0, 0 )
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
		friendly_doors_status = DOOR_STATUS_CLOSED
		hostile_door_list = CreateList()
		hostile_doors_status = DOOR_STATUS_CLOSED
		all_door_lists = CreateList()
			all_door_lists.addlast( friendly_door_list )
			all_door_lists.addlast( hostile_door_list )
		AI_spawners = CreateList()
	End Method
	
	Method clear()
		background_clean = Null
		background_dynamic = Null
		foreground = Null
		particle_list_background.Clear()
		particle_list_foreground.Clear()
		retained_particle_list.Clear()
		retained_particle_list_count = 0
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
		player_engine_running = False
		player_spawn_point = Null
		player_brain = Null
		player = Null
	End Method
	
	Method load_level%( argument:Object, generate_images% = True )
		'level
		If String( argument )
			Local file:TStream = ReadFile( String( argument ))
			If Not file
				Return False 'indicate failure
			End If
			Local json:TJSON = TJSON.Create( file )
			file.Close()
			lev = Create_LEVEL_from_json( json )
			If lev = Null
				Return False 'indicate failure
			End If
		Else If LEVEL( argument )
			lev = LEVEL( argument )
		End If
		'camera bounding
		calculate_camera_constraints()
		'pathing (AI bots)
		pathing = PATHING_STRUCTURE.Create( lev )
		'walls (Collisions)
		For Local cursor:CELL = EachIn lev.get_blocking_cells()
			walls.AddLast( lev.get_wall( cursor ))
		Next
		If generate_images
			'images (Drawing)
			background_clean = generate_sand_image( lev.width, lev.height )
			foreground = generate_level_walls_image( lev )
			'initialize dynamic background texture with same data as background clean
			background_dynamic = TImage.Create( lev.width, lev.height, 1, FILTEREDIMAGE|DYNAMICIMAGE, 0, 0, 0 )
			SetOrigin( 0, 0 ); SetColor( 255, 255, 255 ); SetAlpha( 1 ); SetRotation( 0 ); SetScale( 1, 1 )
			DrawImage( background_clean, 0, 0 )
			GrabImage( background_dynamic, 0, 0 )
		End If
		'props
		For Local pd:PROP_DATA = EachIn lev.props
			Local prop:AGENT = get_prop( pd.archetype )
			prop.manage( prop_list )
			prop.move_to( pd.pos )
		Next
		'doors
		For Local sp:SPAWNER = EachIn lev.spawners
			If sp.class = SPAWNER.class_GATED_FACTORY
				Select sp.alignment
					Case ALIGNMENT_FRIENDLY
						add_door( sp.pos, friendly_door_list )
					Case ALIGNMENT_HOSTILE
						add_door( sp.pos, hostile_door_list )
				End Select
			End If
		Next
		'spawning system
		reset_spawners()
		'indicate success to caller
		Return True
	End Method
	
	Method calculate_camera_constraints()
'		If lev.width <= window_w
'			origin_min_x = window_w/2 - lev.width/2
'			origin_max_x = origin_min_x
'		Else 'lev.width > window_w
'			origin_min_x = -20
'			origin_max_x = 20 + lev.width - window_w
'		End If
'		If lev.height <= window_h
'			origin_min_y = window_h/2 - lev.height/2
'			origin_max_y = origin_min_y
'		Else 'lev.height > window_h
'			origin_min_y = -20
'			origin_max_y = 20 + lev.height - window_h
'		End If
	End Method
	
	Method reset_spawners( alignment% = ALIGNMENT_NONE )
		If alignment = ALIGNMENT_NONE
			'flags and counters
			level_enemies_killed = 0
			level_enemy_count = lev.enemy_count()
			active_friendly_units = 0
			active_friendly_spawners = 0
			active_hostile_units = 0
			active_hostile_spawners = 0
			'spawn queues and tracking info
			spawn_cursor = New CELL[lev.spawners.Length] 'automagically initialized to (0, 0); exactly where it needs to be :)
			spawn_ts = New Int[lev.spawners.Length]
			last_spawned = New COMPLEX_AGENT[lev.spawners.Length]
			spawn_counter = New Int[lev.spawners.Length]
			For Local i% = 0 To lev.spawners.Length-1
				spawn_cursor[i] = New CELL
				spawn_ts[i] = now()
				last_spawned[i] = Null
				spawn_counter[i] = 0
				If lev.spawners[i].alignment = ALIGNMENT_FRIENDLY
					active_friendly_spawners :+ 1
				Else If lev.spawners[i].alignment = ALIGNMENT_HOSTILE
					active_hostile_spawners :+ 1
				End If
			Next
		Else 'alignment <> ALIGNMENT_NONE
			'flags and counters
			Select alignment
				Case ALIGNMENT_FRIENDLY
					active_friendly_units = 0
				Case ALIGNMENT_HOSTILE
					active_hostile_units = 0
			End Select
			'spawn queues and tracking info
			For Local i% = 0 To lev.spawners.Length-1
				If lev.spawners[i].alignment = alignment
					spawn_cursor[i] = New CELL
					spawn_ts[i] = now()
					last_spawned[i] = Null
					spawn_counter[i] = 0
					If lev.spawners[i].alignment = ALIGNMENT_FRIENDLY
						active_friendly_spawners :+ 1
					Else If lev.spawners[i].alignment = ALIGNMENT_HOSTILE
						active_hostile_spawners :+ 1
					End If
				End If
			Next
		End If
	End Method
	
	'returns a list of agents spawned
	Method spawning_system_update:TList()
		Local spawned:TList = CreateList()
		'for each spawner
		Local sp:SPAWNER, cur:CELL, ts%, last:COMPLEX_AGENT, counter%
		For Local i% = 0 To lev.spawners.Length-1
			sp = lev.spawners[i]
			cur = spawn_cursor[i]
			ts = spawn_ts[i]
			last = last_spawned[i]
			counter = spawn_counter[i]
			'if this spawner has more enemies to spawn
			If counter < sp.size
				'if it is time to spawn this spawner's current squad
				If now() - ts >= sp.delay_time[cur.row]
					'if this squad has just been started, or the last spawned enemy is away, dead or null
					If cur.col = 0 Or last = Null Or last.dead() Or last.dist_to( sp.pos ) >= SPAWN_POINT_POLITE_DISTANCE
						Local brain:CONTROL_BRAIN = spawn_agent( sp.squads[cur.row][cur.col], sp.alignment, sp.pos )
						last_spawned[i] = brain.avatar
						spawned.addLast( last_spawned[i] )
						'various counters
						spawn_counter[i] :+ 1
						cur.col :+ 1
						'if that last guy was the last squadmember of the current squad
						If cur.col > sp.squads[cur.row].Length-1
							'advance this spawner to first squadmember of next squad
							cur.col = 0
							cur.row :+ 1
							'restart delay timer
							spawn_ts[i] = now()
							'if that last squad was the last squad of the current spawner
							If cur.row > sp.squads.Length-1
								'active spawner counter update
								Select sp.alignment
									Case ALIGNMENT_FRIENDLY
										active_friendly_spawners :- 1
									Case ALIGNMENT_HOSTILE
										active_hostile_spawners :- 1
								End Select
							End If
						End If
					End If
				Else
				End If
			End If
		Next
		Return spawned
	End Method
	
	Method spawn_agent:CONTROL_BRAIN( archetype_index%, alignment%, spawn_point:POINT )
		Local this_agent:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], alignment ))
		Select alignment
			Case ALIGNMENT_HOSTILE
				this_agent.manage( hostile_agent_list )
				active_hostile_units :+ 1
			Case ALIGNMENT_FRIENDLY
				this_agent.manage( friendly_agent_list )
				active_friendly_units :+ 1
		End Select
		Local brain:CONTROL_BRAIN = Create_CONTROL_BRAIN( this_agent, CONTROL_BRAIN.CONTROL_TYPE_AI,, 10, 1000, 1000 )
		'this should be data-driven somehow
		brain.factory_queue = ..
		[	ENEMY_INDEX_MOBILE_MINI_BOMB, ..
			ENEMY_INDEX_MOBILE_MINI_BOMB, ..
			ENEMY_INDEX_MOBILE_MINI_BOMB, ..
			ENEMY_INDEX_MOBILE_MINI_BOMB ] 
		brain.manage( control_brain_list )
		this_agent.spawn_at( spawn_point, 1250 )
		this_agent.snap_all_turrets()
		'this should come from an emitter event attached to the agent
		Local pt:POINT = Create_POINT( this_agent.pos_x, this_agent.pos_y )
		Local em:EMITTER = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_SPAWNER] ))
		em.manage( environmental_emitter_list )
		em.parent = pt
		em.attach_at( ,, 30,60, -180,180,,,,, -0.04,-0.08 )
		em.enable( MODE_ENABLED_WITH_TIMER )
		em.time_to_live = 1000
		em.prune_on_disable = True
		Local part:PARTICLE = get_particle( "soft_glow" )
		part.manage( particle_list_foreground )
		part.parent = pt
		Return brain
	End Method
	
	Method deal_damage( ag:AGENT, damage# )
		'actual damage assignment
		ag.receive_damage( damage )
		'player-specific code
		If human_participation And ag.id = get_player_id()
			'health bar chunk fall-off
			Local health_pct# = player.cur_health/player.max_health
			Local damage_pct# = damage/player.max_health
			
			Local bit:WIDGET = WIDGET( WIDGET.Create( "health bit", create_rect_img( damage_pct * health_bar_w, health_bar_h - 3 ),,, REPEAT_MODE_LOOP_BACK, True ))
			bit.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0.0,  0.0,   0, 255, 255, 255, 1.0,,, 500 )))
			bit.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 6.0,-16.0,-3.0, 255,   0,   0, 0.0,,, 500 )))
			bit.parent = Create_POINT( get_image( "health_mini" ).width + 3, window_h - 2*(get_font( "consolas_bold_12" ).Height() + 3) + 2 )
			bit.attach_at( health_pct * health_bar_w, 2, 0, True )
			bit.manage( health_bits )
		End If
		'resulting death
		If ag.dead() 'some agent was killed
			'agent death animations and sounds, and memory cleanup
			ag.die()
			'shalt we spawneth teh phat lewts?! perhaps!
			spawn_pickup( ag.pos_x, ag.pos_y )
			'complex-agent-specific death routine
			If COMPLEX_AGENT( ag )
				'duplicate code, pulled from ENVIRONMENT.kill()
				Select COMPLEX_AGENT( ag ).political_alignment
					Case ALIGNMENT_FRIENDLY
						active_friendly_units :- 1
					Case ALIGNMENT_HOSTILE
						active_hostile_units :- 1
				End Select
				'hostile complex agent death (as in, not allied with the player)
				If COMPLEX_AGENT( ag ).political_alignment = ALIGNMENT_HOSTILE
					level_enemies_killed :+ 1
				End If
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
		player_engine_ignition = False
		player_engine_running = False
	End Method
	
	Method respawn_player()
		If player <> Null And player_brain <> Null And player.managed() And player_brain.managed()
			player_spawn_point = random_spawn_point( ALIGNMENT_FRIENDLY )
			player.move_to( player_spawn_point )
			player.snap_all_turrets()
			active_friendly_units :+ 1
		End If
	End Method
	
	Method register_AI_spawner( brain:CONTROL_BRAIN )
		AI_spawners.AddLast( brain )
		Select brain.avatar.political_alignment
			Case ALIGNMENT_FRIENDLY
				active_friendly_spawners :+ 1
			Case ALIGNMENT_HOSTILE
				active_hostile_spawners :+ 1
		End Select
	End Method
	
	Method update_AI_spawners_registry()
'		If Not AI_spawners.IsEmpty()
'			Local cursor_link:TLink = AI_spawners.FirstLink()
'			Repeat
'				Local cursor_link_remove:TLink = cursor_link
'				cursor_link = cursor_link.NextLink()
'				Local brain:CONTROL_BRAIN = CONTROL_BRAIN( cursor_link.Value() )
'				If brain.spawn_index >= brain.factory_queue.Length Or brain.avatar.dead()
'					'spawner dead
'					cursor_link_remove.Remove()
'					Select brain.avatar.political_alignment
'						Case ALIGNMENT_FRIENDLY
'							active_friendly_spawners :- 1
'						Case ALIGNMENT_HOSTILE
'							active_hostile_spawners :- 1
'					End Select
'				End If
'			Until cursor_link = AI_spawners.LastLink()
'		End If
	End Method
	
	Method spawn_pickup( x%, y% ) 'request; depends on probability
		Local pkp:PICKUP
		If Rnd( 0.0, 1.0 ) < PICKUP_PROBABILITY
			Local index% = Rand( 0, pickup_archetype.Length - 1 )
			pkp = pickup_archetype[index]
			If pkp <> Null
				pkp = pkp.clone()
				pkp.pos_x = x; pkp.pos_y = y
				pkp.auto_manage()
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
	
	Method add_door( p:POINT, door_list:TList )
		Local left_door:WIDGET
		Local right_door:WIDGET
		left_door = widget_archetype[WIDGET_INDEX_ARENA_DOOR].clone()
		right_door = widget_archetype[WIDGET_INDEX_ARENA_DOOR].clone()
		left_door.parent = p
		right_door.parent = p
		left_door.attach_at( 25 + 50/3 - widget_archetype[WIDGET_INDEX_ARENA_DOOR].img.height/2 + 1, 0, 90, True )
		right_door.attach_at( 25 + 50/3 - widget_archetype[WIDGET_INDEX_ARENA_DOOR].img.height/2 + 1, 0, -90, True )
		left_door.manage( environmental_widget_list )
		right_door.manage( environmental_widget_list )
		door_list.AddLast( left_door )
		door_list.AddLast( right_door )
		Local bg:PARTICLE = get_particle( "door_bg" )
		bg.move_to( p )
		particle_list_background.AddLast( bg )
		Local fg:PARTICLE = get_particle( "door_fg" )
		fg.move_to( p )
		particle_list_foreground.AddLast( fg )
	End Method
	
	Method activate_doors( political_alignment% )
		Local political_door_list:TList
		Select political_alignment
			Case ALIGNMENT_FRIENDLY
				political_door_list = friendly_door_list
				friendly_doors_status = Not friendly_doors_status
			Case ALIGNMENT_HOSTILE
				political_door_list = hostile_door_list
				hostile_doors_status = Not hostile_doors_status
		End Select
		For Local door:WIDGET = EachIn political_door_list
			door.queue_transformation( 1 )
		Next
	End Method
	
	Method reset_all_doors()
		For Local door:WIDGET = EachIn friendly_door_list
			door.reset()
		Next
		For Local door:WIDGET = EachIn hostile_door_list
			door.reset()
		Next
		friendly_doors_status = DOOR_STATUS_CLOSED
		hostile_doors_status = DOOR_STATUS_CLOSED
	End Method
	
	Method find_path:TList( start_x#, start_y#, goal_x#, goal_y#, per_waypoint_chaotic_nudging% = False )
		Local start_cell:CELL = pathing.containing_cell( start_x, start_y )
		Local goal_cell:CELL = pathing.containing_cell( goal_x, goal_y )
		If pathing.grid( start_cell ) = PATH_BLOCKED Or pathing.grid( goal_cell ) = PATH_BLOCKED
			Return Null
		End If
		pathing.reset()
		Local cell_list:TList = ..
			pathing.find_CELL_path( start_cell, goal_cell )
		Local list:TList = CreateList()
		If cell_list <> Null And Not cell_list.IsEmpty()
			For Local cursor:CELL = EachIn cell_list
				If per_waypoint_chaotic_nudging
					list.AddLast( lev.get_random_contained_point( cursor ))
				Else
					list.AddLast( lev.get_midpoint( cursor ))
				End If
			Next
		End If
		Return list
	End Method

	Method point_inside_arena%( p:POINT )
		Return True
	End Method
	
	Method kill( brain:CONTROL_BRAIN )
		If brain <> Null And Not brain.avatar.dead()
			brain.avatar.die()
			'this should be part of the complex agent's death emitters
			play_sound( get_sound( "cannon_hit" ), 0.5, 0.25 )
			Select brain.avatar.political_alignment
				Case ALIGNMENT_FRIENDLY
					active_friendly_units :- 1
				Case ALIGNMENT_HOSTILE
					active_hostile_units :- 1
			End Select
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

