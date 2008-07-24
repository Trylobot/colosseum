Rem
	turret.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type TURRET
	'Images
	Field img:TImage
	Field muz_img:TImage
	Field proj_img:TImage
	Field hit_img:TImage
	'Parent
	Field parent:COMPLEX_AGENT
	'Angle, Angular Velocity and Angular Acceleration
	Field ang#
	Field ang_vel#
	Field ang_acc#
	'Turret offset (from parent's handle)
	Field offset#
	Field offset_ang#
	'Reloading
	Field reload_time% 'time required to reload
	Field last_reloaded_ts% 'timestamp of last reload
	'Recoil
	Field barrel_travel_time% 'time required for projectile to travel the length of the barrel
	Field recoil_offset#
	Field recoil_offset_ang#
'	'Muzzle offset (from this turret's handle)
'	Field muz_offset#
'	Field muz_offset_ang#
'	Field muz_vel#
	'Emitters
	Field muzzle_emitter:PROJECTILE_EMITTER
	Field muzzle_flash_emitter:EMITTER
	Field muzzle_smoke_emitter:EMITTER
	Field ejector_port_emitter:EMITTER
	
	Method New()
	End Method
	
	Method set_offset( off_x#, off_y# )
		offset = Sqr( off_x*off_x + off_y*off_y )
		offset_ang = ATan( off_y/off_x )
		If off_x < 0
			offset_ang :- 180
		End If
	End Method
	Method set_muz_offset( muz_off_x#, muz_off_y# )
		muz_offset = Sqr( muz_off_x*muz_off_x + muz_off_y*muz_off_y )
		muz_offset_ang = ATan( muz_off_y/muz_off_x )
		If muz_off_x < 0
			muz_offset_ang :- 180
		End If
	End Method
	
'	Method set()
'		offset = Sqr( off_x*off_x + off_y*off_y )
'		offset_ang = ATan( off_y/off_x )
'		If off_x < 0
'			offset_ang :- 180
'		End If
'	End Method
	
	Method draw()
		SetRotation( parent.ang + ang )
		DrawImage( ..
			img, ..
			parent.pos_x + offset * Cos( offset_ang + parent.ang ), ..
			parent.pos_y + offset * Sin( offset_ang + parent.ang ))
	End Method
	
	Method update()
		'angle
		ang :+ ang_vel
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
			
			'create muzzle flash
			Create_PARTICLE( ..
				muz_img, ..
				parent.pos_x + offset * Cos( offset_ang + parent.ang ) + muz_offset * Cos( muz_offset_ang + parent.ang + ang ), ..
				parent.pos_y + offset * Sin( offset_ang + parent.ang ) + muz_offset * Sin( muz_offset_ang + parent.ang + ang ), ..
				0, ..
				0, ..
				ang + parent.ang, ..
				1.000, 1.000, ..
				player_turret_muzzle_life_time)
			
			'create projectile
			Create_PROJECTILE( ..
				proj_img, ..
				hit_img, ..
				parent.pos_x + offset * Cos( offset_ang + parent.ang ) + muz_offset * Cos( muz_offset_ang + parent.ang + ang ), ..
				parent.pos_y + offset * Sin( offset_ang + parent.ang ) + muz_offset * Sin( muz_offset_ang + parent.ang + ang ), ..
				parent.vel_x + muz_vel * Cos( parent.ang + ang ), ..
				parent.vel_y + muz_vel * Sin( parent.ang + ang ), ..
				ang + parent.ang, ..
				50, 10, ..
				infinite_life_time )
				
			reload()
		End If
	End Method
	
End Type
Function Create_TURRET:TURRET() 'arguments?
	Local tur:TURRET = New TURRET
	'tur.set(...)
	Return tur
End Function
