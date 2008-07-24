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
Function Create_AGENT:AGENT() 'more arguments?
	Local new_entity:AGENT = New AGENT
	'initializers?
	Return new_entity
End Function

