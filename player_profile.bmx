Rem
	player_profile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PLAYER_PROFILE
	Field name$
	Field cash%
	Field kills%
	Field inventory:INVENTORY_DATA[]
	Field vehicle:VEHICLE_DATA
	Field input_method%
	Field progress:PROGRESS_DATA[]
	Field campaign$
	Field campaign_level%
	
	Field src_path$ 'private field, used for load/save
		
	Method New()
		name = "new_profile"
		cash = 0
		kills = 0
		input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
		src_path = generate_src_path()
	End Method
	
	Method count_inventory%( query_item:INVENTORY_DATA )
		Local q% = search_inventory( query_item )
		Local item:INVENTORY_DATA
		If q >= 0
			item = inventory[q]
		End If
		If item
			Return item.count
		Else
			Return 0
		End If
	End Method
	
	Method buy_part( query_item:INVENTORY_DATA )
		Local cost% = 0
		Select query_item.item_type
			Case "chassis"
				cost = get_player_chassis( query_item.key ).cash_value
			Case "turret"
				cost = get_turret( query_item.key ).cash_value
		End Select
		If profile.cash > cost
			profile.cash :- cost
			Local q% = search_inventory( query_item )
			Local item:INVENTORY_DATA
			If q >= 0
				item = inventory[q]
			End If
			If item
				item.count :+ 1
			Else
				If inventory
					inventory = inventory[..(inventory.Length + 1)]
					inventory[inventory.Length - 1] = query_item.clone()
				Else 'Not inventory
					inventory = [ query_item.clone() ]
				End If
			End If
		End If
	End Method
	
	Method sell_part( query_item:INVENTORY_DATA )
		Local cost% = 0
		Select query_item.item_type
			Case "chassis"
				cost = get_player_chassis( query_item.key ).cash_value
			Case "turret"
				cost = get_turret( query_item.key ).cash_value
		End Select
		Local q% = search_inventory( query_item )
		Local item:INVENTORY_DATA
		If q >= 0
			item = inventory[q]
		End If
		If item
			If item.count > 0
				item.count :- 1
				profile.cash :+ cost
			End If
			If item.count <= 0
				If inventory.Length > 1
					Local new_inventory:INVENTORY_DATA[inventory.Length - 1]
					If q > 0
						For Local i% = 0 To q - 1
							new_inventory[i] = inventory[i]
						Next
					End If
					If q < inventory.Length - 1
						For Local i% = q + 1 To inventory.Length - 1
							new_inventory[i - 1] = inventory[i]
						Next
					End If
					inventory = new_inventory
				Else 'inventory.Length <= 1
					inventory = Null
				End If
			End If
		End If
	End Method
	
	Method search_inventory%( query_item:INVENTORY_DATA )
		If inventory
			For Local i% = 0 To inventory.Length - 1
				If inventory[i].eq( query_item ) Then Return i
			Next
		End If
		Return -1
	End Method
	
	Method generate_src_path$()
		Return user_path + name + "." + saved_game_file_ext
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		Local inv:TJSONArray = TJSONArray.Create( inventory.Length )
		For Local i% = 0 To inventory.Length - 1
			inv.SetByIndex( i, inventory[i].to_json() )
		Next
		this_json.SetByName( "inventory", inv )
		this_json.SetByName( "vehicle", vehicle.to_json() )
		this_json.SetByName( "input_method", TJSONNumber.Create( input_method ))
		Local prog:TJSONArray = TJSONArray.Create( progress.Length )
		For Local i% = 0 To progress.Length - 1
			prog.SetByIndex( i, progress[i].to_json() )
		Next
		this_json.SetByName( "progress", prog )
		this_json.SetByName( "campaign", TJSONString.Create( campaign ))
		this_json.SetByName( "campaign_level", TJSONNumber.Create( campaign_level ))
		Return this_json
	End Method
End Type

