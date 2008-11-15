Rem
	control_brain.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem


'______________________________________________________________________________
Const waypoint_radius# = 30.0
Const friendly_blocking_scalar_projection_distance# = 20.0

Const CONTROL_TYPE_HUMAN% = 1
Const CONTROL_TYPE_AI% = 2
Const INPUT_KEYBOARD% = 1
Const INPUT_KEYBOARD_MOUSE_HYBRID% = 2
Const INPUT_XBOX_360_CONTROLLER% = 3
Const AI_BRAIN_MR_THE_BOX% = 1
Const AI_BRAIN_TURRET% = 2
Const AI_BRAIN_SEEKER% = 3
Const AI_BRAIN_VEHICLE% = 4
Const AI_BRAIN_TANK% = 5
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
	If control_type = CONTROL_TYPE_AI
		cb.ai_type = avatar.ai_type
	Else
		cb.ai_type = UNSPECIFIED
	End If
	cb.think_delay = think_delay
	cb.look_target_delay = look_target_delay
	cb.find_path_delay = find_path_delay
	
	cb.sighted_target = False
	cb.last_think_ts = now()
	cb.last_look_target_ts = now()
	cb.last_find_path_ts = now()

	Return cb
End Function
'_________________________________________
Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field target:AGENT 'current target
	Field control_type% 'control type indicator
	Field input_type% 'for human-based controllers, the input device
	Field ai_type% 'for AI-based controllers, the specific AI "style"
	Field think_delay% 'mandatory delay between think cycles
	Field look_target_delay% 'mandatory delay between "see_target" calls
	Field find_path_delay% 'mandatory delay between "find_path" calls
	
	Field path:TList 'path to some destination
	Field waypoint:cVEC 'next waypoint
	Field ang_to_target# '(private)
	Field dist_to_target# '(private)
	Field sighted_target% '(private)
	Field last_think_ts% '(private)
	Field last_look_target_ts% '(private)
	Field last_find_path_ts% '(private)
	Field FLAG_waiting% '(private)
	
	Method New()
	End Method
	
	Method update()
		prune()
		If control_type = CONTROL_TYPE_HUMAN
			input_control()
		Else If control_type = CONTROL_TYPE_AI
			'how often this brain gets processing time
			If (now() - last_think_ts) > think_delay
				last_think_ts = now()
				If waypoint = Null Or waypoint_reached()
					get_next_waypoint()
				End If
				AI_control()
			End If
		End If
	End Method
	
	Method input_control()
		Select input_type
			
			Case INPUT_KEYBOARD, INPUT_KEYBOARD_MOUSE_HYBRID
				'If engine is running
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
				Else
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					'start engine
					If KeyHit( KEY_E ) And Not game.player_engine_ignition
						game.player_engine_ignition = True
					End If
				End If
				
				If input_type = INPUT_KEYBOARD
					'turret(s) angular velocity
					If KeyDown( KEY_RIGHT ) Or KeyDown( KEY_L )
						avatar.turn_turret( 0, 1.0  )
						avatar.turn_turret( 1, 1.0  )
					ElseIf KeyDown( KEY_LEFT ) Or KeyDown( KEY_J )
						avatar.turn_turret( 0, -1.0 )
						avatar.turn_turret( 1, -1.0 )
					Else
						avatar.turn_turret( 0, 0.0 )
						avatar.turn_turret( 1, 0.0 )
					EndIf
				Else If input_type = INPUT_KEYBOARD_MOUSE_HYBRID
					For Local t:TURRET = EachIn game.player.turret_list
						Local diff# = ang_wrap( t.ang - t.ang_to_cVEC( game.mouse ))
						Local diff_mag# = Abs( diff )
						If diff_mag > 5*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 1.0  )
								avatar.turn_turret( 1, 1.0  )
							Else 'diff > 0
								avatar.turn_turret( 0, -1.0 )
								avatar.turn_turret( 1, -1.0 )
							End If
						Else If diff_mag > 2.5*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.5  )
								avatar.turn_turret( 1, 0.5  )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.5 )
								avatar.turn_turret( 1, -0.5 )
							End If
						Else If diff_mag > 1.25*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.25 )
								avatar.turn_turret( 1, 0.25 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.25 )
								avatar.turn_turret( 1, -0.25 )
							End If
						Else If diff_mag > 0.75*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.125 )
								avatar.turn_turret( 1, 0.125 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.125 )
								avatar.turn_turret( 1, -0.125 )
							End If
						Else If diff_mag > 0.375*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.0625 )
								avatar.turn_turret( 1, 0.0625 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.0625 )
								avatar.turn_turret( 1, -0.0625 )
							End If
						Else
							If diff < 0
								avatar.turn_turret( 0, 0.03125 )
								avatar.turn_turret( 1, 0.03125 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.03125 )
								avatar.turn_turret( 1, -0.03125 )
							End If
						End If
					Next
				End If
				
				If input_type = INPUT_KEYBOARD
					'turret(s) fire
					If KeyDown( KEY_SPACE )
						avatar.fire( 0 )
					End If
					If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
						avatar.fire( 1 )
					End If
