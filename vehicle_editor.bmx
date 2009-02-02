Rem
	vehicle_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const ANCHOR_HOVER_RADIUS% = 100

Function vehicle_editor( v_dat:VEHICLE_DATA )
	Local mouse:POINT = Create_POINT( MouseX(), MouseY() )
	'Local last_mouse:POINT = Copy_POINT( mouse )
	Local mouse_drag_start:POINT
	Local mouse_dragging%
	Local mouse_down_1%
	Local player:COMPLEX_AGENT = bake_player( v_dat )
	Local mouse_shadow:COMPLEX_AGENT = New COMPLEX_AGENT
	mouse_shadow.add_turret_anchor( cVEC.Create( 0, 0 ))
	Local title$ = "customize vehicle"
	
	'cache inventory items
	Local inventory:POINT[profile.inventory.Length]
	For Local i% = 0 Until profile.inventory.Length
		Local item:INVENTORY_DATA = profile.inventory[i]
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
		
		'mouse hover over closest anchor
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

		'click/drag detection
		If Not mouse_dragging And MouseDown( 1 ) And Not mouse_down_1
			mouse_dragging = True
			mouse_drag_start = Copy_POINT( mouse )
			mouse_shadow.remove_all_turrets()
			If closest_turret_anchor 'started a drag op near a turret anchor
				'attach a copy of any turret attached to the closest anchor to the mouse shadow
				For Local i% = 0 Until v_dat.turret_key[closest_turret_anchor_i].Length
					mouse_shadow.add_turret( get_turret( v_dat.turret_key[closest_turret_anchor_i][i] ), closest_turret_anchor_i )
				Next
				mouse_shadow.set_images_unfiltered()
				'remove all the turrets on the anchor point
				
			End If
		Else If mouse_dragging And Not MouseDown( 1 ) And mouse_down_1
			mouse_dragging = False
			mouse_drag_start = Null
			If closest_turret_anchor 'concluded a drag op near a turret anchor
				'attach the mouse_shadow turret to the player object and the vehicle data, and update its on-screen avatar
				
			End If
		End If
		
		'draw player in current state
		player.draw( 0.5, 8.0 )
		
		'draw inventory
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetImageFont( get_font( "consolas_14" ))
		DrawText_with_outline( "inventory", 10, 60 )
		SetImageFont( get_font( "consolas_12" ))
		Local inv_y% = 80
		For Local i% = 0 Until inventory.Length
			Local name$ = ""
			If COMPLEX_AGENT(inventory[i]) Then name = COMPLEX_AGENT(inventory[i]).name
			If TURRET(inventory[i]) Then name = TURRET(inventory[i]).name
			DrawText_with_outline( name, 10, inv_y + i*TextHeight(name) )
'			If some_condition
'				inventory[i].move_to( mouse )
'				inventory[i].draw( 0.5, 3.0 )
'			End If
		Next
		
		'closest turret anchor (if any)
		If closest_turret_anchor
			SetAlpha( 1.2 - mouse.dist_to( closest_turret_anchor )/ANCHOR_HOVER_RADIUS )
			DrawLine_awesome( mouse.pos_x, mouse.pos_y, closest_turret_anchor.x, closest_turret_anchor.y )
		End If
		
		'mouse shadow
		If mouse_dragging
			mouse_shadow.move_to( mouse, True )
			mouse_shadow.draw( 0.5, 3.0 )
		End If
		
		'mouse state
		If MouseDown( 1 )
			mouse_down_1 = True
		Else
			mouse_down_1 = False
		End If
		
		Flip( 1 )
	Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
	If AppTerminate() Then End
	
	SetClsColor( 0, 0, 0 )
End Function

Function bake_player:COMPLEX_AGENT( v_dat:VEHICLE_DATA )
	Local player:COMPLEX_AGENT = create_player( v_dat )
	player.set_images_unfiltered()
	player.move_to( Create_POINT( window_w/2, window_h/2, 0 ), True )
	player.update()
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

