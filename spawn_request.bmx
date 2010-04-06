Rem
	spawn_request.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "point.bmx"

'______________________________________________________________________________
Function Create_SPAWN_REQUEST:SPAWN_REQUEST( unit_key$, alignment%, spawn_point:POINT, source_spawner_index% = -1 )
	Local sr:SPAWN_REQUEST = New SPAWN_REQUEST
	sr.unit_key = unit_key
	sr.alignment = alignment
	sr.spawn_point = spawn_point
	sr.source_spawner_index = source_spawner_index
	Return sr
End Function

Type SPAWN_REQUEST
	Field unit_key$ 'to feed to get_unit()
	Field alignment% 'political alignment
	Field spawn_point:POINT 'spawn location in-game
	Field source_spawner_index% '(optional) call-back for the spawn_controller's last_spawned array
End Type

