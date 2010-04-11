Rem
	projectile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "physical_object.bmx"
'Import "emitter.bmx"
'Import "texture_manager.bmx"
'Import "particle_emitter.bmx"
'Import "agent.bmx"
'Import "audio.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global projectile_map:TMap = CreateMap()

Function get_projectile:PROJECTILE( key$, source_id% = NULL_ID, copy% = True )
	Local proj:PROJECTILE = PROJECTILE( projectile_map.ValueForKey( Key.toLower() ))
	If copy And proj Then Return proj.clone( source_id )
	Return proj
End Function

Const PROJECTILE_MEMBER_EMITTER_CONSTANT% = 0
Const PROJECTILE_MEMBER_EMITTER_PAYLOAD% = 1

Type PROJECTILE Extends PHYSICAL_OBJECT
	
	Field img:IMAGE_ATLAS_REFERENCE 'image to be drawn
	Field snd_impact:TSound 'sound to be played on impact
	Field damage# 'maximum damage dealt by projectile
	Field explosive_force_magnitude#
	Field radius# 'radius of damage spread
	Field max_vel# 'absolute maximum speed (enforced)
	Field ignore_other_projectiles% 'DEPRECATED 'whether to ignore collisions with other projectiles {true|false}
	Field source_id% '(private) reference to entity which emitted this projectile; allows for collisions with it to be ignored
	Field emitter_list_constant:TList
	Field emitter_list_payload:TList
	
	Method New()
		emitter_list_constant = CreateList()
		emitter_list_payload = CreateList()
	End Method
	
	Function Create:Object( ..
	img:IMAGE_ATLAS_REFERENCE = Null, ..
	hitbox:BOX = Null, ..
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
		p.img = img
		p.hitbox = hitbox
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
			img, hitbox, snd_impact, damage, explosive_force_magnitude, radius, max_vel, mass, frictional_coefficient, ignore_other_projectiles, new_source_id, pos_x, pos_y, vel_x, vel_y, ang, ang_vel ))
		'emitter lists
		For Local em:PARTICLE_EMITTER = EachIn emitter_list_constant
			p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_CONSTANT )
		Next
		For Local em:PARTICLE_EMITTER = EachIn emitter_list_payload
			p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_PAYLOAD )
		Next
		Return p
	End Method

	Method update()
		'physical object variables
		Super.update()
		'constant-on emitters
		For Local em:PARTICLE_EMITTER = EachIn emitter_list_constant
			em.update()
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
	
	Method emit( background_particle_manager:TList = Null, foreground_particle_manager:TList = Null )
		For Local em:PARTICLE_EMITTER = EachIn emitter_list_constant
			em.emit( background_particle_manager, foreground_particle_manager )
		Next
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		SetRotation( ang )
		DrawImageRef( img, pos_x, pos_y )
	End Method
	
	'Method impact( material%, hit_player% = False )
	Method impact( ..
	other:AGENT = Null, other_agent_is_player% = False, ..
	impact_sound:TSound, ..
	background_particle_manager:TList = Null, foreground_particle_manager:TList = Null )
		'payload emitters
		For Local em:PARTICLE_EMITTER = EachIn emitter_list_payload
			em.enable( EMITTER.MODE_ENABLED_WITH_COUNTER )
			While em.is_enabled() And em.ready()
				em.update()
				em.emit( background_particle_manager, foreground_particle_manager )
			End While
		Next
		Local volume# = 0.3333
		If other <> Null And other_agent_is_player Then volume = 1.00
		play_sound( impact_sound, volume, 0.25 )
	End Method
	
	Method add_emitter:PARTICLE_EMITTER( other_em:PARTICLE_EMITTER, category% )
		Local em:PARTICLE_EMITTER
		Select category
			Case PROJECTILE_MEMBER_EMITTER_CONSTANT
				em = Copy_PARTICLE_EMITTER( other_em, emitter_list_constant, Self )
				em.enable()
				Return em
			Case PROJECTILE_MEMBER_EMITTER_PAYLOAD
				em = Copy_PARTICLE_EMITTER( other_em, emitter_list_payload, Self )
				em.disable()
				Return em
			Default
				Return Null
		End Select
	End Method
	
End Type

Function Create_PROJECTILE_from_json:PROJECTILE( json:TJSON )
	Local p:PROJECTILE
	'no required fields
	p = PROJECTILE( PROJECTILE.Create() )
	'read and assign optional fields as available
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED                 Then p.img = get_image( json.GetString( "image_key" ))
	If p.img
		p.hitbox = Create_BOX( p.img.handle_x, p.img.handle_y, p.img.width(), p.img.height() )
	End If
	If json.TypeOf( "impact_sound_key" ) <> JSON_UNDEFINED          Then p.snd_impact = get_sound( json.GetString( "impact_sound_key" ))
	If json.TypeOf( "damage" ) <> JSON_UNDEFINED                    Then p.damage = json.GetNumber( "damage" )
	If json.TypeOf( "explosive_force_magnitude" ) <> JSON_UNDEFINED Then p.explosive_force_magnitude = json.GetNumber( "explosive_force_magnitude" )
	If json.TypeOf( "radius" ) <> JSON_UNDEFINED                    Then p.radius = json.GetNumber( "radius" )
	If json.TypeOf( "max_vel" ) <> JSON_UNDEFINED                   Then p.max_vel = json.GetNumber( "max_vel" )
	If json.TypeOf( "mass" ) <> JSON_UNDEFINED                      Then p.mass = json.GetNumber( "mass" )
	If json.TypeOf( "ignore_other_projectiles" ) <> JSON_UNDEFINED  Then p.ignore_other_projectiles = json.GetBoolean( "ignore_other_projectiles" )
	If json.TypeOf( "constant_emitters" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "constant_emitters" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local em:PARTICLE_EMITTER = Create_PARTICLE_EMITTER_from_json_reference( TJSON.Create( array.GetByIndex( i )))
				If em Then p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_CONSTANT )
			Next
		End If
	End If
	If json.TypeOf( "payload_emitters" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "payload_emitters" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local em:PARTICLE_EMITTER = Create_PARTICLE_EMITTER_from_json_reference( TJSON.Create( array.GetByIndex( i )))
				If em Then p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_PAYLOAD )
			Next
		End If
	End If
	Return p
End Function


