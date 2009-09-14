Rem
	constants.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict

'______________________________________________________________________________
Const settings_file_ext$ = "colosseum_settings"
Const data_file_ext$ = "colosseum_data"
Const level_file_ext$ = "colosseum_level"
Const saved_game_file_ext$ = "colosseum_profile"
Const autosave_path$ = "user/autosave.colosseum_data"

Const art_path$ = "art/"
Const data_path$ = "data/"
Const font_path$ = "fonts/"
Const level_path$ = "levels/"
Const sound_path$ = "sound/"
Const user_path$ = "user/"

Const default_settings_file_name$ = "settings."+settings_file_ext
Const default_assets_file_name$ = "assets."+data_file_ext

'______________________________________________________________________________
'these need to go away, kind of a hack
Const main_screen_x% = 15
Const main_screen_y% = 15

Type POLITICAL_ALIGNMENT
	Const NONE% = 0
	Const FRIENDLY% = 1
	Const HOSTILE% = 2
End Type

Type EVENT
	Const ALL_STOP% = 0
	Const TURN_RIGHT% = 1
	Const TURN_LEFT% = 2
	Const DRIVE_FORWARD% = 3
	Const DRIVE_BACKWARD% = 4
	Const DEATH% = 5
End Type

Type COMMAND
	Const NONE% = 0
	Const LOAD_ASSETS% = 10
	Const SHOW_CHILD_MENU% = 50
	Const BACK_TO_PARENT_MENU% = 51
	Const BACK_TO_MAIN_MENU% = 53
	Const PLAY_LEVEL% = 100
	Const FULL_KILL_TALLY% = 110
	Const BUY_PART% = 3000
	Const SELL_PART% = 3010
	Const PAUSE% = 2000
	Const RESUME% = 2010
	Const NEW_GAME% = 200
	Const NEW_LEVEL% = 210
	Const LOAD_GAME% = 300
	Const LOAD_LEVEL% = 310
	Const SAVE_GAME% = 400
	Const SAVE_LEVEL% = 401
	Const EDIT_LEVEL% = 500
	Const EDIT_VEHICLE% = 550
	Const CONNECT_TO_NETWORK_GAME% = 650
	Const HOST_NETWORK_GAME% = 655
	Const PLAYER_PROFILE_NAME% = 700
	Const PLAYER_PROFILE_PATH% = 710
	Const PLAYER_INPUT_TYPE% = 1000
	Const PLAYER_INVERT_REVERSE_STEERING% = 1001
	Const SETTINGS_FULLSCREEN% = 1010
	Const SETTINGS_RESOLUTION% = 1011
	Const SETTINGS_REFRESH_RATE% = 1012
	Const SETTINGS_BIT_DEPTH% = 1013
	Const SETTINGS_AUDIO% = 1017
	Const NETWORK_IP_ADDRESS% = 1020
	Const NETWORK_PORT% = 1021
	Const NETWORK_LEVEL% = 1022
	Const SETTINGS_SHOW_AI_MENU_GAME% = 1025
	Const SETTINGS_PARTICLE_LIMIT% = 1031
	Const SETTINGS_APPLY_ALL% = 1100
	Const QUIT_LEVEL% = 10010
	Const QUIT_GAME% = 65535
	
	Function decode$( code% )
		Select code
			Case NONE; Return "NONE"
			Case LOAD_ASSETS; Return "LOAD_ASSETS"
			Case SHOW_CHILD_MENU; Return "SHOW_CHILD_MENU"
			Case BACK_TO_PARENT_MENU; Return "BACK_TO_PARENT_MENU"
			Case BACK_TO_MAIN_MENU; Return "BACK_TO_MAIN_MENU"
			Case PLAY_LEVEL; Return "PLAY_LEVEL"
			Case CONNECT_TO_NETWORK_GAME; Return "CONNECT_TO_NETWORK_GAME"
			Case HOST_NETWORK_GAME; Return "HOST_NETWORK_GAME"
			Case FULL_KILL_TALLY; Return "FULL_KILL_TALLY"
			Case BUY_PART; Return "BUY_PART"
			Case SELL_PART; Return "SELL_PART"
			Case PAUSE; Return "PAUSE"
			Case RESUME; Return "RESUME"
			Case NEW_GAME; Return "NEW_GAME"
			Case NEW_LEVEL; Return "NEW_LEVEL"
			Case LOAD_GAME; Return "LOAD_GAME"
			Case LOAD_LEVEL; Return "LOAD_LEVEL"
			Case SAVE_GAME; Return "SAVE_GAME"
			Case SAVE_LEVEL; Return "SAVE_LEVEL"
			Case EDIT_LEVEL; Return "EDIT_LEVEL"
			Case EDIT_VEHICLE; Return "EDIT_VEHICLE"
			Case PLAYER_PROFILE_NAME; Return "PLAYER_PROFILE_NAME"
			Case PLAYER_PROFILE_PATH; Return "PLAYER_PROFILE_PATH"
			Case PLAYER_INPUT_TYPE; Return "PLAYER_INPUT_TYPE"
			Case PLAYER_INVERT_REVERSE_STEERING; Return "PLAYER_INVERT_REVERSE_STEERING"
			Case SETTINGS_FULLSCREEN; Return "SETTINGS_FULLSCREEN"
			Case SETTINGS_RESOLUTION; Return "SETTINGS_RESOLUTION"
			Case SETTINGS_REFRESH_RATE; Return "SETTINGS_REFRESH_RATE"
			Case SETTINGS_BIT_DEPTH; Return "SETTINGS_BIT_DEPTH"
			Case SETTINGS_AUDIO; Return "SETTINGS_AUDIO"
			Case NETWORK_IP_ADDRESS; Return "NETWORK_IP_ADDRESS"
			Case NETWORK_PORT; Return "NETWORK_PORT"
			Case NETWORK_LEVEL; Return "NETWORK_LEVEL"
			Case SETTINGS_SHOW_AI_MENU_GAME; Return "SETTINGS_SHOW_AI_MENU_GAME"
			Case SETTINGS_PARTICLE_LIMIT; Return "SETTINGS_PARTICLE_LIMIT"
			Case SETTINGS_APPLY_ALL; Return "SETTINGS_APPLY_ALL"
			Case QUIT_LEVEL; Return "QUIT_LEVEL"
			Case QUIT_GAME; Return "QUIT_GAME"
			Default; Return String.FromInt( code )
		End Select
	End Function
