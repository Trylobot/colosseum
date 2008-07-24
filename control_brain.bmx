Rem
	load_images.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global control_brain_list:TList = CreateList()

Const AI_TYPE_ROCKET_TURRET% = 0

'Global sensor_image:TImage = img_half_circle
'Global crosshair_image:TImage = img_cone

Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field target:COMPLEX_AGENT 'current target
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
					
					
					
			End Select
		End If
	End Method
	
	Method debug()
		ang_to_target = angle_between( avatar.pos_x, avatar.pos_y, target.pos_x, target.pos_y )
		dist_to_target = Sqr( (target.pos_x-avatar.pos_x)*(target.pos_x-avatar.pos_x) + (target.pos_y-avatar.pos_y)*(target.pos_y-avatar.pos_y) )
		
		Local ax# = avatar.pos_x, ay# = avatar.pos_y, tx# = target.pos_x, ty# = target.pos_y
		Local radius# = 30
		'circular radius
		SetLineWidth(1); SetColor(127, 127, 127); DrawOval( ax - radius, ay - radius, 2*radius, 2*radius )
		SetColor(0, 0, 0); DrawOval( ax - radius + 1, ay - radius + 1, 2*radius - 2, 2*radius - 2 )
		'radius to angle zero
		SetColor(127, 127, 127); DrawLine( ax, ay, ax + radius, ay )
		'radius to avatar angle
		SetColor(127, 255, 127); DrawLine( ax, ay, ax + radius*Cos(avatar.turrets[0].ang), ay + radius*Sin(avatar.turrets[0].ang) )
		'radius to target
		SetLineWidth(2); SetColor(255, 127, 127); DrawLine( ax, ay, ax + radius*Cos(ang_to_target), ay + radius*Sin(ang_to_target) )
		'line 1 to target
		SetLineWidth(1); DrawLine( ax, ay, ax + dist_to_target*Cos(ang_to_target), ay + dist_to_target*Sin(ang_to_target) )
		'line 2 to target (actual, correct )
		SetColor(127, 127, 255); DrawLine( ax, ay, target.pos_x, target.pos_y )
		'line from polar target to actual target
		SetColor(64, 64, 127); DrawLine( target.pos_x, target.pos_y, ax + dist_to_target*Cos(ang_to_target), ay + dist_to_target*Sin(ang_to_target) )
		'vector components
		SetColor(64, 64, 64); DrawLine( ax, ay, target.pos_x, ay ); DrawLine( target.pos_x, ay, target.pos_x, target.pos_y )
		SetColor(255, 255, 255); DrawLine( ax, ay, ax + dist_to_target*Cos(ang_to_target), ay ); DrawLine( ax + dist_to_target*Cos(ang_to_target), ay, ax + dist_to_target*Cos(ang_to_target), ay + dist_to_target*Sin(ang_to_target) )
		'positions
		
		
		SetColor(255, 255, 255)
	End Method
	
End Type
