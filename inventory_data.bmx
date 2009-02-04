Rem
	inventory_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_INVENTORY_DATA:INVENTORY_DATA( item_type$, key$, count% = 1 )
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = item_type
	item.key = key
	item.count = count
	Return item
End Function

Type INVENTORY_DATA
	Field item_type$
	Field key$
	Field count%
	
	Method clone:INVENTORY_DATA()
		Return Create_INVENTORY_DATA( item_type, key, count )
	End Method
	
	Method eq%( other:INVENTORY_DATA )
		If Not other Then Return False
		Return item_type = other.item_type And key = other.key
	End Method
	
	Method to_string$()
		Return item_type+"."+key
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "item_type", TJSONString.Create( item_type ))
		this_json.SetByName( "key", TJSONString.Create( key ))
		this_json.SetByName( "count", TJSONNumber.Create( count ))
		Return this_json
	End Method
	
End Type

Function Create_INVENTORY_DATA_from_json:INVENTORY_DATA( json:TJSON ) 
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = json.GetString( "item_type" ) 
	item.key = json.GetString( "key" )
	item.count = json.GetNumber( "count" )
	Return item
End Function
