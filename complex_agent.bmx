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
	
	Field lightmap:TImage 'lighting effect image array
	
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
	Field factory_queue$[] 'list of complex agents to spawn (only applies to carriers)
	
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
		c.cash_value = cash_value
		c.max_health = max_health
		c.mass = mass
		c.frictional_coefficient = frictional_coefficient
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
		c.lightmap = other.lightmap
		c.ai_name = other.ai_name
		c.cash_value = other.cash_value
		c.max_health = other.max_health
		c.mass = other.mass
		c.frictional_coefficient = other.frictional_coefficient
		c.physics_disabled = other.physics_disabled
		
		c.pos_x = other.pos_x; c.pos_y = other.pos_y
		c.ang = other.ang
		c.cur_health = c.max_health
		
		For Local a:cVEC = EachIn other.turret_anchors
			c.add_turret_anchor( a.x, a.y )
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
			c.add_widget( other_w, WIDGET_CONSTANT )
		Next
		For Local other_w:WIDGET = EachIn other.deploy_widgets
			c.add_widget( other_w, WIDGET_DEPLOY )
		Next
		For Local other_w:WIDGET = EachIn other.ai_lightbulb_widgets
			c.add_widget( other_w, WIDGET_AI_LIGHTBULB )
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
		
		'turrets
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
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		If spawning
			alpha_override :* time_alpha_pct( spawn_begin_ts, spawn_time, True )
		End If
		'colored glow/shadow to display political alignment
		If img
			Select political_alignment
				Case ALIGNMENT_FRIENDLY
					SetColor( 96, 96, 255 )
				Case ALIGNMENT_HOSTILE
					SetColor( 255, 96, 96 )
				Default
					SetColor( 255, 255, 255 )
			End Select
			SetAlpha( 0.15*alpha_override )
			Local glow_scale# = 0.3*scale_override*(img.width-2)/17.0
			SetScale( glow_scale, glow_scale )
			DrawImage( get_image( "halo" ), pos_x, pos_y )
		End If
		'widgets behind
		For Local widget_list:TList = EachIn all_widget_lists
			For Local w:WIDGET = EachIn widget_list
				If w.layer = LAYER_BEHIND_PARENT
					w.draw( alpha_override, scale_override )
				End If
			Next
		Next
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
		SetRotation( ang )
		'tracks
		If right_track <> Null And left_track <> Null
			left_track.draw( alpha_override )
			right_track.draw( alpha_override )
		End If
		'chassis image
		If img
			SetColor( 255, 255, 255 )
			SetAlpha( alpha_override )
			SetScale( scale_override, scale_override )
			SetRotation( ang )
			DrawImage( img, pos_x, pos_y )
			'chassis lighting effect
			If lightmap
				Local separation# = 360.0 / lightmap.frames.Length
				For Local i% = 0 Until lightmap.frames.Length
					Local diff# = Abs( ang_wrap( ang - ((i - 1) * separation )))
					If diff < 90.0
						SetAlpha( alpha_override * 0.5 * (90.0 - diff)/90.0 )
						DrawImage( lightmap, pos_x, pos_y, i )
					End If
				Next
			End If
		End If
		'widgets in front of
		For Local widget_list:TList = EachIn all_widget_lists
			For Local w:WIDGET = EachIn widget_list
				If w.layer = LAYER_IN_FRONT_OF_PARENT
					w.draw( alpha_override, scale_override )
				End If
			Next
		Next
		'turrets
		For Local t:TURRET = EachIn turrets
			t.draw( alpha_override, scale_override )
		Next
		'sticky particles (damage)
		For Local s:PARTICLE = EachIn stickies
			s.draw()
		Next
		'projectile impact flash
		If flash And img
			flash = False
			SetBlend( LIGHTBLEND )
			SetColor( 255, 255, 255 )
			SetAlpha( alpha_override )
			SetScale( scale_override, scale_override )
			SetRotation( ang )
			DrawImage( img, pos_x, pos_y )
			SetBlend( ALPHABLEND )
		End If
	End Method
	
	'___________________________________________
	Method move_to( argument:Object, snap_turrets% = False, perform_update% = False )
		Super.move_to( argument )
		If snap_turrets Then snap_all_turrets()
		If perform_update Then update()
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
	Method fire_all( priority% )
		If Not spawning
			For Local t:TURRET = EachIn turrets
				If t.priority = priority Then t.fire()
			Next
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
			t.move_to( Self )
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
	Method get_turret_system_pos:POINT( index% )
		If index < turret_systems.Length
			Return POINT(turrets[turret_systems[index][0]])
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
			
			Case PICKUP.AMMO
				Local tur_list:TList = CreateList()
				For Local t:TURRET = EachIn turrets
					If t.class = TURRET.AMMUNITION And t.max_ammo <> INFINITY Then tur_list.AddLast( t )
				Next
				Local lowest_cur_ammo% = -1, lowest_cur_ammo_turret:TURRET
				For Local t:TURRET = EachIn tur_list
					If t.cur_ammo < lowest_cur_ammo Or lowest_cur_ammo < 0
						lowest_cur_ammo = t.cur_ammo
						lowest_cur_ammo_turret = t
					End If
				Next
				If lowest_cur_ammo_turret <> Null Then lowest_cur_ammo_turret.re_stock( pkp.pickup_amount )
			
			Case PICKUP.HEALTH
				cur_health :+ pkp.pickup_amount
				If cur_health > max_health Then cur_health = max_health
			
			Case PICKUP.COOLDOWN
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
	Method add_turret_anchor:cVEC( x# = 0, y# = 0 )
		Local a:cVEC = Create_cVEC( x, y )
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
		If other_t And anchor_index >= 0 And anchor_index < turret_anchors.Length
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
	Method add_factory_unit( archetype$, count% = 1 )
		If count <= 0 Then Return
		If factory_queue = Null
			factory_queue = New String[count]
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
		add_emitter( get_particle_emitter( "TANK_TREAD_DUST_CLOUD", False ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, -separation_y, dist_min, dist_max, dist_ang_min, dist_ang_max, vel_min, vel_max )
		add_emitter( get_particle_emitter( "TANK_TREAD_DUST_CLOUD", False ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, separation_y, dist_min, dist_max, dist_ang_min, dist_ang_max, vel_min, vel_max )
		add_emitter( get_particle_emitter( "TANK_TREAD_DUST_CLOUD", False ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, -separation_y, dist_min, dist_max, 180 + dist_ang_min, 180 + dist_ang_max, vel_min, vel_max )
		add_emitter( get_particle_emitter( "TANK_TREAD_DUST_CLOUD", False ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, separation_y, dist_min, dist_max, 180 + dist_ang_min, 180 + dist_ang_max, vel_min, vel_max )
	End Method
	'___________________________________________
	Method add_trail_package( archetype$, offset_x# = 0.0, separation_x# = 0.0, separation_y# = 0.0 )
		add_emitter( get_particle_emitter( archetype, False ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, -separation_y )
		add_emitter( get_particle_emitter( archetype, False ), EVENT_DRIVE_FORWARD ).attach_at( offset_x + separation_x, separation_y )
		add_emitter( get_particle_emitter( archetype, False ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, -separation_y )
		add_emitter( get_particle_emitter( archetype, False ), EVENT_DRIVE_BACKWARD ).attach_at( offset_x - separation_x, separation_y )
	End Method
	'___________________________________________
	Method add_death_package()
		add_emitter( get_particle_emitter( "EXPLOSION", False ), EVENT_DEATH ).attach_at( 0, 0 )
		add_emitter( get_particle_emitter( "SHOCKWAVE", False ), EVENT_DEATH ).attach_at( 0, 0 )
	End Method
	
	Method set_images_unfiltered()
		If img Then img = unfilter_image( img )
		If left_track Then left_track.img = unfilter_image( left_track.img )
		If right_track Then right_track.img = unfilter_image( right_track.img )
		For Local t:TURRET = EachIn turrets
			t.set_images_unfiltered()
		Next
	End Method
	
	Method scale_all( scale# )
		If left_track Then left_track.scale = scale
		If right_track Then right_track.scale = scale
		For Local list:TList = EachIn Self.all_widget_lists
			For Local w:WIDGET = EachIn list
				w.attach_at( w.attach_x * scale, w.attach_y * scale, w.ang_offset )
			Next
		Next
		For Local t:TURRET = EachIn turrets
			t.scale_all( scale )
		Next
	End Method
		
End Type

Function Create_COMPLEX_AGENT_from_json:COMPLEX_AGENT( json:TJSON )
	Local cmp_ag:COMPLEX_AGENT
	'no required fields
	cmp_ag = COMPLEX_AGENT( COMPLEX_AGENT.Archetype() )
	'optional fields
	If json.TypeOf( "name" ) <> JSON_UNDEFINED                    Then cmp_ag.name = json.GetString( "name" )
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED
		cmp_ag.img = get_image( json.GetString( "image_key" ))
		cmp_ag.hitbox = cmp_ag.img
	End If
	If json.TypeOf( "hitbox_image_key" ) <> JSON_UNDEFINED        Then cmp_ag.hitbox = get_image( json.GetString( "hitbox_image_key" ))
	If json.TypeOf( "gibs_image_key" ) <> JSON_UNDEFINED          Then cmp_ag.gibs = get_image( json.GetString( "gibs_image_key" ))
	If json.TypeOf( "lightmap_image_key" ) <> JSON_UNDEFINED      Then cmp_ag.lightmap = get_image( json.GetString( "lightmap_image_key" ))
	If json.TypeOf( "ai_name" ) <> JSON_UNDEFINED                 Then cmp_ag.ai_name = json.GetString( "ai_name" )
	If json.TypeOf( "cash_value" ) <> JSON_UNDEFINED              Then cmp_ag.cash_value = json.GetNumber( "cash_value" )
	If json.TypeOf( "max_health" ) <> JSON_UNDEFINED              Then cmp_ag.max_health = json.GetNumber( "max_health" )
	If json.TypeOf( "mass" ) <> JSON_UNDEFINED                    Then cmp_ag.mass = json.GetNumber( "mass" )
	If json.TypeOf( "frictional_coefficient" ) <> JSON_UNDEFINED  Then cmp_ag.frictional_coefficient = json.GetNumber( "frictional_coefficient" )
	If json.TypeOf( "driving_force_magnitude" ) <> JSON_UNDEFINED Then cmp_ag.driving_force.magnitude_max = json.GetNumber( "driving_force_magnitude" )
	If json.TypeOf( "turning_force_magnitude" ) <> JSON_UNDEFINED Then cmp_ag.turning_force.magnitude_max = json.GetNumber( "turning_force_magnitude" )
	If json.TypeOf( "physics_disabled" ) <> JSON_UNDEFINED        Then cmp_ag.physics_disabled = json.GetBoolean( "physics_disabled" )
	'emitters
	If json.TypeOf( "emitters" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "emitters" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local emitter_json:TJSON = TJSON.Create( array.GetByIndex( i ))
				Local em:EMITTER = Create_EMITTER_from_json_reference( emitter_json )
				If em Then cmp_ag.add_emitter( em, emitter_json.GetNumber( "event" ))
			Next
		End If
	End If
	'death package
	If json.TypeOf( "death_package" ) <> JSON_UNDEFINED
		If json.GetBoolean( "death_package" )
			cmp_ag.add_death_package()
		End If
	End If
	'motivator package
	If json.TypeOf( "motivator_package" ) <> JSON_UNDEFINED
		Local obj:TJSONObject = json.GetObject( "motivator_package" )
		If obj And Not obj.IsNull()
			Local motivator_json:TJSON = TJSON.Create( obj )
			cmp_ag.add_motivator_package( ..
				motivator_json.GetString( "particle_key" ), ..
				motivator_json.GetNumber( "offset_x" ), ..
				motivator_json.GetNumber( "separation_y" ))
		End If
	End If
	'trail package
	If json.TypeOf( "trail_package" ) <> JSON_UNDEFINED
		Local obj:TJSONObject = json.GetObject( "trail_package" )
		If obj And Not obj.IsNull()
			Local trail_json:TJSON = TJSON.Create( obj )
			cmp_ag.add_trail_package( ..
				trail_json.GetString( "particle_emitter_key" ), ..
				trail_json.GetNumber( "offset_x" ), ..
				trail_json.GetNumber( "separation_x" ), ..
				trail_json.GetNumber( "separation_y" ))
		End If
	End If
	'dust cloud package
	If json.TypeOf( "dust_cloud_package" ) <> JSON_UNDEFINED
		Local obj:TJSONObject = json.GetObject( "dust_cloud_package" )
		If obj And Not obj.IsNull()
			Local dust_cloud_json:TJSON = TJSON.Create( obj )
			cmp_ag.add_dust_cloud_package( ..
				dust_cloud_json.GetNumber( "offset_x" ), ..
				dust_cloud_json.GetNumber( "separation_x" ), ..
				dust_cloud_json.GetNumber( "separation_y" ), ..
				dust_cloud_json.GetNumber( "dist_min" ), ..
				dust_cloud_json.GetNumber( "dist_max" ), ..
				dust_cloud_json.GetNumber( "dist_ang_min" ), ..
				dust_cloud_json.GetNumber( "dist_ang_max" ), ..
				dust_cloud_json.GetNumber( "vel_min" ), ..
				dust_cloud_json.GetNumber( "vel_max" ))
		End If
	End If
	'widgets
	If json.TypeOf( "widgets" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "widgets" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local widget_json:TJSON = TJSON.Create( array.GetByIndex( i ))
				Local w:WIDGET = Create_WIDGET_from_json_reference( widget_json )
				If w Then cmp_ag.add_widget( w, widget_json.GetNumber( "type" ))
			Next
		End If
	End If
	'turret anchors
	If json.TypeOf( "turret_anchors" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "turret_anchors" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local obj:TJSONObject = TJSONObject( array.GetByIndex( i ))
				If obj And Not obj.IsNull()
					Local anchor_json:TJSON = TJSON.Create( obj )
					cmp_ag.add_turret_anchor( ..
						anchor_json.GetNumber( "offset_x" ), ..
						anchor_json.GetNumber( "offset_y" ))
				End If
			Next
		End If
	End If
	'turrets
	If json.TypeOf( "turrets" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "turrets" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local turret_json:TJSON = TJSON.Create( array.GetByIndex( i ))
				Local t:TURRET = Create_TURRET_from_json_reference( turret_json )
				If t Then cmp_ag.add_turret( t, turret_json.GetNumber( "anchor" ))
			Next
		End If
	End If
	'factory units
	If json.TypeOf( "factory_units" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "factory_units" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local obj:TJSONObject = TJSONObject( array.GetByIndex( i ))
				If obj And Not obj.IsNull()
					Local factory_unit_json:TJSON = TJSON.Create( obj )
					cmp_ag.add_factory_unit( ..
						factory_unit_json.GetString( "unit_key" ), ..
						factory_unit_json.GetNumber( "count" ))
				End If
			Next
		End If
	End If
	Return cmp_ag
End Function



