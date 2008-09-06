Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Background cached texture
Global FLAG_retain_particles% = False
Const retained_particle_limit% = 1500
Global FLAG_dim_bg% = False
Const cursor_blink% = 500
Global str$

'______________________________________________________________________________
'Drawing to Screen
Function draw_all()
	SetBlend( ALPHABLEND )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )

	If Not FLAG_in_menu And Not FLAG_in_shop
		draw_game()
	Else
		If FLAG_in_menu
			draw_main_screen()
		Else If FLAG_in_shop
			draw_shop()
		End If
	End If
	
End Function

'Function draw_loading()
'	draw_percentage_bar( window_w/5,window_h/5, 3*window_w/5,3*window_w/5, loaded_pct )
'End Function
'______________________________________________________________________________
'In-game stuff
Function draw_game()
	
	'SetViewport( 0,0, arena_offset_left+arena_w+arena_offset_right,arena_offset_top+arena_h+arena_offset_bottom )
	
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
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'hostile agents
	For Local hostile:COMPLEX_AGENT = EachIn game.hostile_agent_list
		hostile.draw()
	Next
	'friendly agents
	For Local friendly:COMPLEX_AGENT = EachIn game.friendly_agent_list
		friendly.draw()
	Next
	
	'foreground particles
	For Local part:PARTICLE = EachIn game.particle_list_foreground
		part.draw()
	Next
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'aiming reticle
	If game.player.turret_list.Count() <> 0
		If player_input_type = INPUT_KEYBOARD
			SetRotation( TURRET( game.player.turret_list.First() ).ang )
			DrawImage( img_reticle, TURRET( game.player.turret_list.First() ).pos_x + 60*Cos( TURRET( game.player.turret_list.First() ).ang ), TURRET( game.player.turret_list.First() ).pos_y + 50*Sin( TURRET( game.player.turret_list.First() ).ang ) )
		Else If player_input_type = INPUT_KEYBOARD_MOUSE_HYBRID
			'position the larger dot of the reticle directly at the mouse position
			'point the ellipsis dots at the player's turret
			SetRotation( TURRET( game.player.turret_list.First() ).ang_to_cVEC( mouse_point ))
			DrawImage( img_reticle, mouse_point.x, mouse_point.y )
		End If
	End If
	SetRotation( 0 )

	SetViewport( 0,0, window_w,window_h )

	'draw side-panel statistics and info
	draw_stats()

	'help actual
	If FLAG_draw_help
		SetColor( 0, 0, 0 )
		SetAlpha( 0.550 )
		DrawRect( 0, 0, window_w, window_h )
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		If game.player_brain.input_type = INPUT_KEYBOARD
			DrawImage( img_help_kb, arena_offset + arena_w/2 - img_help_kb.width/2, arena_offset + arena_h/2 - img_help_kb.height/2 )
		Else If game.player_brain.input_type = INPUT_KEYBOARD_MOUSE_HYBRID
			DrawImage( img_help_kb_mouse, arena_offset + arena_w/2 - img_help_kb_mouse.width/2, arena_offset + arena_h/2 - img_help_kb_mouse.height/2 )
		End If
	'help reminder
	Else
		SetImageFont( get_font( "consolas_12" ))
		str = "F1 for help"
		DrawText_with_shadow( str, game.player_spawn_point.pos_x - arena_offset - TextWidth( str ), game.player_spawn_point.pos_y - arena_offset/3 )
	End If
	
	'game over
	If FLAG_game_over
		SetColor( 0, 0, 0 )
		SetAlpha( 0.650 )
		DrawRect( 0, 0, window_w, window_h )
		SetRotation( -30 )
		SetAlpha( 0.500 )
		SetColor( 200, 255, 200 )
		SetImageFont( get_font( "consolas_bold_150" ))
		DrawText( "GAME OVER", 25, window_h - 150 )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		SetImageFont( get_font( "consolas_24" ))
		DrawText( "press ESC", 300, window_h - 150 )
		
	End If
	SetRotation( 0 )
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	
	'level X
	If (now() - level_passed_ts) < level_intro_time
		SetImageFont( get_font( "consolas_bold_100" ))
		SetColor( 255, 255, 127 )
		Local pct# = Float(now() - level_passed_ts)/Float(level_intro_time)
		If pct < 0.25 'fade in
			SetAlpha( pct / 0.25 )
		Else If pct < 0.75 'hold
			SetAlpha( 1 )
		Else 'fade out
			SetAlpha( 1 - (( pct - 0.75) / 0.25 ))
		End If
		str = "LEVEL " + (player_level + 1)
		DrawText( str, arena_offset + arena_w/2 - TextWidth( str )/2, arena_offset + arena_h/2 - TextHeight( str )/2 )
	End If
	
	SetImageFont( get_font( "consolas_12" ))
	SetAlpha( 0.75 )
	Local x# = game.player_spawn_point.pos_x + arena_offset, y# = game.player_spawn_point.pos_y - arena_offset/3
	'commands to player
	If Not FLAG_player_engine_running
		DrawText_with_shadow( "(E) start your engine.", x, y )
	Else If FLAG_player_in_locker And FLAG_waiting_for_player_to_enter_arena
		DrawText_with_shadow( "enter the arena.", x, y )
	Else If Not FLAG_battle_in_progress And FLAG_waiting_for_player_to_exit_arena
		DrawText_with_shadow( "return to gate. (R) skip", x, y )
	End If
	
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
	
	'menu options
	x :+ 5; y :+ 70
	draw_menus( x, y )
	
	'copyright stuff
	SetColor( 157, 157, 157 )
	SetImageFont( get_font( "consolas_10" ))
	h = GetImageFont().Height() - 1
	x = 25; y = window_h - h*9
	DrawText( "Colosseum (c) 2008 Tyler W.R. Cole", x, y ); y :+ h
	DrawText( "  aka ~qTylerbot~q", x, y ); y :+ h
	DrawText( "music by ~qNickPerrin~q", x, y ); y :+ h
	DrawText( "json binding by ~qgrable~q", x, y ); y :+ h
	DrawText( "special thanks to", x, y ); y :+ h
	DrawText( "  ~qKaze~q", x, y ); y :+ h
	DrawText( "  ~qSniperAceX~q", x, y ); y :+ h
	DrawText( "written in 100% BlitzMax", x, y ); y :+ h
	
	'draw auto-AI demo area
	draw_AI_demo()
	
