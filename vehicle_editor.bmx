Rem
	vehicle_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const ANCHOR_HOVER_RADIUS% = 100
Const CHASSIS_HOVER_RADIUS% = 125
Const INVENTORY_SIDEBAR_WIDTH% = 190

Function show_error( err$ )
	DebugLog err
End Function

Function vehicle_editor( v_dat:VEHICLE_DATA )
	Local mouse:POINT = Create_POINT( MouseX(), MouseY() )
	Local mouse_dragging%
	Local dragging_inventory_i%
	Local mouse_down_1%
	Local player:COMPLEX_AGENT = bake_player( v_dat )
	Local mouse_shadow:COMPLEX_AGENT = New COMPLEX_AGENT
	mouse_shadow.add_turret_anchor( cVEC.Create( 0, 0 ))
	Local mouse_items:INVENTORY_DATA[]
	Local title$ = "customize vehicle"
	
	'cache inventory items
	Local inventory:POINT[profile.inventory.Length]
	Local unused_inventory_count%[profile.inventory.Length]
	For Local i% = 0 Until profile.inventory.Length
		Local item:INVENTORY_DATA = profile.inventory[i]
		unused_inventory_count[i] = profile.inventory[i].count
		Select item.item_type
			Case "chassis"
				Local ch:COMPLEX_AGENT = get_player_chassis( item.key )
				ch.set_images_unfiltered()
				inventory[i] = ch
			Case "turret"
				Local t:TURRET = get_turret( item.key )
				t.set_images_unfiltered()
				inventory[i] = t
		End Select
	Next
	
	SetClsColor( 19, 19, 33 )
	Repeat
		Cls()
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		
		'title
		SetImageFont( get_font( "consolas_bold_24" ))
		SetColor( 0, 0, 0 )
		SetAlpha( 0.5 )
		DrawRect( 0, 0, 20 + TextWidth( title ), 20 + TextHeight( title ))
		SetColor( 255, 255, 255 )
		DrawRectLines( -1, -1, 21 + TextWidth( title ), 21 + TextHeight( title ))
		SetAlpha( 1 )
		DrawText_with_outline( title, 10, 10 )
		
		'mouse
		'last_mouse = Copy_POINT( mouse )
		mouse.pos_x = MouseX(); mouse.pos_y = MouseY()
		
		'closest turret anchor detection, if any
		Local closest_turret_anchor:cVEC = Null
		Local closest_turret_anchor_i% = -1
		For Local i% = 0 To player.turret_anchors.Length - 1
			Local anchor:cVEC = player.turret_anchors[i].clone()
			anchor.x :+ player.pos_x; anchor.y :+ player.pos_y
			If mouse.dist_to( anchor ) <= ANCHOR_HOVER_RADIUS .. 
			And (Not closest_turret_anchor Or mouse.dist_to( anchor ) < mouse.dist_to( closest_turret_anchor ))
				'hovering near an anchor
				closest_turret_anchor = anchor
				closest_turret_anchor_i = i
			End If
		Next
		
		Local chassis_hover% = False
		If mouse.dist_to( player ) <= CHASSIS_HOVER_RADIUS chassis_hover = True
		
		'draw inventory (and calculate any mouse-hover inventory items)
		Local hover_inventory_listing% = -1
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetImageFont( get_font( "consolas_14" ))
		SetColor( 127, 127, 127 )
		DrawText_with_outline( "inventory", 10, 60 )
		SetColor( 255, 255, 255 )
		SetImageFont( get_font( "consolas_12" ))
		Local inv_y% = 80
		For Local i% = 0 Until inventory.Length
			Local name$ = ""
			If COMPLEX_AGENT(inventory[i]) Then name = COMPLEX_AGENT(inventory[i]).name
			If TURRET(inventory[i]) Then name = TURRET(inventory[i]).name
			If name = ""
				Continue 'skip blank names
			Else 'name = "{item_name}"
				If unused_inventory_count[i] > 1 Then name = "("+format_number(unused_inventory_count[i])+") "+name
			End If
			Local listing_rect:BOX = Create_BOX( 5, inv_y + i*TextHeight(name), TextWidth(name) + 10, 12 )
			If Not mouse_dragging ..
			And mouse.pos_x >= listing_rect.x And mouse.pos_x <= listing_rect.x + listing_rect.w ..
			And mouse.pos_y >= listing_rect.y And mouse.pos_y <= listing_rect.y + listing_rect.h
				If hover_inventory_listing < 0 Then hover_inventory_listing = i
				'move the actual object representing the inventory item to the mouse position
				inventory[i].move_to( Copy_POINT( mouse ).add_pos( 0, 0 ))
				'if the item is a turret, and the turret has no base, draw a "fake base" for it
				If TURRET(inventory[i])
					Local t:TURRET = TURRET(inventory[i])
					If Not t.img
						SetRotation( 0 )
						SetScale( 1, 1 )
						SetColor( 255, 255, 255 )
						SetAlpha( 0.20 )
						DrawRect( t.pos_x - 8, t.pos_y - 8, 16, 16 )
						SetAlpha( 0.20 )
						DrawRectLines( t.pos_x - 8, t.pos_y - 8, 16, 16 )
						SetAlpha( 0.10 )
						DrawLine( t.pos_x - 8, t.pos_y, t.pos_x + 8 - 1, t.pos_y )
						DrawLine( t.pos_x, t.pos_y - 8, t.pos_x, t.pos_y + 8 - 1 )
					End If
				End If
				'draw the inventory item
				inventory[i].draw( 0.5, 3.0 )
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetColor( 255, 255, 255 )
				SetAlpha( 0.3333 )
				'draw a highlight box around the item description
				DrawRect( listing_rect.x, listing_rect.y, listing_rect.w, listing_rect.h )
				SetAlpha( 1 )
				DrawRectLines( listing_rect.x, listing_rect.y, listing_rect.w, listing_rect.h )
			End If
			SetAlpha( 1 )
			'draw the text of the item description
			DrawText_with_outline( name, 10, inv_y + i*TextHeight(name) )
		Next
		
		'draw player in current state
		player.draw( 0.5, 8.0 )
		
		'click/drag detection
		dragging_inventory_i = -1
		If Not mouse_dragging And MouseDown( 1 ) And Not mouse_down_1 'STARTED a drag
			mouse_dragging = True
			mouse_shadow.remove_all_turrets()
			If closest_turret_anchor 'started a drag op near a turret anchor
				'attach a copy of any turret attached to the closest anchor to the mouse shadow
				mouse_items = New INVENTORY_DATA[v_dat.turret_key[closest_turret_anchor_i].Length]
				For Local i% = 0 Until v_dat.turret_key[closest_turret_anchor_i].Length
					mouse_items[i] = Create_INVENTORY_DATA( "turret", v_dat.turret_key[closest_turret_anchor_i][i] )
					mouse_shadow.add_turret( get_turret( v_dat.turret_key[closest_turret_anchor_i][i] ), closest_turret_anchor_i )
				Next
				mouse_shadow.set_images_unfiltered()
				'remove the turrets from the vehicle data and refresh the player object
				Local result$ = v_dat.remove_turrets( closest_turret_anchor_i )
				If result <> "success" 
					show_error( result )
				Else 'Not error
					player = bake_player( v_dat )
				End If
			Else If hover_inventory_listing >= 0 'started a drag op near an inventory item
				dragging_inventory_i = hover_inventory_listing
				unused_inventory_count[hover_inventory_listing] :- 1
				mouse_dragging = True
				'attach the inventory turret to or set the chassis of the mouse shadow
				If COMPLEX_AGENT(inventory[hover_inventory_listing])
					mouse_shadow = COMPLEX_AGENT( COMPLEX_AGENT.Copy( COMPLEX_AGENT(inventory[hover_inventory_listing]) ))
					mouse_items = [ profile.inventory[hover_inventory_listing].clone() ]
				Else If TURRET(inventory[hover_inventory_listing])
					mouse_shadow.remove_all_turrets()
					mouse_shadow.add_turret( TURRET(inventory[hover_inventory_listing]), 0 )
					mouse_shadow.set_images_unfiltered()
					mouse_items = [ profile.inventory[hover_inventory_listing].clone() ]
				End If
			End If
		Else If mouse_dragging And Not MouseDown( 1 ) And mouse_down_1 'FINISHED a drag
			mouse_dragging = False
			If mouse_shadow.img And chassis_hover 'finished a drag op near the chassis with a chassis
				Local is_unit% = False
				v_dat.set( mouse_items[0].key, is_unit ) 'change the chassis
				player = bake_player( v_dat )
			Else If closest_turret_anchor 'finished a drag op near a turret anchor with turret(s)
				If dragging_inventory_i >= 0 'dragging from INVENTORY
					Local result$ = v_dat.add_turret( profile.inventory[dragging_inventory_i].key, closest_turret_anchor_i )
					If result <> "success" 
						show_error( result )
					Else 'Not error
						player = bake_player( v_dat )
					End If
				Else 'dragging from EXISTING CHASSIS (potentially many turrets)
					'attach the turrets to the player at the nearest anchor
					Local new_turret_keys$[mouse_items.Length]
					For Local k% = 0 Until mouse_items.Length
						new_turret_keys[k] = mouse_items[k].key
					Next
					Local error$
					Local returned_turret_keys$[]
					Local returned_value:Object = v_dat.replace_turrets( new_turret_keys, closest_turret_anchor_i )
					If String[](returned_value)
						returned_turret_keys = String[](returned_value)
						player = bake_player( v_dat )
						For Local r% = 0 Until returned_turret_keys.Length
							Local item:INVENTORY_DATA = Create_INVENTORY_DATA( "turret", returned_turret_keys[r] )
							For Local i% = 0 Until profile.inventory.Length
								If item.eq( profile.inventory[i] )
									unused_inventory_count[i] :+ 1
								End If
							Next
						Next
					Else If String(returned_value) 'error
						error = String(returned_value)
						show_error( error )
					End If
				End If
			Else If mouse.pos_x <= INVENTORY_SIDEBAR_WIDTH 'finished a drag op in the inventory sidebar with {anything}
				If dragging_inventory_i >= 0 'dragging from inventory
					unused_inventory_count[dragging_inventory_i] :+ 1
				Else
					For Local m% = 0 To mouse_items.Length
						For Local i% = 0 Until profile.inventory.Length
							If mouse_items[m].eq( profile.inventory[i] )
								unused_inventory_count[i] :+ 1
							End If
						Next
					Next
				End If
			End If
			'reset the mouse shadow
			mouse_shadow = New COMPLEX_AGENT
			mouse_shadow.add_turret_anchor( cVEC.Create( 0, 0 ))
			mouse_items = Null
		End If
		
		'drag destinations draw
		If mouse_shadow.img And chassis_hover
			SetAlpha( 0.15 )
			SetColor( 255, 255, 255 )
			SetScale( 1, 1 )
			DrawOval( player.pos_x - CHASSIS_HOVER_RADIUS, player.pos_y - CHASSIS_HOVER_RADIUS, 2*CHASSIS_HOVER_RADIUS, 2*CHASSIS_HOVER_RADIUS ) 
		Else If closest_turret_anchor
			SetAlpha( 1.2 - mouse.dist_to( closest_turret_anchor )/ANCHOR_HOVER_RADIUS )
			DrawLine_awesome( mouse.pos_x, mouse.pos_y, closest_turret_anchor.x, closest_turret_anchor.y )
		Else If mouse_dragging And mouse.pos_x <= INVENTORY_SIDEBAR_WIDTH
			SetAlpha( 0.15 )
			SetColor( 255, 255, 255 )
			SetScale( 1, 1 )
			SetImageFont( get_font( "consolas_bold_24" ))
			DrawRect( 0, 21 + TextHeight( title ), INVENTORY_SIDEBAR_WIDTH, window_h ) 
		End If
		
		'mouse shadow
		If mouse_dragging
			mouse_shadow.move_to( mouse, True )
			mouse_shadow.draw( 0.5, 3.0 )
			For Local t:TURRET = EachIn mouse_shadow.turrets
				If Not t.img
					SetRotation( 0 )
					SetScale( 1, 1 )
					SetColor( 255, 255, 255 )
					SetAlpha( 0.20 )
					DrawRect( t.pos_x - 8, t.pos_y - 8, 16, 16 )
					SetAlpha( 0.20 )
					DrawRectLines( t.pos_x - 8, t.pos_y - 8, 16, 16 )
					SetAlpha( 0.10 )
					DrawLine( t.pos_x - 8, t.pos_y, t.pos_x + 8 - 1, t.pos_y )
					DrawLine( t.pos_x, t.pos_y - 8, t.pos_x, t.pos_y + 8 - 1 )
					Exit
				End If
			Next
		End If
		
		'mouse state
		If MouseDown( 1 )
			mouse_down_1 = True
		Else
			mouse_down_1 = False
		End If
		
		Flip( 1 )
	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
	End
	
	SetClsColor( 0, 0, 0 )
