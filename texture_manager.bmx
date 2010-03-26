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
Function DrawImageRef( img:IMAGE_ATLAS_REFERENCE, x#, y#, anim_frame% = 0 )
	img.atlas.Draw( x, y, img.atlas_entry_index, anim_frame% )
End Function

Type IMAGE_ATLAS_REFERENCE
  Field atlas:TImageAtlas
	Field atlas_entry_index%
  Field frames%
	Field width%
	Field height%
	Field handle_x%
	Field handle_y%
	
	Function Create:IMAGE_ATLAS_REFERENCE( atlas:TImageAtlas, atlas_entry_index% )
		Local ref:IMAGE_ATLAS_REFERENCE = New IMAGE_ATLAS_REFERENCE
		ref.atlas = atlas
		ref.atlas_entry_index = atlas_entry_index
		ref.frames = 1
		ref.width = atlas.rects[atlas_entry_index].w
		ref.height = atlas.rects[atlas_entry_index].h
		Return ref
	End Function
	
	Method Draw( x#, y#, anim_frame% = 0 )
		atlas.Draw( x, y, atlas_entry_index, anim_frame% )
	End Method
	
	Method UseFrame()
		atlas.UseFrame( atlas_entry_index )
	End Method
	
End Type

'______________________________________________________________________________
Type TEXTURE_MANAGER
	Global image_atlases:TImageAtlas[]
	Global reference_map:TMap
  
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
				'/////////////////////////////////////////////////////////////////
				image_atlases[a] = TImageAtlas.Load( atlas_path, rects, handles )
				'/////////////////////////////////////////////////////////////////
				For Local f% = 0 Until source_path.Length
					reference_map.Insert( source_path[f], IMAGE_ATLAS_REFERENCE.Create( image_atlases[a], f ))
				Next
			Next
		End If
	End Function
	
	Function Load_TImage_json( json:TJSON )
		Local ref:IMAGE_ATLAS_REFERENCE
		Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%, flip_horizontal%, flip_vertical%
		path = json.GetString( "path" )
		ref = TEXTURE_MANAGER.GetImageRef( path )
		frames = json.GetNumber( "frames" )
		'flip_horizontal = json.GetBoolean( "flip_horizontal" )
		'flip_vertical = json.GetBoolean( "flip_vertical" )
		'img = pixel_transform( img, flip_horizontal, flip_vertical ) 'does nothing if both are false
		handle_x = json.GetNumber( "handle_x" )
		handle_y = json.GetNumber( "handle_y" )
		If frames = 1
			ref.handle_x = handle_x
			ref.handle_y = handle_y
			ref.atlas.handles[ref.atlas_entry_index].x = handle_x
			ref.atlas.handles[ref.atlas_entry_index].y = handle_y
		Else If frames > 1
			
		End If
		'If frames >= 1
			'If frames = 1
				'img = LoadImage( path )
				
			'Else 'frames > 1
				'frame_width = json.GetNumber( "frame_width" )
				'frame_height = json.GetNumber( "frame_height" )
				'img = LoadAnimImage( path, frame_width, frame_height, 0, frames )
			'End If
			'If img
				'flip_horizontal = json.GetBoolean( "flip_horizontal" )
				'flip_vertical = json.GetBoolean( "flip_vertical" )
				'img = pixel_transform( img, flip_horizontal, flip_vertical ) 'does nothing if both are false
				'handle_x = json.GetNumber( "handle_x" )
				'handle_y = json.GetNumber( "handle_y" )
				'SetImageHandle( img, handle_x, handle_y )
				'Return img
			'End If
		'End If
		'Return Null
	End Function
  
End Type

