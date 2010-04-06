Rem
	spawn_controller.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "constants.bmx"
'Import "cell.bmx"
'Import "unit_factory_data.bmx"
'Import "entity_data.bmx"
'Import "spawn_request.bmx"
'Import "agent.bmx"

'______________________________________________________________________________
Function Create_SPAWN_CONTROLLER:SPAWN_CONTROLLER( unit_factories:UNIT_FACTORY_DATA[], immediate_units:ENTITY_DATA[] )
	Local sc:SPAWN_CONTROLLER = New SPAWN_CONTROLLER
	sc.unit_factories = unit_factories
	sc.immediate_units = immediate_units
	sc.init()
	Return sc
End Function
	
Type SPAWN_CONTROLLER
	Const SPAWN_POINT_POLITE_DISTANCE% = 35.0 'delete me (please?)
	
	Field unit_factories:UNIT_FACTORY_DATA[]
	Field active_unit_factories%[] 'for ENVIRONMENT's information
	Field unit_factory_cursor:CELL[] 'for each unit_factory, a (row,col) pointer indicating the current agent to be spawned
	Field spawn_ts%[] 'for each unit_factory, the timestamp of the spawn process start
	Field spawn_counter%[] 'for each unit_factory, a count of how many enemies have been spawned so far
	Field active_children:TList[] 'TList<AGENT>[] -- for each unit_factory, a list of units spawned. removed when dead

	Field immediate_units:ENTITY_DATA[]
	Field unspawned_immediate_units%[] 'for ENVIRONMENT's information

	Field current_wave%
	Field max_wave_index%

	Field open_spawn_request%[] 'set to true while a spawn request exists; set to false after request is processed
	Field spawn_request_list:TList 'TList<SPAWN_REQUEST> to be processed by ENVIRONMENT
	
	Method New()
		spawn_request_list = CreateList()
		current_wave = 0
	End Method
	
	Method init()
		'factories
		If unit_factories And unit_factories.Length > 0
			Local size% = unit_factories.Length
			active_unit_factories = New Int[size]
			unit_factory_cursor = New CELL[size]
			spawn_ts = New Int[size]
			spawn_counter = New Int[size]
			active_children = New TList[size]
			open_spawn_request = New Int[size]
			For Local i% = 0 Until size
				active_unit_factories[i] = True
				unit_factory_cursor[i] = New CELL
				spawn_ts[i] = now()
				spawn_counter[i] = 0
				active_children[i] = CreateList()
				If unit_factories[i].wave_index
					For Local sq% = 0 Until unit_factories[i].wave_index.Length
						max_wave_index = Max( max_wave_index, unit_factories[i].wave_index[sq] )
					Next
				End If
			Next
		End If
		'immediates
		If immediate_units And immediate_units.Length > 0
			unspawned_immediate_units = New Int[immediate_units.Length]
			For Local i% = 0 Until immediate_units.Length
				unspawned_immediate_units[i] = True
			Next
		End If
	End Method

	Method reset( omit_immediates% = False )
		'spawn queues and tracking info
		For Local i% = 0 Until unit_factories.Length
			unit_factory_cursor[i] = New CELL
			spawn_ts[i] = now()
			active_children[i].Clear()
			spawn_counter[i] = 0
			active_unit_factories[i] = True
		Next
		'immediates
		If Not omit_immediates
			For Local i% = 0 Until unspawned_immediate_units.Length
				unspawned_immediate_units[i] = True
			Next
		End If
	End Method
	
	Method update()
		'each unit factory
		Local children:TList
		Local uf:UNIT_FACTORY_DATA
		Local cur:CELL
		Local ts%
		Local last:AGENT
		Local counter%
		For Local i% = 0 Until unit_factories.Length
			'skip this factory if it doesn't have any squads
			uf = unit_factories[i]
			If Not uf.squads Then Continue
			'prune dead children
			children = active_children[i]
			For Local child:AGENT = EachIn children
				If child.dead() Then children.Remove( child )
			Next
			cur = unit_factory_cursor[i]
			ts = spawn_ts[i]
			If Not children.IsEmpty()
				last = AGENT( children.Last() )
			Else
				last = Null
			End If
			counter = spawn_counter[i]
			'if this factory has more enemies to spawn
			If counter < uf.wave_unit_count( current_wave )
				'if it is time to spawn this unit_factory's current squad
				If uf.wave_index[cur.row] = current_wave ..
				And now() - ts >= uf.delay_time[cur.row]
					'if the last spawned enemy (if any) is far away or dead
					If Not last Or last.dead() Or last.dist_to( uf.pos ) >= SPAWN_POINT_POLITE_DISTANCE
						'Local brain:CONTROL_BRAIN = spawn_unit( uf.squads[cur.row][cur.col], uf.alignment, uf.pos )
						'last_spawned[i] = brain.avatar
						'////////////////////////////////////////////////////////////////////////////////////////////////////////
						spawn_request_list.AddLast( Create_SPAWN_REQUEST( uf.squads[cur.row][cur.col], uf.alignment, uf.pos, i ))
						open_spawn_request[i] = True
						'////////////////////////////////////////////////////////////////////////////////////////////////////////
						'counter/cursor maintenance
						spawn_counter[i] :+ 1 '; counter :+ 1
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
		'each unspawned immediate
		Local u:ENTITY_DATA
		For Local i% = 0 Until immediate_units.Length
			If unspawned_immediate_units[i]
				unspawned_immediate_units[i] = False
				u = immediate_units[i]
				spawn_request_list.AddLast( Create_SPAWN_REQUEST( u.archetype, u.alignment, u.pos ))
			End If
		Next
		'wave increment
		If current_wave < max_wave_index
			Local wave_concluded% = True
			For Local i% = 0 Until unit_factories.Length
				uf = unit_factories[i]
				If Not uf.wave_index Then Continue
				cur = unit_factory_cursor[i]
				children = active_children[i]
				If open_spawn_request[i] Or Not children.IsEmpty()
					wave_concluded = False 'wave is still considered in progress; early abort
					Exit
				End If
			Next
			If wave_concluded 'all factories are finished with this wave
				current_wave :+ 1
				'reset counters
				For Local i% = 0 Until unit_factories.Length
					spawn_counter[i] = 0
				Next
			End If
		End If
	End Method
	
End Type

