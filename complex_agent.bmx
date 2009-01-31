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
Const WIDGET_AI_LIGHTBULB% = 3

Const TURRETS_ALL% = -1

Const ALIGNMENT_NONE% = 0
Const ALIGNMENT_FRIENDLY% = 1
Const ALIGNMENT_HOSTILE% = 2

Const MAX_COMPLEX_AGENT_VELOCITY# = 4.0 'hard velocity limit

'___________________________________________
Type COMPLEX_AGENT Extends AGENT
	
	Field political_alignment% '{friendly|hostile}
	Field ai_name$ 'artificial intelligence variant identifier (only used for AI-controlled agents)
	Field cash_value%

	Field turrets:TURRET[] 'all of this agent's actual turret objects
	Field turret_anchors:cVEC[] 'discrete anchor points where it is valid to attach a turret
	Field turret_systems%[][] 'for each anchor point, a list of the attached turrets (composing a turret_system)

	Field driving_force:FORCE 'permanent force for this object; also added to the general force list
	Field turning_force:FORCE 'permanent torque for this object; also added to the general force list

	Field drive_forward_emitters:TList 'TList<EMITTER> emitters triggered when the agent drives forward
	Field drive_backward_emitters:TList 'TList<EMITTER> emitters triggered when the agent drives backward
	Field all_emitter_lists:TList 'TList<TList<EMITTER>> master emitter list

	Field constant_widgets:TList 'TList<WIDGET> always-on widgets
	Field deploy_widgets:TList 'TList<WIDGET> widgets that toggle when the agent deploys/undeploys
	Field ai_lightbulb_widgets:TList 'TList<WIDGET>
	Field all_widget_lists:TList 'TList<TList<WIDGET>> widget master list

	Field stickies:TList 'TList<PARTICLE> damage particles
	Field left_track:PARTICLE 'a special particle that represents the "left track" of a tank
	Field right_track:PARTICLE 'a special particle that represents the "right track" of a tank

	Field spawning%
	Field spawn_time%
	Field spawn_begin_ts%
	
	Field is_deployed%
	Field factory_queue%[] 'list of complex agents to spawn (only applies to carriers)
	
	'___________________________________________
	Method New()
		drive_forward_emitters = CreateList()
		drive_backward_emitters = CreateList()
		all_emitter_lists = CreateList()
			all_emitter_lists.AddLast( drive_forward_emitters )
			all_emitter_lists.AddLast( drive_backward_emitters )
			all_emitter_lists.AddLast( death_emitters )
		constant_widgets = CreateList()
		deploy_widgets = CreateList()
		ai_lightbulb_widgets = CreateList()
		all_widget_lists = CreateList()
			all_widget_lists.AddLast( constant_widgets )
			all_widget_lists.AddLast( deploy_widgets )
			all_widget_lists.AddLast( ai_lightbulb_widgets )
		stickies = CreateList()
	End Method
	
	'___________________________________________
	Function Archetype:Object( ..
	name$ = Null, ..
	img:TImage = Null, ..
	hitbox:TImage = Null, ..
	gibs:TImage = Null, ..
	ai_name$ = Null, ..
	cash_value% = 0, ..
	max_health# = 100.0, ..
	mass# = 100.0, ..
	frictional_coefficient# = 0.0, ..
	driving_force_magnitude# = 0.0, ..
	turning_force_magnitude# = 0.0, ..
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

		For Local list:TList = EachIn other.all_emitter_lists
			For Local other_em:EMITTER = EachIn list
				c.add_emitter( other_em, other_em.trigger_event )
			Next
		Next
		
		c.driving_force = FORCE( FORCE.Copy( other.driving_force, c.force_list ))
		c.driving_force.combine_ang_with_parent_ang = True
		c.turning_force = FORCE( FORCE.Copy( other.turning_force, c.force_list ))
		
		For Local other_w:WIDGET = EachIn other.constant_widgets
			c.add_widget( other_w, WIDGET_CONSTANT ).attach_at( other_w.attach_x, other_w.attach_y, other_w.ang_offset )
		Next
		For Local other_w:WIDGET = EachIn other.deploy_widgets
			c.add_widget( other_w, WIDGET_DEPLOY ).attach_at( other_w.attach_x, other_w.attach_y, other_w.ang_offset )
		Next
		For Local other_w:WIDGET = EachIn other.ai_lightbulb_widgets
			c.add_widget( other_w, WIDGET_AI_LIGHTBULB ).attach_at( other_w.attach_x, other_w.attach_y, other_w.ang_offset )
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
		
		c.factory_queue = other.factory_queue[..]
		
		c.drive( 0 )
		c.turn( 0 )
		
		Return c
	End Function

	'___________________________________________
	Method update()
		Super.update()
		
		'smooth out and constrain velocity
		Local vel# = vector_length( vel_x, vel_y )
		If vel > MAX_COMPLEX_AGENT_VELOCITY
			Local proportion# = MAX_COMPLEX_AGENT_VELOCITY/vel
			vel_x :* proportion
			vel_y :* proportion
		Else If vel <= 0.00001
			vel_x = 0
			vel_y = 0
		End If
		
		'turret groups
		For Local t:TURRET = EachIn turrets
			t.update()
		Next
		'widgets
		For Local widget_list:TList = EachIn all_widget_lists
			For Local w:WIDGET = EachIn widget_list
				w.update()
			Next
		Next
		'emitters
		For Local list:TList = EachIn all_emitter_lists
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
		
		'spawn mode
		If now() - spawn_begin_ts >= spawn_time Then spawning = False
		
	End Method
	
	'___________________________________________
	Method draw( alpha_override# = 1.0, scale_override# = 1.0, hide_widgets% = False )
		If spawning
			alpha_override :* time_alpha_pct( spawn_begin_ts, spawn_time, True )
		End If
		'colored glow/shadow to display political alignment
		Select political_alignment
			Case ALIGNMENT_FRIENDLY
				SetColor( 96, 96, 255 )
			Case ALIGNMENT_HOSTILE
				SetColor( 255, 96, 96 )
		End Select
		SetAlpha( 0.15*alpha_override )
		SetScale( 0.3*scale_override*(img.width-2)/17.0, 0.3*scale_override*(img.width-2)/17.0 )
		DrawImage( get_image( "halo" ), pos_x, pos_y )
		'widgets behind
		If Not hide_widgets
			For Local widget_list:TList = EachIn all_widget_lists
				For Local w:WIDGET = EachIn widget_list
					If w.layer = LAYER_BEHIND_PARENT
						w.draw( alpha_override, scale_override )
					End If
				Next
			Next
		End If
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
		SetRotation( ang )
		'tracks
		If right_track <> Null And left_track <> Null
			left_track.draw( alpha_override, scale_override )
			right_track.draw( alpha_override, scale_override )
		End If
		'chassis
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
		SetRotation( ang )
		If img <> Null Then DrawImage( img, pos_x, pos_y )
		'widgets in front of
		If Not hide_widgets
			For Local widget_list:TList = EachIn all_widget_lists
				For Local w:WIDGET = EachIn widget_list
					If w.layer = LAYER_IN_FRONT_OF_PARENT
						w.draw( alpha_override, scale_override )
					End If
				Next
			Next
		End If
		'turrets
		For Local t:TURRET = EachIn turrets
			t.draw( alpha_override, scale_override )
		Next
		'sticky particles (damage)
		For Local s:PARTICLE = EachIn stickies
			s.draw()
		Next
	End Method
	
	'___________________________________________
	Method move_to( argument:Object, snap_turrets% = False )
		Super.move_to( argument )
		If snap_turrets Then snap_all_turrets()
	End Method
	'___________________________________________
	Method spawn_at( p:POINT, time% )
		spawning = True
		spawn_time = time
		spawn_begin_ts = now()
		move_to( p )
	End Method
	
	'___________________________________________
	Method drive( pct# )
		If Not spawning And Not is_deployed
			driving_force.control_pct = pct
			If pct > 0
				enable_only_rear_emitters()
			Else If pct < 0
				enable_only_forward_emitters()
			Else
				disable_all_emitters()
			End If
		End If
	End Method
	'___________________________________________
	Method turn( pct# )
		If Not spawning And Not is_deployed
			turning_force.control_pct = pct
		End If
	End Method
	'___________________________________________
	Method fire( index% )
		If Not spawning
			If index < turrets.Length
				turrets[index].fire()
			End If
		End If
	End Method
	'___________________________________________
	Method fire_blanks_all()
		For Local t:TURRET = EachIn turrets
			t.fire_blanks_all()
		Next
	End Method
	'___________________________________________
	Method overheated%( index% )
		If index < turrets.Length
			Return turrets[index].overheated()
		End If
	End Method
	'___________________________________________
	Method mostly_cooled%( index% )
		If index < turrets.Length
			Return turrets[index].cur_heat <= (0.25 * turrets[index].max_heat)
		End If
	End Method
	'___________________________________________
	Method turn_turret_system( index%, control_pct# )
		If Not spawning
			If index < turret_systems.Length
				For Local tur_index% = EachIn turret_systems[index]
					turrets[tur_index].turn( control_pct )
				Next
			End If
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
	Method get_turret_system_max_ang_vel#( index% )
		If index < turret_systems.Length
			Return turrets[turret_systems[index][0]].max_ang_vel
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
	Method deploy()
		drive( 0 )
		turn( 0 )
		is_deployed = True
		For Local w:WIDGET = EachIn deploy_widgets
			w.queue_transformation( 1 )
		Next
	End Method
	'___________________________________________
	Method undeploy()
		is_deployed = False
		For Local w:WIDGET = EachIn deploy_widgets
			w.queue_transformation( 1 )
		Next
	End Method
	
	'___________________________________________
	Method grant_pickup( pkp:PICKUP )
		Select pkp.pickup_type
			
			Case AMMO_PICKUP
				play_sound( get_sound( "reload" ))
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
			
			Case COOLDOWN_PICKUP
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
	Method ai_lightbulb( enable% = True )
		For Local w:WIDGET = EachIn ai_lightbulb_widgets
			If enable And Not w.transforming
				w.queue_transformation( INFINITY )
			Else If Not enable And w.transforming
				w.stop_at( 0 )
			End If
		Next
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
			Case WIDGET_AI_LIGHTBULB
				w.manage( ai_lightbulb_widgets )
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
	'___________________________________________
	Method add_factory_unit( archetype%, count% = 1 )
		If count <= 0 Then Return
		If factory_queue = Null
			factory_queue = New Int[count]
			For Local i% = 0 To factory_queue.Length - 1
				factory_queue[i] = archetype
			Next
		Else 'factory_queue <> null
			Local old_size% = factory_queue.Length
			factory_queue = factory_queue[..(factory_queue.Length + count)]
			For Local i% = old_size To (factory_queue.Length - 1)
				factory_queue[i] = archetype
			Next
		End If
	End Method
	'___________________________________________
	Method add_motivator_package( particle_key$, offset_x# = 0.0, separation_y# = 0.0 )
		left_track = get_particle( particle_key )
		left_track.parent = Self
		left_track.attach_at( offset_x, -separation_y )
		right_track = get_particle( particle_key )
		right_track.parent = Self
		right_track.attach_at( offset_x, separation_y )
	End Method
	'___________________________________________
	Method add_dust_cloud_package( offset_x# = 0.0, separation_x# = 0.0, separation_y# = 0.0, dist_min# = 0.0, dist_max# = 0.0, dist_ang_min# = 0.0, dist_ang_max# = 0.0, vel_min# = 0.0, vel_max# = 0.0 )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DUST_CLOUD] ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, -separation_y, dist_min, dist_max, dist_ang_min, dist_ang_max, vel_min, vel_max )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DUST_CLOUD] ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, separation_y, dist_min, dist_max, dist_ang_min, dist_ang_max, vel_min, vel_max )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DUST_CLOUD] ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, -separation_y, dist_min, dist_max, 180 + dist_ang_min, 180 + dist_ang_max, vel_min, vel_max )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_TANK_TREAD_DUST_CLOUD] ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, separation_y, dist_min, dist_max, 180 + dist_ang_min, 180 + dist_ang_max, vel_min, vel_max )
	End Method
	'___________________________________________
	Method add_trail_package( archetype%, offset_x# = 0.0, separation_x# = 0.0, separation_y# = 0.0 )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[archetype] ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, -separation_y )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[archetype] ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, separation_y )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[archetype] ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, -separation_y )
		add_emitter( Copy_EMITTER( particle_emitter_archetype[archetype] ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, separation_y )
	End Method
		
End Type
