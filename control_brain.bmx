Rem
	control_brain.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global control_brain_list:TList = CreateList()

Const CONTROL_TYPE_HUMAN% = 0
Const CONTROL_TYPE_AI% = 1

Const INPUT_KEYBOARD% = 0
Const INPUT_XBOX_360_CONTROLLER% = 1

Const AI_BRAIN_ROCKET_TURRET% = 0
Const AI_BRAIN_TANK% = 1

Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field target:POINT 'current target
	Field control_type% 'control type indicator
	Field input_type% 'for human-based controllers, the input device
	Field ai_type% 'for AI-based controllers, the specific AI "style"
	Field turret_angular_velocity_max# 'maximum turret rotation speed
	
	Field ang_to_target# '(private)
	Field dist_to_target# '(private)
	
	Method New()
	End Method
	
	Method update()
		prune()
		If      control_type = CONTROL_TYPE_HUMAN Then input_control() ..
		Else If control_type = CONTROL_TYPE_AI    Then AI_control()			
	End Method
	
	Method prune()
		If avatar = Null Or avatar.dead()
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
				If KeyDown( KEY_L ) Or KeyDown( KEY_RIGHT )
					avatar.turn_turrets( ROTATE_CLOCKWISE_DIRECTION, player_turret_angular_velocity_max  )
				ElseIf KeyDown( KEY_J ) Or KeyDown( KEY_LEFT )
					avatar.turn_turrets( ROTATE_COUNTER_CLOCKWISE_DIRECTION, player_turret_angular_velocity_max )
				Else
					avatar.turn_turrets( ALL_STOP )
				EndIf
				'turrets fire
				If KeyDown( KEY_SPACE )
					avatar.fire_turret( 0 )
				End If
				If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
					avatar.fire_turret( 1 )
				End If
					
			Case INPUT_XBOX_360_CONTROLLER
				
			
		End Select
	End Method
	
	Method AI_control()
		Select ai_type

			Case AI_BRAIN_ROCKET_TURRET
				If target <> Null
					'analyze current target
					ang_to_target = vector_diff_angle( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
					dist_to_target = vector_diff_length( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
					Local ang_diff# = avatar.turrets[0].ang - ang_to_target
					'rotate turret if necessary
					If      ang_diff > 0 Then avatar.turn_turrets( ROTATE_CLOCKWISE_DIRECTION, turret_angular_velocity_max ) ..
					Else If ang_diff < 0 Then avatar.turn_turrets( ROTATE_COUNTER_CLOCKWISE_DIRECTION, turret_angular_velocity_max )
					'if enemy in sight then FIRE
					If Abs( ang_diff ) < 2.500 Then avatar.fire_turret( 0 )
					'To Do: add code to check for friendlies in the line of fire.
				Else
					'no target
					ang_to_target = avatar.turrets[0].ang
					dist_to_target = 0
				End If
				
			Case AI_BRAIN_TANK
				'...?
				
		End Select
	End Method
	
End Type



