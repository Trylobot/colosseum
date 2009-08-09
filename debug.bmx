Rem
	debug.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

?Debug
''______________________________________________________________________________
Global debug_origin:cVEC = Create_cVEC( 0, 0 )
Global real_origin:cVEC = Create_cVEC( 0, 0 )
Global global_start:CELL
Global global_goal:CELL
'______________________________________________________________________________
Function debug_ts( message$ )
	DebugLog "" + now() + " :: " + message
End Function
'______________________________________________________________________________
Function debug_init()
	'debug_get_keys()
End Function
'______________________________________________________________________________
Function debug_generate_level_mini_preview()
	Local lev:LEVEL = load_level( "levels/training1.colosseum_level" )
	Local img:TImage = generate_level_mini_preview( lev )
	save_pixmap_to_file( img.Lock( 0, True, False ), "training1_minipreview" )
End Function
'______________________________________________________________________________
Global FLAG_debug_overlay% = False
Global fps%, last_frame_ts%, time_count%, frame_count%
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
	If game <> Null And FLAG_debug_overlay
		debug_overlay()
		debug_fps()
		'debug_agent_lists()
	End If
	If profile
		If KeyDown( KEY_NUMADD )
			profile.cash :+ 1
		Else If KeyDown( KEY_NUMSUBTRACT )
			If profile.cash > 0 Then profile.cash :- 1
		End If
		get_current_menu().update()
	End If
	If KeyHit( KEY_F4 ) Then DebugStop
End Function
'______________________________________________________________________________
Function debug_get_map_keys()
	DebugLog " fonts: [ ~n  " + ",~n  ".Join( get_keys( font_map )) + " ]"
	DebugLog " sounds: [ ~n  " + ",~n  ".Join( get_keys( sound_map )) + " ]"
	DebugLog " images: [ ~n  " + ",~n  ".Join( get_keys( image_map )) + " ]"
	DebugLog " props: [ ~n  " + ",~n  ".Join( get_keys( prop_map )) + " ]"
	DebugLog " ai_types: [ ~n  " + ",~n  ".Join( get_keys( ai_type_map )) + " ]"
End Function
'______________________________________________________________________________
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
'______________________________________________________________________________
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
'______________________________________________________________________________
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
'______________________________________________________________________________
Function debug_agent_lists( to_console% = False )
	SetOrigin( 0, 0 )
	sx = 2; sy = 2
	For Local list:TList = EachIn main_game.agent_lists
		For Local ag:COMPLEX_AGENT = EachIn list
			If Not to_console
				debug_drawtext( ag.name + ":" + ag.id )
			Else
				DebugLog( ag.name + ":" + ag.id )
			End If
		Next
		If list <> main_game.agent_lists.Last()
			sy :+ 5
			SetColor( 127, 127, 127 )
			DrawLine( sx, sy, sx + 80, sy )
			sy :+ 5
		End If
	Next
End Function
'______________________________________________________________________________
Global spawn_archetype_index% = 0
Global spawn_archetype$ = ""
Global spawn_alignment% = ALIGNMENT_NONE
Global spawn_agent:COMPLEX_AGENT
Global cb:CONTROL_BRAIN = Null
Function debug_overlay()
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	sx = 2; sy = 2
	
	'basic info 
	SetColor( 255, 255, 255 )
	debug_drawtext( "       active_particle_limit "+active_particle_limit )
	debug_drawtext( "game.retained_particle_count "+game.retained_particle_count )
	SetColor( 127, 127, 255 )
	debug_drawtext( "   friendly units "+game.active_friendly_units )
	debug_drawtext( "friendly spawners "+game.active_friendly_spawners )
	SetColor( 255, 127, 127 )
	debug_drawtext( "    hostile units "+game.active_hostile_units )
	debug_drawtext( " hostile spawners "+game.active_hostile_spawners )
	
	If game <> Null
		SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
	End If
	sx = game.mouse.x + 16; sy = game.mouse.y
	
	SetColor( 255, 255, 255 )
	'show pathing grid divisions
	SetAlpha( 0.20 )
	SetLineWidth( 1 )
	For Local i% = 0 To game.lev.horizontal_divs.length - 1
		DrawLine( 0,0+game.lev.horizontal_divs[i], 0+game.lev.width,0+game.lev.horizontal_divs[i] )
	Next
	For Local i% = 0 To game.lev.vertical_divs.length - 1
		DrawLine( 0+game.lev.vertical_divs[i],0, 0+game.lev.vertical_divs[i],0+game.lev.height )
	Next

	'show particle bounding boxes
	If game <> Null
		SetAlpha( 0.08 )
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
		dist = brain.avatar.dist_to( game.mouse )
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
		bomb.move_to( game.mouse )
		bomb.self_destruct()
	End If
	
	If KeyHit( KEY_C )
		If closest_cb <> Null
			Local p:PARTICLE = get_particle( "cash_from_kill" )
			p.str :+ closest_cb.avatar.cash_value
			p.str_update()
			p.pos_x = closest_cb.avatar.pos_x
			p.pos_y = closest_cb.avatar.pos_y - 20
			p.auto_manage()
		End If
	End If

	If KeyHit( KEY_QUOTES )
		game.spawn_pickup( game.mouse.x, game.mouse.y, 1.0 )
	End If
	
	If KeyHit( KEY_P )
		spawn_alignment :+ 1
		If spawn_alignment > 2 Then spawn_alignment = 0
		spawn_agent = Null
	End If
	If spawn_alignment <> ALIGNMENT_NONE
		If spawn_agent = Null
			spawn_archetype = get_keys( unit_map )[spawn_archetype_index]
			spawn_agent = get_unit( spawn_archetype, spawn_alignment )
			spawn_agent.scale_all( 1.50 )
			spawn_agent.ang = Rand( 360 )
			spawn_agent.add_force( FORCE( FORCE.Create( PHYSICS_TORQUE,, -spawn_agent.mass/100.0 )))
		End If
		spawn_agent.move_to( game.mouse, True )
		spawn_agent.update()
		spawn_agent.draw( 0.50, 1.50 )
		
		If KeyHit( KEY_O )
			game.spawn_unit( spawn_archetype, spawn_alignment, POINT( spawn_agent ))
			spawn_agent = Null
		Else If KeyHit( KEY_OPENBRACKET )
			spawn_archetype_index :- 1
			If spawn_archetype_index < 0 Then spawn_archetype_index = get_keys( unit_map ).Length-1
			spawn_agent = Null
		Else If KeyHit( KEY_CLOSEBRACKET )
			spawn_archetype_index :+ 1
			If spawn_archetype_index > get_keys( unit_map ).Length-1 Then spawn_archetype_index = 0
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
			Select cb.avatar.political_alignment
				Case ALIGNMENT_FRIENDLY
					allied_agent_list = game.friendly_agent_list
				Case ALIGNMENT_HOSTILE
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

