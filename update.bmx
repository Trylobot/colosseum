Rem
	update.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Physics and Timing Update
Function update_all()
	
	If ..
	Not FLAG_in_menu And ..
	Not FLAG_in_shop And ..
	Not FLAG_draw_help
		
		'_______________________________________
		'game logic
		'if waiting for player to enter arena
		If FLAG_waiting_for_player_to_enter_arena
			'if player has not entered the arena
			If player_spawn_point.dist_to(player) < arena_offset
				'if the player has started the engine
				If FLAG_player_engine_running
					'open the friendly doors
					If friendly_doors_status = DOOR_STATUS_CLOSED Then activate_doors( ALIGNMENT_FRIENDLY )
				End If
			'else, player has entered the arena
			Else 'player_spawn_point.dist_to(player) >= (arena_offset/2.0)
				FLAG_player_in_locker = False
				FLAG_waiting_for_player_to_enter_arena = False
				If hostile_doors_status = DOOR_STATUS_CLOSED Then activate_doors( ALIGNMENT_HOSTILE )
				FLAG_battle_in_progress = True
				battle_toggle_ts = now()
				FLAG_waiting_for_player_to_exit_arena = True
				FLAG_spawn_enemies = True
			End If
		End If
		'if there are no more enemies this level
		If FLAG_battle_in_progress And hostile_agent_list.Count() = 0 And enemy_spawn_queue.IsEmpty() And cur_squad = Null
			FLAG_battle_in_progress = False
			battle_toggle_ts = now()
			If hostile_doors_status = DOOR_STATUS_OPEN Then activate_doors( ALIGNMENT_HOSTILE )
			FLAG_spawn_enemies = False
		End If
		'if the battle is over, and waiting for player to exit arena, and player has exited the arena
		If Not FLAG_battle_in_progress And FLAG_waiting_for_player_to_exit_arena And player_spawn_point.dist_to(player) < (arena_offset/2.0)
			FLAG_waiting_for_player_to_exit_arena = False
			FLAG_player_in_locker = True
			'FLAG_player_engine_running = False
			level_passed_ts = now()
			load_next_level()
		End If
		
		'spawning
		If FLAG_spawn_enemies
			spawning_system_update()
		End If
		
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.update()
		Next
		'projectiles
		For Local proj:PROJECTILE = EachIn projectile_list
			proj.update()
		Next	
		'particles
		For Local list:TList = EachIn particle_lists
			For Local part:PARTICLE = EachIn list
				part.update()
				part.prune()
			Next
		Next

		'control brains
		For Local cb:CONTROL_BRAIN = EachIn control_brain_list
			cb.update()
		Next
		'complex agents
		For Local list:TList = EachIn agent_lists
			For Local ag:COMPLEX_AGENT = EachIn list
				ag.update()
			Next
		Next
		
		'environment
		For Local w:WIDGET = EachIn environmental_widget_list
			w.update()
		Next
		
		'retained particles
		If retained_particle_list_count > retained_particle_limit
			FLAG_retain_particles = True
		End If
		
	Else If FLAG_in_menu And FLAG_AI_demo
		update_AI_demo()
	
	End If
End Function

Function update_AI_demo()
	
End Function


