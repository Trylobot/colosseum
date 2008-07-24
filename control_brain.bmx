Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global control_brain_list:TList = CreateList()

Const AI_TYPE_ROCKET_TURRET% = 0

Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field target:POINT 'current target
	Field ai_type% 'AI sub-program switch
	Field velocity_max# 'maximum velocity
	Field angular_velocity_max# 'maximum turning speed
	Field turret_angular_velocity_max# 'maximum turret rotation speed
	
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
					ang_to_target = vector_diff_angle( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
					dist_to_target = vector_diff_length( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
					
			End Select
		End If
	End Method
	
End Type