Function debug_kill_tally()
	kill_tally( "total kills",, 1 )
	kill_tally( "total kills",, 2 )
	kill_tally( "total kills",, 3 )
	kill_tally( "total kills",, 4 )
	kill_tally( "total kills",, 5 )
	kill_tally( "total kills",, 6 )
	kill_tally( "total kills",, 7 )
End Function

Function debug_print_profile_inventory()
	Local str$ = " profile.inventory_________________~n"
	For Local item:INVENTORY_DATA = EachIn profile.inventory
		str :+ "   "+item.to_string()+"~n"
	Next
	DebugLog str
	
End Function

''______________________________________________________________________________
'Function debug_doors()
'	Local spawn:POINT = Create_POINT( window_w/2, window_h/2 )
'	Local env:ENVIRONMENT = Create_ENVIRONMENT()
'	env.add_door( spawn, ALIGNMENT_FRIENDLY )
'	
'	Local before% = now()
'	Repeat
'		Cls()
'		
'		If KeyHit( KEY_ENTER )
'			env.toggle_doors( ALIGNMENT_FRIENDLY )
'		End If
'		If MouseDown( 1 )
'			spawn.move_to( Create_cVEC( MouseX(), MouseY() ))
'		End If
'		
'		If now() - before > time_per_frame_min
'			before = now()
'			For Local d:DOOR = EachIn env.friendly_door_list
'				d.update()
'			Next
'		End If
'		
'		For Local d:DOOR = EachIn env.friendly_door_list
'			d.draw_bg()
'			d.draw_fg()
'		Next
'		
'		Flip( 1 )
'	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
'	End
'End Function
''______________________________________________________________________________
'Function debug_dirtyrects()
'	Local o:cVEC = Create_cVEC( 0, 0 )
'	Local window_rect:BOX = Create_BOX( o.x, o.y, window_w, window_h )
'	Local mouse:cVEC
'
'	Local list:TList = CreateList()
'	Local bg_img:TImage = generate_sand_image( window_w, window_h )
'	Local retain_particles% = False
'	Local visible_particles%, hidden_particles%
'	SetImageFont( get_font( "consolas_12" ))
'	
'	Local before% = now()
'	Repeat
'		Cls()
'		
'		sx = 1 - o.x
'		sy = 1 - o.y
'		
'		mouse = Create_cVEC( MouseX(), MouseY() )
'		
'		If now() - before > time_per_frame_min
'			before = now()
'			
'			If KeyDown( KEY_RIGHT ) Then o.x :+ 2
'			If KeyDown( KEY_LEFT  ) Then o.x :- 2
'			If KeyDown( KEY_DOWN  ) Then o.y :+ 2
'			If KeyDown( KEY_UP    ) Then o.y :- 2
'			
'			SetOrigin( o.x, o.y )
'			window_rect = Create_BOX( -o.x, -o.y, window_w, window_h )
'			
'			If MouseDown( 1 )
'				Local p:PARTICLE = get_particle( "tank_tread_trail_medium" )
'				p.move_to( Create_cVEC( mouse.x - o.x, mouse.y - o.y ))
'				p.ang = Rnd( -180, 180 )
'				p.manage( list )
'			End If
'			
'			If KeyHit( KEY_ENTER )
'				retain_particles = True
'			End If
'			
'		End If
'		
'		SetAlpha( 1 )
'		SetColor( 255, 255, 255 )
'		SetRotation( 0 )
'		SetScale( 1, 1 )
'		DrawImage( bg_img, 0, 0 )
'		
'		visible_particles = 0
'		hidden_particles = 0
'		For Local p:PARTICLE = EachIn list
'			p.draw()
'			
'			Local dirty_rect:BOX = p.get_bounding_box()
'			If window_rect.contains( dirty_rect )
'				visible_particles :+ 1
'			Else
'				hidden_particles :+ 1
'			End If
'		Next
'		
'		If retain_particles
'			retain_particles = False
'			For Local p:PARTICLE = EachIn list
'				Local dirty_rect:BOX = p.get_bounding_box()
'				If window_rect.contains( dirty_rect )
'					'copy+paste pixmap into bg_img
'					Local dirty_rect_pixmap:TPixmap = GrabPixmap( dirty_rect.x + o.x, dirty_rect.y + o.y, dirty_rect.w, dirty_rect.h )
'					Local bg_img_pixmap:TPixmap = LockImage( bg_img )
'					bg_img_pixmap.Paste( dirty_rect_pixmap, dirty_rect.x, dirty_rect.y )
'					UnlockImage( bg_img )
'					p.unmanage()
'				End If
'			Next
'		End If
'		
'		If KeyDown( KEY_RSHIFT )
'			SetAlpha( 1 )
'			SetColor( 255, 255, 255 )
'			SetRotation( 0 )
'			SetScale( 1, 1 )
'			debug_drawtext( "visible particles "+visible_particles )
'			debug_drawtext( "hidden particles  "+hidden_particles )
'			
'			For Local p:PARTICLE = EachIn list
'				Local dirty_rect:BOX = p.get_bounding_box()
'				SetAlpha( 0.33333 )
'				DrawRectLines( dirty_rect.x, dirty_rect.y, dirty_rect.w, dirty_rect.h )
'			Next
'		End If
'		
'		Flip( 1 )
'	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
'	End
'End Function
''______________________________________________________________________________
'Function debug_widget()
'	Local list:TList = CreateList()
'	Local before% = now()
'	Local mouse:POINT = New POINT
'	
'	Local game:ENVIRONMENT = create_environment()
'	Local carrier:COMPLEX_AGENT = game.spawn_agent( ENEMY_INDEX_CARRIER, ALIGNMENT_HOSTILE, Create_POINT( window_w/2, window_h/3 )).avatar
'	
'	Local p:POINT = Create_POINT( window_w/2, 2*window_h/3 )
'	Local w:WIDGET
'	
'	w = WIDGET( WIDGET.Create( "blinker", create_rect_img( 25, 25, 12.5, 12.5 ),,,, False ))
'	w.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( ,,,,,, 0.5,,, 1000 )))
'	w.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( ,,,,,, 1.0,,, 1000 )))
'	w = w.clone()
'	w.parent = p
'	w.manage( list )
'
'	w = WIDGET( WIDGET.Create( "pump", create_rect_img( 15, 15, 7.5, 7.5 ),,,, False ))
'	w.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create(   0.0 ,,,,,,,,, 1000 )))
'	w.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( -35.0 ,,,,,,,,, 1000 )))
'	w = w.clone()
'	w.parent = p
'	w.attach_at( -35,,, true )
'	w.manage( list )
'	
'  w = WIDGET( WIDGET.Create( "hinged_door", create_rect_img( 50, 10, 5, 5 ),,,, False ))
'	w.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( -25.0 ,,  0.0,,,,,,, 1000 )))
'	w.add_state( TRANSFORM_STATE( TRANSFORM_STATE.Create( -25.0 ,, 90.0,,,,,,, 1000 )))
'	w = w.clone()
'	w.parent = p
'	w.attach_at( -10, -10,, true )
'	w.manage( list )
'	
'	Repeat
'		Cls()
'		
'		sx = 1; sy = 1
'		mouse.pos_x = MouseX(); mouse.pos_y = MouseY()
'		
'		If MouseDown( 1 )
'			'p.move_to( mouse )
'		End If
'		If KeyDown( KEY_LEFT )
'			'p.ang :+ 1
'		Else If KeyDown( KEY_RIGHT )
'			'p.ang :- 1
'		End If
'		If MouseHit( 2 )
'			For Local w:WIDGET = EachIn list
'				w.queue_transformation( 1 )
'			Next
'			carrier.deploy()
'		End If
'		
'		If (now() - before) > time_per_frame_min
'			before = now()
'			
'			For Local w:WIDGET = EachIn list
'				w.update()
'			Next
'			carrier.update()
'		End If
'		
'		Local i% = 0
'		For Local w:WIDGET = EachIn list
'			debug_drawline( create_cvec( w.get_x(), w.get_y() ), w.parent )
'			w.draw()
'			
'			SetColor( 255, 255, 255 )
'			SetAlpha( 1 )
'			SetRotation( 0 )
'			SetScale( 1, 1 )
'			debug_drawtext( "w["+i+"].state_index_cur "+w.state_index_cur )
'			
'			i :+ 1
'		Next
'		
'		carrier.draw()
'		
'		For Local list:TList = EachIn carrier.all_widget_lists
'			For Local w:WIDGET = EachIn list
'				debug_drawtext( "w.offset_ang="+w.offset_ang+" w.ang_offset="+w.ang_offset )
'			Next
'		Next
'		
'		Flip( 1 )
'	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
'	End
'End Function
''______________________________________________________________________________
'Function debug_spawner()
'	Local mouseP:POINT = New POINT
'	Local environmental_emitter_list:TList = CreateList()
'	Local agent_list:TList = CreateList()
'	Local particle_list_bg:TList = CreateList()
'	Local particle_list_fg:TList = CreateList()
'
'	Repeat
'		Cls()
'		
'		mouseP.pos_x = MouseX(); mouseP.pos_y = MouseY()
'		
'		If MouseHit( 1 )
'			Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[PLAYER_INDEX_LIGHT_TANK] ))
'			ag.manage( agent_list )
'			ag.spawn_at( mouseP, 1250 )
'			Local em:EMITTER = EMITTER( EMITTER.Copy( particle_emitter_archetype[PARTICLE_EMITTER_INDEX_SPAWNER] ))
'			em.manage( environmental_emitter_list )
'			em.parent = ag
'			em.attach_at( ,, 30,60, -180,180,,,,, -0.015,-0.025 )
'			em.enable( MODE_ENABLED_WITH_TIMER )
'			em.time_to_live = 1000
'			Local p:PARTICLE = get_particle( "soft_glow" )
'			p.red = 0.3; p.green = 0.3; p.blue = 0.9
'			p.manage( particle_list_fg )
'			p.move_to( ag )
'		End If
'		
'		For Local em:EMITTER = EachIn environmental_emitter_list
'			em.update()
'			em.emit( particle_list_bg )
'		Next
'		
'		For Local p:PARTICLE = EachIn particle_list_bg
'			p.update()
'			p.draw()
'			p.prune()
'		Next
'		For Local ag:COMPLEX_AGENT = EachIn agent_list
'			ag.update()
'			ag.draw()
'		Next
'		For Local p:PARTICLE = EachIn particle_list_fg
'			p.update()
'			p.draw()
'			p.prune()
'		Next
'		
'		Flip( 1 )
'	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
'	End
'End Function

