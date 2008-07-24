Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const AI_TYPE_ROCKET_TURRET% = 0

Global control_brain_list:TList = CreateList()

Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'avatar in the game world which is controlled by this brain
	Field target:POINT 'current target
	Field ai_type% 'AI subroutine switch
	Field velocity_max#
	Field angular_velocity_max#
	Field turret_angular_velocity_max#
	
	Field ang_to_target# '(private)
	Field dist_to_target# '(private)
	
	Method New()
	End Method
	
	Method prune()
		If avatar = Null Or avatar.dead()
			remove_me()
		End If
	End Method
	
	Method think_and_act()
		If target <> Null
			Select ai_type
				
				Case AI_TYPE_ROCKET_TURRET
					
					point_at( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y, ang_to_target, dist_to_target )
					
					Local comp% = compare_angles( avatar.turrets[0].ang, ang_to_target, 2.0 )
					
					If comp = RESULT_LESS_THAN
						avatar.command_all_turrets( ROTATE_COUNTER_CLOCKWISE_DIRECTION, turret_angular_velocity_max )
					Else If comp = RESULT_GREATER_THAN
						avatar.command_all_turrets( ROTATE_CLOCKWISE_DIRECTION, turret_angular_velocity_max )
					Else 'comp = RESULT_EQUAL
						avatar.command_all_turrets( ALL_STOP )
						avatar.fire( 0 )
					End If
					
'					Local diff# = ang_to_target - avatar.turrets[0].ang
'
'					If Abs( diff ) < 1.000
'						avatar.fire( 0 )
'					End If
'					
'					If diff < 0
'						avatar.command_all_turrets( ROTATE_COUNTER_CLOCKWISE_DIRECTION, turret_angular_velocity_max )
'					Else 'diff >= 0
'						avatar.command_all_turrets( ROTATE_CLOCKWISE_DIRECTION, turret_angular_velocity_max )
'					End If
					
'					If Abs( ang_to_target - avatar.ang ) < 4
'						avatar.fire( 0 )
'					End If
'					
'					SetColor( 0, 255, 0 )
'					DrawLine( avatar.pos_x, avatar.pos_y, avatar
					
			End Select
		End If
	End Method
	
End Type
