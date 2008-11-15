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
