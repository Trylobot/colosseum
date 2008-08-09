Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Background cached texture
Global bg_cache:TImage
Const retained_particle_limit% = 5000
Global str$

'______________________________________________________________________________
'Drawing to Screen
Function draw_all()
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )

	If FLAG_in_menu
		'main menu
		draw_menu()
	
	Else If FLAG_in_shop
		'buy stuff at the shop
		draw_shop()
	
	Else

		'arena & retained particles
		draw_arena_bg()
		SetColor( 255, 255, 255 )

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
		'pickups
		For Local pkp:PICKUP = EachIn pickup_list
			pkp.draw()
		Next
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		
		'arena foreground
		draw_arena_fg()
		
		'aiming reticle
		SetRotation( player.turrets[0].ang )
		DrawImage( img_reticle, player.turrets[0].pos_x, player.turrets[0].pos_y )
		SetRotation( 0 )

		'interface
		draw_stats()

		'help actual
		If FLAG_draw_help
			SetColor( 0, 0, 0 )
			SetAlpha( 0.550 )
			DrawRect( 0, 0, window_w, window_h )
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
			DrawImage( img_help, window_w/2 - img_help.width/2, window_h/2 - img_help.height/2 )
		'help reminder
		Else
			SetImageFont( consolas_normal_12 )
			SetColor( 0, 0, 0 )
			DrawText( "F1 for help", arena_offset - 10+1, 2+1 )
			SetColor( 255, 255, 255 )
			DrawText( "F1 for help", arena_offset - 10, 2 )
		End If
		
		'game over
		If FLAG_game_over
			SetColor( 0, 0, 0 )
			SetAlpha( 0.550 )
			DrawRect( 0, 0, window_w, window_h )
			SetRotation( -30 )
			SetAlpha( 0.333 )
			SetColor( 200, 255, 200 )
			SetImageFont( consolas_bold_150 )
			DrawText( "GAME OVER", 25, window_h - 150 )
			SetAlpha( 1 )
			SetColor( 255, 255, 255 )
			SetImageFont( consolas_normal_24 )
			DrawText( "press ESC", 300, window_h - 150 )
			
		End If
		SetRotation( 0 )
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		
		'level intro
		If (now() - level_passed_ts) < level_intro_time
			SetImageFont( consolas_bold_100 )
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
		
		SetImageFont( consolas_normal_24 )
		SetColor( 127, 255, 255 )
		SetAlpha( 0.75 )
		Local x# = player_spawn_point.pos_x + arena_offset, y# = player_spawn_point.pos_y
		'commands to player
		If Not FLAG_player_engine_running
			DrawText( "[E] start your engine.", x, y )
		Else If FLAG_player_in_locker And FLAG_waiting_for_player_to_enter_arena
			DrawText( "Please enter the arena.", x, y )
		Else If Not FLAG_battle_in_progress And FLAG_waiting_for_player_to_exit_arena
			DrawText( "To proceed, return to your gate.", x, y )
		End If
		
	End If
	
End Function
'______________________________________________________________________________
'Menu and GUI
Function draw_arena_bg()

	If bg_cache = Null
		init_bg_cache()
	End If

	'draw arena background cache image
	SetRotation( 0 )
	DrawImage( bg_cache, 0,0 )

	'incorporate retained particles into bg_cache and remove them from the managed list
	For Local part:PARTICLE = EachIn retained_particle_list
		part.draw()
	Next
	If retained_particle_list_count > retained_particle_limit
		GrabImage( bg_cache, 0,0 )
		retained_particle_list.Clear()
		retained_particle_list_count = 0
	End If
		
End Function
'______________________________________________________________________________
Function draw_arena_fg()
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	
	DrawImage( img_arena_fg, 0,0 )
	SetColor( 122, 111, 83 )
	draw_walls( get_level_walls( player_level ))

	For Local w:WIDGET = EachIn environmental_widget_list
		w.draw()
	Next
