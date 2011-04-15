Rem
	turret_barrel.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "point.bmx"
'Import "texture_manager.bmx"
'Import "emitter.bmx"
'Import "particle_emitter.bmx"
'Import "projectile_launcher.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global turret_barrel_map:TMap = CreateMap()

Function get_turret_barrel:TURRET_BARREL( key$, copy% = True )
	Local tb:TURRET_BARREL = TURRET_BARREL( turret_barrel_map.ValueForKey( Key.toLower() ))
	If copy And tb Then Return TURRET_BARREL( tb.clone() )
	Return tb
End Function

Function Create_TURRET_BARREL:TURRET_BARREL( ..
img:TImage = Null, ..
reload_time% = 1000, ..
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
	
	'Field parent:TURRET 'parent turret
	Field parent:POINT 'parent point (usually a TURRET)
	Field recoil_cur# 'current recoil distance
	Field attach_r#, attach_a# 'attachment anchor as a polar, to be able to combine parent turret's current orientation at draw-time
	Field launcher:PROJECTILE_LAUNCHER 'the business end; lets loose actual projectiles into the world
	Field emitter_list:TList 'TList<PARTICLE_EMITTER> list of particle emitters to be expended (by count) when barrel fires
	Field last_reloaded_ts% 'timestamp of last reload

	Method New()
		emitter_list = CreateList()
	End Method
	
	Method clone:Object()
		Local tb:TURRET_BARREL = Create_TURRET_BARREL( img, reload_time, recoil_max )
		If launcher Then tb.set_launcher( launcher )
		For Local em:PARTICLE_EMITTER = EachIn emitter_list
			tb.add_emitter( em )
		Next
		tb.attach_at( attach_x, attach_y )
		Return tb
	End Method
	
	Method update()
		'recoil
		recoil_cur = recoil_max * (1.0 - reloaded_pct())
		'velocity (pass-through by parent's current velocity)
		vel_x = parent.vel_x
		vel_y = parent.vel_y
		'angle (includes parent's)
		ang = parent.ang
		'position (updates by parent's current position)
		pos_x = parent.pos_x + attach_r * Cos( attach_a + ang ) + recoil_cur * Cos( ang )
		pos_y = parent.pos_y + attach_r * Sin( attach_a + ang ) + recoil_cur * Sin( ang )
		'emitters
		If launcher
			launcher.update()
		End If
		For Local em:PARTICLE_EMITTER = EachIn emitter_list
			em.update()
		Next
	End Method
	
	Method emit( projectile_manager:TList = Null, background_particle_manager:TList = Null, foreground_particle_manager:TList = Null )
		If launcher
			launcher.emit( projectile_manager )
		End If
		For Local em:PARTICLE_EMITTER = EachIn emitter_list
			em.emit( background_particle_manager, foreground_particle_manager )
		Next
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		If img
			SetRotation( ang )
			DrawImage( img, pos_x, pos_y )
		End If
	End Method
	
	Method attach_at( new_attach_x#, new_attach_y# )
		attach_x = new_attach_x; attach_y = new_attach_y
		cartesian_to_polar( attach_x,attach_y, attach_r,attach_a )
	End Method
	
	Method fire()
		If launcher
			launcher.enable( EMITTER.MODE_ENABLED_WITH_COUNTER )
		End If
		For Local em:PARTICLE_EMITTER = EachIn emitter_list
			em.enable( EMITTER.MODE_ENABLED_WITH_COUNTER )
		Next
		last_reloaded_ts = now()
	End Method
	
	Method fire_blank()
		last_reloaded_ts = now()
	End Method
	
	Method ready_to_fire%( turret_out_of_ammo%, turret_max_heat#, turret_cur_heat# )
		Return ..
			(parent <> Null) And ..
			(Not turret_out_of_ammo ) And ..
			((now() - last_reloaded_ts) >= reload_time) And ..
			(turret_max_heat = INFINITY Or turret_cur_heat < turret_max_heat )
	End Method
	
	Method reloaded_pct#()
		If (now() - last_reloaded_ts) < reload_time
			Return Float(now() - last_reloaded_ts)/Float(reload_time)
		Else
			Return 1.0
		End If
	End Method
	
	Method set_launcher:PROJECTILE_LAUNCHER( new_launcher:PROJECTILE_LAUNCHER )
		launcher = Copy_PROJECTILE_LAUNCHER( new_launcher )
		launcher.parent = Self
		Return launcher
	End Method
	
	Method add_emitter:PARTICLE_EMITTER( other_em:PARTICLE_EMITTER )
		Return Copy_PARTICLE_EMITTER( other_em, emitter_list, Self )
	End Method
End Type

Function Create_TURRET_BARREL_from_json:TURRET_BARREL( json:TJSON )
	Local t:TURRET_BARREL
	'no required fields
	t = Create_TURRET_BARREL()
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED   Then t.img = get_image( json.GetString( "image_key" ))
	If json.TypeOf( "reload_time" ) <> JSON_UNDEFINED Then t.reload_time = json.GetNumber( "reload_time" )
	If json.TypeOf( "recoil_max" ) <> JSON_UNDEFINED  Then t.recoil_max = json.GetNumber( "recoil_max" )
	If json.TypeOf( "launcher" ) <> JSON_UNDEFINED    Then t.set_launcher( Create_PROJECTILE_LAUNCHER_from_json_reference( TJSON.Create( json.GetObject( "launcher" ))))
	If json.TypeOf( "launch_emitters" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "launch_emitters" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local e:PARTICLE_EMITTER = Create_PARTICLE_EMITTER_from_json_reference( TJSON.Create( array.GetByIndex( i )))
				If e Then t.add_emitter( e )
			Next
		End If
	End If
	Return t
End Function

Function Create_TURRET_BARREL_from_json_reference:TURRET_BARREL( json:TJSON )
	Local tb:TURRET_BARREL
	If json.TypeOf( "turret_barrel_key" ) <> JSON_UNDEFINED Then tb = get_turret_barrel( json.GetString( "turret_barrel_key" ))
	If Not tb Then Return Null
	If json.TypeOf( "attach_at" ) <> JSON_UNDEFINED
		Local obj:TJSONObject = json.GetObject( "attach_at" )
		If obj And Not obj.IsNull()
			Local attach_at:TJSON = TJSON.Create( obj )
			tb.attach_at( ..
				attach_at.GetNumber( "offset_x" ), ..
				attach_at.GetNumber( "offset_y" ))
		End If
	End If
	Return tb
End Function