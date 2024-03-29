Rem
	vehicle_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "complex_agent.bmx"
'Import "turret.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Function Create_VEHICLE_DATA:VEHICLE_DATA( ..
chassis_key$ = Null, ..
is_unit% = False, ..
turret_keys$[][] = Null )
	Local vd:VEHICLE_DATA = New VEHICLE_DATA
	vd.chassis_key = chassis_key
	vd.is_unit = is_unit
	vd.turret_keys = turret_keys
	Return vd
End Function

Type VEHICLE_DATA
	Field chassis_key$
	Field is_unit%
	Field turret_keys$[][]
	
	Method clone:VEHICLE_DATA()
		Local vd:VEHICLE_DATA = New VEHICLE_DATA
		vd.chassis_key = chassis_key
		vd.is_unit = is_unit
		vd.turret_keys = New String[][turret_keys.Length]
		For Local i% = 0 Until turret_keys.Length
			vd.turret_keys[i] = turret_keys[i][..]
		Next
		Return vd
	End Method
	
	Method set_chassis( new_chassis_key$, new_is_unit% = False )
		chassis_key = new_chassis_key
		is_unit = new_is_unit
		Local cmp_ag:COMPLEX_AGENT
		If Not is_unit
			cmp_ag = get_player_vehicle( chassis_key )
		Else
			cmp_ag = get_unit( chassis_key )
		End If
		If cmp_ag Then turret_keys = New String[][cmp_ag.turret_anchors.Length]
	End Method
	
	Method add_turret$( key$, anchor% ) 'returns error message if unsuccessful
		'stock unit
		If is_unit Then Return "This vehicle is standard-issue, and not customizable."
		'invalid anchor
		If anchor >= turret_keys.Length Then Return "FATAL ERROR: anchor "+anchor+" is not defined on this vehicle."
		'normal
		Local t:TURRET = get_turret( key )
		If Not t Then Return "FATAL ERROR: turret."+key+" not found."
		'compatibile?
		If Not chassis_compatible_with_turret( key )
			Return "This turret won't fit onto that chassis."
		End If
		If Not turret_keys[anchor]
			turret_keys[anchor] = [ key ]
		Else 'turret_key[anchor] <> Null
			Select t.priority
				Case TURRET.PRIMARY
					If turrets_of_priority_attached_to_anchor( TURRET.PRIMARY, anchor ) > 0
						Return "That socket already has a large turret."
					End If
					turret_keys[anchor] = [ key, turret_keys[anchor][0] ]
				Case TURRET.SECONDARY
					If turrets_of_priority_attached_to_anchor( TURRET.SECONDARY, anchor ) > 0
						Return "That socket already has a small turret."
					End If
					turret_keys[anchor] = [ turret_keys[anchor][0], key ]
			End Select
		End If
		Return "success"
	End Method
	
	Method get_turrets$[]( anchor% )
		If turret_keys And anchor < turret_keys.Length
			Return turret_keys[anchor][..]
		End If
	End Method
	
	Method replace_turrets$( keys$[], anchor% )
		If Not keys Then Return Null
		'stock unit
		If is_unit Then Return "This vehicle is standard-issue, and not customizable."
		'if any of the turrets are incompatible, abort with error
		For Local key$ = EachIn keys
			If key And key.Length > 0 And Not chassis_compatible_with_turret( key )
				Return "One of the turrets won't fit onto that chassis."
			End If
		Next
		'all good, replace it
		If turret_keys
			If anchor < turret_keys.Length
				turret_keys[anchor] = keys[..]
			End If
		End If
		Return "success"
	End Method
	
	Method remove_turrets$( anchor% )
		If is_unit Then Return "This vehicle is standard-issue, and not customizable."
		If turret_keys
			If anchor < turret_keys.Length
				turret_keys[anchor] = Null
			End If
		End If
		Return "success"
	End Method
	
	Method count_all_turrets%()
		Local count% = 0
		If turret_keys
			For Local a% = 0 Until turret_keys.Length
				count :+ count_turrets( a )
			Next
		End If
		Return count
	End Method
	
	Method count_turrets%( anchor% )
		If turret_keys
			If turret_keys[anchor]
				Local count% = 0
				For Local key$ = EachIn turret_keys[anchor]
					If get_turret( key, False ) Then count :+ 1
				Next
				Return count
			Else
				Return 0
			End If
		End If
		Return -1
	End Method
	
	Method chassis_compatible_with_turret%( key$ ) 'checks the compatibility array for the existence of the given turret key
		Return True
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