End Function
'______________________________________________________________________________
Function draw_walls( walls:TList )
	For Local wall%[] = EachIn walls
		'SetViewport( ?,?, ?,? )
		DrawRect( wall[1],wall[2], wall[3],wall[4] )
	Next
	SetViewport( 0,0, window_w,window_h )
End Function
'______________________________________________________________________________
Function init_bg_cache()
	bg_cache = CreateImage( arena_w + 2*arena_offset,arena_h + 2*arena_offset, DYNAMICIMAGE )

	Cls
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	DrawImage( img_arena_bg, 0,0 )
	GrabImage( bg_cache, 0,0 )
End Function
'______________________________________________________________________________
Function dim_bg_cache()
	If bg_cache = Null
		init_bg_cache()
	End If

	Cls
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	DrawImage( bg_cache, 0,0 )
	SetAlpha( 0.3333 )
	DrawImage( img_arena_bg, 0,0 )
	GrabImage( bg_cache, 0,0 )
End Function
'______________________________________________________________________________
Function draw_menu()
	Local x%, y%
	
	'title
	x = 25; y = 25
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
		DrawText( My.Application.AssemblyInfo, x, y )
	
	'menu options
	x :+ 5; y :+ 70
	Local x_indent% = 0
	For Local option% = 0 To menu_option_count - 1
		If menu_enabled[ option ]
			If option = menu_option
				SetColor( 255, 255, 255 )
				SetImageFont( consolas_bold_24 )
				SetAlpha( 1 )
			Else
				SetColor( 127, 127, 127 )
				SetImageFont( consolas_normal_24 )
				SetAlpha( 1 )
			End If
		Else
			If option <= 4
				SetColor( 64, 64, 64 )
				SetImageFont( consolas_normal_24 )
				SetAlpha( 1 )
			Else
				SetColor( 64, 64, 64 )
				SetImageFont( consolas_normal_24 )
				SetAlpha( 0 )
			End If
		End If
		If option > 4 Then x_indent = 20
		DrawText( menu_display_string[ option ], x + x_indent, y + option*26 )
	Next
	SetAlpha( 1 )
	
	'copyright stuff
	SetColor( 157, 157, 157 )
	SetImageFont( consolas_normal_10 )
	x :+ 200; y :+ 7
	DrawText( "Colosseum (c) 2008 Tylerbot", x, y ); y :+ 10
	DrawText( "  [Tyler W.R. Cole]", x, y ); y :+ 10
	y :+ 10
	DrawText( "written in 100% BlitzMax", x, y ); y :+ 10
	DrawText( "  http://www.blitzmax.com", x, y ); y :+ 10
	y :+ 10
	DrawText( "music by NickPerrin", x, y ); y :+ 10
	DrawText( "  Victory! (8-bit Chiptune)", x, y ); y :+ 10
	DrawText( "  http://www.newgrounds.com", x, y ); y :+ 10
	y :+ 10
	DrawText( "special thanks to", x, y ); y :+ 10
	DrawText( "  Kaze", x, y ); y :+ 10
	DrawText( "  SniperAceX", x, y ); y :+ 10
	
End Function
'______________________________________________________________________________
Function draw_stats()
	Local x%, y%, w%, h%
	
	'level number
	x = arena_w + (arena_offset * 2)
	y = arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	DrawText( "level", x, y ); y :+ 12
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
	DrawText( player_level + 1, x, y ); y :+ 50
	
	'player cash
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	'ToDo: put some code here to comma-separate the displayed cash value
	DrawText( "cash", x, y ); y :+ 12
	SetColor( 50, 220, 50 ); SetImageFont( consolas_bold_50 )
	DrawText( "$" + player_cash, x, y ); y :+ 50
		
	'player health		
	y :+ arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
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
	For Local t:TURRET = EachIn player.turrets
		If t.name <> Null And t.name <> ""
			SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
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
			SetColor( 255*heat_pct, 0, 255*(1 - heat_pct) )
			DrawRect( x + 2, y + 2, (Double(w) - 4.0)*heat_pct, h - 4 )
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
Function draw_shop()
	
End Function


