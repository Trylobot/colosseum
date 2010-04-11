Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "texture_manager.bmx"
'Import "physical_object.bmx"
'Import "constants.bmx"
'Import "particle.bmx"
'Import "force.bmx"
'Import "emitter.bmx"
'Import "particle_emitter.bmx"
'Import "audio.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global prop_map:TMap = CreateMap()

Function get_prop:AGENT( Key$, Copy% = True )
	Local ag:AGENT = AGENT( prop_map.ValueForKey( Key.toLower() ))
	If Copy And ag Then Return Copy_AGENT( ag )
	Return ag
End Function

Function Create_AGENT:AGENT( ..
img:IMAGE_ATLAS_REFERENCE = Null, ..
gibs:IMAGE_ATLAS_REFERENCE = Null, ..
max_health# = 1.0, ..
mass# = 1.0, ..
frictional_coefficient# = 0.0, ..
physics_disabled% = False, ..
destruct_on_contact% = False )
	Local ag:AGENT = New AGENT
	ag.img = img
	If ag.img
		ag.hitbox = Create_BOX( ag.img.handle_x, ag.img.handle_y, ag.img.width(), ag.img.height() )
	End If
	ag.gibs = gibs
	ag.max_health = max_health
	ag.mass = mass
	ag.frictional_coefficient = frictional_coefficient
	ag.physics_disabled = physics_disabled
	ag.destruct_on_contact = destruct_on_contact
	Return ag
End Function

Function Copy_AGENT:AGENT( other:AGENT )
	Return Create_AGENT( ..
		other.img, ..
		other.gibs, ..
		other.max_health, ..
		other.mass, ..
		other.frictional_coefficient, ..
		other.physics_disabled, ..
		other.destruct_on_contact )
End Function

Type AGENT Extends PHYSICAL_OBJECT

	Field img:IMAGE_ATLAS_REFERENCE 'image to be drawn
	Field gibs:IMAGE_ATLAS_REFERENCE 'gib image(s)

	Field max_health# 'maximum health
	Field death_emitters:TList 'particle emitters to be activated on death
	Field destruct_on_contact% 'whether this agent should die on contact with any complex agents

	Field cur_health# 'current health
	Field last_collided_agent_id% 'id of last agent collided with (for self-destructing agents)
	Field flash% 'whether to "flash" as the result of a projectile impact
	
	Method New()
		force_list = CreateList()
		death_emitters = CreateList()
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
		SetRotation( ang )
		DrawImageRef( img, pos_x, pos_y )
'		If flash
'			flash = False
'			SetBlend( LIGHTBLEND )
'			DrawImageRef( img, pos_x, pos_y )
'			SetBlend( ALPHABLEND )
'		End If
	End Method
	
	Method dead%()
		Return (cur_health <= 0)
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no overkill
	End Method

	'these boolean switches need to go.
	Method die( background_particle_manager:TList, foreground_particle_manager:TList, show_halo% = True, show_gibs% = True, audible% = True )
		'bright halo
		If show_halo
			'this particle's creation should be part of the agent's death emitters, not hard coded.
			Local halo:PARTICLE = get_particle( "halo" )
			halo.move_to( Self )
			halo.manage( background_particle_manager )
		End If
		'gibby bits
		If show_gibs
			'this should also be controlled by a death emitter, albeit a more complex one.
			'perhaps a special type of emitter that takes a multi-frame image and a series of data to specify initial conditions for each of the gibs.
			If gibs <> Null
				For Local i% = 0 To gibs.cell_count - 1
					Local gib:PARTICLE = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, gibs, i,,,, LAYER_BACKGROUND, True, 0.100,,,,,,, 750 ))
					Local gib_offset#, gib_offset_ang#
					cartesian_to_polar( gib.pos_x, gib.pos_y, gib_offset, gib_offset_ang )
					gib.pos_x = pos_x + gib_offset*Cos( gib_offset_ang + ang )
					gib.pos_y = pos_y + gib_offset*Sin( gib_offset_ang + ang )
					Local gib_vel#, gib_vel_ang#
					gib_vel = Rnd( -2.0, 2.0 )
					gib_vel_ang = Rnd( 0.0, 359.9999 )
					gib.vel_x = vel_x + gib_vel*Cos( gib_vel_ang + ang )
					gib.vel_y = vel_y + gib_vel*Sin( gib_vel_ang + ang )
					gib.ang = ang + Rand( -30, 30 )
					gib.ang_vel = Rnd( -3.0, 3.0 )
					gib.update()
					gib.created_ts = now()
					gib.manage( background_particle_manager )
				Next
			End If
		End If
		'sound
		If audible
			'...
		End If
		'death emitters
		For Local em:PARTICLE_EMITTER = EachIn death_emitters
			em.enable( EMITTER.MODE_ENABLED_WITH_COUNTER )
			Repeat
				em.update()
				em.emit( background_particle_manager, foreground_particle_manager )
			Until Not em.is_enabled()
		Next
		'delete self
		cur_health = 0
		unmanage()
	End Method
	
	'___________________________________________
	Method add_emitter:PARTICLE_EMITTER( other_em:PARTICLE_EMITTER, evt% )
		Local em:PARTICLE_EMITTER = Copy_PARTICLE_EMITTER( other_em,, Self )
		em.trigger_event = evt
		Select evt
			Case EVENT.DEATH
				em.manage( death_emitters )
		End Select
		Return em
	End Method
	
	Method write_state_to_stream( stream:TStream )
		Super.write_state_to_stream( stream ) 'PHYSICAL_OBJECT
		stream.WriteFloat( cur_health )
	End Method
	
	Method read_state_from_stream( stream:TStream )
		Super.read_state_from_stream( stream )
		cur_health = stream.ReadFloat()
	End Method
	
End Type

Function Create_AGENT_from_json:AGENT( json:TJSON )
	Local a:AGENT
	'no required fields
	a = Create_AGENT()
	'read and assign optional fields as available
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED              Then a.img = get_image( json.GetString( "image_key" ))
	If a.img
		a.hitbox = Create_BOX( a.img.handle_x, a.img.handle_y, a.img.width(), a.img.height() )
	End If
	If json.TypeOf( "gibs_image_key" ) <> JSON_UNDEFINED         Then a.gibs = get_image( json.GetString( "gibs_image_key" ))
	If json.TypeOf( "max_health" ) <> JSON_UNDEFINED             Then a.max_health = json.GetNumber( "max_health" )
	If json.TypeOf( "mass" ) <> JSON_UNDEFINED                   Then a.mass = json.GetNumber( "mass" )
	If json.TypeOf( "frictional_coefficient" ) <> JSON_UNDEFINED Then a.frictional_coefficient = json.GetNumber( "frictional_coefficient" )
	If json.TypeOf( "physics_disabled" ) <> JSON_UNDEFINED       Then a.physics_disabled = json.GetBoolean( "physics_disabled" )
	If json.TypeOf( "destruct_on_contact" ) <> JSON_UNDEFINED    Then a.destruct_on_contact = json.GetBoolean( "destruct_on_contact" )
	Return a
End Function

