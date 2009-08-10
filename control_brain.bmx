Rem
	control_brain.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'___________________________________________
Function Create_CONTROL_BRAIN:CONTROL_BRAIN( ..
avatar:COMPLEX_AGENT, ..
control_type%, ..
input_type% = UNSPECIFIED, ..
think_delay% = 0, ..
look_target_delay% = 0, ..
find_path_delay% = 0 )
	Local cb:CONTROL_BRAIN = New CONTROL_BRAIN
	cb.avatar = avatar
	cb.control_type = control_type
	cb.input_type = input_type
	If control_type = CONTROL_BRAIN.CONTROL_TYPE_AI
		cb.ai = get_ai_type( avatar.ai_name )
	Else
		cb.ai = Null
	End If
	cb.turret_overheated = New Int[avatar.turrets.Length]
	Return cb
End Function
'_________________________________________
Type CONTROL_BRAIN Extends MANAGED_OBJECT
	Const CONTROL_TYPE_HUMAN% = 1
	Const CONTROL_TYPE_AI% = 2
	Const CONTROL_TYPE_REMOTE% = 3
	Const INPUT_KEYBOARD% = 1
	Const INPUT_KEYBOARD_MOUSE_HYBRID% = 2
	Const INPUT_XBOX_360_CONTROLLER% = 3
	Const waypoint_radius# = 25.0
	Const targeting_radius# = 15.0
	Const spawn_delay% = 1000
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field control_type% 'control type indicator (human/AI)
	Field input_type% 'for human-controlled brains, the input device
	Field ai:AI_TYPE 'for AI-controlled brains, the specific AI "style"
	
	Field path:TList 'TList<cVEC> current path
	Field waypoint:cVEC 'current waypoint (can come from path or from tactical analyzer)
	Field target:AGENT 'current target
	Field turret_overheated%[] 'flags for AI turret control
	
	Field spawn_index% 'tracker for factory
	Field last_spawned_ts% 'timestamp of last spawn
	Field spawn_point:POINT 'actual spawn location
	
	Field can_see_target% 'indicator
	Field ally_blocking% 'indicator
	Field ang_to_target# 'measurement
	Field ang_to_waypoint# 'measurement
	Field dist_to_target# 'measurement
	Field dist_to_waypoint# 'measurement
	
	Method update() 'this function needs some TLC
		prune()
		Select control_type
			Case CONTROL_TYPE_HUMAN
				input_control()
			Case CONTROL_TYPE_AI
				AI_control()
			Case CONTROL_TYPE_REMOTE
				remote_control()
		End Select
	End Method
	
	Method prune()
		If avatar = Null
			unmanage()
		Else If avatar.dead()
			avatar.unmanage()
			unmanage()
		End If
	End Method
	
	Method AI_control()
		'AI state
		target = acquire_target()
		If target <> Null
			ang_to_target = avatar.ang_to( target )
			dist_to_target = avatar.dist_to( target )
		End If
		can_see_target = see_target()
		ally_blocking = any_friendly_blocking()
		If can_see_target
			path = Null
		Else 'Not can_see_target
			If path = Null Or path.IsEmpty()
				'acquire new path if needed
				path = get_path_to_target()
			End If
		End If
		If waypoint = Null Or waypoint_reached()
			'acquire new waypoint
			waypoint = get_next_path_waypoint()
		End If
		If waypoint <> Null
			ang_to_waypoint = avatar.ang_to( waypoint )
			dist_to_waypoint = avatar.dist_to( waypoint )
		End If
		'chassis movement
		If ai.can_move And Not (ai.is_carrier And avatar.is_deployed)
			'target availability
			If can_see_target
				If ai.has_turrets And dist_to_target <= 75
					If Not ally_blocking
						'clear shot, stop and take it
						drive_to( Null )
						waypoint = Null
					Else 'ally_blocking
						'try to drive around the ally
						If Not waypoint
							waypoint = get_random_nearby_waypoint()
						End If
						drive_to( waypoint )
					End If
				Else 'Not ai.has_turrets Or dist_to_target > 50
					'drive towards visible target
					drive_to( target )
					waypoint = Null
				End If
				avatar.ai_lightbulb( True ) 'enable the "ai_lightbulbs"
			Else 'Not can_see_target
				drive_to( waypoint )
				avatar.ai_lightbulb( False ) 'disable the "ai_lightbulbs"
			End If
		End If
		'turrets aim/fire
		If ai.has_turrets
			'target availability
			If can_see_target
				'rotate turrets that aren't pointing at the target
				aim_turrets( target )
				'friendly fire prevention
				If Not ally_blocking
					'fire turrets that want to fire
					fire_turrets()
				End If
			Else 'Not can_see_target
				'return turrets to their default orientations
				aim_turrets( Null )
			End If
		End If
		If target <> Null
			'mini-bomb "self-destruct" ability
			If ai.can_self_destruct
				If avatar.last_collided_agent_id = target.id
					avatar.self_destruct()
				End If
			End If
			'carrier "deploy" ability
			If ai.is_carrier
				If can_see_target And dist_to_target <= 175 And Not avatar.is_deployed And Not spawn_index > 0
					avatar.deploy()
					spawn_point = create_spawn_point()
					last_spawned_ts = now()
				End If
				If avatar.is_deployed
					AI_spawning_system_update()
					If spawn_index >= avatar.factory_queue.Length And now() - last_spawned_ts > 5 * spawn_delay 'done spawning + some delay
						avatar.undeploy()
					End If
				End If
			End If
		End If
	End Method
	
	Method drive_to( dest:Object )
		'drive to nowhere.. that's easy!
		If dest = Null
			avatar.drive( 0 )
			avatar.turn( 0 )
			Return 
		End If
		Local diff# = ang_wrap( avatar.ang_to( dest ) - avatar.ang )
		Local diff_mag# = Abs( diff )
		Local max_ang_vel# = avatar.turning_force.magnitude_max / avatar.mass
		If diff_mag > 20.0 * max_ang_vel
			avatar.drive( 0.3333 )
			If diff < 0
				avatar.turn( -1.0 )
			Else 'diff > 0
				avatar.turn( 1.0 )
			End If
		Else 'diff_mag <= 5.0 * max_ang_vel
			avatar.drive( 1.0 )
			If diff < 0
				avatar.turn( -diff_mag /( 20.0 * max_ang_vel ))
			Else 'diff > 0
				avatar.turn( diff_mag /( 20.0 * max_ang_vel ))
			End If
		End If
	End Method
	
	Method aim_turrets( targ:AGENT = Null )
		For Local index% = 0 To avatar.turret_systems.Length-1
			Local diff#
			If targ
				diff = ang_wrap( avatar.get_turret_system_ang( index ) - avatar.get_turret_system_pos( index ).ang_to( targ ))
			Else
				diff = ang_wrap( avatar.get_turret_system_ang( index ) - avatar.ang )
			End If
			Local diff_mag# = Abs( diff )
			Local max_ang_vel# = avatar.get_turret_system_max_ang_vel( index )
			Local threshold# = 3 * max_ang_vel
			If diff_mag >= threshold
				avatar.turn_turret_system( index, -Sgn(diff) )
			Else 'diff_mag < max_ang_vel
				avatar.turn_turret_system( index, -diff/threshold )
			End If
		Next
	End Method
	
	Method fire_turrets()
		Local system_index%, system_turret_index%, turret_index%
		Local diff#, threshold#
		For system_index = 0 To avatar.turret_systems.Length-1
			diff = ang_wrap( avatar.get_turret_system_ang( system_index ) - ang_to_target )
			threshold = ATan2( targeting_radius, dist_to_target )
			For system_turret_index = 0 To avatar.turret_systems[system_index].Length-1
				turret_index = avatar.turret_systems[system_index][system_turret_index]
				'overheat-wait system update
				If avatar.overheated( turret_index )
					turret_overheated[turret_index] = True
				Else If turret_overheated[turret_index] And avatar.mostly_cooled( turret_index )
					turret_overheated[turret_index] = False
				End If
				'firing checklist
				If Not turret_overheated[turret_index] And Abs( diff ) <= threshold
				'And dist_to_target <= t.effective_range ..
					avatar.fire( turret_index )
				End If
			Next
		Next
	End Method
	
	Method create_spawn_point:POINT()
		Local p:POINT = Copy_POINT( avatar )
		p.ang = avatar.ang + 180
		p.pos_x :+ ( avatar.hitbox.width/2 + 15 )*Cos( 180 + avatar.ang )
		p.pos_y :+ ( avatar.hitbox.width/2 + 15 )*Sin( 180 + avatar.ang )
		Return p
	End Method
	
	Method AI_spawning_system_update()
		If spawn_index < avatar.factory_queue.Length And now() - last_spawned_ts > spawn_delay
			game.spawn_unit( avatar.factory_queue[spawn_index], avatar.political_alignment, spawn_point )
			last_spawned_ts = now()
			spawn_index :+ 1
		Else
		End If
	End Method
	
	Method waypoint_reached%()
		Local current_cell:CELL = game.pathing.containing_cell( avatar.pos_x, avatar.pos_y )
		Local waypoint_cell:CELL = game.pathing.containing_cell( waypoint.x, waypoint.y )
		'If waypoint <> Null And avatar.dist_to( waypoint ) <= waypoint_radius
		If current_cell.eq( waypoint_cell )
			Return True
		Else
			Return False 'sir, where are we going? LOL :D
		End If
	End Method
	
	Method get_next_path_waypoint:cVEC()
		If path <> Null And Not path.IsEmpty()
			path.RemoveFirst()
			If path <> Null And Not path.IsEmpty()
				Return cVEC( path.First())
			End If
		End If
		Return Null 'no seriously.. like, where the hell are we... ;_;
	End Method
	
	Method get_random_nearby_waypoint:cVEC()
		Local ang% = Rand( -180, 180 )
		Local dist% = Rand( 20, 50 )
		Return Create_cVEC( ..
			avatar.pos_x + dist*Cos( ang ), ..
			avatar.pos_y + dist*Sin( ang ))
	End Method
	
	Method acquire_target:AGENT()
		Local ag:AGENT = Null, dist#
		Local rival_agent_list:TList
		Local closest_rival_agent:AGENT = Null, dist_to_ag# = -1
		Select avatar.political_alignment
			Case ALIGNMENT_NONE
				Return Null
			Case ALIGNMENT_FRIENDLY
				rival_agent_list =  game.hostile_agent_list
			Case ALIGNMENT_HOSTILE
				rival_agent_list = game.friendly_agent_list
		End Select
		For ag = EachIn rival_agent_list
			dist = avatar.dist_to( ag )
			If dist_to_ag < 0 Or dist < dist_to_ag
				dist_to_ag = dist
				closest_rival_agent = ag
			End If
		Next
		Return closest_rival_agent
	End Method
	
	Method see_target%()
		If target <> Null
			'last_look_target_ts = now()
			Local av:cVEC = Create_cVEC( avatar.pos_x, avatar.pos_y )
			Local targ:cVEC = Create_cVEC( target.pos_x, target.pos_y )
			'for each wall in the level
			For Local wall:BOX = EachIn game.walls
				'if the line connecting this brain's avatar with its target intersects the wall
				If line_intersects_rect( av,targ, Create_cVEC(wall.x, wall.y), Create_cVEC(wall.w, wall.h) )
					'then the avatar cannot see its target
					Return False
				End If
			Next
			'shot is not blocked by a wall
			Return True
		Else 'target = Null
			Return False
		End If
	End Method
	
	Const friendly_blocking_scalar_projection_distance# = 15.0
	Method any_friendly_blocking%()
		If target <> Null
			Local allied_agent_list:TList = CreateList()
			Select avatar.political_alignment
				Case ALIGNMENT_FRIENDLY
					allied_agent_list = game.friendly_agent_list
				Case ALIGNMENT_HOSTILE
					allied_agent_list = game.hostile_agent_list
			End Select
			Local avatar_turret_ang#, ally_offset#, ally_offset_ang#
			Local scalar_projection#
			Local projected_point:cVEC
			For Local ally:COMPLEX_AGENT = EachIn allied_agent_list
				'is this me? LOL
				If avatar.id = ally.id Then Continue
				'find the scalar projection of the relative position of the ally onto the primary turret's line-of-sight
				avatar_turret_ang = avatar.get_turret_system_ang( 0 )
				ally_offset = avatar.dist_to( ally )
				ally_offset_ang = avatar_turret_ang - avatar.ang_to( ally )
				scalar_projection = ally_offset*Cos( ally_offset_ang )
				If scalar_projection > 0
					projected_point = Create_cVEC( ..
						avatar.pos_x + scalar_projection*Cos( avatar_turret_ang ), ..
						avatar.pos_y + scalar_projection*Sin( avatar_turret_ang ))
					'too close?
					If ally.dist_to( projected_point ) < friendly_blocking_scalar_projection_distance
						Return True 'shot blocked
					End If
				End If
			Next
			Return False 'no allies blocking
		Else 'target = Null
			Return False 'a null target can never be blocked
		End If
	End Method
	
	Method get_path_to_target:TList()
		If target <> Null And now() - last_path_calculation_ts > path_calculation_delay
			last_path_calculation_ts = now()
			Return game.find_path( avatar.pos_x,avatar.pos_y, target.pos_x,target.pos_y, True )
		Else
			Return Null
		End If
	End Method
	Const path_calculation_delay% = 100
	Global last_path_calculation_ts%
	
	Method input_control()
		Select input_type
			
			Case INPUT_KEYBOARD
				'chassis control (only if engine is running)
				If game.player_engine_running
					'velocity
					If KeyDown( KEY_W )
						avatar.drive( 1.0 )
					ElseIf KeyDown( KEY_S )
						avatar.drive( -1.0 )
					Else
						avatar.drive( 0.0 )
					EndIf
					'backwards driving turn inversion
					Local sign% = 1
					If avatar.driving_force.control_pct < 0 And profile.invert_reverse_steering
						sign = -1
					End If
					'angular velocity
					If KeyDown( KEY_D )
						avatar.turn( sign * 1.0 )
					ElseIf KeyDown( KEY_A )
						avatar.turn( sign * -1.0 )
					Else
						avatar.turn( 0.0 )
					EndIf
				Else 'Not game.player_engine_running
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
				End If
				'turret(s) angular velocity
				If KeyDown( KEY_RIGHT ) Or KeyDown( KEY_L )
					avatar.turn_turret_system( 0, 1.0  )
				ElseIf KeyDown( KEY_LEFT ) Or KeyDown( KEY_J )
					avatar.turn_turret_system( 0, -1.0 )
				Else
					avatar.turn_turret_system( 0, 0.0 )
				EndIf
				'turret(s) fire
				If KeyDown( KEY_SPACE )
					avatar.fire_all( TURRET.PRIMARY )
				End If
				If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
					avatar.fire_all( TURRET.SECONDARY )
				End If

			Case INPUT_KEYBOARD_MOUSE_HYBRID
				'chassis control (only if engine is running)
				If game.player_engine_running
					'velocity
					If KeyDown( KEY_W ) Or KeyDown( KEY_UP )
						avatar.drive( 1.0 )
					ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_DOWN )
						avatar.drive( -1.0 )
					Else
						avatar.drive( 0.0 )
					EndIf
					'backwards driving turn inversion
					Local sign% = 1
					If avatar.driving_force.control_pct < 0 And profile.invert_reverse_steering
						sign = -1
					End If
					'angular velocity
					If KeyDown( KEY_D ) Or KeyDown( KEY_RIGHT )
						avatar.turn( sign * 1.0 )
					ElseIf KeyDown( KEY_A ) Or KeyDown( KEY_LEFT )
						avatar.turn( sign * -1.0 )
					Else
						avatar.turn( 0.0 )
					EndIf
				Else 'Not game.player_engine_running
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
				End If
				'turret aim control
				mouse_turret_input()
				'turret(s) fire
				If MouseDown( 1 ) And Not FLAG_ignore_mouse_1
					avatar.fire_all( TURRET.PRIMARY )
				End If
				If MouseDown( 2 )
					avatar.fire_all( TURRET.SECONDARY )
				End If
					
			'Case INPUT_XBOX_360_CONTROLLER
			
		End Select
	End Method
	
	Method mouse_turret_input()
		For Local index% = 0 Until avatar.turret_systems.Length
			Local diff# = ang_wrap( avatar.get_turret_system_ang( index ) - avatar.get_turret_system_pos( index ).ang_to( game.mouse ))
			Local diff_mag# = Abs( diff )
			Local max_ang_vel# = avatar.get_turret_system_max_ang_vel( index )
			Local threshold# = 3 * max_ang_vel
			If diff_mag >= threshold
				avatar.turn_turret_system( index, -Sgn(diff) )
			Else 'diff_mag < max_ang_vel
				avatar.turn_turret_system( index, -diff/threshold )
			End If
		Next
	End Method
	
	Method human_input_blocked_update()
		avatar.drive( 0.0 )
		avatar.turn( 0.0 )
		If input_type = INPUT_KEYBOARD_MOUSE_HYBRID
			mouse_turret_input()
		End If
	End Method
	
	Method remote_control() 'used for networked multiplayer
		
	End Method
	
End Type
