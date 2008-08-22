Rem
	load_data.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const LINE_TYPE_HORIZONTAL% = 1
Const LINE_TYPE_VERTICAL% = 2

Function Create_DIVIDER_LINE:DIVIDER_LINE( line_type%, position% )
	Local dl:DIVIDER_LINE = New DIVIDER_LINE
	dl.line_type = line_type
	dl.position = position
	Return dl
End Function

Type DIVIDER_LINE
	Field line_type% '{HORIZONTAL|VERTICAL}
	Field position%
End Type
'______________________________________________________________________________
Const SPAWN_POINT_RANDOM% = -1

Type SQUAD
	Field archetypes%[] 'agents to spawn for this squad
	Field spawn_point% 'can be SPAWN_POINT_RANDOM or a spawn point index
	Field wait_time% 'time delay between spawning the first agent of the previous squad and the first agent of this squad
End Type
'______________________________________________________________________________
Const PATH_PASSABLE% = 0 'indicates normal cost grid cell
Const PATH_BLOCKED% = 1 'indicates entirely impassable grid cell

Function Create_LEVEL:LEVEL( width%, height% )
	Local lev:LEVEL = New LEVEL
	lev.width = width; lev.height = height
	lev.row_count = 1; lev.col_count = 1
	lev.pathing = New Int[ lev.row_count, lev.col_count ]
	Return lev
End Function

Type LEVEL
	Field width%, height% 'size in pixels
	Field dividers:TList 'TList<DIVIDER_LINE>
	Field row_count%, col_count% 'size in pathing cells
	Field pathing%[,] '{PASSABLE|BLOCKED}[w,h]
	Field spawns:TList 'TList<POINT>
	Field squads:TList 'TList<SQUAD>
	
	Field walls:TList 'TList<BOX> cached after level has been completely initialized
	
	Method New()
		dividers = CreateList()
		spawns = CreateList()
		squads = CreateList()
		walls = CreateList()
	End Method
	
	Method add_divider( dl:DIVIDER_LINE )
		
	End Method
	
	Method set_pathing_value( c:CELL, value% )
		
	End Method
	
	Method add_spawn( sp:POINT )
		
	End Method
	
	Method add_squad( sq:SQUAD )
		
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
	
	While Not done And ..
	Not AppTerminate() And Not KeyHit( KEY_ESCAPE )
		Cls
		
		'draw the grid
		SetColor( 255, 255, 255 )
		SetLineWidth( 1 )
		SetAlpha( 0.25 )
		x = gridsnap; y = gridsnap
		Local grid_rows% = lev.height / gridsnap
		Local grid_cols% = lev.width / gridsnap
		For Local r% = 0 To grid_rows
			DrawLine( x,y + r*gridsnap, x + grid_rows*gridsnap,y + r*gridsnap )
		Next
		For Local c% = 0 To grid_cols
			DrawLine( x + c*gridsnap,y, x + c*gridsnap,y + grid_cols*gridsnap )
		Next
		
		'draw the dividers
		SetAlpha( 0.50 )
		For Local d:DIVIDER_LINE = EachIn lev.dividers
			Select d.line_type
				Case LINE_TYPE_HORIZONTAL
					DrawLine( x,d.position, x + lev.width,d.position )
				Case LINE_TYPE_VERTICAL
					DrawLine( d.position,y, d.position,y + lev.height )
			End Select
		Next
		
		'draw the pathing grid
'		SetAlpha( 0.333 )
'		For Local r% = 0 To lev.row_count - 1
'			For Local c% = 0 To lev.col_count - 1
'				If lev.pathing[r,c] = PATH_BLOCKED
'					DrawRect( )
'				End If
'			Next
'		Next
		
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
		
		Select mode
			
			Case EDIT_LEVEL_MODE_DIVIDER
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 1 -> dividers horizontal/vertical", 2,2 )
				SetLineWidth( 3 )
				SetAlpha( 0.60 )
				If mouse_down_1 And Not MouseDown( 1 )
					lev.add_divider( Create_DIVIDER_LINE( LINE_TYPE_HORIZONTAL, mouse.y ))
				Else If mouse_down_2 And Not MouseDown( 2 )
					lev.add_divider( Create_DIVIDER_LINE( LINE_TYPE_VERTICAL, mouse.x ))
				End If
				If MouseDown( 1 )
					mouse_down_1 = True
					DrawLine( x,mouse.y, x + lev.width,mouse.y )
				Else
					mouse_down_1 = False
				End If
				If MouseDown( 2 )
					mouse_down_2 = True
					DrawLine( mouse.x,y, mouse.x,y + lev.height )
				Else
					mouse_down_2 = False
				End If
									
			Case EDIT_LEVEL_MODE_PATHING
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 2 -> pathing pass/block", 2,2 )
				SetAlpha( 0.20 )
				
			
			Case EDIT_LEVEL_MODE_SPAWN
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 3 -> spawn points add/remove", 2,2 )
				
			Default
				SetColor( 255, 255, 255 )
				SetAlpha( 1 )
				DrawText_with_shadow( "mode 0 -> null  {1:dividers, 2:pathing, 3:spawns}", 2,2 )
			
		End Select

		Flip( 1 )
	End While
End Function


