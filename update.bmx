Rem
	update.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "core.bmx"
Import "timescale.bmx"
Import "flags.bmx"
Import "misc.bmx"
Import "hud.bmx"
Import "mouse.bmx"
Import "pickup.bmx"
Import "projectile.bmx"
Import "particle.bmx"
Import "control_brain.bmx"
Import "spawn_request.bmx"
Import "complex_agent.bmx"
Import "widget.bmx"
Import "transform_state.bmx"
Import "agent.bmx"
Import "particle_emitter.bmx"
Import "door.bmx"
Import "physical_object.bmx"
Import "force.bmx"

'______________________________________________________________________________
Global player_health_last# 'for producing choppy bits of health on the HUD

'Physics and Timing Update
Function update_all_objects()
	
	'update body
	If game And Not game.paused
		
		'set drawing origin
		update_drawing_origin()
		
		'count units in-game
		game.count_units()
		'player and game-state flags
		update_flags()
		If Not game Then Return 'possibility exists that game will be freed after updating the flags
		
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
			proj.emit( game.particle_list_background, game.particle_list_foreground )
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
			If FLAG.chat_mode And cb.control_type = CONTROL_BRAIN.CONTROL_TYPE_HUMAN
				cb.human_input_blocked_update()
			Else
				cb.update()
			End If
			'spawn unit request processing
			If cb.ai.is_carrier And Not cb.spawn_request_list.IsEmpty()
				For Local req:SPAWN_REQUEST = EachIn cb.spawn_request_list
					game.spawn_unit_from_request( req )
				Next
			End If
		Next
		'complex agents
		For Local list:TList = EachIn game.complex_agent_lists
			For Local ag_cmp:COMPLEX_AGENT = EachIn list
				ag_cmp.update()
				ag_cmp.emit( game.projectile_list, game.particle_list_background, game.particle_list_foreground )
				'self destruction flag (triggered by mini-bomb control brain)
				If ag_cmp.desire_self_destruction
					agent_self_destruct( ag_cmp )
				End If
			Next
		Next
		'player speed (for audio engine sound tweaking)
		last_known_player_speed = Sqr( Pow(game.player.vel_x,2) + Pow(game.player.vel_y,2) )
		'player life/health bar interaction
		If game.human_participation And game.player.cur_health <> player_health_last
			If game.player.cur_health < player_health_last
				'health bar chunk fall-off
				Local damage# = player_health_last - game.player.cur_health
				Local health_pct# = game.player.cur_health / game.player.max_health
				Local damage_pct# = damage / game.player.max_health
				Local bit:WIDGET = WIDGET( WIDGET.Create( create_rect_img( damage_pct * health_bar_w, health_bar_h - 3 ),,, REPEAT_MODE_LOOP_BACK, True ))
				bit.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 0.0,  0.0,   0, 255, 255, 255, 1.0,,, 500 )))
				bit.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( 6.0,-16.0,-3.0, 255,   0,   0, 0.0,,, 500 )))
				bit.parent = Create_POINT( get_image( "health_mini" ).width + 3, window_h - 2*(get_font( "consolas_bold_12" ).Height() + 3) + 2 )
				bit.attach_at( health_pct * health_bar_w, 2, 0, True )
				bit.manage( health_bits )
			End If
			player_health_last = game.player.cur_health
		End If
		
		'props
		For Local prop:AGENT = EachIn game.prop_list
			prop.update()
		Next
		'environmental emitters
		For Local em:PARTICLE_EMITTER = EachIn game.environmental_emitter_list
			em.update()
			em.emit( game.particle_list_background, game.particle_list_foreground )
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
		game_mouse.x = game.player.pos_x + (2.0 * (mouse.pos_x - window_w/2.0))
		game_mouse.y = game.player.pos_y + (2.0 * (mouse.pos_y - window_h/2.0))
		Select game.player_brain.input_type
			Case CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
				game.drawing_origin.x = window_w/2.0 - (game.player.pos_x + game_mouse.x)/2.0
				game.drawing_origin.y = window_h/2.0 - (game.player.pos_y + game_mouse.y)/2.0
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
			FLAG.engine_running = False
			FLAG.damage_incurred = True
		End If
	End If
End Function

'______________________________________________________________________________
Function update_meta_variable_cache()
	If Not meta_variable_cache
		meta_variable_cache = CreateMap()
	End If
	meta_variable_cache.Insert( "profile.name", profile.name )
	meta_variable_cache.Insert( "profile.cash", format_number( profile.cash ))
	meta_variable_cache.Insert( "profile.kills", format_number( profile.kills ))
	meta_variable_cache.Insert( "profile.invert_reverse_steering", boolean_to_string( profile.invert_reverse_steering ))
	meta_variable_cache.Insert( "level_editor_cache.name", level_editor_cache.name )
	meta_variable_cache.Insert( "fullscreen", boolean_to_string( fullscreen ))
	meta_variable_cache.Insert( "window_w", String.FromInt( window_w ))
	meta_variable_cache.Insert( "window_h", String.FromInt( window_h ))
	meta_variable_cache.Insert( "refresh_rate", String.FromInt( refresh_rate ))
	meta_variable_cache.Insert( "bit_depth", String.FromInt( bit_depth ))
	meta_variable_cache.Insert( "show_ai_menu_game", boolean_to_string( show_ai_menu_game ))
	meta_variable_cache.Insert( "retain_particles", boolean_to_string( retain_particles ))
	meta_variable_cache.Insert( "active_particle_limit", String.FromInt( active_particle_limit ))
	meta_variable_cache.Insert( "network_ip_address", network_ip_address )
	meta_variable_cache.Insert( "network_port", String.FromInt( network_port ))
	meta_variable_cache.Insert( "network_level", StripAll( network_level ))
	meta_variable_cache.Insert( "profile.count_inventory(this)", "(x ?)" ) 'tricky
End Function

'______________________________________________________________________________
Function agent_self_destruct( ag:AGENT )
	Local nearby_objects:TList = game.near_to( ag, 200.0 ) 'the "radius" argument should come from data
	Local damage#, total_force#
	For Local phys_obj:PHYSICAL_OBJECT = EachIn nearby_objects
		Local dist# = ag.dist_to( phys_obj ) 
		'damage
		damage = 150 'this should come from data
		If AGENT( phys_obj )
			game.deal_damage( AGENT( phys_obj ), damage / Pow(( 0.05 * dist + 2 ), 2 ))
		End If
		'explosive knock-back force & torque
		total_force = (phys_obj.mass * 750) / Pow( 0.5 * dist + 24, 2 ) - 5 'the maximum comes from data, and is modulated with the actual distance
		phys_obj.add_force( FORCE( FORCE.Create( PHYSICS_FORCE, ag.ang_to( phys_obj ), total_force, 100 )))
		phys_obj.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE,, Rnd( -2.0, 2.0 )*total_force, 100 )))
	Next
	'self-destruct explosion sound
	play_sound( get_sound( "cannon_hit" ),, 0.25 )
	
	'agent death effects
	ag.die( game.particle_list_background )
End Function

