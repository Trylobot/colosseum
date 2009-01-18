Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const EVENT_ALL_STOP% = 0
Const EVENT_TURN_RIGHT% = 1
Const EVENT_TURN_LEFT% = 2
Const EVENT_DRIVE_FORWARD% = 3
Const EVENT_DRIVE_BACKWARD% = 4
Const EVENT_DEATH% = 5

Const WIDGET_CONSTANT% = 1
Const WIDGET_DEPLOY% = 2

Const TURRETS_ALL% = -1

Const ALIGNMENT_NONE% = 0
Const ALIGNMENT_FRIENDLY% = 1
Const ALIGNMENT_HOSTILE% = 2

'___________________________________________
Type COMPLEX_AGENT Extends AGENT
	
	Field political_alignment% '{friendly|hostile}
	Field ai_name$ 'artificial intelligence variant identifier (only used for AI-controlled agents)

	Field turrets:TURRET[] 'all of this agent's actual turret objects
	Field turret_anchors:cVEC[] 'discrete anchor points where it is valid to attach a turret
	Field turret_systems%[][] 'for each anchor point, a list of the attached turrets (composing a turret_system)

	Field driving_force:FORCE 'permanent force for this object; also added to the general force list
	Field turning_force:FORCE 'permanent torque for this object; also added to the general force list

	Field drive_forward_emitters:TList 'emitters triggered when the agent drives forward
	Field drive_backward_emitters:TList 'emitters triggered when the agent drives backward
	Field all_emitters:TList 'master emitter list

	Field constant_widgets:TList 'always-on widgets
	Field deploy_widgets:TList 'widgets that toggle when the agent deploys/undeploys
	Field all_widgets:TList 'widget master list

	Field stickies:TList 'damage particles
	Field left_track:PARTICLE 'a special particle that represents the "left track" of a tank
	Field right_track:PARTICLE 'a special particle that represents the "right track" of a tank

	Field red%, green%, blue%
	Field alpha#
	Field scale#
	
	'___________________________________________
	Method New()
		drive_forward_emitters = CreateList()
		drive_backward_emitters = CreateList()
		all_emitters = CreateList()
			all_emitters.AddLast( drive_forward_emitters )
			all_emitters.AddLast( drive_backward_emitters )
			all_emitters.AddLast( death_emitters )
		constant_widgets = CreateList()
		deploy_widgets = CreateList()
		all_widgets = CreateList()
			all_widgets.AddLast( constant_widgets )
			all_widgets.AddLast( deploy_widgets )
		stickies = CreateList()
		red = 255; green = 255; blue = 255
		alpha = 1.0
		scale = 1.0
	End Method
	
	'___________________________________________
	Function Archetype:Object( ..
	name$, ..
	img:TImage, ..
	hitbox:TImage = Null, ..
	gibs:TImage, ..
	ai_name$ = Null, ..
	cash_value%, ..
	max_health#, ..
	mass#, ..
	frictional_coefficient#, ..
	driving_force_magnitude#, ..
	turning_force_magnitude#, ..
	physics_disabled% = False )
		Local c:COMPLEX_AGENT = New COMPLEX_AGENT
		
		'static fields
		c.name = name
		c.img = img
		c.hitbox = hitbox
		If hitbox = Null Then c.hitbox = img
		c.gibs = gibs
		c.ai_name = ai_name
		c.max_health = max_health
		c.mass = mass
		c.frictional_coefficient = frictional_coefficient
		c.cash_value = cash_value
		c.physics_disabled = physics_disabled
		
		'dynamic fields
		c.cur_health = max_health

		c.driving_force = FORCE( FORCE.Create( PHYSICS_FORCE, 0, driving_force_magnitude ))
		c.turning_force = FORCE( FORCE.Create( PHYSICS_TORQUE, 0, turning_force_magnitude ))
		
		Return c
	End Function
	
	'___________________________________________
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
		c.hitbox = other.hitbox
		c.gibs = other.gibs
		c.ai_name = other.ai_name
		c.max_health = other.max_health
		c.mass = other.mass
		c.frictional_coefficient = other.frictional_coefficient
		c.cash_value = other.cash_value
		c.physics_disabled = other.physics_disabled
		
		c.pos_x = other.pos_x; c.pos_y = other.pos_y
		c.ang = other.ang
		c.cur_health = c.max_health
		
		For Local a:cVEC = EachIn other.turret_anchors
			c.add_turret_anchor( a )
		Next
		For Local sys_index% = 0 To other.turret_systems.Length-1
			For Local tur_index% = 0 To other.turret_systems[sys_index].Length-1
				c.add_turret( other.turrets[other.turret_systems[sys_index][tur_index]], sys_index )
			Next
		Next

		For Local list:TList = EachIn other.all_emitters
			For Local other_em:EMITTER = EachIn list
				c.add_emitter( other_em, other_em.trigger_event )
			Next
		Next
		
		c.driving_force = FORCE( FORCE.Copy( other.driving_force, c.force_list ))
		c.driving_force.combine_ang_with_parent_ang = True
		c.turning_force = FORCE( FORCE.Copy( other.turning_force, c.force_list ))
		
		For Local other_w:WIDGET = EachIn other.constant_widgets
			c.add_widget( other_w, WIDGET_CONSTANT ).attach_at( other_w.attach_x, other_w.attach_y )
		Next
		For Local other_w:WIDGET = EachIn other.deploy_widgets
			c.add_widget( other_w, WIDGET_DEPLOY ).attach_at( other_w.attach_x, other_w.attach_y )
		Next
		
		If other.right_track <> Null And other.left_track <> Null
			c.right_track = other.right_track.clone()
			c.right_track.attach_at( other.right_track.off_x, other.right_track.off_y )
			c.right_track.parent = c
			c.right_track.animation_direction = other.right_track.animation_direction
			
			c.left_track = other.left_track.clone()
			c.left_track.attach_at( other.left_track.off_x, other.left_track.off_y )
			c.left_track.parent = c
			c.left_track.animation_direction = other.left_track.animation_direction
		End If
		
		Return c
	End Function

	'___________________________________________
	Method update()
		'update agent variables
		Super.update()
		'smooth out velocity
		Local vel# = vector_length( vel_x, vel_y )
		If vel <= 0.00001
			vel_x = 0
			vel_y = 0
		End If
		
		'turret groups
		For Local t:TURRET = EachIn turrets
			t.update()
		Next
		'widgets
		For Local widget_list:TList = EachIn all_widgets
			For Local w:WIDGET = EachIn widget_list
				w.update()
			Next
		Next
		'emitters
		For Local list:TList = EachIn all_emitters
			For Local em:EMITTER = EachIn list
				em.update()
				em.emit()
			Next
		Next
		
		'tracks (will be motivator objects soon, and this will be somewhat automatic, as a function of {velocity} and {angular velocity}
		If right_track <> Null And left_track <> Null
			Local frame_delay# = INFINITY
			Local vel_ang# = vector_angle( vel_x, vel_y )
			If vel > 0.00001
				If Abs( ang_wrap( vel_ang - ang )) <= 90
					right_track.animation_direction = ANIMATION_DIRECTION_FORWARDS
					left_track.animation_direction = ANIMATION_DIRECTION_FORWARDS
					frame_delay = 17.5 * (1.0/vel)
				Else
					right_track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
					left_track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
					frame_delay = 17.5 * (1.0/vel)
				End If
			End If
			If frame_delay >= 100 Or frame_delay = INFINITY
				If ang_vel > 0.00001
					right_track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
					left_track.animation_direction = ANIMATION_DIRECTION_FORWARDS
					frame_delay = 40 * (1.0/Abs(ang_vel))
				Else If ang_vel < -0.00001
					right_track.animation_direction = ANIMATION_DIRECTION_FORWARDS
					left_track.animation_direction = ANIMATION_DIRECTION_BACKWARDS
					frame_delay = 40 * (1.0/Abs(ang_vel))
				End If
			End If
			right_track.frame_delay = frame_delay
			left_track.frame_delay = frame_delay
			right_track.update()
			left_track.update()
		End If
	End Method
	
	'___________________________________________
	Method draw( red_override% = -1, green_override% = -1, blue_override% = -1, alpha_override# = -1.0, scale_override# = -1.0, hide_widgets% = False )
		If red_override   <> -1   Then red   = red_override   Else red   = 255
		If green_override <> -1   Then green = green_override Else green = 255
		If blue_override  <> -1   Then blue  = blue_override  Else blue  = 255
		If alpha_override <> -1.0 Then alpha = alpha_override Else alpha = 1.0
		If scale_override <> -1.0 Then scale = scale_override Else scale = 1.0
		
		'chassis widgets
		For Local widget_list:TList = EachIn all_widgets
			For Local w:WIDGET = EachIn widget_list
				If w.layer = LAYER_BEHIND_PARENT
					w.draw()
				End If
			Next
		Next
		SetColor( red, green, blue )
		SetAlpha( alpha )
		SetScale( scale, scale )
		SetRotation( ang )
		'tracks
		If right_track <> Null And left_track <> Null
			left_track.red = Float(red)/255.0
			left_track.green = Float(green)/255.0
			left_track.blue = Float(blue)/255.0
			left_track.alpha = alpha
			left_track.scale = scale
			left_track.draw()
			
			right_track.red = Float(red)/255.0
			right_track.green = Float(green)/255.0
			right_track.blue = Float(blue)/255.0
			right_track.alpha = alpha
			right_track.scale = scale
			right_track.draw()
		End If
		'chassis
		SetColor( red, green, blue )
		SetAlpha( alpha )
		SetScale( scale, scale )
		SetRotation( ang )
		If img <> Null Then DrawImage( img, pos_x, pos_y )
		'chassis widgets
		If Not hide_widgets
			For Local widget_list:TList = EachIn all_widgets
				For Local w:WIDGET = EachIn widget_list
					If w.layer = LAYER_IN_FRONT_OF_PARENT
						w.draw()
					End If
				Next
			Next
		End If
		'turrets
		For Local t:TURRET = EachIn turrets
			t.draw()
		Next
		'sticky particles (damage)
		For Local s:PARTICLE = EachIn stickies
			s.draw()
		Next
	End Method
	
	'___________________________________________
	Method drive( pct# )
		driving_force.control_pct = pct
		If pct > 0
			enable_only_rear_emitters()
		Else If pct < 0
			enable_only_forward_emitters()
		Else
			disable_all_emitters()
		End If
	End Method
	'___________________________________________
	Method turn( pct# )
		turning_force.control_pct = pct
	End Method
	'___________________________________________
	Method fire( index% )
		If index < turrets.Length
			turrets[index].fire()
		End If
	End Method
	
	'___________________________________________
	Method DEPRECATED__turn_turret( index%, control_pct# )
'		If index < turret_list.Count()
'			Local t:TURRET = TURRET( turret_list.ValueAtIndex( index ))
'			If t <> Null Then t.turn( control_pct )
'		End If
	End Method
	'___________________________________________
	Method turn_turret_system( index%, control_pct# )
		If index < turret_systems.Length
			For Local tur_index% = EachIn turret_systems[index]
				turrets[tur_index].turn( control_pct )
			Next
		End If
	End Method
	'___________________________________________
	Method snap_all_turrets()
		For Local t:TURRET = EachIn turrets
			t.ang = ang
		Next
	End Method
	'___________________________________________
	Method get_turret_system_ang#( index% )
		If index < turret_systems.Length
			Return turrets[turret_systems[index][0]].ang
		End If
		Return Null
	End Method
	
	'___________________________________________
	Method enable_only_forward_emitters()
		For Local em:EMITTER = EachIn drive_forward_emitters
			em.enable( MODE_ENABLED_FOREVER )
		Next
		For Local em:EMITTER = EachIn drive_backward_emitters
			em.disable()
		Next
	End Method
	'___________________________________________
	Method enable_only_rear_emitters()
		For Local em:EMITTER = EachIn drive_forward_emitters
			em.disable()
		Next
		For Local em:EMITTER = EachIn drive_backward_emitters
			em.enable( MODE_ENABLED_FOREVER )
		Next
	End Method
	'___________________________________________
	Method disable_all_emitters()
		For Local em:EMITTER = EachIn drive_forward_emitters
			em.disable()
		Next
		For Local em:EMITTER = EachIn drive_backward_emitters
			em.disable()
		Next
	End Method
	
	'___________________________________________
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
				If highest_cur_heat_turret <> Null
					highest_cur_heat_turret.cur_heat = 0
					highest_cur_heat_turret.bonus_cooling_start_ts = now()
					highest_cur_heat_turret.bonus_cooling_time = pkp.pickup_amount
				End If
			
		End Select
		pkp.unmanage()
	End Method
	
	'___________________________________________
	Method add_turret_anchor:cVEC( other_a:cVEC )
		Local a:cVEC = other_a.clone()
		'add the anchor to the array
		If turret_anchors = Null
			turret_anchors = New cVEC[1]
		Else 'turret_anchors <> Null
			turret_anchors = turret_anchors[..turret_anchors.Length+1]
		End If
		turret_anchors[turret_anchors.Length-1] = a
		'.. and provide a new turret system slot
		If turret_systems = Null
			turret_systems = New Int[][1]
		Else 'turret_systems <> null
			turret_systems = turret_systems[..turret_systems.Length+1]
		End If
		Return a
	End Method
	'___________________________________________
	Method add_turret:TURRET( other_t:TURRET, anchor_index% )
		If anchor_index >= 0 And anchor_index < turret_anchors.Length
			Local t:TURRET = other_t.clone()
			t.set_parent( Self )
			If turrets = Null
				turrets = New TURRET[1]
			Else 'turrets <> null
				turrets = turrets[..turrets.Length+1]
			End If
			Local turret_index% = turrets.Length-1
			turrets[turret_index] = t
			If turret_systems[anchor_index] = Null
				turret_systems[anchor_index] = New Int[1]
			Else 'turret_systems[anchor_index] <> Null
				turret_systems[anchor_index] = turret_systems[anchor_index][..turret_systems[anchor_index].Length+1]
			End If
			Local turret_system_index% = turret_systems[anchor_index].Length-1
			turret_systems[anchor_index][turret_system_index] = turret_index
			If turret_system_index > 0
				t.max_ang_vel = turrets[turret_systems[anchor_index][0]].max_ang_vel
			End If
			Local a:cVEC = turret_anchors[anchor_index]
			t.attach_at( a.x, a.y )
			Return t
		Else
			Return Null
		End If
	End Method
	'___________________________________________
	Method remove_all_turrets()
		turrets = Null
		turret_systems = New Int[][turret_anchors.Length]
	End Method
	'___________________________________________
	Method add_emitter:EMITTER(	other_em:EMITTER, event% )
		Local em:EMITTER = Copy_EMITTER( other_em )
		em.parent = Self
		em.trigger_event = event
		Select event
			Case EVENT_DRIVE_FORWARD
				em.manage( drive_forward_emitters )
			Case EVENT_DRIVE_BACKWARD
				em.manage( drive_backward_emitters )
			Case EVENT_DEATH
				em.manage( death_emitters )
		End Select
		Return em
	End Method
	'___________________________________________
	Method add_widget:WIDGET( other_w:WIDGET, widget_type% )
		Local w:WIDGET = other_w.clone()
		w.parent = Self
		Select widget_type
			Case WIDGET_CONSTANT
				w.manage( constant_widgets )
			Case WIDGET_DEPLOY
				w.manage( deploy_widgets )
		End Select
		Return w
	End Method
	'___________________________________________
	Method add_sticky:PARTICLE( other_p:PARTICLE )
		Local p:PARTICLE = other_p.clone()
		p.manage( stickies )
		p.parent = Self
		Return p
	End Method
	
End Type
