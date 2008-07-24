Rem
	force.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Type FORCE Extends MANAGED_OBJECT
	
	Field offset# 'offset distance from center of mass for object being acted upon
	Field offset_ang# 'offset angle from center of mass for object being acted upon
	Field magnitude# 'strength of force
	Field direction# 'direction force is pointing
	Field life_time% 'time the force should be active (can be infinite)
	Field created_ts% '(private) timestamp of force creation
	
	Method New()
	End Method
	
	Method dead%()
		Return ..
			life_time = INFINITY Or ..
			(now() - created_ts) > life_time
	End Method
	
	Method prune()
		If dead()
			remove_me()
		End If
	End Method
	
End Type
'______________________________________________________________________________
Function Create_FORCE:FORCE( ..
offset#, ..
offset_ang#, ..
magnitude#, ..
direction#, ..
life_time% = INFINITY )
	Local f:FORCE = New FORCE
	
	f.offset = offset
	f.offset_ang = offset_ang
	f.magnitude = magnitude
	f.direction = direction
	f.life_time = life_time
	f.created_ts = now()
	
	Return f
End Function