Function Create_PLAYER_PROFILE_from_json:PLAYER_PROFILE( json:TJSON )
	Local prof:PLAYER_PROFILE = New PLAYER_PROFILE
	prof.name = json.GetString( "name" )
	prof.cash = json.GetNumber( "cash" )
	prof.kills = json.GetNumber( "kills" )
	Local inv:TJSONArray = json.GetArray( "inventory" )
	If inv
		prof.inventory = New INVENTORY_DATA[ inv.Size() ]
		For Local i% = 0 To prof.inventory.Length - 1
			prof.inventory[i] = Create_INVENTORY_DATA_from_json( TJSON.Create( inv.GetByIndex( i )))
		Next
	End If
	prof.vehicle = Create_VEHICLE_DATA_from_json( TJSON.Create( json.GetObject( "vehicle" )))
	prof.input_method = json.GetNumber( "input_method" )
	Local prog:TJSONArray = json.GetArray( "progress" )
	If prog
		prof.progress = New PROGRESS_DATA[ prog.Size() ]
		For Local i% = 0 To prof.progress.Length - 1
			prof.progress[i] = Create_PROGRESS_DATA_from_json( TJSON.Create( prog.GetByIndex( i )))
		Next
	End If
	prof.campaign = json.GetString( "campaign" )
	prof.campaign_level = json.GetNumber( "campaign_level" )
	Return prof
End Function

'______________________________________________________________________________
'helper classes
'_________________
Function Create_INVENTORY_DATA:INVENTORY_DATA( item_type$, key$, count% = 1 )
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = item_type
	item.key = key
	item.count = count
	Return item
End Function
Type INVENTORY_DATA
	Field item_type$
	Field key$
	Field count%
	Method clone:INVENTORY_DATA()
		Return Create_INVENTORY_DATA( item_type, key, count )
	End Method
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "item_type", TJSONString.Create( item_type ))
		this_json.SetByName( "key", TJSONString.Create( key ))
		this_json.SetByName( "count", TJSONNumber.Create( count ))
		Return this_json
	End Method
	Method eq%( other:INVENTORY_DATA )
		If Not other Then Return False
		Return item_type = other.item_type And key = other.key
	End Method
End Type
Function Create_INVENTORY_DATA_from_json:INVENTORY_DATA( json:TJSON ) 
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = json.GetString( "item_type" ) 
	item.key = json.GetString( "key" )
	item.count = json.GetNumber( "count" )
	Return item
End Function
'_________________
Type VEHICLE_DATA
	Field chassis_key$
	Field turrets:TURRET_DATA[]
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "chassis_key", TJSONString.Create( chassis_key ))
		Local turs:TJSONArray = TJSONArray.Create( turrets.Length )
		For Local i% = 0 To turrets.Length - 1
			turs.SetByIndex( i, turrets[i].to_json() )
		Next
		this_json.SetByName( "turrets", turs )
		Return this_json
	End Method
End Type
Function Create_VEHICLE_DATA_from_json:VEHICLE_DATA( json:TJSON )
	Local vd:VEHICLE_DATA = New VEHICLE_DATA
	vd.chassis_key = json.GetString( "chassis" )
	Local ts:TJSONArray = json.GetArray( "turrets" )
	vd.turrets = New TURRET_DATA[ ts.Size() ]
	For Local i% = 0 To vd.turrets.Length - 1
		vd.turrets[i] = Create_TURRET_DATA_from_json( TJSON.Create( ts.GetByIndex( i )))
	Next
	Return vd
End Function
'________________
Type TURRET_DATA
	Field turret_key$
	Field anchor%
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "turret_key", TJSONString.Create( "turret_key" ))
		this_json.SetByName( "anchor", TJSONNumber.Create( anchor ))
		Return this_json
	End Method
End Type
Function Create_TURRET_DATA_from_json:TURRET_DATA( json:TJSON )
	Local td:TURRET_DATA = New TURRET_DATA
	td.turret_key = json.GetString( "turret" )
	td.anchor = json.GetNumber( "anchor" )
	Return td
End Function
'__________________
Type PROGRESS_DATA
	Field campaign_key$
	Field completed%[]
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "campaign_key", TJSONString.Create( campaign_key ))
		this_json.SetByName( "completed", Create_TJSONArray_from_Int_array( completed, True ))
		Return this_json
	End Method
End Type
Function Create_PROGRESS_DATA_from_json:PROGRESS_DATA( json:TJSON )
	Local pd:PROGRESS_DATA = New PROGRESS_DATA
	pd.campaign_key = json.GetString( "campaign" )
	pd.completed = Create_Int_array_from_TJSONArray( json.GetArray( "completed" ), True )
	Return pd
End Function

