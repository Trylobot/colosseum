Rem
	debug.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'main.bmx --> Include "debug.bmx"

?Debug

Global FLAG_debug_overlay% = False

'//////////////////////////////////////////////////////////////////////////////

Function debug_pre_load()
	'debug_audio_drivers()
	'debug_get_keys()
	'debug_set_range()
	'debug_remove_from_array()
	'debug_insert_into_array()
	'debug_array_append
	'test_find_files()
	
End Function

Function debug_pre_main()
	'test_draw_rect_lines()
	'show_me()
	'play_debug_level()
	'debug_graffiti_manager
	'test_draw_kill_tally()
	'play_debug_level()
  'test_bmp_fonts()
  'test_ui_list()
	'test_tweens
	level_editor()
End Function

Function debug_main()
	'enable/disable debug overlays
	If KeyHit( KEY_TILDE )
		FLAG_debug_overlay = Not FLAG_debug_overlay
		'FlushKeys()
	End If
	If KeyHit( KEY_G )
		FLAG_god_mode = Not FLAG_god_mode
	End If
	If game And FLAG_debug_overlay
		'SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
		'game.physics_viewer.Draw()
		'debug_draw_wall_flashes()
		SetOrigin( 0, 0 )
		debug_overlay()
		debug_fps()
		If KeyHit( KEY_R )
			game.respawn_player()
		End If
	End If
	If profile
		If KeyDown( KEY_NUMADD )
			profile.cash :+ 1
		Else If KeyDown( KEY_NUMSUBTRACT )
			If profile.cash > 0 Then profile.cash :- 1
		End If
		'get_current_menu().update()
	End If
	If game And game.player And FLAG_god_mode
		game.player.cur_health = game.player.max_health
	End If
	'If KeyDown( KEY_F4 ) Then DebugStop
End Function

'//////////////////////////////////////////////////////////////////////////////

'debug system infrastructure & hooks
Global debug_origin:cVEC = Create_cVEC( 0, 0 )
Global real_origin:cVEC = Create_cVEC( 0, 0 )
Global global_start:CELL
Global global_goal:CELL

Global FLAG_god_mode% = False
Global fps%, last_frame_ts%, time_count%, frame_count%
Global f12_down%

Global spawn_archetype_index% = 0
Global spawn_archetype$ = ""
Global spawn_alignment% = POLITICAL_ALIGNMENT.NONE
Global spawn_agent:COMPLEX_AGENT
Global cb:CONTROL_BRAIN = Null

Function play_debug_level()
	Local lev:LEVEL = load_level( "levels/debug.level.json" )
	'Local player:COMPLEX_AGENT = get_player_vehicle( "light_tank" )
	Local player:COMPLEX_AGENT = get_unit( "machine_gun_quad" )
	main_game = play_level( lev, player )
	game = main_game
	player.move_to( Create_POINT( 0.45*lev.width, 0.5*lev.height, 0 ))
	player.snap_all_turrets()
	player_has_entered_arena()
	game.spawn_unit( "machine_gun_emplacement", POLITICAL_ALIGNMENT.HOSTILE, Create_POINT( 0.55*lev.width, 0.5*lev.height, 0.0 ))
	game.sandbox = True
End Function

Function test_tweens()
	Cls
	Local tw:TWEEN[] = New TWEEN[9]
	Local i% = 0
	'linear
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.linear_ease ); i :+ 1
	tw[i] = Null; i :+ 1
	tw[i] = Null; i :+ 1
	'quadratic
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.quadratic_ease_in ); i :+ 1
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.quadratic_ease_out ); i :+ 1
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.quadratic_ease_in_out ); i :+ 1
	'sinusoidal
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.sinusoidal_ease_in ); i :+ 1
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.sinusoidal_ease_out ); i :+ 1
	tw[i] = TWEEN.Create( 0.0, 1.0, 1.0, TWEEN.sinusoidal_ease_in_out ); i :+ 1
	Local cols% = Int( Ceil( Sqr( Double( tw.Length ))))
	Local rows% = cols
	Local margin% = 3
	Local width% = SETTINGS_REGISTER.WINDOW_WIDTH.get()/cols
	Local height% = SETTINGS_REGISTER.WINDOW_HEIGHT.get()/rows
	Local width_inset% = width - margin
	Local height_inset% = height - margin
	i = 0
	For Local row% = 0 Until rows
		For Local col% = 0 Until cols
			If tw[i]
				Local x_left% = col*width + margin
				Local y_top% = row*height + margin
				SetViewport( x_left - 1, y_top - 1, width, height )
				SetColor( 127, 127, 127 )
				DrawRect( x_left, y_top, width_inset, height_inset )
				SetColor( 255, 255, 255 ) 
				DrawRectLines( x_left, y_top, width_inset, height_inset, 1 )
				SetColor( 0, 0, 0 )
				For Local t! = 0.0 To 1.0 Step 0.0025
					Local x# = x_left + t*width_inset
					Local y# = y_top + (height_inset - tw[i].get( t )*height_inset)
					DrawOval( x-1.5, y-1.5, 3, 3 )
				Next
			End If
			i :+ 1
			If i >= tw.Length Then Exit
		Next
		If i >= tw.Length Then Exit
	Next
	Flip
	WaitMouse
	End
