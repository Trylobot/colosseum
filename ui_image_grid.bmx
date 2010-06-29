Rem
	ui_image_grid.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Type TUIImageGrid Extends TUIObject
	Field item_images:TImage[][]
	Field item_labels:String[][]
	Field default_item_border_color:TColor
	Field selected_item_border_color:TColor
	Field line_width%
  Field default_item_font:FONT_STYLE
  Field selected_item_font:FONT_STYLE
	
	Field dimensions%[]
	Field items:Object[][]
	Field selected_item:CELL
	Field margin_x%
  Field margin_y%
	Field rect:BOX
	Field max_rows%
	Field max_cols%
	Field img_size%
	Field list_content_refresh_event_handler:TUIEventHandler
  Field item_clicked_event_handlers:TUIEventHandler[][]
	
	
	Method New()
	End Method
	
	Method Construct( ..
  dimensions%[], ..
  default_item_border_color:Object, selected_item_border_color:Object, ..
	line_width%, ..
	default_item_fg_font:Object, default_item_bg_font:Object, ..
	selected_item_fg_font:Object, selected_item_bg_font:Object, ..
	x% = 0, y% = 0 )
    'initialization
		Self.dimensions = dimensions
    Self.items = New Object[Self.item_count]
    Self.panel_color = TColor.Create_by_RGB_object( panel_color )
    Self.border_color = TColor.Create_by_RGB_object( border_color )
    Self.inner_border_color = TColor.Create_by_RGB_object( inner_border_color )
		Self.item_panel_selected_color = TColor.Create_by_RGB_object( item_panel_selected_color )
		Self.line_width = line_width
		Self.header_font = FONT_STYLE.Create( header_fg_font, header_bg_font, header_fg_color, header_bg_color )
    Self.item_font = FONT_STYLE.Create( item_fg_font, item_bg_font, item_fg_color, item_bg_color )
    Self.item_selected_font = FONT_STYLE.Create( item_fg_font, item_bg_font, item_selected_fg_color, item_selected_bg_color )
		Self.rect = Null
		Self.item_rects = Null
		Self.set_position( x, y )
    'derived fields
		Self.selected_item = CELL.Create( 0, 0 )
    Self.margin_x = Self.item_font.width( " " )
    Self.margin_y = Int(0.5 * Float(Self.item_font.height))
    Self.calculate_dimensions()
		Self.item_clicked_event_handlers = New TUIEventHandler[Self.item_count]
	End Method
	
  Method set_position( x%, y% )
		If Not rect Then rect = New BOX
    rect.x = x
    rect.y = y
  End Method
  
	Method draw()
		Local x% = rect.x
		Local y% = rect.y
		Local img:TImage
		Local scale#
		Local alpha#
		Local border_color:TColor
		Local font:FONT_STYLE
		Local label$
		SetRotation( 0 )
		
		For Local r% = 0 Until item_images.Length
			For Local c% = 0 Until item_images[r].Length
				img = item_images[r][c]
				label = item_labels[r][c]
				scale = Float( img_size ) / Float( Max( img.width, img.height ))
				'determine image top-left
				x = margin_x + (c * (img_size + margin_x))
				y = margin_y + (r * (img_size + margin_y))
				'selected item switch
				If( r <> selected_item.row Or c <> selected_item.col )
					alpha = 0.5
					border_color = default_item_border_color
					font = default_item_font
				Else 'r == selected_item.row And c == selected_item.col
			    alpha = 1.0
					border_color = selected_item_border_color
					font = selected_item_font
				End If
				'draw
				SetAlpha( alpha )
				SetScale( 1, 1 )
				border_color.Set()
				DrawRectLines( x - line_width, y - line_width, img_w + 2*line_width, img_h + 2*line_width, line_width )
				SetScale( scale, scale )
				DrawImage( img, x, y )
				SetScale( 1, 1 )
				font.draw_string( label, x + font.width( label ) / 2, y + img_size )
			Next
		Next
	End Method
	
	Method on_mouse_move%( mx%, my% )
		get_item_index_by_screen_coord( mx, my, selected_item )
		Return selected_item.is_valid()
	End Method
	
	Method on_mouse_click%( mx%, my% )
		get_item_index_by_screen_coord( mx, my, selected_item )
		invoke( selected_item )
		Return selected_item.is_valid()
	End Method
	
	Method on_keyboard_up()
		selected_item.row :- 1
	End Method
	
	Method on_keyboard_down()
		selected_item.row :+ 1
	End Method
	
	Method on_keyboard_left()
		selected_item.col :- 1
	End Method
	
	Method on_keyboard_right()
		selected_item.col :+ 1
	End Method
	
	Method on_keyboard_enter()
		invoke( selected_item )
	End Method
	
	Method on_show()
		If list_content_refresh_event_handler
			list_content_refresh_event_handler.invoke( Self )
		End If
	End Method
	
	Method set_dimensions( w%, h% )
		rect.w = w
		rect.h = h
		img_size = Min( (w / max_cols) - (2 * margin_x), (h / max_rows) - (2 * margin_h) )
	End Method
	
	Method get_item_index_by_screen_coord( mx%, my%, item:CELL )
		item.row = my / (rect.h / max_rows)
		item.col = mx / (rect.w / max_cols)
		If item.row < 0 Or item.row >= items.Length Then item.row = CELL.COORDINATE_INVALID
		If item.col < 0 Or item.col >= items[item.row].Length Then item.col = CELL.COORDINATE_INVALID
	End Method
	
	Method invoke( item:CELL )
    If  item.row >= 0 And item.row < items.Length ..
		And item.col >= 0 And item.col < items[item.row].Length ..
		And item_clicked_event_handlers[item.row][item.col]
      item_clicked_event_handlers[item.row][item.col].invoke( items[item.row][item.col] )
    End If
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

