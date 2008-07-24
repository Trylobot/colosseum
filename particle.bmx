Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PARTICLE Extends POINT
	'Images
	Field img:TImage
	'Alpha control
	Field alpha#
	Field alpha_delta#
	'Scale control
	Field scale#
	Field scale_delta#
	'Lifetime
	Field life_time% 'desired length of time (in milliseconds) until the particle is deleted (0 for infinite)
	Field created_ts% 'timestamp of creation
	'Manager flag
	Field retain% 'if true, on particle's expiration, its image is added to the dynamic background texture as a permanent artifact.
	
	Method New()
	End Method
	
	Method debug()
		Super.debug()
		Print "PARTICLE___________"
		Print "img " + (img <> Null)
		Print "alpha " + alpha
		Print "alpha_delta " + alpha_delta
		Print "scale " + scale
		Print "scale_delta " + scale_delta
		Print "life_time " + life_time
		Print "created_ts " + created_ts
		Print "retain " + retain
	End Method
	
	Method dead%()
		If life_time < 0
			Return False
		Else
			Return now() - created_ts >= life_time
		End If
	End Method
	
	Method prune()
		If dead()
			remove_me()
		End If
	End Method	
	
	Method draw()
		SetRotation( ang )
		SetAlpha( alpha )
		SetScale( scale, scale )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method update()
		'update position
		pos_x :+ vel_x
		pos_y :+ vel_y
		'out-of-bounds kill
		If pos_x > arena_w Then remove_me()
		If pos_x < 0       Then remove_me()
		If pos_y > arena_h Then remove_me()
		If pos_y < 0       Then remove_me()
		'update angle
		ang :+ ang_vel
		'angle wrap
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
		'update alpha
		alpha :+ alpha_delta
		'update scale
		scale :+ scale_delta
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_PARTICLE:PARTICLE( ..
img:TImage )
	Local p:PARTICLE = New PARTICLE
	
	'static fields
	p.img = img
	p.created_ts = now()
	
	'dynamic fields
	p.pos_x = 0; p.pos_y = 0
	p.vel_x = 0; p.vel_y = 0
	p.ang = 0
	p.ang_vel = 0
	p.alpha = 1.000
	p.alpha_delta = 0
	p.scale = 1.000
	p.scale_delta = 0
	p.life_time = 0
	
	Return p
End Function
'______________________________________________________________________________
Function Copy_PARTICLE:PARTICLE( other:PARTICLE )
	Local p:PARTICLE = New PARTICLE
	
	'static fields
	p.img = other.img
	p.created_ts = now()
	
	'dynamic fields
	p.pos_x = other.pos_x; p.pos_y = other.pos_y
	p.vel_x = other.vel_x; p.vel_y = other.vel_y
	p.ang = other.ang
	p.ang_vel = other.ang_vel
	p.alpha = other.alpha
	p.alpha_delta = other.alpha_delta
	p.scale = other.scale
	p.scale_delta = other.scale_delta
	p.life_time = other.life_time
	
	p.add_me( particle_list )
	Return p
End Function

