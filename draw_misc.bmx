Rem
	draw_misc.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Function DrawRectLines( x%, y%, w%, h% )
	DrawLine( x,     y,     x+w-1, y,     False )
	DrawLine( x+w-1, y,     x+w-1, y+h-1, False )
	DrawLine( x+w-1, y+h-1, x,     y+h-1, False )
	DrawLine( x,     y+h-1, x,     y,     False )
End Function

Function draw_percentage_bar( x%, y%, w%, h%, pct#, a# = 1.0, r% = 255, g% = 255, b% = 255, borders% = True )
	If      pct > 1.0 Then pct = 1.0 ..
	Else If pct < 0.0 Then pct = 0.0
	SetAlpha( a / 3.0 )
	SetColor( 0, 0, 0 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	DrawRect( x, y, w, h )
	If borders
		SetAlpha( a )
		SetColor( r, g, b )
		SetLineWidth( 1 )
		DrawRectLines( x, y, w, h )
		DrawRect( x + 2.0, y + 2.0, pct*(w - 4.0), h - 4.0 )
	Else 'Not borders
		SetAlpha( a )
		SetColor( r, g, b )
		DrawRect( x, y, pct*w, h )
	End If
End Function



