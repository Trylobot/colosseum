Rem
	progress_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "json.bmx"

'______________________________________________________________________________
Type PROGRESS_DATA
	Field campaign_key$
	Field completed%[]
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "campaign_key", TJSONString.Create( campaign_key ))
		this_json.SetByName( "completed", Create_TJSONArray_from_Int_array( completed, True ))
		Return this_json
	End Method
End Type

Function Create_PROGRESS_DATA_from_json:PROGRESS_DATA( json:TJSON )
	Local pd:PROGRESS_DATA = New PROGRESS_DATA
	pd.campaign_key = json.GetString( "campaign" )
	pd.completed = Create_Int_array_from_TJSONArray( json.GetArray( "completed" ), True )
	Return pd
End Function

