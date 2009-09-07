Rem
	settings.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Global window_w%
Global window_h%
Global fullscreen%
Global bit_depth%
Global refresh_rate%
Global show_ai_menu_game%

Global network_ip_address$
Global network_port%

Function apply_default_settings()
	window_w = 640
	window_h = 480
	fullscreen = False
	bit_depth = 32
	refresh_rate = 60
	show_ai_menu_game = True
	
	network_ip_address = "127.0.0.1"
	network_port = 6112
End Function


