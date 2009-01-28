Rem
	player_profile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type PLAYER_PROFILE
	Field name$
	Field inventory%[]
	Field input_method%
	Field current_level$
	Field cash%
	Field kills%

	Field src_path$
	Field selected_inventory_index%
		
	Method New()
		name = "new_profile"
		inventory = Null
		input_method = CONTROL_BRAIN.INPUT_KEYBOARD_MOUSE_HYBRID
		cash = shop_item_prices[0]
		src_path = generate_src_path()
	End Method
	
	Method generate_src_path$()
		Return user_path + name + "." + saved_game_file_ext
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "inventory", Create_TJSONArray_from_Int_array( inventory ))
		this_json.SetByName( "input_method", TJSONNumber.Create( input_method ))
		this_json.SetByName( "current_level", TJSONString.Create( current_level ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		this_json.SetByName( "selected_inventory_index", TJSONNumber.Create( selected_inventory_index ))
		Return this_json
	End Method
End Type

Function Create_PLAYER_PROFILE_from_json:PLAYER_PROFILE( json:TJSON )
	Local prof:PLAYER_PROFILE = New PLAYER_PROFILE
	prof.name = json.GetString( "name" )
	prof.inventory = Create_Int_array_from_TJSONArray( json.GetArray( "inventory" ))
	prof.input_method = json.GetNumber( "input_method" )
	prof.current_level = json.GetString( "current_level" )
	prof.cash = json.GetNumber( "cash" )
	prof.kills = json.GetNumber( "kills" )
	prof.selected_inventory_index = json.GetNumber( "selected_inventory_index" )
	Return prof
End Function
