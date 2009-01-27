Rem
	turret_barrel.bmx
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
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
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
	
	Method fire_blank()
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
