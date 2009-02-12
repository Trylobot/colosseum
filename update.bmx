Rem
	update.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const time_per_frame_min% = 8 'milliseconds
Global before%
Global timescale#
Const timescale_constant_factor# = 0.375 'simulation speed

Function frame_time_elapsed%() 'true or false: the amount of time required for a physics frame has indeed elapsed?
	Return (now() - before) > time_per_frame_min
End Function
Function reset_frame_timer()
	before = now()
End Function

Function calculate_timescale()
	timescale = timescale_constant_factor * Float(now() - before)/Float(time_per_frame_min)
End Function

'______________________________________________________________________________
'Physics and Timing Update
Global damage_incurred% = False

Function update_all_objects()
	
	'update body
	If game And Not game.paused
		
		'set drawing origin
		update_drawing_origin()
		
		'count units in-game
		game.count_units()
		'player and game-state flags
		update_flags()
		If Not game Then Return 'possibility exists that game will be deleted
		
		'spawner systems
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
				If part.prune() And part.retain
					part.manage( game.retained_particle_list )
					game.retained_particle_count :+ 1
				End If
			Next
		Next

		'control brains
		For Local cb:CONTROL_BRAIN = EachIn game.control_brain_list
			cb.update()
		Next
		'complex agents
		For Local list:TList = EachIn game.complex_agent_lists
			For Local ag_cmp:COMPLEX_AGENT = EachIn list
				ag_cmp.update()
			Next
		Next
		
		'props
		For Local prop:AGENT = EachIn game.prop_list
			prop.update()
		Next
		'environmental emitters
		For Local em:EMITTER = EachIn game.environmental_emitter_list
			em.update()
			em.emit()
			em.prune()
		Next
		'environmental widgets
		For Local w:WIDGET = EachIn game.environmental_widget_list
			w.update()
		Next
		'doors (really just special environmental widgets)
		For Local list:TList = EachIn game.door_lists
			For Local d:DOOR = EachIn list
				d.update()
			Next
		Next
		'health bits
		For Local w:WIDGET = EachIn health_bits
			w.update()
			If w.state_index_cur = 1 Then w.unmanage()
		Next
		
	End If
	
End Function
'______________________________________________________________________________
Function update_drawing_origin()
	If game.human_participation And game.player <> Null
		game.mouse.x = game.player.pos_x + (2.0 * (mouse.pos_x - window_w/2.0))
		game.mouse.y = game.player.pos_y + (2.0 * (mouse.pos_y - window_h/2.0))
		Select game.player_brain.input_type
			Case CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
				game.drawing_origin.x = window_w/2.0 - (game.player.pos_x + game.mouse.x)/2.0
				game.drawing_origin.y = window_h/2.0 - (game.player.pos_y + game.mouse.y)/2.0
			Case CONTROL_BRAIN.INPUT_KEYBOARD
				game.drawing_origin.x = window_w/2 - game.player.pos_x
				game.drawing_origin.y = window_h/2 - game.player.pos_y
		End Select
		'camera constraints; enforce
		If      game.drawing_origin.x < game.origin_min_x Then game.drawing_origin.x = game.origin_min_x ..
		Else If game.drawing_origin.x > game.origin_max_x Then game.drawing_origin.x = game.origin_max_x
		If      game.drawing_origin.y < game.origin_min_y Then game.drawing_origin.y = game.origin_min_y ..
		Else If game.drawing_origin.y > game.origin_max_y Then game.drawing_origin.y = game.origin_max_y
	End If
End Function
'______________________________________________________________________________
Function update_flags()
	'global state flag updates
	If game And game.auto_reset_spawners
		If game.active_friendly_spawners <= 0 And game.active_friendly_units <= 0
			game.reset_spawners( ALIGNMENT_FRIENDLY )
		End If
		If game.active_hostile_spawners <= 0 And game.active_hostile_units <= 0
			game.reset_spawners( ALIGNMENT_HOSTILE )
		End If
	End If
	'flag updates for games with human participation
	If game.human_participation
		'waiting on player to start
		If game.waiting_for_player_to_enter_arena
			'player not entered arena
			If game.player.dist_to( game.player_spawn_point ) < SPAWN_POINT_POLITE_DISTANCE
				If game.player_engine_running
					game.open_doors( ALIGNMENT_FRIENDLY )
				End If
			Else 'player entered arena
				game.player_in_locker = False
				game.waiting_for_player_to_enter_arena = False
				game.open_doors( ALIGNMENT_HOSTILE )
				game.battle_in_progress = True
				game.battle_state_toggle_ts = now()
				game.waiting_for_player_to_exit_arena = True
				game.spawn_enemies = True
			End If
		End If
		'enemies all dead
		If game.battle_in_progress And game.active_hostile_spawners = 0 And game.hostile_agent_list.Count() = 0
			game.game_in_progress = False
			game.battle_in_progress = False
			game.battle_state_toggle_ts = now()
			game.close_doors( ALIGNMENT_HOSTILE )
			game.spawn_enemies = False
			play_sound( get_sound( "victory" ))
		End If
		'player death
		If game.player.dead() 'player just died? (omgwtf)
			game.game_in_progress = False
			game.game_over = True
			game.player_engine_running = False
			tweak_engine_idle()
			damage_incurred = True
		End If
	End If
End Function


