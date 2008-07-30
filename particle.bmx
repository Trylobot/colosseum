Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global retained_particle_list:TList = CreateList()
Global particle_lists:TList = CreateList()
Global particle_list_background:TList = CreateList(); particle_lists.AddLast( particle_list_background )
Global particle_list_foreground:TList = CreateList(); particle_lists.AddLast( particle_list_foreground )

Const LAYER_FOREGROUND% = 0
Const LAYER_BACKGROUND% = 1

Type PARTICLE Extends POINT

	Field img:TImage 'image to be drawn
	Field layer% 'layer {foreground|background}
	Field retain% 'copy particle to background on death?
	Field frictional_coefficient# 'fake friction
	Field red%, green%, blue% 'color tint (static)
	Field life_time% 'time until object is deleted
	Field created_ts% 'timestamp of object creation

	Field alpha# 'alpha value
	Field alpha_delta# 'alpha rate of change with respect to time
	Field scale# 'scale coefficient
	Field scale_delta# 'scale coefficient rate of change with respect to time
	
	Method New()
	End Method
	
	Function Create:Object( ..
	img:TImage, ..
	layer%, ..
	retain% = False, ..
	frictional_coefficient# = 0.0, ..
	red% = 255, green% = 255, blue% = 255, ..
	life_time% = 0, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	vel_x# = 0.0, vel_y# = 0.0, ..
	ang# = 0.0, ..
	ang_vel# = 0.0, ..
	alpha# = 1.0, ..
	alpha_delta# = 0.0, ..
	scale# = 1.0, ..
	scale_delta# = 0.0 )
		Local p:PARTICLE = New PARTICLE

		'static fields
		p.img = img
		p.layer = layer
		p.retain = retain
		p.frictional_coefficient = frictional_coefficient 
		p.red = red; p.green = green; p.blue = blue
		p.life_time = life_time
		p.created_ts = now()
		
		'dynamic fields
		p.pos_x = pos_x; p.pos_y = pos_y
		p.vel_x = vel_x; p.vel_y = vel_y
		p.ang = ang
		p.ang_vel = ang_vel
		p.alpha = alpha
		p.alpha_delta = alpha_delta
		p.scale = scale
		p.scale_delta = scale_delta

		Return p
	End Function
	
	Method clone:PARTICLE()
		Return PARTICLE( PARTICLE.Create( ..
			img, layer, retain, frictional_coefficient, red, green, blue, life_time, pos_x, pos_y, vel_x, vel_y, ang, ang_vel, alpha, alpha_delta, scale, scale_delta ))
	End Method
	
	Method update()
		'friction
		vel_x :- vel_x*frictional_coefficient
		vel_y :- vel_y*frictional_coefficient
		ang_vel :- ang_vel*frictional_coefficient
		'update velocity, position, angular velocity and orientation
		Super.update()
		'update alpha
		alpha :+ alpha_delta
		'update scale
		scale :+ scale_delta
	End Method
	
	Method draw()
		SetColor( red, green, blue )
		SetAlpha( alpha )
		SetScale( scale, scale )
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method dead%()
		Return ..
			(Not (life_time = INFINITY)) And ..
			(now() - created_ts) >= life_time
	End Method
	
	Method prune()
		If dead()
			'remove from normal managed list
			remove_me()
			If retain
				'particle will be added to the background permanently
				add_me( retained_particle_list )
			End If
		End If
	End Method	
	
	Method auto_manage()
		If layer = LAYER_BACKGROUND
			add_me( particle_list_background )
		Else If layer = LAYER_FOREGROUND
			add_me( particle_list_foreground )
		End If
	End Method
	
End Type

