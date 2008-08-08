Rem
	control_brain.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global control_brain_list:TList = CreateList()

Const WAYPOINT_RADIUS% = cell_size

Const UNSPECIFIED% = 0
Const CONTROL_TYPE_HUMAN% = 1
Const CONTROL_TYPE_AI% = 2
Const INPUT_KEYBOARD% = 1
Const INPUT_XBOX_360_CONTROLLER% = 2
Const AI_BRAIN_MR_THE_BOX% = 1
Const AI_BRAIN_TURRET% = 2
Const AI_BRAIN_SEEKER% = 3
Const AI_BRAIN_TANK% = 4

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
	
	Method waypoint_reached%()
		If waypoint <> Null
			dist_to_target = avatar.dist_to_cVEC( waypoint )
			If dist_to_target <= WAYPOINT_RADIUS
				Return True
			Else
				Return False
			End If
		Else
			Return False 'sir, where are we going? LOL :D
		End If
	End Method
	
	Method get_next_waypoint%()
		If path <> Null And Not path.IsEmpty()
			waypoint = cVEC( path.First())
			path.RemoveFirst()
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
				For ag = EachIn hostile_agent_list
					dist = avatar.dist_to( ag )
					If dist_to_ag < 0 Or dist < dist_to_ag
						dist_to_ag = dist
						closest_rival_agent = ag
					End If
				Next
				Return closest_rival_agent 'TARGET ACQUIRED!
			Case ALIGNMENT_HOSTILE
				For ag = EachIn friendly_agent_list
					dist = avatar.dist_to( ag )
					If dist_to_ag < 0 Or dist < dist_to_ag
						dist_to_ag = dist
						closest_rival_agent = ag
					End If
				Next
				Return closest_rival_agent 'TARGET ACQUIRED!
		End Select
	End Method
	
	Method see_target%( delay_override% = False )
		If target <> Null And (delay_override Or (now() - last_look_target_ts < look_target_delay))
			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
			Local targ:cVEC = cVEC( cVEC.Create( target.pos_x, target.pos_y ))
			'for each wall in the level
			For Local wall%[] = EachIn combine_lists( common_walls, get_level_walls( player_level ))
				'if the line connecting this brain's avatar with its target intersects the wall
				If line_intersects_rect( av,targ, cVEC( cVEC.Create(wall[1],wall[2])), cVEC( cVEC.Create(wall[3],wall[4])) )
					'then the avatar cannot see its target
					sighted_target = False
				End If
			Next
			'after checking all the walls, still haven't returned; avatar can therefore see its target
			sighted_target = True
		End If
		Return sighted_target
	End Method
	
	Method get_path_to_target:TList( delay_override% = False )
		last_find_path_ts = now()
		If target <> Null And (delay_override Or (now() - last_find_path_ts < find_path_delay))
			Return find_path( avatar.pos_x,avatar.pos_y, target.pos_x,target.pos_y )
		Else
			Return Null
		End If
	End Method
	
	Method input_control()
		Select input_type
			
			Case INPUT_KEYBOARD
				If FLAG_player_engine_running
					'velocity
					If KeyDown( KEY_W ) Or KeyDown( KEY_I ) Or KeyDown( KEY_UP )
						avatar.drive( 1.0 )
					ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K ) Or KeyDown( KEY_DOWN )
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
				End If
				'turrets angular velocity
				If KeyDown( KEY_RIGHT ) Or KeyDown( KEY_L )
					avatar.turn_turrets( 1.0  )
				ElseIf KeyDown( KEY_LEFT ) Or KeyDown( KEY_J )
					avatar.turn_turrets( -1.0 )
				Else
					avatar.turn_turrets( 0.0 )
				EndIf
				'turrets fire
				If KeyDown( KEY_SPACE )
					avatar.fire( 0 )
				End If
				If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
					avatar.fire( 1 )
				End If
				If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
					avatar.fire( 2 )
				End If
				'disembark
				If KeyDown( KEY_E )
					'avatar.disembark
				End If
					
			Case INPUT_XBOX_360_CONTROLLER
				'...?
			
		End Select
	End Method
	
	Method AI_control()
		Select ai_type

			Case AI_BRAIN_MR_THE_BOX
				avatar.drive( 1.0 )
				avatar.turn( RandF( -1.0, 1.0 ))
				
			Case AI_BRAIN_TURRET
				If target <> Null And Not target.dead()
					'if not facing target, face target; when facing target, fire
					ang_to_target = avatar.ang_to( target )
					Local diff# = angle_diff( avatar.turrets[0].ang, ang_to_target )
					If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
						If diff < 180 Then avatar.turn_turrets( -1.0 ) ..
						Else               avatar.turn_turrets( 1.0 )
					Else 'if enemy in sight, fire; To Do: add code to check for friendlies in the line of fire.
						avatar.turn_turrets( 0 )
						'wait for cooldown
						If FLAG_waiting And avatar.turrets[0].cur_heat <= 0.25*avatar.turrets[0].max_heat Then FLAG_waiting = False ..
						Else If avatar.turrets[0].overheated() Then FLAG_waiting = True
						
						If Not FLAG_waiting Then avatar.fire_turret( 0 )
					End If
				Else
					'no target
					avatar.turn_turrets( 0 )
					target = acquire_target()
				End If
				
			Case AI_BRAIN_SEEKER
				If target <> Null And Not target.dead()
					'if it can see the target, chase it.
					If see_target()
						'chase after current target; if target in range, self-destruct
						avatar.drive( 1.0 )
						ang_to_target = avatar.ang_to( target )
						Local diff# = angle_diff( avatar.ang, ang_to_target )
						If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
							If diff < 180 Then avatar.turn( -1.0 ) ..
							Else               avatar.turn( 1.0 )
						Else
							avatar.turn( 0 )
						End If
						dist_to_target = avatar.dist_to( target )
						If dist_to_target <= 20 Then avatar.self_destruct( target )
					Else
						avatar.drive( 0.0 )
						avatar.turn( 0.0 )
					End If
				Else
					'no target
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					target = acquire_target()
				End If
				
			Case AI_BRAIN_TANK
				If target <> Null And Not target.dead()
					'if it can see the target, then..
					If see_target()
						path = Null
						ang_to_target = avatar.ang_to( target )
						Local diff# = angle_diff( avatar.turrets[0].ang, ang_to_target )
						'stop moving
						avatar.drive( 0.0 )
						avatar.turn( 0.0 )
						'if its turret is pointing at the target, then..
						If Abs(diff) <= 3.000
							'fire turret(s)
							avatar.fire( 0 )
							avatar.fire( 1 )
							'stop aiming
							avatar.turn_turrets( 0.0 )
						'else (not pointing at target)..
						Else
							'aim the turret at the target
							If diff < 180 Then avatar.turn_turrets( -1.0 ) ..
							Else               avatar.turn_turrets( 1.0 )
						End If
					'else (can't see the target) -- if it has a path to the target, then..
					Else
						'return the turret to its resting angle
						Local diff# = angle_diff( avatar.ang, avatar.turrets[0].ang )
						If Abs(diff) <= 3.000
							avatar.turn_turrets( 0.0 )
						Else
							If diff < 180 Then avatar.turn_turrets( 1.0 ) ..
							Else               avatar.turn_turrets( -1.0 )
						End If

						If path <> Null And Not path.IsEmpty() And waypoint <> Null
							ang_to_target = avatar.ang_to_cVEC( waypoint )
							Local diff# = angle_diff( avatar.ang, ang_to_target )
							'if it is pointed toward the path's next waypoint, then..
							If Abs(diff) <= 8.000
								'drive forward
								avatar.drive( 1.0 )
								avatar.turn( 0.0 )
							'else (not pointed toward next waypoint)..
							Else
								'turn towards the next waypoint
								avatar.drive( 0.0 )
								If diff < 180 Then avatar.turn( -1.0 ) ..
								Else               avatar.turn( 1.0 )
							End If
						'else (can't see the target, no path to the target)
						Else
							'attempt to get a path to the target (which will not be used until the next "think cycle"
							path = get_path_to_target()
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
	
	Method prune()
		If avatar = Null
			remove_me()
		Else If avatar.dead()
			avatar.remove_me()
			remove_me()
		End If
	End Method
	
End Type
'______________________________________________________________________________
Function Create_and_Manage_CONTROL_BRAIN:CONTROL_BRAIN( ..
avatar:COMPLEX_AGENT, ..
control_type%, ..
input_type%, ..
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

	cb.add_me( control_brain_list )
	Return cb
End Function


