Rem
	globals.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Basics
AppTitle = My.Application.AssemblyInfo

'Clock and RNG (Random Number Generator)
SeedRnd MilliSecs()
Global clock:TTimer = CreateTimer( 1000 )
Function now%()
	Return clock.Ticks()
End Function
Function RandF#( low#, high# )
	Return 0.0001 * Rand( 10000*low, 10000*high ) 
End Function

'Fonts
Global consolas_normal_10:TImageFont = LoadImageFont( "fonts/consolas.ttf", 10 )
Global consolas_normal_12:TImageFont = LoadImageFont( "fonts/consolas.ttf", 12 )
Global consolas_bold_50:TImageFont = LoadImageFont( "fonts/consolas_bold.ttf", 50 )

'Window / Arena
Const window_w% = 1024
Const window_h% = 768
Const arena_offset% = 25
Const arena_w% = window_w - (arena_offset * 2) - 250
Const arena_h% = window_h - (arena_offset * 2)

'Generic
Const INFINITY% = -1
Const ALL_STOP% = 0
Const CLOCKWISE_DIRECTION% = 1
Const COUNTER_CLOCKWISE_DIRECTION% = 2

'Score
Global player_cash% = 0

'Settings flags
Global FLAG_draw_help% = False
Global FLAG_paused% = False

'Special Player Constants
'velocity (pixels per 1/60 second)
Const player_velocity_max# = 1.100
'angular velocity (degrees per 1/60 second)
Const player_angular_velocity_max# = 1.500
Const player_turret_angular_velocity_max# = 1.850



