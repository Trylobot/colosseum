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
				For Local i% = 0 To horizontal_divs.Length - 1
					If horizontal_divs[i] = pos Then Return
				Next
				horizontal_divs = horizontal_divs[..horizontal_divs.Length+1]
				horizontal_divs[horizontal_divs.Length-1] = pos
				horizontal_divs.Sort()
				row_count :+ 1
			Case LINE_TYPE_VERTICAL
				For Local i% = 0 To vertical_divs.Length - 1
					If vertical_divs[i] = pos Then Return
				Next
				vertical_divs = vertical_divs[..vertical_divs.Length+1]
				vertical_divs[vertical_divs.Length-1] = pos
				vertical_divs.Sort()
				col_count :+ 1
		End Select
		pathing = New Int[row_count,col_count]
	End Method
	
	Method set_pathing_value( x%, y%, value% )
		Local c:CELL = get_cell( x, y )
		If c.row > 0 And c.row < row_count And c.col > 0 And c.col < col_count
			pathing[ c.row, c.col ] = value
		End If
	End Method
	Method get_cell:CELL( x%, y% )
		Local c:CELL = CELL.Create( -1, -1 )
		For Local i% = 0 To vertical_divs.Length - 2
			If x >= vertical_divs[i] And x <= vertical_divs[i+1]
				c.row = i
				Exit
			End If
		Next
		For Local i% = 0 To horizontal_divs.Length - 2
			If y >= horizontal_divs[i] And y <= horizontal_divs[i+1]
				c.col = i
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
Const EDIT_LEVEL_MODE_NONE% = 0
Const EDIT_LEVEL_MODE_DIVIDER% = 1
Const EDIT_LEVEL_MODE_PATHING% = 2
Const EDIT_LEVEL_MODE_SPAWN% = 3

Function edit_level( lev:LEVEL )
	Local done% = False
	Local mode% = EDIT_LEVEL_MODE_NONE
	Local x% = 0, y% =0 
	Local mouse_down_1% = False, mouse_down_2% = False
	
	While Not done
		x = gridsnap; y = 2*gridsnap
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
		For Local r% = 0 To lev.row_count - 2
			For Local c% = 0 To lev.col_count - 2
				If lev.pathing[r,c] = PATH_BLOCKED
					DrawRect( lev.horizontal_divs[r],lev.vertical_divs[c], lev.horizontal_divs[r+1]-lev.horizontal_divs[r],lev.vertical_divs[c+1]-lev.vertical_divs[c] )
				End If
			Next
		Next
		
		'draw the spawn points
		SetAlpha( 0.20 )
		For Local p:POINT = EachIn lev.spawns
			DrawOval( p.pos_x - 3,p.pos_y - 3, 6,6 )
			SetLineWidth( 1 )
			SetAlpha( 0.4 )
			DrawLine( p.pos_x + 2*Cos(p.ang-90),p.pos_y + 2*Sin(p.ang-90), p.pos_x + 2*Cos(p.ang+90),p.pos_y + 2*Sin(p.ang+90) )
			DrawLine( p.pos_x,p.pos_y, p.pos_x + 2*Cos(p.ang),p.pos_y + 2*Sin(p.ang) )
		Next
		
		'process input
		If KeyHit( KEY_1 ) 'horizontal divider mode
			mode = EDIT_LEVEL_MODE_DIVIDER
		Else If KeyHit( KEY_2 ) 'pathing passable mode
			mode = EDIT_LEVEL_MODE_PATHING
		Else If KeyHit( KEY_3 ) 'spawn point mode
			mode = EDIT_LEVEL_MODE_SPAWN
		Else If KeyHit( KEY_0 ) 'null mode
			mode = EDIT_LEVEL_MODE_NONE
		End If
		
		Local mouse:cVEC = cVEC( cVEC.Create( MouseX(),MouseY() ))
		
		SetImageFont( get_font( "consolas_12" ))
		Select mode
			
			Case EDIT_LEVEL_MODE_DIVIDER
				mouse.x = round_to_nearest( mouse.x, gridsnap )
				mouse.y = round_to_nearest( mouse.y, gridsnap )
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 1 -> dividers vertical/horizontal", 2,2 )
				SetLineWidth( 3 )
				SetAlpha( 0.60 )
				If mouse_down_1 And Not MouseDown( 1 )
					lev.add_divider( mouse.y, LINE_TYPE_VERTICAL )
				Else If mouse_down_2 And Not MouseDown( 2 )
					lev.add_divider( mouse.x, LINE_TYPE_HORIZONTAL )
				End If
				If MouseDown( 1 )
					mouse_down_1 = True
					DrawLine( mouse.x,y, mouse.x,y+lev.height )
				Else
					mouse_down_1 = False
				End If
				If MouseDown( 2 )
					mouse_down_2 = True
					DrawLine( x,mouse.y, x+lev.width,mouse.y )
				Else
					mouse_down_2 = False
				End If
									
			Case EDIT_LEVEL_MODE_PATHING
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 2 -> pathing pass/block", 2,2 )
				If mouse_down_1 And Not MouseDown( 1 )
					lev.set_pathing_value( mouse.x,mouse.y, PATH_BLOCKED )
				Else If mouse_down_2 And Not MouseDown( 2 )
					lev.set_pathing_value( mouse.x,mouse.y, PATH_PASSABLE )
				End If
				If MouseDown( 1 )
					mouse_down_1 = True
					Local c:CELL = lev.get_cell( mouse.x, mouse.y )
					SetColor( 255, 255, 255 )
					SetAlpha( 0.20 )
					DrawRect( x+lev.horizontal_divs[c.col],y+lev.vertical_divs[c.row], lev.horizontal_divs[c.col+1],lev.vertical_divs[c.row+1] )
				Else
					mouse_down_1 = False
				End If
				If MouseDown( 2 )
					mouse_down_2 = True
					Local c:CELL = lev.get_cell( mouse.x, mouse.y )
					SetColor( 255, 205, 205 )
					SetAlpha( 0.20 )
					DrawRect( x+lev.horizontal_divs[c.col],y+lev.vertical_divs[c.row], lev.horizontal_divs[c.col+1],lev.vertical_divs[c.row+1] )
				Else
					mouse_down_2 = False
				End If
				
			
			Case EDIT_LEVEL_MODE_SPAWN
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 3 -> spawn points add/remove", 2,2 )
				
			Default
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "level editor  1:dividers, 2:pathing, 3:spawns", 2,2 )
			
		End Select

		check_esc_held()

		Flip( 1 )
		
	End While
End Function


