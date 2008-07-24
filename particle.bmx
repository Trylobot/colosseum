Rem
	particle.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type PARTICLE Extends POINT
	'Images
	Field img:TImage
	'Lifetime
	Field life_time% 'desired length of time (in milliseconds) until the particle is deleted (0 for infinite)
	Field created_ts% 'timestamp of creation
	'Alpha control
	Field alpha_birth#
	Field alpha_death#
	
	Method New()
	End Method
	
	Method dead%()
		If life_time < 0
			Return False
		Else
			Return now() - created_ts >= life_time
		End If
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method update()
		'prune old particles
		If dead()
			link.Remove()
			Return
		End If
		'update positions
		pos_x :+ vel_x
		pos_y :+ vel_y
		'out-of-bounds kill
		If pos_x > arena_w Then link.Remove()
		If pos_x < 0       Then link.Remove()
		If pos_y > arena_h Then link.Remove()
		If pos_y < 0       Then link.Remove()
	End Method
	
End Type
'if( lifetime == -1 ) then the particle never expires;
'else, the particle expires in (lifetime) milliseconds.
Function Create_PARTICLE:PARTICLE( ..
img:TImage, ..
pos_x#, pos_y#, ..
vel_x#, vel_y#, ..
ang#, ..
alpha_birth#, alpha_death#, ..
life_time% = -1 )
	Local p:PARTICLE = New PARTICLE
	p.img = img
	p.pos_x = pos_x
	p.pos_y = pos_y
	p.vel_x = vel_x
	p.vel_y = vel_y
	p.ang = ang
	p.life_time = life_time
	p.created_ts = now()
	p.link = Null
	p.add_me( particle_list )
	Return p
End Function