End Function
'______________________________________________________________________________
Function draw_shop()
	
End Function
'______________________________________________________________________________
Function draw_menus( x%, y% )
	For Local i% = 0 To current_menu
		SetAlpha( 0.5 )
		SetColor( 0, 0, 0 )
		DrawRect( x-3,y-3, 300, 500 )

		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		get_menu( menu_stack[i] ).draw( x + i*20, y + i*20, True )
	Next
End Function
'______________________________________________________________________________
Function draw_AI_demo()
	
End Function
'______________________________________________________________________________
Function draw_arena_bg()

	If game.bg_cache = Null
		init_bg_cache()
	End If

	'draw arena background cache image
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	DrawImage( game.bg_cache, 0,0 )

	'incorporate retained particles into bg_cache and remove them from the managed list
	For Local part:PARTICLE = EachIn game.retained_particle_list
		part.draw()
	Next
	
	If FLAG_retain_particles
		Select global_particle_prune_action
			
			Case PARTICLE_PRUNE_ACTION_ADD_TO_BG_CACHE
				FLAG_retain_particles = False
				game.retained_particle_list.Clear()
				game.retained_particle_list_count = 0
				
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				SetScale( 1, 1 )
				SetRotation( 0 )
				
				GrabImage( game.bg_cache, 0,0 )
				
				If FLAG_dim_bg
					FLAG_dim_bg = False
					
					SetColor( 255, 255, 255 )
					SetAlpha( 0.3333 )
					SetScale( 1, 1 )
					SetRotation( 0 )
					
					DrawImage( img_arena_bg, 0,0 )
					GrabImage( game.bg_cache, 0,0 )
					
				End If
				
			Case PARTICLE_PRUNE_ACTION_FORCED_FADE_OUT
				While game.retained_particle_list_count >= retained_particle_limit
					game.retained_particle_list.FirstLink().Remove()
					game.retained_particle_list_count :- 1
				End While
			
		End Select
	End If
		
End Function
'______________________________________________________________________________
Function draw_arena_fg()
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	
	DrawImage( img_arena_fg, 0,0 )
	draw_walls( game.walls )

	For Local w:WIDGET = EachIn game.environmental_widget_list
		w.draw()
	Next
	
	'use battle_toggle_ts and arena_lights_fade_time to set alpha
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.4*time_alpha_pct( battle_toggle_ts, arena_lights_fade_time, Not FLAG_battle_in_progress ))
	DrawRect( 0,0, window_w,window_h )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.2*time_alpha_pct( battle_toggle_ts, arena_lights_fade_time, Not FLAG_battle_in_progress ))
	SetBlend( LIGHTBLEND )
	DrawImage( img_halo, game.player.pos_x,game.player.pos_y )
	SetScale( 2, 2 )
	DrawImage( img_halo, game.player_spawn_point.pos_x,game.player_spawn_point.pos_y+arena_offset/3 )
	SetBlend( ALPHABLEND )
End Function
'______________________________________________________________________________
Function init_bg_cache()
	game.bg_cache = CreateImage( game.lev.width,game.lev.height, DYNAMICIMAGE )

	Cls
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	DrawImage( img_arena_bg, 0,0 )
	GrabImage( game.bg_cache, 0,0 )
End Function
'______________________________________________________________________________
Function draw_walls( walls:TList )
	
