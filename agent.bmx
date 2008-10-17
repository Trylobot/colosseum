Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type AGENT Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field gibs:TImage 'gib image(s)
	Field max_health# 'maximum health
	Field cash_value% 'cash to be awarded player on this agent's death
	Field death_emitters:TList

	Field cur_health# 'current health
	
	Method New()
		force_list = CreateList()
		death_emitters = CreateList()
	End Method
	
	Method dead%()
		Return (cur_health <= 0)
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no overkill
	End Method

	Method self_destruct( other:AGENT )
		'damage
		other.receive_damage( 100 )
		'explosive forces
		Local offset#, offset_ang#
		cartesian_to_polar( pos_x - other.pos_x, pos_y - other.pos_y, offset, offset_ang )
		Local total_force# = 100.0
		other.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, offset_ang, total_force*Cos( offset_ang - ang ), 100 )))
		other.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE, 0, offset*total_force*Sin( offset_ang - ang ), 100 )))
		'death effects
		die()
	End Method
	
	Method die()
		'spawn halo particle
		Local halo:PARTICLE = PARTICLE( PARTICLE.Create( PARTICLE_TYPE_IMG, img_halo,,,,, LAYER_BACKGROUND, False,,,,,,,, 200, pos_x, pos_y, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 1.0, -0.1000 ))
		halo.auto_manage()
		'spawn gibs
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
				gib.update()
				gib.created_ts = now()
				gib.auto_manage()
			Next
		End If
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
	
End Type

'______________________________________________________________________________
Const PROJECTILE_MEMBER_EMITTER_CONSTANT% = 0
Const PROJECTILE_MEMBER_EMITTER_PAYLOAD% = 1

