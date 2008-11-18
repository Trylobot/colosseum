Rem
	debug.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

?Debug
''______________________________________________________________________________
Global debug_origin:cVEC = cVEC.Create( 0, 0 )
Global real_origin:cVEC = cVEC.Create( 0, 0 )
Const SPAWN_OFF% = 0, SPAWN_HOSTILES% = 1, SPAWN_FRIENDLIES% = 2
Global FLAG_spawn_mode% = SPAWN_OFF
Global spawn_archetype% = enemy_index_start, spawn_agent:COMPLEX_AGENT
Global global_start:CELL, global_goal:CELL
'Global maus_x#, maus_y#, speed# = 1, r#, a#, px#, py#
'Global wait_ts%, wait_time%, r%, c%, mouse:CELL
'Const PATH_UNSET% = 1000
'Global path_type% = PATH_UNSET, mouse_path_type%
'Global p:POINT = Create_POINT( arena_offset+arena_w/2, arena_offset+arena_h/2, -90 )
'Global w:WIDGET[] = New WIDGET[2]
'w[0] = widget_archetype[WIDGET_ARENA_DOOR].clone(); w[0].parent = p; w[0].attach_at( arena_offset/2, -arena_offset/2, 180 - 45 )
'w[1] = widget_archetype[WIDGET_ARENA_DOOR].clone(); w[1].parent = p; w[1].attach_at( arena_offset/2, arena_offset/2, 180 + 45 )
'
''______________________________________________________________________________
'Function debug_ts( message$ )
'	DebugLog "" + now() + " :: " + message
'End Function
'
'______________________________________________________________________________
Global sx%, sy%

Function debug_drawtext( message$, h% = 10 )
	SetImageFont( get_font( "consolas_10" ))
	SetAlpha( 1 )
	Local r%, g%, b%
	GetColor( r, g, b )
	SetColor( 0, 0, 0 )
	DrawText( message, sx+1, sy+1 )
	SetColor( r, g, b )
	DrawText( message, sx, sy )
	sy :+ h
End Function
'______________________________________________________________________________
Function debug_drawline( arg1:Object, arg2:Object, a_msg$ = "", b_msg$ = "", m_msg$ = "" )
	'decl.
	Local a:cVEC = New cVEC, b:cVEC = New cVEC, m:cVEC = New cVEC
	'init.
	If( cVEC(arg1) )
		a = cVEC(arg1)
	Else
		Local p:POINT = POINT(arg1)
		a.x = p.pos_x; a.y = p.pos_y
	End If
	If( cVEC(arg2) )
		b = cVEC(arg2)
	Else
		Local p:POINT = POINT(arg2)
		b.x = p.pos_x; b.y = p.pos_y
	End If
	m.x = (a.x+b.x)/2
	m.y = (a.y+b.y)/2
	'draw
	DrawLine( a.x,a.y, b.x,b.y )
	DrawOval( a.x-2,a.y-2, 5,5 )
	DrawOval( b.x-2,b.y-2, 5,5 )
	DrawOval( m.x-2,m.y-2, 5,5 )
	'messages
	SetImageFont( get_font( "consolas_10" ))
	DrawText( a_msg, Int(a.x+2),Int(a.y+2) )
	DrawText( b_msg, Int(b.x+2),Int(b.y+2) )
	DrawText( m_msg, Int(m.x+2),Int(m.y+2) )
