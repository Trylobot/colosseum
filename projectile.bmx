Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PROJECTILE Extends PARTICLE

	Field exp_img:TImage
	Field mass#
	Field damage#
	Field radius#
	
	Method New()
	End Method
End Type
'______________________________________________________________________________
Function Create_PROJECTILE:PROJECTILE( ..
img:TImage, exp_img:TImage, ..
pos_x#, pos_y#, ..
vel_x#, vel_y#, ..
ang#, ..
mass#, damage#, radius#, ..
life_time% = infinite_life_time )
	Local p:PROJECTILE = New PROJECTILE
	p.img = img
	p.exp_img = exp_img
	p.pos_x = pos_x
	p.pos_y = pos_y
	p.vel_x = vel_x
	p.vel_y = vel_y
	p.ang = ang
	p.life_time = life_time
	p.created_ts = now()
	p.add_me( projectile_list )
	Return p
End Function
