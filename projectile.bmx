Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global projectile_list:TList = CreateList()

Const PROJECTILE_MEMBER_EMITTER_CONSTANT% = 0
Const PROJECTILE_MEMBER_EMITTER_PAYLOAD% = 1

Type PROJECTILE Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field snd_impact:TSound 'sound to be played on impact
	Field damage# 'maximum damage dealt by projectile
	Field explosive_force_magnitude#
	Field radius# 'radius of damage spread
	Field max_vel# 'absolute maximum speed (enforced)
	Field ignore_other_projectiles% 'whether to ignore collisions with other projectiles {true|false}
	Field source_id% '(private) reference to entity which emitted this projectile; allows for collisions with it to be ignored
	Field emitter_list_constant:TList
	Field emitter_list_payload:TList
	
	Method New()
		emitter_list_constant = CreateList()
		emitter_list_payload = CreateList()
	End Method
	
	Function Create:Object( ..
	name$ = Null, ..
	img:TImage = Null, ..
	snd_impact:TSound = Null, ..
	damage# = 0.0, ..
	explosive_force_magnitude# = 0.0, ..
	radius# = 0.0, ..
	max_vel# = INFINITY, ..
	mass# = 1.0, ..
	frictional_coefficient# = 0.0, ..
	ignore_other_projectiles% = False, ..
	source_id% = NULL_ID, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	vel_x# = 0.0, vel_y# = 0.0, ..
	ang# = 0.0, ..
	ang_vel# = 0.0 )
		Local p:PROJECTILE = New PROJECTILE
		
		'static fields
		p.name = name
		p.img = img
		p.snd_impact = snd_impact
		p.damage = damage
		p.radius = radius
		p.max_vel = max_vel
		p.mass = mass
		p.frictional_coefficient = frictional_coefficient
		p.ignore_other_projectiles = ignore_other_projectiles
		p.source_id = source_id
		
		'dynamic fields
		p.pos_x = pos_x; p.pos_y = pos_y
		p.vel_x = vel_x; p.vel_y = vel_y
		p.ang = ang
		p.ang_vel = ang_vel
		
		Return p
	End Function
	
	Method clone:PROJECTILE( new_source_id% = NULL_ID )
		Local p:PROJECTILE = PROJECTILE( PROJECTILE.Create( ..
			name, img, snd_impact, damage, explosive_force_magnitude, radius, max_vel, mass, frictional_coefficient, ignore_other_projectiles, new_source_id, pos_x, pos_y, vel_x, vel_y, ang, ang_vel ))
		'emitter lists
		For Local em:EMITTER = EachIn emitter_list_constant
			p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_CONSTANT )
		Next
		For Local em:EMITTER = EachIn emitter_list_payload
			p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_PAYLOAD )
		Next
		Return p
	End Method

	Method update()
		'physical object variables
		Super.update()
		'constant-on emitters
		For Local em:EMITTER = EachIn emitter_list_constant
			em.update()
			em.emit()
		Next
		'maximum velocity
		If max_vel <> INFINITY
			Local vel_mag#, vel_dir#
			cartesian_to_polar( vel_x, vel_y, vel_mag, vel_dir )
			If vel_mag > max_vel
				polar_to_cartesian( max_vel, vel_dir, vel_x, vel_y )
			End If
		End If
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method auto_manage()
		add_me( projectile_list )
	End Method
	
	Method impact()
		'payload emitters
		For Local em:EMITTER = EachIn emitter_list_payload
			em.enable( MODE_ENABLED_WITH_COUNTER )
			While em.is_enabled() And em.ready()
				em.update()
				em.emit()
			End While
		Next
		play_impact_sound()
	End Method
	
	Method play_impact_sound()
		If snd_impact <> Null
			Local ch:TChannel = AllocChannel()
			CueSound( snd_impact, ch )
			If source_id <> get_player_id()
				SetChannelVolume( ch, 0.1500 )
			End If
			SetChannelRate( ch, RandF( 0.75, 1.25 ))
			ResumeChannel( ch )
			audio_channels.AddLast( ch )
		End If
	End Method
	
	Method add_emitter:EMITTER( other_em:EMITTER, category% )
		Local em:EMITTER
		Select category
			Case PROJECTILE_MEMBER_EMITTER_CONSTANT
				em = EMITTER( EMITTER.Copy( other_em, emitter_list_constant, Self, source_id ))
				em.enable()
				Return em
			Case PROJECTILE_MEMBER_EMITTER_PAYLOAD
				em = EMITTER( EMITTER.Copy( other_em, emitter_list_payload, Self, source_id ))
				em.disable()
				Return em
			Default
				Return Null
		End Select
	End Method
	
End Type

	
