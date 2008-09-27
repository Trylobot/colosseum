Rem
	update.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Physics and Timing Update
Function update_all_objects()
	
	'update body
	If game <> Null

		'if waiting for player to enter arena
		If game.waiting_for_player_to_enter_arena
			'if player has not entered the arena
			If Not (game.player.dist_to( game.player_spawn_point ) > SPAWN_POINT_POLITE_DISTANCE) 'game.point_inside_arena( game.player )
				'if the player has started the engine
				If game.player_engine_running
					'open the friendly doors
					If game.friendly_doors_status = ENVIRONMENT.DOOR_STATUS_CLOSED Then game.activate_doors( ALIGNMENT_FRIENDLY )
				End If
			'else, player has entered the arena
			Else 'point_inside_arena( player )
				game.player_in_locker = False
				game.waiting_for_player_to_enter_arena = False
				If game.hostile_doors_status = ENVIRONMENT.DOOR_STATUS_CLOSED Then game.activate_doors( ALIGNMENT_HOSTILE )
				game.battle_in_progress = True
				game.battle_state_toggle_ts = now()
				game.waiting_for_player_to_exit_arena = True
				game.spawn_enemies = True
			End If
		End If
		'if there are no more enemies this level
		If game.battle_in_progress And game.level_enemies_killed >= game.level_enemy_count
			game.battle_in_progress = False
			game.battle_state_toggle_ts = now()
			If game.hostile_doors_status = ENVIRONMENT.DOOR_STATUS_OPEN Then game.activate_doors( ALIGNMENT_HOSTILE )
			game.spawn_enemies = False
		End If
		'if the battle is over, and waiting for player to exit arena, and player has exited the arena
		If Not game.battle_in_progress And game.waiting_for_player_to_exit_arena And (game.player.dist_to( game.player_spawn_point ) > SPAWN_POINT_POLITE_DISTANCE) 'game.point_inside_arena( game.player )
			game.waiting_for_player_to_exit_arena = False
			game.player_in_locker = True
			'FLAG_player_engine_running = False
			game.level_passed_ts = now()
			game.load_next_level()
		End If
		
		'spawning
'		If game.spawn_enemies
'			game.spawning_system_update()
'		End If
		
		'pickups
		For Local pkp:PICKUP = EachIn game.pickup_list
			pkp.update()
		Next
		'projectiles
		For Local proj:PROJECTILE = EachIn game.projectile_list
			proj.update()
		Next	
		'particles
		For Local list:TList = EachIn game.particle_lists
			For Local part:PARTICLE = EachIn list
				part.update()
				part.prune()
			Next
		Next

		'control brains
		For Local cb:CONTROL_BRAIN = EachIn game.control_brain_list
			cb.update()
		Next
		'complex agents
		For Local list:TList = EachIn game.agent_lists
			For Local ag:COMPLEX_AGENT = EachIn list
				ag.update()
			Next
		Next
		
		'environment
		For Local w:WIDGET = EachIn game.environmental_widget_list
			w.update()
		Next
		
		'retained particles
		If game.retained_particle_list_count > retained_particle_limit
			FLAG_retain_particles = True
		End If
		
	End If
	
End Function

