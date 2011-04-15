Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import brl.max2d
'Import "box.bmx"

'______________________________________________________________________________
Function DrawImageRef( ref:IMAGE_ATLAS_REFERENCE, x#, y#, f% = 0 )
	If ref Then ref.Draw( x, y, f )
End Function

Function CreateImageRef:IMAGE_ATLAS_REFERENCE( atlas:TImage, rect:BOX )
  Local ref:IMAGE_ATLAS_REFERENCE = New IMAGE_ATLAS_REFERENCE
  ref.LoadAtlasRect( atlas, rect )
  Return ref
End Function

'______________________________________________________________________________
Type IMAGE_ATLAS_REFERENCE
	'base image data
	Field atlas:TImage 'pixel data
	'texture coords
	Field src_rect:BOX 'coordinates on texture of this specific image
	'legacy image
	Field handle_x# 'local origin
	Field handle_y# 'local origin
	Field flip_x% 'boolean
	Field flip_y% 'boolean
	'sprite animation
	Field multi_cell% 'boolean
	Field variable_width% 'boolean
	Field cell_count% 'number of cells of animation
	Field cell_rect:BOX[] 'position of each cell, plus width & height from above
	'draw cache
	Field x0#,x1#, y0#,y1#, tx#,ty#, sx#,sy#, sw#,sh#
	Global ox#,oy#
	
	Method Draw( x#, y#, f% = 0 )
		GetOrigin( ox, oy )
		tx = x + ox
		ty = y + oy
		If multi_cell
			sx = cell_rect[f].x
			sy = cell_rect[f].y
			If variable_width
				'ignores flip_x and flip_y
				sw = cell_rect[f].w
				x1 = x0 + sw
			End If
		End If
		'///////////////////////////////////////////////////////
		atlas.Frame(0).Draw( x0,y0, x1,y1, tx,ty, sx,sy,sw,sh )
		'If Not flip_x
		'	If Not flip_y
		'		atlas.Frame(0).Draw( x0,y0, x1,y1, tx,ty, sx,sy,sw,sh )
		'	Else  'flip_y
		'		atlas.Frame(0).Draw( x0,y1, x1,y0, tx,ty, sx,sy,sw,sh )
		'	End If
		'Else  'flip_x
		'	If Not flip_y
		'		atlas.Frame(0).Draw( x1,y0, x0,y1, tx,ty, sx,sy,sw,sh )
		'	Else  'flip_y
		'		atlas.Frame(0).Draw( x1,y1, x0,y0, tx,ty, sx,sy,sw,sh )
		'	End If
		'End If
		
		'///////////////////////////////////////////////////////
	End Method
	
	Method Pixmap:TPixmap( f% = 0 )
		Local r:BOX
		If multi_cell
			r = cell_rect[f]
		Else
			r = src_rect
		End If
		Return atlas.pixmaps[0].Window( r.x, r.y, r.w, r.h )
	End Method

	Method LoadAtlasRect( atlas:TImage, rect:BOX )
		Self.atlas = atlas
		src_rect = rect
		multi_cell = False
		variable_width = False
		cell_rect = Null
	End Method
	
	Method LoadImageModifiers( handle_x#, handle_y#, flip_x% = False, flip_y% = False )
		Self.flip_x = flip_x
		Self.flip_y = flip_y
		If Not flip_x
			Self.handle_x = handle_x
		Else 'flip_x
			Self.handle_x = src_rect.w - handle_x
		End If
		If Not flip_y
			Self.handle_y = handle_y
		Else 'flip_y
			Self.handle_y = src_rect.y - handle_y
		End If
		sx = src_rect.x
		sy = src_rect.y
		sw = src_rect.w
		sh = src_rect.h
		If Not flip_x
			x0 = -handle_x
			x1 = x0 + sw
		Else 'flip_x
			x1 = -handle_x
			x0 = x1 + sw
		End If
		If Not flip_y
			y0 = -handle_y
			y1 = y0 + sh
		Else 'flip_y
			y1 = -handle_y
			y0 = y1 + sh
		End If
	End Method
	
	Method LoadMultiCellAnimation( count%, cell_width#, cell_height# )
		If count <= 1 Then Return
		multi_cell = True
		variable_width = False
		cell_count = count
		cell_rect = New BOX[count]
		Local columns% = src_rect.w / cell_width
		Local rows% = src_rect.h / cell_height
		Local current_cell% = 0
		For Local current_row% = 0 Until rows
			For Local current_column% = 0 Until columns
				'cell coordinates and dimensions
				cell_rect[current_cell] = Create_BOX( ..
					src_rect.x + (current_column*cell_width), ..
					src_rect.y + (current_row*cell_height), ..
					cell_width, ..
					cell_height )
				'early break-out (for animations that don't fill the entire src_rect
				current_cell :+ 1
				If current_cell >= count
					current_column = columns
					current_row = rows
				End If
			Next
		Next
		'handle_x  already set
		'handle_y  already set
		'sx  determined at draw-time
		'sy  determined at draw-time
		sw = cell_width
		sh = cell_height
		If Not flip_x
			x0 = -handle_x
			x1 = x0 + sw
		Else 'flip_x
			x1 = -handle_x
			x0 = x1 + sw
		End If
		If Not flip_y
			y0 = -handle_y
			y1 = y0 + sh
		Else 'flip_y
			y1 = -handle_y
			y0 = y1 + sh
		End If
	End Method
	
	Method LoadVariableWidthBMPFont( count%, char_width%[], offset_x%, baseline_y% )
		If count <= 1 Then Return
		multi_cell = True
		variable_width = True
		cell_count = count
		cell_rect = New BOX[cell_count]
		Local current_x% = 0
		For Local current_char% = 0 Until count
			'character coordinates and dimensions
			cell_rect[current_char] = Create_BOX( ..
				src_rect.x + current_x, ..
				src_rect.y, ..
				char_width[current_char], ..
				src_rect.h )
			'x-coordinate advancement per-character
			current_x :+ char_width[current_char]
		Next
		'flip_x  ignored
		'flip_y  ignored
		handle_x = offset_x
		handle_y = baseline_y
		'sx  determined at draw-time
		'sy  determined at draw-time
		'sw  determined at draw_time
		sh = src_rect.h
		x0 = -handle_x
		'x1  determined at draw-time
		y0 = -handle_y
		y1 = y0 + src_rect.h
	End Method
	
	Method width#( f% = 0 )
		If Not multi_cell
			Return src_rect.w
		Else 'multi_cell
			Return cell_rect[f].w
		End If
	End Method
	
	Method height#( f% = 0 )
		If Not multi_cell
			Return src_rect.h
		Else 'multi_cell
			Return cell_rect[f].h
		End If
	End Method
	
End Type

Function CopyImageRef:IMAGE_ATLAS_REFERENCE( other:IMAGE_ATLAS_REFERENCE )
  Local ref:IMAGE_ATLAS_REFERENCE = New IMAGE_ATLAS_REFERENCE
  ref.atlas = other.atlas
  ref.src_rect = other.src_rect.clone()
  ref.handle_x = other.handle_x
  ref.handle_y = other.handle_y
  ref.flip_x = other.flip_x
  ref.flip_y = other.flip_y
  ref.multi_cell = other.multi_cell
  ref.variable_width = other.variable_width
  ref.cell_count = other.cell_count
  ref.cell_rect = New BOX[ref.cell_count]
  For Local i% = 0 Until ref.cell_count
    ref.cell_rect[i] = other.cell_rect[i].clone()
  Next
  ref.x0 = other.x0
  ref.x1 = other.x1
  ref.y0 = other.y0
  ref.y1 = other.y1
  ref.tx = other.tx
  ref.ty = other.ty
  ref.sx = other.sx
  ref.sy = other.sy
  ref.sw = other.sw
  ref.sh = other.sh
  Return ref
End Function

