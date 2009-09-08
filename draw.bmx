Rem
	draw.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "environment.bmx"
Import "core.bmx"
Import "instaquit.bmx"
Import "settings.bmx"
Import "particle.bmx"
Import "door.bmx"
Import "agent.bmx"
Import "projectile.bmx"
Import "pickup.bmx"
Import "complex_agent.bmx"
Import "widget.bmx"
Import "net.bmx"
Import "control_brain.bmx"
Import "menu.bmx"
Import "inventory_data.bmx"
Import "point.bmx"
Import "turret.bmx"
Import "vec.bmx"
Import "box.bmx"
Import "level.bmx"
Import "image_manip.bmx"
Import "drawtext_ex.bmx"
Import "flags.bmx"
Import "hud.bmx"
Import "mouse.bmx"
Import "input.bmx"

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
	If game <> Null
		draw_game()
		SetColor( 255, 255, 255 )
		SetRotation( 0 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetLineWidth( 1 )
	End If
	
	'menus and such
	If FLAG.in_menu
		'dimmer
		SetColor( 0, 0, 0 )
		SetAlpha( 0.5 )
		DrawRect( 0, 0, window_w, window_h )
		
		If FLAG.in_menu
			draw_main_screen()
		End If
	End If
	
	'instaquit
	If KeyDown( KEY_ESCAPE ) And esc_held And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
		draw_instaquit_progress()
	End If
	
End Function

'______________________________________________________________________________
'In-game stuff
Function draw_game()
	SetBlend( ALPHABLEND )
	SetOrigin( 0, 0 )
	
	'update graffiti manager (for particles that wish to be retained)
	If game.retained_particle_count >= active_particle_limit
		game.graffiti.add_graffiti( game.retained_particle_list )
		game.retained_particle_list.Clear()
		game.retained_particle_count = 0
	End If

	SetOrigin( game.drawing_origin.x, game.drawing_origin.y )
	
	'arena background + retained particles
	SetColor( 255, 255, 255 )
	SetRotation( 0 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	game.graffiti.draw()

	'background particles
	For Local part:PARTICLE = Eachin game.retained_particle_list
		part.draw()
	Next
	For Local part:PARTICLE = EachIn game.particle_list_background
		part.draw()
	Next
	
	'door backgrounds
	For Local list:TList = EachIn game.door_lists
		For Local d:DOOR = EachIn list
			d.draw_bg()
		Next
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
	
	'environmental widgets
	For Local w:WIDGET = EachIn game.environmental_widget_list
		w.draw()
	Next

	'door foregrounds
	For Local list:TList = EachIn game.door_lists
		For Local d:DOOR = EachIn list
			d.draw_fg()
		Next
	Next

	If game.human_participation
		draw_lighting_and_effects()
	End If
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetAlpha( 1 )

	'enemy life bars
'	For Local list:TList = EachIn game.complex_agent_lists
'		For Local cmp_ag:COMPLEX_AGENT = EachIn list
'			draw_percentage_bar( cmp_ag.pos_x - 10, cmp_ag.pos_y + 15, 20, 5, (cmp_ag.cur_health/cmp_ag.max_health), 0.35 )
'		Next
'	Next

	'aimer
	draw_reticle()
	SetRotation( 0 )
	
	If game.human_participation
		'player tips
		Local player_msg$ = Null
		SetImageFont( get_font( "consolas_10" ))
		If Not game.game_in_progress
			player_msg = "press enter"
		End If
		If player_msg <> Null
			DrawText_with_outline( player_msg, game.player.pos_x - TextWidth( player_msg )/2, game.player.pos_y + game.player.img.height + 3 )
		End If
		'multiplayer name tags
		If playing_multiplayer
			'for the local player and each remote player, draw a name tag
			draw_nametag( profile.name, game.player.to_cvec() )
			For Local rp:REMOTE_PLAYER = EachIn remote_players.Values()
				If rp And rp.loaded
					draw_nametag( rp.name, rp.avatar.to_cvec() )
				End If
			Next
		End If
	End If

	SetOrigin( 0, 0 )
	
	If game.human_participation
		'hud
		draw_HUD()
		'health bits
		For Local health_bit:WIDGET = EachIn health_bits
			health_bit.draw()
		Next
		'win message
		If Not game.game_in_progress And Not game.player.dead()
			SetColor( 255, 255, 255 )
			SetScale( 1, 1 )
			SetRotation( 0 )
			SetImageFont( get_font( "consolas_bold_50" ))
			SetAlpha( time_alpha_pct( game.battle_state_toggle_ts, 1200 ))
			Local win_msg$ = "LEVEL COMPLETE!"
			DrawText_with_glow( win_msg, window_w/2 - TextWidth(win_msg)/2, 10 )
		End If
		'help screen
		If FLAG_draw_help
			Local img_help_kb:TImage = get_image( "help_kb" )
			Local img_help_kb_mouse:TImage = get_image( "help_kb_and_mouse" )
			SetColor( 0, 0, 0 )
			SetAlpha( 0.550 )
			DrawRect( 0, 0, window_w, window_h )
			SetColor( 255, 255, 255 )
			SetAlpha( 1 )
			If profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD
				DrawImage( img_help_kb, window_w/2 - img_help_kb.width/2, window_h/2 - img_help_kb.height/2 )
			Else If profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
				DrawImage( img_help_kb_mouse, window_w/2 - img_help_kb_mouse.width/2, window_h/2 - img_help_kb_mouse.height/2 )
			End If
		End If
	End If

	'game over indicator (if game over)
	If game.game_over
		SetColor( 0, 0, 0 )
		SetAlpha( 0.65 )
		SetScale( 1, 1 )
		SetRotation( 0 )
		DrawRect( 0, 0, window_w, window_h )
		SetImageFont( get_font( "consolas_bold_100" ))
		Local w% = TextWidth( "GAME OVER" )
		Local h% = GetImageFont().Height()
		SetColor( 255, 0, 0 )
		DrawText_with_outline( "GAME OVER", window_w/2 - w/2, window_h/2 - h/2 )
	End If
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	
End Function
'______________________________________________________________________________
'Menu and GUI
Function draw_main_screen()
	Local x%, y%, h%
	x = main_screen_x
	
	'title
	y = main_screen_y
	SetColor( 255, 255, 127 )
	SetAlpha( 1 )
	SetImageFont( get_font( "consolas_bold_50" ))
	DrawText_with_outline( AppTitle, x, y )
	
	'info
	SetImageFont( get_font( "consolas_italic_12" ))
	'SetColor( 100, 149, 237 ) 'Cornflower Blue
	SetColor( 255, 255, 127 ) 'Title Yellow
	SetAlpha( time_alpha_pct( info_change_ts + info_stay_time, info_fade_time, False ))
	y = 57
	DrawText_with_outline( info, x, y)
	
	'menu options
	draw_menus()
	
	'credits/copyright stuff
	SetAlpha( 1 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 157, 157, 157 )
	SetImageFont( get_font( "consolas_10" ))
	h = 0.75*TextHeight( info )
	x = 1
	y = window_h - h*3 - 1
	If Not main_game
		DrawText_with_outline( "COLOSSEUM   2008 Tyler W.R. Cole (aka Tylerbot), written in 100% BlitzMax", x, y ); y :+ h
		DrawText_with_outline( "music by NickPerrin and Yoshi-1up, JSON binding by grable", x, y ); y :+ h
		DrawText_with_outline( "thanks to Kaze, SniperAceX, A.E.Mac, ZieramsFolly, Firelord88", x, y ); y :+ h
	End If
	
End Function
'______________________________________________________________________________
Function draw_menus()
	
	SetAlpha( 1 )
	Local cx% = main_screen_x
	Local cy% = main_screen_menu_y
	Local alpha#
	Local blink%
	Local popup% = MENU.is_popup( get_menu( menu_stack[current_menu] ).menu_type )
	For Local i% = 0 To current_menu
		Local m:MENU = get_menu( menu_stack[i] )
		If i = current_menu Or ( popup And i = current_menu - 1 )
			cx = main_screen_x
			cy = main_screen_menu_y + breadcrumb_h - 1
			blink = True
			If popup
				If i = current_menu
					SetColor( 0, 0, 0 )
					SetAlpha( 0.5 )
					DrawRect( 0, 0, window_w, window_h )
					'cx :+ 25
					cy :+ get_menu( menu_stack[i - 1] ).get_focus_offset()
				Else 'i <> current_menu
					blink = False
				End If
			End If
			'/////////////////////////
			m.draw( mouse, dragging_scrollbar,,, blink )
			'/////////////////////////
			'shop decorations
			If m.menu_type = MENU.VERTICAL_LIST_WITH_INVENTORY
				'draw the object to which the focused menu option refers, off to the side a bit.
				Local item:INVENTORY_DATA = INVENTORY_DATA( m.get_focus().argument )
				Local inventory_object:POINT = POINT( bake_item( item ))
				If inventory_object
					cx :+ m.width + 10
					cy :+ m.get_focus_offset()
					If TURRET(inventory_object)
						TURRET(inventory_object).set_images_unfiltered()
						TURRET(inventory_object).scale_all( MOUSE_SHADOW_SCALE )
						If TURRET(inventory_object).img
							cx :+ 3*TURRET(inventory_object).img.handle_x
						Else 'ghost base for turrets with none
							SetColor( 255, 255, 255 )
							SetAlpha( 0.15 )
							DrawRect( cx, cy, 25, 25 )
							DrawRectLines( cx, cy, 25, 25 )
							cx :+ 12.5
						End If
					Else If COMPLEX_AGENT(inventory_object)
						COMPLEX_AGENT(inventory_object).set_images_unfiltered()
						COMPLEX_AGENT(inventory_object).scale_all( MOUSE_SHADOW_SCALE )
						If COMPLEX_AGENT(inventory_object).img
							cx :+ 3*COMPLEX_AGENT(inventory_object).img.handle_x
						End If
					End If
					Local a# = 1.0
					If item.damaged Then a = 0.15
					inventory_object.move_to( Create_cVEC( cx, cy + 12.5 ), True, True )
					inventory_object.draw( a, MOUSE_SHADOW_SCALE )
					If item.damaged
						SetColor( 255, 127, 127 )
						SetAlpha( 1 )
						SetScale( 1, 1 )
						SetRotation( -20 )
						DrawText_with_outline( "DAMAGED!", main_screen_x + m.width + 15, cy + 12.5 )
					End If
				End If
			End If
		Else 'not current menu (or 1 before in case of popup)
			SetAlpha( 1 )
			cx :+ 2
			SetImageFont( get_font( "consolas_10" ))
			Local width% = TextWidth( m.short_name ) + 4*1 + 4
			SetColor( 64, 64, 64 )
			DrawRect( cx, cy, width, breadcrumb_h )
			SetColor( m.red/2, m.green/2, m.blue/2 )
			DrawRect( cx+1, cy+1, width - 2*1, breadcrumb_h - 2*1 )
			SetColor( m.red, m.green, m.blue )
			DrawText_with_outline( m.short_name, cx+1+4, cy+1+1, 0.5 )
			SetColor( 0, 0, 0 )
			SetAlpha( 0.3 )
			DrawRect( cx, cy, width, breadcrumb_h )
			cx :+ width
		End If
	Next
	
	'older "menu stack" menu drawing method
	Rem
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
	End Rem
End Function
'______________________________________________________________________________
Function draw_arena_fg()
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	
	DrawImage( game.foreground, 0, 0 )
End Function

Function draw_lighting_and_effects()
	'darkness
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetColor( 0, 0, 0 )
	SetAlpha( 0.6*time_alpha_pct( game.battle_state_toggle_ts, arena_lights_fade_time, Not game.battle_in_progress ))
	DrawRect( 0,0, game.lev.width,game.lev.height )
	'spotlight
	SetBlend( LIGHTBLEND )
	SetColor( 255, 255, 255 )
	SetAlpha( 0.35*time_alpha_pct( game.battle_state_toggle_ts, arena_lights_fade_time, Not game.battle_in_progress ))
	If game.player <> Null
		SetScale( 1, 1 )
		DrawImage( get_image( "halo" ), game.player.pos_x, game.player.pos_y )
	End If
	
	SetBlend( ALPHABLEND )
End Function

'______________________________________________________________________________
Global last_pos:POINT
Global cur_alpha#, last_alpha#
Global lag_aimer:cVEC

Function draw_reticle()
	If game.human_participation
		If game.player.turrets <> Null
			Local tur:TURRET = game.player.turrets[0]
			Local img_reticle:TImage = get_image( "reticle" )
			Local img_ghost_reticle:TImage = get_image( "ghost_reticle" )
			'KEYBOARD/MOUSE
			If profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
				'turret ghost reticle
				Local distance_from_turret_to_mouse# = tur.dist_to( game_mouse ) 
				SetRotation( tur.ang )
				Local ang_diff# = ang_wrap( tur.ang_to( game_mouse ) - tur.ang )
				SetAlpha( 1 - Abs(ang_diff)/22.5 )
				DrawImage( img_ghost_reticle, tur.pos_x + distance_from_turret_to_mouse * Cos( tur.ang ), tur.pos_y + distance_from_turret_to_mouse * Sin( tur.ang ))
				'actual mouse reticle
				SetRotation( tur.ang_to( game_mouse ))
				SetAlpha( 1.0 )
				DrawImage( img_reticle, game_mouse.x, game_mouse.y )
			'KEYBOARD ONLY
			Else If profile.input_method = CONTROL_BRAIN.INPUT_KEYBOARD
				SetRotation( tur.ang )
				DrawImage( img_reticle, tur.pos_x + 85*Cos( tur.ang ), tur.pos_y + 85*Sin( tur.ang ))
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
	w = health_bar_w
	h = health_bar_h
	
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
	Local img_health_mini:TImage = get_image( "health_mini" )
	DrawImage( img_health_mini, x, y )
	Local pct# = game.player.cur_health/game.player.max_health
	Local c% = 255
	If pct <= 0.33333 Then c = 255 * Sin( now() Mod 180 )
	draw_percentage_bar( x + img_health_mini.width + 3,y, w,h, pct, 1.0, 255, c, c ) ', (1 - (0.5*pct)) )
	
	y = y2
	'player cash
	SetColor( 85, 255, 85 ) 'Cash Green
	SetImageFont( get_font( "consolas_bold_14" ))
	str = "$" + format_number( profile.cash )
	DrawText_with_outline( str, x, y+1-3 )
	If now() - last_kill_ts <= 1250
		SetAlpha( time_alpha_pct( last_kill_ts, 1250, False ))
		DrawText_with_glow( str, x, y+1-3 )
		SetAlpha( 0.3333*GetAlpha() )
		DrawImage( get_image( "halo" ), x + TextWidth(str)/2.0, y+1-3 + TextHeight(str)/2.0 )
	End If
	x :+ w + HORIZONTAL_HUD_MARGIN
	SetImageFont( get_font( "consolas_10" ))
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
			DrawText_with_outline( t.name, x, y-3 ); 'x :+ TextWidth( t.name ) + 3
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
	Local img_icon_music_note:TImage = get_image( "icon_music_note" )
	Local img_icon_speaker_on:TImage = get_image( "icon_speaker_on" )
	Local img_icon_speaker_off:TImage = get_image( "icon_speaker_off" )
	SetAlpha( 0.5 )
	Local music_str$ = "[m]usic"
	x = window_w - 10 - TextWidth( music_str )
	y = y1
	SetColor( 255, 255, 255 )
	DrawText_with_outline( music_str, x, y )
	y = y2
	Local img_spkr:TImage
	If FLAG.bg_music
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
	DrawText_with_outline( "F1 for help", window_w - TextWidth("F1 for help") - 10, window_h - 55 )
	
	'multiplayer chat messages (if applicable)
	If playing_multiplayer
		draw_chats()
	End If
	
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
		DrawRect( 0, 0, window_w, window_h )
		Flip()
	End While
	Return
End Function
'______________________________________________________________________________
Function generate_level_mini_preview:TImage( lev:LEVEL )
	Local pixmap:TPixmap = CreatePixmap( lev.width,lev.height, PF_RGBA8888 )
	pixmap.ClearPixels( encode_ARGB( 1.0, 64,64,64 ))
	For Local w:BOX = EachIn lev.get_walls()
		pixmap.window( w.x, w.y, w.w, w.h ).ClearPixels( encode_ARGB( 1.0, 127,127,127 ))
	Next
	Return LoadImage( pixmap, FILTEREDIMAGE|DYNAMICIMAGE )
End Function

'______________________________________________________________________________
Function draw_chats()
	Local x_start% = 5
	Local y_start% = window_h - 53
	Local y_current% = y_start
	Local line_h% = 14
	SetImageFont( get_font( "consolas_14" ))
	Local prefix$
	'draw chat being entered
	If FLAG.chat_mode
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		DrawText_with_outline( chat, x_start, y_current )
		SetColor( 255, 255, 255 )
		SetAlpha( 0.5 + Sin(now() Mod 360) )
		DrawText_with_outline( "|", x_start + TextWidth( chat ) - Int(TextWidth( "|" )/3), y_current )
		y_current :- line_h
	End If
	'draw chat log
	For Local cm:CHAT_MESSAGE = EachIn chat_message_list
		SetAlpha( time_alpha_pct( cm.added_ts + chat_stay_time, chat_fade_time, False ))
		If cm.from_self
			SetColor( 255, 233,   0 ) 'gold
		Else
			SetColor( 226, 226, 226 ) 'light gray
		End If
		DrawText_with_outline( cm.username+" ", x_start, y_current )
		If cm.from_self
			SetColor( 255, 255, 255 ) 'white
		Else
			SetColor( 170, 170, 170 ) 'gray
		End If
		DrawText_with_outline( cm.message, x_start + TextWidth( cm.username+" " ), y_current )
		y_current :- line_h
	Next
End Function

'______________________________________________________________________________
Function draw_nametag( name$, anchor:cVEC, y_offset% = 27 )
	anchor = anchor.clone()
	anchor.y :+ y_offset
	SetImageFont( get_font( "consolas_bold_10" ))
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







