Rem
	settings.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
'non-configurable internal settings
Global zoom# = 1.0

Type SETTINGS_REGISTER
	Global FULL_SCREEN:GLOBAL_SETTING_BOOLEAN
End Type

'user-configurable settings
Global window_w%
Global window_h%
'Global fullscreen%
Global bit_depth%
Global refresh_rate%
Global audio_driver$
Global bg_music_enabled%
Global show_ai_menu_game%
Global active_particle_limit%
Global network_ip_address$
Global network_port%

Function apply_default_settings()
	window_w = 800
	window_h = 600
	'fullscreen = False
	SETTINGS_REGISTER.FULL_SCREEN = GLOBAL_SETTING_BOOLEAN.Create( False )
	bit_depth = 32
	refresh_rate = 60
	audio_driver = "FreeAudio DirectSound"
	bg_music_enabled = True
	show_ai_menu_game = True
	active_particle_limit = 1000
	network_ip_address = "127.0.0.1"
	network_port = 6112
End Function


Type GLOBAL_SETTING
	Method reset_to_default() Abstract
	Method ToString:String() Abstract
End Type

Type GLOBAL_SETTING_BOOLEAN Extends GLOBAL_SETTING
	Field value%
	Field default_value%
	'////
	Function Create:GLOBAL_SETTING_BOOLEAN( new_default_value% )
		Local setting:GLOBAL_SETTING_BOOLEAN = New GLOBAL_SETTING_BOOLEAN
		setting.default_value = new_default_value
		setting.reset_to_default()
		Return setting
	End Function
	'////
	Method set( new_value% )
		If new_value
			value = True
		Else
			value = False
		End If
	End Method
	'////
	Method toggle()
		value = Not value
	End Method
	'////
	Method get%()
		Return value
	End Method
	'////
	Method reset_to_default()
		value = default_value
	End Method
	'////
	Method ToString:String()
		If value
			Return "TRUE"
		Else
			Return "FALSE"
		End If
	End Method
End Type

Type GLOBAL_SETTING_INTEGER Extends GLOBAL_SETTING
	Field value%
	Field default_value%
	'////
	Function Create:GLOBAL_SETTING_INTEGER( new_default_value% )
		Local setting:GLOBAL_SETTING_INTEGER = New GLOBAL_SETTING_INTEGER
		setting.default_value = new_default_value
		setting.reset_to_default()
		Return setting
	End Function
	'////
	Method set( new_value% )
		value = new_value
	End Method
	'////
	Method get%()
		Return value
	End Method
	'////
	Method reset_to_default()
		value = default_value
	End Method
	'////
	Method ToString:String()
		Return String.FromInt( value )
	End Method
End Type

Type GLOBAL_SETTING_STRING Extends GLOBAL_SETTING
	Field value$
	Field default_value$
	'////
	Function Create:GLOBAL_SETTING_STRING( new_default_value$ )
		Local setting:GLOBAL_SETTING_STRING = New GLOBAL_SETTING_STRING
		setting.default_value = new_default_value
		setting.reset_to_default()
		Return setting
	End Function
	'////
	Method set( new_value$ )
		value = new_value
	End Method
	'////
	Method get$()
		Return value
	End Method
	'////
	Method reset_to_default()
		value = default_value
	End Method
	'////
	Method ToString:String()
		Return get()
	End Method
End Type

