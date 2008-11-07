Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Background cached texture
Global FLAG_retain_particles% = False
Const retained_particle_limit% = 500
Global FLAG_dim_bg% = False
Const cursor_blink% = 500
Global str$

'______________________________________________________________________________
'Drawing to Screen
Function draw_all_graphics()
	SetBlend( ALPHABLEND )
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )

	If FLAG_in_menu
		draw_main_screen()
		If game <> Null
			draw_game()
		End If
	Else If FLAG_in_shop
		draw_shop()
	Else If game <> Null
		draw_game()
	End If
	
End Function

'Function draw_loading()
'	draw_percentage_bar( window_w/5,window_h/5, 3*window_w/5,3*window_w/5, loaded_pct )
'End Function
'______________________________________________________________________________
'In-game stuff
Function draw_game()
	
	SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
	'SetViewport( game.drawing_origin.x, game.drawing_origin.y, game.lev.width, game.lev.height )
	
	'arena (& retained particles)
	SetBlend( ALPHABLEND )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	draw_arena_bg()

	'background particles
	For Local part:PARTICLE = EachIn game.particle_list_background
		part.draw()
	Next
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	
	'props
	For Local prop:AGENT = EachIn game.prop_list
		prop.draw()
	Next
	
	'projectiles
	For Local proj:PROJECTILE = EachIn game.projectile_list
		proj.draw()
	Next
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	
	'pickups
	For Local pkp:PICKUP = EachIn game.pickup_list
		pkp.draw()
	Next
	SetAlpha( 1 )

	'arena foreground
	draw_arena_fg()
	draw_lighting_and_effects()
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'complex agents
	For Local list:TList = EachIn game.complex_agent_lists
		For Local ag_cmp:COMPLEX_AGENT = EachIn list
			ag_cmp.draw()
		Next
	Next
	
	'foreground particles
	For Local part:PARTICLE = EachIn game.particle_list_foreground
		part.draw()
	Next
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'SetViewport( 0, 0, window_w, window_h )

	draw_reticle()
	SetRotation( 0 )

	If game.human_participation
		'player tips
		Local player_msg$ = Null
		SetImageFont( get_font( "consolas_12" ))
		If Not game.player_engine_running
			player_msg = "[E] engine ignition"
		Else If game.player_in_locker And game.waiting_for_player_to_enter_arena
			player_msg = "[W] drive forward"
		Else If Not game.battle_in_progress And game.waiting_for_player_to_exit_arena
			player_msg = "[R] return to loading bay"
		End If
		If player_msg <> Null
			DrawText_with_shadow( player_msg, game.player.pos_x - TextWidth( player_msg )/2, game.player.pos_y + game.player.img.height + 3 )
		End If
	End If

	SetOrigin( 0, 0 )
	
	If game.human_participation
		'hud
		draw_HUD()
	
		'help screen
		If FLAG_draw_help
			SetColor( 0, 0, 0 )
			SetAlpha( 0.550 )
			DrawRect( 0, 0, window_w, window_h )
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
			If profile.input_method = INPUT_KEYBOARD
				DrawImage( img_help_kb, window_w/2 - img_help_kb.width/2, window_h/2 - img_help_kb.height/2 )
			Else If profile.input_method = INPUT_KEYBOARD_MOUSE_HYBRID
				DrawImage( img_help_kb_mouse, window_w/2 - img_help_kb_mouse.width/2, window_h/2 - img_help_kb_mouse.height/2 )
			End If
		End If
	End If

	'game over indicator (if game over)
	If game.game_over
		SetColor( 0, 0, 0 )
		SetAlpha( 0.65 )
		DrawRect( 0, 0, window_w, window_h )
		SetAlpha( 1 )
		SetColor( 0, 0, 0 )
		SetScale( 1, 1 )
		SetImageFont( get_font( "consolas_bold_100" ))
		Local w% = TextWidth( "GAME OVER" )
		Local h% = GetImageFont().Height()
		DrawText( "GAME OVER", window_w/2 - w/2, window_h/2 - h/2 )
		SetColor( 255, 0, 0 )
		Local scale# = 0.85
		SetScale( scale, scale )
		DrawText( "GAME OVER", window_w/2 - scale*w/2, window_h/2 - scale*h/2 )
	End If
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	
End Function
'______________________________________________________________________________
'Menu and GUI
Function draw_main_screen()
	Local x%, y%, h%
	
	'title
	x = 25; y = 25
	SetColor( 255, 255, 127 )
	SetImageFont( get_font( "consolas_bold_50" ))
	DrawText_with_glow( My.Application.AssemblyInfo, x, y )
	
	'copyright stuff
	SetColor( 157, 157, 157 )
	SetImageFont( get_font( "consolas_10" ))
	h = 0.75*GetImageFont().Height()
	x = 1
	y = window_h - h*2 - 1
	DrawText( "Colosseum (c) 2008 Tyler W.R. Cole, aka Tylerbot; music by NickPerrin; json binding by grable", x, y ); y :+ h
	DrawText( "special thanks to Kaze, SniperAceX, Firelord88; written in 100% BlitzMax", x, y ); y :+ h
	
	'menu options
	x = 30; y = 95
	draw_menus( x, y )
	
