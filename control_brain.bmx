Rem
	control_brain.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global control_brain_list:TList = CreateList()

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
	Field think_delay# 'for AI-based controllers, a mandatory delay before it's allowed to think
	
	Field ang_to_target# '(private)
	Field dist_to_target# '(private)
	Field last_think_ts% '(private)
	Field FLAG_waiting% '(private)
	
	Method New()
	End Method
	
	Method update()
		prune()
		If control_type = CONTROL_TYPE_HUMAN
			input_control()
		Else If control_type = CONTROL_TYPE_AI
			'automatic "think delay" designed for distributing CPU cycles to agents who need it
			If (now() - last_think_ts) > think_delay
				last_think_ts = now()
				AI_control()
			End If
		End If
	End Method
	
	Method prune()
		If avatar = Null
			remove_me()
		Else If avatar.dead()
			avatar.remove_me()
			remove_me()
		End If
	End Method
	
	Method input_control()
		Select input_type
			
			Case INPUT_KEYBOARD
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
					avatar.fire_turret( 0 )
				End If
				If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
					avatar.fire_turret( 1 )
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
					ang_to_target = vector_diff_angle( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
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
					ang_to_target = avatar.turrets[0].ang
				End If
				
			Case AI_BRAIN_SEEKER
				If target <> Null And Not target.dead()
					'chase after current target; if target in range, self-destruct
					avatar.drive( 1.0 )
					ang_to_target = vector_diff_angle( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
					Local diff# = angle_diff( avatar.ang, ang_to_target )
					If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
						If diff < 180 Then avatar.turn( -1.0 ) ..
						Else               avatar.turn( 1.0 )
					Else
						avatar.turn( 0 )
					End If
					dist_to_target = vector_diff_length( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
					If dist_to_target <= 25 Then avatar.self_destruct( target )
				Else
					'no target
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
				End If
				
			Case AI_BRAIN_TANK
				If target <> Null And Not target.dead()
					
				Else
					
				End If				
				
		End Select
	End Method
	
End Type
'______________________________________________________________________________
Function Create_and_Manage_CONTROL_BRAIN:CONTROL_BRAIN( ..
avatar:COMPLEX_AGENT, ..
target:AGENT, ..
control_type%, ..
input_type%, ..
ai_type%, ..
think_delay# = 0 )
	Local cb:CONTROL_BRAIN = New CONTROL_BRAIN
	
	cb.avatar = avatar
	cb.target = target
	cb.control_type = control_type
	cb.input_type = input_type
	cb.ai_type = ai_type
	cb.think_delay = think_delay
	
	cb.add_me( control_brain_list )
	Return cb
End Function


