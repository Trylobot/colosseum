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

	'Acceleration 
	Field acc_x#
	Field acc_y#
	'Angular Velocity 
	Field ang_vel#
	'Angular Acceleration
	Field ang_acc#
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
		'wrap at physical boundaries
		If pos_x > arena_w Then pos_x :- arena_w
		If pos_x < 0       Then pos_x :+ arena_w
		If pos_y > arena_h Then pos_y :- arena_h
		If pos_y < 0       Then pos_y :+ arena_h
		'update angles
		ang :+ ang_vel
		If ang >= 360 Then ang :- 360
		If ang <  0   Then ang :+ 360
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no "overkill"
		If cur_health = 0 
			remove_me()
		End If
	End Method

End Type
'______________________________________________________________________________
Function Archetype_AGENT:AGENT( ..
img:TImage, ..
max_health#, ..
mass# )
	Local a:AGENT = New AGENT
	
	'static fields
	a.img = img
	a.max_health = max_health
	a.mass = mass
	
	'dynamic fields
	a.cur_health = max_health
		
	Return a
End Function
'______________________________________________________________________________
Function Copy_AGENT:AGENT( other:AGENT )
	Local a:AGENT = New AGENT
	
	'static fields
	a.img = other.img
	a.max_health = other.max_health
	a.mass = other.mass
	
	'dynamic fields
	a.cur_health = other.max_health
		
	Return a
End Function
