Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "environment.bmx"
'Import "core.bmx"
'Import "instaquit.bmx"
'Import "settings.bmx"
'Import "particle.bmx"
'Import "door.bmx"
'Import "agent.bmx"
'Import "projectile.bmx"
'Import "pickup.bmx"
'Import "complex_agent.bmx"
'Import "widget.bmx"
'Import "net.bmx"
'Import "control_brain.bmx"
'Import "menu.bmx"
'Import "inventory_data.bmx"
'Import "point.bmx"
'Import "turret.bmx"
'Import "vec.bmx"
'Import "box.bmx"
'Import "level.bmx"
'Import "image_manip.bmx"
'Import "draw_misc.bmx"
'Import "texture_manager.bmx"
'Import "flags.bmx"
'Import "hud.bmx"
'Import "mouse.bmx"
'Import "input.bmx"

'______________________________________________________________________________
Const cursor_blink% = 500

'Drawing to Screen
Function draw_all_graphics()
	
	SetBlend( ALPHABLEND )
	SetOrigin( 0, 0 )
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetLineWidth( 1 )

	'game content
	If game
		draw_game()

		SetColor( 255, 255, 255 )
		SetRotation( 0 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetLineWidth( 1 )
	End If
	
	'menus and such
	If FLAG.in_menu
		draw_main_screen()
	End If

  ?Debug
	debug_main()
  ?
	
	'instaquit
	escape_key_update()
	draw_instaquit_progress()
	
	'screenshot
	If KeyHit( KEY_F12 ) Then screenshot()
	
End Function

'______________________________________________________________________________
'In-game stuff
Function draw_game()
	
	'clamp global origin to integer (pixel) boundaries to reduce flicker effect on straight edges when moving
	'Local ox% = game.drawing_origin.x 
	'Local oy% = game.drawing_origin.y
	Local ox# = game.drawing_origin.x 
	Local oy# = game.drawing_origin.y
	SetOrigin( ox, oy )
	
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	
	'arena background + retained particles
	game.graffiti.draw()

	'background particles
	For Local part:PARTICLE = EachIn game.particle_list_background
		part.draw()
	Next
	
	'door backgrounds
	For Local d:DOOR = EachIn game.doors
		d.draw_bg()
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

	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )

	'arena foreground
	DrawImage( game.foreground, 0, 0 )

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
	'(used to be here)
	
	'environmental widgets
	For Local w:WIDGET = EachIn game.environmental_widget_list
		w.draw()
	Next

	'door foregrounds
	For Local d:DOOR = EachIn game.doors
		d.draw_fg()
	Next

	'foreground particles
	For Local part:PARTICLE = EachIn game.particle_list_foreground
		part.draw()
	Next
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 1 )
	
	If game.human_participation
		draw_lighting_and_effects()
	End If
	
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetAlpha( 1 )

	'enemy life bars
	'For Local list:TList = EachIn game.complex_agent_lists
	'	For Local cmp_ag:COMPLEX_AGENT = EachIn list
	'		draw_percentage_bar( cmp_ag.pos_x - 10, cmp_ag.pos_y + 15, 20, 5, (cmp_ag.cur_health/cmp_ag.max_health), 0.35 )
	'	Next
	'Next
	
	'player secondary life bar
	If game.player
		'black out a rectangular bar
		SetColor( 0, 0, 0 )
		DrawRect( game.player.pos_x - 11, game.player.pos_y + 14, 22, 4 )
		'fill in the bar partially according to the player's current health
		'make it blink red if it's less than a third full
		Local c% = 255
		Local pct# = game.player.cur_health/game.player.max_health
		If pct <= 0.33333 Then c = 255 * Sin( now() Mod 180 )
		draw_percentage_bar( game.player.pos_x - 10, game.player.pos_y + 15, 20, 2, pct, 1.0, 255, c, c, False, False )
	End If

	SetColor( 255, 255, 255 )

	'aimer
	draw_reticle()
	SetRotation( 0 )
	
	'nametag disabled
	'If game.human_participation
	'	draw_nametag( profile.name, game.player.to_cvec() )
	'End If

	SetOrigin( 0, 0 )
	
	If game.human_participation
		'hud
		draw_HUD()
		'health bits
		For Local health_bit:WIDGET = EachIn health_bits
			health_bit.draw()
		Next
		If game.win 'win
			draw_win()
		End If
		If game.game_over 'game over
			draw_game_over()
		End If
		'help screen
		If FLAG_draw_help
			draw_help_stuff()
		End If
	End If

	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	
