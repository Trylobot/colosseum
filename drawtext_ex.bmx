Rem
	drawtext_ex.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Function DrawText_with_shadow( str$, x#, y# )
	Local r%, g%, b%
	GetColor( r%, g%, b% )
	SetColor( 0, 0, 0 )
	DrawText( str, x + 1, y + 1 )
	DrawText( str, x + 2, y + 2 )
	SetColor( r, g, b )
	DrawText( str, x, y )
End Function

Function DrawText_with_outline( str$, x#, y#, outline_alpha# = -1.0 )
	Local r%, g%, b%, a#
	GetColor( r%, g%, b% )
	a = GetAlpha()
	SetColor( 0, 0, 0 )
	If outline_alpha <> -1.0
		SetAlpha( outline_alpha )
	End If
	DrawText( str, x + 1, y + 1 )
	DrawText( str, x - 1, y + 1 )
	DrawText( str, x + 1, y - 1 )
	DrawText( str, x - 1, y - 1 )
	SetColor( r, g, b )
	SetAlpha( a )
	DrawText( str, x, y )
End Function

Function DrawText_with_glow( str$, x%, y% )
	Local alpha# = GetAlpha()
	SetAlpha( 0.2*alpha )
	DrawText( str, x-1, y-1 )
	DrawText( str, x+1, y-1 )
	DrawText( str, x+1, y+1 )
	DrawText( str, x-1, y-1 )
	SetAlpha( alpha )
	DrawText( str, x, y )
End Function