Type PROJECTILE Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field snd_impact:TSound 'sound to be played on impact
	Field damage# 'maximum damage dealt by projectile
	Field explosive_force_magnitude#
	Field radius# 'radius of damage spread
	Field max_vel# 'absolute maximum speed (enforced)
	Field ignore_other_projectiles% 'whether to ignore collisions with other projectiles {true|false}
	Field source_id% '(private) reference to entity which emitted this projectile; allows for collisions with it to be ignored
	Field emitter_list_constant:TList
	Field emitter_list_payload:TList
	
	Method New()
		emitter_list_constant = CreateList()
		emitter_list_payload = CreateList()
	End Method
	
	Function Create:Object( ..
	name$ = Null, ..
	img:TImage = Null, ..
	snd_impact:TSound = Null, ..
	damage# = 0.0, ..
	explosive_force_magnitude# = 0.0, ..
	radius# = 0.0, ..
	max_vel# = INFINITY, ..
	mass# = 1.0, ..
	frictional_coefficient# = 0.0, ..
	ignore_other_projectiles% = False, ..
	source_id% = NULL_ID, ..
	pos_x# = 0.0, pos_y# = 0.0, ..
	vel_x# = 0.0, vel_y# = 0.0, ..
	ang# = 0.0, ..
	ang_vel# = 0.0 )
		Local p:PROJECTILE = New PROJECTILE
		
		'static fields
		p.name = name
		p.img = img
		p.snd_impact = snd_impact
		p.damage = damage
		p.radius = radius
		p.max_vel = max_vel
		p.mass = mass
		p.frictional_coefficient = frictional_coefficient
		p.ignore_other_projectiles = ignore_other_projectiles
		p.source_id = source_id
		
		'dynamic fields
		p.pos_x = pos_x; p.pos_y = pos_y
		p.vel_x = vel_x; p.vel_y = vel_y
		p.ang = ang
		p.ang_vel = ang_vel
		
		Return p
	End Function
	
	Method clone:PROJECTILE( new_source_id% = NULL_ID )
		Local p:PROJECTILE = PROJECTILE( PROJECTILE.Create( ..
			name, img, snd_impact, damage, explosive_force_magnitude, radius, max_vel, mass, frictional_coefficient, ignore_other_projectiles, new_source_id, pos_x, pos_y, vel_x, vel_y, ang, ang_vel ))
		'emitter lists
		For Local em:EMITTER = EachIn emitter_list_constant
			p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_CONSTANT )
		Next
		For Local em:EMITTER = EachIn emitter_list_payload
			p.add_emitter( em, PROJECTILE_MEMBER_EMITTER_PAYLOAD )
		Next
		Return p
	End Method

	Method update()
		'physical object variables
		Super.update()
		'constant-on emitters
		For Local em:EMITTER = EachIn emitter_list_constant
			em.update()
			em.emit()
		Next
		'maximum velocity
		If max_vel <> INFINITY
			Local vel_mag#, vel_dir#
			cartesian_to_polar( vel_x, vel_y, vel_mag, vel_dir )
			If vel_mag > max_vel
				polar_to_cartesian( max_vel, vel_dir, vel_x, vel_y )
			End If
		End If
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method auto_manage()
		manage( game.projectile_list )
	End Method
	
	Method impact( other:COMPLEX_AGENT = Null )
		'payload emitters
		For Local em:EMITTER = EachIn emitter_list_payload
			em.enable( MODE_ENABLED_WITH_COUNTER )
			While em.is_enabled() And em.ready()
				em.update()
				em.emit()
			End While
		Next
		Local volume# = 0.3333
		If other <> Null And other.id = get_player_id() Then volume = 1.00
		play_impact_sound( volume )
	End Method
	
	Method play_impact_sound( volume# )
		If snd_impact <> Null
			Local ch:TChannel = AllocChannel()
			CueSound( snd_impact, ch )
			SetChannelVolume( ch, volume )
			SetChannelRate( ch, Rnd( 0.75, 1.25 ))
			ResumeChannel( ch )
			audio_channels.AddLast( ch )
		End If
	End Method
	
	Method add_emitter:EMITTER( other_em:EMITTER, category% )
		Local em:EMITTER
		Select category
			Case PROJECTILE_MEMBER_EMITTER_CONSTANT
				em = EMITTER( EMITTER.Copy( other_em, emitter_list_constant, Self, source_id ))
				em.enable()
				Return em
			Case PROJECTILE_MEMBER_EMITTER_PAYLOAD
				em = EMITTER( EMITTER.Copy( other_em, emitter_list_payload, Self, source_id ))
				em.disable()
				Return em
			Default
				Return Null
		End Select
	End Method
	
End Type

'______________________________________________________________________________
Function Create_TURRET_BARREL:TURRET_BARREL( ..
img:TImage = Null, ..
reload_time%, ..
recoil_max# = 0 )
	Local tb:TURRET_BARREL = New TURRET_BARREL
	'static fields
	tb.img = img
	tb.reload_time = reload_time
	tb.recoil_max = recoil_max
	'dynamic fields
	tb.last_reloaded_ts = now() - tb.reload_time
	Return tb
End Function

Type TURRET_BARREL Extends POINT
	Field img:TImage 'image associated with this turret barrel
	Field reload_time% 'time required to reload this barrel
	Field recoil_max# 'maximum recoil distance
	Field attach_x#, attach_y# 'attachment anchor (at default orientation), set at create-time
	
	Field parent:TURRET 'parent turret
	Field recoil_cur# 'current recoil distance
	Field attach_r#, attach_a# 'attachment anchor as a polar, to be able to combine parent turret's current orientation at draw-time
	Field launcher:EMITTER 'projectile emitter associated with this barrel
	Field emitter_list:TList 'list of particle emitters to be enabled (by count) when barrel fires
	Field last_reloaded_ts% 'timestamp of last reload

	Method New()
		emitter_list = CreateList()
	End Method
	
	Method clone:Object()
		Local tb:TURRET_BARREL = Create_TURRET_BARREL( img, reload_time, recoil_max )
		tb.add_launcher( launcher )
		For Local em:EMITTER = EachIn emitter_list
			tb.add_emitter( em )
		Next
		Return tb
	End Method
	
	Method update()
		'velocity (updates by parent's current velocity)
		vel_x = parent.vel_x
		vel_y = parent.vel_y
		'position (updates by parent's current position)
		pos_x = parent.pos_x + attach_r * Cos( attach_a + parent.ang )
		pos_y = parent.pos_y + attach_r * Sin( attach_a + parent.ang )
		'angle (includes parent's)
		ang = parent.ang
		'recoil position
		If ready_to_fire() Or parent.out_of_ammo() 'not reloading
			recoil_cur = 0
		Else If Not parent.out_of_ammo() 'reloading
			recoil_cur = recoil_max * (1.0 - Float(now() - last_reloaded_ts) / Float(reload_time))
		End If
		'emitters
		launcher.update()
		launcher.emit()
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
		Next
	End Method
	
	Method draw()
		If img <> Null
			SetRotation( ang )
			DrawImage( img, pos_x + recoil_cur * Cos( ang ), pos_y + recoil_cur * Sin( ang ))
		End If
	End Method
	
	Method attach_at( new_attach_x#, new_attach_y# )
		attach_x = new_attach_x; attach_y = new_attach_y
		cartesian_to_polar( attach_x,attach_y, attach_r,attach_a )
	End Method
	
	Method fire()
		If launcher <> Null
			launcher.enable( MODE_ENABLED_WITH_COUNTER )
		End If
		For Local em:EMITTER = EachIn emitter_list
			em.enable( MODE_ENABLED_WITH_COUNTER )
		Next
		last_reloaded_ts = now()
	End Method
	
	Method ready_to_fire%()
		Return ..
			(parent <> Null) And ..
			(parent.cur_ammo <> 0) And ..
			((now() - last_reloaded_ts) >= reload_time) And ..
			(parent.max_heat = INFINITY Or parent.cur_heat < parent.max_heat )
	End Method
	
	Method add_launcher:EMITTER( new_launcher:EMITTER )
		launcher = Copy_EMITTER( new_launcher )
		launcher.parent = Self
		Return launcher
	End Method
	
	Method add_emitter:EMITTER( other_em:EMITTER )
		Return EMITTER( EMITTER.Copy( other_em, emitter_list, Self ))
	End Method
	
End Type
'______________________________________________________________________________
Const TURRET_CLASS_ENERGY% = 0
Const TURRET_CLASS_AMMUNITION% = 1

Type TURRET Extends POINT
	
	Field parent:COMPLEX_AGENT 'parental complex agent this turret is attached to
	Field class% '{ammunition|energy}
	Field img:TImage 'image to be drawn for the "base" of the turret
	Field snd_fire:TSound 'sound to be played when the turret is fired
'	Field snd_turn:TSound 'sound to be played when the turret is turned
	Field max_ang_vel# 'maximum rotation speed for this turret group
	Field turret_barrel_array:TURRET_BARREL[] 'barrels attached to this turret
	Field firing_sequence%[][] 'describes the sequential firing order of the barrels; wrap mode is locked to CYCLIC_WRAP style for simplicity
	Field firing_state% 'indicates which sequence index this turret group is currently on
	Field FLAG_increment% 'if true, indicates this turret group wishes to move to the next firing state; will actually move when completely reloaded
	Field control_pct# '[-1, 1] percent of angular velocity that is being used
	Field max_ammo% 'maximum number of rounds in reserve (this should be stored in individual ammo objects?)
	Field max_heat#
	Field heat_per_shot_min#
	Field heat_per_shot_max#
	Field cooling_coefficient#
	Field overheat_delay%
	Field emitter_list:TList 'list of all emitters to be enabled (with count) when turret fires

	Field off_x#
	Field off_y#
	Field offset# 'static offset from parent-agent's handle
	Field offset_ang# 'angle of static offset
	Field cur_ammo% 'remaining ammunition
	Field cur_heat#
	Field last_overheat_ts%
	Field bonus_cooling_start_ts%
	Field bonus_cooling_time%

	Method New()
		emitter_list = CreateList()
	End Method
	
	Function Create:Object( ..
	name$ = Null, ..
	class%, ..
	img:TImage = Null, ..
	snd_fire:TSound, ..
	turret_barrel_count%, ..
	firing_sequence%[][], ..
	max_ang_vel#, ..
	max_ammo% = INFINITY, ..
	max_heat# = INFINITY, ..
	heat_per_shot_min# = 0.0, heat_per_shot_max# = 0.0, ..
	cooling_coefficient# = 0.0, ..
	overheat_delay% = 0 )
		Local t:TURRET = New TURRET
		
		'static fields
		t.name = name
		t.class = class
		t.img = img
		t.snd_fire = snd_fire
		t.turret_barrel_array = New TURRET_BARREL[turret_barrel_count]
		t.firing_sequence = firing_sequence[..]
		t.max_ang_vel = max_ang_vel
		t.max_ammo = max_ammo
		t.max_heat = max_heat
		t.heat_per_shot_min = heat_per_shot_min; t.heat_per_shot_max = heat_per_shot_max
		t.cooling_coefficient = cooling_coefficient
		t.overheat_delay = overheat_delay
		'dynamic fields
		t.cur_ammo = max_ammo
		t.last_overheat_ts = now() - t.overheat_delay
	
		Return t
	End Function
	
	Method clone:TURRET()
		Local t:TURRET = TURRET( TURRET.Create( name, class, img, snd_fire, turret_barrel_array.Length, firing_sequence, max_ang_vel, max_ammo, max_heat, heat_per_shot_min, heat_per_shot_max, cooling_coefficient, overheat_delay ))
		'turret barrels
		For Local tb% = 0 To turret_barrel_array.Length - 1
			t.add_turret_barrel( turret_barrel_array[tb], tb )
		Next
		'copy all emitters
		For Local em:EMITTER = EachIn emitter_list
			EMITTER( EMITTER.Copy( em, t.emitter_list, t ))
		Next
		Return t
	End Method

	Method set_parent( new_parent:COMPLEX_AGENT )
		parent = new_parent
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.launcher.source_id = parent.id
		Next
	End Method
	
	Method attach_at( off_x_new#, off_y_new# )
		off_x = off_x_new; off_y = off_y_new
		cartesian_to_polar( off_x_new, off_y_new, offset, offset_ang )
	End Method
	
	Method update()
		'velocity (updates by parent's current velocity)
		vel_x = parent.vel_x
		vel_y = parent.vel_y
		'position (updates by parent's current position)
		pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang )
		pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang )
		'angular velocity
		ang_vel = control_pct * max_ang_vel
		'angle (includes parent's)
		ang = ang_wrap( ang + ang_vel + parent.ang_vel )
		'barrels
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.update()
		Next
		'turret barrel firing state readiness
		If FLAG_increment
			If ready_to_fire()
				FLAG_increment = False
				firing_state :+ 1
				'firing state: cyclic wrap enforce
				If firing_state > firing_sequence.Length - 1 Then firing_state = 0
			End If
		End If
		'emitters
		For Local em:EMITTER = EachIn emitter_list
			em.update()
			em.emit()
		Next
		'heat/cooling
		If Not overheated() Then cur_heat :- cur_heat*cooling_coefficient
	End Method
	
	Method draw()
		SetColor( parent.red, parent.green, parent.blue )
		SetAlpha( parent.alpha )
		SetScale( parent.scale, parent.scale )
		
		SetRotation( ang )
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.draw()
		Next
		If img <> Null
			DrawImage( img, pos_x, pos_y )
		End If
	End Method
	
	Method fire()
		If Not FLAG_increment
			FLAG_increment = True
			If cur_ammo > 0 Then cur_ammo :- 1
			For Local tb_index% = EachIn firing_sequence[firing_state]
				turret_barrel_array[tb_index].fire()
			Next
			raise_temp()
			play_firing_sound()
			For Local em:EMITTER = EachIn emitter_list
				em.enable( MODE_ENABLED_WITH_COUNTER )
			Next
		End If
	End Method
	
	Method ready_to_fire%()
		For Local tb% = EachIn firing_sequence[firing_state]
			If Not turret_barrel_array[tb].ready_to_fire()
				Return False
			End If
		Next
		Return True
	End Method
	
	Method turn( new_control_pct# )
		control_pct = new_control_pct
	End Method
	
	Method re_stock( count% )
		cur_ammo :+ count
		If cur_ammo > max_ammo Then cur_ammo = max_ammo
	End Method
	
	Method out_of_ammo%()
		Return (cur_ammo = 0)
	End Method
	
	Method raise_temp()
		If (now() - bonus_cooling_start_ts) >= bonus_cooling_time
			cur_heat :+ Rnd( heat_per_shot_min, heat_per_shot_max )
			If cur_heat >= max_heat
				last_overheat_ts = now()
				cur_heat = max_heat
			End If
		End If
	End Method
	
	Method overheated%()
		Return (now() - last_overheat_ts) < overheat_delay
	End Method
	
	Method play_firing_sound()
		If snd_fire <> Null
			Local ch:TChannel = AllocChannel()
			CueSound( snd_fire, ch )
			If parent.id <> get_player_id()
				SetChannelVolume( ch, 0.1500 )
			End If
			SetChannelRate( ch, Rnd( 0.90, 1.15 ))
			ResumeChannel( ch )
			audio_channels.AddLast( ch )
		End If
	End Method
	
	Method add_turret_barrel:TURRET_BARREL( other_tb:TURRET_BARREL, slot% )
		Local tb:TURRET_BARREL = TURRET_BARREL( other_tb.clone() )
		tb.parent = Self
		turret_barrel_array[slot] = tb
		Return tb
	End Method
	
	Method add_emitter:EMITTER( other_em:EMITTER )
		Return EMITTER( EMITTER.Copy( other_em, emitter_list, Self ))
	End Method
	
End Type

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
	Field ai_type% 'artificial intelligence subroutine index (only used for AI-controlled agents)

	Field turret_list:TList 'list of turret groups attached to this agent

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
		turret_list = CreateList()
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
	gibs:TImage, ..
	ai_type%, ..
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
		c.gibs = gibs
		c.ai_type = ai_type
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
		
		For Local other_t:TURRET = EachIn other.turret_list
			c.add_turret( other_t ).attach_at( other_t.off_x, other_t.off_y )
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
		For Local t:TURRET = EachIn turret_list
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
	Method draw( red_override% = -1, green_override% = -1, blue_override% = -1, alpha_override# = -1.0, scale_override# = -1.0 )
		If red_override   <> -1   Then red   = red_override   Else red   = 255
		If green_override <> -1   Then green = green_override Else green = 255
		If blue_override  <> -1.0 Then blue  = blue_override  Else blue  = 255
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
			left_track.draw()
			right_track.draw()
		End If
		'chassis
		SetColor( red, green, blue )
		SetAlpha( alpha )
		SetScale( scale, scale )
		SetRotation( ang )
		If img <> Null Then DrawImage( img, pos_x, pos_y )
		'chassis widgets
		For Local widget_list:TList = EachIn all_widgets
			For Local w:WIDGET = EachIn widget_list
				If w.layer = LAYER_IN_FRONT_OF_PARENT
					w.draw()
				End If
			Next
		Next
		'turrets
		For Local t:TURRET = EachIn turret_list
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
		If      pct > 0 Then enable_only_rear_emitters() ..
		Else If pct < 0 Then enable_only_forward_emitters() ..
		Else                 disable_all_emitters()
	End Method
	'___________________________________________
	Method turn( pct# )
		turning_force.control_pct = pct
	End Method
	
	'___________________________________________
	Method fire( index% )
		If index < turret_list.Count()
			Local t:TURRET = TURRET( turret_list.ValueAtIndex( index ))
			If t <> Null Then t.fire()
		End If
	End Method
	'___________________________________________
	Method turn_turret( index%, control_pct# )
		If index < turret_list.Count()
			Local t:TURRET = TURRET( turret_list.ValueAtIndex( index ))
			If t <> Null Then t.turn( control_pct )
		End If
	End Method
	'___________________________________________
	Method snap_all_turrets()
		For Local t:TURRET = EachIn turret_list
			t.ang = ang
		Next
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
				For Local t:TURRET = EachIn turret_list
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
				For Local t:TURRET = EachIn turret_list
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
	Method add_turret:TURRET( other_t:TURRET )
		Local t:TURRET = other_t.clone()
		t.set_parent( Self )
		t.manage( turret_list )
		Return t
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

'______________________________________________________________________________
Const waypoint_radius# = 20.0
Const friendly_blocking_scalar_projection_distance# = 20.0

Const CONTROL_TYPE_HUMAN% = 1
Const CONTROL_TYPE_AI% = 2
Const INPUT_KEYBOARD% = 1
Const INPUT_KEYBOARD_MOUSE_HYBRID% = 2
Const INPUT_XBOX_360_CONTROLLER% = 3
Const AI_BRAIN_MR_THE_BOX% = 1
Const AI_BRAIN_TURRET% = 2
Const AI_BRAIN_SEEKER% = 3
Const AI_BRAIN_TANK% = 4
'___________________________________________
Function Create_CONTROL_BRAIN:CONTROL_BRAIN( ..
avatar:COMPLEX_AGENT, ..
control_type%, ..
input_type% = UNSPECIFIED, ..
think_delay% = 0, ..
look_target_delay% = 0, ..
find_path_delay% = 0 )
	Local cb:CONTROL_BRAIN = New CONTROL_BRAIN
	
	cb.avatar = avatar
	cb.control_type = control_type
	cb.input_type = input_type
	If control_type = CONTROL_TYPE_AI
		cb.ai_type = avatar.ai_type
	Else
		cb.ai_type = UNSPECIFIED
	End If
	cb.think_delay = think_delay
	cb.look_target_delay = look_target_delay
	cb.find_path_delay = find_path_delay
	
	cb.sighted_target = False
	cb.last_think_ts = now()
	cb.last_look_target_ts = now()
	cb.last_find_path_ts = now()

	Return cb
End Function
'_________________________________________
Type CONTROL_BRAIN Extends MANAGED_OBJECT
	
	Field avatar:COMPLEX_AGENT 'this brain's "body"
	Field target:AGENT 'current target
	Field control_type% 'control type indicator
	Field input_type% 'for human-based controllers, the input device
	Field ai_type% 'for AI-based controllers, the specific AI "style"
	Field think_delay% 'mandatory delay between think cycles
	Field look_target_delay% 'mandatory delay between "see_target" calls
	Field find_path_delay% 'mandatory delay between "find_path" calls
	
	Field path:TList 'path to some destination
	Field waypoint:cVEC 'next waypoint
	Field ang_to_target# '(private)
	Field dist_to_target# '(private)
	Field sighted_target% '(private)
	Field last_think_ts% '(private)
	Field last_look_target_ts% '(private)
	Field last_find_path_ts% '(private)
	Field FLAG_waiting% '(private)
	
	Method New()
	End Method
	
	Method update()
		prune()
		If control_type = CONTROL_TYPE_HUMAN
			input_control()
		Else If control_type = CONTROL_TYPE_AI
			'how often this brain gets processing time
			If (now() - last_think_ts) > think_delay
				last_think_ts = now()
				If waypoint = Null Or waypoint_reached()
					get_next_waypoint()
				End If
				AI_control()
			End If
		End If
	End Method
	
	Method input_control()
		Select input_type
			
			Case INPUT_KEYBOARD, INPUT_KEYBOARD_MOUSE_HYBRID
				'If engine is running
				If game.player_engine_running
					'velocity
					If KeyDown( KEY_W ) Or KeyDown( KEY_I ) Or KeyDown( KEY_UP )
						avatar.drive( 1.0 )
					ElseIf KeyDown( KEY_S ) Or KeyDown( KEY_K ) Or KeyDown( KEY_DOWN )
						avatar.drive( -1.0 )
					Else
						avatar.drive( 0.0 )
					EndIf
					'angular velocity
					If KeyDown( KEY_D )
						avatar.turn( 1.0 )
					ElseIf KeyDown( KEY_A )
						avatar.turn( -1.0 )
					Else
						avatar.turn( 0.0 )
					EndIf
				Else
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					'start engine
					If KeyHit( KEY_E ) And Not game.player_engine_ignition
						game.player_engine_ignition = True
					End If
				End If
				
				If input_type = INPUT_KEYBOARD
					'turret(s) angular velocity
					If KeyDown( KEY_RIGHT ) Or KeyDown( KEY_L )
						avatar.turn_turret( 0, 1.0  )
						avatar.turn_turret( 1, 1.0  )
					ElseIf KeyDown( KEY_LEFT ) Or KeyDown( KEY_J )
						avatar.turn_turret( 0, -1.0 )
						avatar.turn_turret( 1, -1.0 )
					Else
						avatar.turn_turret( 0, 0.0 )
						avatar.turn_turret( 1, 0.0 )
					EndIf
				Else If input_type = INPUT_KEYBOARD_MOUSE_HYBRID
					For Local t:TURRET = EachIn game.player.turret_list
						Local diff# = ang_wrap( t.ang - t.ang_to_cVEC( game.mouse ))
						Local diff_mag# = Abs( diff )
						If diff_mag > 5*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 1.0  )
								avatar.turn_turret( 1, 1.0  )
							Else 'diff > 0
								avatar.turn_turret( 0, -1.0 )
								avatar.turn_turret( 1, -1.0 )
							End If
						Else If diff_mag > 2.5*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.5  )
								avatar.turn_turret( 1, 0.5  )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.5 )
								avatar.turn_turret( 1, -0.5 )
							End If
						Else If diff_mag > 1.25*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.25 )
								avatar.turn_turret( 1, 0.25 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.25 )
								avatar.turn_turret( 1, -0.25 )
							End If
						Else If diff_mag > 0.75*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.125 )
								avatar.turn_turret( 1, 0.125 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.125 )
								avatar.turn_turret( 1, -0.125 )
							End If
						Else If diff_mag > 0.375*t.max_ang_vel
							If diff < 0
								avatar.turn_turret( 0, 0.0625 )
								avatar.turn_turret( 1, 0.0625 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.0625 )
								avatar.turn_turret( 1, -0.0625 )
							End If
						Else
							If diff < 0
								avatar.turn_turret( 0, 0.03125 )
								avatar.turn_turret( 1, 0.03125 )
							Else 'diff > 0
								avatar.turn_turret( 0, -0.03125 )
								avatar.turn_turret( 1, -0.03125 )
							End If
						End If
					Next
				End If
				
				If input_type = INPUT_KEYBOARD
					'turret(s) fire
					If KeyDown( KEY_SPACE )
						avatar.fire( 0 )
					End If
					If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT )
						avatar.fire( 1 )
					End If
