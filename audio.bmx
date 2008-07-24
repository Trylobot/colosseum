Rem
	audio.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Audio
Function play_bg_music()
	If FLAG_bg_music_on
		ResumeChannel( bg_music )
	Else If Not FLAG_bg_music_on
		PauseChannel( bg_music )
	End If
End Function

