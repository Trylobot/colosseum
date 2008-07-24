Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type COMPLEX_AGENT Extends AGENT
	'Turret List
	Field turret_list:TList
	Field turret_count%
	'Emitters
	Field tread_debris_emitter:EMITTER[4] 'front left, front right, back right, back left emitters
	Field tread_print_emitter:EMITTER[4] 'front left, front right, back right, back left emitters
	
	Method New()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
		For Local tur:TURRET = EachIn turret_list
			tur.draw()
		Next
	End Method
	
	'think of this method like a request, safe to call at any time.
	'ie, if the player is currently reloading, this method will do nothing.
	Method fire( turret_index% = 0 )
		Local this_turret:TURRET = get_turret( turret_index )
		If this_turret <> Null
			this_turret.fire()
		End If
	End Method
	
	Method get_turret:TURRET( turret_index% )
		If turret_index >= 0 And turret_index < turret_count
			Return TURRET(turret_list.ValueAtIndex( turret_index ))
		Else
			Return Null
		End If
	End Method
	
	Method add_turret( new_turret:TURRET )
		new_turret.last_reloaded_ts = now()
		new_turret.parent = Self
		turret_list.AddLast( new_turret )
		turret_count :+ 1
	End Method
	
	Method update()
		'update positions and offsets
		pos_x :+ vel_x
		pos_y :+ vel_y
		If pos_x > arena_w Then pos_x :- arena_w
		If pos_x < 0       Then pos_x :+ arena_w
		If pos_y > arena_h Then pos_y :- arena_h
		If pos_y < 0       Then pos_y :+ arena_h
		'update angles
		ang :+ ang_vel
		If ang >= 360     Then ang :- 360
		If ang <  0       Then ang :+ 360
		'update turrets
		For Local tur:TURRET = EachIn turret_list
			tur.update()
		Next
	End Method
	
	Method enable_only_forward_tread_debris_emitters()
		tread_debris_emitter[0].enable_timer( infinite_life_time )
		tread_debris_emitter[1].enable_timer( infinite_life_time )
		tread_debris_emitter[2].disable()
		tread_debris_emitter[3].disable()
	End Method
	Method enable_only_rear_tread_debris_emitters()
		tread_debris_emitter[0].disable()
		tread_debris_emitter[1].disable()
		tread_debris_emitter[2].enable_timer( infinite_life_time )
		tread_debris_emitter[3].enable_timer( infinite_life_time )
	End Method
	Method disable_all_tread_debris_emitters()
		tread_debris_emitter[0].disable()
		tread_debris_emitter[1].disable()
		tread_debris_emitter[2].disable()
		tread_debris_emitter[3].disable()
	End Method
	
	Method enable_only_forward_tread_print_emitters()
		tread_print_emitter[0].enable()
		tread_print_emitter[1].enable()
		tread_print_emitter[2].disable()
		tread_print_emitter[3].disable()
	End Method
	Method enable_only_rear_tread_print_emitters()
		tread_print_emitter[0].disable()
		tread_print_emitter[1].disable()
		tread_print_emitter[2].enable()
		tread_print_emitter[3].enable()
	End Method
	Method disable_all_tread_print_emitters()
		tread_print_emitter[0].disable()
		tread_print_emitter[1].disable()
		tread_print_emitter[2].disable()
		tread_print_emitter[3].disable()
	End Method
	
End Type
Function Create_COMPLEX_AGENT:COMPLEX_AGENT() 'more arguments?
	Local ag:COMPLEX_AGENT = New COMPLEX_AGENT
	ag.turret_list = CreateList()
	ag.turret_count = 0
	For Local i% = 0 To 3
		ag.tread_debris_emitter[i] = New EMITTER
		ag.tread_debris_emitter[i].parent = ag
		emitter_list.AddLast( ag.tread_debris_emitter[i] )
	Next
	Return ag
End Function
