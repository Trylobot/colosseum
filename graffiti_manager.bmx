Rem
	graffiti_manager.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "box.bmx"
Import "texture_manager.bmx"
Import "particle.bmx"

'______________________________________________________________________________
Type GRAFFITI_MANAGER
	Field cache:TImage[,]
	Field bounds:BOX[,]
	Field rows%, cols%
	Field col_width%, row_height%
	Field level_width%, level_height%
	
	Function Create:GRAFFITI_MANAGER( background_clean:TImage, backbuffer_width%, backbuffer_height% )
		Local g:GRAFFITI_MANAGER = New GRAFFITI_MANAGER
		g.col_width = backbuffer_width
		g.row_height = backbuffer_height
		g.level_width = background_clean.width
		g.level_height = background_clean.height
		g.rows = Ceil( Float(g.level_height) / Float(g.row_height) )
		g.cols = Ceil( Float(g.level_width) / Float(g.col_width) )
		g.cache = New TImage[ g.rows, g.cols ]
		g.bounds = New BOX[ g.rows, g.cols ]
		Local flags% = DYNAMICIMAGE | FILTEREDIMAGE
		SetOrigin( 0, 0 )
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetRotation( 0 )
		For Local r% = 0 Until g.rows
			For Local c% = 0 Until g.cols
				g.bounds[r,c] = Create_BOX( c * g.col_width, r * g.row_height, g.col_width, g.row_height )
				g.cache[r,c] = CreateImage( g.col_width, g.row_height, 1, flags )
				Cls()
				DrawImage( background_clean, c * -g.col_width, r * -g.row_height )
				GrabImage( g.cache[r,c], 0, 0 )
			Next
		Next
		Return g
	End Function
	
	Method resize_backbuffer( backbuffer_width%, backbuffer_height% )
		
	End Method
	
	Method add_graffiti( particle_list:TList )
		If particle_list.IsEmpty() Then Return
		For Local r% = 0 Until rows
			For Local c% = 0 Until cols
				'only update cache if necessary
				Local changed% = False
				For Local p:PARTICLE = EachIn particle_list
					'test particle for intersection with this cache cell
					If bounds[r,c].intersects( p.get_bounding_box() )
						If Not changed
							changed = True
							Cls()
							SetColor( 255, 255, 255 )
							SetAlpha( 1 )
							SetScale( 1, 1 )
							SetRotation( 0 )
							DrawImage( cache[r,c], 0, 0 )
						End If
						SetColor( p.red*255, p.green*255, p.blue*255 )
						SetAlpha( p.alpha )
						SetScale( p.scale, p.scale )
						SetRotation( p.ang )
						DrawImageRef( p.img, p.pos_x Mod col_width, p.pos_y Mod row_height, p.frame )
					End If
				Next
				If changed
					GrabImage( cache[r,c], 0, 0 )
				End If
			Next
		Next
	End Method
	
	Method draw()
		SetColor( 255, 255, 255 )
		SetAlpha( 1 )
		SetScale( 1, 1 )
		SetRotation( 0 )
		For Local r% = 0 Until rows
			For Local c% = 0 Until cols
				If cache[r,c]
					DrawImage( cache[r,c], c*col_width, r*row_height )
				End If
			Next
		Next
	End Method
	
End Type

