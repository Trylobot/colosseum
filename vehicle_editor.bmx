Rem
	vehicle_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const ANCHOR_HOVER_RADIUS% = 100
Const CHASSIS_HOVER_RADIUS% = 200
Const INVENTORY_SIDEBAR_WIDTH% = 190

Function vehicle_editor:VEHICLE_DATA( v_dat:VEHICLE_DATA )
	v_dat = v_dat.clone()
	Local mouse:POINT = Create_POINT( MouseX(), MouseY() )
	Local mouse_dragging%
	Local dragging_gladiator% = False
	Local dragging_inventory_i% = -1
	Local dragging_anchor% = -1
	Local mouse_down_1%
	Local player:COMPLEX_AGENT = bake_player( v_dat )
	Local mouse_shadow:COMPLEX_AGENT = New COMPLEX_AGENT
	mouse_shadow.add_turret_anchor( cVEC.Create( 0, 0 ))
	Local mouse_items:INVENTORY_DATA[]
	Local title$ = "customize vehicle"
	Local kill_signal%
	Local v_dat_backup:VEHICLE_DATA
	
	'gladiator thingy
	Local stock_gladiator:COMPLEX_AGENT = get_unit( "machine_gun_quad" )

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
	
	'chassis being used
	For Local i% = 0 Until profile.inventory.Length
		'chassis search
		If profile.inventory[i].item_type = "chassis" And profile.inventory[i].key = v_dat.chassis_key
			unused_inventory_count[i] :- 1
			Exit 'only 1 could be possible; done
		End If
	Next
	'turrets being used
	For Local i% = 0 Until profile.inventory.Length
		For Local anchor% = 0 Until v_dat.turret_keys.Length
			If v_dat.turret_keys[anchor]
				For Local t% = 0 Until v_dat.turret_keys[anchor].Length
					If profile.inventory[i].item_type = "turret" And profile.inventory[i].key = v_dat.turret_keys[anchor][t]
						unused_inventory_count[i] :- 1
					End If
				Next
			End If
		Next
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
		
		'chassis hover detection
		Local chassis_hover% = False
		If mouse.dist_to( player ) <= CHASSIS_HOVER_RADIUS chassis_hover = True
		
		'draw stock gladiator button
		Local hover_gladiator% = False
		SetImageFont( get_font( "consolas_12" ))
		Local gladiator_y% = 84
		Local stock_name$ = "(free) gladiator chassis"
		Local stock_rect:BOX = Create_BOX( 5, gladiator_y, TextWidth(stock_name) + 10, 12 )
		If Not mouse_dragging ..
		And mouse.pos_x >= stock_rect.x And mouse.pos_x <= stock_rect.x + stock_rect.w ..
		And mouse.pos_y >= stock_rect.y And mouse.pos_y <= stock_rect.y + stock_rect.h
			hover_gladiator = True
			'draw the gladiator object near the mouse
			stock_gladiator.move_to( mouse, True )
			stock_gladiator.draw( 0.5, 3.0 )
			'draw a highlight box around the item description
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetColor( 255, 255, 255 )
			SetAlpha( 0.3333 )
			DrawRect( stock_rect.x, stock_rect.y, stock_rect.w, stock_rect.h )
			SetAlpha( 1 )
			DrawRectLines( stock_rect.x, stock_rect.y, stock_rect.w, stock_rect.h )
		End If
		SetScale( 1, 1 )
		SetColor( 255, 255, 255 )
		'regardless of the hover state, show the text of the item's description
		DrawText_with_outline( stock_name, 10, gladiator_y )
		
		'draw inventory (and calculate any mouse-hover inventory items)
		Local hover_inventory_listing% = -1
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetImageFont( get_font( "consolas_italic_18" ))
		SetColor( 127, 127, 164 )
		DrawText_with_outline( "inventory", 10, 60 )
		SetColor( 255, 255, 255 )
		SetImageFont( get_font( "consolas_12" ))
		Local inv_y% = 98
		For Local i% = 0 Until inventory.Length
			Local name$ = ""
			If COMPLEX_AGENT(inventory[i]) Then name = COMPLEX_AGENT(inventory[i]).name
			If TURRET(inventory[i]) Then name = TURRET(inventory[i]).name
			If name = ""
				Continue 'skip blank names
			Else 'name = "{item_name}"
				name = format_number(unused_inventory_count[i])+" "+name
			End If
			Local listing_rect:BOX = Create_BOX( 5, inv_y + i*TextHeight(name), TextWidth(name) + 10, 12 )
			'if hovering over the inventory listing and it has not yet been used ..
			If Not mouse_dragging ..
			And unused_inventory_count[i] > 0 ..
			And mouse.pos_x >= listing_rect.x And mouse.pos_x <= listing_rect.x + listing_rect.w ..
			And mouse.pos_y >= listing_rect.y And mouse.pos_y <= listing_rect.y + listing_rect.h
				hover_inventory_listing = i
				'move the actual object representing the inventory item to the mouse position
				inventory[i].move_to( mouse, True )
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
				'draw a highlight box around the item description
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetColor( 255, 255, 255 )
				SetAlpha( 0.3333 )
				DrawRect( listing_rect.x, listing_rect.y, listing_rect.w, listing_rect.h )
				SetAlpha( 1 )
				DrawRectLines( listing_rect.x, listing_rect.y, listing_rect.w, listing_rect.h )
			End If
			SetAlpha( 1 )
			If unused_inventory_count[i] <= 0
				SetColor( 96, 96, 96 )
			Else
				SetColor( 255, 255, 255 )
			End If
			'regardless of the hover state, show the text of the item's description
			DrawText_with_outline( name, 10, inv_y + i*TextHeight(name) )
		Next
		
		'chassis drag destination goes _under_ the chassis object, oddly
		If chassis_hover And Not closest_turret_anchor
			SetAlpha( 0.085 )
			SetColor( 255, 255, 255 )
			SetScale( 1, 1 )
			DrawOval( player.pos_x - CHASSIS_HOVER_RADIUS, player.pos_y - CHASSIS_HOVER_RADIUS, 2*CHASSIS_HOVER_RADIUS, 2*CHASSIS_HOVER_RADIUS ) 
		End If

		'draw player in current state
		If player.img 'valid player
			player.draw( 0.5, 8.0 )
		Else 'invalid player
			SetImageFont( get_font( "consolas_12" ))
			'draw a placeholder for the chassis, so the user knows what to do
			SetAlpha( 0.085 )
			SetColor( 255, 255, 255 )
			SetScale( 1, 1 )
			DrawRect( window_w/2 - 50, window_h/2 - 50, 100, 100 )
			SetAlpha( 0.15 )
			DrawRectLines( window_w/2 - 50, window_h/2 - 50, 100, 100 )
			SetAlpha( 0.3 )
			DrawText( " chassis", window_w/2 - 30, window_h/2 - 12 )
			DrawText( "goes here", window_w/2 - 30, window_h/2 )
		End If
		
		'click/drag detection
		If Not mouse_dragging And MouseDown( 1 ) And Not mouse_down_1 'STARTED a drag
			mouse_dragging = True
			mouse_shadow.remove_all_turrets()
			dragging_inventory_i = -1
			
			If closest_turret_anchor And Not v_dat.is_unit And v_dat.count_turrets( closest_turret_anchor_i ) > 0 'started a drag op near a turret anchor
				'remove the turrets from the vehicle data and refresh the player object
				Local returned_turret_keys$[] = v_dat.get_turrets( closest_turret_anchor_i )
				Local result$ = v_dat.remove_turrets( closest_turret_anchor_i )
				If result = "success" 'removed turrets successfully
					dragging_anchor = closest_turret_anchor_i
					player = bake_player( v_dat )
					DebugLog " dragging turrets:[ "+", ".Join(returned_turret_keys)+" ] from anchor "+closest_turret_anchor_i
					'attach a copy of any turret attached to the closest anchor to the mouse shadow
					If returned_turret_keys
						mouse_items = New INVENTORY_DATA[returned_turret_keys.Length]
						For Local i% = 0 Until returned_turret_keys.Length
							mouse_items[i] = Create_INVENTORY_DATA( "turret", returned_turret_keys[i] )
							Local t:TURRET = get_turret( mouse_items[i].key )
							If t
								mouse_shadow.add_turret( t, closest_turret_anchor_i )
							End If
						Next
						mouse_shadow.set_images_unfiltered()
					End If
				Else 'error
					show_error( result )
				End If
				
			Else If chassis_hover And player.img 'yanked a valid chassis
				mouse_shadow = player
				If v_dat.is_unit
					mouse_items = [ Create_INVENTORY_DATA( "unit", v_dat.chassis_key )]
				Else 'Not v_dat.is_unit
					mouse_items = [ Create_INVENTORY_DATA( "chassis", v_dat.chassis_key )]
					For Local anchor% = 0 Until v_dat.turret_keys.Length
						For Local t% = 0 Until v_dat.turret_keys[anchor].Length
							mouse_items = mouse_items[..mouse_items.Length+1]
							mouse_items[mouse_items.Length-1] = Create_INVENTORY_DATA( "turret", v_dat.turret_keys[anchor][t] )
						Next
					Next
				End If
				v_dat_backup = v_dat.clone()
				v_dat = New VEHICLE_DATA
				player = bake_player( v_dat )
			
			Else If hover_inventory_listing >= 0 'started a drag op near an inventory item
				dragging_inventory_i = hover_inventory_listing
				unused_inventory_count[hover_inventory_listing] :- 1
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
				DebugLog " dragging item:"+profile.inventory[hover_inventory_listing].to_string()
			
			Else If hover_gladiator
				dragging_gladiator = True
				'attach the gladiator to the mouse chassis
				mouse_shadow = get_unit( "machine_gun_quad" )
				mouse_items = [ Create_INVENTORY_DATA( "unit", "machine_gun_quad" )]
				DebugLog " dragging item:unit.machine_gun_quad"
			End If
		
		Else If mouse_dragging And Not MouseDown( 1 ) And mouse_down_1 'FINISHED a drag
			mouse_dragging = False
			
			If closest_turret_anchor And Not v_dat.is_unit 'dropped onto a turret anchor
			
				If dragging_inventory_i >= 0 'dropped turret from inventory onto a turret anchor; add it to vehicle data and bake
					Local result$ = v_dat.add_turret( profile.inventory[dragging_inventory_i].key, closest_turret_anchor_i )
					If result = "success"
						player = bake_player( v_dat )
						DebugLog " added turret "+profile.inventory[dragging_inventory_i].key+" to anchor "+closest_turret_anchor_i
					Else 'error
						show_error( result )
						unused_inventory_count[dragging_inventory_i] :+ 1
					End If
				
				Else 'yanked a mess of turrets from the existing chassis
					'attach the turrets to the player at the nearest anchor
					Local new_turret_keys$[mouse_items.Length]
					For Local k% = 0 Until mouse_items.Length
						new_turret_keys[k] = mouse_items[k].key
					Next
					Local returned_turret_keys$[] = v_dat.get_turrets( closest_turret_anchor_i )
					Local result$ = v_dat.replace_turrets( new_turret_keys, closest_turret_anchor_i )
					If result = "success" 'replaced old turrets
						player = bake_player( v_dat )
						DebugLog " added turrets:[ "+", ".Join(new_turret_keys)+" ] to anchor "+closest_turret_anchor_i
						'if any, return the old turrets to the inventory
						If returned_turret_keys
							For Local r% = 0 Until returned_turret_keys.Length
								Local item:INVENTORY_DATA = Create_INVENTORY_DATA( "turret", returned_turret_keys[r] )
								For Local i% = 0 Until profile.inventory.Length
									If item.eq( profile.inventory[i] )
										unused_inventory_count[i] :+ 1
									End If
								Next
							Next
						End If
					Else 'error
						show_error( result )
					End If
				End If
			
			Else If mouse_shadow.img And chassis_hover 'dropped a chassis on the chassis
				'return the current chassis to the inventory
				For Local i% = 0 Until profile.inventory.Length
					If profile.inventory[i].key = v_dat.chassis_key
						unused_inventory_count[i] :+ 1
						Exit
					End If
				Next
				'use the new one
				If mouse_items[0].item_type = "unit"
					v_dat.set_chassis( mouse_items[0].key, True ) 'change the chassis
				Else If mouse_items[0].item_type = "chassis"
					v_dat.set_chassis( mouse_items[0].key, False ) 'change the chassis
					If mouse_items.Length > 1
						v_dat = v_dat_backup
						v_dat_backup = New VEHICLE_DATA
					End If
				End If
				player = bake_player( v_dat )
				DebugLog " changed chassis to "+mouse_items[0].to_string()
			
			Else If Not v_dat.is_unit 'finished a drag near neither the chassis nor any of its turret anchors; drop it into the inventory
				
				If dragging_inventory_i >= 0 'dragging from inventory
					unused_inventory_count[dragging_inventory_i] :+ 1
				
				Else If mouse_items 'dragging from chassis anchor
					Local item_strings$[mouse_items.Length]
					For Local m% = 0 Until mouse_items.Length
						For Local i% = 0 Until profile.inventory.Length
							If mouse_items[m].eq( profile.inventory[i] )
								unused_inventory_count[i] :+ 1
							End If
						Next
						item_strings[m] = mouse_items[m].to_string()
					Next
					DebugLog " returned items:[ "+", ".Join(item_strings)+" ] to the inventory"
				End If
			End If
			
			'reset the mouse shadow
			dragging_gladiator = False
			dragging_inventory_i = -1
			dragging_anchor = -1
			mouse_shadow = New COMPLEX_AGENT
			mouse_shadow.add_turret_anchor( cVEC.Create( 0, 0 ))
			mouse_items = Null
		End If
		
		'drag destinations draw
		If closest_turret_anchor
			SetAlpha( 1.2 - mouse.dist_to( closest_turret_anchor )/ANCHOR_HOVER_RADIUS )
			DrawLine_awesome( mouse.pos_x, mouse.pos_y, closest_turret_anchor.x, closest_turret_anchor.y )
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
		
		kill_signal = AppTerminate()
	Until KeyHit( KEY_ESCAPE ) Or kill_signal
	If kill_signal Then End
	
	SetClsColor( 0, 0, 0 )
	FlushKeys()
	FlushMouse()
	Return v_dat
End Function

Function bake_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA )
	Local player:COMPLEX_AGENT = create_player( v_dat, False )
	If Not player Then player = New COMPLEX_AGENT
	player.set_images_unfiltered()
	player.move_to( Create_POINT( window_w/2, window_h/2, 0 ), True )
	?Debug
	If v_dat Then DebugLog " player vehicle data~n"+v_dat.to_json().ToSource()
	?
	Return player
End Function

Function show_error( err$ )
	DebugLog " "+err
End Function

