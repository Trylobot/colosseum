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
	Field emitter_list:TList 'list of all emitters
	Field projectile_emitter:EMITTER 'emits this turret's main projectile
	Field muzzle_flash_emitter:EMITTER 'optional muzzle-flash emitter
	Field muzzle_smoke_emitter:EMITTER 'optional muzzle-smoke emitter
	Field ejector_port_emitter:EMITTER 'optional shell-casing ejector port

	Field offset# 'static offset from parent-agent's handle
	Field offset_ang# 'angle of static offset
	Field last_reloaded_ts% 'timestamp of last reload
	Field reloading_progress_inverse# '(private) used for calculating turret position
	Field cur_ammo% 'remaining ammunition
	Field cur_recoil_off_x# '(private) used in calculating recoil's effect on final position
	Field cur_recoil_off_y# '(private) used in calculating recoil's effect on final position

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
		'position (updates by parent's current position)
		pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang )
		pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang )
		'angle
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
	End Method
	
	Method ready_to_fire%()
		Return ..
			cur_ammo <> 0 And ..
			(now() - last_reloaded_ts) >= reload_time
	End Method
	Method reload()
		last_reloaded_ts = now()
	End Method
	Method re_stock( count% )
		cur_ammo :+ count
		If cur_ammo > max_ammo Then cur_ammo = max_ammo
	End Method
	Method out_of_ammo%()
		Return (cur_ammo <= 0)
	End Method
		
	Method fire()
		If ready_to_fire()
			For Local em:EMITTER = EachIn emitter_list
				em.enable( MODE_ENABLED_WITH_COUNTER )
			Next
			If cur_ammo > 0 Then cur_ammo :- 1
			reload()
		End If
	End Method
	
	Method attach_to( ..
	new_parent:COMPLEX_AGENT, ..
	off_x_new#, off_y_new# )
		parent = new_parent
		cartesian_to_polar( off_x_new, off_y_new, offset, offset_ang )
	End Method
	
End Type
'______________________________________________________________________________
Function Archetype_TURRET:TURRET( ..
img_base:TImage, img_barrel:TImage, ..
max_ang_vel#, ..
reload_time%, ..
max_ammo%, ..
recoil_off_x#, recoil_off_y# )
	Local t:TURRET = New TURRET
	
	'static fields
	t.img_base = img_base; t.img_barrel = img_barrel
	t.max_ang_vel = max_ang_vel
	t.reload_time = reload_time
	t.max_ammo = max_ammo
	cartesian_to_polar( recoil_off_x, recoil_off_y, t.recoil_offset, t.recoil_offset_ang )
	
	'dynamic fields
	t.parent = Null
	t.offset = 0
	t.offset_ang = 0
	t.last_reloaded_ts = now() - t.reload_time
	t.cur_ammo = max_ammo
	t.cur_recoil_off_x = 0; t.cur_recoil_off_y = 0

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
	'emitters
	If other.projectile_emitter <> Null
		If t.parent <> Null Then t.projectile_emitter = Copy_EMITTER( other.projectile_emitter, t.emitter_list, t, new_parent.id ) ..
		Else                     t.projectile_emitter = Copy_EMITTER( other.projectile_emitter, t.emitter_list, t )
	End If
	If other.muzzle_flash_emitter <> Null Then t.muzzle_flash_emitter = Copy_EMITTER( other.muzzle_flash_emitter, t.emitter_list, t )
	If other.muzzle_smoke_emitter <> Null Then t.muzzle_smoke_emitter = Copy_EMITTER( other.muzzle_smoke_emitter, t.emitter_list, t )
	If other.ejector_port_emitter <> Null Then t.ejector_port_emitter = Copy_EMITTER( other.ejector_port_emitter, t.emitter_list, t )
	
	'dynamic fields
	t.offset = other.offset
	t.offset_ang = other.offset_ang
	t.last_reloaded_ts = other.last_reloaded_ts
	t.cur_ammo = other.cur_ammo
	t.cur_recoil_off_x = other.cur_recoil_off_x; t.cur_recoil_off_y = other.cur_recoil_off_y

	Return t
End Function

