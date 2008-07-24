Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Global px# = 300, py# = 300, speed# = 1

'______________________________________________________________________________
Global control_brain_list:TList = CreateList()

Const AI_TYPE_ROCKET_TURRET% = 0

'Global sensor_image:TImage = img_half_circle
'Global crosshair_image:TImage = img_cone

Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field target:POINT 'current target
	Field ai_type% 'AI sub-program switch
'	Field sensor_radius# 'radius of sensor images
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
'					ang_to_target = vector_diff_angle( px, py, MouseX(), MouseY() )
'					dist_to_target = vector_diff_length( px, py, MouseX(), MouseY() )
					
			End Select
		End If
	End Method
	
	Method debug()
'		px :+ speed * KeyDown( KEY_RIGHT ) - speed * KeyDown( KEY_LEFT )
'		py :+ speed * KeyDown( KEY_DOWN ) - speed * KeyDown( KEY_UP )
'		'SetColor( 255, 127, 127 ); DrawLine( px, py, px + 30*Cos(avatar.turrets[0].ang), avatar.pos_y + 30*Sin(avatar.turrets[0].ang) )
'		SetColor( 127, 255, 127 ); DrawLine( px, py, py + dist_to_target*Cos(dist_to_target), avatar.pos_y + dist_to_target*Sin(dist_to_target) )
'		
		SetColor( 255, 127, 127 ); DrawLine( avatar.pos_x, avatar.pos_y, avatar.pos_x + 30*Cos(avatar.turrets[0].ang), avatar.pos_y + 30*Sin(avatar.turrets[0].ang) )
		SetColor( 127, 255, 127 ); DrawLine( avatar.pos_x, avatar.pos_y, avatar.pos_x + dist_to_target*Cos(dist_to_target), avatar.pos_y + dist_to_target*Sin(dist_to_target) )
	End Method
	
End Type
