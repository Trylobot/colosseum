Rem
	globals.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'Basics
SetGraphicsDriver D3D7Max2DDriver()
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
Function cartesian_to_polar( c_x#, c_y#, p_dist# Var, p_ang# Var )
	p_dist = Sqr( c_x*c_x + c_y*c_y )
	If c_x <> 0
		p_ang = ATan( c_y/c_x )
		If c_x < 0 Then p_ang :- 180
	Else 'x = 0
		If c_y > 0 Then p_ang = 90 Else If c_y < 0 Then p_ang = 90 Else p_ang = 0
	End If
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



