Rem
	player_profile.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "inventory_data.bmx"
'Import "constants.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Global profile:PLAYER_PROFILE

Type PLAYER_PROFILE
	Field name$
	Field cash%
	Field kills%
	Field levels_beaten$[]
	
	Field src_path$ 'private field, used for load/save
		
	Method generate_src_path$()
		Return user_path + name + "." + saved_game_file_ext
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "cash", TJSONNumber.Create( cash ))
		this_json.SetByName( "kills", TJSONNumber.Create( kills ))
		this_json.SetByName( "levels_beaten", Create_TJSONArray_from_String_array( levels_beaten ))
		Return this_json
	End Method
End Type

Function Create_PLAYER_PROFILE_from_json:PLAYER_PROFILE( json:TJSON )
	Local prof:PLAYER_PROFILE = New PLAYER_PROFILE
	prof.name = json.GetString( "name" )
	prof.cash = json.GetNumber( "cash" )
	prof.kills = json.GetNumber( "kills" )
	prof.levels_beaten = json.GetArrayString( "levels_beaten" )
	Return prof
End Function