'					If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
'						avatar.fire_turret_group( 2 )
'					End If
				Else If input_type = INPUT_KEYBOARD_MOUSE_HYBRID
					'turret(s) fire
					If MouseDown( 1 )
						avatar.fire( 0 )
					End If
					If MouseDown( 2 )
						avatar.fire( 1 )
					End If
				End If
					
			Case INPUT_XBOX_360_CONTROLLER
				'..?
			
		End Select
	End Method
	
	Method AI_control()
		Select ai_type

			Case AI_BRAIN_MR_THE_BOX
				If path <> Null And Not path.IsEmpty() And waypoint <> Null
					follow_path()
				Else
					If (now() - last_find_path_ts >= find_path_delay)
						path = get_path_to_somewhere()
					Else
						blindly_wander()
					End If
				End If
				
			Case AI_BRAIN_TURRET
				If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, chase it.
					If sighted_target
						'if not facing target, face target; when facing target, fire
						ang_to_target = avatar.ang_to( target )
						Local diff# = ang_wrap( TURRET( avatar.turret_list.First() ).ang - ang_to_target )
						If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
							If diff >= 0 Then avatar.turn_turret( 0, -1.0 ) ..
							Else               avatar.turn_turret( 0, 1.0 )
						Else 'if enemy in sight, fire; To Do: add code to check for friendlies in the line of fire.
							avatar.turn_turret( 0, 0 )
							'wait for cooldown
							If FLAG_waiting And TURRET( avatar.turret_list.First() ).cur_heat <= 0.25*TURRET( avatar.turret_list.First() ).max_heat Then FLAG_waiting = False ..
							Else If TURRET( avatar.turret_list.First() ).overheated() Then FLAG_waiting = True
							If Not FLAG_waiting Then avatar.fire( 0 )
						End If
					Else
						'no line of sight to target
						avatar.turn_turret( 0, 0 )
					End If
				Else
					'no target
					avatar.turn_turret( 0, 0 )
					target = acquire_target()
				End If
				
			Case AI_BRAIN_SEEKER
				If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, chase it.
					If sighted_target
						enable_seek_lights()
						'chase after current target; if target in range, self-destruct
						path = Null
						avatar.drive( 1.0 )
						ang_to_target = avatar.ang_to( target )
						Local diff# = ang_wrap( avatar.ang - ang_to_target )
						If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
							If diff >= 0 Then avatar.turn( -1.0 ) ..
							Else               avatar.turn( 1.0 )
						Else
							avatar.turn( 0 )
						End If
						dist_to_target = avatar.dist_to( target )
						If dist_to_target <= 20 Then avatar.self_destruct( target )
					Else 'cannot see target
						enable_wander_lights()
						If path <> Null And Not path.IsEmpty() And waypoint <> Null
							ang_to_target = avatar.ang_to_cVEC( waypoint )
							Local diff# = ang_wrap( avatar.ang - ang_to_target )
							'if it is pointed toward the path's next waypoint, then..
							If Abs(diff) <= 5.000
								'drive forward
								avatar.drive( 0.4600 )
								avatar.turn( 0.0 )
							'else (not pointed toward next waypoint)..
							Else
								'turn towards the next waypoint and drive at 1/3 speed
								avatar.drive( 0.2300 )
								If diff >= 0 Then avatar.turn( -1.0 ) ..
								Else               avatar.turn( 1.0 )
							End If
						'else (can't see the target, no path to the target)
						Else
							'attempt to get a path to the target (which will not be used until the next "think cycle"
							If (now() - last_find_path_ts >= find_path_delay)
								path = get_path_to_target()
							End If
							blindly_wander()
						End If
					End If
				Else
					'no target
					avatar.drive( 0.333 )
					avatar.turn( Rnd( -0.5, 0.5 ))
					target = acquire_target()
				End If
				
			Case AI_BRAIN_TANK
				If Not game.point_inside_arena( avatar )
					avatar.drive( 1.0 )
					Return
				Else If target <> Null And Not target.dead()
					'if it's okay to try and see the target..
					If (now() - last_look_target_ts >= look_target_delay)
						sighted_target = see_target()
					End If
					'if it can see the target, then..
					If sighted_target
						enable_seek_lights()
						path = Null
						ang_to_target = avatar.ang_to( target )
						Local diff# = ang_wrap( TURRET( avatar.turret_list.First() ).ang - ang_to_target )
						'stop moving
						avatar.drive( 0.0 )
						avatar.turn( 0.0 )
						'if its turret is pointing at the target, then..
						If Abs(diff) <= 3.000
							'fire turret(s)
							'wait for cooldown
							If FLAG_waiting And TURRET( avatar.turret_list.First() ).cur_heat <= 0.25*TURRET( avatar.turret_list.First() ).max_heat Then FLAG_waiting = False ..
							Else If TURRET( avatar.turret_list.First() ).overheated() Then FLAG_waiting = True
							If Not FLAG_waiting Then avatar.fire( 0 )
							'stop aiming
							avatar.turn_turret( 0, 0.0 )
						'else (not pointing at target)..
						Else
							'aim the turret at the target
							If diff >= 0 Then avatar.turn_turret( 0, -1.0 ) ..
							Else               avatar.turn_turret( 0, 1.0 )
						End If
					'else (can't see the target) -- if it has a path to the target, then..
					Else
						enable_wander_lights()
						'return the turret to its resting angle
						Local diff# = ang_wrap( avatar.ang - TURRET( avatar.turret_list.First() ).ang )
						If Abs(diff) <= 3.000
							avatar.turn_turret( 0, 0.0 )
						Else
							If diff >= 0 Then avatar.turn_turret( 0, 1.0 ) ..
							Else               avatar.turn_turret( 0, -1.0 )
						End If

						If path <> Null And Not path.IsEmpty() And waypoint <> Null
							ang_to_target = avatar.ang_to_cVEC( waypoint )
							Local diff# = ang_wrap( avatar.ang - ang_to_target )
							'if it is pointed toward the path's next waypoint, then..
							If Abs(diff) <= 3.000
								'drive forward
								avatar.drive( 1.0 )
								avatar.turn( 0.0 )
							'else (not pointed toward next waypoint)..
							Else
								'turn towards the next waypoint and drive at 1/3 speed
								avatar.drive( 0.3333 )
								If diff >= 0 Then avatar.turn( -1.0 ) ..
								Else               avatar.turn( 1.0 )
							End If
						'else (can't see the target, no path to the target)
						Else
							'attempt to get a path to the target (which will not be used until the next "think cycle"
							If (now() - last_find_path_ts >= find_path_delay)
								path = get_path_to_target()
							End If
							'stop driving
							avatar.drive( 0.0 )
							avatar.turn( 0.0 )
						End If
					End If
				Else
					'attempt to acquire a new target
					avatar.drive( 0.0 )
					avatar.turn( 0.0 )
					target = acquire_target()
				End If				
				
		End Select
	End Method
	
	Method track( t:TURRET, p:POINT )
		Local diff# = ang_wrap( t.ang - t.ang_to( p ))
		Local diff_mag# = Abs( diff )
		
