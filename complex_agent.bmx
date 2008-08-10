Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Global friendly_agent_list:TList = CreateList()
Global hostile_agent_list:TList = CreateList()
Global agent_lists:TList = CreateList()
	agent_lists.AddLast( friendly_agent_list )
	agent_lists.AddLast( hostile_agent_list )

Const EVENT_ALL_STOP% = 0
Const EVENT_TURN_RIGHT% = 1
Const EVENT_TURN_LEFT% = 2
Const EVENT_DRIVE_FORWARD% = 3
Const EVENT_DRIVE_BACKWARD% = 4
Const EVENT_DEATH% = 5

Const TURRETS_ALL% = -1

Const ALIGNMENT_NONE% = 0
Const ALIGNMENT_FRIENDLY% = 1
Const ALIGNMENT_HOSTILE% = 2

Type COMPLEX_AGENT Extends AGENT
	
	Field political_alignment% '{friendly|hostile}
	Field ai_type% 'artificial intelligence subroutine index (only used for AI-controlled agents)
	
	Field turrets:TURRET[] 'turret array
	Field turret_count% 'number of turret slots
	Field firing_sequence%[][][]
	Field firing_state%[]
	Field FLAG_increment_firing_group%[]
	
	Field driving_force:FORCE 'permanent force for this object; also added to the general force list
	Field turning_force:FORCE 'permanent torque for this object; also added to the general force list
	Field drive_forward_emitters:TList
	Field drive_backward_emitters:TList
	Field all_emitters:TList
	Field widget_list_below:TList
	Field widget_list_above:TList
	Field stickies:TList
	
	Method New()
		drive_forward_emitters = CreateList()
		drive_backward_emitters = CreateList()
		all_emitters = CreateList()
			all_emitters.AddLast( drive_forward_emitters )
			all_emitters.AddLast( drive_backward_emitters )
			all_emitters.AddLast( death_emitters )
		widget_list_below = CreateList()
		widget_list_above = CreateList()
		stickies = CreateList()
	End Method
	
	Function Archetype:Object( ..
	name$, ..
	img:TImage, ..
	gibs:TImage, ..
	ai_type%, ..
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
		c.name = name
		c.img = img
		c.gibs = gibs
		c.ai_type = ai_type
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
		c.driving_force = FORCE( FORCE.Create( PHYSICS_FORCE, 0, driving_force_magnitude ))
		c.turning_force = FORCE( FORCE.Create( PHYSICS_TORQUE, 0, turning_force_magnitude ))
		
		Return c
	End Function
	
	Function Copy:Object( other:COMPLEX_AGENT, political_alignment% = ALIGNMENT_NONE )
		If other = Null Then Return Null
		Local c:COMPLEX_AGENT = New COMPLEX_AGENT
		
		c.name = other.name
		If political_alignment <> ALIGNMENT_NONE
			c.political_alignment = political_alignment
		Else 'political_alignment == ALIGNMENT_NONE
			c.political_alignment = other.political_alignment
		End If
		c.img = other.img
		c.gibs = other.gibs
		c.ai_type = other.ai_type
		c.max_health = other.max_health
		c.mass = other.mass
		c.frictional_coefficient = other.frictional_coefficient
		c.cash_value = other.cash_value
		c.physics_disabled = other.physics_disabled
		
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
		
DebugLog "COMPLEX_AGENT::Copy( other{"+other.name+"}, "+political_alignment+" )"
DebugLog "copying emitters/start"
DebugLog "   c.all_emitters.Count() -> "+c.all_emitters.Count()
DebugLog "   For Local list:TList = EachIn c.all_emitters"
		For Local list:TList = EachIn c.all_emitters
DebugLog "     list.Count() -> "+list.Count()
DebugLog "     For Local other_em:EMITTER = EachIn list"
			For Local other_em:EMITTER = EachIn list
DebugLog "       c.add_emitter( other_em{"+other_em.name+"}, other_em.trigger_event )"
				c.add_emitter( other_em, other_em.trigger_event )
			Next
		Next
DebugLog "copying emitters/finish"
		
		c.driving_force = FORCE( FORCE.Copy( other.driving_force, c.force_list ))
		c.driving_force.combine_ang_with_parent_ang = True
		c.turning_force = FORCE( FORCE.Copy( other.turning_force, c.force_list ))
		
		For Local other_w:WIDGET = EachIn other.widget_list_below
			c.add_widget( other_w ).attach_at( other_w.attach_x, other_w.attach_y )
		Next
		For Local other_w:WIDGET = EachIn other.widget_list_above
			c.add_widget( other_w ).attach_at( other_w.attach_x, other_w.attach_y )
		Next
		
		If      political_alignment = ALIGNMENT_FRIENDLY Then c.add_me( friendly_agent_list ) ..
		Else If political_alignment = ALIGNMENT_HOSTILE  Then c.add_me( hostile_agent_list )
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
		For Local w:WIDGET = EachIn widget_list_below
			w.update()
		Next
		For Local w:WIDGET = EachIn widget_list_above
			w.update()
		Next
		'emitters
		For Local list:TList = EachIn all_emitters
			For Local em:EMITTER = EachIn list
				em.update()
				em.emit()
			Next
		Next
	End Method
	
	Method draw()
		For Local w:WIDGET = EachIn widget_list_below
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
		For Local w:WIDGET = EachIn widget_list_above
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
		For Local em:EMITTER = EachIn drive_forward_emitters
			em.enable( MODE_ENABLED_FOREVER )
		Next
		For Local em:EMITTER = EachIn drive_backward_emitters
			em.disable()
		Next
	End Method
	Method enable_only_rear_emitters()
		For Local em:EMITTER = EachIn drive_forward_emitters
			em.disable()
		Next
		For Local em:EMITTER = EachIn drive_backward_emitters
			em.enable( MODE_ENABLED_FOREVER )
		Next
	End Method
	Method disable_all_emitters()
		For Local em:EMITTER = EachIn drive_forward_emitters
			em.disable()
		Next
		For Local em:EMITTER = EachIn drive_backward_emitters
			em.disable()
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
				Local highest_cur_heat% = -1, highest_cur_heat_turret:TURRET
				For Local t:TURRET = EachIn tur_list
					If t.cur_heat > highest_cur_heat
						highest_cur_heat = t.cur_heat
						highest_cur_heat_turret = t
					End If
				Next
				If highest_cur_heat_turret <> Null Then highest_cur_heat_turret.cur_heat = 0
			
		End Select
		pkp.remove_me()
	End Method
	
	Method add_turret:TURRET( other_t:TURRET, slot% )
		Local t:TURRET = other_t.clone()
		t.set_parent( Self )
		turrets[slot] = t
		Return t
	End Method
	
	Method add_emitter:EMITTER(	other_em:EMITTER, event% )
		Local em:EMITTER = Copy_EMITTER( other_em )
		em.parent = Self
		em.trigger_event = event
		Select event
			Case EVENT_DRIVE_FORWARD
				em.add_me( drive_forward_emitters )
			Case EVENT_DRIVE_BACKWARD
				em.add_me( drive_backward_emitters )
			Case EVENT_DEATH
				em.add_me( death_emitters )
		End Select
		Return em
	End Method
	
	Method add_widget:WIDGET( other_w:WIDGET )
		Local w:WIDGET = other_w.clone()
		w.parent = Self
		If w.layer = LAYER_BEHIND_PARENT
			w.add_me( widget_list_below )
		Else If w.layer = LAYER_IN_FRONT_OF_PARENT
			w.add_me( widget_list_above )
		End If
		Return w
	End Method
	
	Method add_sticky:PARTICLE( other_p:PARTICLE )
		Local p:PARTICLE = other_p.clone()
		p.add_me( stickies )
		p.parent = Self
		Return p
	End Method
	
	Method auto_manage( new_political_alignment% = ALIGNMENT_NONE )
		political_alignment = new_political_alignment
		If      new_political_alignment = ALIGNMENT_FRIENDLY Then add_me( friendly_agent_list ) ..
		Else If new_political_alignment = ALIGNMENT_HOSTILE  Then add_me( hostile_agent_list )
	End Method
	
End Type

	
