Rem
	vehicle_editor.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const ANCHOR_HOVER_RADIUS% = 150

Function vehicle_editor( v_dat:VEHICLE_DATA )
	Local mouse:POINT = Create_POINT( MouseX(), MouseY() )
	Local last_mouse:POINT = Copy_POINT( mouse )
	Local mouse_drag_start:POINT
	Local mouse_dragging%
	Local mouse_down_1%
	Local player:COMPLEX_AGENT = bake_player( v_dat )
	Local title$ = "customize vehicle"
	
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
		last_mouse = Copy_POINT( mouse )
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
		If MouseDown( 1 ) And Not mouse_down_1 And Not mouse_dragging
			mouse_dragging = True
			mouse_drag_start = Copy_POINT( mouse )
			
			If closest_turret_anchor
				'started drag near a turret anchor
				'is there anything attached?
				For Local turret_i% = EachIn player.turret_systems[closest_turret_anchor_i]
					
				Next
			End If
			
			
		Else If Not MouseDown( 1 ) And mouse_down_1 And mouse_dragging
			mouse_dragging = False
			mouse_drag_start = Null
		End If
		
		'draw player in current state
		player.draw( 0.5, 8.0 )
		
		'closest turret anchor (if any)
		If closest_turret_anchor
			DrawLine_awesome( mouse.pos_x, mouse.pos_y, closest_turret_anchor.x, closest_turret_anchor.y )
		End If
		
		'mouse state
		If MouseDown( 1 ) Then mouse_down_1 = True Else mouse_down_1 = False
		
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