End Type

Type MENU_ID
	Const MAIN_MENU% = 100
	Const PAUSED% = 105
	Const PROFILE_MENU% = 155
	Const LOADING_BAY% = 200
	Const INPUT_PROFILE_NAME% = 205
	Const SELECT_LEVEL% = 270
	Const CONFIRM_NEW_GAME% = 299
	Const LOAD_GAME% = 300
	Const CONFIRM_LOAD_GAME% = 310
	Const LOAD_LEVEL% = 315
	Const SAVE_GAME% = 400
	Const INPUT_GAME_FILE_NAME% = 410
	Const SAVE_LEVEL% = 450
	Const INPUT_LEVEL_FILE_NAME% = 460
	Const CONFIRM_ERASE_LEVEL% = 470
	Const SETTINGS% = 500
	Const OPTIONS_PERFORMANCE% = 501
	Const PREFERENCES% = 505
	Const OPTIONS_VIDEO% = 510
	Const CHOOSE_RESOLUTION% = 511
	Const INPUT_REFRESH_RATE% = 512
	Const INPUT_BIT_DEPTH% = 513
	Const INPUT_PARTICLE_LIMIT% = 514
	Const OPTIONS_AUDIO% = 520
	Const CHOOSE_AUDIO_DRIVER% = 521
	Const OPTIONS_CONTROLS% = 530
	Const OPTIONS_GAME% = 540
	Const GAME_DATA% = 600
	Const LEVEL_EDITOR% = 610
	Const CASH_TOTAL% = 700
	Const PARTS_CATALOG% = 710
	Const BUY_PARTS% = 720
	Const SELL_PARTS% = 730
	Const MULTIPLAYER% = 800
	Const MULTIPLAYER_JOIN_GAME% = 810
	Const MULTIPLAYER_CREATE_GAME% = 811
	Const INPUT_NETWORK_IP_ADDRESS% = 820
	Const INPUT_NETWORK_PORT% = 821
	Const SELECT_NETWORK_LEVEL% = 822
	
	Function decode$( code% )
		Select code
			Case MAIN_MENU; Return "MAIN_MENU"
			Case LOADING_BAY; Return "LOADING_BAY"
			Case INPUT_PROFILE_NAME; Return "INPUT_PROFILE_NAME"
			Case SELECT_LEVEL; Return "SELECT_LEVEL"
			Case CASH_TOTAL; Return "CASH_TOTAL"
			Case PARTS_CATALOG; Return "PARTS_CATALOG"
			Case BUY_PARTS; Return "BUY_PARTS"
			Case SELL_PARTS; Return "SELL_PARTS"
			Case MULTIPLAYER; Return "MULTIPLAYER"
			Case MULTIPLAYER_JOIN_GAME; Return "MULTIPLAYER_JOIN_GAME"
			Case MULTIPLAYER_CREATE_GAME; Return "MULTIPLAYER_CREATE_GAME"
			Case INPUT_NETWORK_IP_ADDRESS; Return "INPUT_NETWORK_IP_ADDRESS"
			Case INPUT_NETWORK_PORT; Return "INPUT_NETWORK_PORT"
			Case SELECT_NETWORK_LEVEL; Return "SELECT_NETWORK_LEVEL"
			Case LOAD_GAME; Return "LOAD_GAME"
			Case CONFIRM_LOAD_GAME; Return "CONFIRM_LOAD_GAME"
			Case LOAD_LEVEL; Return "LOAD_LEVEL"
			Case SAVE_GAME; Return "SAVE_GAME"
			Case INPUT_GAME_FILE_NAME; Return "INPUT_GAME_FILE_NAME"
			Case SAVE_LEVEL; Return "SAVE_LEVEL"
			Case INPUT_LEVEL_FILE_NAME; Return "INPUT_LEVEL_FILE_NAME"
			Case CONFIRM_ERASE_LEVEL; Return "CONFIRM_ERASE_LEVEL"
			Case SETTINGS; Return "SETTINGS"
			Case OPTIONS_PERFORMANCE; Return "OPTIONS_PERFORMANCE"
			Case PREFERENCES; Return "PREFERENCES"
			Case OPTIONS_VIDEO; Return "OPTIONS_VIDEO"
			Case CHOOSE_RESOLUTION; Return "CHOOSE_RESOLUTION"
			Case INPUT_REFRESH_RATE; Return "INPUT_REFRESH_RATE"
			Case INPUT_BIT_DEPTH; Return "INPUT_BIT_DEPTH"
			Case INPUT_PARTICLE_LIMIT; Return "INPUT_PARTICLE_LIMIT"
			Case OPTIONS_AUDIO; Return "OPTIONS_AUDIO"
			Case CHOOSE_AUDIO_DRIVER; Return "CHOOSE_AUDIO_DRIVER"
			Case OPTIONS_CONTROLS; Return "OPTIONS_CONTROLS"
			Case OPTIONS_GAME; Return "OPTIONS_GAME"
			Case GAME_DATA; Return "GAME_DATA"
			Case LEVEL_EDITOR; Return "LEVEL_EDITOR"
			Case PAUSED; Return "PAUSED"
			Case CONFIRM_NEW_GAME; Return "CONFIRM_NEW_GAME"
			Case PROFILE_MENU; Return "PROFILE_MENU"
			Default; Return String.FromInt( code )
		End Select
	End Function
End Type