End Function
'______________________________________________________________________________
Function draw_menus( x%, y%, tabbed_view% = True )
	If tabbed_view 'new "tabbed" menu drawing method
		SetAlpha( 1 )
		Local cx% = x, cy% = y
		Local w% = 20, h% = 14
		Local border% = 3
		For Local i% = 0 To current_menu
			Local m:MENU = get_menu( menu_stack[i] )
			If i < current_menu
				SetColor( 64, 64, 64 )
				DrawRect( cx, cy, w, h )
				SetColor( m.red/2, m.green/2, m.blue/2 )
				DrawRect( cx+border, cy+border, w-border*2, h-border*2 )
				cx :+ w-border
			Else 'i == current_menu
				cx = x
				cy = y
				If i > 0
					cy :+ h-border
				End If
				m.draw( cx, cy )
			End If
		Next
	Else 'older "menu stack" menu drawing method
		'calculate menu overlay alphas
		Local menu_overlay_alpha#[] = New Float[current_menu+1]
		Local alpha# = 0.0
		For Local i% = current_menu To 0 Step -1
			menu_overlay_alpha[i] = alpha
			alpha :+ 0.5 * (1 - alpha)
		Next
		'draw menus
		For Local i% = 0 To current_menu
			SetAlpha( 1 )
			SetColor( 255, 255, 255 )
			get_menu( menu_stack[i] ).draw( x + i*20, y + i*20,, menu_overlay_alpha[i])
		Next
	End If
	SetAlpha( 1 )
End Function
'______________________________________________________________________________
Function draw_arena_bg()
	'this first check tweaks the origin, if the retain_particles flag is set.
	'it is necessary because GrabImage only operates on integer coordinates.
	'so, if it will be called, the origin for this frame only will be truncated to the nearest integer.
	'this may result in a bit of a "skip" onscreen, but I can live with that.
	'the alternative is that GrabImage will get a fucked-up version of the canvas and look horrible ever after. 
	If FLAG_retain_particles
		Local x#, y#
		GetOrigin( x, y )
		SetOrigin( Int(x), Int(y) )
	End If

	'draw arena background cache image
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	DrawImage( game.background_clean, 0.0, 0.0 )
	DrawImage( game.background_dynamic, 0.0, 0.0 )

	'draw particles to be retained
	For Local part:PARTICLE = EachIn game.retained_particle_list
		part.draw()
	Next

	'if an arbitrary performance threshold is reached, ..
	' save backbuffer to dynamic texture, and delete retained particles
	If FLAG_retain_particles
		'delete retained particles
		FLAG_retain_particles = False
		game.retained_particle_list.Clear()
		game.retained_particle_list_count = 0
		
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetRotation( 0 )
		'save backbuffer to dynamic texture
		GrabImage( game.background_dynamic, game.drawing_origin.x, game.drawing_origin.y )
		
		'fade-out particles if desired, by blending backbuffer with the "clean" background
		If FLAG_dim_bg
			FLAG_dim_bg = False
			
			SetColor( 255, 255, 255 )
			SetAlpha( 0.3333 )
			SetScale( 1, 1 )
			SetRotation( 0 )
			'draw the clean background, again
			DrawImage( game.background_clean, 0.0, 0.0 )
			
			'save backbuffer to dynamic texture, again
			GrabImage( game.background_dynamic, game.drawing_origin.x, game.drawing_origin.y )
		End If
	End If
		
End Function
'______________________________________________________________________________
Function draw_arena_fg()
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	
	DrawImage( game.foreground, 0, 0 )
	'DrawPixmap( game.foreground, 0, 0 )

	For Local w:WIDGET = EachIn game.environmental_widget_list
		w.draw()
	Next
End Function