'Global maus_x#, maus_y#, speed# = 1, r#, a#, px#, py#
'Global wait_ts%, wait_time%, r%, c%, mouse:CELL
'Const PATH_UNSET% = 1000
'Global path_type% = PATH_UNSET, mouse_path_type%
''______________________________________________________________________________
'Function debug_format_number()
'	Local i% = 1, n% = 0
'	While n <= 100000000
'		DebugLog "  case "+i+" -> format_number( "+n+" ) = "+format_number( n )
'		i :+ 1
'		If n = 0 Then n :+ 1 Else n :* 10
'	End While
'	End
'End Function
''______________________________________________________________________________
'Function debug_coordinate_overlay()
'	Local move_speed% = 1
'	If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT ) Then move_speed = 5
'	If      KeyDown( KEY_LEFT )  Then debug_origin.x :+ move_speed ..
'	Else If KeyDown( KEY_RIGHT ) Then debug_origin.x :- move_speed
'	If      KeyDown( KEY_UP )    Then debug_origin.y :+ move_speed ..
'	Else If KeyDown( KEY_DOWN )  Then debug_origin.y :- move_speed
'	
'	SetScale( 1, 1 )
'	SetRotation( 0 )
'	
'	'real origin -> game origin
'	SetOrigin( 0, 0 )
'	SetColor( 255, 255, 255 )
'	SetAlpha( 0.5 )
'	debug_drawline( real_origin, game.drawing_origin,, "("+Int(game.drawing_origin.x)+","+Int(game.drawing_origin.y)+")" )
'	''real origin -> player
'	'debug_drawline( real_origin, game.player )
'	''game origin -> player
'	'debug_drawline( game.drawing_origin, game.player )
'	
'	'crosshairs (show real screen center)
'	SetColor( 127, 127, 127 )
'	SetAlpha( 0.25 )
'	debug_drawline( cVEC.Create( window_w_half, 0 ), cVEC.Create( window_w_half, window_h ),,, "("+Int(debug_origin.x)+","+Int(debug_origin.y)+")")
'	debug_drawline( cVEC.Create( 0, window_h_half ), cVEC.Create( window_w, window_h_half ))
'	
'	'player -> mouse
'	SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
'	SetColor( 127, 255, 255 )
'	SetAlpha( 0.5 )
'	debug_drawline( game.player, game.mouse, "P", "M", "CENTER ME!" )
'
'End Function

