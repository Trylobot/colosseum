Rem
	turret.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const TURRET_CLASS_ENERGY% = 0
Const TURRET_CLASS_AMMUNITION% = 1

Type TURRET Extends POINT
	
	Field parent:COMPLEX_AGENT 'parental complex agent this turret is attached to
	Field class% '{ammunition|energy}
	Field img_base:TImage 'image to be drawn for the "base" of the turret
	Field img_barrel:TImage 'image to be drawn for the "barrel" of the turret
	Field snd_fire:TSound 'sound to be played when the turret is fired
	Field max_ang_vel# 'maximum rotation speed for this turret
	Field control_pct# '[-1, 1] percent of angular velocity that is being used
	Field reload_time% 'time required to reload
	Field max_ammo% 'maximum number of rounds in reserve (this should be stored in individual ammo objects?)
	'Field ammo:AMMUNITION 'ammunition object that controls the fired projectiles' look, muzzle velocity, mass, and damage
	Field recoil_off_x#
	Field recoil_off_y#
	Field recoil_offset# 'current distance from local origin due to recoil
	Field recoil_offset_ang# 'current angle of recoil
	Field max_heat#
	Field heat_per_shot_min#
	Field heat_per_shot_max#
	Field cooling_coefficient#
	Field overheat_delay%
	
	Field emitter_list:TList 'list of all emitters, to be enabled (with count) when turret fires
	'it is expected that at least one projectile emitter would be added to this object, so it can fire, but it's not necessary.

	Field off_x#
	Field off_y#
	Field offset# 'static offset from parent-agent's handle
	Field offset_ang# 'angle of static offset
	Field last_reloaded_ts% 'timestamp of last reload
	Field reloading_progress_inverse# '(private) used for calculating turret position
	Field cur_ammo% 'remaining ammunition
	Field cur_recoil_off_x# '(private) used in calculating recoil's effect on final position
	Field cur_recoil_off_y# '(private) used in calculating recoil's effect on final position
	Field cur_heat#
	Field last_overheat_ts%

	Method New()
		emitter_list = CreateList()
	End Method
	
	Function Create:Object( ..
	name$, ..
	class%, ..
	img_base:TImage, img_barrel:TImage, ..
	snd_fire:TSound, ..
	max_ang_vel#, ..
	reload_time%, ..
	max_ammo%, ..
	recoil_off_x#, recoil_off_y#, ..
	max_heat# = INFINITY, ..
	heat_per_shot_min# = 0.0, heat_per_shot_max# = 0.0, ..
	cooling_coefficient# = 0.0, ..
	overheat_delay% = 0 )
		Local t:TURRET = New TURRET
		
		'static fields
		t.name = name
		t.class = class
		t.img_base = img_base; t.img_barrel = img_barrel
		t.snd_fire = snd_fire
		t.max_ang_vel = max_ang_vel
		t.reload_time = reload_time
		t.max_ammo = max_ammo
		t.recoil_off_x = recoil_off_x; t.recoil_off_y = recoil_off_y
		cartesian_to_polar( recoil_off_x, recoil_off_y, t.recoil_offset, t.recoil_offset_ang )
		t.max_heat = max_heat
		t.heat_per_shot_min = heat_per_shot_min; t.heat_per_shot_max = heat_per_shot_max
		t.cooling_coefficient = cooling_coefficient
		t.overheat_delay = overheat_delay
		
		'dynamic fields
		t.offset = 0
		t.offset_ang = 0
		t.last_reloaded_ts = now() - t.reload_time
		t.cur_ammo = max_ammo
		t.cur_recoil_off_x = 0; t.cur_recoil_off_y = 0
		t.cur_heat = 0
		t.last_overheat_ts = now() - t.overheat_delay
	
		Return t
	End Function
	
	Method clone:TURRET()
		Local t:TURRET = TURRET( TURRET.Create( ..
			name, class, img_base, img_barrel, snd_fire, max_ang_vel, reload_time, max_ammo, recoil_off_x, recoil_off_y, max_heat, heat_per_shot_min, heat_per_shot_max, cooling_coefficient, overheat_delay ))
		'copy all emitters
		For Local em:EMITTER = EachIn emitter_list
			EMITTER( EMITTER.Copy( em, t.emitter_list, t ))
		Next
		Return t
	End Method

	Method set_parent( new_parent:COMPLEX_AGENT )
		parent = new_parent
		For Local em:EMITTER = EachIn emitter_list
			em.source_id = parent.id
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
		'angle (includes parent's)
		ang :+ ang_vel + parent.ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
		'recoil position (relative to turret handle)
		If ready_to_fire() Or out_of_ammo()
			cur_recoil_off_x = 0
			cur_recoil_off_y = 0
		Else If Not out_of_ammo() 'reloading
			reloading_progress_inverse = 1.0 - Double(now() - last_reloaded_ts) / Double(reload_time)
			cur_recoil_off_x = reloading_progress_inverse * recoil_offset * Cos( ang + recoil_offset_ang )
			cur_recoil_off_y = reloading_progress_inverse * recoil_offset * Sin( ang + recoil_offset_ang )
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
		SetRotation( ang )
		If img_barrel <> Null
			DrawImage( img_barrel, pos_x + cur_recoil_off_x, pos_y + cur_recoil_off_y )
		End If
		If img_base <> Null
			DrawImage( img_base, pos_x, pos_y )
		End If
	End Method
	
	Method turn( pct# )
		control_pct = pct
		ang_vel = control_pct*max_ang_vel
	End Method
	
	Method ready_to_fire%()
		Return ..
			cur_ammo <> 0 And ..
			(now() - last_reloaded_ts) >= reload_time And ..
			(max_heat = INFINITY Or cur_heat < max_heat)
	End Method
	Method reload()
		last_reloaded_ts = now()
	End Method
	Method re_stock( count% )
		cur_ammo :+ count
		If cur_ammo > max_ammo Then cur_ammo = max_ammo
	End Method
	Method out_of_ammo%()
		Return (cur_ammo = 0)
	End Method
	Method raise_temp()
		cur_heat :+ RandF( heat_per_shot_min, heat_per_shot_max )
		If cur_heat >= max_heat
			last_overheat_ts = now()
			cur_heat = max_heat
		End If
	End Method
	Method overheated%()
		Return (now() - last_overheat_ts) < overheat_delay
	End Method
		
	Method fire()
		If ready_to_fire()
			For Local em:EMITTER = EachIn emitter_list
				em.enable( MODE_ENABLED_WITH_COUNTER )
			Next
			If cur_ammo > 0 Then cur_ammo :- 1
			reload()
			raise_temp()
			play_firing_sound()
		End If
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
	
	Method add_emitter:EMITTER( emitter_type%, archetype_index% )
		If emitter_type = EMITTER_TYPE_PARTICLE
			Return EMITTER( EMITTER.Copy( particle_emitter_archetype[archetype_index], emitter_list, Self ))
		Else If emitter_type = EMITTER_TYPE_PROJECTILE
			Return EMITTER( EMITTER.Copy( projectile_launcher_archetype[archetype_index], emitter_list, Self ))
		End If
	End Method
	
End Type


