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
	Field cooling_rate#
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
	snd_fire:TSound = Null, ..
	turret_barrel_count%, ..
	firing_sequence%[][], ..
	max_ang_vel# = 0.5, ..
	max_ammo% = INFINITY, ..
	heat_based% = False, ..
	heat_per_shot_min# = 0.0, heat_per_shot_max# = 0.0, ..
	cooling_rate# = 0.0, ..
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
		If heat_based Then t.max_heat = 1.00 Else t.max_heat = INFINITY
		t.heat_per_shot_min = heat_per_shot_min; t.heat_per_shot_max = heat_per_shot_max
		t.cooling_rate = cooling_rate
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
			(max_heat <> INFINITY), ..
			heat_per_shot_min, ..
			heat_per_shot_max, ..
			cooling_rate, ..
			overheat_delay, ..
			effective_range ))
		'copy all turret barrels
		For Local tb_index% = 0 Until turret_barrel_array.Length
			Local tb:TURRET_BARREL = turret_barrel_array[tb_index]
			t.add_turret_barrel( tb, tb_index ).attach_at( tb.attach_x, tb.attach_y )
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
		If parent
			'velocity (updates by parent's current velocity)
			vel_x = parent.vel_x
			vel_y = parent.vel_y
			'position (updates by parent's current position)
			pos_x = parent.pos_x + offset * Cos( offset_ang + parent.ang )
			pos_y = parent.pos_y + offset * Sin( offset_ang + parent.ang )
			'angular velocity
			ang_vel = control_pct * max_ang_vel
			'angle (includes parent's)
			ang = ang_wrap( ang + timescale * ang_vel + timescale * parent.ang_vel )
		End If
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
		If Not overheated() Then cur_heat :- timescale * cooling_rate
		If cur_heat < 0 Then cur_heat = 0
	End Method
	
	Method draw( alpha_override# = 1.0, scale_override# = 1.0 )
		SetColor( 255, 255, 255 )
		SetAlpha( alpha_override )
		SetScale( scale_override, scale_override )
		SetRotation( ang )
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.draw( alpha_override, scale_override )
		Next
		If img
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
		If control_pct > 1.0 Then control_pct = 1.0 ..
		Else If control_pct < -1.0 Then control_pct = -1.0
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
	
	Method reloaded_pct#()
		Local pct# = 1.0
		For Local tb% = EachIn firing_sequence[firing_state]
			pct = Min( pct, turret_barrel_array[tb].reloaded_pct() )
		Next
		Return pct
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
	
	Method move_to( argument:Object, snap_turrets% = False, perform_update% = False )
		Super.move_to( argument )
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.move_to( Self )
		Next
		If perform_update Then update()
	End Method
	
	Method set_images_unfiltered()
		If img Then img = unfilter_image( img )
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			If tb.img Then tb.img = unfilter_image( tb.img )
		Next
	End Method
	
	Method scale_all( scale# )
		attach_at( off_x * scale, off_y * scale )
		For Local tb:TURRET_BARREL = EachIn turret_barrel_array
			tb.attach_at( tb.attach_x * scale, tb.attach_y * scale )
		Next
	End Method
End Type

Function Create_TURRET_from_json:TURRET( json:TJSON )
	Local t:TURRET
	'required fields
	Local class%
	Local priority%
	Local turret_barrel_count%
	Local firing_sequence%[][]
	If json.TypeOf( "class" ) <> JSON_UNDEFINED               Then class = json.GetNumber( "class" )
	If json.TypeOf( "priority" ) <> JSON_UNDEFINED            Then priority = json.GetNumber( "priority" )
	If json.TypeOf( "turret_barrel_count" ) <> JSON_UNDEFINED Then turret_barrel_count = json.GetNumber( "turret_barrel_count" )
	If json.TypeOf( "firing_sequence" ) <> JSON_UNDEFINED     Then firing_sequence = Create_Int_array_array_from_TJSONArray( json.GetArray( "firing_sequence" ))
	'initialization
	t = TURRET( TURRET.Create( , class, priority,,,, turret_barrel_count, firing_sequence ))
	'optional fields
	If json.TypeOf( "name" ) <> JSON_UNDEFINED              Then t.name = json.GetString( "name" )
	If json.TypeOf( "image_key" ) <> JSON_UNDEFINED         Then t.img = get_image( json.GetString( "image_key" ))
	If json.TypeOf( "cash_value" ) <> JSON_UNDEFINED        Then t.cash_value = json.GetNumber( "cash_value" )
	If json.TypeOf( "firing_sound_key" ) <> JSON_UNDEFINED  Then t.snd_fire = get_sound( json.GetString( "firing_sound_key" ))
	If json.TypeOf( "max_ang_vel" ) <> JSON_UNDEFINED       Then t.max_ang_vel = json.GetNumber( "max_ang_vel" )
	If json.TypeOf( "max_ammo" ) <> JSON_UNDEFINED          Then t.max_ammo = json.GetNumber( "max_ammo" )
	If json.TypeOf( "heat_based" ) <> JSON_UNDEFINED        Then If json.GetBoolean( "heat_based" ) Then t.max_heat = 1.00 Else t.max_heat = INFINITY
	If json.TypeOf( "heat_per_shot_min" ) <> JSON_UNDEFINED Then t.heat_per_shot_min = json.GetNumber( "heat_per_shot_min" )
	If json.TypeOf( "heat_per_shot_max" ) <> JSON_UNDEFINED Then t.heat_per_shot_max = json.GetNumber( "heat_per_shot_max" )
	If json.TypeOf( "cooling_rate" ) <> JSON_UNDEFINED      Then t.cooling_rate = json.GetNumber( "cooling_rate" )
	If json.TypeOf( "overheat_delay" ) <> JSON_UNDEFINED    Then t.overheat_delay = json.GetNumber( "overheat_delay" )
	If json.TypeOf( "effective_range" ) <> JSON_UNDEFINED   Then t.effective_range = json.GetNumber( "effective_range" )
	If json.TypeOf( "turret_barrels" ) <> JSON_UNDEFINED
		Local array:TJSONArray = json.GetArray( "turret_barrels" )
		If array And Not array.IsNull()
			For Local i% = 0 Until array.Size()
				Local tb:TURRET_BARREL = Create_TURRET_BARREL_from_json_reference( TJSON.Create( array.GetByIndex( i )))
				If tb Then t.add_turret_barrel( tb, i )
			Next
		End If
	End If
	Return t
End Function

Function Create_TURRET_from_json_reference:TURRET( json:TJSON )
	
End Function


