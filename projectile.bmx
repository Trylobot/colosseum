Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global projectile_list:TList = CreateList()

Type PROJECTILE Extends PHYSICAL_OBJECT
	
	Field img:TImage
	Field explosion_particle_index% 'archetype index of particle to be created on hit
	Field damage# 'maximum damage dealt by projectile
	Field radius# 'radius of damage spread
	Field emitter_list:TList
	Field trail_emitter:EMITTER 'trail particle emitter
	Field thrust_emitter:EMITTER 'thrust particle emitter
	Field source:COMPLEX_AGENT '(private) reference to agent which emitted this projectile; allows for collisions with it to be ignored
	
	Method New()
		force_list = CreateList()
		emitter_list = CreateList()
	End Method
	
	Method update()
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
		Next
		'physical object variables
		Super.update()
	End Method
	
	Method draw()
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
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
	p.frictional_coefficient = 0
	
	'dynamic fields
	p.pos_x = 0; p.pos_y = 0
	p.vel_x = 0; p.vel_y = 0
	p.ang = 0
	p.ang_vel = 0
	
	Return p
End Function
'______________________________________________________________________________
Function Copy_PROJECTILE:PROJECTILE( other:PROJECTILE, source:COMPLEX_AGENT )
	Local p:PROJECTILE = New PROJECTILE
	If other = Null Then Return p
	
	'static fields
	p.source = source
	p.img = other.img
	p.explosion_particle_index = other.explosion_particle_index
	p.mass = other.mass
	p.damage = other.damage
	p.radius = other.radius
	p.frictional_coefficient = 0
	
	'emitters
	If other.thrust_emitter <> Null
		p.thrust_emitter = Copy_EMITTER( other.thrust_emitter, p.emitter_list, p )
		p.thrust_emitter.enable( MODE_ENABLED_FOREVER )
	End If
	If other.trail_emitter <> Null
		p.trail_emitter = Copy_EMITTER( other.trail_emitter, p.emitter_list, p )
		p.trail_emitter.enable( MODE_ENABLED_FOREVER )
	End If
	
	'dynamic fields
	p.pos_x = other.pos_x; p.pos_y = other.pos_y
	p.vel_x = other.vel_x; p.vel_y = other.vel_y
	p.ang = other.ang
	p.ang_vel = other.ang_vel
	
	p.add_me( projectile_list )
	Return p
End Function
