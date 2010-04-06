Rem
	campaign_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "json.bmx"

'______________________________________________________________________________
Global campaign_data_map:TMap = CreateMap()
Global campaign_ordering$[]

Function get_campaign_data:CAMPAIGN_DATA( key$ ) 'returns a reference to the global instance
	Local data:CAMPAIGN_DATA = CAMPAIGN_DATA( campaign_data_map.ValueForKey( key.toLower() ))
	Return data
End Function

Type CAMPAIGN_DATA
	Field name$
	Field levels$[]
	Field player_vehicle$
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "name", TJSONString.Create( name ))
		this_json.SetByName( "levels", Create_TJSONArray_from_String_array( levels ))
		this_json.SetByName( "player_vehicle", TJSONString.Create( player_vehicle ))
		Return this_json
	End Method
	
End Type

Function Create_CAMPAIGN_DATA_from_json:CAMPAIGN_DATA( json:TJSON ) 
	Local data:CAMPAIGN_DATA = New CAMPAIGN_DATA
	data.name = json.GetString( "name" ) 
	data.levels = Create_String_array_from_TJSONArray( json.GetArray( "levels" ))
	data.player_vehicle = json.GetString( "player_vehicle" )
	Return data
End Function