Function draw_lighting_and_effects()
	'use battle_toggle_ts and arena_lights_fade_time to set alpha
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.4*time_alpha_pct( game.battle_state_toggle_ts, arena_lights_fade_time, Not game.battle_in_progress ))
	DrawRect( 0,0, game.lev.width,game.lev.height )
	
	SetBlend( LIGHTBLEND )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.2*time_alpha_pct( game.battle_state_toggle_ts, arena_lights_fade_time, Not game.battle_in_progress ))
	If game.player <> Null
		SetScale( 1, 1 )
		DrawImage( img_halo, game.player.pos_x, game.player.pos_y )
	End If
	If game.player_spawn_point <> Null
		SetScale( 2, 2 )
		DrawImage( img_halo, game.player_spawn_point.pos_x, game.player_spawn_point.pos_y+15.0 )
	End If
	SetBlend( ALPHABLEND )
End Function

'______________________________________________________________________________
Global last_pos:POINT
Global lag_aimer:cVEC

Function draw_reticle()
	If game.human_participation
		If game.player.turret_list.Count() <> 0
			Local p_tur:TURRET = TURRET( game.player.turret_list.First() )
			
			If profile.input_method = INPUT_KEYBOARD_MOUSE_HYBRID
				'lag-behind reticle
				'initialization
				If last_pos = Null Then last_pos = Copy_POINT( p_tur )
				If lag_aimer = Null Then lag_aimer = cVEC.Create( p_tur.pos_x + 50*Cos( p_tur.ang ), p_tur.pos_y + 50*Sin( p_tur.ang ) )
				Local ang_to_mouse# = p_tur.ang_to_cVEC( game.mouse )
				Local dist_from_lag_aimer_to_mouse# = vector_diff_length( lag_aimer.x, lag_aimer.y, game.mouse.x, game.mouse.y )
				Local dist_to_ptur# = p_tur.dist_to_cVEC( lag_aimer )
				lag_aimer.x :+ p_tur.pos_x - last_pos.pos_x
				lag_aimer.y :+ p_tur.pos_y - last_pos.pos_y
				last_pos = Copy_POINT( p_tur )
				'if angle of separation is not too close to zero
				If Abs( ang_wrap( p_tur.ang - ang_to_mouse )) > (40.0 / dist_from_lag_aimer_to_mouse)
					lag_aimer = intersection( lag_aimer, game.mouse, cVEC.Create( p_tur.pos_x, p_tur.pos_y ), cVEC.Create( p_tur.pos_x + Cos( p_tur.ang ), p_tur.pos_y + Sin( p_tur.ang )))
					SetAlpha( 0.01 * Min( dist_from_lag_aimer_to_mouse, dist_to_ptur ) - 0.1 )
					SetRotation( p_tur.ang )
					DrawImage( img_reticle, lag_aimer.x, lag_aimer.y )
				Else
					lag_aimer = game.mouse.clone()
				End If
				'actual mouse reticle
				SetRotation( p_tur.ang_to_cVEC( game.mouse ))
				SetAlpha( 1.0 )
				DrawImage( img_reticle, game.mouse.x, game.mouse.y )
			
			Else If profile.input_method = INPUT_KEYBOARD
				SetRotation( p_tur.ang )
				DrawImage( img_reticle, p_tur.pos_x + 85*Cos( p_tur.ang ), p_tur.pos_y + 85*Sin( p_tur.ang ))
			
			End If
		End If
	End If
End Function

'______________________________________________________________________________
Const HORIZONTAL_HUD_MARGIN% = 35
Const CASH_WIDTH% = 120

