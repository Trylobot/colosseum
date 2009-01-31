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
Type INVENTORY_DATA
	Field item_type$
	Field key$
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "item_type", TJSONString.Create( item_type ))
		this_json.SetByName( "key", TJSONString.Create( key ))
		Return this_json
	End Method
End Type
Function Create_INVENTORY_DATA_from_json:INVENTORY_DATA( json:TJSON ) 
	Local id:INVENTORY_DATA = New INVENTORY_DATA
	id.item_type = json.GetString( "item_type" ) 
	id.key = json.GetString( "key" ) 
	Return id
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

