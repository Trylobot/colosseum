Rem
	globals.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

SeedRnd MilliSecs()
Global clock:TTimer = CreateTimer( 1000 )
Function now%()
	Return clock.Ticks()
End Function

'distance (pixels)
Const player_length% = 25
Const player_width% = 17
Const player_turret_recoil_dist# = 4.000
'velocity (pixels per 1/60 second)
Const player_velocity_max# = 1.100
Const player_turret_projectile_muzzle_velocity# = 4.500
Const player_turret_mgun_muzzle_velocity# = 5.500
'angular velocity (degrees per 1/60 second)
Const player_angular_velocity_max# = 1.500
Const player_turret_angular_velocity_max# = 1.850
'time (ms)
Const infinite_life_time% = -1
Const player_turret_reload_time% = 450
Const player_mgun_reload_time% = 75
Const player_turret_recoil_time% = 450
Const player_turret_muzzle_life_time% = 125
Const projectile_explode_life_time% = 300

'object manager lists
Global projectile_list:TList = CreateList()
Global particle_list:TList = CreateList()
Global enemy_list:TList = CreateList()
Global emitter_list:TList = CreateList()

'settings flags
Global FLAG_draw_help% = False

'generic
Global player_cash% = 0
