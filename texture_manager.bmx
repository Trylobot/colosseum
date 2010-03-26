Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import brl.map
Import "image_atlas.bmx"
Import "json.bmx"

'______________________________________________________________________________
Type IMAGE_ATLAS_REFERENCE
  Field atlas:TImageAtlas
  Field frame%
	
	Function Create:IMAGE_ATLAS_REFERENCE( atlas:TImageAtlas, frame% )
		Local atlas_ref:IMAGE_ATLAS_REFERENCE = New IMAGE_ATLAS_REFERENCE
		atlas_ref.atlas = atlas
		atlas_ref.frame = frame
		Return atlas_ref
	End Function
End Type

'______________________________________________________________________________
Type TEXTURE_MANAGER
	Global image_atlases:TImageAtlas[]
	Global reference_map:TMap
  
  Function Draw( ref:IMAGE_ATLAS_REFERENCE, x#, y# )
    ref.atlas.SetDimensionsFromFrame( ref.frame )
    DrawImage( ref.atlas, x, y, ref.frame )
  End Function
  
  Function GetImageRef:IMAGE_ATLAS_REFERENCE( image_source_path$ )
		Return IMAGE_ATLAS_REFERENCE( reference_map.ValueForKey( image_source_path ))
  End Function
	
	Function Load_TEXTURE_MANAGER_from_json( json:TJSON )
		Local atlases_json:TJSONArray
		Local atlas_json:TJSON
		Local atlas_image_frames:TJSONArray
		Local atlas_image_frame:TJSON
		Local atlas_path$
		Local source_path$[]
		Local rects:BOX[]
		Local handles:cVEC[]
		
		atlases_json = json.GetArray("")
		If atlases_json
			image_atlases = New TImageAtlas[atlases_json.Size()]
			reference_map = CreateMap()
			
			For Local a% = 0 Until atlases_json.Size()
				atlas_json = TJSON.Create( atlases_json.GetByIndex( a ))
				atlas_path = atlas_json.GetString( "atlas_path" )
				atlas_image_frames = atlas_json.GetArray( "frames" )
				
				source_path = New String[atlas_image_frames.Size()]
				rects = New BOX[atlas_image_frames.Size()]
				handles = New cVEC[atlas_image_frames.Size()]
				For Local f% = 0 Until atlas_image_frames.Size()
					atlas_image_frame = TJSON.Create( atlas_image_frames.GetByIndex( f ))
					source_path[f] = atlas_image_frame.GetString( "source_path" )
					rects[f] = New BOX
					rects[f].x = atlas_image_frame.GetNumber( "x" )
					rects[f].y = atlas_image_frame.GetNumber( "y" )
					rects[f].w = atlas_image_frame.GetNumber( "w" )
					rects[f].h = atlas_image_frame.GetNumber( "h" )
				Next
				
				image_atlases[a] = LoadImageAtlas( atlas_path, rects, handles )
				For Local f% = 0 Until source_path.Length
					reference_map.Insert( source_path[f], IMAGE_ATLAS_REFERENCE.Create( image_atlases[a], f ))
				Next
			Next
		End If
	End Function
  
End Type

'______________________________________________________________________________
Function DrawImageRef( ref:IMAGE_ATLAS_REFERENCE, x#, y# )
  TEXTURE_MANAGER.Draw( ref, x, y )
End Function

