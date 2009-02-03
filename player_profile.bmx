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
		End Select
		If profile.cash >= cost
			Return True
		End If
	End Method
	
	Method can_sell%( query_item:INVENTORY_DATA )
		Return count_inventory( query_item ) >= 1
	End Method
	
	Method get_cost%( query_item:INVENTORY_DATA )
		Select query_item.item_type
			Case "chassis"
				Return get_player_chassis( query_item.key ).cash_value
			Case "turret"
				Return get_turret( query_item.key ).cash_value
		End Select
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
	
	Method remove_part( item_index% )
		Local item:INVENTORY_DATA = inventory[item_index]
		item.count :- 1
		If item.count <= 0
			If inventory.Length > 1
				Local new_inventory:INVENTORY_DATA[inventory.Length - 1]
				If item_index > 0
					For Local i% = 0 To item_index - 1
						new_inventory[i] = inventory[i]
					Next
				End If
				If item_index < inventory.Length - 1
					For Local i% = item_index + 1 To inventory.Length - 1
						new_inventory[i - 1] = inventory[i]
					Next
				End If
				inventory = new_inventory
			Else 'inventory.Length <= 1
				inventory = Null
			End If
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
		this_json.SetByName( "vehicle", vehicle.to_json() )
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


'private helper classes
'______________________________________________________________________________
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
	
	Method eq%( other:INVENTORY_DATA )
		If Not other Then Return False
		Return item_type = other.item_type And key = other.key
	End Method
	
	Method to_string$()
		Return item_type+"."+key
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "item_type", TJSONString.Create( item_type ))
		this_json.SetByName( "key", TJSONString.Create( key ))
		this_json.SetByName( "count", TJSONNumber.Create( count ))
		Return this_json
	End Method
	
End Type

Function Create_INVENTORY_DATA_from_json:INVENTORY_DATA( json:TJSON ) 
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = json.GetString( "item_type" ) 
	item.key = json.GetString( "key" )
	item.count = json.GetNumber( "count" )
	Return item
End Function

'______________________________________________________________________________
Type VEHICLE_DATA
	Field chassis_key$
	Field is_unit%
	Field turret_keys$[][]
	
	Method set( new_chassis_key$, new_is_unit% = False )
		chassis_key = new_chassis_key
		is_unit = new_is_unit
	End Method
	
	Method add_turret$( key$, anchor% ) 'returns error message if unsuccessful
		'stock unit
		If is_unit Then Return "This vehicle is standard-issue, and not customizable."
		If anchor < turret_keys.Length
			Local t:TURRET = get_turret( key )
			If Not t Then Return "FATAL ERROR: turret."+key+" not found."
			'adding a turret can only be done if the chassis is compatible
			If Not chassis_compatible_with_turret( key )
				Return "This turret won't fit onto that chassis."
			End If
			If turret_keys[anchor] = Null
				If t.priority = TURRET.PRIMARY
					turret_keys[anchor] = [ key, String(Null) ]
				Else If t.priority = TURRET.SECONDARY
					turret_keys[anchor] = [ String(Null), key ]
				End If
			Else 'turret_key[anchor] <> Null
				'adding a primary turret can only be done if there are no turrets at all attached to this anchor
				If t.priority = TURRET.PRIMARY And turrets_of_priority_attached_to_anchor( TURRET.PRIMARY, anchor ) >= 1
					Return "That socket already has a large turret."
				End If
				'adding a secondary turret can only be done if there are no secondary turrets attached to this anchor
				If t.priority = TURRET.SECONDARY And turrets_of_priority_attached_to_anchor( TURRET.SECONDARY, anchor ) >= 1
					Return "That socket already has a small turret."
				End If
				'all good, add it
				If t.priority = TURRET.PRIMARY
					turret_keys[anchor] = [ key, turret_keys[anchor][1] ]
				Else If t.priority = TURRET.SECONDARY
					turret_keys[anchor] = [ turret_keys[anchor][0], key ]
				End If
			End If
		Else
			Return "FATAL ERROR: anchor "+anchor+" is not defined on this vehicle."
		End If
		Return "success"
	End Method
	
	Method replace_turrets:Object( keys$[], anchor% ) 'returns the old array if successful
DebugStop
		'stock unit
		If is_unit Then Return "This vehicle is standard-issue, and not customizable."
		'if any of the turrets are incompatible, abort with error
		For Local key$ = EachIn keys
			If Not chassis_compatible_with_turret( key )
				Return "One of the turrets won't fit onto that chassis."
			End If
		Next
		'all good, replace it
		Local old_turrets$[] = turret_keys[anchor][..]
		If anchor < turret_keys.Length
			turret_keys[anchor] = keys
		End If
		Return old_turrets 'success
	End Method
	
	Method remove_turrets:Object( anchor% ) 'returns the old array if successful
		If is_unit Then Return "This vehicle is standard-issue, and not customizable."
		Local old_turrets$[] = turret_keys[anchor][..]
		If anchor < turret_keys.Length
			turret_keys[anchor] = Null
		End If
		Return old_turrets
	End Method
	
	Method chassis_compatible_with_turret%( key$ ) 'checks the compatibility array for the existence of the given turret key
		Local cd:COMPATIBILITY_DATA = get_compatibility( chassis_key )
		For Local tur$ = EachIn cd.turret_keys
			If tur = key Then Return True
		Next
		Return False
	End Method
	
	Method turrets_of_priority_attached_to_anchor%( priority%, anchor% )
		If anchor < turret_keys.Length
			Local count% = 0
			For Local key$ = EachIn turret_keys[anchor]
				Local t:TURRET = get_turret( key, False )
				If t And t.priority = priority Then count :+ 1
			Next
			Return count
		End If
		Return -1
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "chassis_key", TJSONString.Create( chassis_key ))
		this_json.SetByName( "is_unit", TJSONBoolean.Create( is_unit ))
		this_json.SetByName( "turret_keys", Create_TJSONArray_from_String_array_array( turret_keys ))
		Return this_json
	End Method
End Type

Function Create_VEHICLE_DATA_from_json:VEHICLE_DATA( json:TJSON )
	Local vd:VEHICLE_DATA = New VEHICLE_DATA
	vd.chassis_key = json.GetString( "chassis_key" )
	vd.is_unit = json.GetBoolean( "is_unit" )
	vd.turret_keys = Create_String_array_array_from_TJSONArray( json.GetArray( "turret_keys" ))
	Return vd
End Function

'______________________________________________________________________________
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

'____________________________
Type COMPATIBILITY_DATA
	Field chassis_key$
	Field inherits_from$
	Field turret_keys$[]
	
	Method clone:COMPATIBILITY_DATA()
		Local cd:COMPATIBILITY_DATA = New COMPATIBILITY_DATA
		cd.chassis_key = chassis_key
		cd.inherits_from = inherits_from
		cd.turret_keys = turret_keys[..]
		Return cd
	End Method
	
	Method inherit( other_cd:COMPATIBILITY_DATA )
		If turret_keys
			If other_cd.turret_keys
				Local old_size% = turret_keys.Length
				turret_keys = turret_keys[..(turret_keys.Length+other_cd.turret_keys.Length)]
				For Local i% = 0 Until other_cd.turret_keys.Length
					turret_keys[i + old_size] = other_cd.turret_keys[i]
				Next
			End If
		Else
			turret_keys = other_cd.turret_keys[..]
		End If
	End Method
	
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

