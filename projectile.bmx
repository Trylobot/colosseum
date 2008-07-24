Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global projectile_list:TList = CreateList()

Type PROJECTILE Extends PARTICLE
	'Images
	Field explosion_particle_index%
	'Data
	Field mass#
	Field damage#
	Field radius#
	'Emitters
	Field trail_emitter:EMITTER
	Field thrust_emitter:EMITTER
	
	Method New()
	End Method
	
'	Method debug()
'		Super.debug()
'		Print "PROJECTILE_________"
'		Print "explosion_particle_index " + explosion_particle_index
'		Print "mass " + mass
'		Print "damage " + damage
'		Print "trail_emitter " + (trail_emitter <> Null)
'		Print "thrust_emitter " + (thrust_emitter <> Null)
'	End Method
	
	Method dead%()
		Return False
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_PROJECTILE:PROJECTILE( ..
img:TImage,  ..
explosion_particle_index%,  ..
mass#, ..
damage#, ..
radius# )
	Local p:PROJECTILE = New PROJECTILE
	
	'static fields
	p.img = img
	p.explosion_particle_index = explosion_particle_index
	p.mass = mass
	p.damage = damage
	p.radius = radius
	p.created_ts = now()
	
	'dynamic fields
	p.pos_x = 0; p.pos_y = 0
	p.vel_x = 0; p.vel_y = 0
	p.ang = 0
	p.ang_vel = 0
	p.life_time = 0
	
	Return p
End Function
'______________________________________________________________________________
Function Copy_PROJECTILE:PROJECTILE( other:PROJECTILE )
	Local p:PROJECTILE = New PROJECTILE
	If other = Null Then Return p
	
	'static fields
	p.img = other.img
	p.explosion_particle_index = other.explosion_particle_index
	p.mass = other.mass
	p.damage = other.damage
	p.radius = other.radius
	p.created_ts = now()
	'emitters
	p.thrust_emitter = other.thrust_emitter
	p.trail_emitter = other.trail_emitter
	
	'dynamic fields
	p.pos_x = other.pos_x; p.pos_y = other.pos_y
	p.vel_x = other.vel_x; p.vel_y = other.vel_y
	p.ang = other.ang
	p.ang_vel = other.ang_vel
	p.life_time = other.life_time
	
	p.add_me( projectile_list )
	Return p
End Function
