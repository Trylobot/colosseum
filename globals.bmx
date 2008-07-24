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
Function RandF#( low#, high# )
	Return 0.0001 * Rand( 10000*low, 10000*high ) 
End Function

'object manager lists
Global particle_list:TList = CreateList()
Global emitter_list:TList = CreateList()
Global projectile_list:TList = CreateList()
Global enemy_list:TList = CreateList()

'generic
Const infinite_life_time% = -1
Const infinite_count% = -1
Global player_cash% = 0

'settings
Global FLAG_draw_help% = False

'player
'distance (pixels)
Const player_turret_recoil_dist# = 4.000
'velocity (pixels per 1/60 second)
Const player_velocity_max# = 1.100
'angular velocity (degrees per 1/60 second)
Const player_angular_velocity_max# = 1.500
Const player_turret_angular_velocity_max# = 1.850

Const window_w% = 850
Const window_h% = 550