''______________________________________________________________________________
''Function debug_load_data()
''	DebugLog( " debug load_data" )
''	For Local file_path$ = EachIn file_paths
''		DebugLog( " file_path -> "+file_path )
''	Next
''	For Local key$ = EachIn font_map.Keys()
''		Local font:TImageFont = get_font( key )
''		DebugLog( " font_map -> "+key+" -> { CountGlyphs():"+font.CountGlyphs()+", Height():"+font.Height()+" }" )
''	Next
''	For Local key$ = EachIn sound_map.Keys()
''		Local sound:TSound = get_sound( key )
''		Local db_str$ = "null"
''		If sound <> Null Then db_str = "loaded"
''		DebugLog( " sound_map -> "+key+" -> "+db_str )
''	Next
''	For Local key$ = EachIn image_map.Keys()
''		Local image:TImage = get_image( key )
''		DebugLog( " image_map -> "+key+" -> { size("+image.width+","+image.height+"), handle("+Int(image.handle_x)+","+Int(image.handle_y)+"), frames:"+image.frames.Length )
''	Next
''End Function
'______________________________________________________________________________

'Function debug_draw_walls()
'	Local lev:LEVEL = Create_LEVEL( 100, 100 )
'	lev.add_divider( 33, LINE_TYPE_HORIZONTAL )
'	lev.add_divider( 66, LINE_TYPE_HORIZONTAL )
'	lev.add_divider( 82, LINE_TYPE_HORIZONTAL )
'	lev.add_divider( 25, LINE_TYPE_VERTICAL )
'	lev.add_divider( 75, LINE_TYPE_VERTICAL )
'	lev.add_divider( 82, LINE_TYPE_VERTICAL )
'	lev.set_path_region( CELL.Create( 1, 1 ), PATH_BLOCKED )
'	lev.set_path_region( CELL.Create( 1, 2 ), PATH_BLOCKED )
'	lev.set_path_region( CELL.Create( 0, 1 ), PATH_BLOCKED )
'	lev.set_path_region( CELL.Create( 2, 1 ), PATH_BLOCKED )
'	lev.set_path_region( CELL.Create( 2, 2 ), PATH_BLOCKED )
'
'	Local img:TImage = generate_level_walls_image( lev )
'	Local scale# = 5.00
'	SetScale( scale,scale )
'	SetLineWidth( 1.00 )
'	Local origin:cVEC = cVEC.Create( 0, 0 )
'	Repeat
'		Cls
'
'		SetAlpha( 1.0 )
'		DrawImage( img, 0,0 )
'
'		SetAlpha( 0.333 )
'		For Local i% = 0 To lev.horizontal_divs.length - 1
'			DrawLine( origin.x,origin.y+scale*lev.horizontal_divs[i], origin.x+lev.width,origin.y+scale*lev.horizontal_divs[i] )
'		Next
'		For Local i% = 0 To lev.vertical_divs.length - 1
'			DrawLine( origin.x+scale*lev.vertical_divs[i],origin.y, origin.x+scale*lev.vertical_divs[i],origin.y+lev.height )
'		Next
'		
'		Flip
'	Until KeyHit( KEY_ESCAPE )
'	End
'End Function

