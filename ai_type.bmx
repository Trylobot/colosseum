Rem
	ai_type.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_AI_TYPE:AI_TYPE( ..
has_turrets%, ..
can_move%, ..
can_self_destruct%, ..
is_carrier% )
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

