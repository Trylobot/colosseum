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
	'base image data
	Field atlas:TImage 'pixel data
	Field iframe:TImageFrame 'for drawing
	'texture coords
	Field src_rect:BOX 'coordinates on texture of this specific image
	Field width# 'if single cell, width of src_rect; else, width of each cell
	Field height# 'if single cell, height of src_rect; else, height of each cell
	'legacy image
	Field handle_x# 'local origin
	Field handle_y# 'local origin
	'sprite animation
	Field multi_cell% 'boolean
	Field cell_count% 'number of cells of animation
	Field cell_pos:cVEC[] 'position of each cell, plus width & height from above
  'drawing cache
	Field x0#,x1#, y0#,y1#, tx#,ty#, sx#,sy#, sw#,sh#
	Global ox#,oy#
	
	Method Draw( x#, y#, f% = 0 )
		GetOrigin( ox, oy )
    tx = x + ox
    ty = y + oy
		If multi_cell
			sx = cell_pos[f].x
	    sy = cell_pos[f].y
		End If
		'///////////////////////////////////////////////
		iframe.Draw( x0,y0, x1,y1, tx,ty, sx,sy,sw,sh )
		'///////////////////////////////////////////////
	End Method

	Function Create:IMAGE_ATLAS_REFERENCE( atlas:TImage, rect:BOX )
		Local ref:IMAGE_ATLAS_REFERENCE = New IMAGE_ATLAS_REFERENCE
		ref.LoadAtlas( atlas, rect )
		Return ref
	End Function
	
	Method LoadAtlas( atlas:TImage, rect:BOX )
		Self.atlas = atlas
		iframe = atlas.Frame( 0 )
		src_rect = rect
		width = rect.w
		height = rect.h
		multi_cell = False
		cell_pos = Null
	End Method
	
	Method LoadImageModifiers( handle_x#, handle_y#, flip_x% = False, flip_y% = False )
		Self.handle_x = handle_x
		Self.handle_y = handle_y
		If Not flip_x
			x0 = -handle_x
			x1 = x0 + width
		Else 'flip_x
			x1 = -handle_x
			x0 = x1 + width
		End If
		If Not flip_y
	    y0 = -handle_y
	    y1 = y0 + height
		Else 'flip_y
	    y1 = -handle_y
	    y0 = y1 + height
		End If
		sx = src_rect.x
		sy = src_rect.y
    sw = width
    sh = height
	End Method
	
	Method LoadMultiFrameAnimation( cell_count%, cell_width#, cell_height# )
		If cell_count <= 1 Then Return
		multi_cell = True
		Self.cell_count = cell_count
    width = cell_width
    height = cell_height
		cell_pos = New cVEC[cell_count]
		Local columns% = src_rect.w / width
		Local rows% = src_rect.h / height
		Local current_cell% = 0
		For Local current_row% = 0 Until rows
			For Local current_column% = 0 Until columns
				'cell coordinates
				cell_pos[current_cell] = Create_cVEC( ..
					src_rect.x + (current_column*width), ..
					src_rect.y + (current_row*height) )
				'early break-out (for animations that don't fill the entire src_rect
				current_cell :+ 1
				If current_cell >= cell_count
					Return
				End If
			Next
		Next
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

