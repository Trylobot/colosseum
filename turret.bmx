Rem
	turret.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TURRET Extends POINT
	
	Field parent:COMPLEX_AGENT 'parental complex agent this turret is attached to
	Field img_base:TImage 'image to be drawn for the "base" of the turret
	Field img_barrel:TImage 'image to be drawn for the "barrel" of the turret
	Field max_ang_vel# 'maximum rotation speed for this turret
	Field control_pct# '[-1, 1] percent of angular velocity that is being used
	Field reload_time% 'time required to reload
	Field max_ammo% 'maximum number of rounds in reserve (this should be stored in individual ammo objects?)
	'Field ammo:AMMUNITION 'ammunition object that controls the fired projectiles' look, muzzle velocity, mass, and damage
	Field recoil_offset# 'current distance from local origin due to recoil
	Field recoil_offset_ang# 'current angle of recoil
	Field max_heat#
	Field heat_per_shot_min#
	Field heat_per_shot_max#
	Field cooling_coefficient#
	Field overheat_delay%
	
	Field emitter_list:TList 'list of all emitters, to be enabled (with count) when turret fires
	'it is expected that at least one projectile emitter would be added to this object, so it can fire.

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
		End If
	End Method
	
	Method attach_to( ..
	new_parent:COMPLEX_AGENT, ..
	off_x_new#, off_y_new# )
		parent = new_parent
		cartesian_to_polar( off_x_new, off_y_new, offset, offset_ang )
	End Method
	
	Method add_emitter:EMITTER( emitter_type%, emitter_archetype_index% )
		If emitter_type = EMITTER_TYPE_PARTICLE
			Return Copy_EMITTER( particle_emitter_archetype[emitter_archetype_index], emitter_list )
		Else If emitter_type = EMITTER_TYPE_PROJECTILE
			Return Copy_EMITTER( projectile_emitter_archetype[emitter_archetype_index], emitter_list )
		End If
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_TURRET:TURRET( ..
img_base:TImage, img_barrel:TImage, ..
max_ang_vel#, ..
reload_time%, ..
max_ammo%, ..
recoil_off_x#, recoil_off_y#, ..
max_heat#, ..
heat_per_shot_min#, heat_per_shot_max#, ..
cooling_coefficient#, ..
overheat_delay% )
	Local t:TURRET = New TURRET
	
	'static fields
	t.img_base = img_base; t.img_barrel = img_barrel
	t.max_ang_vel = max_ang_vel
	t.reload_time = reload_time
	t.max_ammo = max_ammo
	cartesian_to_polar( recoil_off_x, recoil_off_y, t.recoil_offset, t.recoil_offset_ang )
	t.max_heat = max_heat
	t.heat_per_shot_min = heat_per_shot_min; t.heat_per_shot_max = heat_per_shot_max
	t.cooling_coefficient = cooling_coefficient
	t.overheat_delay = overheat_delay
	
	'dynamic fields
	t.parent = Null
	t.offset = 0
	t.offset_ang = 0
	t.last_reloaded_ts = now() - t.reload_time
	t.cur_ammo = max_ammo
	t.cur_recoil_off_x = 0; t.cur_recoil_off_y = 0
	t.cur_heat = 0
	t.last_overheat_ts = now() - t.overheat_delay

	Return t
End Function
'______________________________________________________________________________
Function Copy_TURRET:TURRET( other:TURRET, new_parent:COMPLEX_AGENT = Null )
	If other = Null Then Return Null
	Local t:TURRET = New TURRET
	
	'static fields
	t.parent = new_parent
	t.img_base = other.img_base; t.img_barrel = other.img_barrel
	t.max_ang_vel = other.max_ang_vel
	t.reload_time = other.reload_time
	t.max_ammo = other.max_ammo
	t.recoil_offset = other.recoil_offset
	t.recoil_offset_ang = other.recoil_offset_ang
	t.max_heat = other.max_heat
	t.heat_per_shot_min = other.heat_per_shot_min; t.heat_per_shot_max = other.heat_per_shot_max
	t.cooling_coefficient = other.cooling_coefficient
	t.overheat_delay = other.overheat_delay
	'emitters
	Local id% = NULL_ID
	If new_parent <> Null Then id = new_parent.id
	For Local em:EMITTER = EachIn other.emitter_list
		Copy_EMITTER( em, t.emitter_list, t, id )
	Next
	
	'dynamic fields
	t.offset = other.offset
	t.offset_ang = other.offset_ang
	t.last_reloaded_ts = other.last_reloaded_ts
	t.cur_ammo = other.cur_ammo
	t.cur_recoil_off_x = other.cur_recoil_off_x; t.cur_recoil_off_y = other.cur_recoil_off_y

	Return t
End Function

