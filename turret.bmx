Rem
	turret.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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
			cur_heat :+ RandF( heat_per_shot_min, heat_per_shot_max )
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
			SetChannelRate( ch, RandF( 0.90, 1.15 ))
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


