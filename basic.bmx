Rem
	basic.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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

Function avg#( a#, b# )
	Return (a + b)/2.0
End Function

Function boolean_to_string$( b% )
	If b = True
		Return "true"
	Else 'b = false
		Return "false"
	End If
End Function

Function string_to_boolean%( str$ )
	Select str
		Case "true"
			Return 1
		Case "false"
			Return 0
		Case "yes"
			Return 1
		Case "no"
			Return 0
		Case "on"
			Return 1
		Case "off"
			Return 0
		Case "enabled"
			Return 1
		Case "disabled"
			Return 0
		Default
			Return str.ToInt()
	End Select
End Function

Function address%( obj:Object )
	If obj <> Null
		Return Int( Byte Ptr( obj ))
	Else
		Return 0
	End If
End Function

Function encode_ARGB%( alpha#, red%, green%, blue% )
	Local argb% = 0
	argb :+ blue Shl 0
	argb :+ green Shl 8
	argb :+ red Shl 16
	argb :+ Int(alpha*255) Shl 24
	Return argb
End Function
'______________________________________________________________________________
Function time_alpha_pct#( ts%, time%, in% = True )
	If in 'fade in
		If (now() - ts) <= time
			Return (Float(now() - ts) / Float(time))
		Else
			Return 1.0
		End If
	Else 'fade out
		If (now() - ts) <= time
			Return (1.0 - (Float(now() - ts) / Float(time)))
		Else
			Return 0.0
		End If
	End If
End Function

'______________________________________________________________________________
Type MANAGED_OBJECT
	
	Field name$ 'name of this object
	Field id% 'unique identification number
	Field link:TLink 'back-reference to the list which contains this object
	
	Method New()
		id = get_new_id()
	End Method
	
	Method managed%()
		Return (link <> Null)
	End Method
	
	Method manage( list:TList )
		link = ( list.AddLast( Self ))
	End Method
	
	Method unmanage()
		If link <> Null
			link.Remove()
			link = Null
		End If
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
'Function combine_lists:TList( list1:TList, list2:TList )
'	Local newlist:TList = list1.Copy()
'	For Local obj:Object = EachIn list2
'		list1.AddLast( obj )
'	Next
'	Return newlist
'End Function

Function remove_from_Int_array:Int[]( arr%[], i% )
	
End Function

Function insert_into_Int_array:Int[]( arr%[], i%, val% )
	
End Function

'______________________________________________________________________________
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

Function Copy_POINT:POINT( other:POINT )
	Return Create_POINT( ..
		other.pos_x, other.pos_y, ..
		other.ang, ..
		other.vel_x, other.vel_y, ..
		other.ang_vel, ..
		other.acc_x, other.acc_y, ..
		other.ang_acc )
End Function
'__________________________________
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
		ang = ang_wrap( ang + ang_vel )
	End Method
	
	Method dist_to#( other:POINT )
		Return Sqr( Pow(other.pos_x-pos_x,2) + Pow(other.pos_y-pos_y,2) )
	End Method
	Method dist_to_cVEC#( other:cVEC )
		Return Sqr( Pow(other.x-pos_x,2) + Pow(other.y-pos_y,2) )
	End Method
	
	Method ang_to#( other:POINT )
		Return ATan2( other.pos_y-pos_y, other.pos_x-pos_x )
	End Method
	Method ang_to_cVEC#( other:cVEC )
		Return ATan2( other.y-pos_y, other.x-pos_x )
	End Method
	
	Method add_pos:POINT( delta_pos_x#, delta_pos_y# )
		Local p:POINT = Copy_POINT( Self )
		p.pos_x :+ delta_pos_x; p.pos_y :+ delta_pos_y
		Return p
	End Method
	
	Method to_json:TJSONObject()
		Local this_json:TJSONObject = New TJSONObject
		this_json.SetByName( "pos_x", TJSONNumber.Create( pos_x ))
		this_json.SetByName( "pos_y", TJSONNumber.Create( pos_y ))
		this_json.SetByName( "ang", TJSONNumber.Create( ang ))
		this_json.SetByName( "vel_x", TJSONNumber.Create( vel_x ))
		this_json.SetByName( "vel_y", TJSONNumber.Create( vel_y ))
		this_json.SetByName( "ang_vel", TJSONNumber.Create( ang_vel ))
		this_json.SetByName( "acc_x", TJSONNumber.Create( acc_x ))
		this_json.SetByName( "acc_y", TJSONNumber.Create( acc_y ))
		this_json.SetByName( "ang_acc", TJSONNumber.Create( ang_acc ))
		Return this_json
	End Method
	
End Type

Function Create_POINT_from_json:POINT( json:TJSON )
	Local p:POINT = New POINT
	p.pos_x = json.GetNumber( "pos_x" )
	p.pos_y = json.GetNumber( "pos_y" )
	p.ang = json.GetNumber( "ang" )
	p.vel_x = json.GetNumber( "vel_x" )
	p.vel_y = json.GetNumber( "vel_y" )
	p.ang_vel = json.GetNumber( "ang_vel" )
	p.acc_x = json.GetNumber( "acc_x" )
	p.acc_y = json.GetNumber( "acc_y" )
	p.ang_acc = json.GetNumber( "ang_acc" )
	Return p
End Function

'______________________________________________________________________________
'vector & angle functions
Function ang_wrap#( a# ) 'forces the angle into the range [-180,180]
	If a < -180
		Local mult% = Abs( (a-180) / 360 )
		a :+ mult * 360
	Else If a > 180
		Local mult% = Abs( (a+180) / 360 )
		a :- mult * 360
	End If
	Return a
End Function

Function vector_length#( vx#, vy# )
	Return Sqr( Pow(vx,2) + Pow(vy,2) )
End Function

Function vector_angle#( vx#, vy# )
	Return ATan2( vy, vx )
End Function

Function vector_diff_length#( ax#, ay#, bx#, by# ) 'distance /a/ and /b/
	Local dx# = bx - ax, dy# = by - ay
	Return Sqr( Pow(dx,2) + Pow(dy,2) )
End Function

Function vector_diff_angle#( ax#, ay#, bx#, by# ) 'angle of line connecting /a/ to /b/
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
'______________________________________________________________________________
Function round_to_nearest#( x#, interval# )
	If (x Mod interval) < (interval / 2.0)
		Return (Int(x / interval) * interval)
	Else
		Return (Int(1 + x / interval) * interval)
	End If
End Function
'______________________________________________________________________________
Function line_intersects_line%( v1:cVEC, v2:cVEC, v3:cVEC, v4:cVEC )
	Local denom# = ((v4.y-v3.y)*(v2.x-v1.x))-((v4.x-v3.x)*(v2.y-v1.y))
	Local num# =   ((v4.x-v3.x)*(v1.y-v3.y))-((v4.y-v3.y)*(v1.x-v3.x))
	Local num2# =  ((v2.x-v1.x)*(v1.y-v3.y))-((v2.y-v1.y)*(v1.x-v3.x))
	If denom = 0.0
		Return False 'coincident or parallel (no intersection possible)
	End If
	
	Local ua# = num/denom
	Local ub# = num2/denom
	Return (ua >= 0.0 And ua <= 1.0) And (ub >= 0.0 And ub <= 1.0)
End Function
'______________________________________________________________________________
Function line_intersects_rect%( v1:cVEC, v2:cVEC, r:cVEC, r_dim:cVEC )
	Local lower_left:cVEC = cVEC( cVEC.Create( r.x, r.y+r_dim.y ))
	Local upper_right:cVEC = cVEC( cVEC.Create( r.x+r_dim.x, r.y ))
	Local upper_left:cVEC = cVEC( cVEC.Create( r.x, r.y ))
	Local lower_right:cVEC = cVEC( cVEC.Create( r.x+r_dim.x, r.y+r_dim.y ))
	
	'is line completely encased by rect? 
	Rem (will never happen in my game)
	If  (v1.x > lower_left.x And v1.x < upper_right.x) And (v1.y < lower_left.y And v1.y > upper_right.y) ..
	And (v2.x > lower_left.x And v2.x < upper_right.x) And (v2.y < lower_left.y And v2.y > upper_right.y)
		Return True
	End If
	EndRem
	
	'line intersects one of the lines making up the rectangle's borders
	If line_intersects_line( v1,v2, upper_left,lower_left ) ..
	Or line_intersects_line( v1,v2, lower_left,lower_right ) ..
	Or line_intersects_line( v1,v2, upper_left,upper_right ) ..
	Or line_intersects_line( v1,v2, upper_right,lower_right )
		Return True
	Else
		Return False
	End If
End Function
'______________________________________________________________________________
Function Create_BOX:BOX( x#, y#, w#, h# )
	Local b:BOX = New BOX
	b.x = x; b.y = y
	b.w = w; b.h = h
	Return b
End Function

Type BOX
	Field x#, y# 'position components
	Field w#, h# 'dimension components
	Method clone:BOX()
		Return Create_BOX( x, y, w, h )
	End Method
End Type

'______________________________________________________________________________
Function Create_cVEC:cVEC( x#, y# )
	Local v:cVEC = New cVEC
	v.x = x; v.y = y
	Return v
End Function

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
Function Create_pVEC:pVEC( r#, a# )
	Local v:pVEC = New pVEC
	v.r = r; v.a = a
	Return v
End Function

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

'______________________________________________________________________________
Const RANGE_DISTRIBUTION_FLAT% = 0
Const RANGE_DISTRIBUTION_LINEAR% = 1
Const RANGE_DISTRIBUTION_QUADRATIC% = 2
Const RANGE_DISTRIBUTION_ROOT% = 3
Const RANGE_DISTRIBUTION_EXPONENTIAL% = 4
Const RANGE_DISTRIBUTION_LOGARITHMIC% = 5
Const RANGE_DISTRIBUTION_INVERSE% = 6

Type RANGE
	Field low#, high# 'absolute min and max of any returned value
	Field low_eq_high% '{true|false}
	'Field distribution_type% '{flat|linear|quadratic|root|exponential|logarithmic|inverse}
	'Field coefficients#[] 'distribution function coefficients
	
	Method New()
		'coefficients = new Float[5]
	End Method
	
	Function Create:RANGE( low#, high# )
		Local r:RANGE = New RANGE
		r.low = low; r.high = high
		If low = high Then r.low_eq_high = True
		Return r
	End Function
	Method clone:RANGE()
		Return RANGE.Create( low, high )
	End Method

	Method set( new_low#, new_high# )
		low = new_low; high = new_high
		If low = high Then low_eq_high = True
	End Method

	Method get#()
		If low_eq_high
			Return low
		Else
			Return RandF( low, high )
		End If
	End Method
End Type
'______________________________________________________________________________
Type RANGE_Int
	Field low%, high%
	Field low_eq_high% '{true|false}
	
	Method New()
	End Method

	Function Create:RANGE_Int( low%, high% )
		Local r:RANGE_Int = New RANGE_Int
		r.low = low; r.high = high
		If low = high Then r.low_eq_high = True
		Return r
	End Function
	Method clone:RANGE_Int()
		Return RANGE_Int.Create( low, high )
	End Method

	Method set( new_low%, new_high% )
		low = new_low; high = new_high
		If low = high Then low_eq_high = True ..
		Else               low_eq_high = False
	End Method

	Method get%()
		If low_eq_high
			Return low
		Else
			Return Rand( low, high )
		End If
	End Method
End Type

'______________________________________________________________________________
Type CELL
	Global MAXIMUM_COST% = 2147483647
	Global COORDINATE_INVALID% = -1
	Global DIRECTION_NORTH% = 0
	Global DIRECTION_NORTHEAST% = 1
	Global DIRECTION_EAST% = 2
	Global DIRECTION_SOUTHEAST% = 3
	Global DIRECTION_SOUTH% = 4
	Global DIRECTION_SOUTHWEST% = 5
	Global DIRECTION_WEST% = 6
	Global DIRECTION_NORTHWEST% = 7
	Global ALL_DIRECTIONS%[] = [ DIRECTION_NORTH, DIRECTION_NORTHEAST, DIRECTION_EAST, DIRECTION_SOUTHEAST, DIRECTION_SOUTH, DIRECTION_SOUTHWEST, DIRECTION_WEST, DIRECTION_NORTHWEST ]
	
	Field row%
	Field col%
	Method New()
	End Method
	
	Function Create:CELL( row%, col% )
		Local c:CELL = New CELL
		c.row = row; c.col = col
		Return c
	End Function
	
	Function Create_INVALID:CELL()
		Return Create( COORDINATE_INVALID, COORDINATE_INVALID )
	End Function
	
	Method copy( other:CELL )
		row = other.row; col = other.col
	End Method
	
	Method clone:CELL()
		Return CELL.Create( row, col )
	End Method
	
	Method is_valid%()
		Return (row <> COORDINATE_INVALID And col <> COORDINATE_INVALID)
	End Method
	
	Method set( new_row%, new_col% )
		row = new_row; col = new_col
	End Method
	
	Method eq%( other:CELL )
		If row = other.row And col = other.col ..
		Then Return True Else Return False
	End Method
	
	Method add_assign( other:CELL )
		row :+ other.row; col :+ other.col
	End Method
	
	Method add:CELL( other:CELL )
		Return CELL.Create( row + other.row, col + other.col )
	End Method
	
	Method move_assign( dir% )
		Select dir
			Case DIRECTION_NORTH
				row :- 1
			Case DIRECTION_NORTHEAST
				row :- 1; col :+ 1
			Case DIRECTION_EAST
				          col :+ 1
			Case DIRECTION_SOUTHEAST
				row :+ 1; col :+ 1
			Case DIRECTION_SOUTH
				row :+ 1
			Case DIRECTION_SOUTHWEST
				row :+ 1; col :- 1
			Case DIRECTION_WEST
				          col :+ 1
			Case DIRECTION_NORTHWEST
				row :- 1; col :- 1
		End Select
	End Method
	
	Method move:CELL( dir% )
		Local c:CELL = clone()
		c.move_assign( dir )
		Return c
	End Method
	
End Type
