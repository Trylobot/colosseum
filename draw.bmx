Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Background cached texture
Global bg_cache:TImage
Global FLAG_retain_particles% = False
Const retained_particle_limit% = 500
Global FLAG_dim_bg% = False
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
'______________________________________________________________________________
'In-game stuff
Function draw_game()
	
	'arena (& retained particles)
	SetBlend( ALPHABLEND )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	draw_arena_bg()

	'background particles
	For Local part:PARTICLE = EachIn particle_list_background
		part.draw()
	Next
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	
	'projectiles
	For Local proj:PROJECTILE = EachIn projectile_list
		proj.draw()
	Next
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	'pickups
	For Local pkp:PICKUP = EachIn pickup_list
		pkp.draw()
	Next
	SetAlpha( 1 )

	'arena foreground
	draw_arena_fg()
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	'hostile agents
	For Local hostile:COMPLEX_AGENT = EachIn hostile_agent_list
		hostile.draw()
	Next
	'friendly agents
	For Local friendly:COMPLEX_AGENT = EachIn friendly_agent_list
		friendly.draw()
	Next
	
	'foreground particles
	For Local part:PARTICLE = EachIn particle_list_foreground
		part.draw()
	Next
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 255, 255, 255 )
	
	'aiming reticle
	If player_input_type = INPUT_KEYBOARD
		SetRotation( player.turrets[0].ang )
		DrawImage( img_reticle, player.turrets[0].pos_x + 60*Cos( player.turrets[0].ang ), player.turrets[0].pos_y + 50*Sin( player.turrets[0].ang ) )
	Else If player_input_type = INPUT_KEYBOARD_MOUSE_HYBRID
		'position the larger dot of the reticle directly at the mouse position
		'point the ellipsis dots at the player's turret
		SetRotation( player.turrets[0].ang_to_cVEC( mouse_point ))
		DrawImage( img_reticle, mouse_point.x, mouse_point.y )
	End If
	SetRotation( 0 )

	'draw side-panel statistics and info
	draw_stats()

	'help actual
	If FLAG_draw_help
		SetColor( 0, 0, 0 )
		SetAlpha( 0.550 )
		DrawRect( 0, 0, window_w, window_h )
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		If player_brain.input_type = INPUT_KEYBOARD
			DrawImage( img_help_kb, arena_offset + arena_w/2 - img_help_kb.width/2, arena_offset + arena_h/2 - img_help_kb.height/2 )
		Else If player_brain.input_type = INPUT_KEYBOARD_MOUSE_HYBRID
			DrawImage( img_help_kb_mouse, arena_offset + arena_w/2 - img_help_kb_mouse.width/2, arena_offset + arena_h/2 - img_help_kb_mouse.height/2 )
		End If
	'help reminder
	Else
		SetImageFont( get_font( "consolas_12" ))
		str = "F1 for help"
		DrawText_with_shadow( str, player_spawn_point.pos_x - arena_offset - TextWidth( str ), player_spawn_point.pos_y - arena_offset/3 )
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
	Local x# = player_spawn_point.pos_x + arena_offset, y# = player_spawn_point.pos_y - arena_offset/3
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
	Local x%, y%
	
	'title
	x = 25; y = 25
	SetColor( 255, 255, 127 ); SetImageFont( get_font( "consolas_bold_50" ))
		DrawText( My.Application.AssemblyInfo, x, y )
	
	'menu options
	x :+ 5; y :+ 70
	draw_menus( x, y )
	
	'copyright stuff
	SetColor( 157, 157, 157 )
	SetImageFont( get_font( "consolas_10" ))
	x = window_w - 400; y = 25
	DrawText( "Colosseum (c) 2008 Tylerbot", x, y ); y :+ 10
	DrawText( "  [Tyler W.R. Cole]", x, y ); y :+ 10
	y :+ 10
	DrawText( "written in 100% BlitzMax", x, y ); y :+ 10
	DrawText( "  http://www.blitzmax.com", x, y ); y :+ 10
	x = window_w - 200; y = 25
	DrawText( "music by NickPerrin", x, y ); y :+ 10
	DrawText( "  Victory! (8-bit Chiptune)", x, y ); y :+ 10
	DrawText( "  http://www.newgrounds.com", x, y ); y :+ 10
	y :+ 10
	DrawText( "special thanks to", x, y ); y :+ 10
	DrawText( "  Kaze", x, y ); y :+ 10
	DrawText( "  SniperAceX", x, y ); y :+ 10
	
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

	If bg_cache = Null
		init_bg_cache()
	End If

	'draw arena background cache image
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	DrawImage( bg_cache, 0,0 )

	'incorporate retained particles into bg_cache and remove them from the managed list
	For Local part:PARTICLE = EachIn retained_particle_list
		part.draw()
	Next

	If FLAG_retain_particles
		FLAG_retain_particles = False
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetRotation( 0 )
		GrabImage( bg_cache, 0,0 )
		retained_particle_list.Clear()
		retained_particle_list_count = 0
		If FLAG_dim_bg
			FLAG_dim_bg = False
			SetColor( 255, 255, 255 )
			SetAlpha( 0.3333 )
			SetScale( 1, 1 )
			SetRotation( 0 )
			DrawImage( img_arena_bg, 0,0 )
			GrabImage( bg_cache, 0,0 )
		End If
	End If
		
