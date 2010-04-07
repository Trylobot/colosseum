Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import brl.max2d
'Import brl.map
'Import "vec.bmx"
'Import "box.bmx"
'Import "json.bmx"

'______________________________________________________________________________
Function DrawImageRef( ref:IMAGE_ATLAS_REFERENCE, x#, y#, f% = 0 )
	If ref Then ref.Draw( x, y, f )
End Function

'______________________________________________________________________________
Type IMAGE_ATLAS_REFERENCE
	'image data pointer
	Field atlas:TImage
	Field iframe:TImageFrame
	'texture atlas composition data
	Field src_rect:BOX
	Field width%
	Field height%
	'legacy image data
	Field handle_x#
	Field handle_y#
	Field flip_x%
	Field flip_y%
	'sprite animation data (multi-cell)
	Field frames%
	Field rect:BOX[]
	
  'static memory
	Global x0#,x1#, y0#,y1#, tx#,ty#, sx#,sy#, sw#,sh#
	
	Method Draw( x#, y#, f% = 0 )
		x0 = -handle_x
    y0 = -handle_y
		x1 = x0 + width
    y1 = y0 + height
		GetOrigin( tx, ty )
    tx :+ x
    ty :+ y
		sx = rect[f].x
    sy = rect[f].y
    sw = width
    sh = height
		'///////////////////////////////////////////////
		iframe.Draw( x0,y0, x1,y1, tx,ty, sx,sy,sw,sh )
		'///////////////////////////////////////////////
	End Method

	Function Create:IMAGE_ATLAS_REFERENCE( atlas:TImage, rect:BOX )
		Local ref:IMAGE_ATLAS_REFERENCE = New IMAGE_ATLAS_REFERENCE
		ref.atlas = atlas
		ref.iframe = atlas.Frame( 0 )
		ref.src_rect = rect
		ref.width = rect.w
		ref.height = rect.h
		ref.frames = 1
		ref.rect = [ref.src_rect]
		Return ref
	End Function
	
	Method LoadImageModifiers( handle_x#, handle_y#, flip_x% = False, flip_y% = False )
		Self.handle_x = handle_x
		Self.handle_y = handle_y
		Self.flip_x = flip_x
		Self.flip_y = flip_y
	End Method
	
	Method LoadMultiFrameAnimation( frames%, frame_width%, frame_height% )
		Self.frames = frames
		rect = New BOX[frames]
		Local cols% = width / frame_width
		Local rows% = height / frame_height
		Local f% = 0
		For Local r% = 0 Until rows
			For Local c% = 0 Until cols
				'texture coordinates for this cell of animation
				rect[f] = Create_BOX( ..
					src_rect.x + (c*frame_width), ..
					src_rect.y + (r*frame_height), ..
					frame_width, ..
					frame_height )
				f :+ 1
				If f >= frames
					Return
				End If
			Next
		Next
    width = frame_width
    height = frame_height
	End Method
	
End Type

'______________________________________________________________________________
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
	
	Function Load_TEXTURE_MANAGER_from_json( json:TJSON )
		Local atlases_json:TJSONArray
		Local atlas_json:TJSON
		Local atlas_image_frames:TJSONArray
		Local atlas_image_frame:TJSON
		
		Local atlas_path$
		Local atlas:TImage
		Local source_path$
		Local rect:BOX
		Local ref:IMAGE_ATLAS_REFERENCE
		
		atlases_json = json.GetArray("")
		If atlases_json
			image_atlases = New TImage[atlases_json.Size()]
			reference_map = CreateMap()
			image_key_map = CreateMap()
			For Local a% = 0 Until atlases_json.Size()
				atlas_json = TJSON.Create( atlases_json.GetByIndex( a ))
				atlas_path = atlas_json.GetString( "atlas_path" ).Trim()
				
				atlas = LoadImage( atlas_path )
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
					'/////////////////////////////////////////////////
					ref = IMAGE_ATLAS_REFERENCE.Create( atlas, rect )
					'/////////////////////////////////////////////////
					source_path = atlas_image_frame.GetString( "source_path" ).Trim()
					reference_map.Insert( source_path, ref )
				Next
			Next
		End If
	End Function
	
	Function Load_TImage_json( json:TJSON, image_key$ )
		Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%, flip_horizontal%, flip_vertical%
		Local handle:cVEC
		Local ref:IMAGE_ATLAS_REFERENCE
		
		path = json.GetString( "path" ).Trim()
		image_key_map.Insert( image_key, path )
		ref = GetImageRef( image_key )
		frames = json.GetNumber( "frames" )
		flip_horizontal = json.GetBoolean( "flip_horizontal" )
		flip_vertical = json.GetBoolean( "flip_vertical" )
		handle_x = json.GetNumber( "handle_x" )
		handle_y = json.GetNumber( "handle_y" )
		'////////////////////////////////////////////////////////////////////////////
		ref.LoadImageModifiers( handle_x, handle_y, flip_horizontal, flip_vertical )
		'////////////////////////////////////////////////////////////////////////////
		If frames > 1
			frame_width = json.GetNumber( "frame_width" )
			frame_height = json.GetNumber( "frame_height" )
			'////////////////////////////////////////////////////////////////
			ref.LoadMultiFrameAnimation( frames, frame_width, frame_height )
			'////////////////////////////////////////////////////////////////
		End If
	End Function
	
End Type

