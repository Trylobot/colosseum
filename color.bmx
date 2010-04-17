Rem
	color.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
Type TColor
	Const RED% = 1
	Const GREEN% = 2
	Const BLUE% = 3
	
	Const HUE% = 1
	Const SATURATION% = 2
	Const LUMINANCE% = 3
	
	Field R%, G%, B%
	Field H#, S#, L#
  
  Method Set()
    SetColor( R, G, B )
  End Method
	
	'( H [0.0,360.0] ), ( S,L [0.0,1.0] )
	Function Create_by_HSL:TColor( H#, S#, L#, auto_calc_RGB% = False )
		Local c:TColor = New TColor
		c.H = H
		c.S = S
		c.L = L
		If auto_calc_RGB Then c.calc_RGB()
		Return c
	End Function
	
	Method calc_RGB()
		Local nR#
		Local nG#
		Local nB#
		If S = 0.0
			nR = L
			nG = L
			nB = L
		Else 'S <> 0.0
			Local nH#, nH_int%, nH_part#
			nH = H / 60.0
			nH_int = Floor( nH )
			nH_part = nH - nH_int
			Local e_temp#, f_temp#, g_temp#
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
	Function Create_by_RGB:TColor( R%, G%, B%, auto_calc_HSL% = False )
		Local c:TColor = New TColor
		c.R = R
		c.G = G
		c.B = B
		If auto_calc_HSL Then c.calc_HSL()
		Return c
	End Function
	
	Function Create_by_RGB_object:TColor( obj:Object )
		If Int[](obj)
			Local RGB%[] = Int[](obj)
			If RGB.Length = 3
				Return Create_by_RGB( RGB[0], RGB[1], RGB[2], False )
			Else
				Return Null
			End If
		Else If TColor(obj)
			Return TColor(obj)
		Else
			Return Null
		End If
	End Function
	
	Method calc_HSL()
		Local nR# = R / 255.0
		Local nG# = G / 255.0
		Local nB# = B / 255.0
		Local max_component%
		Local max_component_value#
		Local min_component_value#
		Local delta#
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
	
	Method clone:TColor()
		Local c:TColor = New TColor
		c.R = R; c.G = G; c.B = B
		c.H = H; c.S = S; c.L = L
		Return c
	End Method
	
End Type

Function encode_ARGB%( alpha#, red%, green%, blue% )
	Return (blue)|(green Shl 8)|(red Shl 16)|(Int(alpha*255) Shl 24)
End Function

Const MASK_ALPHA% = 2 Shl 31 + 2 Shl 30 + 2 Shl 29 + 2 Shl 28 + 2 Shl 27 + 2 Shl 26 + 2 Shl 25 + 2 Shl 24
Const MASK_RED%   = 2 Shl 23 + 2 Shl 22 + 2 Shl 21 + 2 Shl 20 + 2 Shl 19 + 2 Shl 18 + 2 Shl 17 + 2 Shl 16
Const MASK_GREEN% = 2 Shl 15 + 2 Shl 14 + 2 Shl 13 + 2 Shl 12 + 2 Shl 11 + 2 Shl 10 + 2 Shl 9  + 2 Shl 8 
Const MASK_BLUE%  = 2 Shl 7  + 2 Shl 6  + 2 Shl 5  + 2 Shl 4  + 2 Shl 3  + 2 Shl 2  + 2 Shl 1  + 2 Shl 0 

Function decode_ARGB( argb%, alpha# Var, red% Var, green% Var, blue% Var )
	alpha = Float(argb Shr 24)/255.0
	red   = (argb & MASK_RED) Shr 16
	green = (argb & MASK_GREEN) Shr 8
	blue  = (argb & MASK_BLUE)
End Function