End Function
'______________________________________________________________________________
Function debug_fps()
	SetOrigin( 0, 0 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetColor( 255, 255, 127 )
	SetImageFont( get_font( "consolas_bold_24" ))
	sx = window_w - TextWidth( String.FromInt( fps ))
	sy = window_h - GetImageFont().Height() - 30
	DrawText( String.FromInt( fps ), sx, sy )
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
Global cb:CONTROL_BRAIN = Null

Function debug_overlay()
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetOrigin( 0, 0 )
	
	sx = 2; sy = 2
	
'	If cb <> Null
'		'keyboard help
'		debug_drawtext( "[1]: set target to player" )
'		debug_drawtext( "[2]: get path to target" )
'		debug_drawtext( "[3]: see target" )
'		debug_drawtext( "[4]: player path to mouse" )
'	End If
	debug_drawtext( "("+debug_origin.x+","+debug_origin.y+")", 18 )
	debug_drawtext( "enemies "+game.hostile_agent_list.Count() )
	Local sp:SPAWNER, cur:CELL, ts%, last:COMPLEX_AGENT, counter%, str$
	debug_drawtext( "spawners "+game.lev.spawners.Length )
	For Local i% = 0 To game.lev.spawners.Length-1
		sp = game.lev.spawners[i]
		cur = game.spawn_cursor[i]
		ts = game.spawn_ts[i]
		last = game.last_spawned[i]
		counter = game.spawn_counter[i]
		If     ( sp.alignment = ALIGNMENT_FRIENDLY ) SetColor( 127, 127, 255 ) ..
		Else If( sp.alignment = ALIGNMENT_HOSTILE )  SetColor( 255, 127, 127 )
		str = " sp["+i+"] "+counter+"/"+sp.size+" "
		'if this spawner has more enemies to spawn
		If counter < sp.size
			str :+ "ACTIVE"
'		Else
'			str :+ ""
		End If
		debug_drawtext( str )
	Next
	
	If game <> Null
		SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
	End If
	
	SetColor( 255, 255, 255 )
	'show pathing grid divisions
	SetAlpha( 0.20 )
	For Local i% = 0 To game.lev.horizontal_divs.length - 1
		DrawLine( 0,0+game.lev.horizontal_divs[i], 0+game.lev.width,0+game.lev.horizontal_divs[i] )
	Next
	For Local i% = 0 To game.lev.vertical_divs.length - 1
		DrawLine( 0+game.lev.vertical_divs[i],0, 0+game.lev.vertical_divs[i],0+game.lev.height )
	Next

	SetColor( 255, 255, 255 )
	
	If KeyHit( KEY_Q )
		cb = Null
		For Local brain:CONTROL_BRAIN = EachIn game.control_brain_list
			If brain.avatar.dist_to_cVEC( game.mouse ) <= 15
				cb = brain
				Exit
			End If
		Next
	Else
		For Local brain:CONTROL_BRAIN = EachIn game.control_brain_list
			If brain.avatar.dist_to_cVEC( game.mouse ) <= 15
				SetColor( 255, 255, 255 )
				SetAlpha( 0.333 )
				DrawOval( brain.avatar.pos_x-15,brain.avatar.pos_y-15, 30,30 )
			End If
		Next
	End If
	
	If cb <> Null
		
		'manipulate by keyboard
		If KeyDown( KEY_1 )
			cb.target = game.player
		End If
		If KeyDown( KEY_2 )
			cb.path = cb.get_path_to_target()
		End If
		If KeyDown( KEY_3 )
			'cb.sighted_target = cb.see_target()
			'cb.see_target_DEBUG()
		End If
		If KeyDown( KEY_4 )
			game.player_brain.path = game.find_path( game.player.pos_x, game.player.pos_y, game.mouse.x, game.mouse.y )
		End If
		
		'draw info
		sx = game.mouse.x + 16; sy = game.mouse.y
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
			Local av:cVEC = cVEC( cVEC.Create( cb.avatar.pos_x, cb.avatar.pos_y ))
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
	
	If KeyHit( KEY_QUOTES )
		game.spawn_pickup( mouse.x, mouse.y )
	End If
	
	If KeyHit( KEY_9 )
		FLAG_retain_particles = True
		If KeyDown( KEY_0 )
			FLAG_dim_bg = True
		End If
	End If
	
	If KeyHit( KEY_P )
		FLAG_spawn_mode :+ 1
		If FLAG_spawn_mode > 2 Then FLAG_spawn_mode = 0
	End If
	If FLAG_spawn_mode <> SPAWN_OFF
		If spawn_agent = Null
			spawn_agent = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[spawn_archetype] ))
		End If
		spawn_agent.pos_x = game.mouse.x; spawn_agent.pos_y = game.mouse.y
		spawn_agent.ang = spawn_agent.ang_to( game.player ) + 180
		spawn_agent.update()
		spawn_agent.snap_all_turrets()
		If FLAG_spawn_mode = SPAWN_HOSTILES
			spawn_agent.draw( 255, 127, 127 )
		Else 'FLAG_spawn_mode = SPAWN_FRIENDLIES
			spawn_agent.draw( 127, 127, 255 )
		End If
		If KeyHit( KEY_ENTER )
			If FLAG_spawn_mode = SPAWN_HOSTILES
				spawn_agent.manage( game.hostile_agent_list )
			Else 'FLAG_spawn_mode = SPAWN_FRIENDLIES
				spawn_agent.manage( game.friendly_agent_list )
			End If
			Local agent_brain:CONTROL_BRAIN = Create_CONTROL_BRAIN( spawn_agent, CONTROL_BRAIN.CONTROL_TYPE_AI,, 10, 1000, 1000 )
			agent_brain.manage( game.control_brain_list )
			spawn_agent = Null
		Else If KeyHit( KEY_OPENBRACKET )
			spawn_archetype :- 1
			If spawn_archetype < enemy_index_start Then spawn_archetype = complex_agent_archetype.Length - 1
			spawn_agent = Null
		Else If KeyHit( KEY_CLOSEBRACKET )
			spawn_archetype :+ 1
			If spawn_archetype > complex_agent_archetype.Length - 1 Then spawn_archetype = enemy_index_start
			spawn_agent = Null
		End If
	End If
	
