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
		src_path = generate_src_path()
	End Method
	
	Method buy_part( query_item:INVENTORY_DATA )
		If can_buy( query_item )
			Local cost% = get_cost( query_item )
			profile.cash :- cost
			add_part( query_item )
		End If
	End Method
	
	Method sell_part( query_item:INVENTORY_DATA )
		If can_sell( query_item )
			Local cost% = get_cost( query_item )
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
			Default
				Return False
		End Select
		If profile.cash >= cost
			Return True
		End If
		Return False
	End Method
	
	Method can_sell%( query_item:INVENTORY_DATA )
		Return count_inventory( query_item ) >= 1
	End Method
	
	Method get_cost%( query_item:INVENTORY_DATA )
		If query_item
			Local factor# = 1.0
			If query_item.damaged Then factor = 0.5
			Return factor * get_inventory_object_cost( query_item.item_type, query_item.key )
		End If
		Return 0
	End Method
	
	Method checklist%( item_list:TList )
		For Local item:INVENTORY_DATA = EachIn item_list
			If count_inventory( item ) < item.count
				Return False 'not enough of an item
			End If
		Next
		Return True 'everything checks out
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
	
	Method search_inventory%( query_item:INVENTORY_DATA )
		If inventory
			For Local i% = 0 To inventory.Length - 1
				If inventory[i].eq( query_item ) Then Return i
			Next
		End If
		Return -1
	End Method
	
	Method add_part( new_item:INVENTORY_DATA )
		Local q% = search_inventory( new_item )
		Local item:INVENTORY_DATA
		If q >= 0
			item = inventory[q]
		End If
		If item
			item.count :+ 1
		Else
			If inventory
				inventory = inventory[..(inventory.Length + 1)]
				inventory[inventory.Length - 1] = new_item.clone()
			Else 'Not inventory
				inventory = [ new_item.clone() ]
			End If
		End If
	End Method
	
	Method remove_part:INVENTORY_DATA( item_index%, count% = 1 )
		If item_index >= 0 And item_index < inventory.Length
			Local item:INVENTORY_DATA = inventory[item_index]
			If item.count >= count 'have enough
				Local removed_item:INVENTORY_DATA = item.clone() 'create a copy of the item
				removed_item.count = count 'requested units to be returned
				item.count :- count 'remove requested units from self inventory
				If item.count <= 0 'none left of this item
					If inventory.Length > 1 'inventory has other items
						Local new_inventory:INVENTORY_DATA[inventory.Length - 1]
						If item_index > 0 'item is not the "first" item
							For Local i% = 0 To item_index - 1
								new_inventory[i] = inventory[i]
							Next
						End If
						If item_index < inventory.Length - 1 'item is not the "last" item
							For Local i% = item_index + 1 To inventory.Length - 1
								new_inventory[i - 1] = inventory[i]
							Next
						End If
						inventory = new_inventory 'resized inventory, excluding the zero'd item
					Else 'inventory.Length <= 1
						inventory = Null 'no other items left
					End If
				End If
				Return removed_item 'return requested item
			End If
		End If
		Return Null
	End Method
	
	Method damage_part( query_item:INVENTORY_DATA )
		Local index% = search_inventory( query_item )
		If index >= 0
			Local item:INVENTORY_DATA = remove_part( index )
			item.damaged = True
			add_part( item )
		End If
	End Method
	
	Method sort_inventory()
		inventory.Sort()
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
		'check inventory; remove those with low count or invalid identifiers
		For Local i% = prof.inventory.Length - 1 To 0 Step -1
			If prof.inventory[i].count < 1
				prof.remove_part( i )
			End If
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


