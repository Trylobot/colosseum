'______________________________________________________________________________
Type PROP_DATA
	Field archetype%
	Field pos:POINT
	
	Method New()
		pos = New POINT
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "archetype", TJSONNumber.Create( archetype ))
		this_json.SetByName( "pos", pos.to_json() )
		Return this_json
	End Method
End Type

Function Create_PROP_DATA_from_json:PROP_DATA( json:TJSON )
	Local pd:PROP_DATA = New PROP_DATA
	pd.archetype = json.GetNumber( "archetype" )
	pd.pos = Create_POINT_from_json( TJSON.Create( json.GetObject( "pos" )))
	Return pd
End Function

