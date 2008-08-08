Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Global agent_lists:TList = CreateList()
Global friendly_agent_list:TList = CreateList(); agent_lists.AddLast( friendly_agent_list )
Global hostile_agent_list:TList = CreateList(); agent_lists.AddLast( hostile_agent_list )

Const ALL_STOP% = 0
Const ROTATE_CLOCKWISE_DIRECTION% = 1
Const ROTATE_COUNTER_CLOCKWISE_DIRECTION% = 2
Const MOVE_FORWARD_DIRECTION% = 3
Const MOVE_REVERSE_DIRECTION% = 4

Const TURRETS_ALL% = -1

Const ALIGNMENT_NONE% = 0
Const ALIGNMENT_FRIENDLY% = 1
Const ALIGNMENT_HOSTILE% = 2

Type COMPLEX_AGENT Extends AGENT
	
	Field political_alignment% '{friendly|hostile}
	
	Field turrets:TURRET[] 'turret array
	Field turret_count% 'number of turret slots
	Field firing_sequence%[][][]
	Field firing_state%[]
	Field FLAG_increment_firing_group%[]
	'Field motivators:MOTIVATOR[] 'motivator force array (controls certain animations)
	Field motivator_count% 'number of motivator slots
	
	Field driving_force:FORCE 'permanent force for this object; also added to the general force list
	Field turning_force:FORCE 'permanent torque for this object; also added to the general force list
	Field emitter_list:TList
	Field forward_debris_emitters:EMITTER[] 'forward-facing debris emitter array
	Field rear_debris_emitters:EMITTER[] 'rear-facing debris emitter array
	Field forward_trail_emitters:EMITTER[] 'forward-facing trail emitter array
	Field rear_trail_emitters:EMITTER[] 'rear-facing debris trail array
	Field widget_list_behind:TList
	Field widget_list_in_front:TList
	Field stickies:TList
	
	Method New()
		emitter_list = CreateList()
		widget_list_behind = CreateList()
		widget_list_in_front = CreateList()
		stickies = CreateList()
	End Method
	
	Function Archetype:Object( ..
	img:TImage, ..
	gibs:TImage, ..
	cash_value%, ..
	max_health#, ..
	mass#, ..
	frictional_coefficient#, ..
	turret_count%, ..
	motivator_count%, ..
	driving_force_magnitude#, ..
	turning_force_magnitude#, ..
	physics_disabled% = False )
		Local c:COMPLEX_AGENT = New COMPLEX_AGENT
		
		'static fields
		c.img = img
		c.gibs = gibs
		c.max_health = max_health
		c.mass = mass
		c.frictional_coefficient = frictional_coefficient
		c.cash_value = cash_value
		c.physics_disabled = physics_disabled
		
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
		c.driving_force = FORCE( FORCE.Create( PHYSICS_FORCE, 0, driving_force_magnitude ))
		c.turning_force = FORCE( FORCE.Create( PHYSICS_TORQUE, 0, turning_force_magnitude ))
		
		Return c
	End Function
	
	Function Copy:Object( other:COMPLEX_AGENT, political_alignment% = ALIGNMENT_NONE )
		If other = Null Then Return Null
		Local c:COMPLEX_AGENT = New COMPLEX_AGENT
		
		'static fields
		If political_alignment <> ALIGNMENT_NONE
			c.political_alignment = political_alignment
		Else 'political_alignment == ALIGNMENT_NONE
			c.political_alignment = other.political_alignment
		End If
		c.img = other.img
		c.gibs = other.gibs
		c.max_health = other.max_health
		c.mass = other.mass
		c.frictional_coefficient = other.frictional_coefficient
		c.cash_value = other.cash_value
		c.physics_disabled = other.physics_disabled
		
		'dynamic fields
		c.pos_x = other.pos_x; c.pos_y = other.pos_y
		c.ang = other.ang
		c.cur_health = c.max_health
		If other.turret_count > 0
			c.turret_count = other.turret_count
			c.turrets = New TURRET[ other.turret_count ]
			For Local i% = 0 To other.turret_count - 1
				If other.turrets[i] <> Null
					c.add_turret( other.turrets[i], i ).attach_at( other.turrets[i].off_x, other.turrets[i].off_y )
				End If
			Next
		End If
		c.firing_sequence = other.firing_sequence[..]
		c.firing_state = other.firing_state[..]
		c.FLAG_increment_firing_group = other.FLAG_increment_firing_group[..]
		If other.motivator_count > 0
			c.motivator_count = other.motivator_count
			'c.motivators = New MOTIVATOR[ other.motivator_count ]
			c.forward_debris_emitters = New EMITTER[ other.forward_debris_emitters.Length ]
			c.rear_debris_emitters = New EMITTER[ other.rear_debris_emitters.Length ]
			c.forward_trail_emitters = New EMITTER[ other.forward_trail_emitters.Length ]
			c.rear_trail_emitters = New EMITTER[ other.rear_trail_emitters.Length ]
			For Local i% = 0 To other.motivator_count - 1
				'c.motivators[i] = Copy_MOTIVATOR( other.motivators[i] )
				If other.forward_debris_emitters[i] <> Null Then c.forward_debris_emitters[i] = EMITTER( EMITTER.Copy( other.forward_debris_emitters[i], c.emitter_list, c ))
				If other.rear_debris_emitters[i] <> Null Then c.rear_debris_emitters[i] = EMITTER( EMITTER.Copy( other.rear_debris_emitters[i], c.emitter_list, c ))
				If other.forward_trail_emitters[i] <> Null Then c.forward_trail_emitters[i] = EMITTER( EMITTER.Copy( other.forward_trail_emitters[i], c.emitter_list, c ))
				If other.rear_trail_emitters[i] <> Null Then c.rear_trail_emitters[i] = EMITTER( EMITTER.Copy( other.rear_trail_emitters[i], c.emitter_list, c ))
			Next
		End If
		c.driving_force = FORCE( FORCE.Copy( other.driving_force, c.force_list ))
		c.driving_force.combine_ang_with_parent_ang = True
		c.turning_force = FORCE( FORCE.Copy( other.turning_force, c.force_list ))
		For Local other_w:WIDGET = EachIn other.widget_list_behind
			c.add_widget( other_w ).attach_at( other_w.attach_x, other_w.attach_y )
		Next
		For Local other_w:WIDGET = EachIn other.widget_list_in_front
			c.add_widget( other_w ).attach_at( other_w.attach_x, other_w.attach_y )
		Next
		
		If political_alignment = ALIGNMENT_FRIENDLY Then c.add_me( friendly_agent_list ) ..
		Else If political_alignment = ALIGNMENT_HOSTILE Then c.add_me( hostile_agent_list )
		Return c
	End Function

	Method update()
		'update agent variables
		Super.update()
		'turrets
		For Local t:TURRET = EachIn turrets
			t.update()
		Next
		'firing groups
		For Local i% = 0 To FLAG_increment_firing_group.Length - 1
			If FLAG_increment_firing_group[i]
				Local all_ready% = True
				For Local t_index% = EachIn firing_sequence[i][firing_state[i]]
					If Not turrets[t_index].ready_to_fire()
						all_ready = False
						Exit
					End If
				Next
				If all_ready
					firing_state[i] :+ 1
					If firing_state[i] > firing_sequence[i].Length - 1 Then firing_state[i] = 0
					FLAG_increment_firing_group[i] = False
				End If
			End If
		Next
		'widgets
		For Local w:WIDGET = EachIn widget_list_behind
			w.update()
		Next
		For Local w:WIDGET = EachIn widget_list_in_front
			w.update()
		Next
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
		Next
	End Method
	
	Method draw()
		For Local w:WIDGET = EachIn widget_list_behind
			w.draw()
		Next
		
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetRotation( ang )
		If img <> Null Then DrawImage( img, pos_x, pos_y )
		
		For Local t:TURRET = EachIn turrets
			t.draw()
		Next
		For Local w:WIDGET = EachIn widget_list_in_front
			w.draw()
		Next
		For Local s:PARTICLE = EachIn stickies
			s.draw()
		Next
	End Method
	
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire_turret( turret_index% = 0 )
		If turret_index < turrets.Length And turrets[turret_index] <> Null Then turrets[turret_index].fire()
	End Method
	'this method uses firing groups and sequences for complex turret control
	Method fire( seq_index% )
		If seq_index = TURRETS_ALL
			For Local i% = 0 To firing_sequence.Length - 1
				fire( i )
			Next
			Return
		End If
		If seq_index < firing_sequence.Length And Not FLAG_increment_firing_group[seq_index]
			For Local t_index% = EachIn firing_sequence[seq_index][firing_state[seq_index]]
				fire_turret( t_index )
			Next
			FLAG_increment_firing_group[seq_index] = True
		End If
	End Method
	
	Method drive( pct# )
		driving_force.control_pct = pct
		If      pct > 0 Then enable_only_rear_emitters() ..
		Else If pct < 0 Then enable_only_forward_emitters() ..
		Else                 disable_all_emitters()
	End Method
	
	Method turn( pct# )
		turning_force.control_pct = pct
	End Method
	
	Method turn_turrets( pct# )
		For Local t:TURRET = EachIn turrets
			t.turn( pct )
		Next
	End Method
	Method snap_turrets()
		For Local t:TURRET = EachIn turrets
			t.ang = ang
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
				Local tur_list:TList = CreateList()
				For Local t:TURRET = EachIn turrets
					If t.class = TURRET_CLASS_AMMUNITION And t.max_ammo <> INFINITY Then tur_list.AddLast( t )
				Next
				Local lowest_cur_ammo% = -1, lowest_cur_ammo_turret:TURRET
				For Local t:TURRET = EachIn tur_list
					If t.cur_ammo < lowest_cur_ammo Or lowest_cur_ammo < 0
						lowest_cur_ammo = t.cur_ammo
						lowest_cur_ammo_turret = t
					End If
				Next
				If lowest_cur_ammo_turret <> Null Then lowest_cur_ammo_turret.re_stock( pkp.pickup_amount )
			
			Case HEALTH_PICKUP
				cur_health :+ pkp.pickup_amount
				If cur_health > max_health Then cur_health = max_health
			
			Case PICKUP_INDEX_COOLDOWN
				Local tur_list:TList = CreateList()
				For Local t:TURRET = EachIn turrets
					If t.max_heat <> INFINITY Then tur_list.AddLast( t )
				Next
				Local lowest_cur_heat% = -1, lowest_cur_heat_turret:TURRET
				For Local t:TURRET = EachIn tur_list
					If t.cur_heat < lowest_cur_heat Or lowest_cur_heat < 0
						lowest_cur_heat = t.cur_heat
						lowest_cur_heat_turret = t
					End If
				Next
				If lowest_cur_heat_turret <> Null Then lowest_cur_heat_turret.re_stock( pkp.pickup_amount )
			
		End Select
		pkp.remove_me()
	End Method
	
	Method add_turret:TURRET( other_t:TURRET, slot% )
		Local t:TURRET = other_t.clone()
		t.set_parent( Self )
		turrets[slot] = t
		Return t
	End Method
	
	'Method add_motivator:MOTIVATOR( motivator_archetype_index% )
	'	
	'End Method
	
	Method add_emitter:EMITTER(	particle_emitter_archetype_index% )
		Return EMITTER( EMITTER.Copy( particle_emitter_archetype[particle_emitter_archetype_index], emitter_list, Self ))
	End Method
	
	Method add_widget:WIDGET( other_w:WIDGET )
		Local w:WIDGET = other_w.clone()
		w.parent = Self
		If w.layer = LAYER_BEHIND_PARENT
			w.add_me( widget_list_behind )
		Else If w.layer = LAYER_IN_FRONT_OF_PARENT
			w.add_me( widget_list_in_front )
		End If
		Return w
	End Method
	
	Method add_sticky:PARTICLE( other_p:PARTICLE )
		Local p:PARTICLE = other_p.clone()
		p.add_me( stickies )
		p.parent = Self
		Return p
	End Method
		
End Type

	