End Function
'______________________________________________________________________________
Function draw_arena_fg()
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	
	DrawImage( img_arena_fg, 0,0 )
	draw_walls( get_level_walls( player_level ))

	For Local w:WIDGET = EachIn environmental_widget_list
		w.draw()
	Next
	
	'use battle_toggle_ts and arena_lights_fade_time to set alpha
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.4*time_alpha_pct( battle_toggle_ts, arena_lights_fade_time, Not FLAG_battle_in_progress ))
	DrawRect( 0,0, arena_offset*2+arena_w,arena_offset*2+arena_h )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.2*time_alpha_pct( battle_toggle_ts, arena_lights_fade_time, Not FLAG_battle_in_progress ))
	SetBlend( LIGHTBLEND )
	DrawImage( img_halo, player.pos_x,player.pos_y )
	SetScale( 2, 2 )
	DrawImage( img_halo, player_spawn_point.pos_x,player_spawn_point.pos_y+arena_offset/3 )
	SetBlend( ALPHABLEND )
End Function
'______________________________________________________________________________
Function init_bg_cache()
	bg_cache = CreateImage( arena_w + 2*arena_offset,arena_h + 2*arena_offset, DYNAMICIMAGE )

	Cls
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	DrawImage( img_arena_bg, 0,0 )
	GrabImage( bg_cache, 0,0 )
End Function
'______________________________________________________________________________
Function draw_walls( walls:TList )
	
	For Local wall%[] = EachIn walls
		SetViewport( wall[1],wall[2], wall[3],wall[4] )
		DrawImage( img_walls_inner, arena_offset,arena_offset )
	Next
	For Local wall%[] = EachIn walls
		SetViewport( wall[1]+8,wall[2]+8, wall[3]-16,wall[4]-16 )
		DrawImage( img_walls_border, arena_offset,arena_offset )
	Next
	SetViewport( 0,0, window_w,window_h )
End Function
'______________________________________________________________________________
Function draw_stats()
	Local x%, y%, w%, h%
	
	'level number
	x = arena_w + (arena_offset*2) + arena_offset/2
	y = arena_offset/2
	SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
	DrawText( "level", x, y ); y :+ 12
	SetColor( 255, 255, 127 ); SetImageFont( get_font( "consolas_bold_50" ))
	DrawText( player_level + 1, x, y ); y :+ 50
	
	'player cash
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
	'ToDo: put some code here to comma-separate the displayed cash value
	DrawText( "cash", x, y ); y :+ 12
	SetColor( 50, 220, 50 ); SetImageFont( get_font( "consolas_bold_50" ))
	DrawText( "$" + player_cash, x, y ); y :+ 50
		
	'player health		
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( get_font( "consolas_12" ))
	DrawText( "health", x, y ); y :+ 12
	w = 175;h = 18
	SetColor( 255, 255, 255 )
	DrawRect( x, y, w, h )
	SetColor( 32, 32, 32 )
	DrawRect( x + 1, y + 1, w - 2, h - 2 )
	SetColor( 255, 255, 255 )
	DrawRect( x + 2, y + 2, (Double(w) - 4.0)*(player.cur_health / player.max_health), h - 4 )
	y :+ h
	
	'player ammo, overheat & charge indicators
	y :+ arena_offset
	Local ammo_row_len% = 10
	Local temp_x%, temp_y%
	For Local t:TURRET = EachIn player.turret_list
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
Function DrawText_with_shadow( str$, pos_x%, pos_y% )
	SetColor( 0, 0, 0 )
	DrawText( str, pos_x + 1, pos_y + 1 )
	
	SetColor( 255, 255, 255 )
	DrawText( str, pos_x, pos_y )
End Function

Function DrawText_with_glow( str$, pos_x%, pos_y% )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.2 )
	DrawText( str, pos_x-1, pos_y-1 )
	DrawText( str, pos_x+1, pos_y-1 )
	DrawText( str, pos_x+1, pos_y+1 )
	DrawText( str, pos_x-1, pos_y-1 )
	SetAlpha( 1 )
	DrawText( str, pos_x, pos_y )
End Function