End Function
'______________________________________________________________________________
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
'Function draw_widget_debug()
'	
'	SetRotation( 0 )
'	SetLineWidth( 2 )
'	For Local w:WIDGET = EachIn w
'		
'		Local w_off:pVEC = w.widget_offset()
'		Local w_st:pVEC = w.state_offset()
'		
'		Local v:cVEC[] = New cVEC[20]
'		v[0] = cVEC( cVEC.Create( p.pos_x, p.pos_y ))
'		v[1] = cVEC( cVEC.Create( v[0].x + w_off.x(), v[0].y + w_off.y() ))
'		v[2] = cVEC( cVEC.Create( v[1].x + w_st.x(), v[1].y + w_st.y() ))
'		
'		Local color%[] = [ ..
'		127, ..
'		196, ..
'		255 ]
'		
'		For Local i% = 1 To v.Length - 1
'			If v[i] = Null Then Exit
'			DrawOval( v[i-1].x-4,v[i-1].y-4, 8,8 )
'			SetColor( color[i-1], color[i-1], color[i-1] )
'			DrawLine( v[i-1].x,v[i-1].y, v[i].x,v[i].y )
'			DrawOval( v[i].x-4,v[i].y-4, 8,8 )
'		Next
'	Next
'	
'	If KeyDown( KEY_P )
'		If MouseDown( 1 )
'			w[0].attach_at( MouseX()-p.pos_x, MouseY()-p.pos_y, w[0].ang_offset )
'		Else If MouseDown( 2 )
'			w[1].attach_at( MouseX()-p.pos_x, MouseY()-p.pos_y, w[1].ang_offset )
'		End If
'	Else If KeyDown( KEY_A )
'		If MouseDown( 1 )
'			w[0].ang_offset = MouseX()
'		Else If MouseDown( 2 )
'			w[1].ang_offset = MouseX()
'		End If
'	End If
'	
'	If KeyHit( KEY_W )
'		For Local w:WIDGET = EachIn w
'			w.begin_transformation( 1 )
'		Next
'	End If
'	
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
