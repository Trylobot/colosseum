Rem
	basic.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type MANAGED_OBJECT
	
	Field name$
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
Global next_managed_object_id% = 0
Const NULL_ID% = -1

Function get_new_id%()
	next_managed_object_id :+ 1
	Return next_managed_object_id
End Function
'______________________________________________________________________________
Type POINT Extends MANAGED_OBJECT
	
	Field pos_x# 'position (x-axis), pixels
	Field pos_y# 'position (y-axis), pixels
	Field ang# 'orientation angle, degrees
	Field vel_x# 'velocity (x-component), pixels per second
	Field vel_y# 'velocity (y-component), pixels per second
	Field ang_vel# 'angular velocity, degrees per second
	Field acc_x# 'acceleration (x-component), pixels per second per second
	Field acc_y# 'acceleration (y-component), pixels per second per second
	Field ang_acc# 'angular acceleration, degrees per second per second
	
	Method New()
	End Method
	
'	Method clone:POINT()
'		Return Create_POINT( pos_x, pos_y, ang, vel_x, vel_y, ang_vel, acc_x, acc_y, ang_acc )
'	End Method
	
	Method update()
		'velocity
		vel_x :+ acc_x
		vel_y :+ acc_y
		'position
		pos_x :+ vel_x
		pos_y :+ vel_y
		'angular velocity
		ang_vel :+ ang_acc
		'orientation
		ang = angle_sum( ang, ang_vel )
	End Method
	
End Type

Function Create_POINT:POINT( ..
pos_x# = 0.0, pos_y# = 0.0, ..
ang# = 0.0, ..
vel_x# = 0.0, vel_y# = 0.0, ..
ang_vel# = 0.0, ..
acc_x# = 0.0, acc_y# = 0.0, ..
ang_acc# = 0.0 )
	Local p:POINT = New POINT
	p.pos_x = pos_x; p.pos_y = pos_y
	p.ang = ang
	p.vel_x = vel_x; p.vel_y = vel_y
	p.ang_vel = ang_vel
	p.acc_x = acc_x; p.acc_y = acc_y
	p.ang_acc = ang_acc
	Return p
End Function
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
Function Pow#( x#, p% )
	For Local i% = 1 To p - 1
		x :* x
	Next
	Return x
End Function
'______________________________________________________________________________
'vector & angle functions
Function angle_sum#( a1#, a2# )
	Local a# = (a1 + a2) Mod 360
	If a < 0 Then Return a + 360 ..
	Else          Return a
End Function
Function vector_length#( vx#, vy# )
	Return Sqr( Pow(vx,2) + Pow(vy,2) )
End Function
Function vector_angle#( vx#, vy# )
	Return ATan2( vy, vx )
End Function
Function vector_diff_length#( ax#, ay#, bx#, by# )
	Local dx# = bx - ax, dy# = by - ay
	Return Sqr( Pow(dx,2) + Pow(dy,2) )
End Function
Function vector_diff_angle#( ax#, ay#, bx#, by# )
	Local dx# = bx - ax, dy# = by - ay
	Return ATan2( dy, dx )
End Function
Function cartesian_to_polar( x#, y#, r# Var, a# Var )
	r = Sqr( Pow(x,2) + Pow(y,2) )
	a = ATan2( y, x )
End Function
Function polar_to_cartesian( r#, a#, x# Var, y# Var )
	x = r*Cos( a )
	y = r*Sin( a )
End Function
Function angle_diff#( a1#, a2# )
	Local a# = (a1 - a2) Mod 360
	If a >= 0 Then Return a ..
	Else           Return a + 360
End Function
'______________________________________________________________________________
Type cVEC 'cartesian coordinate system 2D vector
	
	Field x# 'x axis vector component
	Field y# 'y axis vector component
	
	Method New()
	End Method
	
	Function Create:Object( x#, y# )
		Local v:cVEC = New cVEC
		v.x = x; v.y = y
		Return v
	End Function
	Method clone:cVEC()
		Return cVEC( cVEC.Create( x, y ))
	End Method
	
	Method r#()
		Return Sqr( Pow( x, 2 ) + Pow( y, 2 ))
	End Method
	Method a#()
		Return ATan2( y, x )
	End Method
End Type
'______________________________________________________________________________
Type pVEC 'polar coordinate system 2D vector
	
	Field r# 'radius vector component
	Field a# 'angle vector component (theta)
	
	Method New()
	End Method
	
	Function Create:Object( r#, a# )
		Local v:pVEC = New pVEC
		v.r = r; v.a = a
		Return v
	End Function
	Method clone:pVEC()
		Return pVEC( pVEC.Create( r, a ))
	End Method
	
	Method x#()
		Return (r * Cos( a ))
	End Method
	Method y#()
		Return (r * Sin( a ))
	End Method
End Type

