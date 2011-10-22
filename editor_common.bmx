
'editor common
SuperStrict

Global LINE_HEIGHT% = 14

'//////////////////////////////////////////////////////////////////////////////
'generic functions
Function draw_string( source:Object, x%, y%, fg% = $FFFFFF, bg% = $000000, origin_x# = 0.0, origin_y# = 0.0, line_height_override% = -1, draw_bg% = True )
  Local LH% = LINE_HEIGHT
  If line_height_override > -1
    LH = line_height_override
  End If
	Local lines$[]
	Local widget:TextWidget
	Local text$ = String(source)
	If Not text
		widget = TextWidget(source) 'assume widget passed
		If widget
			lines = widget.lines
		Else 'assume string array passed
			lines = String[](source)
		End If
	Else
		lines = text.Split("~n")
	End If
	If origin_x <> 0.0 Or origin_y <> 0.0
		If Not widget
			widget = TextWidget.Create( text )
		End If
		x :- origin_x*Float( widget.w )
		y :- origin_y*Float( widget.h )
	End If
	Local x_cur% = x
	Local y_cur% = y
	SetRotation( 0 )
	SetScale( 1.0, 1.0 )
	Local a# = GetAlpha()
	If draw_bg
		SetColor( (bg & $FF0000) Shr 16, (bg & $00FF00) Shr 8, (bg & $0000FF) Shr 0 )
		SetAlpha( 0.5*a )
		For Local line$ = EachIn lines
			'outline and block shadow effects
			DrawText( line, x_cur - 1, y_cur - 1 ); DrawText( line, x_cur    , y_cur - 1 ); DrawText( line, x_cur + 1, y_cur - 1 )
			DrawText( line, x_cur - 1, y_cur     ); DrawText( line, x_cur    , y_cur     ); DrawText( line, x_cur + 1, y_cur     )
			DrawText( line, x_cur - 1, y_cur + 1 ); DrawText( line, x_cur    , y_cur + 1 ); DrawText( line, x_cur + 1, y_cur + 1 )
			DrawText( line, x_cur + 2, y_cur + 2 )
			y_cur :+ LH
		Next
		x_cur = x
		y_cur = y
	End If
	SetColor( (fg & $FF0000) Shr 16, (fg & $00FF00) Shr 8, (fg & $0000FF) Shr 0 )
	SetAlpha( a )
	For Local line$ = EachIn lines
		'foreground
		DrawText( line, x_cur, y_cur )
		y_cur :+ LH
	Next
End Function

Function DrawRectLines( x%, y%, w%, h%, L% = 1 )
	DrawRect( x, y, w, L ) 'top horiz
	DrawRect( x+W-L, y, L, H ) 'right vert
	DrawRect( x, y+h-L, w, L ) 'bottom horiz
	DrawRect( x, y, L, h ) 'left vert
End Function

Function draw_crosshairs( x%, y%, r%, diagonal% = False )
	Local a# = GetAlpha()
	SetColor( 0, 0, 0 )
	SetLineWidth( 3 )
	SetAlpha( 0.8*a )
	If Not diagonal
		DrawRect( x-1, y-r-1, 3, 2*r+2 )
		DrawRect( x-r-1, y-1, 2*r+2, 3 )
	Else
		DrawLine( x-r-1, y-r-1, x+r+1, y+r+1 )
		DrawLine( x-r-1, y+r+1, x+r+1, y-r-1 )
	End If
	SetColor( 255, 255, 255 )
	SetLineWidth( 1 )
	SetAlpha( a )
	If Not diagonal
		DrawLine( x, y-r, x, y+r )
		DrawLine( x-r, y, x+r, y )
	Else
		DrawLine( x-r, y-r, x+r, y+r )
		DrawLine( x-r, y+r, x+r, y-r )
	End If
End Function

Function draw_pointer( x%, y%, r%, l%, rot# )
	SetColor( 0, 0, 0 )
	DrawOval( x-r, y-r, 2*r, 2*r )
	SetLineWidth( 3 )
	DrawLine( x, y, x + 1 + l, y )
	SetColor( 255, 255, 255 )
	DrawOval( x-(r-2), y-(r-2), 2*(r-2), 2*(r-2) )
	SetLineWidth( 1 )
	DrawLine( x, y, x + l, y )
	SetColor( 0, 0, 0 )
	DrawOval( x-(r-4), y-(r-4), 2*(r-4), 2*(r-4) )
End Function

'-----------------------

Type TextWidget
  Field lines$[]
  Field w%
  Field h%
  
  Function Create:TextWidget( obj:Object )
    Local w:TextWidget = New TextWidget
    If String(obj)
			w.set( String(obj) )
		Else If String[](obj)
			w.lines = String[](obj)
			w.update_size()
		End If
    Return w
  End Function
  
  Method set( str$ )
    lines = str.Split("~n")
		update_size()
  End Method
	
	Method update_size()
    w = 0
    For Local line$ = EachIn lines
      w = Max( w, TextWidth( line ))
    Next
    h = lines.length*LINE_HEIGHT
	End Method
  
  Method append( widget:TextWidget )
    w = Max( w, widget.w )
    h :+ widget.h
    lines = lines[..(lines.length + widget.lines.length)]
    For Local L% = 0 Until widget.lines.length
      lines[L + lines.length] = widget.lines[L]
    Next
  End Method
End Type


