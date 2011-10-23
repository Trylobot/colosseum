
'editor common
SuperStrict

Const W% = 1024
Const H% = 768
Const LINE_HEIGHT% = 14
'Const font_path$ = "/WINDOWS/Fonts/monaco.ttf"
'Const font_path$ = "/WINDOWS/Fonts/DroidSansMono.ttf"
Const font_path$ = "/WINDOWS/Fonts/consola.ttf"
Global editor_font:TImageFont = LoadImageFont( font_path, 12 )

'//////////////////////////////////////////////////////////////////////////////
'functions

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

Function draw_messages()
	SetScale( 1, 1 )
	SetOrigin( 0, 0 )
	SetRotation( 0 )
	SetColor( 255, 255, 255 )
	Local size% = message.list.Count()
	Local i% = 0
	For Local m:message = EachIn message.list
		SetAlpha( m.alpha() )
		draw_string( m.text, W - 4, (H - ((size - 1 - i)*LINE_HEIGHT)) - 4,,, 1.0, 1.0 )
		i :+ 1
	Next
EndFunction

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
'instaquit
Global esc_held% = False
Global esc_press_ts% = MilliSecs()
Global esc_held_progress_bar_show_time_required% = 180
Global instaquit_time_required% = 1000
Global FLAG_instaquit_plz% = False

Function escape_key_update()
	If FLAG_instaquit_plz Then Return 'no questions asked
	'instaquit
	If esc_held And (MilliSecs() - esc_press_ts) >= instaquit_time_required
		FLAG_instaquit_plz = True
	End If
	'escape key state
	If KeyDown( KEY_ESCAPE )
		If Not esc_held
			esc_press_ts = MilliSecs()
		End If
		esc_held = True
	Else
		esc_held = False
	End If
End Function

Function escape_key_release%()
	Return (esc_held And Not KeyDown( KEY_ESCAPE ))
End Function

Function time_alpha_pct#( ts%, time%, in% = True ) 'either fading IN or OUT
	Local ms% = MilliSecs()
	If in 'fade in
		If (ms - ts) <= time
			Return (Float(ms - ts) / Float(time))
		Else
			Return 1.0
		End If
	Else 'fade out
		If (ms - ts) <= time
			Return (1.0 - (Float(ms - ts) / Float(time)))
		Else
			Return 0.0
		End If
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

Function draw_instaquit_progress()
	If KeyDown( KEY_ESCAPE ) And esc_held And (MilliSecs() - esc_press_ts) >= esc_held_progress_bar_show_time_required
		'draw black transparent screen overlay
		SetOrigin( 0, 0 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		Local alpha_multiplier# = time_alpha_pct( esc_press_ts + esc_held_progress_bar_show_time_required, esc_held_progress_bar_show_time_required )
		SetAlpha( 0.75 * alpha_multiplier )
		SetColor( 0, 0, 0 )
		DrawRect( 0,0, W,H )
		'draw progress bar
		SetAlpha( 1.0 * alpha_multiplier )
		SetColor( 255, 255, 255 )
		Local margin% = W/4
		draw_percentage_bar( margin, H/2 - editor_font.Height() - 5, W - 2*margin, 50, Float( MilliSecs() - esc_press_ts ) / Float( instaquit_time_required - 50 ),,,,,,, 2 )
		''draw text label
		'Local str$ = "Continue holding ESC to QUIT"
		'Local x% = W/2 - TextWidth( str )/2
		'Local y% = H/2 + FONT.Height()
		'draw_string( str, x, y ) 
	End If
End Function


'//////////////////////////////////////////////////////////////////////////////
'classes

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

Type message
	Global list:TList = CreateList()
	Global life_time% = 6000
	Global fade_time% = 1000
	Function create:message( str$ )
		Local m:message = New Message
		m.text = TextWidget.Create( str )
		m.created = MilliSecs() + (life_time - fade_time)
		list.AddLast( m )
		Return m
	EndFunction
	Function update()
		'Prune oldest message
		If Not list.IsEmpty()
			Local first:TLink = list.FirstLink()
			Local m:message = message(first.Value())
			If m.alpha() <= 0
				first.Remove()
			EndIf
		EndIf
	EndFunction
	
	Field text:TextWidget
	Field created%
	Method alpha#()
		Return time_alpha_pct( created, fade_time, false )
	EndMethod
EndType



