Rem
	inventory_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Function Create_INVENTORY_DATA:INVENTORY_DATA( ..
item_type$, ..
key$, ..
count% = 1, ..
damaged% = False )
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = item_type
	item.key = key
	item.count = count
	item.damaged = damaged
	Return item
End Function

Type INVENTORY_DATA
	Field item_type$
	Field key$
	Field count%
	Field damaged%
	
	Method clone:INVENTORY_DATA()
		Return Create_INVENTORY_DATA( ..
			item_type, ..
			key, ..
			count, ..
			damaged )
	End Method
	
	Method eq%( other:INVENTORY_DATA )
		If Not other Then Return False
		Return ..
			item_type = other.item_type And ..
			key = other.key And ..
			damaged = other.damaged
	End Method
	
	Method compare%( with_object:Object ) ' return true if Self is "greater than" other
		Local other:INVENTORY_DATA = INVENTORY_DATA(with_object)
		If other
			If item_type <> other.item_type 'chassis items are always the greatest
				If item_type = "chassis" Then Return 65535 ..
				Else If other.item_type = "chassis" Then Return -65535
			Else 'item types are the same
				'compare the costs
				'Return get_inventory_object_cost( item_type, key ) - get_inventory_object_cost( other.item_type, other.key )
				Return get_inventory_object_cost( other.item_type, other.key ) - get_inventory_object_cost( item_type, key )
			End If
		End If
		Return False
	EndMethod

	Method to_string$()
		Return item_type+"."+key
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "item_type", TJSONString.Create( item_type ))
		this_json.SetByName( "key", TJSONString.Create( key ))
		this_json.SetByName( "count", TJSONNumber.Create( count ))
		this_json.SetByName( "damaged", TJSONBoolean.Create( damaged ))
		Return this_json
	End Method
	
End Type

Function Create_INVENTORY_DATA_from_json:INVENTORY_DATA( json:TJSON ) 
	Local item:INVENTORY_DATA = New INVENTORY_DATA
	item.item_type = json.GetString( "item_type" ) 
	item.key = json.GetString( "key" )
	item.count = json.GetNumber( "count" )
	item.damaged = json.GetBoolean( "damaged" )
	Return item
End Function

