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
Type TUIList
  'list data
  Field items_display:String[]
  'panel display
  Field panel_color:TColor
  Field border_color:TColor
  Field inner_border_color:TColor
	Field line_width%
  'item display
  Field item_font:FONT_STYLE
  Field item_selected_font:FONT_STYLE
	Field item_panel_selected_color:TColor

  'private & derived fields
  Field items:Object[]
  Field item_count%
  Field selected_item% '-1 if none
  Field margin_x%
  Field margin_y%
	Field rect:BOX
	Field item_rects:BOX[]
  'event handlers
  Field item_clicked_event_handlers:TList[]
  

  Function Create:TUIList( ..
  items_display:String[], ..
  panel_color:Object, border_color:Object, inner_border_color:Object, item_panel_selected_color:Object, ..
	line_width%, ..
	item_fg_font:BMP_FONT, item_bg_font:BMP_FONT, ..
	item_fg_color:Object, item_bg_color:Object, ..
	item_selected_fg_color:Object, item_selected_bg_color:Object, ..
	x% = 0, y% = 0 )
    Local ui_list:TUIList = New TUIList
    'initialization
    ui_list.items_display = items_display
    ui_list.item_count = items_display.Length
    ui_list.items = New Object[ui_list.item_count]
    ui_list.panel_color = TColor.Create_by_RGB_object( panel_color )
    ui_list.border_color = TColor.Create_by_RGB_object( border_color )
    ui_list.inner_border_color = TColor.Create_by_RGB_object( inner_border_color )
		ui_list.line_width = line_width
		ui_list.item_panel_selected_color = TColor.Create_by_RGB_object( item_panel_selected_color )
    ui_list.item_font = FONT_STYLE.Create( item_fg_font, item_bg_font, item_fg_color, item_bg_color )
    ui_list.item_selected_font = FONT_STYLE.Create( item_fg_font, item_bg_font, item_selected_fg_color, item_selected_bg_color )
		ui_list.set_position( x, y )
    'derived fields
    ui_list.selected_item = -1
    ui_list.margin_x = item_font.width( " " )
    ui_list.margin_y = Int(0.5 * Float(item_font.height))
    ui_list.calculate_dimensions()
		ui_list.item_clicked_event_handlers = New TList[item_count]
    Return ui_list
  End Function
  
  Method draw()
    SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
    SetLineWidth( line_width )
    'draw panels
    If panel_color
      panel_color.Set()
      DrawRect( rect.x, rect.y, rect.w, rect.h )
    End If
    If border_color
      border_color.Set()
      DrawRectLines( rect.x, rect.y, rect.w, rect.h )
    End If
    If inner_border_color
      inner_border_color.Set()
      DrawRectLines( rect.x + line_width, rect.y + line_width, rect.w - 2*line_width, rect.h - 2*line_width )
    End If
    'draw list item text
    Local ix% = rect.x + margin_x
    Local iy% = rect.y + margin_y
		Local ir:BOX
    For Local i% = 0 Until items_display.Length
      If i <> selected_item
        'draw normal item text
				iy :+ item_font.draw_string( items_display[i], ix, iy ) + item_font.height + margin_y
      Else 'i == selected_item
        'draw selected item box
				item_panel_selected_color.Set()
				ir = item_rects[i]
				DrawRect( ir.x, ir.y, ir.w, ir.h )
				'draw item text
        iy :+ item_selected_font.draw_string( items_display[i], ix, iy ) + item_font.height + margin_y
      End If
			SetScale( 1, 1 )
    Next
    'scrollbar
    'TODO - add intelligent scrollbar support
  End Method
  
  Method add_item( item:Object, item_display:String )
    item_count :+ 1
    items = items[..item_count]
    items[item_count-1] = item
    items_display = items_display[..item_count]
    items_display[item_count-1] = item_display
		item_rects = item_rects[..item_count]
		item_rects[item_count-1] = New BOX
		item_clicked_event_handlers = item_clicked_event_handlers[..item_count]
		calculate_dimensions()
  End Method
	
	Method set_item( i%, item:Object )
		If i < 0 Or i >= item_count Then Return
		items[i] = item
	End Method
	
	Method update_item_display( i%, display$ )
		If i < 0 Or i >= item_count Then Return
		items_display[i] = display
		calculate_dimensions()
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
	
	Method select_previous_item()
		selected_item :- 1
		If selected_item < 0
			selected_item = item_count - 1
		End If
	End Method
	
	Method select_next_item()
		selected_item :+ 1
		If selected_item > (item_count - 1)
			selected_item = 0
		End If
	End Method
	
	Method on_mouse_move%( mx%, my% )
    selected_item = get_item_index_by_screen_coord( mx, my )
		Return selected_item <> -1
  End Method
  
  Method on_mouse_click%( mx%, my% )
    Local i% = get_item_index_by_screen_coord( mx, my )
		If selected_item <> -1
			invoke( i )
			Return True
		Else
			Return False
		End If
  End Method
	
	Method invoke_selected%()
		If selected_item <> -1
			invoke( selected_item )
			Return True
		Else
			Return False
		End If
	End Method
	
	Method invoke( i% )
    If i >= 0 And i < item_count And item_clicked_event_handlers[i]
      For Local event_handler:TUIListEventHandler = EachIn item_clicked_event_handlers[i]
        event_handler.invoke( items[i] )
      Next
    End If
	End Method
  
  Method add_item_clicked_event_handler( i%, event_handler(item:Object) )
		If i >= 0 And i < item_count
			If Not item_clicked_event_handlers[i] Then item_clicked_event_handlers[i] = CreateList()
			item_clicked_event_handlers[i].AddLast( TUIListEventHandler.Create( event_handler ))
		End If
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

Type TUIListEventHandler
	'private fields
	Field event_handler(item:Object)
	'factory
	Function Create:TUIListEventHandler( event_handler(item:Object) )
		Local h:TUIListEventHandler = New TUIListEventHandler
		h.event_handler = event_handler
		Return h
	End Function
	'handler invocation
	Method invoke( item:Object )
		event_handler( item )
	End Method
End Type

'______________________________________________________________________________
'Type TUIList Extends TUIList
'	Field header_font:FONT_STYLE
'	Field header_panel_color:TColor
'	
'End Type

