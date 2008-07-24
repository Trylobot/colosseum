Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Global friendly_agent_list:TList = CreateList()
Global hostile_agent_list:TList = CreateList()

Const ALL_STOP% = 0
Const ROTATE_CLOCKWISE_DIRECTION% = 1
Const ROTATE_COUNTER_CLOCKWISE_DIRECTION% = 2
Const MOVE_FORWARD_DIRECTION% = 3
Const MOVE_REVERSE_DIRECTION% = 4

Const ALIGNMENT_NONE% = 0
Const ALIGNMENT_FRIENDLY% = 1
Const ALIGNMENT_HOSTILE% = 2

Type COMPLEX_AGENT Extends AGENT
	
	Field turrets:TURRET[] 'turret array
	Field turret_count% 'number of turret slots
	'Field motivators:MOTIVATOR[] 'motivator force array (controls certain animations)
	Field motivator_count% 'number of motivator slots
	
	Field driving_force:FORCE 'permanent force for this object; also added to the general force list
	Field turning_force:FORCE 'permanent torque for this object; also added to the general force list
	
	Field emitter_list:TList
	Field forward_debris_emitters:EMITTER[] 'forward-facing debris emitter array
	Field rear_debris_emitters:EMITTER[] 'rear-facing debris emitter array
	Field forward_trail_emitters:EMITTER[] 'forward-facing trail emitter array
	Field rear_trail_emitters:EMITTER[] 'rear-facing debris trail array
	
	Method New()
		force_list = CreateList()
		emitter_list = CreateList()
	End Method
	
	Method draw()
		SetRotation( ang )
		If img <> Null Then DrawImage( img, pos_x, pos_y )
		For Local t:TURRET = EachIn turrets
			t.draw()
		Next
	End Method
	
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire_turret( turret_index% = 0 )
		If turret_index < turret_count And turrets[turret_index] <> Null
			turrets[turret_index].fire()
		End If
	End Method
	
	Method update()
		'turrets
		For Local t:TURRET = EachIn turrets
			t.update()
		Next
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
		Next
		'update agent variables
		Super.update()
	End Method
	
	Method drive( pct# )
		driving_force.control_pct = pct
	End Method
	Method turn( pct# )
		turning_force.control_pct = pct
	End Method
	
	Method turn_turrets( action%, angular_speed# = 0 )
		For Local t:TURRET = EachIn turrets
			Select action
				Case ALL_STOP
					t.ang_vel = 0
				Case ROTATE_CLOCKWISE_DIRECTION
					t.ang_vel = angular_speed
				Case ROTATE_COUNTER_CLOCKWISE_DIRECTION
					t.ang_vel = -( angular_speed )
			End Select
		Next
	End Method
	
	Method enable_only_forward_emitters()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters[i] <> Null Then forward_debris_emitters[i].enable( MODE_ENABLED_FOREVER )
			If forward_trail_emitters[i] <> Null  Then forward_trail_emitters[i].enable( MODE_ENABLED_FOREVER )
			If rear_debris_emitters[i] <> Null    Then rear_debris_emitters[i].disable()
			If rear_trail_emitters[i] <> Null     Then rear_trail_emitters[i].disable()
		Next
	End Method
	Method enable_only_rear_emitters()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters[i] <> Null Then forward_debris_emitters[i].disable()
			If forward_trail_emitters[i] <> Null  Then forward_trail_emitters[i].disable()
			If rear_debris_emitters[i] <> Null    Then rear_debris_emitters[i].enable( MODE_ENABLED_FOREVER )
			If rear_trail_emitters[i] <> Null     Then rear_trail_emitters[i].enable( MODE_ENABLED_FOREVER )
		Next
	End Method
	Method disable_all_emitters()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters[i] <> Null Then forward_debris_emitters[i].disable()
			If forward_trail_emitters[i] <> Null  Then forward_trail_emitters[i].disable()
			If rear_debris_emitters[i] <> Null    Then rear_debris_emitters[i].disable()
			If rear_trail_emitters[i] <> Null     Then rear_trail_emitters[i].disable()
		Next
	End Method
	
	Method grant_pickup( pkp:PICKUP )
		Select pkp.pickup_type
			Case AMMO_PICKUP
				'ToDo: insert code to analyze the ammunition type of the pickup and see what turrets take that ammunition
				turrets[0].re_stock( pkp.pickup_amount )
			Case HEALTH_PICKUP
				cur_health :+ pkp.pickup_amount
				If cur_health > max_health Then cur_health = max_health
		End Select
		pkp.remove_me()
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_COMPLEX_AGENT:COMPLEX_AGENT( ..
img:TImage, ..
max_health#, ..
mass#, ..
frictional_coefficient#, ..
cash_value%, ..
turret_count%, ..
motivator_count%, ..
driving_force_magnitude#, ..
turning_force_magnitude# )
	Local c:COMPLEX_AGENT = New COMPLEX_AGENT
	
	'static fields
	c.img = img
	c.max_health = max_health
	c.mass = mass
	c.cash_value = cash_value
	
	'dynamic fields
	c.cur_health = max_health
	c.turret_count = turret_count
	If c.turret_count > 0
		c.turrets = New TURRET[ turret_count ]
	End If
	c.motivator_count = motivator_count
	If c.motivator_count > 0
		'c.motivators = New MOTIVATOR[ motivator_count ]
		c.forward_debris_emitters = New EMITTER[ motivator_count ]
		c.rear_debris_emitters = New EMITTER[ motivator_count ]
		c.forward_trail_emitters = New EMITTER[ motivator_count ]
		c.rear_trail_emitters = New EMITTER[ motivator_count ]
	End If
	c.driving_force = Create_FORCE( PHYSICS_FORCE, 0, driving_force_magnitude )
	c.turning_force = Create_FORCE( PHYSICS_TORQUE, 0, turning_force_magnitude )
	
	Return c
End Function
'______________________________________________________________________________
Function Copy_COMPLEX_AGENT:COMPLEX_AGENT( other:COMPLEX_AGENT, political_alignment% = ALIGNMENT_NONE )
	Local c:COMPLEX_AGENT = New COMPLEX_AGENT
	If other = Null Then Return c
	
	'static fields
	c.img = other.img
	c.max_health = other.max_health
	c.mass = other.mass
	c.cash_value = other.cash_value
	
	'dynamic fields
	c.pos_x = other.pos_x; c.pos_y = other.pos_y
	c.ang = other.ang
	c.cur_health = c.max_health
	If other.turret_count > 0
		c.turret_count = other.turret_count
		c.turrets = New TURRET[ other.turret_count ]
		For Local i% = 0 To other.turret_count - 1
			If other.turrets[i] <> Null Then c.turrets[i] = Copy_TURRET( other.turrets[i], c )
		Next
	End If
	If other.motivator_count > 0
		c.motivator_count = other.motivator_count
		'c.motivators = New MOTIVATOR[ other.motivator_count ]
		c.forward_debris_emitters = New EMITTER[ other.forward_debris_emitters.Length ]
		c.rear_debris_emitters = New EMITTER[ other.rear_debris_emitters.Length ]
		c.forward_trail_emitters = New EMITTER[ other.forward_trail_emitters.Length ]
		c.rear_trail_emitters = New EMITTER[ other.rear_trail_emitters.Length ]
		For Local i% = 0 To other.motivator_count - 1
			'c.motivators[i] = Copy_MOTIVATOR( other.motivators[i] )
			If other.forward_debris_emitters[i] <> Null Then c.forward_debris_emitters[i] = Copy_EMITTER( other.forward_debris_emitters[i], c.emitter_list, c )
			If other.rear_debris_emitters[i] <> Null Then c.rear_debris_emitters[i] = Copy_EMITTER( other.rear_debris_emitters[i], c.emitter_list, c )
			If other.forward_trail_emitters[i] <> Null Then c.forward_trail_emitters[i] = Copy_EMITTER( other.forward_trail_emitters[i], c.emitter_list, c )
			If other.rear_trail_emitters[i] <> Null Then c.rear_trail_emitters[i] = Copy_EMITTER( other.rear_trail_emitters[i], c.emitter_list, c )
		Next
	End If
	c.driving_force = Copy_FORCE( other.driving_force, c.force_list )
	c.turning_force = Copy_FORCE( other.turning_force, c.force_list )
	
	If political_alignment = ALIGNMENT_FRIENDLY Then c.add_me( friendly_agent_list ) ..
	Else If political_alignment = ALIGNMENT_HOSTILE Then c.add_me( hostile_agent_list )
	Return c
End Function

