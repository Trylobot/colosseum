Rem
	shop.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function draw_shop()
	Local x%, y%, h%
	Local cx%, cy%
	
	x = 25; y = 25
	SetColor( 127, 255, 127 )
	SetImageFont( get_font( "consolas_bold_50" )); h = GetImageFont().Height() - 1
	DrawText_with_glow( "Quarters", x, y ); y :+ 1.5*h
	
	SetColor( 255, 255, 255 )
	SetImageFont( get_font( "consolas_bold_24" )); h = GetImageFont().Height() - 1
	DrawText( "play", x, y ); y :+ h
	
	SetImageFont( get_font( "consolas_12" )); h = GetImageFont().Height() - 1
	DrawText( "profile [" + profile.profile_name + "]" , x, y ); y :+ h
	DrawText( "cash    $" + format_number( profile.cash ), x, y ); y :+ h
	DrawText( "kills    " + format_number( profile.kills ), x, y ); y :+ h
	DrawText( "inventory", x, y ); y :+ h
	SetLineWidth( 1 )
	SetColor( 127, 127, 127 )
	DrawRectLines( x, y, profile.inventory.Length*50, 50 )
	SetColor( 255, 255, 255 )
	cx = x + 50/2; cy = y + 50/2
	Local inventory_y% = cy
	For Local i% = 0 To profile.inventory.Length - 1
		Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[profile.inventory[i]] ))
		ag.pos_x = cx; ag.pos_y = cy; ag.ang = -45
		ag.snap_all_turrets
		ag.update()
		ag.draw()
		cx :+ 50
	Next
	y :+ 50 + 3
	SetRotation( 0 )
	DrawText( "selected", x, y );
	cx = x + TextWidth("selected") + 8
	cy = y + GetImageFont().Height()/2
	DrawOval( cx-2,cy-2, 4,4 )
	DrawLine( cx,cy, x + 50/2 + 50*profile.selected_inventory_index, inventory_y + 50/2 )
	DrawOval( x + 50/2 + 50*profile.selected_inventory_index - 2, inventory_y + 50/2 - 2, 4,4 )
	
	'selected option
	
	'text input cursor
	If text_input_mode
		
	End If
	
End Function

'shop options
reset_index()
Global SHOP_OPTION_GO% = postfix_index()
Global SHOP_OPTION_PROFILE_NAME% = postfix_index()
Global SHOP_OPTION_INVENTORY_SELECT% = postfix_index()
Global SHOP_OPTION_3% = postfix_index()
Global SHOP_OPTION_4% = postfix_index()

'shop variables
Global shop_console:CONSOLE = New CONSOLE
Global text_input_mode% = False
Global shop_option% = SHOP_OPTION_GO

Function get_shop_input()
	'execute option
	If KeyHit( KEY_ENTER )
		Select shop_option
			
			Case SHOP_OPTION_GO
				profile.current_level = data_path + "maze.colosseum_level"
				play_level( profile.current_level, profile.inventory[profile.selected_inventory_index] )
			
			Case SHOP_OPTION_PROFILE_NAME
				text_input_mode = Not text_input_mode
			
			Case SHOP_OPTION_INVENTORY_SELECT
				
			
		End Select
	End If
	'text input
	If text_input_mode
		profile.profile_name = shop_console.update( profile.profile_name )
	End If
	
	
End Function