End Function

'______________________________________________________________________________
'Menu and GUI
Function draw_main_screen()
	Rem
	Local x%, y%, h%
	Local fg_font:BMP_FONT = get_bmp_font( "arcade_7" )
	Local bg_font:BMP_FONT = get_bmp_font( "arcade_7_outline" )
	EndRem

	Rem
	'menu options
	If Not show_campaign_chooser
		draw_menus()
	Else 'show_campaign_chooser
		campaign_chooser.draw( main_screen_x, main_screen_menu_y )
	End If
	EndRem
	
	'////////////////////
	' draw current menu
	SetAlpha( 1 )
	If Not FLAG.paused
		MENU_REGISTER.get_top().draw()
	Else 'paused
		MENU_REGISTER.pause.draw()
	End If
	'/////////////
	
	Rem
	'credits & copyrights, and info string
	h = fg_font.height
	x = 10
	y = SETTINGS_REGISTER.WINDOW_HEIGHT.get() - h*colosseum_credits_linecount - 10
	If (Not game Or Not game.human_participation) And MENU_REGISTER.get_top() <> MENU_REGISTER.root
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		SetColor( 105, 105, 105 )
		fg_font.draw_string( colosseum_credits, x, y )
		SetColor( 20, 20, 20 )
		bg_font.draw_string( colosseum_credits, x, y )
	End If
	EndRem
	
	Rem
	'info
	y :- h*2
	'SetImageFont( get_font( "consolas_italic_12" ))
	SetAlpha( time_alpha_pct( info_change_ts + info_stay_time, info_fade_time, False ))
	'DrawText_with_outline( info, x, y )
	'SetColor( 255, 255, 127 ) 'Title Yellow
	SetColor( 100, 149, 237 ) 'Cornflower Blue
	fg_font.draw_string( info, x, y )
	SetColor( 20, 20, 20 )
	bg_font.draw_string( info, x, y )
	EndRem
	
End Function

