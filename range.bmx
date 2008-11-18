Rem
	range.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type RANGE
	Global RANGE_DISTRIBUTION_FLAT% = 0
	Global RANGE_DISTRIBUTION_LINEAR% = 1
	Global RANGE_DISTRIBUTION_QUADRATIC% = 2
	Global RANGE_DISTRIBUTION_ROOT% = 3
	Global RANGE_DISTRIBUTION_EXPONENTIAL% = 4
	Global RANGE_DISTRIBUTION_LOGARITHMIC% = 5
	Global RANGE_DISTRIBUTION_INVERSE% = 6

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
			Return Rnd( low, high )
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
