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
	Global CONTROL_TYPE_HUMAN% = 1
	Global CONTROL_TYPE_AI% = 2
	Global INPUT_KEYBOARD% = 1
	Global INPUT_KEYBOARD_MOUSE_HYBRID% = 2
	Global INPUT_XBOX_360_CONTROLLER% = 3
	Global waypoint_radius# = 30.0
	Global targeting_radius# = 15.0
	Global friendly_blocking_scalar_projection_distance# = 20.0
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field control_type% 'control type indicator (human/AI)
	Field input_type% 'for human-controlled brains, the input device
	Field ai:AI_TYPE 'for AI-controlled brains, the specific AI "style"
	
	Field path:TList 'TList<cVEC> current path
	Field waypoint:cVEC 'current waypoint (can come from path or from tactical analyzer)
	Field target:AGENT 'current target
	Field turret_overheated%[] 'flags for AI turret control
	Field can_see_target% 'indicator
	Field ally_blocking% 'indicator
	Field ang_to_target# 'measurement
	Field ang_to_waypoint# 'measurement
	Field dist_to_target# 'measurement
	Field dist_to_waypoint# 'measurement
	
	'all of the following fields need to go.
	Field DEPRECATED__sighted_target%
	Field DEPRECATED__think_delay%
	Field DEPRECATED__look_target_delay%
	Field DEPRECATED__find_path_delay%
	Field DEPRECATED__last_think_ts%
	Field DEPRECATED__last_look_target_ts%
	Field DEPRECATED__last_find_path_ts%
	Field DEPRECATED__FLAG_waiting%
	
	Method update() 'this function needs some TLC
		prune()
		If control_type = CONTROL_TYPE_HUMAN
			input_control()
		Else If control_type = CONTROL_TYPE_AI
			AI_control()
		End If
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
		If target = Null Or target.dead()
			'acquire new target if possible
			target = acquire_target()
		End If
		If path = Null Or path.IsEmpty()
			'acquire new path if needed
			path = get_path_to_target()
		End If
		If waypoint = Null Or waypoint_reached()
			'acquire new waypoint
			get_next_waypoint()
		End If
		can_see_target = see_target()
		ally_blocking = False 'friendly_blocking()
		ang_to_target = avatar.ang_to( target )
		ang_to_waypoint = avatar.ang_to_cVEC( waypoint )
		dist_to_target = avatar.dist_to( target )
		dist_to_waypoint = avatar.dist_to_cVEC( waypoint )

		'chassis movement
		If ai.can_move
			'target availability
			If can_see_target
				'move to best tactical position
				'.. which would be where, exactly?
				drive_to_waypoint()
			Else 'Not can_see_target
				drive_to_waypoint()
			End If
		End If
		'turrets aim/fire
		If ai.has_turrets
			'target availability (includes whether target is null or dead)
			If can_see_target
				'point turrets at target
				aim_turrets( target )
				'friendly fire prevention
				If Not ally_blocking
					'fire appropriate turrets
					fire_turrets()
				End If
			Else 'Not can_see_target
				'return turrets to their default orientations
				aim_turrets( Null )
			End If
		End If
		'self-destruct ability
		If ai.can_self_destruct
			If avatar.last_collided_agent_id = target.id
				avatar.self_destruct( target )
			End If
		End If
		'carrier launch ability
		If ai.is_carrier
			'...?
		End If
	End Method
	
	Method drive_to_waypoint()
		Local diff# = ang_wrap( avatar.ang - ang_to_waypoint )
		Local threshold# = ATan2( waypoint_radius, dist_to_waypoint )
		'if the avatar is not pointed at the waypoint
		If Abs( diff ) > threshold
			'turn towards the waypoint, while driving at 1/3 throttle
			avatar.drive( 0.3333 )
			avatar.turn( -1.0*Sgn( diff ))
		Else 'avatar is pointed at the waypoint
			'full speed ahead!
			avatar.drive( 1.0 )
			avatar.turn( -1.0*(diff/threshold) )
		End If
	End Method
	
	Method aim_turrets( targ:AGENT = Null )
		For Local index% = 0 To avatar.turret_systems.Length-1
			Local diff#
			If targ <> Null
				diff = ang_wrap( avatar.get_turret_system_ang( index ) - ang_to_target )
			Else
				diff = ang_wrap( avatar.get_turret_system_ang( index ))
			End If
			Local threshold# = ATan2( targeting_radius, dist_to_target )
			'if the turret system is not pointed at the target
			If targ <> Null And Abs( diff ) > threshold
				avatar.turn_turret_system( index, -1.0*Sgn( diff ))
			Else 'turret system is pointed at the target
				avatar.turn_turret_system( index, -1.0*(diff/threshold) )
			End If
		Next
	End Method
	
	Method fire_turrets()
		Local t:TURRET
		For Local system_index% = 0 To avatar.turret_systems.Length-1
			Local diff# = ang_wrap( avatar.get_turret_system_ang( system_index ) - ang_to_target )
			Local threshold# = ATan2( targeting_radius, dist_to_target )
			For Local turret_index% = 0 To avatar.turret_systems[system_index].Length-1
				t = avatar.turrets[turret_index]
				'overheat-wait system update
				If t.overheated()
					turret_overheated[turret_index] = True
				Else If turret_overheated[turret_index] And t.cur_heat <= 0.25*t.max_heat
					turret_overheated[turret_index] = False
				End If
				'firing checklist
				If Not turret_overheated[turret_index] ..
				And dist_to_target <= t.effective_range ..
				And Abs( diff ) <= threshold
					'OMG Fire!
					t.fire()
				End If
			Next
		Next
	End Method
	
	Method input_control()
		Select input_type
			
			Case INPUT_KEYBOARD, INPUT_KEYBOARD_MOUSE_HYBRID
				'chassis control (only if engine is running)
				If game.player_engine_running
					'velocity
					If KeyDown( KEY_W )' Or KeyDown( KEY_I ) Or KeyDown( KEY_UP )
						avatar.drive( 1.0 )
					ElseIf KeyDown( KEY_S )' Or KeyDown( KEY_K ) Or KeyDown( KEY_DOWN )
						avatar.drive( -1.0 )
					Else
						avatar.drive( 0.0 )
					EndIf
					'angular velocity
					If KeyDown( KEY_D )
						avatar.turn( 1.0 )
					ElseIf KeyDown( KEY_A )
						avatar.turn( -1.0 )
					Else
						avatar.turn( 0.0 )
					EndIf
				Else 'Not game.player_engine_running
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					'start engine
					If KeyHit( KEY_E ) And Not game.player_engine_ignition
						game.player_engine_ignition = True
					End If
				End If
				'turret aim control
				If input_type = INPUT_KEYBOARD
					'turret(s) angular velocity
					If KeyDown( KEY_RIGHT ) Or KeyDown( KEY_L )
						avatar.turn_turret_system( 0, 1.0  )
					ElseIf KeyDown( KEY_LEFT ) Or KeyDown( KEY_J )
						avatar.turn_turret_system( 0, -1.0 )
					Else
						avatar.turn_turret_system( 0, 0.0 )
					EndIf
				Else If input_type = INPUT_KEYBOARD_MOUSE_HYBRID
					For Local t:TURRET = EachIn game.player.turrets
						Local diff# = ang_wrap( t.ang - t.ang_to_cVEC( game.mouse ))
						Local diff_mag# = Abs( diff )
						If diff_mag > 5*t.max_ang_vel
							If diff < 0
								avatar.turn_turret_system( 0, 1.0 )
							Else 'diff > 0
								avatar.turn_turret_system( 0, -1.0 )
							End If
						Else If diff_mag > 2.5*t.max_ang_vel
							If diff < 0
								avatar.turn_turret_system( 0, 0.5 )
							Else 'diff > 0
								avatar.turn_turret_system( 0, -0.5 )
							End If
						Else If diff_mag > 1.25*t.max_ang_vel
							If diff < 0
								avatar.turn_turret_system( 0, 0.25 )
							Else 'diff > 0
								avatar.turn_turret_system( 0, -0.25 )
							End If
						Else If diff_mag > 0.75*t.max_ang_vel
							If diff < 0
								avatar.turn_turret_system( 0, 0.125 )
							Else 'diff > 0
								avatar.turn_turret_system( 0, -0.125 )
							End If
						Else If diff_mag > 0.375*t.max_ang_vel
							If diff < 0
								avatar.turn_turret_system( 0, 0.0625 )
							Else 'diff > 0
								avatar.turn_turret_system( 0, -0.0625 )
							End If
						Else
							If diff < 0
								avatar.turn_turret_system( 0, 0.03125 )
							Else 'diff > 0
								avatar.turn_turret_system( 0, -0.03125 )
							End If
						End If
					Next
				End If
				'turret fire control
				If input_type = INPUT_KEYBOARD
					'turret(s) fire
					If KeyDown( KEY_SPACE )
						avatar.fire( 0 )
					End If
					If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
						avatar.fire( 1 )
					End If
					'If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
					'	avatar.fire_turret_group( 2 )
					'End If
				Else If input_type = INPUT_KEYBOARD_MOUSE_HYBRID
					'turret(s) fire
					If MouseDown( 1 )
						avatar.fire( 0 )
					End If
					If MouseDown( 2 )
						avatar.fire( 1 )
					End If
				End If
					
			Case INPUT_XBOX_360_CONTROLLER
				'..?
			
		End Select
	End Method
	
	Method waypoint_reached%()
		If waypoint <> Null And avatar.dist_to_cVEC( waypoint ) <= waypoint_radius
			Return True
		Else
			Return False 'sir, where are we going? LOL :D
		End If
	End Method
	
	Method get_next_waypoint%()
		If path <> Null And Not path.IsEmpty()
			path.RemoveFirst()
			If path <> Null And Not path.IsEmpty()
				waypoint = cVEC( path.First())
			End If
			Return True 'course locked!
		Else
			Return False 'no seriously.. like, where the hell are we... ;_;
		End If
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
			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
			Local targ:cVEC = cVEC( cVEC.Create( target.pos_x, target.pos_y ))
			'for each wall in the level
			For Local wall:BOX = EachIn game.walls
				'if the line connecting this brain's avatar with its target intersects the wall
				If line_intersects_rect( av,targ, cVEC( cVEC.Create(wall.x, wall.y)), cVEC( cVEC.Create(wall.w, wall.h)) )
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
	
	Method friendly_blocking%()
		If target <> Null
			'last_look_target_ts = now()
			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
			'for each allied agent
			Local allied_agent_list:TList = CreateList()
			Select avatar.political_alignment
				Case ALIGNMENT_FRIENDLY
					allied_agent_list = game.friendly_agent_list
				Case ALIGNMENT_HOSTILE
					allied_agent_list = game.hostile_agent_list
			End Select
			Local ally_offset#, ally_offset_ang#
			Local scalar_projection#
			For Local ally:COMPLEX_AGENT = EachIn allied_agent_list
				'if the line of sight of the avatar is too close to the ally
				ally_offset = avatar.turrets[0].dist_to( ally )
				ally_offset_ang = avatar.turrets[0].ang_to( ally )
				scalar_projection = ally_offset*Cos( ally_offset_ang - avatar.turrets[0].ang )
				If ..
				vector_length( ..
					(ally.pos_x - av.x+scalar_projection*Cos(avatar.turrets[0].ang)), ..
					(ally.pos_y - av.y+scalar_projection*Sin(avatar.turrets[0].ang)) ) ..
				< friendly_blocking_scalar_projection_distance
					'then the avatar's shot is blocked by this ally
					Return True
				End If
			Next
			'after checking all the allies, none are blocking
			Return False
		Else 'target == Null, thus no blockers
			Return False
		End If
	End Method

	Method get_path_to_target:TList()
		If target <> Null
			'last_find_path_ts = now()
			Return game.find_path( avatar.pos_x,avatar.pos_y, target.pos_x,target.pos_y )
		Else
			Return Null
		End If
	End Method
	
'	Method enable_seek_lights()
'		For Local w:WIDGET = EachIn avatar.constant_widgets
'			If      w.name = "AI seek light"   Then w.visible = True ..
'			Else If w.name = "AI wander light" Then w.visible = False
'		Next
'	End Method
	
'	Method enable_wander_lights()
'		For Local w:WIDGET = EachIn avatar.constant_widgets
'			If      w.name = "AI seek light"   Then w.visible = False ..
'			Else If w.name = "AI wander light" Then w.visible = True
'		Next
'	End Method
	
End Type
