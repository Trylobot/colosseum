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
	Field max_ammo%
	'Recoil
	Field recoil_offset#
	Field recoil_offset_ang#
	'Emitters
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
		'recoil position (relative to turret handle)
		If ready_to_fire()
			cur_recoil_off_x = 0
			cur_recoil_off_y = 0
		Else 'reloading
			reloading_progress_inverse = 1.0 - Double(now() - last_reloaded_ts) / Double(reload_time)
			cur_recoil_off_x = reloading_progress_inverse * recoil_offset * Cos( ang + recoil_offset_ang )
			cur_recoil_off_y = reloading_progress_inverse * recoil_offset * Sin( ang + recoil_offset_ang )
		End If
		'angle
		ang :+ ang_vel + parent.ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
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
		cur_ammo :+ count - (max_ammo - cur_ammo)
	End Method
		
	Method fire()
		If ready_to_fire()
			
			If projectile_emitter <> Null
				'fire projectile from the muzzle of the barrel
				projectile_emitter.enable_counter()
				projectile_emitter.emit()
			End If
			If ejector_port_emitter <> Null
				'eject shell casing from the ejector port
				ejector_port_emitter.enable_counter()
				ejector_port_emitter.emit()
			End If
			If muzzle_flash_emitter <> Null
				'show a flash from the muzzle of the barrel
				muzzle_flash_emitter.enable_counter()
				muzzle_flash_emitter.emit()
			End If
			If muzzle_smoke_emitter <> Null
				'show smoke from the muzzle of the barrel
				muzzle_smoke_emitter.enable_counter()
				muzzle_smoke_emitter.emit()
			End If
			
			If cur_ammo > 0 Then cur_ammo :- 1
			reload()
			
		End If
	End Method
	
	Method attach_to( ..
	new_parent:COMPLEX_AGENT, ..
	off_x_new#, off_y_new# )
		parent = new_parent
		offset = Sqr( off_x_new*off_x_new + off_y_new*off_y_new )
		offset_ang = ATan( off_y_new/off_x_new )
		If off_x_new < 0 Then offset_ang :- 180
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
	t.recoil_offset = Sqr( recoil_off_x*recoil_off_x + recoil_off_y*recoil_off_y )
	t.recoil_offset_ang = ATan( recoil_off_y/recoil_off_x )
	If recoil_off_x < 0 Then t.recoil_offset_ang :- 180
	
	'dynamic fields
	t.parent = Null
	t.offset = 0
	t.offset_ang = 0
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
	If other.projectile_emitter <> Null Then t.projectile_emitter = Copy_EMITTER( other.projectile_emitter, t )
	If other.muzzle_flash_emitter <> Null Then t.muzzle_flash_emitter = Copy_EMITTER( other.muzzle_flash_emitter, t )
	If other.muzzle_smoke_emitter <> Null Then t.muzzle_smoke_emitter = Copy_EMITTER( other.muzzle_smoke_emitter, t )
	If other.ejector_port_emitter <> Null Then t.ejector_port_emitter = Copy_EMITTER( other.ejector_port_emitter, t )
	
	'dynamic fields
	t.parent = new_parent
	t.offset = other.offset
	t.offset_ang = other.offset_ang
	t.cur_ammo = other.cur_ammo
	t.cur_recoil_off_x = other.cur_recoil_off_x; t.cur_recoil_off_y = other.cur_recoil_off_y

	Return t
End Function

