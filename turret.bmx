Rem
	turret.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TURRET Extends POINT
	Const ENERGY% = 1
	Const AMMUNITION% = 2
	Const PRIMARY% = 1
	Const SECONDARY% = 2
	
	Field parent:COMPLEX_AGENT 'parental complex agent this turret is attached to
	Field class% '{ammunition|energy}
	Field priority% '{primary|secondary}
	Field img:TImage 'image to be drawn for the "base" of the turret
	Field cash_value%
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
	Field effective_range# 'effective range of turret (mostly for AI)
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
	class%, priority%, ..
	img:TImage = Null, ..
	cash_value% = 0, ..
	snd_fire:TSound, ..
	turret_barrel_count%, ..
	firing_sequence%[][], ..
	max_ang_vel#, ..
	max_ammo% = INFINITY, ..
	max_heat# = INFINITY, ..
	heat_per_shot_min# = 0.0, heat_per_shot_max# = 0.0, ..
	cooling_coefficient# = 0.0, ..
	overheat_delay% = 0, ..
	effective_range# = 0.0 )
		Local t:TURRET = New TURRET
		'static fields
		t.name = name
		t.class = class
		t.priority = priority
		t.img = img
		t.cash_value = cash_value
		t.snd_fire = snd_fire
		t.turret_barrel_array = New TURRET_BARREL[turret_barrel_count]
		t.firing_sequence = firing_sequence[..]
		t.max_ang_vel = max_ang_vel
		t.max_ammo = max_ammo
		t.max_heat = max_heat
		t.heat_per_shot_min = heat_per_shot_min; t.heat_per_shot_max = heat_per_shot_max
		t.cooling_coefficient = cooling_coefficient
		t.overheat_delay = overheat_delay
		t.effective_range = effective_range
		'dynamic fields
		t.cur_ammo = max_ammo
		t.last_overheat_ts = now() - t.overheat_delay
		Return t
	End Function
	
	Method clone:TURRET()
		Local t:TURRET = TURRET( TURRET.Create( ..
			name, ..
			class, ..
			priority, ..
			img, ..
			cash_value, ..
			snd_fire, ..
			turret_barrel_array.Length, ..
			firing_sequence, ..
			max_ang_vel, ..
			max_ammo, ..
			max_heat, ..
			heat_per_shot_min, ..
			heat_per_shot_max, ..
			cooling_coefficient, ..
			overheat_delay, ..
			effective_range ))
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
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
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
	
	Method fire_blanks_all()
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.fire_blank()
		Next
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