Function draw_HUD()
	Local x%, y%, y1%, y2%, w%, h%
	Local str$
	
	SetImageFont( get_font( "consolas_bold_12" ))
	Local hud_height% = 2*(GetImageFont().Height() + 3)
	
	x = 0
	y1 = window_h - hud_height
	y2 = window_h - hud_height/2
	w = 85
	h = 12
	
	'hud "chrome"
	y = y1
	SetAlpha( 0.50 )
	SetColor( 0, 0, 0 )
	DrawRect( x,y, window_w,y+hud_height )
	SetAlpha( 0.75 )
	SetColor( 255, 255, 255 )
	DrawLine( x,y-1, x+window_w,y-1 )
	x :+ 2
	y1 :+ 3; y2 :+ 3
	
	y = y1
	'player health		
	SetColor( 255, 255, 255 )
	DrawImage( img_health_mini, x, y )
	Local pct# = game.player.cur_health/game.player.max_health
	draw_percentage_bar( x + img_health_mini.width + 3,y, w,h, pct ) ', (1 - (0.5*pct)) )
	
	y = y2
	'player cash
	SetImageFont( get_font( "consolas_14" ))
	str = "$" + format_number( profile.cash )
	SetColor( 50, 220, 50 )
	DrawText_with_shadow( str, x, y+1-3 )
	x :+ w + HORIZONTAL_HUD_MARGIN
	SetImageFont( get_font( "consolas_bold_12" ))
	
	'player ammo, overheat & charge indicators
	Local ammo_row_len% = w / img_icon_player_cannon_ammo.width
	Local temp_x%, temp_y%
	For Local t:TURRET = EachIn game.player.turret_list
		y = y1
		If t.name <> Null And t.name <> ""
			SetColor( 196, 196, 196 );
			DrawText( t.name, x, y+1 ); 'x :+ TextWidth( t.name ) + 3
		End If
		y = y2
		temp_x = x; temp_y = y
		If t.max_ammo <> INFINITY
			For Local i% = 0 To t.cur_ammo - 1
				If ((i Mod ammo_row_len) = 0) And (i > 0)
					temp_x = x
					If ((i / ammo_row_len) Mod 2) = 1 Then temp_x :+ img_icon_player_cannon_ammo.width / 2
					temp_y :+ img_icon_player_cannon_ammo.height / 2
				End If
				DrawImage( img_icon_player_cannon_ammo, temp_x, temp_y )
				temp_x :+ img_icon_player_cannon_ammo.width
			Next
			x :+ w + HORIZONTAL_HUD_MARGIN
		End If
		If t.max_heat <> INFINITY
			Local heat_pct# = (t.cur_heat / t.max_heat)
			SetColor( 255, 255, 255 )
			DrawRect( x, y, w, h )
			SetColor( 32, 32, 32 )
			DrawRect( x + 1, y + 1, w - 2, h - 2 )
			If (now() - t.bonus_cooling_start_ts) < t.bonus_cooling_time
				SetColor( 32, 32, 255 )
				DrawRect( x + 2, y + 2, w - 4, h - 4 )
				SetViewport( x + 2, y + 2, w - 4, h - 4 )
				SetColor( 255, 255, 255 )
				Local x_offset# = (now()/4) Mod (w+20)
				DrawImage( img_shine, x-10+Abs(x_offset), y + 2 )
				SetViewport( 0, 0, window_w,window_h )
			Else
				SetColor( 255*heat_pct, 0, 255*(1 - heat_pct) )
				DrawRect( x + 2, y + 2, (Double(w) - 4.0)*heat_pct, h - 4 )
			End If
			x :+ w + HORIZONTAL_HUD_MARGIN
		End If
	Next
	
	'music icon
	SetAlpha( 0.5 )
	Local music_str$ = "[m]usic"
	x = window_w - 10 - TextWidth( music_str )
	y = y1
	SetColor( 255, 255, 255 )
	DrawText( music_str, x, y )
	y = y2
	Local img_spkr:TImage
	If FLAG_bg_music_on
		SetAlpha( 1 )
		img_spkr = img_icon_speaker_on
	Else
		SetAlpha( 0.5 )
		img_spkr = img_icon_speaker_off
	End If
	DrawImage( img_icon_music_note, x, y ); x :+ img_icon_music_note.width + 5
	DrawImage( img_spkr, x, y )
	
