Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Background cached texture
Global bg_cache:TImage
Const bg_redraw_delay% = 5000
Global last_bg_redraw_ts% = now() - bg_redraw_delay
Global str$

'______________________________________________________________________________
'Drawing to Screen
Function draw_all()
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetOrigin( 0, 0 )

	If FLAG_in_menu
		'main menu
		draw_menu()
	
	Else If FLAG_in_shop
		'buy stuff at the shop
		draw_shop()
	
	Else
		SetOrigin( arena_offset, arena_offset )

		'arena & retained particles
		draw_arena()
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
		
		'aiming reticle
		SetRotation( player.turrets[0].ang )
		DrawImage( img_reticle, player.turrets[0].pos_x, player.turrets[0].pos_y )
		SetRotation( 0 )

		SetOrigin( 0, 0 )
		SetViewport( 0, 0, window_w, window_h )
		
		'interface
		draw_stats()
		
		'help
		If FLAG_draw_help
			SetColor( 0, 0, 0 )
			SetAlpha( 0.550 )
			DrawRect( 0, 0, window_w, window_h )
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
			DrawImage( img_help, window_w/2 - img_help.width/2, window_h/2 - img_help.height/2 )

		Else If FLAG_game_over
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
		
		'level intro text
		If FLAG_level_intro
			SetOrigin( arena_offset, arena_offset )
			SetColor( 255, 255, 127 )
			SetImageFont( consolas_bold_100 )
			str = "LEVEL " + player_level
			DrawText( str, arena_w/2 - TextWidth( str )/2, arena_h/2 - TextHeight( str )/2 )
			SetColor( 255, 255, 255 )
			SetImageFont( consolas_normal_24 )
			str = "press [enter] to continue"
			DrawText( str, arena_w/2 - TextWidth( str )/2, arena_h/2 - TextHeight( str )/2 + 45 )
			
		End If
		
	End If
	
End Function
'______________________________________________________________________________
'Menu and GUI
Function draw_arena()

	SetViewport( 0, 0, window_w, window_h )

	If bg_cache = Null
		init_bg_cache()
	End If

	SetRotation( 0 ); DrawImage( img_arena_wall, -10, -10 )
	SetRotation( 90 ); DrawImage( img_arena_wall, arena_w + 10, -10 )
	SetRotation( 180 ); DrawImage( img_arena_wall, arena_w + 10, arena_h + 10 )
	SetRotation( 270 ); DrawImage( img_arena_wall, -10, arena_h + 10 )
	SetRotation( 0 )
	DrawImage( bg_cache, 0, 0 )

	SetViewport( arena_offset, arena_offset, arena_w, arena_h )

	For Local part:PARTICLE = EachIn retained_particle_list
		part.draw()
	Next

	If (now() - last_bg_redraw_ts) > bg_redraw_delay
		GrabImage( bg_cache, arena_offset, arena_offset )
		last_bg_redraw_ts = now()
		For Local part:PARTICLE = EachIn retained_particle_list
			part.remove_me()
		Next
	End If
		
End Function
'______________________________________________________________________________
Function init_bg_cache()
	bg_cache = CreateImage( arena_w, arena_h, DYNAMICIMAGE )
	Cls
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetRotation( 0 )
	DrawImage( img_arena_bg, 0, 0 )
	GrabImage( bg_cache, arena_offset, arena_offset )
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
	DrawImage( bg_cache, arena_offset, arena_offset )
	SetAlpha( 0.3333 )
	DrawImage( img_arena_bg, 0, 0 )
	GrabImage( bg_cache, arena_offset, arena_offset )
End Function
'______________________________________________________________________________
Function draw_menu()
	Local x%, y%
	
	'title
	x = 25; y = 25
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
		DrawText( My.Application.AssemblyInfo, x, y )
	
	'menu options
	x :+ 5; Local x_indent% = 0; y :+ 70
	For Local option% = 0 To menu_option_count - 1
		If menu_enabled[ option ]
			If option = menu_option
				SetColor( 255, 255, 255 )
				SetImageFont( consolas_bold_24 )
				'SetAlpha( 0.5 + 0.5*Sin(Float(now())/512.0) )
				SetAlpha( 1 )
			Else
				SetColor( 127, 127, 127 )
				SetImageFont( consolas_normal_24 )
				SetAlpha( 1 )
			End If
		Else
			SetColor( 64, 64, 64 )
			SetImageFont( consolas_normal_24 )
			SetAlpha( 1 )
		End If
		If option > 4 Then x_indent = 25
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
	
	'help reminder
	If Not FLAG_draw_help
		SetColor( 158, 158, 158 ); SetImageFont( consolas_normal_12 )
		DrawText( "F1 for help", arena_offset - 10, 2 )
	End If
	
	'level number
	x = arena_w + (arena_offset * 2)
	y = arena_offset
	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
	DrawText( "level", x, y ); y :+ 12
	SetColor( 255, 255, 127 ); SetImageFont( consolas_bold_50 )
	DrawText( player_level, x, y ); y :+ 50
	
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
'	y :+ arena_offset
'	SetColor( 255, 255, 255 ); SetImageFont( consolas_normal_12 )
'	DrawText( "heavy cannon", x, y ); y :+ 12
'	Local temp_x%, temp_y%
'	temp_x = x; temp_y = y
'	For Local i% = 0 To player.turrets[0].cur_ammo - 1
'		If ((i Mod 20) = 0) And (i > 0)
'			temp_x = x
'			If ((i / 20) Mod 2) = 1 Then temp_x :+ img_icon_player_cannon_ammo.width / 2
'			temp_y :+ img_icon_player_cannon_ammo.height / 3
'		End If
'		DrawImage( img_icon_player_cannon_ammo, temp_x, temp_y )
'		temp_x :+ img_icon_player_cannon_ammo.width - 1
'	Next; y :+ 12 + (player.turrets[0].max_ammo / 20)* img_icon_player_cannon_ammo.height
'	If player.turrets[1] <> Null
'		DrawText( "co-axial machine gun", x, y ); y :+ 12
'		w = 125; h = 14
'		SetColor( 255, 255, 255 )
'		DrawRect( x, y, w, h )
'		SetColor( 32, 32, 32 )
'		DrawRect( x + 1, y + 1, w - 2, h - 2 )
'		SetColor( 255*(player.turrets[1].cur_heat / player.turrets[1].max_heat), 0, 255*(1 - (player.turrets[1].cur_heat / player.turrets[1].max_heat)) )
'		DrawRect( x + 2, y + 2, (Double(w) - 4.0)*(player.turrets[1].cur_heat / player.turrets[1].max_heat), h - 4 )
'	End If
'	y :+ h
	
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


