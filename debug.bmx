Rem
	debug.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'main.bmx --> Include "debug.bmx"

'//////////////////////////////////////////////////////////////////////////////
'new stuff to be tested or fixed

Function debug_audio_drivers()
	DebugLog " AudioDrivers() -->"
	For Local drv$ = EachIn AudioDrivers()
		DebugLog "    " + drv
	Next
End Function

'//////////////////////////////////////////////////////////////////////////////

'debug system infrastructure & hooks
Global debug_origin:cVEC = Create_cVEC( 0, 0 )
Global real_origin:cVEC = Create_cVEC( 0, 0 )
Global global_start:CELL
Global global_goal:CELL

Global FLAG_debug_overlay% = False
Global FLAG_god_mode% = False
Global fps%, last_frame_ts%, time_count%, frame_count%
Global f12_down%

Global spawn_archetype_index% = 0
Global spawn_archetype$ = ""
Global spawn_alignment% = POLITICAL_ALIGNMENT.NONE
Global spawn_agent:COMPLEX_AGENT
Global cb:CONTROL_BRAIN = Null

Function debug_init()
	'debug_audio_drivers()
	'debug_get_keys()
	DebugLog( "_____________________________________________________" )
End Function

Function debug_no_graphics()
	'debug_set_range()
	'debug_remove_from_array()
	'debug_insert_into_array()
	'debug_array_append
	'End
End Function

Function debug_with_graphics()
	'debug_graffiti_manager
	'End
End Function

Function debug_main()
	frame_count :+ 1
	time_count :+ (now() - last_frame_ts)
	last_frame_ts = now()
	If time_count >= 1000
		fps = frame_count
		frame_count = 0
		time_count = 0
	End If
	If KeyHit( KEY_TILDE )
		FLAG_debug_overlay = Not FLAG_debug_overlay
		FlushKeys()
	End If
	If KeyHit( KEY_G )
		FLAG_god_mode = Not FLAG_god_mode
	End If
	If KeyHit( KEY_F4 ) And main_game
		main_game.retained_particle_count = active_particle_limit
	End If
	If game <> Null And FLAG_debug_overlay
		debug_overlay()
		debug_fps()
	End If
	If profile
		If KeyDown( KEY_NUMADD )
			profile.cash :+ 1
		Else If KeyDown( KEY_NUMSUBTRACT )
			If profile.cash > 0 Then profile.cash :- 1
		End If
		get_current_menu().update()
	End If
	If game And game.player And FLAG_god_mode
		game.player.cur_health = game.player.max_health
	End If
	'If KeyDown( KEY_F4 ) Then DebugStop
End Function

