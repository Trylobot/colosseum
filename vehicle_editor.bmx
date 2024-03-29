Rem
	vehicle_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'///////////////////////////////////////////////////////////////////////////////
'NOT CURRENTLY USED!
'///////////////////////////////////////////////////////////////////////////////
'SuperStrict
'Import "vehicle_data.bmx"
'Import "complex_agent.bmx"
'Import "inventory_data.bmx"
'Import "player_profile.bmx"
'Import "turret.bmx"
'Import "point.bmx"
'Import "instaquit.bmx"
'Import "mouse.bmx"
'Import "vec.bmx"
'Import "box.bmx"
'Import "draw_misc.bmx"
'Import "constants.bmx"
'Import "settings.bmx"

'______________________________________________________________________________
Const ANCHOR_HOVER_RADIUS% = 100
Const CHASSIS_HOVER_RADIUS% = 200
Const INVENTORY_SIDEBAR_WIDTH% = 190

Const STAGE_SCALE# = 8.0
Const MOUSE_SHADOW_SCALE# = 3.0

Function vehicle_editor:VEHICLE_DATA( v_dat:VEHICLE_DATA )
	v_dat = v_dat.clone()
	'Local mouse:POINT = Create_POINT( MouseX(), MouseY() )
	Local mouse_dragging%
	Local dragging_gladiator% = False
	Local dragging_chassis% = False
	Local dragging_inventory_i% = -1
	Local dragging_anchor% = -1
	Local mouse_down_1%
	Local player:COMPLEX_AGENT = bake_player( v_dat, STAGE_SCALE )
	Local mouse_shadow:COMPLEX_AGENT
	Local mouse_items:INVENTORY_DATA[]
	Local title$ = "customize vehicle"
	Local kill_signal%
	Local v_dat_backup:VEHICLE_DATA
	Local error_state%
	Local error_appear_ts% = 0
	Const error_flash_time% = 2000
	
	'gladiator thingy
	Local stock_gladiator_key$ = "apc"
	Local stock_gladiator:COMPLEX_AGENT = get_unit( stock_gladiator_key )
	stock_gladiator.set_images_unfiltered()
	stock_gladiator.scale_all( MOUSE_SHADOW_SCALE )

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
				ch.scale_all( MOUSE_SHADOW_SCALE )
				inventory[i] = ch
			Case "turret"
				Local t:TURRET = get_turret( item.key )
				t.set_images_unfiltered()
				t.scale_all( MOUSE_SHADOW_SCALE )
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
		'mouse
		'last_mouse = Copy_POINT( mouse )
		mouse.pos_x = MouseX(); mouse.pos_y = MouseY()
		
		'for instaquit
		escape_key_update()

		tooltip = ""
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		
		'draw title
		SetImageFont( get_font( "consolas_bold_24" ))
		SetColor( 0, 0, 0 )
		SetAlpha( 0.5 )
		DrawRect( 0, 0, 20 + TextWidth( title ), 20 + TextHeight( title ))
		SetColor( 255, 255, 255 )
		DrawRectLines( -1, -1, 21 + TextWidth( title ), 21 + TextHeight( title ))
		SetAlpha( 1 )
		DrawText_with_outline( title, 10, 10 )
		
		'back button
		SetImageFont( get_font( "consolas_bold_24" ))
		Local done$ = "« done"
		SetColor( 0, 0, 0 )
		SetAlpha( 0.5 )
		DrawRect( window_w - 20 - TextWidth( done ), 0, 20 + TextWidth( done ), 20 + TextHeight( done ))
		SetColor( 255, 255, 255 )
		DrawRectLines( window_w - 19 - TextWidth( done ), -1, 20 + TextWidth( done ), 20 + TextHeight( done ))
		SetAlpha( 1 )
		DrawText_with_outline( done, window_w - 10 - TextWidth( done ), 10 )
		Local hovering_on_back_button% = False
		If mouse.pos_x >= window_w - 20 - TextWidth( done ) And mouse.pos_y <= 20 + TextHeight( title )
			hovering_on_back_button = True
			SetAlpha( 0.3333 )
			DrawRect( window_w - 20 - TextWidth( done ), 0, 20 + TextWidth( done ), 20 + TextHeight( done ))
			SetAlpha( 1 )
		End If
		
		'warning: no chassis / no turrets
		'info: non-customizable unit
		Local warning_x% = 50 + TextWidth( title )
		Local warning_y% = 10
		SetAlpha( 1 )
		If v_dat.is_unit
			SetColor( 255, 255, 255 )
			DrawImage( get_image( "information" ), warning_x, warning_y - 4 )
			SetImageFont( get_font( "consolas_12" ))
			DrawText_with_outline( "This vehicle cannot be edited", warning_x + 22, warning_y )
		Else
			If v_dat.chassis_key = ""
				If Not error_state
					error_state = True
					error_appear_ts = now()
				End If
				If error_state And ((now() - error_appear_ts) <= error_appear_ts)
					SetAlpha( 0.5 + 0.5 * Sin( now() Mod 360 ))
				Else
					SetAlpha( 1 )
				End If
				SetColor( 255, 255, 255 )
				DrawImage( get_image( "warning" ), warning_x, warning_y - 4 )
				SetImageFont( get_font( "consolas_12" ))
				SetColor( 255, 216, 0 )
				DrawText_with_outline( "This vehicle needs a chassis", warning_x + 22, warning_y )
			Else If v_dat.count_all_turrets() <= 0
				If Not error_state
					error_state = True
					error_appear_ts = now()
				End If
				If error_state And ((now() - error_appear_ts) <= error_appear_ts)
					SetAlpha( 0.5 + 0.5 * Sin( now() Mod 360 ))
				Else
					SetAlpha( 1 )
				End If
				SetColor( 255, 255, 255 )
				DrawImage( get_image( "warning" ), warning_x, warning_y - 4 )
				SetImageFont( get_font( "consolas_12" ))
				SetColor( 255, 216, 0 )
				DrawText_with_outline( "This vehicle needs at least one turret", warning_x + 22, warning_y )
			Else
				error_state = False
				error_appear_ts = 0
			End If
		End If
		SetAlpha( 1 )
		
		'closest turret anchor detection, if any
		Local closest_turret_anchor:cVEC = Null
		Local closest_turret_anchor_i% = -1
		For Local i% = 0 To player.turret_anchors.Length - 1
			Local anchor:cVEC = player.to_cvec().add( player.turret_anchors[i].scale( STAGE_SCALE ))
			If mouse.dist_to( anchor ) <= ANCHOR_HOVER_RADIUS .. 
			And (Not closest_turret_anchor Or mouse.dist_to( anchor ) < mouse.dist_to( closest_turret_anchor ))
				'hovering near an anchor
				closest_turret_anchor = anchor
				closest_turret_anchor_i = i
				'tooltip = "turret anchor"
			End If
		Next
		
		'chassis hover detection
		Local chassis_hover% = False
		If mouse.dist_to( player ) <= CHASSIS_HOVER_RADIUS
			chassis_hover = True
			'tooltip = "chassis"
		End If
		
		'draw stock gladiator button
		Local hover_gladiator% = False
		SetImageFont( get_font( "consolas_12" ))
		Local gladiator_y% = 86
		Local stock_name$ = "standard-issue gladiator"
		Local stock_rect:BOX = Create_BOX( 5, gladiator_y, TextWidth(stock_name) + 10, 12 )
		If Not mouse_dragging ..
		And mouse.pos_x >= stock_rect.x And mouse.pos_x <= stock_rect.x + stock_rect.w ..
		And mouse.pos_y >= stock_rect.y And mouse.pos_y <= stock_rect.y + stock_rect.h
			hover_gladiator = True
			'tooltip = "inventory item"
			'draw the gladiator object near the mouse
			stock_gladiator.move_to( mouse, True, True )
			stock_gladiator.draw( 0.5, MOUSE_SHADOW_SCALE )
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
		Local h% = TextHeight( "A" )
		Local inv_y% = 107
		For Local i% = 0 Until inventory.Length
			If profile.inventory[i].damaged 'Or v_dat.is_unit
				inv_y :- h
			Else
				Local name$ = ""
				Local compatible% = True
				If COMPLEX_AGENT(inventory[i])
					name = COMPLEX_AGENT(inventory[i]).name
				Else If TURRET(inventory[i])
					name = TURRET(inventory[i]).name
					compatible = (v_dat.chassis_key <> "" And v_dat.chassis_compatible_with_turret( profile.inventory[i].key ))
				End If
				If name = ""
					Continue 'skip blank names
				Else 'name = "{item_name}"
					name = format_number(unused_inventory_count[i])+" "+name
				End If
				Local listing_rect:BOX = Create_BOX( 5, inv_y + i*h, TextWidth(name) + 10, 12 )
				'if hovering over the inventory listing and it has not yet been used ..
				If Not mouse_dragging ..
				And compatible ..
				And unused_inventory_count[i] > 0 ..
				And mouse.pos_x >= listing_rect.x And mouse.pos_x <= listing_rect.x + listing_rect.w ..
				And mouse.pos_y >= listing_rect.y And mouse.pos_y <= listing_rect.y + listing_rect.h
					hover_inventory_listing = i
					'tooltip = "inventory item"
					'move the actual object representing the inventory item to the mouse position
					inventory[i].move_to( mouse, True, True )
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
					inventory[i].draw( 0.5, MOUSE_SHADOW_SCALE )
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
					If compatible
						SetColor( 255, 255, 255 )
					Else
						SetColor( 196, 127, 127 )
					End If
				End If
				'regardless of the hover state, show the text of the item's description
				DrawText_with_outline( name, 10, inv_y + i*h )
				'incompatibility show
				If Not compatible
					'DrawLine_awesome( 8, inv_y + (i + 0.333)*h, TextWidth(name) + 8, inv_y + (i + 0.333)*h, False, 3, 1 )
					SetRotation( 0 )
					SetScale( 1, 1 )
					SetColor( 255, 255, 255 )
					SetAlpha( 1 )
					DrawImage( get_image( "lock" ), TextWidth(name) + 15, inv_y + i*h - 3 )
				End If
			End If
		Next
		
		'drag destinations: chassis hover, turret anchor hover
		Local gonna_show_turret_anchor_line% = ..
			(Not v_dat.is_unit ..
			And closest_turret_anchor ..
			And Not dragging_chassis ..
			And (v_dat.count_turrets( closest_turret_anchor_i ) > 0 Or mouse_items))
		If chassis_hover And Not gonna_show_turret_anchor_line
			SetAlpha( 0.085 )
			SetColor( 255, 255, 255 )
			SetScale( 1, 1 )
			DrawOval( player.pos_x - CHASSIS_HOVER_RADIUS, player.pos_y - CHASSIS_HOVER_RADIUS, 2*CHASSIS_HOVER_RADIUS, 2*CHASSIS_HOVER_RADIUS ) 
		End If

		'draw player in current state
		If player.img 'valid player
			player.draw( 1.0, STAGE_SCALE )
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
			If hovering_on_back_button 'done
				SetClsColor( 0, 0, 0 )
				FlushKeys()
				FlushMouse()
				Return v_dat
			End If
			
			mouse_dragging = True
			mouse_shadow = New COMPLEX_AGENT
			mouse_shadow.add_turret_anchor()
			dragging_inventory_i = -1
			
			If closest_turret_anchor And Not v_dat.is_unit And v_dat.count_turrets( closest_turret_anchor_i ) > 0 'started a drag op near a turret anchor
				'remove the turrets from the vehicle data and refresh the player object
				Local returned_turret_keys$[] = v_dat.get_turrets( closest_turret_anchor_i )
				Local result$ = v_dat.remove_turrets( closest_turret_anchor_i )
				If result = "success" 'removed turrets successfully
					dragging_anchor = closest_turret_anchor_i
					player = bake_player( v_dat, STAGE_SCALE )
					DebugLog " dragging turrets: [ "+", ".Join(returned_turret_keys)+" ] from anchor "+closest_turret_anchor_i
					'attach a copy of any turret attached to the closest anchor to the mouse shadow
					If returned_turret_keys
						mouse_items = New INVENTORY_DATA[returned_turret_keys.Length]
						For Local i% = 0 Until returned_turret_keys.Length
							mouse_items[i] = Create_INVENTORY_DATA( "turret", returned_turret_keys[i] )
							Local t:TURRET = get_turret( mouse_items[i].key )
							If t
								mouse_shadow.add_turret( t, 0 )
							End If
						Next
						mouse_shadow.set_images_unfiltered()
						mouse_shadow.scale_all( STAGE_SCALE )
					End If
				Else 'error
					show_error( result )
				End If
				
			Else If chassis_hover And player.img 'yanked a valid chassis
				dragging_chassis = True
				mouse_shadow = player
				'mouse_shadow.scale_all( 1/STAGE_SCALE )
				'mouse_shadow.scale_all( MOUSE_SHADOW_SCALE )
				mouse_shadow.move_to( mouse, True, True )
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
				player = bake_player( v_dat, STAGE_SCALE )
			
			Else If hover_inventory_listing >= 0 'started a drag op near an inventory item
				dragging_inventory_i = hover_inventory_listing
				unused_inventory_count[hover_inventory_listing] :- 1
				'attach the inventory turret to or set the chassis of the mouse shadow
				If COMPLEX_AGENT(inventory[hover_inventory_listing])
					dragging_chassis = True
					mouse_shadow = COMPLEX_AGENT( COMPLEX_AGENT.Copy( COMPLEX_AGENT(inventory[hover_inventory_listing]) ))
					mouse_shadow.scale_all( 1/MOUSE_SHADOW_SCALE )
					mouse_shadow.scale_all( STAGE_SCALE )
					mouse_items = [ profile.inventory[hover_inventory_listing].clone() ]
				Else If TURRET(inventory[hover_inventory_listing])
					mouse_shadow.add_turret( TURRET(inventory[hover_inventory_listing]), 0 )
					mouse_shadow.set_images_unfiltered()
					mouse_shadow.scale_all( 1/MOUSE_SHADOW_SCALE )
					mouse_shadow.scale_all( STAGE_SCALE )
					mouse_items = [ profile.inventory[hover_inventory_listing].clone() ]
				End If
				DebugLog " dragging item: "+profile.inventory[hover_inventory_listing].to_string()
			
			Else If hover_gladiator 'started dragging the stock gladiator
				dragging_chassis = True
				dragging_gladiator = True
				'attach the gladiator to the mouse chassis
				mouse_shadow = get_unit( stock_gladiator_key )
				mouse_shadow.set_images_unfiltered()
				mouse_shadow.scale_all( STAGE_SCALE )
				mouse_items = [ Create_INVENTORY_DATA( "unit", stock_gladiator_key )]
				DebugLog " dragging item: unit."+stock_gladiator_key
			End If
		
		Else If mouse_dragging And Not MouseDown( 1 ) And mouse_down_1 'FINISHED a drag
			mouse_dragging = False
			
			If closest_turret_anchor And Not dragging_chassis 'dropped onto a turret anchor
				If dragging_inventory_i >= 0 'dropped turret from inventory onto a turret anchor; add it to vehicle data and bake
					Local result$ = v_dat.add_turret( profile.inventory[dragging_inventory_i].key, closest_turret_anchor_i )
					If result = "success"
						player = bake_player( v_dat, STAGE_SCALE )
						DebugLog " added turret "+profile.inventory[dragging_inventory_i].key+" to anchor "+closest_turret_anchor_i
					Else If result.Find( "That socket already has a" ) <> -1 'error
						Local do_replacement% = False
						Local old_turret_keys$[] = v_dat.get_turrets( closest_turret_anchor_i )
						Local replaced_turret_index%
						If result = "That socket already has a large turret."
							do_replacement = True
							replaced_turret_index = 0
						Else If result = "That socket already has a small turret."
							do_replacement = True
							replaced_turret_index = 1
						End If
						If do_replacement
							'physically replace turret
							v_dat.turret_keys[closest_turret_anchor_i][replaced_turret_index] = profile.inventory[dragging_inventory_i].key
							'add replaced turret back to inventory
							For Local i% = 0 Until profile.inventory.Length
								Local tur_item:INVENTORY_DATA = Create_INVENTORY_DATA( "turret", old_turret_keys[replaced_turret_index] )
								If tur_item.eq( profile.inventory[i] )
									unused_inventory_count[i] :+ 1
								End If
							Next
						End If
						player = bake_player( v_dat, STAGE_SCALE )
					Else
						show_error( result )
						unused_inventory_count[dragging_inventory_i] :+ 1
					End If
				
				Else 'dropped a mess of turrets from the existing chassis
					'attach the turrets to the player at the nearest anchor
					Local new_turret_keys$[mouse_items.Length]
					For Local k% = 0 Until mouse_items.Length
						new_turret_keys[k] = mouse_items[k].key
					Next
					Local returned_turret_keys$[] = v_dat.get_turrets( closest_turret_anchor_i )
					Local result$ = v_dat.replace_turrets( new_turret_keys, closest_turret_anchor_i )
					If result = "success" 'replaced old turrets
						player = bake_player( v_dat, STAGE_SCALE )
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
			
			Else If dragging_chassis And chassis_hover 'dropped a chassis on the chassis
				'return the current chassis to the inventory
				For Local i% = 0 Until profile.inventory.Length
					If profile.inventory[i].key = v_dat.chassis_key
						unused_inventory_count[i] :+ 1
						Exit
					End If
				Next
				'use the new one
				If mouse_items[0].item_type = "unit"
					v_dat.set_chassis( mouse_items[0].key, True ) 'change the chassis to a unit
				Else If mouse_items[0].item_type = "chassis"
					v_dat.set_chassis( mouse_items[0].key, False ) 'change the chassis to a player chassis potentially with turrets
					If mouse_items.Length > 1
						v_dat = v_dat_backup
						v_dat_backup = New VEHICLE_DATA
					End If
				End If
				player = bake_player( v_dat, STAGE_SCALE )
				DebugLog " changed chassis to "+mouse_items[0].to_string()
			
			Else 'finished a drag near neither the chassis nor any of its turret anchors; drop it into the inventory
				
				If dragging_inventory_i >= 0 'dragging from inventory
					unused_inventory_count[dragging_inventory_i] :+ 1
					DebugLog " returned "+profile.inventory[dragging_inventory_i].to_string()+" to the inventory"
				
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
			dragging_chassis = False
			dragging_anchor = -1
			mouse_shadow = New COMPLEX_AGENT
			mouse_shadow.add_turret_anchor()
			mouse_items = Null
		End If
		
		'mouse state refresh
		If MouseDown( 1 )
			mouse_down_1 = True
		Else
			mouse_down_1 = False
		End If
		
		'turret anchor indicator
		If gonna_show_turret_anchor_line
			SetAlpha( 1.2 - mouse.dist_to( closest_turret_anchor )/ANCHOR_HOVER_RADIUS )
			DrawLine_awesome( mouse.pos_x, mouse.pos_y, closest_turret_anchor.x, closest_turret_anchor.y )
		End If
		
		'mouse shadow
		If mouse_dragging
			mouse_shadow.move_to( mouse, True )
			mouse_shadow.update()
			mouse_shadow.draw( 0.33333, STAGE_SCALE )
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
		
		'tooltip
		show_tooltip()
		
		If KeyDown( KEY_ESCAPE ) And esc_held And (now() - esc_press_ts) >= esc_held_progress_bar_show_time_required
			draw_instaquit_progress()
		End If
	
		Flip( 1 )
		
		kill_signal = AppTerminate()
	Until escape_key_release() Or KeyHit( KEY_BACKSPACE ) Or kill_signal
	If kill_signal Then End
	
	SetClsColor( 0, 0, 0 )
	FlushKeys()
	FlushMouse()

	Return v_dat
