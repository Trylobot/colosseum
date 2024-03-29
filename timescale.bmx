Rem
	timescale.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict
'Import "misc.bmx"

'______________________________________________________________________________
Const time_per_frame_min% = 8/2 'milliseconds
Const timescale_constant_factor# = 0.350/2.0 '0.350 'represents simulation speed
Const timescale_max# = 5.000/2.0

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
	If timescale > timescale_max Then timescale = timescale_max
End Function

