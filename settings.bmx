Rem
	settings.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
'Non Configurable
Global zoom# = 1.0

'Configurable
Global window_w%
Global window_h%
Global fullscreen%
Global bit_depth%
Global refresh_rate%
Global audio_driver$
Global bg_music_enabled%
Global show_ai_menu_game%
Global active_particle_limit%
Global network_ip_address$
Global network_port%

Function apply_default_settings()
	window_w = 640
	window_h = 480
	fullscreen = False
	bit_depth = 32
	refresh_rate = 60
	audio_driver = Null
	bg_music_enabled = True
	show_ai_menu_game = True
	active_particle_limit = 1000
	network_ip_address = "127.0.0.1"
	network_port = 6112
End Function


