Rem
	spawn_controller.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "spawner.bmx"
Import "spawn_request.bmx"
Import "cell.bmx"
Import "complex_agent.bmx"
Import "door.bmx"

'______________________________________________________________________________
Type SPAWN_CONTROLLER
	
	Field current_wave%
	'Field waves:SPAWNER_WAVE[] 'spawn waves
	Field spawn_cursor:CELL[] 'for each spawner, a (row,col) pointer indicating the current agent to be spawned
	Field spawn_ts%[] 'for each spawner, the timestamp of the spawn process start
	Field last_spawned:COMPLEX_AGENT[] 'for each spawner, a reference to the last spawned enemy (so they don't overlap)
	Field spawn_counter%[] 'for each spawner, a count of how many enemies have been spawned so far
	Field spawner_door:DOOR[] 'for each spawner, a door (potentially)
	
	
	
	Method reset_spawners( alignment% = ALIGNMENT_NONE, omit_turrets% = False )
		If alignment = ALIGNMENT_NONE 'ALL
			'flags and counters
			active_friendly_units = 0
			active_friendly_spawners = 0
			active_hostile_units = 0
			active_hostile_spawners = 0
			'spawn queues and tracking info
			spawn_cursor = New CELL[lev.spawners.Length] 'automagically initialized to (0, 0); exactly where it needs to be :)
			spawn_ts = New Int[lev.spawners.Length]
			last_spawned = New COMPLEX_AGENT[lev.spawners.Length]
			spawn_counter = New Int[lev.spawners.Length]
			spawner_door = New DOOR[lev.spawners.Length]
			For Local i% = 0 To lev.spawners.Length-1
				If omit_turrets And lev.spawners[i].class = SPAWNER.class_TURRET_ANCHOR Then Continue
				spawn_cursor[i] = New CELL
				spawn_ts[i] = now()
				last_spawned[i] = Null
				spawn_counter[i] = 0
				If lev.spawners[i].class = SPAWNER.class_GATED_FACTORY
					spawner_door[i] = add_door( lev.spawners[i].pos, lev.spawners[i].alignment )
				End If
				If lev.spawners[i].alignment = ALIGNMENT_FRIENDLY
					active_friendly_spawners :+ 1
				Else If lev.spawners[i].alignment = ALIGNMENT_HOSTILE
					active_hostile_spawners :+ 1
				End If
			Next
		Else 'alignment <> ALIGNMENT_NONE
			'flags and counters
			Select alignment
				Case ALIGNMENT_FRIENDLY
					active_friendly_units = 0
				Case ALIGNMENT_HOSTILE
					active_hostile_units = 0
			End Select
			'spawn queues and tracking info
			For Local i% = 0 To lev.spawners.Length-1
				If omit_turrets And lev.spawners[i].class = SPAWNER.class_TURRET_ANCHOR Then Continue
				If lev.spawners[i].alignment = alignment
					spawn_cursor[i] = New CELL
					spawn_ts[i] = now()
					last_spawned[i] = Null
					spawn_counter[i] = 0
					If lev.spawners[i].alignment = ALIGNMENT_FRIENDLY
						active_friendly_spawners :+ 1
					Else If lev.spawners[i].alignment = ALIGNMENT_HOSTILE
						active_hostile_spawners :+ 1
					End If
				End If
			Next
		End If
	End Method
	
		'returns a list of agents spawned
	Method spawning_system_update:TList()
		Local spawned:TList = CreateList()
		'for each spawner
		Local sp:SPAWNER, cur:CELL, ts%, last:COMPLEX_AGENT, counter%
		For Local i% = 0 Until lev.spawners.Length
			sp = lev.spawners[i]
			cur = spawn_cursor[i]
			ts = spawn_ts[i]
			last = last_spawned[i]
			counter = spawn_counter[i]
			'if this spawner has more enemies to spawn
			If counter < sp.size
				'if it is time to spawn this spawner's current squad
				If now() - ts >= sp.delay_time[cur.row]
					If spawner_door[i] Then spawner_door[i].open()
					'if this squad has just been started, or the last spawned enemy is away, dead or null
					If cur.col = 0 Or last = Null Or last.dead() Or last.dist_to( sp.pos ) >= SPAWN_POINT_POLITE_DISTANCE
						Local brain:CONTROL_BRAIN = spawn_unit( sp.squads[cur.row][cur.col], sp.alignment, sp.pos )
						last_spawned[i] = brain.avatar
						spawned.addLast( last_spawned[i] )
						'various counters
						spawn_counter[i] :+ 1
						cur.col :+ 1
						'if that last guy was the last squadmember of the current squad
						If cur.col > sp.squads[cur.row].Length-1
							'advance this spawner to first squadmember of next squad
							cur.col = 0
							cur.row :+ 1
							'restart delay timer
							spawn_ts[i] = now()
							'close door
							'If spawner_door[i] Then spawner_door[i].close()
							'if that last squad was the last squad of the current spawner
							If cur.row > sp.squads.Length-1
								'active spawner counter update
								Select sp.alignment
									Case ALIGNMENT_FRIENDLY
										active_friendly_spawners :- 1
									Case ALIGNMENT_HOSTILE
										active_hostile_spawners :- 1
								End Select
							End If
						End If
					End If
				Else
				End If
			End If
		Next
		Return spawned
	End Method
	
		
	
End Type

