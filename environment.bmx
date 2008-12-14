Rem
	environment.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const SPAWN_POINT_POLITE_DISTANCE% = 35.0 'delete me (please?)

Function Create_ENVIRONMENT:ENVIRONMENT( human_participation% )
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
	Field environmental_widget_list:TList 'TList<WIDGET>
	Field projectile_list:TList 'TList<PROJECTILE>
	Field friendly_agent_list:TList 'TList<COMPLEX_AGENT>
	Field hostile_agent_list:TList 'TList<COMPLEX_AGENT>
	Field complex_agent_lists:TList 'TList<TList<COMPLEX_AGENT>>
	Field prop_list:TList 'TList<AGENT>
	Field agent_lists:TList 'TList<TList<AGENT>>
	Field pickup_list:TList 'TList<PICKUP>
	Field control_brain_list:TList 'TList<CONTROL_BRAIN>
	
	Field level_enemy_count% 'number of enemies that could possibly be spawned
	Field level_enemies_killed% 'number of enemies that have been killed since being spawned
	
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
	
	Method load_level%( path$ )
		Local file:TStream = ReadFile( path )
		If Not file
			Return False 'indicate failure
		End If
		Local json:TJSON = TJSON.Create( file )
		file.Close()
		lev = Create_LEVEL_from_json( json )
		If lev = Null
			Return False 'indicate failure
		End If
		calculate_camera_constraints()
		
		'pathing (AI bots)
		pathing = PATHING_STRUCTURE.Create( lev )
		'walls (Collisions)
		For Local cursor:CELL = EachIn lev.get_blocking_cells()
			walls.AddLast( lev.get_wall( cursor ))
		Next
		'images (Drawing)
		background_clean = generate_sand_image( lev.width, lev.height )
		foreground = generate_level_walls_image( lev )
		'initialize dynamic background texture with same data as background clean
		background_dynamic = TImage.Create( lev.width, lev.height, 1, FILTEREDIMAGE|DYNAMICIMAGE, 0, 0, 0 )
		SetOrigin( 0, 0 ); SetColor( 255, 255, 255 ); SetAlpha( 1 ); SetRotation( 0 ); SetScale( 1, 1 )
		DrawImage( background_clean, 0, 0 )
		GrabImage( background_dynamic, 0, 0 )
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
		'spawn queues
		spawn_cursor = New CELL[lev.spawners.Length] 'automagically initialized to (0, 0); exactly where it needs to be :)
		spawn_ts = New Int[lev.spawners.Length]
		last_spawned = New COMPLEX_AGENT[lev.spawners.Length]
		spawn_counter = New Int[lev.spawners.Length]
		For Local i% = 0 To lev.spawners.Length-1
			spawn_cursor[i] = New CELL
			spawn_ts[i] = now()
			last_spawned[i] = Null
			spawn_counter[i] = 0
		Next
		'flags
		level_enemy_count = lev.enemy_count()
		level_enemies_killed = 0
		'indicate success
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
	
	Method spawning_system_update()
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
					'if this squad is just started, or the last spawned enemy is far enough away, or dead or null
					If cur.col = 0 Or last = Null Or last.dead() Or last.dist_to( sp.pos ) >= SPAWN_POINT_POLITE_DISTANCE
						Local brain:CONTROL_BRAIN = spawn_agent( sp.squads[cur.row][cur.col], sp.alignment, sp.pos )
						last_spawned[i] = brain.avatar
						'counter
						spawn_counter[i] :+ 1
						cur.col :+ 1
						'if that last guy was the last squadmember of the current squad
						If cur.col > sp.squads[cur.row].Length-1
							'point to first squadmember of spawner's next squad
							cur.col = 0
							cur.row :+ 1
							'start delay timer
							spawn_ts[i] = now()
						End If
					End If
				End If
			End If
		Next
	End Method
	
	Method spawn_agent:CONTROL_BRAIN( archetype_index%, alignment%, spawn_point:POINT )
		Local this_agent:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[archetype_index], alignment ))
		Select alignment
			Case ALIGNMENT_HOSTILE
				this_agent.manage( hostile_agent_list )
			Case ALIGNMENT_FRIENDLY
				this_agent.manage( friendly_agent_list )
		End Select
		Local brain:CONTROL_BRAIN = Create_CONTROL_BRAIN( this_agent, CONTROL_BRAIN.CONTROL_TYPE_AI,, 10, 1000, 1000 )
		brain.manage( control_brain_list )
		this_agent.move_to( spawn_point )
		this_agent.snap_all_turrets()
		Return brain
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
		End If
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
	
End Type