''______________________________________________________________________________
'Function test_ang_wrap()
'	For Local i# = -750.0 To 750.0 Step 10
'		If Abs( ang_wrap( i )) > 180 Then debuglog( "ang_wrap() test failed" )
'	Next
'End Function
''______________________________________________________________________________
'Function debug_atan2()
'	For Local i% = 0 To 360
'		DebugLog "  ATan2( Sin("+i+"), Cos("+i+") ) -> "+ATan2( Sin(i), Cos(i) )
'	Next
'End Function
''______________________________________________________________________________
'Function debug_complex_agent_emitters()
'	sx = arena_offset + 3; sy = arena_offset + 3; h = 10
'	If player <> Null And Not FLAG_in_menu
'		debug_drawtext( player.drive_forward_emitters.Count() )
'		debug_drawtext( player.drive_backward_emitters.Count() )
'		debug_drawtext( player.death_emitters.Count() )
'	End If
'End Function
''______________________________________________________________________________
'Function debug_main()
'	Repeat
'		For Local w:WIDGET = EachIn w
'			w.update()
'		Next
'		Cls
'		draw_widget_debug()
'		For Local w:WIDGET = EachIn w
'			w.draw()
'		Next
'		Flip( 1 )
'	Until AppTerminate() Or KeyHit( KEY_ESCAPE )
'End Function
''______________________________________________________________________________
'Function debug_range()
'	Local r:RANGE_Int = New RANGE_Int
'	Local str$ = ""
'	
'	Print "( " + r.low + ", " + r.high + " )"
'	str = ""
'	For Local i% = 0 To 10
'		str :+ r.get() + " "
'	Next
'	Print str
'	
'	r.set( 1, 5 )
'	
'	Print "( " + r.low + ", " + r.high + " )"
'	str = ""
'	For Local i% = 0 To 10
'		str :+ r.get() + " "
'	Next
'	Print str
'	
'End Function
'______________________________________________________________________________
'Function debug_heap( message$ = "" )
'	SetColor( 255, 255, 255 )
'	SetRotation( 0 )
'	SetScale( 1, 1 )
'	SetAlpha( 1 )
'	
'	Local pq:PATH_QUEUE = pathing.potential_paths
'	Local tree:CELL[] = pathing.potential_paths.binary_tree
'
'	Local wait_ts% = now()
'	Local wait_time%
'	If KeyDown( KEY_F3 ) Then wait_time = 0 Else wait_time = 500
'	wait_time = 500
'
'	While ((now() - wait_ts) <= wait_time) And Not KeyHit( KEY_F3 )
'		
'		If KeyHit( KEY_ESCAPE ) Then End
'		If KeyDown( KEY_F4 ) Then wait_ts = now()
'		
'		Cls
'		
'		sx = 3; sy = 3
'		
'		'draw optional message
'		SetColor( 127, 127, 255 ); SetAlpha( 1 )
'		SetImageFont( get_font( "consolas_12" ))
'		DrawText( message, sx, sy ); sy :+ 11
'
'		SetImageFont( get_font( "consolas_10" ))
'		If tree[0] = Null Then SetColor( 64, 64, 64 ) ..
'		Else                   SetColor( 255, 255, 255 )
'		DrawText( heap_info( 0 ), sx, sy )
'		draw_heap( 0 )
'		
'		Flip
'		
'	End While
'End Function
'
'Function draw_heap( i% )
'	Local pq:PATH_QUEUE = pathing.potential_paths
'	Local tree:CELL[] = pathing.potential_paths.binary_tree
'	If i < pq.item_count
'		
'		If pq.left_child_i( i ) < pq.item_count
'			sx :+ 4; sy :+ 9
'			If tree[pq.left_child_i( i )] = Null Then                        SetColor( 64, 64, 64 ) ..
'			Else If pq.get_cost(i) > pq.get_cost( pq.left_child_i( i )) Then SetColor( 255, 127, 127 ) ..
'			Else                                                             SetColor( 255, 255, 255 )
'			DrawText( heap_info( pq.left_child_i( i )), sx, sy )
'			draw_heap( pq.left_child_i( i ))
'			
'			If pq.right_child_i( i ) < pq.item_count
'				sy :+ 9
'				If tree[pq.right_child_i( i )] = Null Then                        SetColor( 64, 64, 64 ) ..
'				Else If pq.get_cost(i) > pq.get_cost( pq.right_child_i( i )) Then SetColor( 255, 127, 127 ) ..
'				Else                                                              SetColor( 255, 255, 255 )
'				DrawText( heap_info( pq.right_child_i( i )), sx, sy )
'				draw_heap( pq.right_child_i( i ))
'			End If
'			
'			sx :- 4
'		End If
'		
'	End If
'End Function
'
'Function heap_info$( i% )
'	Local info$ = ""+i+" "
'	If pathing.potential_paths.binary_tree[i] <> Null
'		'info :+ Int( pathing.f( pathing.potential_paths.binary_tree[i] ))
'		info :+ Int( pathing.potential_paths.get_cost( i ))
'	Else 'tree[i] == Null
'		info :+ "null"
'	End If
'	If i = 0
'		info :+ " {ROOT}"
''	Else If pathing.potential_paths.left_child_i( i ) > pathing.potential_paths.item_count - 1
''		info :+ " {leaf}"
''	Else If i = pathing.potential_paths.item_count - 1
''		info :+ " {LAST}"
'	End If
'	Return info
'End Function
'
'Function debug_heap_indent%( i% )
'	Local indent% = 0
'	While i > 0
'		indent :+ 4
'		i = pathing.potential_paths.parent_i( i )
'	End While
'	Return indent
'End Function
''______________________________________________________________________________
''F4 to path from player to mouse; hold F4 to pause; hold F3 to fast-forward
'Function debug_pathing( message$ = "", done% = False )
'	SetColor( 255, 255, 255 )
'	SetRotation( 0 )
'	SetScale( 1, 1 )
'	SetAlpha( 1 )
'	
'	Local wait_ts% = now()
'	Local wait_time%
'	If KeyDown( KEY_F3 ) Then wait_time = 0 Else wait_time = 500
'
'	While (((now() - wait_ts) <= wait_time) And (Not done)) ..
'	Or (done And Not KeyHit( KEY_F2 ))
'		
'		If KeyHit( KEY_ESCAPE ) Then End
'		If KeyDown( KEY_F4 ) Then wait_ts = now()
'		
'		Local mouse:CELL = containing_cell( MouseX() - arena_offset, MouseY() - arena_offset )
'		If KeyDown( KEY_F5 )
'			pathing.set_grid( mouse, PATH_BLOCKED )
'		Else If KeyDown( KEY_F6 )
'			pathing.set_grid( mouse, PATH_PASSABLE )
'		End If
'		
'		Cls
'		
'		'draw debug help
'		SetColor( 255, 255, 255 ); SetAlpha( 1 )
'		SetImageFont( get_font( "consolas_12" ))
'		DrawText( "set_goal,find_path:F4  pause:F4/faster:F3  block:F5  clear:F6", 3, 3 )
'		'draw pathing_grid cell border lines
'		SetLineWidth( 1 ); SetColor( 32, 32, 32 ); SetAlpha( 1.00 )
'		For Local r% = 2 To pathing_grid_h - 2
'			DrawLine( arena_offset, r*cell_size, pathing_grid_w*cell_size - arena_offset, r*cell_size )
'		Next
'		For Local c% = 2 To pathing_grid_w - 2
'			DrawLine( c*cell_size, arena_offset, c*cell_size, pathing_grid_h*cell_size - arena_offset )
'		Next
'		Local cursor:CELL = New CELL
'		For cursor.row = 2 To pathing_grid_h - 3
'			For cursor.col = 2 To pathing_grid_w - 3
'				'draw pathing_grid contents
'				SetColor( 255, 255, 255 ); SetAlpha( 0.85 )
'				If pathing.grid( cursor ) = PATH_BLOCKED Then ..
'					DrawRect( cursor.col*cell_size + 1, cursor.row*cell_size + 1, cell_size - 2, cell_size - 2 )
'			Next
'		Next
'		For cursor = EachIn pathing.pathing_visited_list
'			'draw pathing_came_from
'			SetLineWidth( 1 ); SetColor( 255, 255, 255 ); SetAlpha( 0.5 )
'			If pathing.came_from( cursor ) <> Null Then ..
'				DrawLine( cursor.col*cell_size + cell_size/2, cursor.row*cell_size + cell_size/2, pathing.came_from( cursor ).col*cell_size + cell_size/2, pathing.came_from( cursor ).row*cell_size + cell_size/2 )
'			'draw pathing_visited
'			SetColor( 255, 212, 212 ); SetAlpha( 0.5 )
'			DrawRect( cursor.col*cell_size + 1, cursor.row*cell_size + 1, cell_size - 2, cell_size - 2 )
'		Next
'		''potential paths header
'		'SetAlpha( 1 ); SetImageFont( get_font( "consolas_10" ))
'		'SetColor( 127, 127, 127 )
'		'DrawText( "potential paths", arena_w + 4, 4 )
'		'sx = arena_offset + arena_w + 4
'		'sy = arena_offset
'		'SetImageFont( get_font( "consolas_10" ))
'		'If pathing.potential_paths.binary_tree[0] = Null Then SetColor( 64, 64, 64 ) Else SetColor( 255, 255, 255 )
'		'DrawText( heap_info( 0 ), sx, sy )
'		'draw_heap( 0 )
'		
'		'start and goal
'		If global_start <> Null
'			SetColor( 64, 255, 64 ); SetAlpha( 1 )
'			DrawRect( global_start.col*cell_size + 1, global_start.row*cell_size + 1, cell_size - 2, cell_size - 2 )
'		End If
'		If global_goal <> Null
'			SetColor( 64, 64, 255 ); SetAlpha( 1 )
'			DrawRect( global_goal.col*cell_size + 1, global_goal.row*cell_size + 1, cell_size - 2, cell_size - 2 )
'		End If
'		'draw optional message
'		SetColor( 255, 255, 255 ); SetAlpha( 1 )
'		SetImageFont( get_font( "consolas_12" ))
'		DrawText( message, 3, 15 )
'		
'		Flip
'		
'	End While
'End Function
''______________________________________________________________________________
'Function console_debug()
'	For Local i% = 0 To 360 Step 5
'		Print "round_to_nearest( " + i + ", 90 ) = " + round_to_nearest( i, 90 )
'	Next
'End Function
''______________________________________________________________________________
'Function visual_debug()
'	SetColor( 255, 255, 255 )
'	SetRotation( 0 )
'	SetScale( 1, 1 )
'	SetAlpha( 1 )
'	
''	sx = 4; sy = 4
''	h = 10
''	
''	SetImageFont( consolas_normal_12 )
''	debug_drawtext( "player.stickies " + player.stickies.Count() )
'	
''	Local length# = 30
''	SetLineWidth( 2 )
''	SetColor( 64, 127, 64 )
''	For Local p:PROJECTILE = EachIn projectile_list
''		For Local f:FORCE = EachIn p.force_list
''			DrawLine( p.pos_x, p.pos_y, p.pos_x + length*f.magnitude_cur*Cos( p.ang + f.direction ), p.pos_y + length*f.magnitude_cur*Sin( p.ang + f.direction ) )
''		Next
''	Next
'
''	debug_drawtext( "friendly agents " + friendly_agent_list.Count() )
''	debug_drawtext( "hostile agents " + hostile_agent_list.Count() )
'
'
''	SetColor( 127, 64, 64 ); DrawLine( c.x, c.y, c.x + c.vel_x*length, c.y + c.vel_y*length )
''	SetColor( 64, 127, 64 ); DrawLine( c.x, c.y, c.x + c.acc_x*length, c.y + c.acc_y*length )
''	SetColor( 64, 64, 127 ); DrawLine( c.x, c.y, c.x + Cos(c.ang)*length, c.y + Sin(c.ang)*length )
''	SetColor( 255, 127, 127 ); DrawLine( c.x, c.y, c.x + length*c.driving_force.control_pct*Cos(c.driving_force.direction + c.ang), c.y + length*c.driving_force.control_pct*Sin(c.driving_force.direction + c.ang) )
''	SetColor( 127, 255, 127 ); DrawLine( c.x, c.y, c.x + length*c.turning_force.control_pct*Cos(c.ang + 90),                        c.y + length*c.turning_force.control_pct*Sin(c.ang + 90) )
''	px :+ speed * KeyDown( KEY_RIGHT ) - speed * KeyDown( KEY_LEFT )
''	py :+ speed * KeyDown( KEY_DOWN ) - speed * KeyDown( KEY_UP )
''	maus_x = MouseX() - arena_offset
''	maus_y = MouseY() - arena_offset
''	
''	a = vector_diff_angle( px, py, maus_x, maus_y )
''	r = vector_diff_length( px, py, maus_x, maus_y )
''	
''	SetLineWidth( 1 )
''	SetColor( 127, 255, 127 ); DrawLine( px, py, px + r*Cos(a), py + r*Sin(a) )
''
''	SetColor( 255, 127, 127 ); DrawLine( px, py, px + 30*Cos(avatar.turrets[0].ang), avatar.y + 30*Sin(avatar.turrets[0].ang) )
''	SetColor( 255, 127, 127 ); DrawLine( avatar.x, avatar.y, avatar.x + 30*Cos(avatar.turrets[0].ang), avatar.y + 30*Sin(avatar.turrets[0].ang) )
''	SetColor( 127, 255, 127 ); DrawLine( avatar.x, avatar.y, avatar.x + dist_to_target*Cos(dist_to_target), avatar.y + dist_to_target*Sin(dist_to_target) )
''
''	SetColor( 255, 255, 255 )
'
'	
''	Local p:COMPLEX_AGENT = player, t:TURRET = p.turrets[0]
''	DrawText( "tur.proj_em.offset " + em.offset, sx, sy ); sy :+ h
''	DrawText( "tur.proj_em.offset_ang " + em.offset_ang, sx, sy ); sy :+ h
''	DrawText( "ammo (main) " + t.cur_ammo + "/" + t.max_ammo, sx, sy); sy :+ h
''	sy :+ h
''	SetColor( 220, 30, 30 ); SetImageFont( consolas_normal_12 )
''	DrawText( "particles " + (particle_list_background.Count() + particle_list_foreground.Count()), sx, sy ); sy :+ h
''	DrawText( "retained_particles " + retained_particle_list.Count(), sx, sy ); sy :+ h
''	DrawText( "emitters " + emitter_list.Count(), sx, sy ); sy :+ h
''	DrawText( "projectiles " + (friendly_projectile_list.Count() + hostile_projectile_list.Count()), sx, sy ); sy :+ h
''	DrawText( "enemies " + enemy_list.Count(), sx, sy ); sy :+ h
''	DrawText( "pickups " + pickup_list.Count(), sx, sy ); sy :+ h
''	sy :+ h
'	
''	SetColor( 255, 20, 20 )
''	SetLineWidth(2)
''	Local x#[3], y#[3], i%
''	
''	x[0] = em.parent.x
''	x[1] = em.parent.x + em.offset * Cos( em.parent.ang + em.offset_ang )
''	x[2] = em.parent.x + em.offset * Cos( em.parent.ang + em.offset_ang )
''	
''	y[0] = em.parent.y
''	y[1] = em.parent.y + em.offset * Sin( em.parent.ang + em.offset_ang )
''	y[2] = em.parent.y + em.offset * Sin( em.parent.ang + em.offset_ang )
''	
''	For i = 0 To x.Length - 2
''		DrawLine( x[i], y[i], x[i+1], y[i+1] )
''	Next
'
'
'
''	DrawText( "projectiles " + projectile_list.Count(), offset, offset + 10*line ); line :+ 1
''	DrawText( "particles " + particle_list.Count(), offset, offset + 10*line ); line :+ 1
''	DrawText( DEBUG_COUNTER, offset, offset + 10*line ); line :+ 1
''	DrawText( test_timer.Ticks(), offset, offset + 10*line ); line :+ 1
''	If Not particle_list.IsEmpty()
''		Local p:PARTICLE = PARTICLE(particle_list.Last())
''		DrawText( "--- latest particle ---", offset, offset + 10*line ); line :+ 1
''		Local L% = p.life_time
''		DrawText( "life_time       L = " + L, offset, offset + 10*line ); line :+ 1
''		Local C% = now()
''		DrawText( "clock           C = " + C, offset, offset + 10*line ); line :+ 1
''		Local T% = p.created_ts
''		DrawText( "created_ts      T = " + T, offset, offset + 10*line ); line :+ 1
''		
''		DrawText( "              C-T = " + (C-T), offset, offset + 10*line ); line :+ 1
''		DrawText( "          C-T > L = " + ((C-T) > L), offset, offset + 10*line ); line :+ 1
''	End If
''	DrawText( display_name + ".x       " + x, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".y       " + y, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".vel_x       " + vel_x, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".vel_y       " + vel_y, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".ang         " + ang, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".ang_vel     " + ang_vel, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".tur_ang     " + tur_ang, x, line*10 + y ); line :+ 1
''	DrawText( display_name + ".tur_ang_vel " + tur_ang_vel, x, line*10 + y ); line :+ 1
''	SetLineWidth(2)
''	For Local i% = 0 To 3
''		If player.tread_debris_emitter[i].alive()
''			DrawText( "emitter " + i + " active", offset, i * 10 + offset )
''			DrawLine( player.x, player.y, player.x + player.tread_debris_emitter[i].offset * Cos( player.tread_debris_emitter[i].offset_ang + player.ang ), player.y + player.tread_debris_emitter[i].offset * Sin( player.tread_debris_emitter[i].offset_ang + player.ang ))
''		End If
''	Next
''	
''	SetLineWidth(2)
''	Local x#[3], y#[3], i%
''	
''	x[0] = p.x
''	x[1] = p.x + t.offset * Cos( t.offset_ang + p.ang )
''	x[2] = p.x + t.offset * Cos( t.offset_ang + p.ang ) + t.muz_offset * Cos( t.muz_offset_ang + p.ang + t.ang )
''	
''	y[0] = p.y
''	y[1] = p.y + t.offset * Sin( t.offset_ang + p.ang )
''	y[2] = p.y + t.offset * Sin( t.offset_ang + p.ang ) + t.muz_offset * Sin( t.muz_offset_ang + p.ang + t.ang )
''	
''	For i = 0 To x.Length - 2
''		DrawLine( x[i], y[i], x[i+1], y[i+1] )
''	Next
''	For i = 0 To x.Length - 1
''		DrawText( "x" + i + " = " + x[i], offset, offset + 10*line ); line :+ 1
''		DrawText( "y" + i + " = " + y[i], offset, offset + 10*line ); line :+ 1
''	Next
'	
''	Print "0 Mod 360 = " + 0 Mod 360 + "; should be 0"
''	Print "90 Mod 360 = " + 90 Mod 360 + "; should be 90"
''	Print "180 Mod 360 = " + 180 Mod 360 + "; should be 180"
''	Print "270 Mod 360 = " + 270 Mod 360 + "; should be 270"
''	Print "359 Mod 360 = " + 359 Mod 360 + "; should be 359"
''	Print "360 Mod 360 = " + 360 Mod 360 + "; should be 0"
''	Print "540 Mod 360 = " + 540 Mod 360 + "; should be 180"
''	Print "720 Mod 360 = " + 720 Mod 360 + "; should be 0"
''	Print "-90 Mod 360 = " + (-90) Mod 360 + "; should be 270"
''	Print "-180 Mod 360 = " + (-180) Mod 360 + "; should be 180"
''	Print "-270 Mod 360 = " + (-270) Mod 360 + "; should be 90"
''	Print "-359 Mod 360 = " + (-359) Mod 360 + "; should be 1"
''	Print "-360 Mod 360 = " + (-360) Mod 360 + "; should be 0"
''	Print "-540 Mod 360 = " + (-540) Mod 360 + "; should be 180"
''	Print "-720 Mod 360 = " + (-720) Mod 360 + "; should be 0"
'
'End Function
?

