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
	Field img:TImage
	'Reloading
	Field reload_time% 'time required to reload
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
	
	Method New()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method update()
		'position (updates by parent's current position)
		pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang )
		pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang )
		'angle
		ang :+ ang_vel + parent.ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
	End Method
	
	Method reload()
		last_reloaded_ts = now()
	End Method
	Method not_reloading%()
		Return (now() - last_reloaded_ts) >= reload_time
	End Method
		
	Method fire()
		If not_reloading()
			
			'fire projectile from the muzzle of the barrel
			projectile_emitter.enable_counter()
			projectile_emitter.emit()
			'eject shell casing from the ejector port
			ejector_port_emitter.enable_counter()
			ejector_port_emitter.emit()
			'show a flash from the muzzle of the barrel
			muzzle_flash_emitter.enable_counter()
			muzzle_flash_emitter.emit()
			'show smoke from the muzzle of the barrel
			muzzle_smoke_emitter.enable_counter()
			muzzle_smoke_emitter.emit()
			
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
img:TImage, ..
reload_time%, ..
recoil_off_x#, recoil_off_y# )
	Local t:TURRET = New TURRET
	
	'static fields
	t.img = img
	t.reload_time = reload_time
	t.recoil_offset = Sqr( recoil_off_x*recoil_off_x + recoil_off_y*recoil_off_y )
	t.recoil_offset_ang = ATan( recoil_off_y/recoil_off_x )
	If recoil_off_x < 0 Then t.recoil_offset_ang :- 180
	
	'dynamic fields
	t.parent = Null
	t.offset = 0
	t.offset_ang = 0

	Return t
End Function
'______________________________________________________________________________
Function Copy_TURRET:TURRET( other:TURRET, new_parent:COMPLEX_AGENT = Null )
	Local t:TURRET = New TURRET
	
	'static fields
	t.img = other.img
	t.reload_time = other.reload_time
	t.recoil_offset = other.recoil_offset
	t.recoil_offset_ang = other.recoil_offset_ang
	'emitters
	t.projectile_emitter = Copy_EMITTER( other.projectile_emitter, t )
	t.muzzle_flash_emitter = Copy_EMITTER( other.muzzle_flash_emitter, t )
	t.muzzle_smoke_emitter = Copy_EMITTER( other.muzzle_smoke_emitter, t )
	t.ejector_port_emitter = Copy_EMITTER( other.ejector_port_emitter, t )
	
	'dynamic fields
	t.parent = new_parent
	t.offset = other.offset
	t.offset_ang = other.offset_ang

	Return t
End Function



'old firing routine (pre-archetype) for reference
'			'create muzzle flash
'			Create_PARTICLE( ..
'				muz_img, ..
'				parent.pos_x + offset * Cos( offset_ang + parent.ang ) + muz_offset * Cos( muz_offset_ang + ang ), ..
'				parent.pos_y + offset * Sin( offset_ang + parent.ang ) + muz_offset * Sin( muz_offset_ang + ang ), ..
'				0, ..
'				0, ..
'				ang + parent.ang, ..
'				1.000, 1.000, ..
'				player_turret_muzzle_life_time)
'			
'			'create projectile
'			Create_PROJECTILE( ..
'				proj_img, ..
'				hit_img, ..
'				parent.pos_x + offset * Cos( offset_ang + parent.ang ) + muz_offset * Cos( muz_offset_ang + ang ), ..
'				parent.pos_y + offset * Sin( offset_ang + parent.ang ) + muz_offset * Sin( muz_offset_ang + ang ), ..
'				parent.vel_x + muz_vel * Cos( ang ), ..
'				parent.vel_y + muz_vel * Sin( ang ), ..
'				ang + parent.ang, ..
'				50, 10, ..
'				infinite_life_time )
