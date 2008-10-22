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
'shop items
Global shop_items%[] =       [     0,     1,     2 ]
Global shop_item_prices%[] = [   500,  2500, 10000 ]
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
	SetColor( 255, 255, 255 )
	SetImageFont( get_font( shop_option_font_name_title )); h = GetImageFont().Height() - 1
	DrawText_with_glow( "Loading Bay", x, y ); y :+ 1.25*h
	
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
	If Not (profile.inventory = Null Or profile.inventory.Length = 0)
'		SetColor( 96, 96, 96 )
'		SetImageFont( get_font( shop_option_font_name_not_selected ))
'		DrawText( "[0 vehicles owned]", cx - TextWidth( "[0 vehicles owned]" )/2, cy - GetImageFont().Height() - 1 )
'		y :+ GetImageFont().Height() - 1
'	Else
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
	End If
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
	'execute option
	If KeyHit( KEY_ENTER )
		Select shop_option
			
			Case SHOP_OPTION_GO
				If profile.current_level <> "" And Not (profile.inventory = Null Or profile.inventory.Length = 0)
					play_level( profile.current_level, profile.inventory[profile.selected_inventory_index] )
				Else
					If profile.current_level = ""
						display_error( "no level selected;~nselect one below" )
					Else If profile.inventory = Null Or profile.inventory.Length = 0
						display_error( "no vehicle selected;~nbuy one at the shop" )
					End If
				End If
			
			Case SHOP_OPTION_PROFILE_NAME
				FlushKeys()
				text_input_mode = Not text_input_mode
			
			Case SHOP_OPTION_INVENTORY_SELECT
				If Not (profile.inventory = Null Or profile.inventory.Length = 0)
					inventory_select()
				Else
					display_error( "inventory is empty;~nbuy stuff at the shop" )
				End If
					
			Case SHOP_OPTION_LEVEL_SELECT
				level_select()
			
			Case SHOP_OPTION_BUY_STUFF
				If shop_items_left_to_purchase()
					buy_stuff()
				Else
					display_error( "you own everything" )
				End If
			
		End Select
	End If
	If Not text_input_mode
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
	Else 'text_input_mode
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
		SetColor( 255, 255, 255 )
		SetImageFont( get_font( shop_option_font_name_not_selected ))
		For Local i% = 0 To profile.inventory.Length - 1
			Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[profile.inventory[i]] ))
			ag.pos_x = cx; ag.pos_y = cy; ag.ang = -45
			ag.snap_all_turrets
			ag.update()
			Local alpha# = 0.3333
			If i = profile.selected_inventory_index
				alpha = 1.0
				SetScale( 1, 1 )
				SetRotation( 0 )
				SetAlpha( 1 )
				SetColor( 255, 255, 255 )
				DrawText( ag.name, cx - TextWidth( ag.name )/2, cy + spacing/2 + 3 )
				SetColor( 127, 127, 127 )
				DrawText( "[ENTER] equip", cx - TextWidth( "[ENTER] equip" )/2, cy + spacing/2 + 3 + 1.5*(GetImageFont().Height() - 1))
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
	Local bg:TPixmap = GrabPixmap( 0, 0, window_w, window_h )
	Local level_select_index% = 0
	Local level_files$[]
	
	'data read from disk
	Local level_files_list:TList = find_files( data_path, level_file_ext )
	level_files = New String[level_files_list.Count()]
	For Local i% = 0 To level_files.Length - 1
		level_files[i] = String(level_files_list.ValueAtIndex(i))
	Next
	'size calculate, and current selected index
	Local spacing% = 26
	SetImageFont( get_font( shop_option_font_name_selected ))
	Local widths#[] = New Float[level_files.Length]
	For Local i% = 0 To level_files.Length - 1
		widths[i] = TextWidth( StripAll( level_files[i] ))
		If level_files[i] = profile.current_level
			level_select_index = i
		End If
	Next
	Local w% = widths[maximum(widths)] + spacing
	Local h% = GetImageFont().Height()*level_files.Length + spacing
	
	Repeat
		Cls
		
		'position
		Local cx% = shop_margin
		Local cy% = level_y
		
		'draw
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetColor( 0, 0, 0 )
		SetAlpha( 0.75 )
		DrawPixmap( bg, 0, 0 ) 'pixmaps not affected by draw state
		DrawRect( 0, 0, window_w, window_h )

		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetColor( 127, 127, 127 )
		DrawRect( cx, cy, w, h )
		SetColor( 0, 0, 0 )
		DrawRect( cx+3, cy+3, w-6, h-6 )
		cx :+ spacing/2
		cy :+ spacing/2
		For Local i% = 0 To level_files.Length - 1
			Local str$ = StripAll( level_files[i] )
			If i = level_select_index
				SetColor( 255, 255, 255 )
				DrawText_with_glow( str, cx, cy )
			Else
				SetColor( 127, 127, 127 )
				DrawText( str, cx, cy )
			End If
			cy :+ GetImageFont().Height()
		Next
		
		Flip( 1 )
		
		'input
		If KeyHit( KEY_DOWN )
			level_select_index :+ 1
			If level_select_index > level_files.Length - 1
				level_select_index = 0
			End If
		End If
		If KeyHit( KEY_UP )
			level_select_index :- 1
			If level_select_index < 0
				level_select_index = level_files.Length - 1
			End If
		End If
		
	Until KeyHit( KEY_ENTER ) Or KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
	
	profile.current_level = level_files[level_select_index]
	