Function debug_overlay()
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	sx = 2; sy = 2
	
	'basic info 
	'SetColor( 255, 255, 255 )
	'debug_drawtext( "       active_particle_limit "+active_particle_limit )
	'debug_drawtext( "game.retained_particle_count "+game.retained_particle_count )
	'SetColor( 127, 127, 255 )
	'debug_drawtext( "   friendly units "+game.active_friendly_units )
	'debug_drawtext( "friendly spawners "+game.active_friendly_spawners )
	'SetColor( 255, 127, 127 )
	'debug_drawtext( "    hostile units "+game.active_hostile_units )
	'debug_drawtext( " hostile spawners "+game.active_hostile_spawners )
	
	If game <> Null
		SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
	End If
	sx = game_mouse.x + 16; sy = game_mouse.y
	
	'show pathing grid divisions
	SetColor( 255, 255, 255 )
	SetAlpha( 0.04 )
	SetLineWidth( 1 )
	For Local i% = 0 To game.lev.horizontal_divs.length - 1
		DrawLine( 0,0+game.lev.horizontal_divs[i], 0+game.lev.width,0+game.lev.horizontal_divs[i] )
	Next
	For Local i% = 0 To game.lev.vertical_divs.length - 1
		DrawLine( 0+game.lev.vertical_divs[i],0, 0+game.lev.vertical_divs[i],0+game.lev.height )
	Next
	
	'graffiti manager
	'If game And game.graffiti
	'	Local g:GRAFFITI_MANAGER = game.graffiti
	'	SetLineWidth( 2 )
	'	SetAlpha( 0.5 )
	'	SetColor( 255, 32, 32 )
	'	For Local r% = 0 Until g.rows
	'		For Local c% = 0 Until g.cols
	'			DrawRectLines( c * g.col_width, r * g.row_height, g.col_width, g.row_height )
	'		Next
	'	Next
	'End If

	'show particle bounding boxes
	SetColor( 255, 255, 255 )
	If game <> Null
		SetAlpha( 0.06 )
		Local dirty_rect:BOX
		For Local p:PARTICLE = EachIn game.retained_particle_list
			dirty_rect = p.get_bounding_box()
			DrawRectLines( dirty_rect.x, dirty_rect.y, dirty_rect.w, dirty_rect.h )
		Next
	End If

	SetColor( 255, 255, 255 )
	
	Local closest_cb:CONTROL_BRAIN = Null
	Local dist%, closest_dist% = 15
	For Local brain:CONTROL_BRAIN = EachIn game.control_brain_list
		'closest avatar search
		dist = brain.avatar.dist_to( game_mouse )
		If dist < closest_dist
			closest_dist = dist
			closest_cb = brain
		End If
		'show forces
		For Local f:FORCE = EachIn brain.avatar.force_list
			If f.physics_type = PHYSICS_FORCE
				Local x# = brain.avatar.pos_x, y# = brain.avatar.pos_y
				Local ang# = f.direction + f.combine_ang_with_parent_ang*brain.avatar.ang
				SetLineWidth( 1 )
				SetAlpha( 0.2 )
				DrawLine( x, y, x + f.magnitude_cur*Cos(ang), y + f.magnitude_cur*Sin(ang) )
			End If
		Next
	Next
	
	'select control_brain/avatar for inspection
	If KeyHit( KEY_Q )
		cb = closest_cb
	Else If closest_cb <> Null
		DrawOval( closest_cb.avatar.pos_x-15,closest_cb.avatar.pos_y-15, 30,30 )
	End If
	
	'instantly kill avatar under cursor
	If KeyDown( KEY_K )
		game.kill( closest_cb )
	End If
	
	'cause an explosion under cursor via mini-bomb self detonation
	If KeyHit( KEY_SEMICOLON )
		Local bomb:COMPLEX_AGENT = get_unit( "mini_bomb" )
		bomb.move_to( game_mouse )
		agent_self_destruct( bomb )
	End If
	
	If KeyHit( KEY_C )
		If closest_cb <> Null
			Local p:PARTICLE = get_particle( "cash_from_kill" )
			p.str :+ closest_cb.avatar.cash_value
			p.str_update()
			p.pos_x = closest_cb.avatar.pos_x
			p.pos_y = closest_cb.avatar.pos_y - 20
			p.manage( game.particle_list_foreground )
		End If
	End If

	If KeyHit( KEY_QUOTES )
		game.spawn_pickup( game_mouse.x, game_mouse.y, 1.0 )
	End If
	
	If KeyHit( KEY_P )
		spawn_alignment :+ 1
		If spawn_alignment > 2 Then spawn_alignment = 0
		spawn_agent = Null
	End If
	If spawn_alignment <> POLITICAL_ALIGNMENT.NONE
		If spawn_agent = Null
			spawn_archetype = get_map_keys( unit_map )[spawn_archetype_index]
			spawn_agent = get_unit( spawn_archetype, spawn_alignment )
			spawn_agent.scale_all( 1.50 )
			spawn_agent.ang = Rand( 360 )
			spawn_agent.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE,, -spawn_agent.mass/100.0 )))
		End If
		spawn_agent.move_to( game_mouse, True )
		spawn_agent.update()
		spawn_agent.draw( 0.50, 1.50 )
		
		If KeyHit( KEY_O )
			game.spawn_unit( spawn_archetype, spawn_alignment, POINT( spawn_agent ))
			spawn_agent = Null
		Else If KeyHit( KEY_OPENBRACKET )
			spawn_archetype_index :- 1
			If spawn_archetype_index < 0 Then spawn_archetype_index = get_map_keys( unit_map ).Length-1
			spawn_agent = Null
		Else If KeyHit( KEY_CLOSEBRACKET )
			spawn_archetype_index :+ 1
			If spawn_archetype_index > get_map_keys( unit_map ).Length-1 Then spawn_archetype_index = 0
			spawn_agent = Null
		End If
	End If
	
	If cb <> Null And cb.managed()
		
		'manipulate by keyboard
		If KeyHit( KEY_T )
			game.player.unmanage()
			game.player = cb.avatar
			game.player_brain.avatar = game.player
			cb.unmanage()
		End If
		If KeyHit( KEY_X )
			If Not cb.avatar.is_deployed
				cb.avatar.deploy()
			Else
				cb.avatar.undeploy()
			End If
		End If
		
		'draw info
		debug_drawtext( cb.avatar.name )
		If cb.target <> Null
			debug_drawtext( "target -> " + cb.target.name )
		Else 'cb.target == Null
			debug_drawtext( "no target" )
		End If
		If cb.can_see_target
			debug_drawtext( "can see target" )
			SetColor( 255, 255, 255 )
		Else
			debug_drawtext( "no line-of-sight to target" )
			SetColor( 255, 32, 32 )
		End If
		If cb.target <> Null
			SetLineWidth( 1 )
			SetAlpha( 0.5 )
			DrawLine( cb.avatar.pos_x,cb.avatar.pos_y, cb.target.pos_x,cb.target.pos_y )
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
		End If
		
		'pathing
		If cb.path <> Null And Not cb.path.IsEmpty()
			debug_drawtext( "path to target displayed" )
			'start and goal
			Local cell_size% = 8
			Local START:cVEC = cVEC( cb.path.First() )
			Local goal:cVEC = cVEC( cb.path.Last() )
			SetColor( 64, 255, 64 ); SetAlpha( 0.5 )
			DrawRect( start.x - cell_size/2 + 1, start.y - cell_size/2 + 1, cell_size - 2, cell_size - 2 )
			SetColor( 64, 64, 255 ); SetAlpha( 0.5 )
			DrawRect( goal.x - cell_size/2 + 1, goal.y - cell_size/2 + 1, cell_size - 2, cell_size - 2 )
			'path
			Local v0:cVEC, v1:cVEC
			SetColor( 255, 255, 255 )
			For Local v1:cVEC = EachIn cb.path
				If v0 <> Null Then DrawLine( v0.x,v0.y, v1.x,v1.y ) Else v0 = New cVEC
				v0.x = v1.x; v0.y = v1.y
			Next
		Else
			debug_drawtext( "no path" )
		End If
		
		'friendly fire
		If cb.target <> Null And cb.avatar.turrets <> Null
			SetLineWidth( 1 )
			SetColor( 196, 196, 196 )
			SetAlpha( 0.20 )
			Local av:cVEC = Create_cVEC( cb.avatar.pos_x, cb.avatar.pos_y )
			Local allied_agent_list:TList = CreateList()
			Select cb.avatar.alignment
				Case POLITICAL_ALIGNMENT.FRIENDLY
					allied_agent_list = game.friendly_agent_list
				Case POLITICAL_ALIGNMENT.HOSTILE
					allied_agent_list = game.hostile_agent_list
			End Select
			Local ally_offset#, ally_offset_ang#
			Local scalar_projection#
			For Local ally:COMPLEX_AGENT = EachIn allied_agent_list
				'if the line of sight of the avatar is too close to the ally
				ally_offset = cb.avatar.turrets[0].dist_to( ally )
				ally_offset_ang = cb.avatar.turrets[0].ang_to( ally )
				scalar_projection = ally_offset*Cos( ally_offset_ang - cb.avatar.turrets[0].ang )
				SetColor( 196, 196, 196 )
				DrawLine( av.x,av.y, av.x+scalar_projection*Cos(cb.avatar.turrets[0].ang),av.y+scalar_projection*Sin(cb.avatar.turrets[0].ang) )
				
				If vector_length( ..
				(ally.pos_x - av.x+scalar_projection*Cos(cb.avatar.turrets[0].ang)), ..
				(ally.pos_y - av.y+scalar_projection*Sin(cb.avatar.turrets[0].ang)) ) ..
				< CONTROL_BRAIN.friendly_blocking_scalar_projection_distance
					SetColor( 255, 127, 127 )
				End If
				DrawLine( ally.pos_x,ally.pos_y, av.x+scalar_projection*Cos(cb.avatar.turrets[0].ang),av.y+scalar_projection*Sin(cb.avatar.turrets[0].ang) )
			Next
		End If
			
	End If
	
