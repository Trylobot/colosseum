Rem
	range.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type RANGE
	Field low#, high#
	Field low_eq_high%
	
	Function Create:RANGE( low#, high# )
		Local r:RANGE = New RANGE
		r.set( low, high )
		Return r
	End Function
	
	Method clone:RANGE()
		Return RANGE.Create( low, high )
	End Method

	Method set( new_low#, new_high# )
		low = new_low
		high = new_high
		If new_low = new_high 'range with zero width
			low_eq_high = True
		Else 'new_low <> new_high
			low_eq_high = False
			If new_low > new_high 'reversed constraints
				low = new_high
				high = new_low
			End If
		End If
	End Method

	Method get#()
		If Not low_eq_high
			Return Rnd( low, high )
		Else
			Return low
		End If
	End Method
	
End Type

'______________________________________________________________________________
Type RANGE_Int
	Field low%, high%
	Field low_eq_high% 

	Function Create:RANGE_Int( low%, high% )
		Local r:RANGE_Int = New RANGE_Int
		r.set( low, high )
		Return r
	End Function
	
	Method clone:RANGE_Int()
		Return RANGE_Int.Create( low, high )
	End Method

	Method set( new_low%, new_high% )
		low = new_low
		high = new_high
		If new_low = new_high 'range with zero width
			low_eq_high = True
		Else 'new_low <> new_high
			low_eq_high = False
			If new_low > new_high 'reversed constraints
				low = new_high
				high = new_low
			End If
		End If
	End Method

	Method get%()
		If Not low_eq_high
			Return Rand( low, high )
		Else
			Return low
		End If
	End Method
	
End Type
