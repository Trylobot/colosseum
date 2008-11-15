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
	
	Function Create:pVEC( r#, a# )
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

