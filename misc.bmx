Rem
	misc.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
'constants
Const INFINITY% = -1
Const UNSPECIFIED% = -1

'random
SeedRnd MilliSecs()
'clock
Function now%()
	Return MilliSecs()
End Function

Function Pow#( x#, p% )
	For Local i% = 1 To p - 1
		x :* x
	Next
	Return x
End Function

Function ints_to_floats:Float[]( arr%[] )
	Local f#[] = New Float[arr.Length]
	For Local i% = 0 To arr.Length
		f[i] = Float( arr[i] )
	Next
	Return f
End Function

Function average#( n#[] ) 'returns the average value of a given list of numbers
	If n <> Null And n.Length > 0
		Local sum# = 0
		For Local i% = 0 To n.Length-1
			sum :+ n[i]
		Next
		Return (sum / Double(n.Length))
	Else
		Return 0.0
	End If
End Function

Function maximum%( n#[] ) 'returns the index of the maximum value of a given list of numbers
	If n <> Null And n.Length > 0
		Local max_i% = 0
		Local max_val# = n[0]
		If n.Length > 1
			For Local i% = 1 To n.length-1
				If n[i] > max_val
					max_i = i
					max_val = n[i]
				End If
			Next
		End If
		Return max_i
	Else
		Return 0
	End If
End Function

Function minimum%( n#[] ) 'returns the index of the minimum value of a given list of numbers
	If n <> Null And n.Length > 0
		Local min_i% = 0
		Local min_val# = n[0]
		If n.Length > 1
			For Local i% = 1 To n.length-1
				If n[i] < min_val
					min_i = i
					min_val = n[i]
				End If
			Next
		End If
		Return min_i
	Else
		Return 0
	End If
End Function

Function one_of%( x%, arr%[] )
	If arr.Length = 0 Then Return False
	For Local i% = EachIn arr
		If x = i Then Return True
	Next
	Return False
End Function

Function contained_in%( x$, arr$[] )
	If arr.Length = 0 Then Return False
	For Local i$ = EachIn arr
		If x = i Then Return True
	Next
	Return False
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

Function format_number$( n% )
	Local n_str$ = String.FromInt( n )
	If n_str.Length <= 3 Then Return n_str
	Local f_str$ = ""
	For Local index% = 0 To n_str.Length-1
		If index > 0 And index Mod 3 = 0
			f_str = "," + f_str
		End If
		f_str = Chr(n_str[n_str.Length-1-index]) + f_str
	Next
	Return f_str
End Function

Function str_repeat$( str$, count% )
	Local result$ = str[..]
	For Local i% = 0 To count - 1
		result :+ str
	Next
	Return result
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
Function time_alpha_pct#( ts%, time%, in% = True ) 'either fading IN or OUT
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
Function pad$( str$, width%, pad$ = " ", align_right% = True )
	While str.Length < width
		If align_right
			str = pad + str
		Else 'align left
			str = str + pad
		End If
	EndWhile
	Return str
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

Type INTEGER
	Field value%
	Function Create:INTEGER( value% )
		Local i:INTEGER = New INTEGER; i.value = value;	Return i
	End Function
End Type