'		If diff_mag > 5*t.max_ang_vel
'			If diff < 0
'				avatar.turn_turret( 0, 1.0  )
'				avatar.turn_turret( 1, 1.0  )
'			Else 'diff > 0
'				avatar.turn_turret( 0, -1.0 )
'				avatar.turn_turret( 1, -1.0 )
'			End If
'		Else If diff_mag > 2.5*t.max_ang_vel
'			If diff < 0
'				avatar.turn_turret( 0, 0.5  )
'				avatar.turn_turret( 1, 0.5  )
'			Else 'diff > 0
'				avatar.turn_turret( 0, -0.5 )
'				avatar.turn_turret( 1, -0.5 )
'			End If
'		Else If diff_mag > 1.25*t.max_ang_vel
'			If diff < 0
'				player.turn_turret( 0, 0.25 )
'				player.turn_turret( 1, 0.25 )
'			Else 'diff > 0
'				player.turn_turret( 0, -0.25 )
'				player.turn_turret( 1, -0.25 )
'			End If
'		Else If diff_mag > 0.75*t.max_ang_vel
'			If diff < 0
'				player.turn_turret( 0, 0.125 )
'				player.turn_turret( 1, 0.125 )
'			Else 'diff > 0
'				player.turn_turret( 0, -0.125 )
'				player.turn_turret( 1, -0.125 )
'			End If
'		Else If diff_mag > 0.375*t.max_ang_vel
'			If diff < 0
'				player.turn_turret( 0, 0.0625 )
'				player.turn_turret( 1, 0.0625 )
'			Else 'diff > 0
'				player.turn_turret( 0, -0.0625 )
'				player.turn_turret( 1, -0.0625 )
'			End If
'		Else
'			player.turn_turret( 0, 0.0 )
'			player.turn_turret( 1, 0.0 )
'		End If
	End Method
	
	Method waypoint_reached%()
		If waypoint <> Null And avatar.dist_to_cVEC( waypoint ) <= waypoint_radius
			Return True
		Else
			Return False 'sir, where are we going? LOL :D
		End If
	End Method
	
	Method get_next_waypoint%()
		If path <> Null And Not path.IsEmpty()
			waypoint = cVEC( path.First())
			path.RemoveFirst()
			Return True 'course locked!
		Else
			Return False 'no seriously.. like, where the hell are we... ;_;
		End If
	End Method
	
	Method acquire_target:AGENT()
		Local ag:AGENT = Null, dist#
		Local closest_rival_agent:AGENT = Null, dist_to_ag# = -1
		Select avatar.political_alignment
			Case ALIGNMENT_NONE
				Return Null
			Case ALIGNMENT_FRIENDLY
				For ag = EachIn game.hostile_agent_list
					dist = avatar.dist_to( ag )
					If dist_to_ag < 0 Or dist < dist_to_ag
						dist_to_ag = dist
						closest_rival_agent = ag
					End If
				Next
				Return closest_rival_agent 'TARGET ACQUIRED!
			Case ALIGNMENT_HOSTILE
				For ag = EachIn game.friendly_agent_list
					dist = avatar.dist_to( ag )
					If dist_to_ag < 0 Or dist < dist_to_ag
						dist_to_ag = dist
						closest_rival_agent = ag
					End If
				Next
				Return closest_rival_agent 'TARGET ACQUIRED!
		End Select
	End Method
	
	Method see_target%()
		If target <> Null
			last_look_target_ts = now()
			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
			Local targ:cVEC = cVEC( cVEC.Create( target.pos_x, target.pos_y ))
			'for each wall in the level
			For Local wall:BOX = EachIn game.walls
				'if the line connecting this brain's avatar with its target intersects the wall
				If line_intersects_rect( av,targ, cVEC( cVEC.Create(wall.x, wall.y)), cVEC( cVEC.Create(wall.w, wall.h)) )
					'then the avatar cannot see its target
					Return False
				End If
			Next
			'after checking all the walls, still haven't returned; avatar can therefore see its target
			'however, the shot might be blocked by a friendly
			If avatar.turret_list.Count() > 0
				Return Not friendly_blocking()
			Else 'avatar.turret_count <= 0
				Return True
			End If
		Else 'target == Null
			Return False
		End If
	End Method
