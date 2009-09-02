Rem
	prop_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "agent.bmx"
Import "point.bmx"
Import "json.bmx"

'______________________________________________________________________________
Global prop_map:TMap = CreateMap()

Function get_prop:AGENT( Key$, Copy% = True )
	Local ag:AGENT = AGENT( prop_map.ValueForKey( Key.toLower() ))
	If Copy And ag Then Return Copy_AGENT( ag )
	Return ag
End Function

Type PROP_DATA
	Field archetype$
	Field pos:POINT
	
	Method New()
		pos = New POINT
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "archetype", TJSONString.Create( archetype ))
		this_json.SetByName( "pos", pos.to_json() )
		Return this_json
	End Method
End Type

Function Create_PROP_DATA_from_json:PROP_DATA( json:TJSON )
	Local pd:PROP_DATA = New PROP_DATA
	pd.archetype = json.GetString( "archetype" )
	pd.pos = Create_POINT_from_json( TJSON.Create( json.GetObject( "pos" )))
	Return pd
End Function