'					If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
'						avatar.fire_turret_group( 2 )
'					End If
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
	
	Method AI_control()
		Select ai_type

			Case AI_BRAIN_MR_THE_BOX
				If path <> Null And Not path.IsEmpty() And waypoint <> Null
					follow_path()
				Else
					If (now() - last_find_path_ts >= find_path_delay)
						path = get_path_to_somewhere()
					Else
						blindly_wander()
					End If
				End If
				
			Case AI_BRAIN_TURRET
				If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, chase it.
					If sighted_target
						'if not facing target, face target; when facing target, fire
						ang_to_target = avatar.ang_to( target )
						Local diff# = ang_wrap( TURRET( avatar.turret_list.First() ).ang - ang_to_target )
						If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
							If diff >= 0 Then avatar.turn_turret( 0, -1.0 ) ..
							Else               avatar.turn_turret( 0, 1.0 )
						Else 'if enemy in sight, fire; To Do: add code to check for friendlies in the line of fire.
							avatar.turn_turret( 0, 0 )
							'wait for cooldown
							If FLAG_waiting And TURRET( avatar.turret_list.First() ).cur_heat <= 0.25*TURRET( avatar.turret_list.First() ).max_heat Then FLAG_waiting = False ..
							Else If TURRET( avatar.turret_list.First() ).overheated() Then FLAG_waiting = True
							If Not FLAG_waiting Then avatar.fire( 0 )
						End If
					Else
						'no line of sight to target
						avatar.turn_turret( 0, 0 )
					End If
				Else
					'no target
					avatar.turn_turret( 0, 0 )
					target = acquire_target()
				End If
				
			Case AI_BRAIN_SEEKER
				If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, chase it.
					If sighted_target
						enable_seek_lights()
						'chase after current target; if target in range, self-destruct
						path = Null
						avatar.drive( 1.0 )
						ang_to_target = avatar.ang_to( target )
						Local diff# = ang_wrap( avatar.ang - ang_to_target )
						If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
							If diff >= 0 Then avatar.turn( -1.0 ) ..
							Else               avatar.turn( 1.0 )
						Else
							avatar.turn( 0 )
						End If
						dist_to_target = avatar.dist_to( target )
						If avatar.last_collided_agent_id = target.id Then avatar.self_destruct( target )
					Else 'cannot see target
						enable_wander_lights()
						If path <> Null And Not path.IsEmpty() And waypoint <> Null
							ang_to_target = avatar.ang_to_cVEC( waypoint )
							Local diff# = ang_wrap( avatar.ang - ang_to_target )
							'if it is pointed toward the path's next waypoint, then..
							If Abs(diff) <= 5.000
								'drive forward
								avatar.drive( 0.4600 )
								avatar.turn( 0.0 )
							'else (not pointed toward next waypoint)..
							Else
								'turn towards the next waypoint and drive at 1/3 speed
								avatar.drive( 0.2300 )
								If diff >= 0 Then avatar.turn( -1.0 ) ..
								Else               avatar.turn( 1.0 )
							End If
						'else (can't see the target, no path to the target)
						Else
							'attempt to get a path to the target (which will not be used until the next "think cycle"
							If (now() - last_find_path_ts >= find_path_delay)
								path = get_path_to_target()
								If path <> Null And Not path.IsEmpty() Then waypoint = cVEC( path.First())
							End If
							blindly_wander()
						End If
					End If
				Else
					'no target
					avatar.drive( 0.333 )
					avatar.turn( Rnd( -0.5, 0.5 ))
					target = acquire_target()
				End If
				
			Case AI_BRAIN_VEHICLE
				If Not game.point_inside_arena( avatar )
					avatar.drive( 1.0 )
					Return
				Else If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, then..
					If sighted_target
						enable_seek_lights()
						path = Null
						ang_to_target = avatar.ang_to( target )
						Local diff# = ang_wrap( TURRET( avatar.turret_list.First() ).ang - ang_to_target )
						'stop moving
						avatar.drive( 0.0 )
						avatar.turn( 0.0 )
						'if its turret is pointing at the target, then..
						If Abs(diff) <= 3.000
							'fire turret(s)
							'wait for cooldown
							If FLAG_waiting And TURRET( avatar.turret_list.First() ).cur_heat <= 0.25*TURRET( avatar.turret_list.First() ).max_heat Then FLAG_waiting = False ..
							Else If TURRET( avatar.turret_list.First() ).overheated() Then FLAG_waiting = True
							If Not FLAG_waiting Then avatar.fire( 0 )
							'stop aiming
							avatar.turn_turret( 0, 0.0 )
						'else (not pointing at target)..
						Else
							'aim the turret at the target
							If diff >= 0 Then avatar.turn_turret( 0, -1.0 ) ..
							Else               avatar.turn_turret( 0, 1.0 )
						End If
					'else (can't see the target) -- if it has a path to the target, then..
					Else
						enable_wander_lights()
						'return the turret to its resting angle
						Local diff# = ang_wrap( avatar.ang - TURRET( avatar.turret_list.First() ).ang )
						If Abs(diff) <= 3.000
							avatar.turn_turret( 0, 0.0 )
						Else
							If diff >= 0 Then avatar.turn_turret( 0, 1.0 ) ..
							Else               avatar.turn_turret( 0, -1.0 )
						End If

						If path <> Null And Not path.IsEmpty() And waypoint <> Null
							ang_to_target = avatar.ang_to_cVEC( waypoint )
							Local diff# = ang_wrap( avatar.ang - ang_to_target )
							'if it is pointed toward the path's next waypoint, then..
							If Abs(diff) <= 3.000
								'drive forward
								avatar.drive( 1.0 )
								avatar.turn( 0.0 )
							'else (not pointed toward next waypoint)..
							Else
								'turn towards the next waypoint and drive at 1/3 speed
								avatar.drive( 0.3333 )
								If diff >= 0 Then avatar.turn( -1.0 ) ..
								Else               avatar.turn( 1.0 )
							End If
						'else (can't see the target, no path to the target)
						Else
							'attempt to get a path to the target (which will not be used until the next "think cycle"
							If (now() - last_find_path_ts >= find_path_delay)
								path = get_path_to_target()
								If path <> Null And Not path.IsEmpty() Then waypoint = cVEC( path.First())
							End If
							'stop driving
							avatar.drive( 0.0 )
							avatar.turn( 0.0 )
						End If
					End If
				Else
					'attempt to acquire a new target
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					target = acquire_target()
				End If				
				
			Case AI_BRAIN_TANK
				If Not game.point_inside_arena( avatar )
					avatar.drive( 1.0 )
					Return
				Else If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, then..
					If sighted_target
						enable_seek_lights()
						path = Null
						ang_to_target = avatar.ang_to( target )
						dist_to_target = avatar.dist_to( target )
						Local diff# = ang_wrap( TURRET( avatar.turret_list.First() ).ang - ang_to_target )
						'stop moving
						avatar.drive( 0.0 )
						avatar.turn( 0.0 )
						'if its turret is pointing at the target, then..
						If Abs(diff) <= 3.000
							'fire turret(s)
							'switch weapon preference based on range; short -> m.gun, long -> cannon
							If dist_to_target > 250
								avatar.fire( 0 )
							Else 'dist_to_target <= 250
								'wait for cooldown
								If FLAG_waiting And TURRET( avatar.turret_list.ValueAtIndex( 1 )).cur_heat <= 0.25*TURRET( avatar.turret_list.ValueAtIndex( 1 )).max_heat
									FLAG_waiting = False
								Else If TURRET( avatar.turret_list.ValueAtIndex( 1 )).overheated()
									FLAG_waiting = True
								End If
								If Not FLAG_waiting Then avatar.fire( 1 )
							End If
							'stop aiming turrets
							avatar.turn_turret( 0, 0.0 )
							avatar.turn_turret( 1, 0.0 )
						'else (not pointing at target)..
						Else
							'aim the turret at the target
							If diff >= 0
								avatar.turn_turret( 0, -1.0 )
								avatar.turn_turret( 1, -1.0 )
							Else
								avatar.turn_turret( 0, 1.0 )
								avatar.turn_turret( 1, 1.0 )
							End If
						End If
					'else (can't see the target) -- if it has a path to the target, then..
					Else
						enable_wander_lights()
						'return the turret to its resting angle
						Local diff# = ang_wrap( avatar.ang - TURRET( avatar.turret_list.First() ).ang )
						If Abs(diff) <= 3.000
							avatar.turn_turret( 0, 0.0 )
							avatar.turn_turret( 1, 0.0 )
						Else
							If diff >= 0
								avatar.turn_turret( 0, 1.0 )
								avatar.turn_turret( 1, 1.0 )
							Else
								avatar.turn_turret( 0, -1.0 )
								avatar.turn_turret( 1, -1.0 )
							End If
						End If

						If path <> Null And Not path.IsEmpty() And waypoint <> Null
							ang_to_target = avatar.ang_to_cVEC( waypoint )
							Local diff# = ang_wrap( avatar.ang - ang_to_target )
							'if it is pointed toward the path's next waypoint, then..
							If Abs(diff) <= 3.000
								'drive forward
								avatar.drive( 1.0 )
								avatar.turn( 0.0 )
							'else (not pointed toward next waypoint)..
							Else
								'turn towards the next waypoint and drive at 1/3 speed
								avatar.drive( 0.3333 )
								If diff >= 0 Then avatar.turn( -1.0 ) ..
								Else              avatar.turn( 1.0 )
							End If
						'else (can't see the target, no path to the target)
						Else
							'attempt to get a path to the target (which will not be used until the next "think cycle"
							If (now() - last_find_path_ts >= find_path_delay)
								path = get_path_to_target()
								If path <> Null And Not path.IsEmpty() Then waypoint = cVEC( path.First())
							End If
							'stop driving
							avatar.drive( 0.0 )
							avatar.turn( 0.0 )
						End If
					End If
				Else
					'attempt to acquire a new target
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					target = acquire_target()
				End If
				
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
			If path <> Null And Not path.IsEmpty() Then waypoint = cVEC( path.First())
			Return True 'course locked!
		Else
			Return False 'no seriously.. like, where the hell are we... ;_;
		End If
	End Method
	
	Method acquire_target:AGENT()
		Local ag:AGENT = Null, dist#
		Local closest_rival_agent:AGENT = Null, dist_to_ag# = -1
		Select avatar.political_alignment
			Case ALIGNMENT_NONE
				Return Null
			Case ALIGNMENT_FRIENDLY
				For ag = EachIn game.hostile_agent_list
					dist = avatar.dist_to( ag )
					If dist_to_ag < 0 Or dist < dist_to_ag
						dist_to_ag = dist
						closest_rival_agent = ag
					End If
				Next
				Return closest_rival_agent 'TARGET ACQUIRED!
			Case ALIGNMENT_HOSTILE
				For ag = EachIn game.friendly_agent_list
					dist = avatar.dist_to( ag )
					If dist_to_ag < 0 Or dist < dist_to_ag
						dist_to_ag = dist
						closest_rival_agent = ag
					End If
				Next
				Return closest_rival_agent 'TARGET ACQUIRED!
		End Select
	End Method
	
	Method see_target%()
		If target <> Null
			last_look_target_ts = now()
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
			'after checking all the walls, still haven't returned; avatar can therefore see its target
			'however, the shot might be blocked by a friendly
			If avatar.turret_list.Count() > 0
				'Return Not friendly_blocking()
				Return True 'disable friendly fire check temporarily, until function can be debugged
			Else 'avatar.turret_count <= 0
				Return True
			End If
		Else 'target == Null
			Return False
		End If
	End Method
	
	Method friendly_blocking%()
		If target <> Null
			last_look_target_ts = now()
			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
			Local targ:cVEC = cVEC( cVEC.Create( target.pos_x, target.pos_y ))
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
				ally_offset = TURRET( avatar.turret_list.First() ).dist_to( ally )
				ally_offset_ang = TURRET( avatar.turret_list.First() ).ang_to( ally )
				scalar_projection = ally_offset*Cos( ally_offset_ang - TURRET( avatar.turret_list.First() ).ang )
				
				If vector_length( ..
				(ally.pos_x - av.x+scalar_projection*Cos(TURRET( avatar.turret_list.First() ).ang)), ..
				(ally.pos_y - av.y+scalar_projection*Sin(TURRET( avatar.turret_list.First() ).ang)) ) ..
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
			last_find_path_ts = now()
			Return game.find_path( avatar.pos_x,avatar.pos_y, target.pos_x,target.pos_y )
		Else
			Return Null
		End If
	End Method
	
	Method get_path_to_somewhere:TList()
		last_find_path_ts = now()
		Local somewhere:cVEC = cVEC( cVEC.Create( Rnd( 0, game.lev.width-1 ), Rnd( 0, game.lev.height-1 )))
		Return game.find_path( avatar.pos_x,avatar.pos_y, somewhere.x,somewhere.y )
	End Method
	
	Method blindly_wander()
		avatar.drive( 0.333 )
		avatar.turn( Rnd( -0.5, 0.5 ))
	End Method
	
	Method seek_target()
		avatar.drive( 1.0 )
		turn_toward_target()
	End Method
	
	Method follow_path()
		ang_to_target = avatar.ang_to_cVEC( waypoint )
		Local diff# = ang_wrap( avatar.ang - ang_to_target )
		'if it is pointed toward the path's next waypoint, then..
		If Abs(diff) <= 15.000
			'drive forward
			avatar.drive( 1.0 )
			avatar.turn( 0.0 )
		'else (not pointed toward next waypoint)..
		Else
			'turn towards the next waypoint and drive at 1/3 speed
			avatar.drive( 0.3333 )
			If diff >= 0 Then avatar.turn( -1.0 ) ..
			Else               avatar.turn( 1.0 )
		End If
	End Method
	
	Method turn_toward_target()
		ang_to_target = avatar.ang_to( target )
		Local diff# = ang_wrap( avatar.ang - ang_to_target )
		If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
			If diff >= 0 Then avatar.turn( -1.0 ) ..
			Else               avatar.turn( 1.0 )
		Else
			avatar.turn( 0 )
		End If
	End Method
	
	Method fire_at_target()
		'fire turret(s)
		'wait for cooldown
		If FLAG_waiting And TURRET( avatar.turret_list.First() ).cur_heat <= 0.25*TURRET( avatar.turret_list.First() ).max_heat Then FLAG_waiting = False ..
		Else If TURRET( avatar.turret_list.First() ).overheated() Then FLAG_waiting = True
		If Not FLAG_waiting Then avatar.fire( 0 )
		'stop aiming
		avatar.turn_turret( 0, 0.0 )
	End Method
	
	Method turn_turrets_toward_target()
		ang_to_target = avatar.ang_to( target )
		Local diff# = ang_wrap( avatar.ang - ang_to_target )
		'aim the turret at the target
		If diff >= 0 Then avatar.turn_turret( 0, -1.0 ) ..
		Else               avatar.turn_turret( 0, 1.0 )
	End Method
	
	Method enable_seek_lights()
		For Local w:WIDGET = EachIn avatar.constant_widgets
			If      w.name = "AI seek light"   Then w.visible = True ..
			Else If w.name = "AI wander light" Then w.visible = False
		Next
	End Method
	
	Method enable_wander_lights()
		For Local w:WIDGET = EachIn avatar.constant_widgets
			If      w.name = "AI seek light"   Then w.visible = False ..
			Else If w.name = "AI wander light" Then w.visible = True
		Next
	End Method
	
	Method prune()
		If avatar = Null
			unmanage()
		Else If avatar.dead()
			avatar.unmanage()
			unmanage()
		End If
	End Method
	
End Type
