Rem
	basic.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type MANAGED_OBJECT
	
	Field link:TLink 'back-reference to the list which contains this object
	Field id% 'unique identification number
	
	Method New()
		id = get_new_id()
	End Method
	
	Method add_me( list:TList )
		link = ( list.AddLast( Self ))
	End Method
	Method remove_me()
		If link <> Null
			link.Remove()
			link = Null
		End If
	End Method
	
	Method managed%()
		Return (link <> Null)
	End Method
	
End Type
'______________________________________________________________________________
'clock and random
SeedRnd MilliSecs()
Global clock:TTimer = CreateTimer( 1000 )
Function now%()
	Return clock.Ticks()
End Function
Function RandF#( lo#, hi# )
	Return lo + (hi-lo)*RndFloat()
End Function
'______________________________________________________________________________
Global next_managed_object_id% = 0
Const NULL_ID% = -1

Function get_new_id%()
	next_managed_object_id :+ 1
	Return next_managed_object_id
End Function
'______________________________________________________________________________
'vector functions
Function vector_length#( vx#, vy# )
	Return Sqr( vx*vx + vy*vy )
End Function
Function vector_angle#( vx#, vy# )
	Return ATan2( vy, vx )
End Function
Function vector_diff_length#( ax#, ay#, bx#, by# )
	Local dx# = bx - ax, dy# = by - ay
	Return Sqr( dx*dx + dy*dy )
End Function
Function vector_diff_angle#( ax#, ay#, bx#, by# )
	Local dx# = bx - ax, dy# = by - ay
	Return ATan2( dy, dx )
End Function
Function cartesian_to_polar( x#, y#, r# Var, a# Var )
	r = Sqr( x*x + y*y )
	a = ATan2( y, x )
End Function
Function polar_to_cartesian( r#, a#, x# Var, y# Var )
	x = r*Cos( a )
	y = r*Sin( a )
End Function
Function ang_diff#( a1#, a2# )
	Local diff# = a1 - a2
	If diff < 0 Then diff :+ 360
	Return diff
End Function
'______________________________________________________________________________
Type cVEC 'cartesian 2D vector
	
	Field x# 'x axis vector component
	Field y# 'y axis vector component
	
	Method New()
	End Method
	
End Type
'______________________________________________________________________________
Type pVEC 'polar 2D vector
	
	Field r# 'radius vector component
	Field a# 'angle vector component (theta)
	
	Method New()
	End Method
	
End Type
