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
	Field damaged_inventory:INVENTORY_DATA[]
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
	
	Method buy_part( query_item:INVENTORY_DATA )
		If can_buy( query_item )
			Local cost% = get_cost( query_item )
			profile.cash :- cost
			add_part( query_item )
		End If
	End Method
	
	Method sell_part( query_item:INVENTORY_DATA, damaged% = False )
		If can_sell( query_item )
			Local cost% = get_cost( query_item, damaged )
			Local item_index% = search_inventory( query_item )
			profile.cash :+ cost
			remove_part( item_index )
		End If
	End Method
	
	Method can_buy%( query_item:INVENTORY_DATA )
		Local cost% = 0
		Select query_item.item_type
			Case "chassis"
				cost = get_player_chassis( query_item.key ).cash_value
			Case "turret"
				cost = get_turret( query_item.key ).cash_value
		End Select
		If profile.cash >= cost
			Return True
		End If
	End Method
	
	Method can_sell%( query_item:INVENTORY_DATA )
		Return count_inventory( query_item ) >= 1
	End Method
	
	Method get_cost%( query_item:INVENTORY_DATA, damaged% = False )
		Local factor# = 1.0
		If damaged Then factor = 0.5
		Select query_item.item_type
			Case "chassis"
				Return get_player_chassis( query_item.key ).cash_value * factor
			Case "turret"
				Return get_turret( query_item.key ).cash_value * factor
		End Select
	End Method
	
	Method checklist%( item_list:TList )
		For Local item:INVENTORY_DATA = EachIn item_list
			If count_inventory( item ) < item.count
				Return False 'not enough of an item
			End If
		Next
		Return True 'everything checks out
	End Method
	
	Method count_inventory%( query_item:INVENTORY_DATA, damaged% = False )
		Local item_collection:INVENTORY_DATA[]
		If Not damaged Then item_collection = inventory ..
		Else item_collection = damaged_inventory
		Local q% = search_inventory( query_item, damaged )
		Local item:INVENTORY_DATA
		If q >= 0
			item = item_collection[q]
		End If
		If item
			Return item.count
		Else
			Return 0
		End If
	End Method
	
	Method search_inventory%( query_item:INVENTORY_DATA, damaged% = False )
		Local item_collection:INVENTORY_DATA[]
		If Not damaged Then item_collection = inventory ..
		Else item_collection = damaged_inventory
		If item_collection
			For Local i% = 0 To item_collection.Length - 1
				If item_collection[i].eq( query_item ) Then Return i
			Next
		End If
		Return -1
	End Method
	
	Method add_part( new_item:INVENTORY_DATA, damaged% = False )
		Local item_collection:INVENTORY_DATA[]
		If Not damaged Then item_collection = inventory ..
		Else item_collection = damaged_inventory
		Local q% = search_inventory( new_item, damaged )
		Local item:INVENTORY_DATA
		If q >= 0
			item = item_collection[q]
		End If
		If item 'named item exists currently
			item.count :+ 1
		Else 'item does not yet exist
			If item_collection
				item_collection = item_collection[..(item_collection.Length + 1)]
				item_collection[item_collection.Length - 1] = new_item.clone()
			Else 'Not item_collection
				item_collection = [ new_item.clone() ]
			End If
			If Not damaged Then inventory = item_collection ..
			Else damaged_inventory = item_collection
		End If
	End Method
	
	Method remove_part:INVENTORY_DATA( item_index%, damaged% = False )
		Local item_collection:INVENTORY_DATA[]
		If Not damaged Then item_collection = inventory ..
		Else item_collection = damaged_inventory
		If item_collection
			Local item:INVENTORY_DATA = item_collection[item_index]
			item.count :- 1
			If item.count <= 0
				If item_collection.Length > 1
					Local new_item_collection:INVENTORY_DATA[item_collection.Length - 1]
					If item_index > 0
						For Local i% = 0 To item_index - 1
							new_item_collection[i] = item_collection[i]
						Next
					End If
					If item_index < item_collection.Length - 1
						For Local i% = item_index + 1 To item_collection.Length - 1
							new_item_collection[i - 1] = item_collection[i]
						Next
					End If
					If Not damaged Then inventory = new_item_collection ..
					Else damaged_inventory = new_item_collection
					Return item
				Else 'inventory.Length <= 1
					If Not damaged Then inventory = Null ..
					Else damaged_inventory = Null
				End If
			End If
		End If
		Return Null
	End Method
	
	Method damage_part( query_item:INVENTORY_DATA )
		Local index% = search_inventory( query_item )
		If index >= 0
			Local item:INVENTORY_DATA = remove_part( index )
			add_part( item, True )
		End If
	End Method
	
	Method generate_src_path$()
		Return user_path + name + "." + saved_game_file_ext
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		If inventory
			Local inv:TJSONArray = TJSONArray.Create( inventory.Length )
			For Local i% = 0 Until inventory.Length
				inv.SetByIndex( i, inventory[i].to_json() )
			Next
			this_json.SetByName( "inventory", inv )
		Else
			this_json.SetByName( "inventory", Null )
		End If
		If damaged_inventory
			Local inv:TJSONArray = TJSONArray.Create( damaged_inventory.Length )
			For Local i% = 0 Until damaged_inventory.Length
				inv.SetByIndex( i, damaged_inventory[i].to_json() )
			Next
			this_json.SetByName( "damaged_inventory", inv )
		Else
			this_json.SetByName( "damaged_inventory", Null )
		End If
		If vehicle
			this_json.SetByName( "vehicle", vehicle.to_json() )
		Else
			this_json.SetByName( "vehicle", Null )
		End If
		this_json.SetByName( "input_method", TJSONNumber.Create( input_method ))
		If progress
			Local prog:TJSONArray = TJSONArray.Create( progress.Length )
			For Local i% = 0 Until progress.Length
				prog.SetByIndex( i, progress[i].to_json() )
			Next
			this_json.SetByName( "progress", prog )
		Else
			this_json.SetByName( "progress", Null )
		End If
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
	inv = json.GetArray( "damaged_inventory" )
	If inv
		prof.damaged_inventory = New INVENTORY_DATA[ inv.Size() ]
		For Local i% = 0 To prof.damaged_inventory.Length - 1
			prof.damaged_inventory[i] = Create_INVENTORY_DATA_from_json( TJSON.Create( inv.GetByIndex( i )))
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


