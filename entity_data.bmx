Rem
	entity_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "point.bmx"
Import "json.bmx"

'______________________________________________________________________________
Function Create_ENTITY_DATA:ENTITY_DATA( ..
archetype$, ..
pos:POINT, ..
alignment% = 0, ..
entity_type% = 0 )
	Local d:ENTITY_DATA = New ENTITY_DATA
	d.archetype = archetype
	d.pos = pos
	d.alignment = alignment
	d.entity_type = entity_type
	Return d
End Function

Type ENTITY_DATA
	Field archetype$
	Field pos:POINT
	Field alignment% '(optional) defaults to NONE
	
	Field entity_type% 'run-time field
		Const PROP% = 1
		Const UNIT% = 2
	
	Method New()
		pos = New POINT
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "archetype", TJSONString.Create( archetype ))
		this_json.SetByName( "pos", pos.to_json() )
		If alignment <> 0 'Not "NONE"
			this_json.SetByName( "alignment", TJSONNumber.Create( alignment ))
		End If
		Return this_json
	End Method
End Type

Function Create_ENTITY_DATA_from_json:ENTITY_DATA( json:TJSON )
	Local d:ENTITY_DATA
	'required fields
	Local archetype$, pos:POINT
	archetype = json.GetString( "archetype" )
	pos = Create_POINT_from_json( TJSON.Create( json.GetObject( "pos" )))
	'initialization with default values for optional fields
	d = Create_ENTITY_DATA( archetype, pos )
	'optional fields
	If json.TypeOf( "alignment" ) <> JSON_UNDEFINED Then d.alignment = json.GetNumber( "alignment" )
	Return d
End Function

