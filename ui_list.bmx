Rem
	ui_list.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import brl.TList
'Import "bmp_font.bmx"
'Import "color.bmx"

'______________________________________________________________________________
Type TUIList Extends TUIObject
	Field header:String
  Field items_display:String[]
  Field panel_color:TColor
  Field border_color:TColor
  Field inner_border_color:TColor
	Field item_panel_selected_color:TColor
	Field line_width%
	Field header_font:FONT_STYLE
  Field item_font:FONT_STYLE
  Field item_selected_font:FONT_STYLE

  Field items:Object[]
  Field item_count%
  Field selected_item% '-1 if none
  Field margin_x%
  Field margin_y%
	Field rect:BOX
	Field item_rects:BOX[]
	Field list_content_refresh_event_handler:TUIEventHandler
  Field item_clicked_event_handlers:TUIEventHandler[]
  
	
	Method New()
		Construct( ..
			"NULL", 1, ..
			[ 127, 127, 127 ], [ 255, 255, 255 ], [ 0, 0, 0 ], [ 255, 255, 255 ], ..
			2, ..
			"arcade_14", "arcade_14_outline", ..
			[255, 255, 255], [0, 0, 0], ..
			"arcade_7", "arcade_7_outline", ..
			[255, 255, 255], [0, 0, 0], ..
			[0, 0, 0], [205, 205, 205], ..
			10, 70 )
		set_item( 0, "NULL", Null, Null )
	End Method

  Method Construct( ..
  header:String, item_count%, ..
  panel_color:Object, border_color:Object, inner_border_color:Object, item_panel_selected_color:Object, ..
	line_width%, ..
	header_fg_font:Object, header_bg_font:Object, ..
	header_fg_color:Object, header_bg_color:Object, ..
	item_fg_font:Object, item_bg_font:Object, ..
	item_fg_color:Object, item_bg_color:Object, ..
	item_selected_fg_color:Object, item_selected_bg_color:Object, ..
	x% = 0, y% = 0 )
    'initialization
		Self.header = header
    Self.item_count = item_count
    Self.items = New Object[item_count]
		Self.items_display = New String[item_count]
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
    Self.selected_item = 0
    Self.margin_x = Self.item_font.width( " " )
    Self.margin_y = Int(0.5 * Float(Self.item_font.height))
    Self.calculate_dimensions()
		Self.item_clicked_event_handlers = New TUIEventHandler[item_count]
  End Method
  
  Method set_position( x%, y% )
		If Not rect Then rect = New BOX
    rect.x = x
    rect.y = y
		If Not item_rects Then item_rects = New BOX[item_count]
		For Local i% = 0 Until item_count
			If Not item_rects[i] Then item_rects[i] = New BOX
			item_rects[i].x = rect.x
			item_rects[i].y = rect.y + margin_y/2 + i*(margin_y + item_font.height)
		Next
  End Method
  
  Method draw()
    SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
    'draw panels
    If panel_color
      panel_color.Set()
      DrawRect( rect.x, rect.y, rect.w, rect.h )
    End If
    If border_color
      border_color.Set()
      DrawRectLines( rect.x, rect.y, rect.w, rect.h, line_width )
    End If
    If inner_border_color
      inner_border_color.Set()
      DrawRectLines( rect.x + line_width, rect.y + line_width, rect.w - 2*line_width, rect.h - 2*line_width, line_width )
    End If
		'draw header
		If header_font
			SetScale( 1, 1 )
			header_font.draw_string( header, rect.x + margin_x/2, rect.y - header_font.height - margin_y/2 )
		End If
    'draw list item text
    Local ix% = rect.x + margin_x
    Local iy% = rect.y + margin_y
		Local ir:BOX
    For Local i% = 0 Until items_display.Length
      If i <> selected_item
        'draw normal item text
				SetScale( 1, 1 )
				iy :+ item_font.draw_string( items_display[i], ix, iy ) + item_font.height + margin_y
      Else 'i == selected_item
        'draw selected item box
				item_panel_selected_color.Set()
				ir = item_rects[i]
				SetScale( 1, 1 )
				DrawRect( ir.x, ir.y, ir.w, ir.h )
				'draw item text
        iy :+ item_selected_font.draw_string( items_display[i], ix, iy ) + item_font.height + margin_y
      End If
    Next
    'scrollbar
    'TODO - add intelligent scrollbar support
  End Method
  
	Method on_mouse_move%( mx%, my% )
    selected_item = get_item_index_by_screen_coord( mx, my )
		Return selected_item <> -1
  End Method
  
  Method on_mouse_click%( mx%, my% )
    selected_item = get_item_index_by_screen_coord( mx, my )
		invoke( selected_item )
		Return selected_item <> -1
  End Method
	
	Method on_keyboard_up()
		selected_item :- 1
		If selected_item < 0
			selected_item = item_count - 1
		End If
	End Method
	
	Method on_keyboard_down()
		selected_item :+ 1
		If selected_item > (item_count - 1)
			selected_item = 0
		End If
	End Method
	
	Method on_keyboard_left()
	End Method
	
	Method on_keyboard_right()
	End Method
	
	Method on_keyboard_enter%()
		If selected_item <> -1
			invoke( selected_item )
			Return True
		Else
			Return False
		End If
	End Method
	
	Method on_show()
		If list_content_refresh_event_handler
			list_content_refresh_event_handler.invoke( Self )
		End If
	End Method
	
	Method set_item( i%, item_display:String, event_handler(item:Object), item:Object = Null )
		If i < 0 Or i >= item_count Then Return
		items[i] = item
    items_display[i] = item_display
		item_clicked_event_handlers[i] = TUIEventHandler.Create( event_handler )
		calculate_dimensions()
	End Method
	
  Method add_new_item( item_display:String, event_handler(item:Object), item:Object = Null )
    Local i% = item_count
		item_count :+ 1
    items = items[..item_count]
    items_display = items_display[..item_count]
		item_clicked_event_handlers = item_clicked_event_handlers[..item_count]
		item_rects = item_rects[..item_count]
    items[i] = item
    items_display[i] = item_display
		item_clicked_event_handlers[i] = TUIEventHandler.Create( event_handler )
		calculate_dimensions()
  End Method
	
  Method calculate_dimensions()
    'list panel dimensions
		If Not rect Then rect = New BOX
    Local item_width%
    For Local i% = 0 Until item_count
      item_width = 2*margin_x + item_font.width( items_display[i] )
      If item_width > rect.w
				rect.w = item_width
			End If
    Next
    rect.h = (item_count + 1)*margin_y + item_count*item_font.height
		'individual item dimensions
		If Not item_rects Then item_rects = New BOX[item_count]
		For Local i% = 0 Until item_count
			If Not item_rects[i] Then item_rects[i] = New BOX
			item_rects[i].Set( rect.x, rect.y + margin_y/2 + i*(margin_y + item_font.height), rect.w, margin_y + item_font.height )
		Next
  End Method
  
  Method select_item( i% )
		If i >= 0 And i < item_count
			selected_item = i
		Else
			selected_item = -1
		End If
	End Method
	
	Method invoke( i% )
    If i >= 0 And i < item_count And item_clicked_event_handlers[i]
      item_clicked_event_handlers[i].invoke( items[i] )
    End If
	End Method
  
  Method set_list_content_refresh_event_handler( event_handler(item:Object) )
		list_content_refresh_event_handler = TUIEventHandler.Create( event_handler )
  End Method
  
  Method get_item_index_by_screen_coord%( sx%, sy% )
    sx :- rect.x
		sy :- rect.y
		If sx < 0 Or sx > rect.w Then Return -1
    If sy < 0 Or sy > rect.h Then Return -1
		Local i%
		i = (sy - margin_y/2) / (margin_y + item_font.height)
		If i >= 0 And i < item_count
			Return i
		Else
			Return -1
		End If
  End Method
	
	Method get_item_rect:BOX( i% )
		If i >= 0 And i < item_count Then Return item_rects[i] Else Return Null
	End Method
  
End Type

