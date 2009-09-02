Rem
	flags.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Type FLAG
	'game state
	Global in_menu%
	Global playing_multiplayer%
	Global chat_mode%
	'audio
	Global bg_music%
	Global engine_ignition%
	Global engine_running%
	'input bleed prevention
	Global ignore_mouse_1%
	'consequence of failure
	Global damage_incurred%
End Type

