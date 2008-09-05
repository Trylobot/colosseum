Rem
	color.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type COLOR
	Global RED% = 1
	Global GREEN% = 2
	Global BLUE% = 3
	Global HUE% = 1
	Global SATURATION% = 2
	Global LUMINANCE% = 3
	
	Field R%, G%, B%
	Field H!, S!, L!
	
	Function Create_HSL:COLOR( H!, S!, L! ) '( H [0.0,360.0] ), ( S,L [0.0,1.0] )
		Local c:COLOR = New COLOR
		c.H = H
		c.S = S
		c.L = L
		c.calc_RGB()
		Return c
	End Function
	
	Method calc_RGB()
		Local nR!
		Local nG!
		Local nB!
		If S = 0.0
			nR = L
			nG = L
			nB = L
		Else 'S <> 0.0
			If L < 0.500
				
			Else 'L >= 0.500
				
			End If
		End If
	End Method
	
	Function Create_RGB:COLOR( R%, G%, B% ) '( R,G,B [0,255] )
		Local c:COLOR = New COLOR
		c.R = R
		c.G = G
		c.B = B
		c.calc_HSL()
		Return c
	End Function
	
	Method calc_HSL()
		Local nR! = R / 255.0
		Local nG! = G / 255.0
		Local nB! = B / 255.0
		Local max_component%
		Local max_component_value!
		Local min_component_value!
		Local delta!
		If nR > nG
			max_component = RED
			max_component_value = nR
			min_component_value = nG
		Else 'nR <= nG
			max_component = GREEN
			max_component_value = nG
			min_component_value = nR
		End If
		If nB > max_value
			max_component = BLUE
			max_component_value = nB
		Else If nB < min_value
			min_component_value = nB
		End If
		L = (max_component_value + min_component_value) / 2.0
		If max_component_value = min_component_value
			S = 0
		Else 'max_component_value <> min_component_value
			delta = max_component_value - min_component_value
			If L < 0.500
				S = delta / (max_component_value + min_component_value)
			Else
				S = delta / (2.0 - delta)
			End If
			Select max_component
				Case RED
					H = 0.0 + (nG - nB) / delta
				Case GREEN
					H = 2.0 + (nB - nR) / delta
				Case BLUE
					H = 4.0 + (nR - nG) / delta
			End Select
			H :* 60.0
			If H < 0.0 Then H :+ 360.0
		End If
	End Method
	
End Type

