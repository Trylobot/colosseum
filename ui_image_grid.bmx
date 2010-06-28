Rem
	ui_image_grid.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Type TUIImageGrid Extends TUIObject
	Field items_display:TImage[][]
	Field border_color:TColor
	Field item_panel_selected_color:TColor
	Field line_width%
	
	Field items:Object[][]
	Field max_rows%
	Field max_cols%
	Field selected_item:CELL
	Field margin_x%
  Field margin_y%
	Field rect:BOX
	Field list_content_refresh_event_handler:TUIEventHandler
  Field item_clicked_event_handlers:TUIEventHandler[][]
	
	
	Method New()
	End Method
	
	Method Construct()
	End Method
	
  Method set_position( x%, y% )
		If Not rect Then rect = New BOX
    rect.x = x
    rect.y = y
  End Method
  
	Method draw()
    SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		
	End Method
	
	Method on_mouse_move%( mx%, my% )
	End Method
	
	Method on_mouse_click%( mx%, my% )
	End Method
	
	Method on_keyboard_up()
	End Method
	
	Method on_keyboard_down()
	End Method
	
	Method on_keyboard_left()
	End Method
	
	Method on_keyboard_right()
	End Method
	
	Method on_keyboard_enter()
	End Method
	
	Method on_show()
	End Method
	
	
	Rem
	Function Create:TUIImageGrid( image:TImage[][], enabled%[][], label$[] )
		Local g:TUIImageGrid = New TUIImageGrid
		g.image = image
		g.enabled = enabled
		g.label = label
		Return g
	End Function
	
	Rem
	Method upate()
		update_focus_from_mouse()
		If KeyHit( KEY_ENTER ) Or MouseHit( 1 )
			callback( focus )
		End If
		If KeyHit( KEY_RIGHT )
			focus.row :+ 1; If focus.row > image.Length - 1 Then focus.row = 0
		Else If KeyHit( KEY_LEFT )
			focus.row :- 1; If focus.row < 0 Then focus.row = image.Length - 1
		End If
	End Method
	
	Method draw( x%, y% )
		reset_draw_state()
		Local cx%, cy%
		Local column_width%
		cx = x
		For Local c% = 0 Until image.Length
			cy = y
			SetImageFont( get_font( "consolas_bold_14" ))
			column_width = Max( image_size + 2*margin - 1, TextWidth( group_label[c] ) + 2*margin )
			If focus.row = c
				Local column_left_x% = cx - margin
				Local column_right_x% = column_left_x + column_width
				SetColor( 0, 0, 0 )
				SetAlpha( 0.50 )
				DrawRect( column_left_x + 1, 0, column_width, window_h )
				SetColor( 160, 160, 160 )
				SetAlpha( 0.80 )
				SetLineWidth( 1 )
				DrawLine( column_left_x,  0, column_left_x,  window_h )
				DrawLine( column_right_x, 0, column_right_x, window_h )
				SetAlpha( 1.00 )
				SetColor( 255, 255, 255 )
			Else
				SetAlpha( 0.50 )
			End If
			DrawText_with_outline( group_label[c], cx, cy )
			cy :+ 22
			For Local L% = 0 Until image[c].Length
				draw_preview_img( image[c][L], cx, cy, lock[c][L], (focus.row = c) )
				cy :+ scale*image[c][L].height + margin
			Next
			cx :+ column_width + margin
		Next
	End Method
	
	Method draw_preview_img( img:TImage, x%, y%, locked%, focused% )
		scale = Float(image_size) / Float(Max( img.width, img.height ))
		SetScale( scale, scale )
		If locked
			SetColor( 64, 64, 64 )
		End If
		DrawImage( img, x, y )
		SetScale( 1, 1 )
		SetColor( 255, 255, 255 )
		If locked
			DrawImageRef( get_image( "lock" ), x + scale*img.width/2, y + scale*img.height/2 )
		End If
	End Method
	
	Method update_focus_from_mouse()
		Local cx%, cy%
		Local column_width%
		cx = MouseX()
		For Local c% = 0 Until image.Length
			cy = MouseY()
			'SetImageFont( get_font( "consolas_bold_14" ))
			column_width = Max( image_size + 2*margin - 1, TextWidth( group_label[c] ) + 2*margin )
			'If focus.row = c
			Local column_left_x% = cx - margin
			Local column_right_x% = column_left_x + column_width
			'SetColor( 0, 0, 0 )
			'SetAlpha( 0.50 )
			'DrawRect( column_left_x + 1, 0, column_width, window_h )
			'SetColor( 160, 160, 160 )
			'SetAlpha( 0.80 )
			'SetLineWidth( 1 )
			'DrawLine( column_left_x,  0, column_left_x,  window_h )
			'DrawLine( column_right_x, 0, column_right_x, window_h )
			'SetAlpha( 1.00 )
			'SetColor( 255, 255, 255 )
			'Else
			'SetAlpha( 0.50 )
			'End If
			'DrawText_with_outline( group_label[c], cx, cy )
			cy :+ 22
			For Local L% = 0 Until image[c].Length
				'draw_preview_img( image[c][L], cx, cy, lock[c][L], (focus.row = c) )
				cy :+ scale*image[c][L].height + margin
			Next
			cx :+ column_width + margin
		Next
	End Method
	
	Const image_size% = 50
	Const margin% = 10
	
	EndRem
	
End Type

