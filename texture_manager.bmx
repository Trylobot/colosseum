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
Function DrawImageRef( ref:IMAGE_ATLAS_REFERENCE, x#, y#, f% = 0 )
	ref.Draw( x, y, f )
End Function

'______________________________________________________________________________
Type IMAGE_ATLAS_REFERENCE
	'image data pointer
	Field atlas:TImage
	Field DXFrame:TD3D7ImageFrame
	'Field GLFrame:TGLImageFrame
	'source image data
	Field src_rect:BOX
	Field src_uv:BOX
	Field width%
	Field height%
	'additional image data (separate)
	Field handle:cVEC
	Field flip_x%
	Field flip_y%
	'sprite animation data (optional)
	Field frames%
	Field rect:BOX[]
	Field uv:BOX[]
	'temps for scale push/pop
	Global g_sx#, g_sy#
	
	Method Draw( x#, y#, f% = 0 )
		PreDraw( f )
		ScalePush()
		DrawImageRect( atlas, x, y, rect[f].w, rect[f].h )
		ScalePop()
	End Method
	
	Method LoadAtlas( atlas:TImage, rect:BOX )
		Self.atlas = atlas
		Self.DXFrame = TD3D7ImageFrame( atlas.frame( 0 ))
		'Self.GLFrame = TGLImageFrame( atlas.frame( 0 ))
		Self.src_rect = rect
		Self.width = src_rect.w
		Self.height = src_rect.h
		Self.src_uv = CalculateUV( rect, atlas.width, atlas.height )
	End Method
	
	Method LoadLegacy( handle:cVEC, flip_x% = False, flip_y% = False )
		Self.handle = handle
		Self.flip_x = flip_x
		Self.flip_y = flip_y
	End Method
	
	Method NullAnim()
		frames = 1
		rect = [src_rect]
		uv = [src_uv]
	End Method
	
	Method LoadAnim( frames%, frame_width%, frame_height% )
		Self.frames = frames
		rect = New BOX[frames]
		uv = New BOX[frames]
		Local rows% = src_rect.h / frame_height
		Local cols% = src_rect.w / frame_width
		Local f% = 0
		For Local r% = 0 Until rows
			For Local c% = 0 Until cols
				'anim frame "sub-rect" within this atlas-ref's rect
				rect[f] = Create_BOX( ..
					src_rect.x + (c*frame_width), ..
					src_rect.y + (r*frame_height), ..
					frame_width, ..
					frame_height )
				uv[f] = CalculateUV( rect[f], atlas.width, atlas.height )
				'total frame count
				f :+ 1
				If f >= frames
					Return 'done loading anim
				End If
			Next
		Next
	End Method
	
	Method PreDraw( f% = 0 )
		DXFrame.setUV( uv[f].x, uv[f].y, uv[f].w, uv[f].h )
		'GLFrame.u0 = uv.x; GLFrame.v0 = uv.w; GLFrame.u1 = uv.y; GLFrame.v1 = uv.h
		atlas.handle_x = handle.x
		atlas.handle_y = handle.y
	End Method
	
	Method ScalePush()
		GetScale( g_sx, g_sy )
		SetScale( g_sx * (1 - 2*flip_x), g_sy * (1 - 2*flip_y) )
	End Method
	
	Method ScalePop()
		SetScale( g_sx, g_sy )
	End Method
	
	Function CalculateUV:BOX( r:BOX, tw#, th# )
		Return Create_BOX( ..
			r.x / tw, ..
			r.y / th, ..
			(r.x + r.w) / tw, ..
			(r.y + r.h) / th )
	End Function
	
End Type

'______________________________________________________________________________
Type TEXTURE_MANAGER
	Global image_atlases:TImage[]
	Global reference_map:TMap 'map[source_path:String] --> ref:IMAGE_ATLAS_REFERENCE
	Global image_key_map:TMap 'map[image_name:String] --> source_path:String
  
  Function GetImageRef:IMAGE_ATLAS_REFERENCE( image_key$ )
    Local image_src$ = String( image_key_map.ValueForKey( image_key ))
		If image_src
			Local ref:IMAGE_ATLAS_REFERENCE = IMAGE_ATLAS_REFERENCE( reference_map.ValueForKey( image_src ))
      If ref
				Return ref
			Else
				'Throw "reference_map[~q" + image_src + "~q] is null"
			End If
		Else
			'Throw "image_key_map[~q" + image_key + "~q] is null"
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
					'////////////////////////////
					ref.LoadAtlas( atlas, rect )
					'////////////////////////////
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
		handle = Create_cVEC( handle_x, handle_y )
		'////////////////////////////////////////////////////////
		ref.LoadLegacy( handle, flip_horizontal, flip_vertical )
		'////////////////////////////////////////////////////////
		If frames = 1
			ref.NullAnim()
		Else If frames > 1
			frame_width = json.GetNumber( "frame_width" )
			frame_height = json.GetNumber( "frame_height" )
			'/////////////////////////////////////////////////
			ref.LoadAnim( frames, frame_width, frame_height )
			'/////////////////////////////////////////////////
		End If
	End Function
	
End Type

