Rem
	load_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const SPAWN_POINT_RANDOM% = -1

Type SQUAD
	Field archetypes%[] 'agents to spawn for this squad
	Field spawn_point% 'can be SPAWN_POINT_RANDOM or a spawn point index
	Field wait_time% 'time delay between spawning the first agent of the previous squad and the first agent of this squad
End Type
'______________________________________________________________________________
Const LINE_TYPE_HORIZONTAL% = 1
Const LINE_TYPE_VERTICAL% = 2

Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell

Const COORDINATE_INVALID% = -1

Function Create_LEVEL:LEVEL( width%, height% )
	Local lev:LEVEL = New LEVEL
	lev.width = width; lev.height = height
	lev.row_count = 1; lev.col_count = 1
	lev.horizontal_divs = [ 0, lev.height ]
	lev.vertical_divs = [ 0, lev.width ]
	lev.pathing = New Int[ lev.row_count, lev.col_count ]
	Return lev
End Function

Type LEVEL
	Field width%, height% 'size in pixels
	Field row_count%, col_count% 'number of divisions
	Field horizontal_divs%[] 'horizontal dividers
	Field vertical_divs%[] 'vertical dividers
	Field pathing%[,] '{PASSABLE|BLOCKED}[w,h]
	Field spawns:TList 'TList<POINT>
	Field squads:TList 'TList<SQUAD>
	Field walls:TList 'TList<BOX> (cached after level has been completely initialized)
	
	Method New()
		spawns = CreateList()
		squads = CreateList()
	End Method
	
	Method add_divider( pos%, line_type% )
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				If pos <= 0 Or pos >= height Then Return
				For Local i% = 0 To horizontal_divs.Length - 2
					If pos > horizontal_divs[i] And pos < horizontal_divs[i+1]
						Local old_horizontal_divs%[] = horizontal_divs
						horizontal_divs = New Int[old_horizontal_divs.Length+1]
						'all old divs up to the new one's spot
						For Local j% = 0 To i
							horizontal_divs[j] = old_horizontal_divs[j]
						Next
						'new div
						horizontal_divs[i+1] = pos
						'all old divs after the new one's spot
						For Local j% = i+1 To old_horizontal_divs.Length - 1
							horizontal_divs[j+1] = old_horizontal_divs[j]
						Next
						row_count :+ 1
						pathing = New Int[row_count,col_count]
						Return
					End If
				Next
			
			Case LINE_TYPE_VERTICAL
				If pos <= 0 Or pos >= width Then Return
				For Local i% = 0 To vertical_divs.Length - 2
					If pos > vertical_divs[i] And pos < vertical_divs[i+1]
						Local old_vertical_divs%[] = vertical_divs
						vertical_divs = New Int[old_vertical_divs.Length+1]
						'all old divs up to the new one's spot
						For Local j% = 0 To i
							vertical_divs[j] = old_vertical_divs[j]
						Next
						'new div
						vertical_divs[i+1] = pos
						'all old divs after the new one's spot
						For Local j% = i+1 To old_vertical_divs.Length - 1
							vertical_divs[j+1] = old_vertical_divs[j]
						Next
						col_count :+ 1
						pathing = New Int[row_count,col_count]
						Return
					End If
				Next
				
		End Select
	End Method
	
	Method remove_divider( pos%, line_type% )
		Select line_type
			
			Case LINE_TYPE_HORIZONTAL
				If pos <= 0 Or pos >= height Then Return
				For Local i% = 0 To horizontal_divs.Length - 1
					If pos = horizontal_divs[i]
						Local old_horizontal_divs%[] = horizontal_divs
						horizontal_divs = New Int[old_horizontal_divs.Length-1]
						'all old divs up to the removed one's spot
						For Local j% = 0 To i
							horizontal_divs[j] = old_horizontal_divs[j]
						Next
						'all old divs after the removed one's spot
						For Local j% = i+1 To old_horizontal_divs.Length - 1
							horizontal_divs[j-1] = old_horizontal_divs[j]
						Next
						row_count :- 1
						pathing = New Int[row_count,col_count]
						Return
					End If
				Next
			
			Case LINE_TYPE_VERTICAL
				If pos <= 0 Or pos >= width Then Return
				For Local i% = 0 To vertical_divs.Length - 1
					If pos = vertical_divs[i]
						Local old_vertical_divs%[] = vertical_divs
						vertical_divs = New Int[old_vertical_divs.Length-1]
						'all old divs up to the removed one's spot
						For Local j% = 0 To i
							vertical_divs[j] = old_vertical_divs[j]
						Next
						'all old divs after the removed one's spot
						For Local j% = i+1 To old_vertical_divs.Length - 1
							vertical_divs[j-1] = old_vertical_divs[j]
						Next
						col_count :- 1
						pathing = New Int[row_count,col_count]
						Return
					End If
				Next
			
		End Select
	End Method
	
	Method set_pathing_value( x%, y%, value% )
		Local c:CELL = get_cell( x, y )
		If c.row <> COORDINATE_INVALID And c.col <> COORDINATE_INVALID
			pathing[ c.row, c.col ] = value
		End If
	End Method
	Method get_cell:CELL( x%, y% )
		Local c:CELL = CELL.Create( COORDINATE_INVALID, COORDINATE_INVALID )
		For Local i% = 0 To vertical_divs.Length - 2
			If x > vertical_divs[i] And x < vertical_divs[i+1]
				c.col = i
				Exit
			End If
		Next
		For Local i% = 0 To horizontal_divs.Length - 2
			If y > horizontal_divs[i] And y < horizontal_divs[i+1]
				c.row = i
				Exit
			End If
		Next
		Return c
	End Method
	
	Method add_spawn( sp:POINT )
		spawns.AddLast( sp )
	End Method
	
	Method add_squad( sq:SQUAD )
		squads.AddLast( sq )
	End Method
	
