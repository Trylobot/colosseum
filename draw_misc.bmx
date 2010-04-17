Rem
	draw_misc.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "settings.bmx"
'Import "box.bmx"

'______________________________________________________________________________
Function reset_draw_state()
	SetColor( 255, 255, 255 )
	SetAlpha( 1 )
	SetScale( 1, 1 )
	SetRotation( 0 )
End Function

Function screencap:TImage()
	SetOrigin( 0, 0 )
	Return LoadImage( GrabPixmap( 0, 0, window_w, window_h ))
End Function

Function DrawRectLines( x%, y%, w%, h%, L% = 1 )
	DrawRect( x, y, w, L ) 'top horiz
	DrawRect( x+w-L, y, L, h ) 'right vert
	DrawRect( x, y+h-L, w, L ) 'bottom horiz
	DrawRect( x, y, L, h ) 'left vert
End Function

Function draw_box( b:BOX, solid% = False )
	If solid
		DrawRect( b.x, b.y, b.w, b.h )
	Else
		DrawRectLines( b.x, b.y, b.w, b.h )
	End If
End Function

Function draw_percentage_bar( ..
x#, y#, w#, h#, ..
pct#, ..
a# = 1.0, r% = 255, g% = 255, b% = 255, ..
borders% = True, snap_to_pixels% = True, ..
line_width# = 1.0 )
	'truncate
	If snap_to_pixels
		x = Floor( x )
		y = Floor( y )
		w = Floor( w )
		h = Floor( h )
		line_width = Floor( line_width )
	End If
	'normalize
	If pct > 1.0
		pct = 1.0
	Else If pct < 0.0
		pct = 0.0
	End If
	SetAlpha( a )
	SetColor( 0, 0, 0 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	DrawRect( x, y, w, h )
	SetAlpha( a )
	SetColor( r, g, b )
	
	If borders
		DrawRectLines( x, y, w, h, line_width )
		DrawRect( x + 2.0*line_width, y + 2.0*line_width, pct*(w - 4.0*line_width), h - 4.0*line_width )
	Else 'Not borders
		DrawRect( x, y, pct*w, h )
	End If
End Function

Function draw_fuzzy( img:TImage )
	If img
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		DrawImage( img, 0, 0 )
		SetAlpha( 0.333333 )
		SetBlend( LIGHTBLEND )
		DrawImage( img, 2, 0 )
		DrawImage( img, 0, 2 )
		DrawImage( img, 0, -2 )
		DrawImage( img, -2, 0 )
		SetAlpha( 0.666666 )
		SetBlend( ALPHABLEND )
		SetColor( 0, 0, 0 )
		DrawRect( 0, 0, window_w, window_h )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
	End If
End Function

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



