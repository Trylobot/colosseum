Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global projectile_list:TList = CreateList()

Type PROJECTILE Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field explosion_particle_index% 'archetype index of particle to be created on hit
	Field damage# 'maximum damage dealt by projectile
	Field radius# 'radius of damage spread
	Field source_id% '(private) reference to entity which emitted this projectile; allows for collisions with it to be ignored
	Field emitter_list:TList 'emitter-management list
	Field trail_emitter:EMITTER 'trail particle emitter
	Field thrust_emitter:EMITTER 'thrust particle emitter

	Method New()
		force_list = CreateList()
		emitter_list = CreateList()
	End Method
	
	Function Create:Object( ..
	img:TImage, ..
	explosion_particle_index%, ..
	damage#, ..
	radius#, ..
	mass#, ..
	frictional_coefficient#, ..
	source_id% = NULL_ID, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	vel_x# = 0.0, vel_y# = 0.0, ..
	ang# = 0.0, ..
	ang_vel# = 0.0 )
		Local p:PROJECTILE = New PROJECTILE
		
		'static fields
		p.img = img
		p.explosion_particle_index = explosion_particle_index
		p.damage = damage
		p.radius = radius
		p.mass = mass
		p.frictional_coefficient = frictional_coefficient
		p.source_id = source_id
		
		'dynamic fields
		p.pos_x = pos_x; p.pos_y = pos_y
		p.vel_x = vel_x; p.vel_y = vel_y
		p.ang = ang
		p.ang_vel = ang_vel
		
		Return p
	End Function
	
	Method clone:PROJECTILE( source_id% = NULL_ID )
		Local p:PROJECTILE = PROJECTILE( PROJECTILE.Create( ..
			img, explosion_particle_index, damage, radius, mass, frictional_coefficient, source_id, pos_x, pos_y, vel_x, vel_y, ang, ang_vel ))

		'emitters
		If thrust_emitter <> Null
			p.thrust_emitter = EMITTER( EMITTER.Copy( thrust_emitter, p.emitter_list, p ))
			p.thrust_emitter.enable( MODE_ENABLED_FOREVER )
		End If
		If trail_emitter <> Null
			p.trail_emitter = EMITTER( EMITTER.Copy( trail_emitter, p.emitter_list, p ))
			p.trail_emitter.enable( MODE_ENABLED_FOREVER )
		End If
		
		Return p
	End Method

	Method update()
		'physical object variables
		Super.update()
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
		Next
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method auto_manage()
		add_me( projectile_list )
	End Method
	
End Type

	
