Rem
	image_manip.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "color.bmx"

'______________________________________________________________________________
Function create_rect_img:TIMage( w%, h%, hx% = 0, hy% = 0 )
	'create pixmap of given size, with a border pixel for smoothing
	Local pixmap:TPixmap = CreatePixmap( w + 2, h + 2, PF_RGBA8888 )
	Local r% = 255, g% = 255, b% = 255
	pixmap.ClearPixels( encode_ARGB( 1.0, r, g, b ))
	'erase the outer border
	For Local x% = 0 To w + 2 - 1
		pixmap.WritePixel( x, 0, encode_ARGB( 0.0, r, g, b ))
	Next
	For Local x% = 0 To w + 2 - 1
		pixmap.WritePixel( x, h + 2 - 1, encode_ARGB( 0.0, r, g, b ))
	Next
	For Local y% = 0 To h + 2 - 1
		pixmap.WritePixel( 0, y, encode_ARGB( 0.0, r, g, b ))
	Next
	For Local y% = 0 To h + 2 - 1
		pixmap.WritePixel( w + 2 - 1, y, encode_ARGB( 0.0, r, g, b ))
	Next
	For Local x% = 1 + w/2 To w + 2 - 1
		For Local y% = 1 + h/3 To 1 + 2*h/3
			pixmap.WritePixel( x, y, encode_ARGB( 0.0, r, g, b ))
		Next
	Next
	'transfer to video memory
	Local img:TImage = LoadImage( pixmap, FILTEREDIMAGE )
	SetImageHandle( img, 0.5 + hx, 0.5 + hy )
	Return img
End Function

'______________________________________________________________________________
Function pixel_transform:TImage( img_src:TImage, flip_horizontal% = False, flip_vertical% = False )
	If Not flip_horizontal And Not flip_vertical
		Return img_src;
	End If
	Local pixmap_src:TPixmap = img_src.Lock( 0, True, False )
	Local pixmap_new:TPixmap = pixmap_src.Copy()
	'transform the pixels
	Local new_x%, new_y%
	For Local x% = 0 To pixmap_src.width - 1
		For Local y% = 0 To pixmap_src.height - 1
			If flip_horizontal
				new_x = pixmap_src.width - 1 - x
			Else
				new_x = x
			End If
			If flip_vertical
				new_y = pixmap_src.height - 1 - y
			Else
				new_y = y
			End If
			pixmap_new.WritePixel( new_x, new_y, pixmap_src.ReadPixel( x, y ))
		Next
	Next
	UnlockImage( img_src )
	Local img_new:TImage = LoadImage( pixmap_new, FILTEREDIMAGE|MIPMAPPEDIMAGE )
	'set the image handle
	SetImageHandle( img_new, img_src.handle_x, img_src.handle_y )
	If flip_horizontal
		img_new.handle_x = img_src.width - 1 - img_src.handle_x
	End If
	If flip_vertical
		img_new.handle_y = img_src.height - 1 - img_src.handle_y
	End If
	Return img_new
End Function

'______________________________________________________________________________
Function unfilter_image:TImage( img:TImage )
	If Not img Then Return Null
	Local new_img:TImage = LoadImage( img.pixmaps[0], 0 )'img.flags&(~MIPMAPPEDIMAGE) )
	SetImageHandle( new_img, img.handle_x, img.handle_y )
	Return new_img
End Function




