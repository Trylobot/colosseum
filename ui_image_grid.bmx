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
	item_fg_font:Object, item_bg_font:Object, ..
	margin_x% = 0, margin_y% = 0, ..
	x% = 0, y% = 0, ..
	w% = 0, h% = 0 )
    'initialization
		Self.dimensions = dimensions
    Self.default_item_border_color = TColor.Create_by_RGB_object( default_item_border_color )
    Self.selected_item_border_color = TColor.Create_by_RGB_object( selected_item_border_color )
		Self.line_width = line_width
		Self.default_item_font = FONT_STYLE.Create( item_fg_font, item_bg_font, selected_item_border_color, default_item_border_color )
    Self.selected_item_font = FONT_STYLE.Create( item_fg_font, item_bg_font, default_item_border_color, selected_item_border_color )
		Self.rect = Null
		Self.margin_x = margin_x
		Self.margin_y = margin_y
		Self.set_position( x, y )
		Self.set_dimensions( w, h )
    'derived fields
		Self.selected_item = CELL.Create( 0, 0 )
    Self.items = New Object[][dimensions.Length]
    Self.item_images = New TImage[][dimensions.Length]
    Self.item_labels = New String[][dimensions.Length]
		Self.item_clicked_event_handlers = New TUIEventHandler[][dimensions.Length]
		For Local d% = 0 Until dimensions.Length
			Self.items[d] = New Object[dimensions[d]]
			Self.item_images[d] = New TImage[dimensions[d]]
			Self.item_labels[d] = New String[dimensions[d]]
			Self.item_clicked_event_handlers[d] = New TUIEventHandler[dimensions[d]]
		Next
	End Method
	
  Method set_position( x%, y% )
		If Not rect Then rect = New BOX
    rect.x = x
    rect.y = y
  End Method
  
	Method set_dimensions( w%, h% )
		rect.w = w
		rect.h = h
		img_size = Min( (w / max_cols) - (2 * margin_x), (h / max_rows) - (2 * margin_y) )
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
				DrawRectLines( x - line_width, y - line_width, img_size + 2*line_width, img_size + 2*line_width, line_width )
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
	
	Method set_item( row%, col%, item_label:String, item_image:TImage, event_handler(item:Object), item:Object = Null )
		If row < 0 Or row >= dimensions.Length ..
		Or col < 0 Or col >= dimensions[row] Then Return
		items[row][col] = item
    item_images[row][col] = item_image
		item_labels[row][col] = item_label
		item_clicked_event_handlers[row][col] = TUIEventHandler.Create( event_handler )
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
	
End Type

