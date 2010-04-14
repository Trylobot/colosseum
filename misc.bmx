Rem
	misc.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import brl.Random
'Import brl.Map

'______________________________________________________________________________
SeedRnd MilliSecs()

'rudimentary constants
Const INFINITY% = -1
Const UNSPECIFIED% = -1

Function now%()
	Return MilliSecs()
End Function

'______________________________________________________________________________
Function FileExists%( path$ )
  Return FileType( path ) = FILETYPE_FILE
End Function

Function DirExists%( path$ )
  Return FileType( path ) = FILETYPE_DIR
End Function

'______________________________________________________________________________
Function find_files:TList( path$, ext$ = "", list:TList = Null )
	If Not list Then list = CreateList()
	For Local entry$ = EachIn LoadDir( path, True )
		If entry = ".svn" Then Continue 'source control
		Local entry_full$ = pcat([ path, entry ])
		Select FileType( entry_full )
			Case FILETYPE_FILE
				If ext = "" Or ExtractExt( entry_full ) = ext
					list.AddLast( entry_full )
				End If
			Case FILETYPE_DIR
				find_files( entry_full, ext, list )
		End Select
	Next
	Return list
End Function

Function pcat$( str$[] )
	Local result$ = ""
	Local first% = True
	For Local s$ = EachIn str
		If first
			first = False
		Else
			result :+ "/"
		End If
		result :+ s
	Next
	Return result.Replace( "//", "/" ).Replace( "\\", "\" )
End Function

'______________________________________________________________________________
Function Pow#( x#, p% )
	For Local i% = 1 To p - 1
		x :* x
	Next
	Return x
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

'______________________________________________________________________________
Function contained_in%( x$, arr$[] )
	If arr.Length = 0 Then Return False
	For Local i$ = EachIn arr
		If x = i Then Return True
	Next
	Return False
End Function

Function boolean_to_string$( b% )
	If b
		Return "true"
	Else
		Return "false"
	End If
End Function

Function string_to_boolean%( str$ )
	Select str
		Case "true"
			Return 1
		Case "false"
			Return 0
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

Function reverse_string$( str$ )
	Local rev$ = ""
	For Local i% = 0 Until str.Length
		rev :+ str[str.Length - 1 - i..str.Length - 1 - i + 1]
	Next
	Return rev
End Function

Function line_count%( multi_line_str$ )
	Return multi_line_str.Split( "~n" ).Length
End Function

'______________________________________________________________________________
Function array_append%[]( src%[], value% )
	If src
		Return insert_into_array( value, src, (src.Length - 1) )
	Else
		Return [ value ]
	End If
End Function

Function insert_into_array%[]( value%, src%[], insert_after% ) 'inserts immediately after index
	Local arr%[] = New Int[src.Length+1]
	'left of index (including index)
	If insert_after > -1
		copy_into( src[..insert_after+1], arr, 0 )
	End If
	'just after index
	arr[insert_after+1] = value
	'right of index
	If insert_after < src.Length - 1
		copy_into( src[insert_after+1..], arr, insert_after+2 )
	End If
	Return arr
End Function

Function remove_from_array%[]( src%[], index% )
	Local arr%[] = New Int[src.Length-1]
	'left of index
	If index > 0
		copy_into( src[..index], arr, 0 )
	End If
	'right of index
	If index < src.Length-1
		copy_into( src[index+1..], arr, index )
	End If
	Return arr
End Function

Function set_range( value%, start_index%, count%, arr%[] )
	For Local i% = start_index Until (start_index + count)
		arr[i] = value
	Next
End Function

Function copy_into( src%[], dest%[], start_at% )
	For Local i% = 0 Until src.Length
		dest[start_at+i] = src[i]
	Next
End Function

Function ints_to_floats:Float[]( arr%[] )
	Local f#[] = New Float[arr.Length]
	For Local i% = 0 To arr.Length
		f[i] = Float( arr[i] )
	Next
	Return f
End Function

Function address%( obj:Object )
	If obj <> Null
		Return Int( Byte Ptr( obj ))
	Else
		Return 0
	End If
End Function

'______________________________________________________________________________
Function get_map_keys$[]( map:TMap )
	Local list:TList = CreateList()
	For Local str$ = EachIn MapKeys( map )
		list.AddLast( str )
	Next
	Return list_to_string_array( list )
End Function

Function get_map_values$[]( map:TMap )
	Local list:TList = CreateList()
	For Local str$ = EachIn MapValues( map )
		list.AddLast( str )
	Next
	Return list_to_string_array( list )
End Function

Function list_to_string_array:String[]( L:TList )
	Local arr:Object[] = ListToArray( L )
	Local str:String[] = New String[ arr.length ]
	For Local i% = 0 Until str.length
		str[i] = String( arr[i] )
	Next
	Return str
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

Function enforce_suffix$( str$, suffix$ )
	Return str + suffix
End Function

'______________________________________________________________________________
'misc/silly types
Type INTEGER
	Field value%
	Function Create:INTEGER( value% )
		Local i:INTEGER = New INTEGER; i.value = value;	Return i
	End Function
End Type

