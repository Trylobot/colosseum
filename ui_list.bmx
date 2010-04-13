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
  Field panel_color:TColor
  Field inner_border_color:TColor
  'item display
  Field items_display:String[]
  Field item_font:FONT_STYLE
  Field item_hover_font:FONT_STYLE
  Field hover_item% '-1 if none
  'event handlers
  Field item_clicked_event_handlers( list:TUIList, i% )[]
  
  'private fields
  Field width%
  Field height%
  Field margin_x%
  Field margin_y%
  
  Function Create:TUIList( ..
  items:Object[], ..
  panel_color:TColor, inner_border_color:TColor, ..
  items_display:String[], item_font:FONT_STYLE, item_hover_font:FONT_STYLE )
    Local ui_list:TUIList = New TUIList
    'initialization
    ui_list.items = items
    ui_list.panel_color = panel_color
    ui_list.inner_border_color = inner_border_color
    ui_list.items_display = items_display
    ui_list.item_font = item_font
    ui_list.item_hover_font = item_hover_font
    ui_list.hover_item = -1
    'derived fields
    ui_list.item_count = items.Length
    ui_list.margin_x = item_font.width( "w" )
    ui_list.margin_y = Int(0.75 * Float(item_font.height))
    ui_list.calculate_dimensions()
    Return ui_list
  End Function
  
  Method draw( x%, y% )
    'draw panels
    If panel_color
      panel_color.Set()
      DrawRect( x, y, width, height )
    End If
    If inner_border_color
      inner_border_color.Set()
      DrawRectLines( x, y, width, height )
    End If
    'draw list item text
    Local ix% = x, iy% = y
    For Local i% = 0 Until items_display.Length
      If i <> hover_item
        iy :+ item_font.draw_string( items_display[i], ix, iy ) + item_font.height
      Else 'i == hover_item
        'effects behind?
        iy :+ item_hover_font.draw_string( items_display[i], ix, iy ) + item_font.height
        'effects in front?
      End If
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
  End Method
  
  Method calculate_dimensions()
    width = 0
    height = 0
    Local item_width%
    For Local i% = 0 Until item_count
      item_width = 2*margin_x + item_font.width( items_display[i] )
      If item_width > width Then width = item_width
    Next
    height = (item_count + 1)*margin_y + item_count*item_font.height
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
  
  Method get_item_index_by_screen_coord%( x%, y% )
    'TODO
    Return -1
  End Method
  
End Type

