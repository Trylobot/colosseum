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
		
		'player-related stuff
		If game.human_participation
			'local origin
			If game.player <> Null
				game.mouse.x = game.player.pos_x + (2.0 * (mouse.x - window_w/2))
				game.mouse.y = game.player.pos_y + (2.0 * (mouse.y - window_h/2))
				Select game.player_brain.input_type
					Case INPUT_KEYBOARD_MOUSE_HYBRID
						game.drawing_origin.x = window_w/2 - Int((game.player.pos_x + game.mouse.x)/2)
						game.drawing_origin.y = window_h/2 - Int((game.player.pos_y + game.mouse.y)/2)
					Case INPUT_KEYBOARD
						game.drawing_origin.x = window_w/2 - Int(game.player.pos_x)
						game.drawing_origin.y = window_h/2 - Int(game.player.pos_y)
				End Select
'				If game.drawing_origin.x < game.origin_min_x Then game.drawing_origin.x = game.origin_min_x
'				If game.drawing_origin.y < game.origin_min_y Then game.drawing_origin.y = game.origin_min_y
'				If game.drawing_origin.x > game.origin_max_x Then game.drawing_origin.x = game.origin_max_x
'				If game.drawing_origin.y > game.origin_max_y Then game.drawing_origin.y = game.origin_max_y
			End If
			'if waiting for player to enter arena
			If game.waiting_for_player_to_enter_arena
				'if player has not entered the arena
				If game.player.dist_to( game.player_spawn_point ) < SPAWN_POINT_POLITE_DISTANCE 'game.point_inside_arena( game.player )
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
			'if there are no more enemies left
			If game.battle_in_progress And game.level_enemies_killed >= game.level_enemy_count
				game.battle_in_progress = False
				game.battle_state_toggle_ts = now()
				If game.hostile_doors_status = ENVIRONMENT.DOOR_STATUS_OPEN Then game.activate_doors( ALIGNMENT_HOSTILE )
				game.spawn_enemies = False
			End If
			'if the battle is over, and player has exited the arena
			If Not game.battle_in_progress And game.waiting_for_player_to_exit_arena And (game.player.dist_to( game.player_spawn_point ) < SPAWN_POINT_POLITE_DISTANCE) 'game.point_inside_arena( game.player )
				game.waiting_for_player_to_exit_arena = False
				game.player_in_locker = True
				'FLAG_player_engine_running = False
				game.level_passed_ts = now()
				'go back to shop
				FLAG_in_shop = True
			End If
		End If
		
		'spawner system
		If game.spawn_enemies
			game.spawning_system_update()
		End If
		
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
		'agents
		For Local list:TList = EachIn game.agent_lists
			For Local ag:COMPLEX_AGENT = EachIn list
				ag.update()
			Next
		Next
		
		'environmental widgets
		For Local w:WIDGET = EachIn game.environmental_widget_list
			w.update()
		Next
		
		'retain particles (?)
		If game.retained_particle_list_count > retained_particle_limit
			FLAG_retain_particles = True
		End If
		
	End If
	
End Function

