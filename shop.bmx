Rem
	shop.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'shop options
reset_index()
Global SHOP_OPTION_GO% = postfix_index()
Global SHOP_OPTION_PROFILE_NAME% = postfix_index()
Global SHOP_OPTION_INVENTORY_SELECT% = postfix_index()
Global SHOP_OPTION_LEVEL_SELECT% = postfix_index()
Global SHOP_OPTION_BUY_STUFF% = postfix_index()
Global shop_option_count% = array_index
Global shop_option% = SHOP_OPTION_GO
Global shop_option_font_name_title$ = "consolas_bold_50"
Global shop_option_font_name_selected$ = "consolas_bold_24"
Global shop_option_font_name_not_selected$ = "consolas_12"
'input
Global shop_console:CONSOLE = New CONSOLE
Global text_input_mode% = False
'positioning
Global shop_margin% = 25
Global profile_name_y%
Global inventory_y%
Global level_y%
Global buy_stuff_y%
'______________________________________________________________________________
Function draw_shop()
	Local x%, y%, h%
	Local cx%, cy%
	
	SetRotation( 0 )
	SetScale( 1, 1 )
	
	x = shop_margin; y = shop_margin
	SetColor( 127, 255, 127 )
	SetImageFont( get_font( shop_option_font_name_title )); h = GetImageFont().Height() - 1
	DrawText_with_glow( "Quarters", x, y ); y :+ 1.25*h
	
	SetImageFont( get_font( shop_option_font_name_selected )); h = GetImageFont().Height() - 1
	SetColor( 96, 255, 96 )
	DrawText_with_glow( "$" + format_number( profile.cash ), x, y ); y :+ h
	SetColor( 255, 96, 96 )
	DrawText_with_glow( "kills  " + format_number( profile.kills ), x, y ); y :+ h
	y :+ h
	draw_shop_option( "play", (shop_option = SHOP_OPTION_GO), x, y )
	profile_name_y = y
	draw_shop_option( "profile " + profile.profile_name, (shop_option = SHOP_OPTION_PROFILE_NAME), x, y )
	draw_shop_option( "current vehicle", (shop_option = SHOP_OPTION_INVENTORY_SELECT), x, y )
	inventory_y = y
	Local spacing% = 50
	SetLineWidth( 1 )
	SetColor( 127, 127, 127 )
	DrawRectLines( x, y, profile.inventory.Length*spacing, spacing )
	
	SetColor( 255, 255, 255 )
	cx = x + spacing/2
	cy = y + spacing/2
	For Local i% = 0 To profile.inventory.Length - 1
		Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[profile.inventory[i]] ))
		ag.pos_x = cx; ag.pos_y = cy; ag.ang = -45
		ag.snap_all_turrets
		ag.update()
		Local alpha# = 0.3333
		If i = profile.selected_inventory_index
			alpha = 1.0
		End If
		ag.draw( ,,,, alpha )
		cx :+ spacing
	Next
	y :+ 50 + 3
	SetRotation( 0 )
	draw_shop_option( "level " + StripAll( profile.current_level ), (shop_option = SHOP_OPTION_LEVEL_SELECT), x, y )
	level_y = y
	draw_shop_option( "shop", (shop_option = SHOP_OPTION_BUY_STUFF), x, y )
	buy_stuff_y = y

	'text input cursor
	If text_input_mode
		SetImageFont( get_font( shop_option_font_name_selected ))
		SetAlpha( 0.5 + Sin(now() Mod 360) )
		DrawText( "|", shop_margin + TextWidth( "profile " + profile.profile_name ) - 4, profile_name_y )
	End If
	
End Function
'______________________________________________________________________________
Function draw_shop_option( str$, selected% = False, x%, y% Var )
	If selected
		SetColor( 255, 255, 255 )
		SetImageFont( get_font( shop_option_font_name_selected ))
	Else
		SetColor( 196, 196, 196 )
		SetImageFont( get_font( shop_option_font_name_not_selected ))
	End If
	DrawText_with_glow( str, x, y )
	y :+ GetImageFont().Height() - 1
End Function
'______________________________________________________________________________
Function get_shop_input()
	'choose option
	If KeyHit( KEY_DOWN )
		shop_option :+ 1
		If shop_option >= shop_option_count
			shop_option = 0
		End If
	End If
	If KeyHit( KEY_UP )
		shop_option :- 1
		If shop_option < 0
			shop_option = shop_option_count - 1
		End If
	End If
	'execute option
	If KeyHit( KEY_ENTER )
		Select shop_option
			
			Case SHOP_OPTION_GO
				profile.current_level = data_path + "debug.colosseum_level"
				play_level( profile.current_level, profile.inventory[profile.selected_inventory_index] )
			
			Case SHOP_OPTION_PROFILE_NAME
				FlushKeys()
				text_input_mode = Not text_input_mode
			
			Case SHOP_OPTION_INVENTORY_SELECT
				inventory_select()
				
			Case SHOP_OPTION_LEVEL_SELECT
				level_select()
			
			Case SHOP_OPTION_BUY_STUFF
				buy_stuff()
			
		End Select
	End If
	'text input
	If text_input_mode
		profile.profile_name = shop_console.update( profile.profile_name )
	End If
	
End Function
'______________________________________________________________________________
Function inventory_select()
	Local bg:TPixmap = GrabPixmap( 0, 0, window_w, window_h )
	
	Repeat
		Cls
		
		'position
		Local cx% = shop_margin
		Local cy% = inventory_y
		
		'draw
		DrawPixmap( bg, 0, 0 )
		SetScale( 1, 1 )
		SetColor( 0, 0, 0 )
		SetAlpha( 0.75 )
		SetRotation( 0 )
		DrawRect( 0, 0, window_w, window_h )

		SetColor( 255, 255, 255 )
		Local spacing% = 100
		SetAlpha( 1 )
		SetColor( 127, 127, 127 )
		DrawRect( cx, cy, profile.inventory.Length*spacing, spacing )
		SetColor( 0, 0, 0 )
		DrawRect( cx+3, cy+3, profile.inventory.Length*spacing-6, spacing-6 )
		cx :+ spacing/2
		cy :+ spacing/2
		SetScale( 2, 2 )
		For Local i% = 0 To profile.inventory.Length - 1
			Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[profile.inventory[i]] ))
			ag.pos_x = cx; ag.pos_y = cy; ag.ang = -45
			ag.snap_all_turrets
			ag.update()
			Local alpha# = 0.3333
			If i = profile.selected_inventory_index
				alpha = 1.0
			End If
			ag.draw( ,,,, alpha, 2 )
			cx :+ spacing
		Next
		
		Flip( 1 )
		
		'input
		If KeyHit( KEY_RIGHT )
			profile.selected_inventory_index :+ 1
			If profile.selected_inventory_index > profile.inventory.Length - 1
				profile.selected_inventory_index = 0
			End If
		End If
		If KeyHit( KEY_LEFT )
			profile.selected_inventory_index :- 1
			If profile.selected_inventory_index < 0
				profile.selected_inventory_index = profile.inventory.Length - 1
			End If
		End If
		
	Until KeyHit( KEY_ENTER ) Or KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
End Function
'______________________________________________________________________________
Function level_select()
	
End Function
'______________________________________________________________________________
Function buy_stuff()
	
End Function