End Type

Const gridsnap% = 10
'______________________________________________________________________________
Const EDIT_LEVEL_MODE_PAN% = 1
Const EDIT_LEVEL_MODE_DIVIDER% = 2
Const EDIT_LEVEL_MODE_PATHING% = 3
Const EDIT_LEVEL_MODE_SPAWN% = 4

Function edit_level( lev:LEVEL )
	Local mode% = EDIT_LEVEL_MODE_PAN
	Local x% = gridsnap, y% = 2*gridsnap
	Local mouse_down_1% = False, mouse_down_2% = False
	
	While Not KeyHit( KEY_ESCAPE )
	
		Cls
		
		'draw the grid
		SetColor( 255, 255, 255 )
		SetLineWidth( 1 )
		SetAlpha( 0.25 )
		Local grid_rows% = lev.height / gridsnap
		Local grid_cols% = lev.width / gridsnap
		For Local i% = 0 To grid_rows
			DrawLine( x,y+i*gridsnap, x+grid_cols*gridsnap,y+i*gridsnap )
		Next
		For Local i% = 0 To grid_cols
			DrawLine( x+i*gridsnap,y, x+i*gridsnap,y+grid_rows*gridsnap )
		Next
		
		'draw the dividers
		SetAlpha( 0.50 )
		For Local i% = 0 To lev.horizontal_divs.length - 1
			DrawLine( x,y+lev.horizontal_divs[i], x+lev.width,y+lev.horizontal_divs[i] )
		Next
		For Local i% = 0 To lev.vertical_divs.length - 1
			DrawLine( x+lev.vertical_divs[i],y, x+lev.vertical_divs[i],y+lev.height )
		Next
		
		'draw the pathing grid
		SetColor( 127, 127, 127 )
		SetAlpha( 0.50 )
		For Local r% = 0 To lev.row_count - 1 'lev.horizontal_divs.Length - 2
			For Local c% = 0 To lev.col_count - 1 'lev.vertical_divs.Length - 2
				If lev.pathing[r,c] = PATH_BLOCKED
					DrawRect( x+lev.vertical_divs[c],y+lev.horizontal_divs[r], lev.vertical_divs[c+1]-lev.vertical_divs[c],lev.horizontal_divs[r+1]-lev.horizontal_divs[r] )
				End If
			Next
		Next
		
		'draw the spawn points
		SetAlpha( 0.20 )
		For Local p:POINT = EachIn lev.spawns
			DrawOval( x+p.pos_x - 3,y+p.pos_y - 3, 6,6 )
			SetLineWidth( 1 )
			SetAlpha( 0.4 )
			DrawLine( x+p.pos_x + 2*Cos(p.ang-90),y+p.pos_y + 2*Sin(p.ang-90), x+p.pos_x + 2*Cos(p.ang+90),y+p.pos_y + 2*Sin(p.ang+90) )
			DrawLine( x+p.pos_x,y+p.pos_y, x+p.pos_x + 2*Cos(p.ang),y+p.pos_y + 2*Sin(p.ang) )
		Next
		
		'process input
		If KeyHit( KEY_1 ) 'divider mode
			mode = EDIT_LEVEL_MODE_PAN
		Else If KeyHit( KEY_2 ) 'pathing passable/blocking mode
			mode = EDIT_LEVEL_MODE_DIVIDER
		Else If KeyHit( KEY_3 ) 'spawn point mode
			mode = EDIT_LEVEL_MODE_PATHING
		Else If KeyHit( KEY_4 ) 'null mode
			mode = EDIT_LEVEL_MODE_SPAWN
		End If
		
		Local mouse:cVEC = cVEC( cVEC.Create( MouseX(),MouseY() ))
		
		SetImageFont( get_font( "consolas_12" ))
		Select mode
			
			Case EDIT_LEVEL_MODE_PAN
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PAN+" -> camera pan", 2,2 )
				If MouseDown( 1 )
					x = mouse.x/2 + gridsnap
					y = mouse.y/2 + 2*gridsnap
				Else If MouseDown( 2 )
					x = gridsnap
					y = 2*gridsnap
				End If
			
			Case EDIT_LEVEL_MODE_DIVIDER
				mouse.x = round_to_nearest( mouse.x, gridsnap )
				mouse.y = round_to_nearest( mouse.y, gridsnap )
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_DIVIDER+" -> dividers vertical/horizontal", 2,2 )
				If mouse_down_1 And Not MouseDown( 1 )
					If Not KeyDown( KEY_LCONTROL ) And Not KeyDown( KEY_RCONTROL )
						lev.add_divider( mouse.x-x, LINE_TYPE_VERTICAL )
					Else 
						lev.remove_divider( mouse.x-x, LINE_TYPE_VERTICAL )
					End If
				End If
				If mouse_down_2 And Not MouseDown( 2 )
					If Not KeyDown( KEY_LCONTROL ) And Not KeyDown( KEY_RCONTROL )
						lev.add_divider( mouse.y-y, LINE_TYPE_HORIZONTAL )
					Else 
						lev.remove_divider( mouse.y-y, LINE_TYPE_HORIZONTAL )
					End If
				End If
				SetAlpha( 0.60 )
				If MouseDown( 1 )
					mouse_down_1 = True
					SetLineWidth( 3 )
					DrawLine( mouse.x,y, mouse.x,y+lev.height )
					SetLineWidth( 1 )
					DrawLine( mouse.x,y, mouse.x,y+lev.height )
				Else
					mouse_down_1 = False
				End If
				If MouseDown( 2 )
					mouse_down_2 = True
					SetLineWidth( 3 )
					DrawLine( x,mouse.y, x+lev.width,mouse.y )
					SetLineWidth( 1 )
					DrawLine( x,mouse.y, x+lev.width,mouse.y )
				Else
					mouse_down_2 = False
				End If
									
			Case EDIT_LEVEL_MODE_PATHING
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_PATHING+" -> pathing blocked/passable", 2,2 )
				If MouseDown( 1 )
					lev.set_pathing_value( mouse.x-x,mouse.y-y, PATH_BLOCKED )
				Else If MouseDown( 2 )
					lev.set_pathing_value( mouse.x-x,mouse.y-y, PATH_PASSABLE )
				End If
				
			
			Case EDIT_LEVEL_MODE_SPAWN
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode "+EDIT_LEVEL_MODE_SPAWN+" -> spawn points add/remove", 2,2 )
				
			Default
				'help
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "[level editor]  "+EDIT_LEVEL_MODE_PAN+":pan  "+EDIT_LEVEL_MODE_DIVIDER+":dividers  "+EDIT_LEVEL_MODE_PATHING+":pathing  "+EDIT_LEVEL_MODE_SPAWN+":spawns", 2,2 )
			
		End Select

		Flip( 1 )
		
	End While
End Function


