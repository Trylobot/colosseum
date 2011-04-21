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
	Const max_item_label_length% = 11
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
		Self.default_item_font = FONT_STYLE.Create( item_fg_font, item_bg_font, default_item_border_color, selected_item_border_color )
    Self.selected_item_font = FONT_STYLE.Create( item_fg_font, item_bg_font, selected_item_border_color, default_item_border_color )
		Self.rect = Null
		Self.margin_x = margin_x
		Self.margin_y = margin_y
    'derived fields
		Self.selected_item = CELL.Create( 0, 0 )
    Self.items = New Object[][dimensions.Length]
    Self.item_images = New TImage[][dimensions.Length]
    Self.item_labels = New String[][dimensions.Length]
		Self.item_clicked_event_handlers = New TUIEventHandler[][dimensions.Length]
		Self.max_rows = dimensions.Length
		For Local d% = 0 Until dimensions.Length
			Self.items[d] = New Object[dimensions[d]]
			Self.item_images[d] = New TImage[dimensions[d]]
			Self.item_labels[d] = New String[dimensions[d]]
			Self.item_clicked_event_handlers[d] = New TUIEventHandler[dimensions[d]]
			If dimensions[d] > Self.max_cols
				Self.max_cols = dimensions[d]
			End If
		Next
		'last bits
		Self.set_position( x, y )
		Self.set_dimensions( w, h )
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
		SetRotation( 0 )
		SetAlpha( 0.775 )
		SetColor( 0, 0, 0 )	
		DrawRect( 0, 0, SETTINGS_REGISTER.WINDOW_WIDTH.get(), SETTINGS_REGISTER.WINDOW_HEIGHT.get() )
		
		SetAlpha( 1.0 )
		SetColor( 255, 255, 255 )	
		Local item_rect:BOX = New BOX
		Local x%, y%
		Local text_x%
		Local img:TImage
		Local scale#
		Local img_alpha#
		Local border_alpha#
		Local text_alpha#
		Local highlight_alpha#
		Local border_color:TColor
		Local font:FONT_STYLE
		Local label$
		
		For Local r% = 0 Until item_images.Length
			For Local c% = 0 Until item_images[r].Length
				img = item_images[r][c]
				label = item_labels[r][c]
				scale = Float( img_size ) / Float( Max( img.width, img.height ))
				'determine image top-left
				get_item_rect( r, c, item_rect )
				x = item_rect.x + margin_x
				y = item_rect.y + margin_y
				'set draw styles based on current selection
				If( r = selected_item.row And c = selected_item.col )
			    img_alpha = 1.0
					border_alpha = 0.75 + 0.25*Sin( now()/2 )
					text_alpha = 1.0
					highlight_alpha = 0.075 + 0.05*Sin( now()/2 )
					border_color = selected_item_border_color
					font = selected_item_font
				Else 'r <> selected_item.row Or c <> selected_item.col
					img_alpha = 0.5
					border_alpha = 0.5
					text_alpha = 0.125
					highlight_alpha = 0.0
					border_color = default_item_border_color
					font = default_item_font
				End If
				'draw border
				SetAlpha( border_alpha )
				SetScale( 1, 1 )
				border_color.Set()
				DrawRectLines( x - line_width, y - line_width, img_size + 2*line_width, img_size + 2*line_width, line_width )
				'draw image content
				SetAlpha( img_alpha )
				SetScale( scale, scale )
				DrawImage( img, x, y )
				'draw label
				SetAlpha( text_alpha )
				SetScale( 1, 1 )
				text_x = x + img_size/2 - font.width( label )/2
				font.draw_string( label, text_x, y + img_size + 2*line_width )
				'draw highlight box
				SetAlpha( highlight_alpha )
				SetScale( 1, 1 )
				SetColor( 255, 255, 255 )
				draw_box( item_rect, True )
			Next
		Next
	End Method
	
	Method on_mouse_move%( mx%, my% )
		mx :- rect.x
		my :- rect.y
		get_item_index_by_screen_coord( mx, my, selected_item )
		Return selected_item.is_valid()
	End Method
	
	Method on_mouse_click%( mx%, my% )
		mx :- rect.x
		my :- rect.y
		get_item_index_by_screen_coord( mx, my, selected_item )
		invoke( selected_item )
		Return selected_item.is_valid()
	End Method
	
	Method on_keyboard_up()
		move_selection( CELL.DIRECTION_NORTH )
	End Method
	
	Method on_keyboard_down()
		move_selection( CELL.DIRECTION_SOUTH )
	End Method
	
	Method on_keyboard_left()
		move_selection( CELL.DIRECTION_WEST )
	End Method
	
	Method on_keyboard_right()
		move_selection( CELL.DIRECTION_EAST )
	End Method
	
	Method on_keyboard_enter()
		invoke( selected_item )
	End Method
	
	Method on_show()
		If list_content_refresh_event_handler
			list_content_refresh_event_handler.invoke( Self )
		End If
	End Method
	
	Method invoke( item:CELL )
    If  does_grid_cell_exist( item ) ..
		And item_clicked_event_handlers[item.row][item.col]
      item_clicked_event_handlers[item.row][item.col].invoke( items[item.row][item.col] )
    End If
	End Method
	
	Method set_item( row%, col%, item_label:String, uppercase% = True, item_image:TImage, event_handler(item:Object), item:Object = Null )
		If Not does_grid_cell_exist( CELL.Create( row, col )) Then Return
		items[row][col] = item
    item_images[row][col] = item_image
		If item_label.Length > max_item_label_length Then item_label = Left( item_label, max_item_label_length )
		If uppercase Then item_label = Upper( item_label )
		item_labels[row][col] = item_label
		item_clicked_event_handlers[row][col] = TUIEventHandler.Create( event_handler )
	End Method
	
	Method get_item_index_by_screen_coord( mx%, my%, item:CELL )
		item.row = (my - rect.y) / (img_size + 2 * margin_y + default_item_font.height)
		item.col = (mx - rect.x) / (img_size + 2 * margin_x)
		If Not does_grid_cell_exist( item )
			item.row = CELL.COORDINATE_INVALID
			item.col = CELL.COORDINATE_INVALID
		End If
	End Method
	
	Method get_item_rect:BOX( row%, col%, item_rect:BOX )
		item_rect.x = rect.x + (col * (img_size + 2 * margin_x))
		item_rect.y = rect.y + (row * (img_size + 2 * margin_y + default_item_font.height))
		item_rect.w = rect.x + ((col + 1) * (img_size + 2 * margin_x)) - 1 - item_rect.x
		item_rect.h = rect.y + ((row + 1) * (img_size + 2 * margin_y + default_item_font.height)) - 1 - item_rect.y
	End Method
	
	Method move_selection( dir% )
		If Not does_grid_cell_exist( selected_item )
			selected_item.set( 0, 0 )
			Return
		End If
		'selection is currently valid; move it around
		Local max_n%
		Local delta:CELL = New CELL
		Select dir
			Case CELL.DIRECTION_EAST
				max_n = max_cols
				delta.col = +1
			Case CELL.DIRECTION_WEST
				max_n = max_cols
				delta.col = -1
			Case CELL.DIRECTION_SOUTH
				max_n = max_rows
				delta.row = +1
			Case CELL.DIRECTION_NORTH
				max_n = max_rows
				delta.row = -1
		End Select
		Local n% = 0
		Repeat
			selected_item.add( delta )
		Until (n > max_n) ..
		Or does_grid_cell_exist( selected_item )
	End Method
	
	Method does_grid_cell_exist%( c:CELL )
    If  c.row >= 0 And c.row < items.Length ..
		And c.col >= 0 And c.col < items[c.row].Length
			Return True
		Else
			Return False
		End If
	End Method
	
End Type