End Function

Function test_draw_rect_lines()
	SetColor( 255, 255, 255 )
	Repeat
		Cls
		DrawRectLines( 0,   0,  50, 20, 1 )
		DrawRectLines( 50,  20, 50, 20, 2 )
		DrawRectLines( 100, 40, 50, 20, 3 )
		DrawRectLines( 150, 60, 50, 20, 4 )
		DrawRectLines( 200, 80, 50, 20, 5 )
		Flip
	Until AppTerminate() Or KeyHit( KEY_ESCAPE )
	End
End Function

Function test_ui_list()
  
	Local list1:TUIList = New TUIList
	list1.Construct( ..
    "test", 5, ..
		[ 127, 127, 127 ], [ 255, 255, 255 ], [ 0, 0, 0 ], [ 255, 255, 255 ], ..
		2, ..
		"arcade_21", "arcade_21_outline", ..
		[255, 255, 255], [0, 0, 0], ..
    "arcade_14", "arcade_14_outline", ..
		[255, 255, 255], [0, 0, 0], [0, 0, 0], [205, 205, 205], ..
		,,,, ..
		10, 10 )
	list1.set_item( 0, "item1", debug_ui_list_item_clicked, "1" )
	list1.set_item( 1, "item2", debug_ui_list_item_clicked, "2" )
	list1.set_item( 2, "item3", debug_ui_list_item_clicked, "3" )
	list1.set_item( 3, "item4", debug_ui_list_item_clicked, "4" )
	list1.set_item( 4, "item5", debug_ui_list_item_clicked, "5" )
  
  Repeat
    Cls
    list1.draw()
    list1.on_mouse_move( MouseX(), MouseY() )
    If MouseHit( 1 )
      list1.on_mouse_click( MouseX(), MouseY() )
    End If
    Flip
  Until KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_ENTER ) Or KeyHit( KEY_SPACE )
  End
  
End Function

Function debug_ui_list_item_clicked( item:Object )
  DebugLog( "list item clicked " + String(item) )
End Function

Function test_bmp_fonts()
	Local fg_font:BMP_FONT, bg_font:BMP_FONT
	Local x%, y% = 0, h%, t%, fg%, bg%
	Local test_str$ = " !~q#$%&'()*+,-./0123456789:;<=>?@~nABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`~nabcdefghijklmnopqrstuvwxyz{|}~~"
	Local size%[]
	SetClsColor( 127, 127, 127 )
	Cls
	size = [ 5, 10 ]
	For Local s% = 0 Until size.Length
		x = 2*size[s]/size[0]
		fg_font = get_bmp_font( "small_" + size[s] )
		bg_font = get_bmp_font( "small_" + size[s] + "_outline" )
		h = fg_font.height
		fg = 255
		bg = 0
		y :+ draw_layered_string( test_str, x, y, fg_font, bg_font, fg,fg,fg, bg,bg,bg ); y :+ 2*h
		y :+ draw_layered_string( reverse_string(test_str), x, y, fg_font, bg_font, fg,fg,fg, bg,bg,bg ); y :+ 2*h
	Next
	size = [ 7, 14 ]
	For Local s% = 0 Until size.Length
		x = 2*size[s]/size[0]
		fg_font = get_bmp_font( "arcade_" + size[s] )
		bg_font = get_bmp_font( "arcade_" + size[s] + "_outline" )
		h = fg_font.height
		fg = 255
		bg = 0
		y :+ draw_layered_string( test_str, x, y, fg_font, bg_font, fg,fg,fg, bg,bg,bg ); y :+ 2*h
		y :+ draw_layered_string( reverse_string(test_str), x, y, fg_font, bg_font, fg,fg,fg, bg,bg,bg ); y :+ 2*h
	Next
	Flip
	WaitKey
	End