End Function
'______________________________________________________________________________
Function draw_percentage_bar( x%,y%, w%,h%, pct#, a# = 1.0, r% = 255, g% = 255, b% = 255 )
	SetAlpha( a )
	SetColor( r, g, b )
	SetLineWidth( 1 )
	DrawRectLines( x,y, w,h )
	If      pct > 1.0 Then pct = 1.0 ..
	Else If pct < 0.0 Then pct = 0.0
	DrawRect( x + 2, y + 2, pct*(w - 4.0), h - 4 )
End Function

Function draw_scrollbar( x%, y%, w%, h%, total_size%, window_offset%, window_size% )
	SetLineWidth( 1 )
	Local offset# = (h-2*border_width)*Float(window_offset)/Float(total_size)
	Local size# = (h-2*border_width)*Float(window_size)/Float(total_size)
	SetColor( 64, 64, 64 )
	DrawRect( x, y, w, h )
	'SetColor( 96, 96, 96 )
	'DrawRectLines( x, y, w, h )
	SetColor( 0, 0, 0 )
	DrawRect( ..
		x+border_width, y+border_width, ..
		w-2*border_width, h-2*border_width )
	SetColor( 64, 64, 64 )
	DrawRect( ..
		x+border_width, y+border_width + offset, ..
		w-2*border_width, size )
	'SetColor( 96, 96, 96 )
	'DrawRectLines( ..
	'	x+border_width, y+border_width + offset, ..
	'	w-2*border_width, size )
End Function

Function DrawRectLines( x%,y%, w%,h% )
	DrawLine( x,     y,     x+w-1, y,     False )
	DrawLine( x+w-1, y,     x+w-1, y+h-1, False )
	DrawLine( x+w-1, y+h-1, x,     y+h-1, False )
	DrawLine( x,     y+h-1, x,     y,     False )
End Function

Function DrawText_with_shadow( str$, x#, y# )
	Local r%, g%, b%
	GetColor( r%, g%, b% )
	SetColor( 0, 0, 0 )
	DrawText( str, x + 1, y + 1 )
	DrawText( str, x + 2, y + 2 )
	SetColor( r, g, b )
	DrawText( str, x, y )
End Function

Function DrawText_with_glow( str$, x%, y% )
	SetAlpha( 0.2 )
	DrawText( str, x-1, y-1 )
	DrawText( str, x+1, y-1 )
	DrawText( str, x+1, y+1 )
	DrawText( str, x-1, y-1 )
	SetAlpha( 1 )
	DrawText( str, x, y )
End Function

Function screenshot()
	SetOrigin( 0, 0 )
	save_pixmap_to_file( GrabPixmap( 0, 0, window_w, window_h ))
End Function

'______________________________________________________________________________
'Procedural drawing methods
Function generate_sand_image:TImage( w%, h% )
	Local pixmap:TPixmap = CreatePixmap( w,h, PF_RGB888 )
	Local max_dist# = Sqr( Pow( w/2, 2 ) + Pow( h/2, 2 ))
	Local ratio# 'distance from point to center compared with max_dist, range [0.0,1.0]
	Local color:TColor
	'oval shaped earth-tone gradient, with static of varying types
	For Local px% = 0 To w-1
		For Local py% = 0 To h-1
			ratio = Sqr( Pow( w/2 - px, 2 ) + Pow( h/2 - py, 2 )) / max_dist
			'ratio:0 -> HSL( 44, 0.34, 0.35 )
			'ratio:1 -> HSL( 40, 0.57, 0.28 )
			color = TColor.Create_by_HSL( 39.0 + ((1.0 - ratio) * 5.0), 0.34 + (ratio * (0.23)), 0.30 + ((1.0 - ratio) * 0.10) )
			If Rand( 1, 2 ) = 1 '1:2 chance of static
				Select Rand( 1, 3 ) '3 types of staic
					Case 1
						color.H :+ Rnd( -10.0, 5.0 )
					Case 2
						color.S :+ Rnd( -0.15, 0.20 )
					Case 3
						color.L :+ Rnd( -0.05, 0.05 )
				End Select
			End If
			color.calc_RGB()
			pixmap.WritePixel( px,py, encode_ARGB( 1.0, color.R,color.G,color.B ))
		Next
	Next
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function
'______________________________________________________________________________
Function generate_level_walls_image:TImage( lev:LEVEL )
	Local pixmap:TPixmap = CreatePixmap( lev.width,lev.height, PF_RGBA8888 )
	pixmap.ClearPixels( encode_ARGB( 0.0, 0,0,0 ))
	Local blocking_cells:TList = lev.get_blocking_cells()
	Local wall:BOX
	Local neighbor%[]
	Local max_dist# = CELL.MAXIMUM_COST
	Local color:TColor
	'for each blocking region
	For Local c:CELL = EachIn blocking_cells
		wall = lev.get_wall( c )
		neighbor = lev.get_cardinal_blocking_neighbor_info( c ) 'in same order as CELL.ALL_CARDINAL_DIRECTIONS
		'for each pixel of the region to be rendered
		For Local px% = wall.x To wall.x+wall.w-1
			For Local py% = wall.y To wall.y+wall.h-1
				Local dist#[] = [ max_dist, max_dist, max_dist, max_dist ]
				If Not neighbor[0] Then dist[0] = py - wall.y          'TOP
				If Not neighbor[1] Then dist[1] = wall.x+wall.w-1 - px 'RIGHT
				If Not neighbor[2] Then dist[2] = wall.y+wall.h-1 - py 'BOTTOM
				If Not neighbor[3] Then dist[3] = px - wall.x          'LEFT
				Select Int( dist[ minimum( dist )])
					Case 0,  2,3
						color = TColor.Create_by_HSL( 0.0, 0.0, 0.80+Rnd( 0.00, 0.20 ))
					Case   1,    4,5
						color = TColor.Create_by_HSL( 0.0, 0.0, 0.55+Rnd( 0.00, 0.10 ))
					Default
						color = TColor.Create_by_HSL( 0.0, 0.0, 0.30+Rnd( 0.00, 0.05 ))
				End Select
				color.calc_RGB()
				pixmap.WritePixel( px,py, encode_ARGB( 1.0, color.R,color.G,color.B ))
			Next
		Next
	Next
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function

