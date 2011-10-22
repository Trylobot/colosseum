
SuperStrict
Import TWRC.rJSON

'//////////////////////////////////////////////////////////////////////////////
'data base class
Type serializable Abstract
	Global type_id:TTypeId
	Function decode:Object( json_str$ )
		Local settings:TJSONDecodeSettings = New TJSONDecodeSettings
		settings.OverrideFieldName( type_id, "object", "object_" )
		Return JSON.Decode( json_str, settings, type_id.ArrayType() )
	EndFunction
	Function encode$( obj:Object )
		Local settings:TJSONEncodeSettings = New TJSONEncodeSettings
		settings.OverrideFieldName( type_id, "object_", "object" )
		settings.default_precision = 8
		Return JSON.Encode( obj, settings, type_id.ArrayType() )
	EndFunction
EndType

'//////////////////////////////////////////////////////////////////////////////
'gibs
gibset_meta.type_id = TTypeId.ForName("gibset_meta")
Type gibset_meta Extends serializable
	Field class$
	Field key$
	Field object_:gibset_data
EndType
Type gibset_data
	Field gibs:gib_data[]
EndType
Type gib_data
	Field image_path$
	Field offset_x!
	Field offset_y!
	Field speed!
EndType


'//////////////////////////////////////////////////////////////////////////////
