Rem
	turret.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TURRET Extends POINT
	
	'Parent
	Field parent:COMPLEX_AGENT
	'Image
	Field img_base:TImage
	Field img_barrel:TImage
	'Reloading
	Field reload_time% 'time required to reload
	'Ammunition
	Field max_ammo%
	'Field ammo:AMMUNITION 'ammunition object that controls the fired projectiles' look, muzzle velocity, mass, and damage
	'Recoil
	Field recoil_offset#
	Field recoil_offset_ang#
	'Emitters
	Field emitter_list:TList
	Field projectile_emitter:EMITTER
	Field muzzle_flash_emitter:EMITTER
	Field muzzle_smoke_emitter:EMITTER
	Field ejector_port_emitter:EMITTER

	'Turret offset (in relation to parent)
	Field offset#
	Field offset_ang#
	'Reloading
	Field last_reloaded_ts%
	Field reloading_progress_inverse#
	Field cur_ammo%
	'Recoil
	Field cur_recoil_off_x#
	Field cur_recoil_off_y#

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
img_base:TImage, ..
img_barrel:TImage, ..
reload_time%, ..
max_ammo%, ..
recoil_off_x#, recoil_off_y# )
	Local t:TURRET = New TURRET
	
	'static fields
	t.img_base = img_base
	t.img_barrel = img_barrel
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
	Local t:TURRET = New TURRET
	If other = Null Then Return t
	
	'static fields
	t.img_base = other.img_base
	t.img_barrel = other.img_barrel
	t.reload_time = other.reload_time
	t.max_ammo = other.max_ammo
	t.recoil_offset = other.recoil_offset
	t.recoil_offset_ang = other.recoil_offset_ang
	'emitters
	If other.projectile_emitter <> Null Then t.projectile_emitter = Copy_EMITTER( other.projectile_emitter, t.emitter_list, t )
	If other.muzzle_flash_emitter <> Null Then t.muzzle_flash_emitter = Copy_EMITTER( other.muzzle_flash_emitter, t.emitter_list, t )
	If other.muzzle_smoke_emitter <> Null Then t.muzzle_smoke_emitter = Copy_EMITTER( other.muzzle_smoke_emitter, t.emitter_list, t )
	If other.ejector_port_emitter <> Null Then t.ejector_port_emitter = Copy_EMITTER( other.ejector_port_emitter, t.emitter_list, t )
	
	'dynamic fields
	t.parent = new_parent
	t.offset = other.offset
	t.offset_ang = other.offset_ang
	t.last_reloaded_ts = other.last_reloaded_ts
	t.cur_ammo = other.cur_ammo
	t.cur_recoil_off_x = other.cur_recoil_off_x; t.cur_recoil_off_y = other.cur_recoil_off_y

	Return t
End Function

