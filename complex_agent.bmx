Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Global enemy_list:TList = CreateList()

Type COMPLEX_AGENT Extends AGENT
	
	'Turrets
	Field turrets:TURRET[]
	Field turret_count%
	'Motivators
	'Field motivators:MOTIVATOR[]
	Field motivator_count%
	'Emitters
	Field forward_debris_emitters:EMITTER[]
	Field rear_debris_emitters:EMITTER[]
	Field forward_trail_emitters:EMITTER[]
	Field rear_trail_emitters:EMITTER[]
	
	Method New()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
		For Local t:TURRET = EachIn turrets
			t.draw()
		Next
	End Method
	
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire( turret_index% = 0 )
		If turret_index < turret_count - 1 And turrets[turret_index] <> Null
			turrets[turret_index].fire()
		End If
	End Method
	
	Method update()
		Super.update()
		'all turrets update
		For Local t:TURRET = EachIn turrets
			t.update()
		Next
	End Method
	
	Method rotate_all_turrets( action% )
		For Local t:TURRET = EachIn turrets
			If action = ALL_STOP
				t.ang_vel = 0
			Else If action = CLOCKWISE_DIRECTION
				t.ang_vel = -player_turret_angular_velocity_max
			Else If action = COUNTER_CLOCKWISE_DIRECTION
				t.ang_vel = player_turret_angular_velocity_max
			End If
		Next
	End Method
	
	Method enable_only_forward_emitters()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters <> Null Then forward_debris_emitters[i].enable_counter( False )
			If forward_trail_emitters <> Null  Then forward_trail_emitters[i].enable_counter( False )
			If rear_debris_emitters <> Null    Then rear_debris_emitters[i].disable()
			If rear_trail_emitters <> Null     Then rear_trail_emitters[i].disable()
		Next
	End Method
	Method enable_only_rear_emitters()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters <> Null Then forward_debris_emitters[i].disable()
			If forward_trail_emitters <> Null  Then forward_trail_emitters[i].disable()
			If rear_debris_emitters <> Null    Then rear_debris_emitters[i].enable_counter( False )
			If rear_trail_emitters <> Null     Then rear_trail_emitters[i].enable_counter( False )
		Next
	End Method
	Method disable_all_emitters()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters <> Null Then forward_debris_emitters[i].disable()
			If forward_trail_emitters <> Null Then forward_trail_emitters[i].disable()
			If rear_debris_emitters <> Null Then rear_debris_emitters[i].disable()
			If rear_trail_emitters <> Null Then rear_trail_emitters[i].disable()
		Next
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_COMPLEX_AGENT:COMPLEX_AGENT( ..
img:TImage, ..
max_health#, ..
mass#, ..
cash_value%, ..
turret_count%, ..
motivator_count% )
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
	
	Return c
End Function
'______________________________________________________________________________
Function Copy_COMPLEX_AGENT:COMPLEX_AGENT( other:COMPLEX_AGENT )
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
			If other.forward_debris_emitters[i] <> Null Then c.forward_debris_emitters[i] = Copy_EMITTER( other.forward_debris_emitters[i], c )
			If other.rear_debris_emitters[i] <> Null Then c.rear_debris_emitters[i] = Copy_EMITTER( other.rear_debris_emitters[i], c )
			If other.forward_trail_emitters[i] <> Null Then c.forward_trail_emitters[i] = Copy_EMITTER( other.forward_trail_emitters[i], c )
			If other.rear_trail_emitters[i] <> Null Then c.rear_trail_emitters[i] = Copy_EMITTER( other.rear_trail_emitters[i], c )
		Next
	End If
	
	Return c
End Function
