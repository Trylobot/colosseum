Rem
	timescale.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "misc.bmx"

'______________________________________________________________________________
Const time_per_frame_min% = 8 'milliseconds
Const timescale_constant_factor# = 0.350 '0.375 'simulation speed

Global before%
Global timescale#

Function frame_time_elapsed%() 'true or false: the amount of time required for a physics frame has indeed elapsed?
	Return (now() - before) > time_per_frame_min
End Function

Function reset_frame_timer()
	before = now()
End Function

Function calculate_timescale()
	timescale = timescale_constant_factor * Float(now() - before)/Float(time_per_frame_min)
End Function

