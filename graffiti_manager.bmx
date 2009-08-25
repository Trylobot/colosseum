Rem
	graffiti_manager.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type GRAFFITI_MANAGER
	Field cache:TImage[,]
	Field bounds:BOX[,]
	Field rows%, cols%
	Field row_height%, col_width%
	
	Function Create:GRAFFITI_MANAGER( total_height%, total_width%, backbuffer_height%, backbuffer_width% )
		Local g:GRAFFITI_MANAGER = New GRAFFITI_MANAGER
		
		Return g
	End Function
	
	Method add_graffiti( particle_list:TList )
		For Local r% = 0 Until rows
			For Local c% = 0 Until cols
				Cls
				Local changed% = False
				For Local p:PARTICLE = EachIn particle_list
					If bounds[r,c].contains_partly( p.get_bounding_box() )
						If Not changed
							changed = True
							SetColor( 255, 255, 255 )
							SetAlpha( 1 )
							SetScale( 1, 1 )
							SetRotation( 0 )
							DrawImage( cache[r,c], 0, 0 )
						End If
						SetColor( p.red, p.green, p.blue )
						SetAlpha( p.alpha )
						SetScale( p.scale, p.scale )
						SetRotation( p.ang )
						DrawImage( p.img, p.pos_x Mod col_width, p.pos_y Mod row_height, p.frame )
					End If
				Next
				If changed
					GrabImage( cache[r,c], 0, 0 )
				End If
			Next
		Next
	End Method
	
End Type

