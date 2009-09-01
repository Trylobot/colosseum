Rem
	settings.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "box.bmx"

'______________________________________________________________________________
Global window_w%
Global window_h%
Global window:BOX
Global fullscreen%
Global bit_depth%
Global refresh_rate%
Global show_ai_menu_game%
Global retain_particles%
Global active_particle_limit%

Global network_ip_address$
Global network_port%

Function apply_default_settings()
	window_w = 640
	window_h = 480
	window = Create_BOX( 0, 0, window_w, window_h )
	fullscreen = False
	bit_depth = 32
	refresh_rate = 60
	show_ai_menu_game = True
	retain_particles = True
	active_particle_limit = 500
	
	network_ip_address = "127.0.0.1"
	network_port = 6112
End Function
