Rem
	settings.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
'SuperStrict

'______________________________________________________________________________
'non-configurable internal settings
Global zoom# = 1.0

Function apply_default_settings()
	'fullscreen = False
	SETTINGS_REGISTER.FULL_SCREEN = GLOBAL_SETTING_BOOLEAN.Create( False )
	
	SETTINGS_REGISTER.ACTUAL_WINDOW_WIDTH = GLOBAL_SETTING_INTEGER.Create( 640 ) 'graphics resolution
	SETTINGS_REGISTER.ACTUAL_WINDOW_HEIGHT = GLOBAL_SETTING_INTEGER.Create( 480 ) 'graphics resolution
	SETTINGS_REGISTER.WINDOW_WIDTH = GLOBAL_SETTING_INTEGER.Create( 640 ) 'virtual resolution (fixed)
	SETTINGS_REGISTER.WINDOW_HEIGHT = GLOBAL_SETTING_INTEGER.Create( 480 ) 'virtual resolution (fixed)
	
	SETTINGS_REGISTER.BIT_DEPTH = GLOBAL_SETTING_INTEGER.Create( 32 )
	SETTINGS_REGISTER.REFRESH_RATE = GLOBAL_SETTING_INTEGER.Create( 60 )
	
	SETTINGS_REGISTER.GRAPHICS_MODE = New DYNAMIC_STRING
	SETTINGS_REGISTER.GRAPHICS_MODE.append( SETTINGS_REGISTER.WINDOW_WIDTH )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( "x" )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( SETTINGS_REGISTER.WINDOW_HEIGHT )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( " px, " )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( SETTINGS_REGISTER.BIT_DEPTH )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( " bpp, " )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( SETTINGS_REGISTER.REFRESH_RATE )
	SETTINGS_REGISTER.GRAPHICS_MODE.append( " Hz" )
	SETTINGS_REGISTER.GRAPHICS_MODE.resolve()
	
	SETTINGS_REGISTER.PLAYER_PROFILE_NAME = GLOBAL_SETTING_STRING.Create( "" )
	
	SETTINGS_REGISTER.LEVEL_EDITOR_CACHE_FILENAME = GLOBAL_SETTING_STRING.Create( "" )
	
	SETTINGS_REGISTER.SHOW_AI_MENU_GAME = GLOBAL_SETTING_BOOLEAN.Create( True )
	SETTINGS_REGISTER.ACTIVE_PARTICLE_LIMIT = GLOBAL_SETTING_INTEGER.Create( 1000 )
	
	audio_driver = "FreeAudio DirectSound"
	bg_music_enabled = True
End Function

Type SETTINGS_REGISTER
	Global FULL_SCREEN:GLOBAL_SETTING_BOOLEAN
	Global ACTUAL_WINDOW_WIDTH:GLOBAL_SETTING_INTEGER
	Global ACTUAL_WINDOW_HEIGHT:GLOBAL_SETTING_INTEGER
	Global WINDOW_WIDTH:GLOBAL_SETTING_INTEGER
	Global WINDOW_HEIGHT:GLOBAL_SETTING_INTEGER
	Global BIT_DEPTH:GLOBAL_SETTING_INTEGER
	Global REFRESH_RATE:GLOBAL_SETTING_INTEGER
	Global GRAPHICS_MODE:DYNAMIC_STRING
	Global PLAYER_PROFILE_NAME:GLOBAL_SETTING_STRING
	Global LEVEL_EDITOR_CACHE_FILENAME:GLOBAL_SETTING_STRING
	Global SHOW_AI_MENU_GAME:GLOBAL_SETTING_BOOLEAN
	Global ACTIVE_PARTICLE_LIMIT:GLOBAL_SETTING_INTEGER
End Type

'user-configurable settings
'Global fullscreen%
'Global window_w%
'Global window_h%
'Global bit_depth%
'Global refresh_rate%
Global audio_driver$
Global bg_music_enabled%
'Global show_ai_menu_game%
'Global active_particle_limit%

'______________________________________________________________________________
Type REQUEST_INPUT_FOR_SETTING_POPUP
	Field x%, y%
	Field font:FONT_STYLE
	Field setting:GLOBAL_SETTING
End Type

'______________________________________________________________________________
Type DYNAMIC_STRING
	Field parts:TList
	Field cached$
	
	Method New()
		parts = CreateList()
	End Method
	
	Method append( part:Object )
		parts.AddLast( part )
	End Method
	
	Method resolve()
		cached = ""
		For Local part:Object = EachIn parts
			cached :+ part.ToString()
		Next
	End Method
	
	Method ToString:String()
		Return cached
	End Method
End Type

'______________________________________________________________________________
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

'______________________________________________________________________________
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

'______________________________________________________________________________
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

'______________________________________________________________________________
Type GLOBAL_SETTING
	Method reset_to_default() Abstract
	Method ToString:String() Abstract
End Type

