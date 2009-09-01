Rem
	spawn_request.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "point.bmx"

'______________________________________________________________________________
Type SPAWN_REQUEST
	Field unit_key$ 'to feed to get_unit()
	Field alignment% 'political alignment
	Field spawn_point:POINT 'spawn location in-game
	
	Function Create:SPAWN_REQUEST( unit_key$, alignment%, spawn_point:POINT )
		Local sr:SPAWN_REQUEST = new SPAWN_REQUEST
		sr.unit_key = unit_key
		sr.alignment = alignment
		sr.spawn_point = spawn_point
		Return sr
	End Function
End Type

