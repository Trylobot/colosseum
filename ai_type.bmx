Rem
	ai_type.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_AI_TYPE:AI_TYPE( ..
has_turrets% = False, ..
can_move% = False, ..
can_self_destruct% = False, ..
is_carrier% = False )
	Local a:AI_TYPE = New AI_TYPE
	a.has_turrets = has_turrets
	a.can_move = can_move
	a.can_self_destruct = can_self_destruct
	a.is_carrier = is_carrier
	Return a
End Function

Function Copy_AI_TYPE:AI_TYPE( other:AI_TYPE )
	Return Create_AI_TYPE( ..
		other.has_turrets, ..
		other.can_move, ..
		other.can_self_destruct, ..
		other.is_carrier )
End Function

Type AI_TYPE
	Field has_turrets%
	Field can_move%
	Field can_self_destruct%
	Field is_carrier%
End Type

Function Create_AI_TYPE_from_json:AI_TYPE( json:TJSON )
	Local ai:AI_TYPE
	'no required fields
	ai = Create_AI_TYPE()
	'optional fields
	If json.TypeOf( "has_turrets" ) <> JSON_UNDEFINED       Then ai.has_turrets = json.GetBoolean( "has_turrets" )
	If json.TypeOf( "can_move" ) <> JSON_UNDEFINED          Then ai.can_move = json.GetBoolean( "can_move" )
	If json.TypeOf( "can_self_destruct" ) <> JSON_UNDEFINED Then ai.can_self_destruct = json.GetBoolean( "can_self_destruct" )
	If json.TypeOf( "is_carrier" ) <> JSON_UNDEFINED        Then ai.is_carrier = json.GetBoolean( "is_carrier" )
	Return ai
End Function


