Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_AGENT:AGENT( ..
img:TImage = Null, ..
gibs:TImage = Null, ..
cash_value% = 0, ..
max_health# = 1.0, ..
mass# = 1.0, ..
frictional_coefficient# = 0.0, ..
physics_disabled% = False, ..
destruct_on_contact% = False )
	Local ag:AGENT = New AGENT
	ag.img = img
	ag.hitbox = img
	ag.gibs = gibs
	ag.cash_value = cash_value
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
		other.cash_value, ..
		other.max_health, ..
		other.mass, ..
		other.frictional_coefficient, ..
		other.physics_disabled, ..
		other.destruct_on_contact )
End Function

Type AGENT Extends PHYSICAL_OBJECT

	Field img:TImage 'image to be drawn
	Field hitbox:TImage	'required for accurate-looking hit detection, since complex agents can be composed of many parts
	Field gibs:TImage 'gib image(s)

	Field max_health# 'maximum health
	Field cash_value% 'cash to be awarded player on death
	Field death_emitters:TList 'emitters to be activated on death
	Field destruct_on_contact% 'whether this agent should die on contact with any complex agents

	Field cur_health# 'current health
	Field last_collided_agent_id% 'id of last agent collided with (for self-destructing agents)
	
	Method New()
		force_list = CreateList()
		death_emitters = CreateList()
	End Method
	
	Method draw( alpha_override# = -1.0, scale_override# = -1.0, DUMMY_PARAMETER% = False )
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method dead%()
		Return (cur_health <= 0)
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no overkill
	End Method

	Method self_destruct()
		Local nearby_objects:TList = game.near_to( Self, 200.0 ) 'the "radius" argument should come from data
		Local damage#, total_force#
		For Local phys_obj:PHYSICAL_OBJECT = EachIn nearby_objects
			Local dist# = dist_to( phys_obj ) 
			'damage
			damage = 150 'this should come from data
			If AGENT( phys_obj )
				game.deal_damage( AGENT( phys_obj ), damage / Pow(( 0.05 * dist + 2 ), 2 ))
			End If
			'explosive knock-back force & torque
			total_force = (phys_obj.mass * 750) / Pow( 0.5 * dist + 24, 2 ) - 5 'the maximum comes from data, and is modulated with the actual distance
			phys_obj.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ang_to( phys_obj ), total_force, 100 )))
			phys_obj.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE,, Rnd( -2.0, 2.0 )*total_force, 100 )))
		Next
		'self-destruct explosion sound
		play_sound( get_sound( "cannon_hit" ),, 0.25 )
		'death effects
		die()
	End Method
	
	'these boolean switches need to go.
	Method die( show_halo% = True, show_gibs% = True, audible% = True )
		'bright halo
		If show_halo
			'this particle's creation should be part of the agent's death emitters, not hard coded.
			Local halo:PARTICLE = get_particle( "halo" )
			halo.move_to( Self )
			halo.auto_manage()
		End If
		'gibby bits
		If show_gibs
			'this should also be controlled by a death emitter, albeit a more complex one.
			'perhaps a special type of emitter that takes a multi-frame image and a series of data to specify initial conditions for each of the gibs.
			If gibs <> Null
				For Local i% = 0 To gibs.frames.Length - 1
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
					gib.ang = ang
					gib.ang_vel = Rnd( -1.0, 1.0 )
					gib.update()
					gib.created_ts = now()
					gib.auto_manage()
				Next
			End If
		End If
		'sound
		If audible
			'...
		End If
		'death emitters
		For Local em:EMITTER = EachIn death_emitters
			em.enable( MODE_ENABLED_WITH_COUNTER )
			While em.ready() And em.is_enabled()
				em.update()
				em.emit()
			End While
		Next
		'delete self
		cur_health = 0
		unmanage()
	End Method
	
	'___________________________________________
	Method add_emitter:EMITTER(	other_em:EMITTER, event% )
		Local em:EMITTER = Copy_EMITTER( other_em )
		em.parent = Self
		em.trigger_event = event
		Select event
			Case EVENT_DEATH
				em.manage( death_emitters )
		End Select
		Return em
	End Method
	
End Type

Function Create_AGENT_from_json:AGENT( json:TJSON )
	Local a:AGENT = New AGENT
	a.img = TImage( get_asset( json.GetString( "img" )))
	a.gibs = TImage( get_asset( json.GetString( "gibs" )))
	a.cash_value = json.GetNumber( "cash_value" )
	a.max_health = json.GetNumber( "max_health" )
	a.mass = json.GetNumber( "mass" )
	a.frictional_coefficient = json.GetNumber( "frictional_coefficient" )
	a.physics_disabled = json.GetBoolean( "physics_disabled" )
	a.destruct_on_contact = json.GetBoolean( "destruct_on_contact" )
	Return a
End Function


