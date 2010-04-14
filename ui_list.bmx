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
  Field items:Object[]
  Field items_display:String[]
  Field item_count%
  'panel display
  Field panel_color:TColor
  Field border_color:TColor
  Field inner_border_color:TColor
  'item display
  Field item_font:FONT_STYLE
  Field item_hover_font:FONT_STYLE
	Field item_panel_hover_color:TColor
  Field hover_item% '-1 if none
  'event handlers
  Field item_clicked_event_handlers( list:TUIList, i% )[]
  
  'private fields
	Field rect:BOX
  Field margin_x%
  Field margin_y%
	Field item_rects:BOX[]
  
  Function Create:TUIList( ..
  items:Object[], items_display:String[], item_count%, ..
  panel_color:Object, border_color:Object, inner_border_color:Object, item_panel_hover_color:Object, ..
  item_font:FONT_STYLE, item_hover_font:FONT_STYLE )
    Local ui_list:TUIList = New TUIList
    'initialization
    ui_list.items = items
    ui_list.items_display = items_display
    ui_list.item_count = item_count
    ui_list.panel_color = TColor.Create_by_RGB_object( panel_color )
    ui_list.border_color = TColor.Create_by_RGB_object( border_color )
    ui_list.inner_border_color = TColor.Create_by_RGB_object( inner_border_color )
		ui_list.item_panel_hover_color = TColor.Create_by_RGB_object( item_panel_hover_color )
    ui_list.item_font = item_font
    ui_list.item_hover_font = item_hover_font
    ui_list.hover_item = -1
    'derived fields
    ui_list.margin_x = item_font.width( " " )
    ui_list.margin_y = Int(0.5 * Float(item_font.height))
    ui_list.calculate_dimensions()
    Return ui_list
  End Function
  
  Method draw()
    SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		Const line_width% = 1
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
      If i <> hover_item
        'draw normal item text
				iy :+ item_font.draw_string( items_display[i], ix, iy ) + item_font.height + margin_y
      Else 'i == hover_item
        'draw hover select box
				item_panel_hover_color.Set()
				ir = item_rects[i]
				DrawRect( ir.x, ir.y, ir.w, ir.h )
				'draw hover item text
        iy :+ item_hover_font.draw_string( items_display[i], ix, iy ) + item_font.height + margin_y
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
		calculate_dimensions()
  End Method
	
	Method update_item_display( display$, i% )
		items_display[i] = display
		calculate_dimensions()
	End Method
  
  Method set_position( x%, y% )
    rect.x = x
    rect.y = y
    For Local i% = 0 Until item_count
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
  
  Method on_mouse_move( mx%, my% )
    hover_item = get_item_index_by_screen_coord( mx, my )
  End Method
  
  Method on_mouse_click( mx%, my% )
    Local i% = get_item_index_by_screen_coord( mx, my )
    If i <> -1
      Local event_handler( ui_list_clicked:TUIList, item_clicked_index% )
      For Local h% = 0 Until item_clicked_event_handlers.Length
        item_clicked_event_handlers[h]( Self, i )
      Next
    End If
  End Method
  
  Method add_item_clicked_event_handler( event_handler( ui_list_clicked:TUIList, item_clicked_index% ))
    item_clicked_event_handlers = item_clicked_event_handlers[..item_clicked_event_handlers.Length+1]
    item_clicked_event_handlers[item_clicked_event_handlers.Length-1] = event_handler
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

'______________________________________________________________________________
Type TUIListFancy
	'this some fancy shit, yo
	Field header_font:FONT_STYLE
	Field header_panel_color:TColor
	Field list:TUIList
	
	
End Type

