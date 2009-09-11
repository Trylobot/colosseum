Rem
	spawn_controller.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "constants.bmx"
Import "unit_factory_data.bmx"
Import "entity_data.bmx"
Import "spawn_request.bmx"
Import "cell.bmx"

'______________________________________________________________________________
Function Create_SPAWN_CONTROLLER:SPAWN_CONTROLLER( unit_factories:UNIT_FACTORY_DATA[], immediate_units:ENTITY_DATA[] )
	Local sc:SPAWN_CONTROLLER = New SPAWN_CONTROLLER
	sc.size = unit_factories.Length
	sc.unit_factories = unit_factories
	sc.immediate_units = immediate_units
	sc.init()
	Return sc
End Function
	
Type SPAWN_CONTROLLER
	Const SPAWN_POINT_POLITE_DISTANCE% = 35.0 'delete me (please?)
	
	Field size% 'number of unit_factories; a shortcut
	Field unit_factories:UNIT_FACTORY_DATA[]
	Field active_unit_factories%[] 'for ENVIRONMENT's information
	Field unit_factory_cursor:CELL[] 'for each unit_factory, a (row,col) pointer indicating the current agent to be spawned
	Field spawn_ts%[] 'for each unit_factory, the timestamp of the spawn process start
	Field spawn_counter%[] 'for each unit_factory, a count of how many enemies have been spawned so far
	Field last_spawned:POINT[] 'for each unit_factory, a reference to the location of the last spawned enemy (so they don't overlap)

	Field immediate_units:ENTITY_DATA[]
	Field unspawned_immediate_units%[] 'for ENVIRONMENT's information

	Field current_wave%
	Field squad_wave%[]
	Field squad_owner%[]

	Field spawn_request_list:TList 'TList<SPAWN_REQUEST> to be processed by ENVIRONMENT
	
	Method New()
		spawn_request_list = CreateList()
	End Method
	
	Method init()
		'factories
		unit_factory_cursor = New CELL[size]
		spawn_ts = New Int[size]
		last_spawned = New POINT[size]
		spawn_counter = New Int[size]
		active_unit_factories = New Int[size]
		Local squad_count% = 0
		For Local i% = 0 Until size
			unit_factory_cursor[i] = New CELL
			spawn_ts[i] = now()
			last_spawned[i] = Null
			spawn_counter[i] = 0
			active_unit_factories[i] = True
			squad_count :+ unit_factories[i].count_squads()
		Next
		'immediates
		unspawned_immediate_units = New Int[immediate_units.Length]
		For Local i% = 0 Until immediate_units.Length
			unspawned_immediate_units[i] = True
		Next
		'waves
		squad_owner = New Int[squad_count]
		squad_wave = New Int[squad_count]
		Local sq% = 0
		For Local i% = 0 Until size
			For Local j% = 0 Until unit_factories[i].count_squads()
				squad_owner[sq] = i
				squad_wave[sq] = unit_factories[i].wave_index[j]
				sq :+ 1
			Next
		Next
	End Method

	Method reset( alignment%, omit_immediates% = False )
		If alignment <> POLITICAL_ALIGNMENT.NONE
			'spawn queues and tracking info
			For Local i% = 0 Until unit_factories.Length
				If unit_factories[i].alignment = alignment
					unit_factory_cursor[i] = New CELL
					spawn_ts[i] = now()
					last_spawned[i] = Null
					spawn_counter[i] = 0
					active_unit_factories[i] = True
				End If
			Next
			'immediates
			If Not omit_immediates
				For Local i% = 0 Until unspawned_immediate_units.Length
					If immediate_units[i].alignment = alignment
						unspawned_immediate_units[i] = True
					End If
				Next
			End If
		End If
	End Method
	
	Method update()
		'for each unit_factory
		Local uf:UNIT_FACTORY_DATA
		Local cur:CELL
		Local ts%
		Local last:POINT
		Local counter%
		For Local i% = 0 Until unit_factories.Length
			uf = unit_factories[i]
			cur = unit_factory_cursor[i]
			ts = spawn_ts[i]
			last = last_spawned[i]
			counter = spawn_counter[i]
			'if this unit_factory has more enemies to spawn
			If counter < uf.size
				'if it is time to spawn this unit_factory's current squad
				If now() - ts >= uf.delay_time[cur.row]
					'if this squad has just been started, or the last spawned enemy is away, dead or null
					If cur.col = 0 Or last = Null Or last.dist_to( uf.pos ) >= SPAWN_POINT_POLITE_DISTANCE 'Or last.dead() 'SHOULD be unnecessary (I hope)
						'Local brain:CONTROL_BRAIN = spawn_unit( uf.squads[cur.row][cur.col], uf.alignment, uf.pos )
						'last_spawned[i] = brain.avatar
						spawn_request_list.AddLast( Create_SPAWN_REQUEST( uf.squads[cur.row][cur.col], uf.alignment, uf.pos, i ))
						'various counters
						spawn_counter[i] :+ 1
						cur.col :+ 1
						'if that last guy was the last squadmember of the current squad
						If cur.col > uf.squads[cur.row].Length-1
							'advance this unit_factory to first squadmember of next squad
							cur.col = 0
							cur.row :+ 1
							'restart delay timer
							spawn_ts[i] = now()
							'if that last squad was the last squad of the current unit_factory
							If cur.row > uf.squads.Length-1
								'signal it
								active_unit_factories[i] = False
							End If
						End If
					End If
				Else
				End If
			End If
		Next
		'for each unspawned immediate unit
		Local u:ENTITY_DATA
		For Local i% = 0 Until immediate_units.Length
			If unspawned_immediate_units[i]
				unspawned_immediate_units[i] = False
				u = immediate_units[i]
				spawn_request_list.AddLast( Create_SPAWN_REQUEST( u.archetype, u.alignment, u.pos ))
			End If
		Next
	End Method
	
End Type

