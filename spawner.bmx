Rem
	spawner.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type SPAWNER
	Global class_GATED_FACTORY% = 1
	Global class_TURRET_ANCHOR% = 2
	
	Field class% '{gated_factory|turret_anchor} <-- this should be gone, doors should be separate entirely
	Field squads$[][] 'grouped references to COMPLEX_AGENT prototypes; to be "baked" at spawn-time; turret anchors ignore all entries beyond the first.
	Field size% 'cached result of count_all_squadmembers()
	Field pos:POINT 'initial state to be conferred on each spawned agent; velocity and acceleration ignored for turret anchors
	Field delay_time%[] 'time delay between squad queueing; ignored for turret anchors
	Field alignment% '{friendly|hostile}
	
	Method New()
		pos = New POINT
	End Method
	
	Method clone:SPAWNER()
		Local sp:SPAWNER = New SPAWNER
		sp.class = class
		sp.squads = New String[][squads.Length]
		For Local index% = 0 To squads.Length - 1
			sp.squads[index] = squads[index][..]
		Next
		sp.pos = Copy_POINT( pos )
		sp.delay_time = delay_time[..]
		sp.alignment = alignment
		Return sp
	End Method
	
	Method add_new_squad%()
		squads = squads[..squads.Length+1]
		squads[squads.Length-1] = Null
		delay_time = delay_time[..delay_time.Length+1]
		delay_time[delay_time.Length-1] = 0
		Return (squads.Length - 1) 'return index of new squad
	End Method
	
	Method remove_squad( squad$[] )
		For Local index% = 0 To squads.Length-1
			Local sq$[] = squads[index]
			If sq = squad
				squads[index] = squads[squads.Length-1]
				squads = squads[..squads.Length-1]
				delay_time[index] = delay_time[delay_time.Length-1]
				delay_time = delay_time[..delay_time.Length-1]
				Exit
			End If
		Next
	End Method
	
	Method add_new_squadmember( squad_index%, archetype$ )
		squads[squad_index] = squads[squad_index][..squads[squad_index].Length+1]
		squads[squad_index][squads[squad_index].Length-1] = archetype
		size = count_all_squadmembers()
	End Method
	
	Method remove_last_squadmember( squad_index% )
		If squad_index >= 0 And squad_index < squads.Length And squads[squad_index].Length > 0
			squads[squad_index] = squads[squad_index][..squads[squad_index].Length-1]
		End If
		If squads[squad_index].Length = 0
			remove_squad( squads[squad_index] )
		End If
	End Method
	
	Method set_delay_time( index%, time% )
		If index >= 0 And index < delay_time.Length
			delay_time[index] = time
		End If
	End Method
	
	Method count_squads%()
		If squads = Null ..
		Then Return 0 ..
		Else Return squads.Length
	End Method
	
	Method count_squadmembers%( squad_index% )
		If (squad_index < 0 Or squad_index >= squads.Length) ..
		Or squads[squad_index] = Null ..
		Then Return 0 ..
		Else Return squads[squad_index].Length
	End Method
	
	Method count_all_squadmembers%()
		Local count% = 0
		For Local index% = 0 To count_squads%()-1
			count :+ count_squadmembers( index )
		Next
		Return count
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "class", TJSONNumber.Create( class ))
		this_json.SetByName( "squads", Create_TJSONArray_from_String_array_array( squads ))
		this_json.SetByName( "pos", pos.to_json() )
		this_json.SetByName( "delay_time", Create_TJSONArray_from_Int_array( delay_time ))
		this_json.SetByName( "alignment", TJSONNumber.Create( alignment ))
		Return this_json
	End Method
End Type

Function Create_SPAWNER_from_json:SPAWNER( json:TJSON )
	Local sp:SPAWNER = New SPAWNER
	sp.class = json.GetNumber( "class" )
	'new system
	'sp.squads = Create_String_array_array_from_TJSONArray( json.GetArray( "squads" ))
	'old system -- begin
	Local squads_DEPRECATED%[][] = Create_Int_array_array_from_TJSONArray( json.GetArray( "squads" ))
	sp.squads = New String[][squads_DEPRECATED.Length]
	For Local i% = 0 Until sp.squads.Length
		sp.squads[i] = New String[squads_DEPRECATED[i].Length]
		For Local m% = 0 Until sp.squads[i].Length
			sp.squads[i][m] = get_keys( unit_map )[squads_DEPRECATED[i][m]]
		Next
	Next
	'old system -- end
	sp.size = sp.count_all_squadmembers()
	sp.pos = Create_POINT_from_json( TJSON.Create( json.GetObject( "pos" )))
	sp.delay_time = json.GetArrayInt( "delay_time" )
	sp.alignment = json.GetNumber( "alignment" )
	Return sp
End Function