'______________________________________________________________________________
Function draw_lighting_and_effects()
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.95 * time_alpha_pct( game.battle_state_toggle_ts, arena_lights_fade_time, Not game.battle_in_progress ))
	
	Local size% = Max( SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
	Local x% = Int( game.player.pos_x )
	Local y% = Int (game.player.pos_y )
	DrawRect( x - 100 - size, y - 100 - size, size, 2*size )
	DrawRect( x + 100,        y - 100 - size, size, 2*size )
	DrawRect( x - 100,        y - 100 - size,  200,   size )
	DrawRect( x - 100,        y + 100,         200,   size )

	DrawImage( get_image( "spotlight" ), x, y )
End Function

'______________________________________________________________________________
Global last_pos:POINT
Global cur_alpha#, last_alpha#
Global lag_aimer:cVEC
Global epileptic_blink%

Function draw_reticle()
	If game.human_participation
		SetScale( 1, 1 )
		SetRotation( 0 )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		DrawImage( get_image( "reticle_simple" ), Floor(game_mouse.x) + 0.5, Floor(game_mouse.y) + 0.5 )
		Rem
		If game.player.turrets <> Null
			Local tur:TURRET = game.player.turrets[0]
			'turret ghost reticle
			Local img_ghost_reticle:TImage = get_image( "ghost_reticle" )
			Local distance_from_turret_to_mouse# = tur.dist_to( game_mouse ) 
			SetRotation( tur.ang )
			Local ang_diff# = ang_wrap( tur.ang_to( game_mouse ) - tur.ang )
			SetAlpha( 1 - Abs(ang_diff)/22.5 )
			DrawImage( img_ghost_reticle, tur.pos_x + distance_from_turret_to_mouse * Cos( tur.ang ), tur.pos_y + distance_from_turret_to_mouse * Sin( tur.ang ))
			'actual mouse reticle
			Local img_reticle:TImage = get_image( "reticle" )
			SetRotation( tur.ang_to( game_mouse ))
			SetAlpha( 1 )
			DrawImage( img_reticle, game_mouse.x, game_mouse.y )
		End If
		EndRem
	End If
End Function

'______________________________________________________________________________
Const HORIZONTAL_HUD_MARGIN% = 35
Const CASH_WIDTH% = 120

Function draw_HUD()
	Local x%, y%, y1%, y2%, w%, h%
	Local str$
	
	'SetImageFont( get_font( "consolas_bold_12" ))
	'Local hud_height% = 2*(GetImageFont().Height() + 3)
	Local fg_font:BMP_FONT = get_bmp_font( "arcade_7" )
	Local bg_font:BMP_FONT = get_bmp_font( "arcade_7_outline" )
	Local hud_height% = 2*bg_font.height + 3
	
	x = 0
	y1 = SETTINGS_REGISTER.WINDOW_HEIGHT.get() - hud_height
	y2 = SETTINGS_REGISTER.WINDOW_HEIGHT.get() - hud_height/2
	w = health_bar_w
	h = health_bar_h
	
	'hud "chrome"
	y = y1
	SetAlpha( 0.50 )
	SetColor( 0, 0, 0 )
	DrawRect( x,y, SETTINGS_REGISTER.WINDOW_WIDTH.get(),y+hud_height )
	SetAlpha( 0.75 )
	SetColor( 255, 255, 255 )
	DrawLine( x,y-1, x+SETTINGS_REGISTER.WINDOW_WIDTH.get(),y-1 )
	x :+ 2
	y1 :+ 3; y2 :+ 3
	
	y = y1
	'player health
	Local img_health_mini:TImage = get_image( "health_mini" )
	DrawImage( img_health_mini, x, y )
	Local pct# = game.player.cur_health/game.player.max_health
	Local c% = 255
	If pct <= 0.33333 Then c = 255 * Sin( now() Mod 180 )
	draw_percentage_bar( x + img_health_mini.width + 3,y, w,h, pct, 1.0, 255, c, c ) ', (1 - (0.5*pct)) )
	
	y = y2
	'player cash
	str = "$" + format_number( profile.cash )
	SetAlpha( 1 )
	SetColor( 255, 255, 255 )
	draw_layered_string( str, x, y, fg_font, bg_font, 85,255,85, 10,75,10 )
	Local life_time% = (get_particle("cash_positive",,False).life_time)
	If now() - last_kill_ts <= life_time
		SetAlpha( time_alpha_pct( last_kill_ts, life_time, False ))
		SetColor( 85, 255, 85 ) 'Cash Green
		SetScale( 1, 0.65 )
		DrawImage( get_image( "halo" ), x + fg_font.width(str)/2.0, y + fg_font.height )
		SetAlpha( 0.3333*GetAlpha() )
		SetColor( 255, 255, 255 )
		SetScale( 1, 1 )
		draw_layered_string( str, x, y, fg_font,, 255,255,255 )
	End If
	x :+ w + HORIZONTAL_HUD_MARGIN
	SetAlpha( 1 )
	
	'player ammo, overheat & charge indicators
	Local img_icon_player_cannon_ammo:TImage = get_image( "icon_player_cannon_ammo" )
	Local img_shine:TImage = get_image( "bar_shine" )
	Local ammo_row_len% = w / img_icon_player_cannon_ammo.width
	Local temp_x%, temp_y%
	For Local t:TURRET = EachIn game.player.turrets
		y = y1
		'turret name
		If t.name <> Null And t.name <> ""
			SetColor( 196, 196, 196 );
			'DrawText_with_outline( t.name, x, y-3 ); 'x :+ TextWidth( t.name ) + 3
		End If
		'reloading/recharging bar
		If t.class = TURRET.AMMUNITION
			SetColor( 255, 255, 255 )
			DrawImage( get_image( "reload_bar" ), x, y+7 )
			DrawImage( get_image( "reload_marker" ), x + t.reloaded_pct()*50, y + 7 )
		Else If t.class = TURRET.ENERGY
			SetColor( 255, 255, 255 )
			DrawImage( get_image( "recharge_bar" ), x, y+7 )
			Local charge_units% = 19 * t.reloaded_pct()
			SetAlpha( 0.5 )
			For Local i% = 0 Until charge_units
				DrawRect( x + 2 + 3*i, y+7+2, 2, 4 )
			Next
			SetAlpha( 1 )
		End If
		'ammunition icons (for ammunition-based turrets)
		y = y2 - 1
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
		'temperature indicator (for turrets that use heat)
		If t.max_heat <> INFINITY
			Local heat_pct# = (t.cur_heat / t.max_heat)
			SetColor( 255, 255, 255 )
			DrawRect( x, y, w, h )
			SetColor( 32, 32, 32 )
			DrawRect( x + 1, y + 1, w - 2, h - 2 )
			If (now() - t.bonus_cooling_start_ts) < t.bonus_cooling_time
				SetColor( 32, 32, 255 )
				DrawRect( x + 2, y + 2, w - 4, h - 4 )
				'SetViewport( x + 2, y + 2, w - 4, h - 4 )
				SetColor( 255, 255, 255 )
				Local x_offset# = (now()/4) Mod (w)
				DrawImage( img_shine, x-10+Abs(x_offset), y + 2 )
				'SetViewport( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(),SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
			Else
				SetColor( 255*heat_pct, 0, 255*(1 - heat_pct) )
				DrawRect( x + 2, y + 2, (Double(w) - 4.0)*heat_pct, h - 4 )
			End If
			x :+ w + HORIZONTAL_HUD_MARGIN
		End If
	Next
	
	'music icon
	Local img_icon_music_note:TImage = get_image( "icon_music_note" )
	Local img_icon_speaker_on:TImage = get_image( "icon_speaker_on" )
	Local img_icon_speaker_off:TImage = get_image( "icon_speaker_off" )
	SetAlpha( 0.5 )
	Local music_str$ = "[m]usic"
	x = SETTINGS_REGISTER.WINDOW_WIDTH.get() - 10 - TextWidth( music_str )
	y = y1
	SetColor( 255, 255, 255 )
	'DrawText_with_outline( music_str, x, y )
	y = y2
	Local img_spkr:TImage
	If bg_music_enabled
		SetAlpha( 1 )
		img_spkr = img_icon_speaker_on
	Else
		SetAlpha( 0.5 )
		img_spkr = img_icon_speaker_off
	End If
	DrawImage( img_icon_music_note, x, y ); x :+ img_icon_music_note.width + 5
	DrawImage( img_spkr, x, y )
	
	'help
	SetColor( 232, 232, 232 )
	SetAlpha( 1 )
	'DrawText_with_outline( "F1 for help", SETTINGS_REGISTER.WINDOW_WIDTH.get() - TextWidth("F1 for help") - 10, SETTINGS_REGISTER.WINDOW_HEIGHT.get() - 55 )
	
End Function

Function draw_win()
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetAlpha( 1.0*time_alpha_pct( game.battle_state_toggle_ts, 1200 ))
	'SetImageFont( get_font( "consolas_bold_50" ))
	Local m1$ = "LEVEL COMPLETED!"
	DrawText_with_outline( m1, SETTINGS_REGISTER.WINDOW_WIDTH.get()/2 - TextWidth(m1)/2, 10 )
	'SetImageFont( get_font( "consolas_12" ))
	Local m2$ = "press enter to continue"
	DrawText_with_outline( m2, SETTINGS_REGISTER.WINDOW_WIDTH.get()/2 - TextWidth(m2)/2, 50 )
	
	draw_kill_tally( game.battle_state_toggle_ts, game.player_kills )
End Function

Function draw_game_over()
	'paint it black
	SetColor( 0, 0, 0 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetAlpha( 1.0*time_alpha_pct( game.battle_state_toggle_ts, 3000 ))
	DrawRect( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
	'message
	SetColor( 255, 0, 0 )
	SetAlpha( 1.0*time_alpha_pct( game.battle_state_toggle_ts, 800 ))
	'SetImageFont( get_font( "consolas_bold_100" ))
	Local m1$ = "GAME OVER."
	DrawText_with_outline( m1, SETTINGS_REGISTER.WINDOW_WIDTH.get()/2 - TextWidth(m1)/2, 10 )
	'SetImageFont( get_font( "consolas_12" ))
	Local m2$ = "press enter to continue"
	DrawText_with_outline( m2, SETTINGS_REGISTER.WINDOW_WIDTH.get()/2 - TextWidth(m2)/2, 150 )
End Function

Function draw_help_stuff()
	'Local img_help_kb:TImage = get_image( "help_kb" )
	'Local img_help_kb_mouse:TImage = get_image( "help_kb_and_mouse" )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.550 )
	DrawRect( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	'draw help
End Function

'______________________________________________________________________________
Global asset_loading_x% = 0
Global asset_loading_y% = 0
Global asset_loading_longest_string_length% = 0

Function draw_loaded_asset( asset_id$ = Null, next_section% = False )
	If next_section
		asset_loading_x :+ asset_loading_longest_string_length + 1
		asset_loading_longest_string_length = 0
		asset_loading_y = 1
	Else
		asset_loading_y :+ 4
	End If
	asset_loading_longest_string_length = Max( asset_loading_longest_string_length, TextWidth( asset_id ))
	SetColor( 127, 127, 127 )
	DrawText( asset_id, asset_loading_x, asset_loading_y )
	Flip()
End Function
'______________________________________________________________________________
Function fade_out()
	SetColor( 0, 0, 0 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 0.08 )
	Local begin_ts% = now()
	While (now() - begin_ts) < 1500
		DrawRect( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
		Flip()
	End While
	Return
End Function

'______________________________________________________________________________
Function draw_nametag( name$, anchor:cVEC, y_offset% = 27 )
	anchor = anchor.clone()
	anchor.y :+ y_offset
	'SetImageFont( get_font( "consolas_bold_10" ))
	Local tw% = TextWidth( name )
	Local h% = 10
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	'SetColor( 50, 50, 50 )
	'DrawOval( anchor.x - tw/2 - h/2, anchor.y - h/2, h, h )
	'DrawOval( anchor.x + tw/2 - h/2, anchor.y - h/2, h, h )
	'DrawRect( anchor.x - tw/2, anchor.y - h/2, tw, h )
	'SetColor( 200, 200, 200 )
	'DrawText( name, anchor.x - tw/2, anchor.y - h/2 )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.60 )
	DrawText_with_outline( name, anchor.x - tw/2, anchor.y - h/2, 0.15 )
End Function

'______________________________________________________________________________
Function draw_kill_tally( start_ts%, count% )
	Const tally_y% = 100
	Const fade_in_time% = 250
	
	Local skull_1x:TImage = get_image( "skull_1x" )
	Local sk_w# = skull_1x.width
	Local sk_h# = skull_1x.height
	Local skulls_per_row% = 10
	Local area_width% = skulls_per_row * sk_w
	Local tally_x% = (SETTINGS_REGISTER.WINDOW_WIDTH.get() - area_width)/2
	Local elapsed% = now() - start_ts
	Local s% = elapsed / fade_in_time 'current skull fading in
	Local cursor:CELL = New CELL
	Local ts%
	
	reset_draw_state()
	For Local i% = 0 Until count
		If i < s
			SetAlpha( 1 )
		Else If i = s
			ts = start_ts + (s * fade_in_time) 'the point in time that this specific skull should start fading in
			SetAlpha( time_alpha_pct( ts, fade_in_time, True ))
		Else 'i > s
			Continue 'skip this iteration entirely, nothing to draw
		End If

		DrawImage( skull_1x, tally_x + sk_w * cursor.col, tally_y + sk_h * cursor.row )

		cursor.col :+ 1
		If cursor.col >= skulls_per_row
			cursor.col = 0
			cursor.row :+ 1
		End If
	Next
End Function







