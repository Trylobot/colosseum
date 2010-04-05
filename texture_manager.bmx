Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import brl.map
Import "vec.bmx"
Import "box.bmx"
Import "json.bmx"

'______________________________________________________________________________
Function DrawImageRef( ref:IMAGE_ATLAS_REFERENCE, x#, y#, anim_frame% = 0 )
	ref.Draw( x, y, anim_frame% )
End Function

'______________________________________________________________________________
Type IMAGE_ATLAS_REFERENCE
	'image data pointer
	Field atlas:TImage
	Field DXFrame:TD3D7ImageFrame
	'Field GLFrame:TGLImageFrame
	'source image data
	Field rect:BOX
	Field uv:BOX
	'additional image data
	Field handle:cVEC
	Field flip_x%
	Field flip_y%
	'sprite animation data
	Field frames%
	Field anim_rect:BOX[]
	Field anim_uv:BOX[]
	
	Method LoadAtlas( atlas:TImage, rect:BOX )
		Self.atlas = atlas
		Self.DXFrame = TD3D7ImageFrame( atlas.frame( 0 ))
		'Self.GLFrame = TGLImageFrame( atlas.frame( 0 ))
		Self.rect = rect
		Self.uv = Create_BOX( ..
			rect.x / atlas.width, ..
			rect.y / atlas.height, ..
			(rect.x + rect.w) / atlas.width, ..
			(rect.y + rect.h) / atlas.height )
	End Method
	
	Method LoadLegacy( handle:cVEC, flip_x% = False, flip_y% = False )
		Self.handle = handle
		Self.flip_x = flip_x
		Self.flip_y = flip_y
	End Method
	
	Method NullAnim()
		Self.frames = 1
		Self.frame_rect = Null
		Self.frame_uv = Null
	End Method
	
	Method LoadAnim( frames%, frame_width%, frame_height% )
		Self.frames = frames
		Self.frame_rect = New BOX[frames]
		Self.frame_uv = New BOX[frames]
	End Method
	
	Method Draw( x#, y#, anim_frame% = 0 )
		PreDraw()
		ScalePush()
		DrawImageRect( atlas, x, y, rect.w, rect.h )
		ScaleRevert()
	End Method
	
	Method PreDraw()
		DXFrame.setUV( uv.x, uv.y, uv.w, uv.h )
		'GLFrame.u0 = uv.x; GLFrame.v0 = uv.w; GLFrame.u1 = uv.y; GLFrame.v1 = uv.h
		atlas.handle_x = handle.x
		atlas.handle_y = handle.y
	End Method
	
	
	Global g_sx#, g_sy#
	
	Method ScalePush()
		GetScale( g_sx, g_sy )
		SetScale( g_sx * (1 - 2*flip_x), g_sy * (1 - 2*flip_y) )
	End Method
	
	Method ScaleRevert()
		SetScale( g_sx, g_sy )
	End Method
	
End Type

'______________________________________________________________________________
Type TEXTURE_MANAGER
	Global image_atlases:TImage[]
	Global reference_map:TMap 'map[source_path:String] --> ref:IMAGE_ATLAS_REFERENCE
	Global image_key_map:TMap 'map[image_name:String] --> source_path:String
  
  Function GetImageRef:IMAGE_ATLAS_REFERENCE( image_key$ )
    If image_key
      Local image_src$ = String( image_key_map.ValueForKey( image_key ))
      If image_src
        Return IMAGE_ATLAS_REFERENCE( reference_map.ValueForKey( image_src ))
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
					ref.LoadAtlas( atlas, rect )
					source_path = atlas_image_frame.GetString( "source_path" ).Trim()
					reference_map.Insert( source_path, ref )
				Next
			Next
		End If
	End Function
	
	Function Load_TImage_json( json:TJSON, image_key$ )
		Local path$, handle_x#, handle_y#, frames%, frame_width%, frame_height%, flip_horizontal%, flip_vertical%
		Local ref:IMAGE_ATLAS_REFERENCE
		
		path = json.GetString( "path" ).Trim()
		image_key_map.Insert( image_key, path )
		ref = GetImageRef( image_key )
		frames = json.GetNumber( "frames" )
		flip_horizontal = json.GetBoolean( "flip_horizontal" )
		flip_vertical = json.GetBoolean( "flip_vertical" )
		handle_x = json.GetNumber( "handle_x" )
		handle_y = json.GetNumber( "handle_y" )
		ref.LoadLegacy( Create_cVEC( handle_x, handle_y ), flip_horizontal, flip_vertical )
		If frames = 1
			ref.NullAnim()
		Else If frames > 1
			frame_width = json.GetNumber( "frame_width" )
			frame_height = json.GetNumber( "frame_height" )
			ref.LoadAnim( frames, frame_width, frame_height )
		End If
	End Function
	
End Type