End Function

Function show_me()
	Local veh:PAIR[] = map_to_array( player_vehicle_map )
	For Local p:PAIR = EachIn veh
		Local obj:Object = player_vehicle_map.ValueForKey( p.key )
	Next
End Function

Function debug_draw_wall_flashes()
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	For Local wall:BOX = EachIn debug_wall_flashes
		draw_box( wall, True )
	Next
	debug_wall_flashes.Clear()
End Function
Global debug_wall_flashes:TList = CreateList()

Function debug_overlay()
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	sx = 2; sy = 2
	
	'basic info 
	SetColor( 255, 255, 255 )
	'debug_drawtext( "wave " + game.hostile_spawner.current_wave )
	
	''profiler
	'For Local i% = 0 Until profiler_label.Length
	'	debug_drawtext( pad( profiler_label[i], 19,, True ) + pad( String.FromLong( profiler_value[i] ), 15,, True ))
	'Next
	
	If game <> Null
		SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
	End If
	
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
	
	'show unit factory status
	SetRotation( 0 )
	SetScale( 1, 1 )
	Local all_spawners:SPAWN_CONTROLLER[] = [ game.hostile_spawner, game.friendly_spawner ]
	Local uf:UNIT_FACTORY_DATA
	Local cur:CELL
	Local size% = 3, sep% = 1
	Local i%, r%, c%
	For Local spawner:SPAWN_CONTROLLER = EachIn all_spawners
		For i = 0 Until spawner.unit_factories.Length
			uf = spawner.unit_factories[i]
			cur = spawner.unit_factory_cursor[i]
			Select uf.alignment
				Case POLITICAL_ALIGNMENT.NONE
					SetColor( 255, 255, 255 )
				Case POLITICAL_ALIGNMENT.FRIENDLY
					SetColor( 64, 64, 255 )
				Case POLITICAL_ALIGNMENT.HOSTILE
					SetColor( 255, 64, 64 )
			End Select
			For r = 0 Until uf.count_squads()
				For c = 0 Until uf.count_squadmembers( r )
					'highlight the current squad (row)
					If r = cur.row
						SetAlpha( 1.0 )
					Else
						SetAlpha( 0.5 )
					End If
					'one square for each squadmember
					DrawRect( ..
						uf.pos.pos_x - 10 - c*(size+sep), ..
						uf.pos.pos_y + 10 + r*(size+sep), ..
						size, size )
				Next
			Next
		Next
	Next
	
	SetAlpha( 1 )
	SetColor( 255, 255, 255 )
	'for each unit
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
		'wheels
		'If brain.avatar.left_steering_wheel And brain.avatar.right_steering_wheel
		'	Local x# = brain.avatar.pos_x, y# = brain.avatar.pos_y
		'	Local ang# = f.direction + f.combine_ang_with_parent_ang*brain.avatar.ang
		'	SetLineWidth( 1 )
		'	SetAlpha( 0.2 )
		'	DrawLine( x, y, x + f.magnitude_cur*Cos(ang), y + f.magnitude_cur*Sin(ang) )
		'End If
	Next
	
	'select control_brain/avatar for inspection
	If KeyHit( KEY_Q )
		cb = closest_cb
	Else If closest_cb <> Null
		DrawOval( closest_cb.avatar.pos_x-15,closest_cb.avatar.pos_y-15, 30,30 )
	End If
	
	'cause an explosion under cursor via mini-bomb self detonation
	If KeyHit( KEY_K )
		Local bomb:COMPLEX_AGENT = get_unit( "mini_bomb" )
		bomb.move_to( game_mouse )
		agent_self_destruct( bomb )
	End If
	
	If KeyHit( KEY_C )
		If closest_cb
			Local p:PARTICLE = get_particle( "cash_from_kill" )
			If p
				p.str :+ closest_cb.avatar.cash_value
				p.str_update()
				p.pos_x = closest_cb.avatar.pos_x
				p.pos_y = closest_cb.avatar.pos_y - 20
				p.manage( game.particle_list_foreground )
			End If
		End If
	End If

	If KeyHit( KEY_QUOTES )
		game.spawn_pickup( game_mouse.x, game_mouse.y, 1.0 )
	End If
	
	If KeyHit( KEY_SEMICOLON )
		If      spawn_alignment <> 0 Then spawn_alignment = 0 ..
		Else If spawn_alignment = 0  Then spawn_alignment = 1
		spawn_agent = Null
	End If
	If KeyHit( KEY_P )
		If      spawn_alignment = 1 Then spawn_alignment = 2 ..
		Else If spawn_alignment = 2 Then spawn_alignment = 1
		spawn_agent = Null
	End If
	If spawn_alignment <> 0
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
		sx = cb.avatar.pos_x; sy = cb.avatar.pos_y + 25
		
		'manipulate by keyboard
		If KeyHit( KEY_T ) And game.human_participation
			If game.player_brain Then game.player_brain.unmanage()
			If game.player Then game.player.unmanage()
			cb.control_type = CONTROL_BRAIN.CONTROL_TYPE_HUMAN
			cb.input_type = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
			game.player_brain = cb
			game.player = cb.avatar
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
			debug_drawtext( "waypoint -> " + cb.dist_to_waypoint )
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
	
