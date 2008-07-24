Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Global enemy_list:TList = CreateList()

Const ALL_STOP% = 0
Const ROTATE_CLOCKWISE_DIRECTION% = 1
Const ROTATE_COUNTER_CLOCKWISE_DIRECTION% = 2
Const MOVE_FORWARD_DIRECTION% = 3
Const MOVE_REVERSE_DIRECTION% = 4

Const ALIGNMENT_NOT_APPLICABLE% = 0
Const ALIGNMENT_FRIENDLY% = 1
Const ALIGNMENT_HOSTILE% = 2

Type COMPLEX_AGENT Extends AGENT
	
	Field political_alignment% 'friendly/hostile
	Field turrets:TURRET[] 'turret array
	Field turret_count% 'number of turret slots
	'Field motivators:MOTIVATOR[] 'motivator array
	Field motivator_count% 'number of motivator slots
	Field forward_debris_emitters:EMITTER[] 'forward-facing debris emitter array
	Field rear_debris_emitters:EMITTER[] 'rear-facing debris emitter array
	Field forward_trail_emitters:EMITTER[] 'forward-facing trail emitter array
	Field rear_trail_emitters:EMITTER[] 'rear-facing debris trail array
	
	Method New()
	End Method
	
	Method draw()
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )

		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
		For Local t:TURRET = EachIn turrets
			t.draw()
		Next
	End Method
	
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire( turret_index% = 0 )
		If turret_index < turret_count And turrets[turret_index] <> Null
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
	
	Method command_all_motivators( action%, speed# = 0 )
'		For Local m:TURRET = EachIn motivators
			If action = MOVE_FORWARD_DIRECTION
				vel_x = speed * Cos( ang )
				vel_y = speed * Sin( ang )
				enable_only_rear_emitters()
			Else If action = MOVE_REVERSE_DIRECTION
				vel_x = -( speed * Cos( ang ))
				vel_y = -( speed * Sin( ang ))
				enable_only_forward_emitters()
			Else If action = ALL_STOP
				vel_x = 0
				vel_y = 0
				disable_all_emitters()
			End If
'		Next
	End Method
	
	Method command_all_turrets( action%, angular_speed# = 0 )
		For Local t:TURRET = EachIn turrets
			If action = ALL_STOP
				t.ang_vel = 0
			Else If action = ROTATE_CLOCKWISE_DIRECTION
				t.ang_vel = angular_speed
			Else If action = ROTATE_COUNTER_CLOCKWISE_DIRECTION
				t.ang_vel = -( angular_speed )
			End If
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
				turrets[0].re_stock( pkp.pickup_amount )
			Case HEALTH_PICKUP
				cur_health :+ pkp.pickup_amount - (max_health - cur_health)
		End Select
	End Method
	
	Method remove_me()
		Super.remove_me()
		For Local i% = 0 To motivator_count - 1
			If forward_debris_emitters[i] <> Null Then forward_debris_emitters[i].remove_me()
			If forward_trail_emitters[i] <> Null  Then forward_trail_emitters[i].remove_me()
			If rear_debris_emitters[i] <> Null    Then rear_debris_emitters[i].remove_me()
			If rear_trail_emitters[i] <> Null     Then rear_trail_emitters[i].remove_me()
		Next
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_COMPLEX_AGENT:COMPLEX_AGENT( ..
political_alignment%, ..
img:TImage, ..
max_health#, ..
mass#, ..
cash_value%, ..
turret_count%, ..
motivator_count% )
	Local c:COMPLEX_AGENT = New COMPLEX_AGENT
	
	'static fields
	c.political_alignment = political_alignment
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
Function Copy_COMPLEX_AGENT:COMPLEX_AGENT( other:COMPLEX_AGENT, emitter_management% = False )
	Local c:COMPLEX_AGENT = New COMPLEX_AGENT
	If other = Null Then Return c
	
	'static fields
	c.political_alignment = other.political_alignment
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
			If other.forward_debris_emitters[i] <> Null Then c.forward_debris_emitters[i] = Copy_EMITTER( other.forward_debris_emitters[i], emitter_management, c )
			If other.rear_debris_emitters[i] <> Null Then c.rear_debris_emitters[i] = Copy_EMITTER( other.rear_debris_emitters[i], emitter_management, c )
			If other.forward_trail_emitters[i] <> Null Then c.forward_trail_emitters[i] = Copy_EMITTER( other.forward_trail_emitters[i], emitter_management, c )
			If other.rear_trail_emitters[i] <> Null Then c.rear_trail_emitters[i] = Copy_EMITTER( other.rear_trail_emitters[i], emitter_management, c )
		Next
	End If
	
	Return c
End Function
