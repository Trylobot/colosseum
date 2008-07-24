Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global friendly_projectile_list:TList = CreateList()
Global hostile_projectile_list:TList = CreateList()

Type PROJECTILE Extends PARTICLE
	
	Field explosion_particle_index% 'archetype index of particle to be created on hit
	Field mass# 'mass of projectile
	Field damage# 'maximum damage dealt by projectile
	Field radius# 'radius of damage spread
	Field trail_emitter:EMITTER 'trail particle emitter
	Field thrust_emitter:EMITTER 'thrust particle emitter
	
	Method New()
	End Method
	
	Method remove_me()
		Super.remove_me()
		If trail_emitter <> Null Then trail_emitter.remove_me()
		If thrust_emitter <> Null Then thrust_emitter.remove_me()
	End Method
	
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
Function Copy_PROJECTILE:PROJECTILE( other:PROJECTILE, managed_list:TList )
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
	If other.thrust_emitter <> Null
		p.thrust_emitter = Copy_EMITTER( other.thrust_emitter, True, p )
		p.thrust_emitter.enable( MODE_ENABLED_FOREVER )
	End If
	If other.trail_emitter <> Null
		p.trail_emitter = Copy_EMITTER( other.trail_emitter, True, p )
		p.trail_emitter.enable( MODE_ENABLED_FOREVER )
	End If
	
	'dynamic fields
	p.pos_x = other.pos_x; p.pos_y = other.pos_y
	p.vel_x = other.vel_x; p.vel_y = other.vel_y
	p.ang = other.ang
	p.ang_vel = other.ang_vel
	p.life_time = other.life_time
	
	If managed_list <> Null Then p.add_me( managed_list )
	Return p
End Function
