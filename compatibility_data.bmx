Rem
	compatibility_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "json.bmx"

'______________________________________________________________________________
Global compatibility_map:TMap = CreateMap()

Function get_compatibility:COMPATIBILITY_DATA( key$ ) 'returns read-only reference (recursive inheritance expansion)
	Local cd:COMPATIBILITY_DATA = COMPATIBILITY_DATA( compatibility_map.ValueForKey( key.toLower() ))
	If cd
		cd = cd.clone()
		If cd.inherits_from Then cd.inherit( get_compatibility( cd.inherits_from ))
	End If
	Return cd
End Function

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
	
	Method is_compatible_with%( query_key$ )
		For Local turret_key$ = EachIn turret_keys
			If turret_key = query_key Then Return True
		Next
		Return False
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

