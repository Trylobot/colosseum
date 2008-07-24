Rem
	force.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const PHYSICS_FORCE% = 0
Const PHYSICS_TORQUE% = 1

Type FORCE Extends MANAGED_OBJECT

	Field physics_type% '(torque/force)?
	Field direction# 'direction force is pointing
	Field magnitude_max# 'maximum strength of force
	Field life_time% 'time the force should be active (can be infinite)
	
	Field control_pct# 'magnitude multiplier; force therefore yields between [-magnitude,magnitude]
	Field magnitude_cur# 'current net magnitude
	Field created_ts% '(private) timestamp of force creation (for auto-pruning)
	
	Method New()
	End Method
	
	Method update()
		If dead()
			remove_me()
		End If
		magnitude_cur = control_pct*magnitude_max
	End Method
	
	Method dead%()
		Return ..
			life_time <> INFINITY And ..
			(now() - created_ts) > life_time
	End Method
	
End Type
'______________________________________________________________________________
Function Create_FORCE:FORCE( ..
physics_type%, ..
direction#, ..
magnitude_max#, ..
life_time% = INFINITY )
	Local f:FORCE = New FORCE
	
	f.physics_type = physics_type
	f.direction = direction
	f.magnitude_max = magnitude_max
	f.life_time = life_time
	
	f.control_pct = 1.0
	f.created_ts = now()
	f.update()
	
	Return f
End Function
'______________________________________________________________________________
Function Copy_FORCE:FORCE( other:FORCE, managed_list:TList )
	Local f:FORCE = New FORCE
	
	f.physics_type = other.physics_type
	f.direction = other.direction
	f.magnitude_max = other.magnitude_max
	f.life_time = other.life_time
	
	f.control_pct = 1.0
	f.created_ts = now()
	f.update()
	
	f.add_me( managed_list )
	Return f
End Function
