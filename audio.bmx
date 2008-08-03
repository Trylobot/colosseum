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

Function play_diesel_engine()
	'start/stop sounds as necessary
	If Not FLAG_game_in_progress
		FLAG_player_engine_started = False
		If ChannelPlaying( engine_idle_loop )
			StopChannel( engine_idle_loop )
			engine_idle_loop = AllocChannel()
			CueSound( snd_engine_idle_loop, engine_idle_loop )
			SetChannelVolume( engine_idle_loop, 0.5000 )
		End If
	Else 'FLAG_game_in_progress
		If Not FLAG_player_engine_started
			ResumeChannel( engine_start )
			FLAG_player_engine_started = True
		Else 'FLAG_player_engine_started
			If Not ChannelPlaying( engine_start ) ..
			And Not ChannelPlaying( engine_idle_loop )
				ResumeChannel( engine_idle_loop )
			End If
		End If
	End If
	'tweak engine idle volume and frequency by player input
	If ChannelPlaying( engine_idle_loop )
		Local p_speed# = Sqr( Pow(player.vel_x,2) + Pow(player.vel_y,2) )
		SetChannelVolume( engine_idle_loop, 0.5000 + ( 0.5000 * p_speed ) )
		SetChannelRate( engine_idle_loop, 0.7500 + (p_speed / 2.0) )
	End If
End Function

Function play_all()
	play_bg_music()
	play_diesel_engine()
End Function

