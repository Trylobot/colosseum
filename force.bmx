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
	Field parent:PHYSICAL_OBJECT 'for forces, parent object this force is attached to
	Field combine_ang_with_parent_ang% 'for forces, indicates whether the direction of the force is absolute
	Field direction# 'direction force is pointing
	Field magnitude_max# 'maximum strength of force
	Field life_time% 'time the force should be active (can be infinite)
	
	Field control_pct# 'magnitude multiplier; force therefore yields between [-magnitude,magnitude]
	Field magnitude_cur# 'current net magnitude
	Field created_ts% '(private) timestamp of force creation (for auto-pruning)
	
	Method New()
	End Method
	
	Function Create:Object( ..
	physics_type%, ..
	direction# = 0.0, ..
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
	
	Function Copy:Object( other:FORCE, managed_list:TList )
		Local f:FORCE = New FORCE
		
		f.physics_type = other.physics_type
		f.direction = other.direction
		f.magnitude_max = other.magnitude_max
		f.life_time = other.life_time
		
		f.control_pct = 1.0
		f.created_ts = now()
		f.update()
		
		f.manage( managed_list )
		Return f
	End Function

	Method update()
		If dead() Then unmanage()
		If      control_pct > 1.0  Then control_pct = 1.0 ..
		Else If control_pct < -1.0 Then control_pct = -1.0
		magnitude_cur = control_pct*magnitude_max
	End Method
	
	Method dead%()
		Return ..
			life_time <> INFINITY And ..
			(now() - created_ts) > life_time
	End Method
	
End Type
