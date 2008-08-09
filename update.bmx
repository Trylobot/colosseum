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
		
		'level/game logic
		If FLAG_waiting_for_player_to_enter_arena And player.pos_y <= player_spawn_point.pos_y - (arena_offset/2.0)
			FLAG_waiting_for_player_to_enter_arena = False
			FLAG_battle_in_progress = True
		End If
		If level_enemies_remaining = 0
			FLAG_waiting_for_player_to_exit_arena = True
			FLAG_battle_in_progress = False
		End If
		If FLAG_waiting_for_player_to_exit_arena And player.pos_y >= player_spawn_point.pos_y
			FLAG_waiting_for_player_to_exit_arena = False
			FLAG_player_in_locker = True
		End If
		
		For Local w:WIDGET = EachIn environmental_widget_list
			w.update() 
		Next
		
		'spawning (safe to use any time)
		spawn_next_enemy()
		
		'control brains (human + ai)
		For Local cb:CONTROL_BRAIN = EachIn control_brain_list
			cb.update()
			cb.prune()
		Next
		
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

		'friendlies
		For Local friendly:COMPLEX_AGENT = EachIn friendly_agent_list
			friendly.update()
		Next

		'hostiles
		For Local hostile:COMPLEX_AGENT = EachIn hostile_agent_list
			hostile.update()
		Next
		
	End If
End Function


