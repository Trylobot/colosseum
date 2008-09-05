Rem
	color.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type TColor
	Global RED% = 1
	Global GREEN% = 2
	Global BLUE% = 3
	Global HUE% = 1
	Global SATURATION% = 2
	Global LUMINANCE% = 3
	
	Field R%, G%, B%
	Field H!, S!, L!
	
	'( H [0.0,360.0] ), ( S,L [0.0,1.0] )
	Function Create_by_HSL:TColor( H!, S!, L! )
		Local c:TColor = New TColor
		c.H = H
		c.S = S
		c.L = L
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
			Local nH!, nH_int%, nH_part!
			nH = H / 60.0
			nH_int = Floor( nH )
			nH_part = nH - nH_int
			Local e_temp!, f_temp!, g_temp!
			e_temp = L * (1.0 - S)
			f_temp = L * (1.0 - (S * nH_part))
			g_temp = L * (1.0 - (S * (1.0 - nH_part)))
			Select nH_int
				Case 0
					nR = L
					nG = g_temp
					nB = e_temp
				Case 1
					nR = f_temp
					nG = L
					nB = e_temp
				Case 2
					nR = e_temp
					nG = L
					nB = g_temp
				Case 3
					nR = e_temp
					nG = f_temp
					nB = L
				Case 4
					nR = g_temp
					nG = e_temp
					nB = L
				Case 5
					nR = L
					nG = e_temp
					nB = f_temp
				Default 'not supposed to happen
					nR = 0
					nG = 0
					nB = 0
			End Select
		End If
		R = nR * 255
		G = nG * 255
		B = nB * 255
	End Method
	
	'( R,G,B [0,255] )
	Function Create_by_RGB:TColor( R%, G%, B% )
		Local c:TColor = New TColor
		c.R = R
		c.G = G
		c.B = B
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
		If nB > max_component_value
			max_component = BLUE
			max_component_value = nB
		Else If nB < min_component_value
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

