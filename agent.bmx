Rem
	agent.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type AGENT Extends PHYSICAL_OBJECT
	
	Field img:TImage 'image to be drawn
	Field max_health# 'maximum health
	Field cash_value% 'cash to be awarded player on this agent's death

	Field cur_health# 'current health
	
	Method New()
		force_list = CreateList()
	End Method
	
	Method draw()
		SetRotation( ang )
		DrawImage( img, pos_x, pos_y )
	End Method
	
	Method dead%()
		Return (cur_health <= 0)
	End Method
	
	Method receive_damage( damage# )
		cur_health :- damage
		If cur_health < 0 Then cur_health = 0 'no overkill
	End Method

End Type
