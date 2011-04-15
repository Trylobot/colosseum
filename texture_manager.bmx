Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import brl.max2d
'Import brl.map
'Import "box.bmx"
'Import "json.bmx"
'Import "base_data.bmx"
'Import "image_atlas_reference.bmx"

'______________________________________________________________________________
Function get_atlas_ref:IMAGE_ATLAS_REFERENCE( key$ )
	Return TEXTURE_MANAGER.GetImageRef( key )
End Function


Type TEXTURE_MANAGER
	Global image_atlases:TImage[]
	Global reference_map:TMap 'map[source_path:String] --> ref:IMAGE_ATLAS_REFERENCE
	Global image_key_map:TMap 'map[image_name:String] --> source_path:String
  
	Function GetImageRef:IMAGE_ATLAS_REFERENCE( image_key$ )
		If image_key
			Local src_path$ = String( image_key_map.ValueForKey( image_key ))
			If src_path
				Return IMAGE_ATLAS_REFERENCE( reference_map.ValueForKey( src_path ))
			End If
		End If
		Return Null
	End Function
	
	Function init( size% )
		image_atlases = New TImage[size]
		reference_map = CreateMap()
		image_key_map = CreateMap()
	End Function
	
	Function load_texture_from_json( json:TJSON )
		Local atlases_json:TJSONArray
		Local atlas_json:TJSON
		Local atlas_image_frames:TJSONArray
		Local atlas_image_frame:TJSON
		
		Local atlas_path$
		Local flags%
		Local atlas:TImage
		Local source_path$
		Local rect:BOX
		Local ref:IMAGE_ATLAS_REFERENCE
		
		atlases_json = json.GetArray("")
		If atlases_json
			For Local a% = 0 Until atlases_json.Size()
				atlas_json = TJSON.Create( atlases_json.GetByIndex( a ))
				atlas_path = atlas_json.GetString( "atlas_path" ).Trim()
				flags = 0
				If atlas_json.GetBoolean( "filtered" ) Then flags :| FILTEREDIMAGE
				If atlas_json.GetBoolean( "mipmapped" ) Then flags :| MIPMAPPEDIMAGE
				atlas = LoadImage( atlas_path, flags )
				If Not atlas
					DebugLog( "Error: atlas not found ~q" + atlas_path + "~q" )
					DebugStop
				End If
				image_atlases[a] = atlas
				
				atlas_image_frames = atlas_json.GetArray( "frames" )
				For Local f% = 0 Until atlas_image_frames.Size()
					atlas_image_frame = TJSON.Create( atlas_image_frames.GetByIndex( f ))
					rect = New BOX
					rect.x = atlas_image_frame.GetNumber( "x" )
					rect.y = atlas_image_frame.GetNumber( "y" )
					rect.w = atlas_image_frame.GetNumber( "w" )
					rect.h = atlas_image_frame.GetNumber( "h" )
					ref = New IMAGE_ATLAS_REFERENCE
					'///////////////////////////////////
					ref = CreateImageRef( atlas, rect )
					'///////////////////////////////////
					source_path = atlas_image_frame.GetString( "source_path" ).Trim()
					reference_map.Insert( source_path, ref )
				Next
			Next
		End If
	End Function
	
	Function load_image_data( json:TJSON, image_key$ )
		Local path$, handle_x#, handle_y#, frames%, frame_width#, frame_height#, flip_x%, flip_y%
		Local ref:IMAGE_ATLAS_REFERENCE
		path = json.GetString( "path" ).Trim()
		image_key_map.Insert( image_key, path )
		ref = GetImageRef( image_key )
		If ref
			frames = json.GetNumber( "frames" )
			flip_x = json.GetBoolean( "flip_horizontal" )
			flip_y = json.GetBoolean( "flip_vertical" )
			handle_x = json.GetNumber( "handle_x" )
			handle_y = json.GetNumber( "handle_y" )
			'////////////////////////////////////////////////////////////
			ref.LoadImageModifiers( handle_x, handle_y, flip_x, flip_y )
			'////////////////////////////////////////////////////////////
			If frames > 1
				frame_width = json.GetNumber( "frame_width" )
				frame_height = json.GetNumber( "frame_height" )
				'////////////////////////////////////////////////////////////////
				ref.LoadMultiCellAnimation( frames, frame_width, frame_height )
				'////////////////////////////////////////////////////////////////
			End If
		Else
			DebugLog( "  ImageAtlasReference "+image_key+" not found. Did you forget to run compose_texture_atlases.bat?" )
			DebugStop
		End If
	End Function
	
End Type