End Function

Function bake_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA, abort_on_error% = False )
	Local player:COMPLEX_AGENT = create_player( v_dat, abort_on_error )
	player.set_images_unfiltered()
	player.move_to( Create_POINT( window_w/2, window_h/2, 0 ), True )
	player.update()
	?Debug
	DebugLog "bake_player________~n"+v_dat.to_json().ToSource()
	?
	Return player
End Function

'helper classes
'____________________________
Type COMPATIBILITY_DATA
	Field chassis_key$
	Field inherits_from$
	Field turret_keys$[]
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "chassis_key", TJSONString.Create( chassis_key ))
		this_json.SetByName( "inherits_from", TJSONString.Create( inherits_from ))
		this_json.SetByName( "turret_keys", Create_TJSONArray_from_String_array( turret_keys ))
		Return this_json
	End Method
End Type
Function Create_COMPATIBILITY_DATA_from_json:COMPATIBILITY_DATA( json:TJSON )
	Local cd:COMPATIBILITY_DATA = New COMPATIBILITY_DATA
	cd.chassis_key = json.GetString( "chassis_key" )
	cd.inherits_from = json.GetString( "inherits_from" )
	cd.turret_keys = Create_String_array_from_TJSONArray( json.GetArray( "turret_keys" ))
	Return cd
End Function

