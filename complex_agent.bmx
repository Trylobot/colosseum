Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
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
		For Local i% = 0 To turret_count - 1
			turrets[i].draw()
		Next
	End Method
	
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire( turret_index% = 0 )
		If turrets[turret_index] <> Null
			turrets[turret_index].fire()
		End If
	End Method
	
	Method update()
		'position
		pos_x :+ vel_x
		pos_y :+ vel_y
		If pos_x > arena_w Then pos_x :- arena_w
		If pos_x < 0       Then pos_x :+ arena_w
		If pos_y > arena_h Then pos_y :- arena_h
		If pos_y < 0       Then pos_y :+ arena_h
		'angle
		ang :+ ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
		'turrets
		For Local i% = 0 To turret_count - 1
			turrets[i].update()
		Next
	End Method
	
	Method enable_only_forward_emitters()
		For Local i% = 0 To motivator_count - 1
			forward_debris_emitters[i].enable_timer( infinite_life_time )
			forward_trail_emitters[i].enable_timer( infinite_life_time )
			rear_debris_emitters[i].disable()
			rear_trail_emitters[i].disable()
		Next
	End Method
	Method enable_only_rear_emitters()
		For Local i% = 0 To motivator_count - 1
			forward_debris_emitters[i].disable()
			forward_trail_emitters[i].disable()
			rear_debris_emitters[i].enable_timer( infinite_life_time )
			rear_trail_emitters[i].enable_timer( infinite_life_time )
		Next
	End Method
	Method disable_all_emitters()
		For Local i% = 0 To motivator_count - 1
			forward_debris_emitters[i].disable()
			forward_trail_emitters[i].disable()
			rear_debris_emitters[i].disable()
			rear_trail_emitters[i].disable()
		Next
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_COMPLEX_AGENT:COMPLEX_AGENT( ..
img:TImage, ..
max_health#, ..
turret_count%, ..
motivator_count% )
	Local c:COMPLEX_AGENT = New COMPLEX_AGENT
	
	'static fields
	c.img = img
	c.max_health = max_health
	
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
	
	'static fields
	c.img = other.img
	c.max_health = other.max_health
	
	'dynamic fields
	c.pos_x = other.pos_x; c.pos_y = other.pos_y
	c.ang = other.ang
	c.cur_health = c.max_health
	If other.turret_count > 0
		c.turret_count = other.turret_count
		c.turrets = New TURRET[ other.turret_count ]
		For Local i% = 0 To other.turret_count - 1
			c.turrets[i] = Copy_TURRET( other.turrets[i], c )
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
			c.forward_debris_emitters[i] = Copy_EMITTER( other.forward_debris_emitters[i], c )
			c.rear_debris_emitters[i] = Copy_EMITTER( other.rear_debris_emitters[i], c )
			c.forward_trail_emitters[i] = Copy_EMITTER( other.forward_trail_emitters[i], c )
			c.rear_trail_emitters[i] = Copy_EMITTER( other.rear_trail_emitters[i], c )
		Next
	End If
	
	Return c
End Function
