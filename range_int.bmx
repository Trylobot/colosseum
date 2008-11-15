Rem
	range_int.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

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