End Function
'______________________________________________________________________________
Function buy_stuff()
	Local bg:TPixmap = GrabPixmap( 0, 0, window_w, window_h )
	Local selected_shop_item_index%
	
	Repeat
		Cls
		
		'position
		Local cx% = shop_margin
		Local cy% = buy_stuff_y
		
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
		DrawRect( cx, cy, shop_items.Length*spacing, spacing )
		SetColor( 0, 0, 0 )
		DrawRect( cx+3, cy+3, shop_items.Length*spacing-6, spacing-6 )
		cx :+ spacing/2
		cy :+ spacing/2
		SetColor( 255, 255, 255 )
		SetImageFont( get_font( shop_option_font_name_not_selected ))
		For Local i% = 0 To shop_items.Length - 1
			Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[shop_items[i]] ))
			ag.pos_x = cx; ag.pos_y = cy; ag.ang = -45
			ag.snap_all_turrets
			ag.update()
			Local alpha# = 0.3333
			If Not one_of( shop_items[i], profile.inventory )
				alpha = 1.0
			End If
			If i = selected_shop_item_index
				SetColor( 255, 255, 255 )
				DrawText( ag.name, cx - TextWidth( ag.name )/2, cy + spacing/2 + 3 )
				SetColor( 96, 255, 96 )
				DrawText( format_number( shop_item_prices[i] ), cx - TextWidth( format_number( shop_item_prices[i] ))/2, cy + spacing/2 + 3 + GetImageFont().Height() - 1 )
				SetColor( 127, 127, 127 )
				If Not one_of( shop_items[i], profile.inventory )
					If profile.cash >= shop_item_prices[selected_shop_item_index]
						DrawText( "[ENTER] buy item", cx - TextWidth( "[ENTER] buy item" )/2, cy + spacing/2 + 3 + 2.5*(GetImageFont().Height() - 1))
					Else
						DrawText( "too expensive", cx - TextWidth( "too expensive" )/2, cy + spacing/2 + 3 + 2.5*(GetImageFont().Height() - 1))
					End If
				End If
			End If
			ag.draw( ,,,, alpha, 2 )
			SetScale( 1, 1 )
			SetRotation( 0 )
			SetAlpha( 1 )
			cx :+ spacing
		Next
		
		Flip( 1 )
		
		'input
		If KeyHit( KEY_RIGHT )
			selected_shop_item_index :+ 1
			If selected_shop_item_index > shop_items.Length - 1
				selected_shop_item_index = 0
			End If
		End If
		If KeyHit( KEY_LEFT )
			selected_shop_item_index :- 1
			If selected_shop_item_index < 0
				selected_shop_item_index = shop_items.Length - 1
			End If
		End If
		
		If KeyHit( KEY_ENTER )
			If ..
			Not( one_of( shop_items[selected_shop_item_index], profile.inventory )) ..
			And profile.cash >= shop_item_prices[selected_shop_item_index]
				profile.cash :- shop_item_prices[selected_shop_item_index]
				profile.inventory = profile.inventory[..profile.inventory.Length+1]
				profile.inventory[profile.inventory.Length-1] = shop_items[selected_shop_item_index]
			End If
		End If
		
	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
End Function
'______________________________________________________________________________
Function shop_items_left_to_purchase%()
	If profile.inventory = Null Or profile.inventory.Length = 0
		Return True
	End If
	For Local i% = 0 To shop_items.Length - 1
		If one_of( shop_items[i], profile.inventory )
			Return True
		End If
	Next
	Return False
End Function
'______________________________________________________________________________
Function display_error( error$ )
	Local bg:TPixmap = GrabPixmap( 0, 0, window_w, window_h )
	Local error_lines$[] = error.Split( "~n" )
	SetImageFont( get_font( shop_option_font_name_selected ))
	Local widths#[] = New Float[error_lines.Length]
	For Local i% = 0 To widths.Length - 1
		widths[i] = TextWidth( error_lines[i] )
	Next
	'draw loop
	Repeat
		'size
		Local w% = 2*shop_margin + widths[maximum(widths)]
		Local h% = 2*shop_margin + error_lines.Length*(GetImageFont().Height() - 1)
		Local cx% = window_w/2 - w/2
		Local cy% = window_h/2 - h/2
		Cls
		DrawPixmap( bg, 0, 0 )
		SetScale( 1, 1 )
		SetColor( 0, 0, 0 )
		SetAlpha( 0.75 )
		SetRotation( 0 )
		DrawRect( 0, 0, window_w, window_h )
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetColor( 127, 127, 127 )
		DrawRect( cx, cy, w, h )
		SetColor( 0, 0, 0 )
		DrawRect( cx+3, cy+3, w-6, h-6 )
		cx :+ shop_margin; cy :+ shop_margin
		SetColor( 255, 96, 96 )
		For Local i% = 0 To error_lines.Length - 1
			DrawText( error_lines[i], cx, cy )
			cy :+ GetImageFont().Height() - 1
		Next
		Flip( 1 )
	Until KeyHit( KEY_ENTER ) Or KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
End Function