?Debug
'	Method see_target_DEBUG%()
'		If target <> Null
'			last_look_target_ts = now()
'			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
'			Local targ:cVEC = cVEC( cVEC.Create( target.pos_x, target.pos_y ))
'			'for each wall in the level
'			For Local wall:BOX = EachIn game.walls
'				'if the line connecting this brain's avatar with its target intersects the wall
'				If line_intersects_rect( av,targ, cVEC( cVEC.Create(wall.x, wall.y)), cVEC( cVEC.Create(wall.w, wall.h)) )
'SetColor( 255, 255, 255 )
'SetAlpha( 0.5 )
'DrawLine( av.x, av.y, targ.x, targ.y )
'DrawRect( wall.x, wall.y, wall.w, wall.h )
'					'then the avatar cannot see its target
'					Return False
'				End If
'			Next
'			'after checking all the walls, still haven't returned; avatar can therefore see its target
'			'however, the shot might be blocked by a friendly
'			If avatar.turret_list.Count() > 0
'				Return Not friendly_blocking()
'			Else 'avatar.turret_count <= 0
'				Return True
'			End If
'		Else 'target == Null
'			debug_drawtext( "target -> null" )
'			Return False
'		End If
'	End Method
?
	
	Method friendly_blocking%()
		If target <> Null
			last_look_target_ts = now()
			Local av:cVEC = cVEC( cVEC.Create( avatar.pos_x, avatar.pos_y ))
			Local targ:cVEC = cVEC( cVEC.Create( target.pos_x, target.pos_y ))
			'for each allied agent
			Local allied_agent_list:TList = CreateList()
			Select avatar.political_alignment
				Case ALIGNMENT_FRIENDLY
					allied_agent_list = game.friendly_agent_list
				Case ALIGNMENT_HOSTILE
					allied_agent_list = game.hostile_agent_list
			End Select
			Local ally_offset#, ally_offset_ang#
			Local scalar_projection#
			For Local ally:COMPLEX_AGENT = EachIn allied_agent_list
				'if the line of sight of the avatar is too close to the ally
				ally_offset = TURRET( avatar.turret_list.First() ).dist_to( ally )
				ally_offset_ang = TURRET( avatar.turret_list.First() ).ang_to( ally )
				scalar_projection = ally_offset*Cos( ally_offset_ang - TURRET( avatar.turret_list.First() ).ang )
				
				If vector_length( ..
				(ally.pos_x - av.x+scalar_projection*Cos(TURRET( avatar.turret_list.First() ).ang)), ..
				(ally.pos_y - av.y+scalar_projection*Sin(TURRET( avatar.turret_list.First() ).ang)) ) ..
				< friendly_blocking_scalar_projection_distance
					'then the avatar's shot is blocked by this ally
					Return True
				End If
			Next
			'after checking all the allies, none are blocking
			Return False
		Else 'target == Null, thus no blockers
			Return False
		End If
	End Method

	Method get_path_to_target:TList()
		If target <> Null
			last_find_path_ts = now()
			Return game.find_path( avatar.pos_x,avatar.pos_y, target.pos_x,target.pos_y )
		Else
			Return Null
		End If
	End Method
	
	Method get_path_to_somewhere:TList()
		last_find_path_ts = now()
		Local somewhere:cVEC = cVEC( cVEC.Create( Rnd( 0, game.lev.width-1 ), Rnd( 0, game.lev.height-1 )))
		Return game.find_path( avatar.pos_x,avatar.pos_y, somewhere.x,somewhere.y )
	End Method
	
	Method blindly_wander()
		avatar.drive( 0.333 )
		avatar.turn( Rnd( -0.5, 0.5 ))
	End Method
	
	Method seek_target()
		avatar.drive( 1.0 )
		turn_toward_target()
	End Method
	
	Method follow_path()
		ang_to_target = avatar.ang_to_cVEC( waypoint )
		Local diff# = ang_wrap( avatar.ang - ang_to_target )
		'if it is pointed toward the path's next waypoint, then..
		If Abs(diff) <= 15.000
			'drive forward
			avatar.drive( 1.0 )
			avatar.turn( 0.0 )
		'else (not pointed toward next waypoint)..
		Else
			'turn towards the next waypoint and drive at 1/3 speed
			avatar.drive( 0.3333 )
			If diff >= 0 Then avatar.turn( -1.0 ) ..
			Else               avatar.turn( 1.0 )
		End If
	End Method
	
	Method turn_toward_target()
		ang_to_target = avatar.ang_to( target )
		Local diff# = ang_wrap( avatar.ang - ang_to_target )
		If Abs( diff ) >= 2.500 'if not pointing at enemy, rotate until ye do
			If diff >= 0 Then avatar.turn( -1.0 ) ..
			Else               avatar.turn( 1.0 )
		Else
			avatar.turn( 0 )
		End If
	End Method
	
	Method fire_at_target()
		'fire turret(s)
		'wait for cooldown
		If FLAG_waiting And TURRET( avatar.turret_list.First() ).cur_heat <= 0.25*TURRET( avatar.turret_list.First() ).max_heat Then FLAG_waiting = False ..
		Else If TURRET( avatar.turret_list.First() ).overheated() Then FLAG_waiting = True
		If Not FLAG_waiting Then avatar.fire( 0 )
		'stop aiming
		avatar.turn_turret( 0, 0.0 )
	End Method
	
	Method turn_turrets_toward_target()
		ang_to_target = avatar.ang_to( target )
		Local diff# = ang_wrap( avatar.ang - ang_to_target )
		'aim the turret at the target
		If diff >= 0 Then avatar.turn_turret( 0, -1.0 ) ..
		Else               avatar.turn_turret( 0, 1.0 )
	End Method
	
	Method enable_seek_lights()
		For Local w:WIDGET = EachIn avatar.constant_widgets
			If      w.name = "AI seek light"   Then w.visible = True ..
			Else If w.name = "AI wander light" Then w.visible = False
		Next
	End Method
	
	Method enable_wander_lights()
		For Local w:WIDGET = EachIn avatar.constant_widgets
			If      w.name = "AI seek light"   Then w.visible = False ..
			Else If w.name = "AI wander light" Then w.visible = True
		Next
	End Method
	
	Method prune()
		If avatar = Null
			unmanage()
		Else If avatar.dead()
			avatar.unmanage()
			unmanage()
		End If
	End Method
	
End Type

