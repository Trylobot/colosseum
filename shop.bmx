Rem
	shop.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'shop state flags
Global shop_option%
Global shop_all_options

'______________________________________________________________________________
Function draw_shop()
	Local x%, y%, h%
	Local cx%, cy%
	
	x = 25; y = 25
	SetColor( 127, 255, 127 )
	SetImageFont( get_font( "consolas_bold_50" )); h = GetImageFont().Height() - 1
	DrawText_with_glow( "Quarters", x, y ); y :+ 1.5*h
	
	SetColor( 255, 255, 255 )
	SetImageFont( get_font( "consolas_12" )); h = GetImageFont().Height() - 1
	DrawText( "profile [" + profile.profile_name + "]" , x, y ); y :+ h
	DrawText( "cash $" + format_number( profile.cash ), x, y ); y :+ h
	DrawText( "kills " + format_number( profile.kills ), x, y ); y :+ h
	DrawText( "inventory", x, y ); y :+ h
	SetLineWidth( 1 )
	SetColor( 127, 127, 127 )
	DrawRectLines( x, y, profile.inventory.Length*50, 50 )
	SetColor( 255, 255, 255 )
	cx = x + 50/2; cy = y + 50/2
	For Local i% = 0 To profile.inventory.Length - 1
		Local ag:COMPLEX_AGENT = COMPLEX_AGENT( COMPLEX_AGENT.Copy( complex_agent_archetype[profile.inventory[i]] ))
		ag.pos_x = cx; ag.pos_y = cy; ag.ang = -45
		ag.snap_all_turrets
		ag.update()
		ag.draw()
		cx :+ 50
	Next
	y :+ 50 + h
	DrawText( "selected", x, y );
	
End Function

Function get_shop_input()
	
End Function


