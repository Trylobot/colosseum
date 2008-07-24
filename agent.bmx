Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type AGENT Extends POINT
	
	'Images
	Field img:TImage
	'Health
	Field max_health#
	'Mass
	Field mass#
	'Cash
	Field cash_value%

	'Health
	Field cur_health#
	
	Method New()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method update()
		'update positions
		pos_x :+ vel_x
		pos_y :+ vel_y
		'update angles
		ang :+ ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
	End Method
	
	Method receive_damage%( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no "overkill"
		If cur_health = 0 
			remove_me()
			Return True
		End If
		Return False
	End Method

End Type
''______________________________________________________________________________
'Function Archetype_AGENT:AGENT( ..
'img:TImage, ..
'max_health#, ..
'mass#, ..
'cash_value% )
'	Local a:AGENT = New AGENT
'	
'	'static fields
'	a.img = img
'	a.max_health = max_health
'	a.mass = mass
'	a.cash_value = cash_value
'	
'	'dynamic fields
'	a.cur_health = max_health
'		
'	Return a
'End Function
''______________________________________________________________________________
'Function Copy_AGENT:AGENT( other:AGENT )
'	Local a:AGENT = New AGENT
'	
'	'static fields
'	a.img = other.img
'	a.max_health = other.max_health
'	a.mass = other.mass
'	a.cash_value = other.cash_value
'	
'	'dynamic fields
'	a.cur_health = other.max_health
'		
'	Return a
'End Function
