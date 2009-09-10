Rem
	spawn_controller.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "constants.bmx"
Import "spawner.bmx"
Import "spawn_request.bmx"
Import "cell.bmx"

'______________________________________________________________________________
Function Create_SPAWN_CONTROLLER:SPAWN_CONTROLLER( spawners:SPAWNER[] )
	Local sc:SPAWN_CONTROLLER = New SPAWN_CONTROLLER
	sc.size = spawners.Length
	sc.spawners = spawners
	sc.init()
	Return sc
End Function
	
Type SPAWN_CONTROLLER
	Const SPAWN_POINT_POLITE_DISTANCE% = 35.0 'delete me (please?)
	
	Field size% 'number of spawners; a shortcut
	Field spawners:SPAWNER[]
	Field active_spawners%[] 'mostly for ENVIRONMENT to count; has side effect of opening/closing doors
	Field spawn_cursor:CELL[] 'for each spawner, a (row,col) pointer indicating the current agent to be spawned
	Field spawn_ts%[] 'for each spawner, the timestamp of the spawn process start
	Field spawn_counter%[] 'for each spawner, a count of how many enemies have been spawned so far
	Field last_spawned:POINT[] 'for each spawner, a reference to the location of the last spawned enemy (so they don't overlap)

	Field current_wave%
	Field squad_wave%[]
	Field squad_owner%[]

	Field spawn_request_list:TList 'TList<SPAWN_REQUEST> to be processed by ENVIRONMENT
	
	Method New()
		spawn_request_list = CreateList()
	End Method
	
	Method init()
		spawn_cursor = New CELL[size]
		spawn_ts = New Int[size]
		last_spawned = New POINT[size]
		spawn_counter = New Int[size]
		active_spawners = New Int[size]
		Local squad_count% = 0
		For Local i% = 0 Until size
			spawn_cursor[i] = New CELL
			spawn_ts[i] = now()
			last_spawned[i] = Null
			spawn_counter[i] = 0
			active_spawners[i] = False
			squad_count :+ spawners[i].count_squads()
		Next
		'waves
		squad_owner = New Int[squad_count]
		squad_wave = New Int[squad_count]
		Local sq% = 0
		For Local i% = 0 Until size
			For Local j% = 0 Until spawners[i].count_squads()
				squad_owner[sq] = i
				squad_wave[sq] = spawners[i].wave_index[j]
				sq :+ 1
			Next
		Next
	End Method

	Method reset( alignment%, omit_turrets% = False )
		If alignment <> POLITICAL_ALIGNMENT.NONE
			'spawn queues and tracking info
			For Local i% = 0 Until spawners.Length
				If omit_turrets And spawners[i].class = SPAWNER.class_TURRET_ANCHOR
					Continue
				End If
				If spawners[i].alignment = alignment
					spawn_cursor[i] = New CELL
					spawn_ts[i] = now()
					last_spawned[i] = Null
					spawn_counter[i] = 0
					active_spawners[i] = False
				End If
			Next
		End If
	End Method
	
	Method update()
		'for each spawner
		Local sp:SPAWNER
		Local cur:CELL
		Local ts%
		Local last:POINT
		Local counter%
		For Local i% = 0 Until spawners.Length
			sp = spawners[i]
			cur = spawn_cursor[i]
			ts = spawn_ts[i]
			last = last_spawned[i]
			counter = spawn_counter[i]
			'if this spawner has more enemies to spawn
			If counter < sp.size
				'if it is time to spawn this spawner's current squad
				If now() - ts >= sp.delay_time[cur.row]
					active_spawners[i] = True
					'if this squad has just been started, or the last spawned enemy is away, dead or null
					If cur.col = 0 Or last = Null Or last.dist_to( sp.pos ) >= SPAWN_POINT_POLITE_DISTANCE 'Or last.dead() 'SHOULD be unnecessary (I hope)
						'Local brain:CONTROL_BRAIN = spawn_unit( sp.squads[cur.row][cur.col], sp.alignment, sp.pos )
						'last_spawned[i] = brain.avatar
						spawn_request_list.AddLast( Create_SPAWN_REQUEST( sp.squads[cur.row][cur.col], sp.alignment, sp.pos, i ))
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
							'if that last squad was the last squad of the current spawner
							If cur.row > sp.squads.Length-1
								'signal it
								active_spawners[i] = False
							End If
						End If
					End If
				Else
				End If
			End If
		Next
	End Method
	
End Type