End Function

Function bake_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA, scale# = 1.0 )
	Local dummy$ = ""
	Local player:COMPLEX_AGENT = create_player( v_dat, False, False, dummy )
	If Not player Then player = New COMPLEX_AGENT
	player.set_images_unfiltered()
	player.scale_all( scale )
	player.move_to( Create_POINT( window_w/2, window_h/2, 0 ), True, True )
	player.update()
	Return player
End Function

Function show_error( err$ )
	DebugLog " "+err
End Function

Global tooltip$ = ""
Function show_tooltip()
	SetImageFont( get_font( "consolas_12" ))
	SetAlpha( 1 )
	SetRotation( 0 )
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	DrawText_with_outline( tooltip, mouse.pos_x - TextWidth( tooltip )/2.0, mouse.pos_y + TextHeight( tooltip ) + 2 )
End Function

Function DrawLine_awesome( x1#, y1#, x2#, y2#, balls% = True, outer_width% = 5, inner_width% = 2 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor( 0, 0, 0 )
	If balls
		DrawOval( x1 - 5, y1 - 5, 10, 10 )
		DrawOval( x2 - 5, y2 - 5, 10, 10 )
	End If
	SetLineWidth( outer_width )
	DrawLine( x1, y1, x2, y2 )
	SetColor( 255, 255, 255 )
	If balls
		DrawOval( x1 - 3, y1 - 3, 6, 6 )
		DrawOval( x2 - 3, y2 - 3, 6, 6 )
	End If
	SetLineWidth( inner_width )
	DrawLine( x1, y1, x2, y2 )
	SetLineWidth( 1 )
End Function

