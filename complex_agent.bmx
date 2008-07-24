Rem
	complex_agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'______________________________________________________________________________
Type COMPLEX_AGENT Extends AGENT
	'Turret List
	Field turrets:TURRET[]
	Field turret_count%
	''Motivators
	'Field motivators:MOTIVATOR[]
	Field motivator_count%
	'Emitters
	Field forward_debris_emitters:EMITTER[]
	Field rear_debris_emitters:EMITTER[]
	Field forward_trail_emitters:EMITTER[]
	Field rear_trail_emitters:EMITTER[]
	
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
		If turrets[turret_index] <> Null
			turrets[turret_index].fire()
		End If
	End Method
	
	Method add_turret( turret_archetype% )
		Local new_turret:TURRET = Clone_TURRET( turret_archetype_lib[ turret_archetype ])
		new_turret.last_reloaded_ts = now()
		new_turret.parent = Self
		'find the next blank slot in the turret array
		For Local i% = 0 To turret_count - 1
			If turrets[i] = Null
				turrets[i] = new_turret
			End If
		Next
	End Method
	
'	Method add_motivator( new_motivator:MOTIVATOR )
'		
'	End Method
'	Method get_motivator( motivator_index% )
'		
'	End Method
	
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
	
	Method enable_only_forward_emitters()
		For Local i% = 0 To motivator_count - 1
			forward_debris_emitters[i].enable_timer( infinite_life_time )
			forward_trail_emitters[i].enable_timer( infinite_life_time )
			rear_debris_emitters[i].disable()
			rear_trail_emitters[i].disable()
		Next
	End Method
	Method enable_only_rear_emitters()
		For Local i% = 0 To motivator_count - 1
			forward_debris_emitters[i].disable()
			forward_trail_emitters[i].disable()
			rear_debris_emitters[i].enable_timer( infinite_life_time )
			rear_trail_emitters[i].enable_timer( infinite_life_time )
		Next
	End Method
	Method disable_all_emitters()
		For Local i% = 0 To motivator_count - 1
			forward_debris_emitters[i].disable()
			forward_trail_emitters[i].disable()
			rear_debris_emitters[i].disable()
			rear_trail_emitters[i].disable()
		Next
	End Method

End Type
'______________________________________________________________________________
Function Create_COMPLEX_AGENT:COMPLEX_AGENT( ..
img:TImage, ..
pos_x#, pos_y#, ..
ang#, ..
max_health#, ..
turret_count%, ..
motivator_count% )
	Local cag:COMPLEX_AGENT = New COMPLEX_AGENT
	cag.img = img
	cag.pos_x = pos_x; cag.pos_y = pos_y
	cag.ang = ang
	cag.max_health = max_health
	cag.cur_health = max_health
	cag.turret_count = turret_count
	If cag.turret_count > 0
		cag.turrets = New TURRET[ turret_count ]
	End If
	cag.motivator_count = motivator_count
	If cag.motivator_count > 0
		'cag.motivators = New MOTIVATOR[ motivator_count ]
		cag.forward_debris_emitters = New EMITTER[ motivator_count ]
		cag.rear_debris_emitters = New EMITTER[ motivator_count ]
		cag.forward_trail_emitters = New EMITTER[ motivator_count ]
		cag.rear_trail_emitters = New EMITTER[ motivator_count ]
		For Local i% = 0 To motivator_count - 1
			cag.forward_debris_emitters[i].parent = cag
			cag.forward_debris_emitters[i].add_me( emitter_list )
			cag.rear_debris_emitters[i].parent = cag
			cag.rear_debris_emitters[i].add_me( emitter_list )
			cag.forward_trail_emitters[i].parent = cag
			cag.forward_trail_emitters[i].add_me( emitter_list )
			cag.rear_trail_emitters[i].parent = cag
			cag.rear_trail_emitters[i].add_me( emitter_list )
		Next
	End If
	Return cag
End Function
'______________________________________________________________________________
Function Clone_COMPLEX_AGENT:COMPLEX_AGENT( old_cag:COMPLEX_AGENT )
	Local cag:COMPLEX_AGENT = New COMPLEX_AGENT
	cag.img = old_cag.img
	cag.pos_x = old_cag.pos_x; cag.pos_y = old_cag.pos_y
	cag.ang = old_cag.ang
	cag.max_health = old_cag.max_health
	cag.cur_health = cag.max_health
	If old_cag.turret_count > 0
		cag.turrets = New TURRET[ old_cag.turret_count ]
		For Local i% = 0 To old_cag.turret_count - 1
			cag.turrets[i] = Clone_TURRET( old_cag.turrets[i] )
		Next
	End If
	If old_cag.motivator_count > 0
		'cag.motivators = New MOTIVATOR[ old_cag.motivator_count ]
		cag.forward_debris_emitters = New EMITTER[ old_cag.forward_debris_emitters.Length ]
		cag.rear_debris_emitters = New EMITTER[ old_cag.rear_debris_emitters.Length ]
		cag.forward_trail_emitters = New EMITTER[ old_cag.forward_trail_emitters.Length ]
		cag.rear_trail_emitters = New EMITTER[ old_cag.rear_trail_emitters.Length ]
		For Local i% = 0 To old_cag.motivator_count - 1
			'cag.motivators[i] = Clone_MOTIVATOR( old_cag.motivators[i] )
			cag.forward_debris_emitters[i] = Clone_EMITTER( old_cag.forward_debris_emitters[i] )
			cag.rear_debris_emitters[i] = Clone_EMITTER( old_cag.rear_debris_emitters[i] )
			cag.forward_trail_emitters[i] = Clone_EMITTER( old_cag.forward_trail_emitters[i] )
			cag.rear_trail_emitters[i] = Clone_EMITTER( old_cag.rear_trail_emitters[i] )
		Next
	End If
	Return cag
End Function