'	'projectile owners
'	For Local proj:PROJECTILE = EachIn game.projectile_list
'		find owner
'		For Local list:TList = EachIn game.agent_lists
'			For Local ag:AGENT = EachIn list
'				If proj.source_id = ag.id
'					DrawLine_awesome( proj.pos_x,proj.pos_y, ag.pos_x,ag.pos_y, True, 3, 1 )
'				End If
'			Next
'		Next
'	Next
	
End Function

Function DrawLine_awesome( x1#, y1#, x2#, y2#, balls% = True, outer_width% = 5, inner_width% = 2 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 0, 0, 0 )
	If balls
		DrawOval( x1 - 5, y1 - 5, 10, 10 )
		DrawOval( x2 - 5, y2 - 5, 10, 10 )
	End If
	SetLineWidth( outer_width )
	DrawLine( x1, y1, x2, y2 )
	SetColor( 255, 255, 255 )
	If balls
		DrawOval( x1 - 3, y1 - 3, 6, 6 )
		DrawOval( x2 - 3, y2 - 3, 6, 6 )
	End If
	SetLineWidth( inner_width )
	DrawLine( x1, y1, x2, y2 )
	SetLineWidth( 1 )
End Function

Function debug_fps()
	frame_count :+ 1
	time_count :+ (now() - last_frame_ts)
	last_frame_ts = now()
	If time_count >= 1000
		fps = frame_count
		frame_count = 0
		time_count = 0
	End If

	SetOrigin( 0, 0 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetColor( 255, 255, 127 )
	'SetImageFont( get_font( "consolas_bold_12" ))
	Local fps_str$ = "fps "+fps
	sx = 2
	sy = 2
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
	'SetImageFont( get_font( "consolas_10" ))
	DrawRect( sx, sy, TextWidth( message + " " ) + 1, h)
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
	''SetImageFont( get_font( "consolas_10" ))
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

Function print_PAIR_array( name$, arr:PAIR[] )
	Local str$ = "{"
	For Local i% = 0 Until arr.Length
		str :+ "~n~q" + arr[i].key + "~q: " + address(arr[i].value)
	Next
	str :+ "~n}"
	DebugLog " " + name + " = " + str
End Function

Function map_to_array:PAIR[]( map:TMap )
	Local list:TList = CreateList()
	Local size% = 0
	For Local key$ = EachIn map.Keys()
		list.AddLast( PAIR.Create( key, map.ValueForKey( key )))
		size :+ 1
	Next
	Local array:PAIR[] = New PAIR[ size ]
	Local i% = 0
	For Local p:PAIR = EachIn list
		array[i] = p
		i :+ 1
	Next
	Return array
End Function

Type PAIR
	Field key$
	Field value:Object

	Function Create:PAIR( key$, value:Object )
		Local p:PAIR= New pair
		p.key = key
		p.value = value
		Return p
	End Function
End Type

?