'	For Local wall:BOX = EachIn walls
'		SetViewport( wall.x,wall.y, wall.w,wall.h )
'		DrawImage( img_walls_inner, arena_offset,arena_offset )
'	Next
'	For Local wall%[] = EachIn walls
'		SetViewport( wall.x+2,wall.y+2, wall.w-4,wall.h-4 )
'		DrawImage( img_walls_border, arena_offset,arena_offset )
'	Next
'	SetViewport( 0,0, window_w,window_h )
End Function
'______________________________________________________________________________
Function draw_stats()
	Local x%, y%, w%, h%
	
	'level number
	x = window_w - stats_panel_w
	y = 25
	SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
	DrawText( "level", x, y ); y :+ 12
	SetColor( 255, 255, 127 ); SetImageFont( get_font( "consolas_bold_50" ))
	DrawText( player_level + 1, x, y ); y :+ 50
	
	'player cash
	y :+ 50
	SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
	'ToDo: put some code here to comma-separate the displayed cash value
	DrawText( "cash", x, y ); y :+ 12
	SetColor( 50, 220, 50 ); SetImageFont( get_font( "consolas_bold_50" ))
	DrawText( "$" + player_cash, x, y ); y :+ 50
		
	'player health		
	y :+ 50
	SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
	DrawText( "health", x, y ); y :+ 12
	w = 175; h = 18
	draw_percentage_bar( x,y, w,h, (game.player.cur_health/game.player.max_health) )
	y :+ h
	
	'player ammo, overheat & charge indicators
	y :+ 50
	Local ammo_row_len% = 10
	Local temp_x%, temp_y%
	For Local t:TURRET = EachIn game.player.turret_list
		If t.name <> Null And t.name <> ""
			SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
			DrawText( t.name, x, y ); y :+ 12
		End If
		temp_x = x; temp_y = y
		If t.max_ammo <> INFINITY
		For Local i% = 0 To t.cur_ammo - 1
			If ((i Mod ammo_row_len) = 0) And (i > 0)
				temp_x = x
				If ((i / ammo_row_len) Mod 2) = 1 Then temp_x :+ img_icon_player_cannon_ammo.width / 2
				temp_y :+ img_icon_player_cannon_ammo.height / 3
			End If
			DrawImage( img_icon_player_cannon_ammo, temp_x, temp_y )
			temp_x :+ img_icon_player_cannon_ammo.width - 1
		Next; y :+ (t.max_ammo / ammo_row_len)*img_icon_player_cannon_ammo.height - 4
		End If
		If t.max_heat <> INFINITY
			w = 125; h = 14
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
				SetViewport( 0,0, window_w,window_h )
			Else
				SetColor( 255*heat_pct, 0, 255*(1 - heat_pct) )
				DrawRect( x + 2, y + 2, (Double(w) - 4.0)*heat_pct, h - 4 )
			End If
		End If
	Next
	y :+ h
	
	'music icon
	y :+ arena_offset
	SetColor( 255, 255, 255 )
	DrawText( "music", x, y ); y :+ 12
	DrawImage( img_icon_music_note, x, y ); x :+ img_icon_music_note.width + 10
	If FLAG_bg_music_on Then DrawImage( img_icon_speaker_on, x, y ) ..
	Else                     DrawImage( img_icon_speaker_off, x, y )
	
End Function
'______________________________________________________________________________
Function draw_percentage_bar( x%,y%, w%,h%, pct# )
	SetColor( 255, 255, 255 )
	DrawRect( x, y, w, h )
	SetColor( 64, 64, 64 )
	DrawRect( x + 1, y + 1, w - 2, h - 2 )
	If      pct > 1.0 Then pct = 1.0 ..
	Else If pct < 0.0 Then pct = 0.0
	SetColor( 255, 255, 255 )
	DrawRect( x + 2, y + 2, pct*(w - 4.0), h - 4 )
End Function

Function DrawText_with_shadow( str$, pos_x%, pos_y% )
	SetColor( 0, 0, 0 )
	DrawText( str, pos_x + 1, pos_y + 1 )
	SetColor( 255, 255, 255 )
	DrawText( str, pos_x, pos_y )
End Function

Function DrawText_with_glow( str$, pos_x%, pos_y% )
	SetAlpha( 0.2 )
	DrawText( str, pos_x-1, pos_y-1 )
	DrawText( str, pos_x+1, pos_y-1 )
	DrawText( str, pos_x+1, pos_y+1 )
	DrawText( str, pos_x-1, pos_y-1 )
	SetAlpha( 1 )
	DrawText( str, pos_x, pos_y )
End Function

Function screenshot()
'	Local screen:TImage = TImage.Create( window_w,window_h, 0, DYNAMICIMAGE )
'	GrabImage( screen, 0,0 )
'	save_screenshot_to_file( screen )
End Function
'______________________________________________________________________________
'Procedural drawing methods
Function generate_sand_image:TImage( w%, h% )
	'draw sand procedurally by any means necessary
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
	Local img:TImage = LoadImage( pixmap )
	Return img
End Function

Function generate_walls_image:TImage( lev:LEVEL )
	Local pixmap:TPixmap = CreatePixmap( lev.width,lev.height, PF_RGBA8888 )
	Local blocking_cells:TList = lev.get_blocking_cells()
	
	
End Function

