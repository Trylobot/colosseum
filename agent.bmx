Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type AGENT Extends POINT
	
	Field img:TImage 'image to be drawn
	Field max_health# 'maximum health
	Field mass# 'mass of agent
	Field cash_value% 'cash to be awarded player on this agent's death

	Field cur_health# 'current health
	
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
		ang = ang Mod 360
	End Method
	
	Method dead%()
		Return (cur_health <= 0)
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no overkill
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