End Function

Function debug_fps()
	SetOrigin( 0, 0 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetColor( 255, 255, 127 )
	SetImageFont( get_font( "consolas_bold_12" ))
	Local fps_str$ = "fps "+fps
	sx = window_w - TextWidth( fps_str ) - 1
	sy = window_h - GetImageFont().Height() - 1
	DrawText_with_outline( fps_str, sx, sy )
End Function

Global sx%, sy%
Function debug_drawtext( message$, h% = 10 )
	Local r%, g%, b%
	SetRotation( 0 )
	SetScale( 1, 1 )
	GetColor( r%, g%, b% )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.65 )
	SetImageFont( get_font( "consolas_10" ))
	DrawRect( sx, sy, TextWidth( message + " " ), TextHeight( message ))
	SetAlpha( 1 )
	SetColor( r, g, b )
	DrawText_with_outline( message, sx, sy )
	sy :+ h
End Function

Function debug_drawline( arg1:Object, arg2:Object, a_msg$ = Null, b_msg$ = Null, m_msg$ = Null )
	'decl.
	Local a:cVEC = New cVEC, b:cVEC = New cVEC, m:cVEC = New cVEC
	'init.
	If cVEC(arg1)
		a = cVEC(arg1)
	Else If point(arg1)
		Local p:POINT = POINT(arg1)
		a.x = p.pos_x; a.y = p.pos_y
	Else
		Return
	End If
	If cVEC(arg2) 
		b = cVEC(arg2)
	Else If point(arg2)
		Local p:POINT = POINT(arg2)
		b.x = p.pos_x; b.y = p.pos_y
	Else
		Return
	End If
	m.x = (a.x+b.x)/2
	m.y = (a.y+b.y)/2
	'draw
	SetLineWidth( 3)
	SetAlpha( 0.5 )
	DrawLine( a.x,a.y, b.x,b.y )
	SetLineWidth( 1 )
	SetAlpha( 1 )
	'DrawOval( a.x-2,a.y-2, 5,5 )
	'DrawOval( b.x-2,b.y-2, 5,5 )
	'DrawOval( m.x-2,m.y-2, 5,5 )
	''messages
	'SetImageFont( get_font( "consolas_10" ))
	'DrawText( a_msg, Int(a.x+2),Int(a.y+2) )
	'DrawText( b_msg, Int(b.x+2),Int(b.y+2) )
	'DrawText( m_msg, Int(m.x+2),Int(m.y+2) )
End Function

Function print_array( name$, arr%[] )
	Local str$ = "["
	For Local i% = 0 Until arr.Length
		If i > 0 Then str :+ ","
		str :+ String.FromInt( arr[i] )
	Next
	str :+ "]"
	DebugLog " " + name + " = " + str
End Function

