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
  Field item_count%
  'panel display
  Field w%, h%
  Field panel_color:TColor
  Field line_color:TColor
  Field header_panel_color:TColor
  Field header_str:String
  Field header_font:FONT_STYLE
  'item display
  Field items_display:String[]
  Field item_font:FONT_STYLE
  Field item_hover_font:FONT_STYLE
  Field hover_item% '-1 if none
  'events
  Field item_clicked_event_handlers( ui_list_clicked:TUIList, item_clicked_index% )[] 'event_handler( ui_list_clicked:TUIList, item_clicked_index% )
  
  Function Create:TUIList( ..
  items:Object[], ..
  panel_color:TColor, line_color:TColor, header_panel_color:TColor, ..
  header_str:String, header_font:FONT_STYLE, ..
  items_display:String[], item_font:FONT_STYLE, item_hover_font:FONT_STYLE )
    Local ui_list:TUIList = New TUIList
    ui_list.items = items
    ui_list.item_count = items.Length
    ui_list.panel_color = panel_color
    ui_list.line_color = line_color
    ui_list.header_panel_color = header_panel_color
    ui_list.header_str = header_str
    ui_list.header_font = header_font
    ui_list.items_display = items_display
    ui_list.item_font = item_font
    ui_list.item_hover_font = item_hover_font
    ui_list.hover_item = -1
    ui_list.calculate_dimensions()
    Return ui_list
  End Function
  
  Method draw( x%, y% )
    'TODO - add intelligent scrollbar support
    panel_color.Set()
    DrawRect( x, y, w, h )
    line_color.Set()
    DrawRectLines( x, y, w, h )
    Local ix% = x
    Local iy% = y
    y :+ header_font.draw_string( header_str, ix, iy )
    For Local i% = 0 Until items_display.Length
      If i <> hover_item
        y :+ item_font.draw_string( items_display[i], ix, iy )
      Else 'i == hover_item
        y :+ item_hover_font.draw_string( items_display[i], ix, iy )
      End If
    Next
  End Method
  
  Method add_item( item:Object, item_display:String )
    item_count :+ 1
    items = items[..item_count]
    items[item_count-1] = item
    items_display = items_display[..item_count]
    items_display[item_count-1] = item_display
  End Method
  
  Method calculate_dimensions()
    'TODO - dynamic size based on content
    w = 200
    h = 400
  End Method
  
  Method on_mouse_move( mx%, my% )
    hover_item = get_item_index_by_screen_coord( mx, my )
  End Method
  
  Method on_mouse_click( mx%, my% )
    Local i% = get_item_index_by_screen_coord( mx, my )
    Local event_handler( ui_list_clicked:TUIList, item_clicked_index% )
    For h% = 0 Until item_clicked_event_handlers.Length
      item_clicked_event_handlers[h]( Self, i )
    Next
  End Method
  
  Method add_item_clicked_event_handler( event_handler( ui_list_clicked:TUIList, item_clicked_index% ))
    item_clicked_event_handlers = item_clicked_event_handlers[..item_clicked_event_handlers.Length+1]
    item_clicked_event_handlers[item_clicked_event_handlers.Length-1] = event_handler
  End Method
  
  Method get_item_index_by_screen_coord%( x%, y% )
    'TODO
    Return -1
  End Method
  
End Type

