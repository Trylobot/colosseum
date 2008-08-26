Rem
	audio.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
'Audio
Global audio_channels:TList = CreateList()

Function play_all()
	play_bg_music()
	
	If FLAG_player_engine_ignition
		start_player_engine()
	End If
	tweak_engine_idle()
	
	Local ch:TChannel
	Local ch_link:TLink = audio_channels.FirstLink(), next_ch_link:TLink
	If ch_link <> Null
		While ch_link <> Null
			ch = TChannel( ch_link.Value() )
			If Not ChannelPlaying( ch )
				StopChannel( ch )
			End If
			next_ch_link = ch_link.NextLink()
			ch_link.Remove()
			ch_link = next_ch_link
		End While
	End If
End Function
'______________________________________________________________________________
Global bg_music:TChannel

Function play_bg_music()
	If bg_music = Null
		bg_music = AllocChannel()
		CueSound( get_sound( "victory_8-bit" ), bg_music )
	End If
	If FLAG_bg_music_on
		ResumeChannel( bg_music )
	Else If Not FLAG_bg_music_on
		PauseChannel( bg_music )
	End If
End Function

'______________________________________________________________________________
Global engine_start:TChannel
Global engine_idle:TChannel

Function start_player_engine()
	If engine_start <> Null
		StopChannel( engine_start )
		engine_start = Null
	End If
	engine_start = AllocChannel()
	CueSound( get_sound( "engine_start" ), engine_start )
	SetChannelVolume( engine_start, 0.5 )
	ResumeChannel( engine_start )
	FLAG_player_engine_ignition = False
	FLAG_player_engine_running = False
End Function

Function tweak_engine_idle()
	If FLAG_player_engine_running	
		If engine_start <> Null
			If Not ChannelPlaying( engine_start )
				'stop engine_start
				StopChannel( engine_start )
				engine_start = Null
				'start engine_idle
				engine_idle = AllocChannel()
				CueSound( get_sound( "engine_idle_loop" ), engine_idle )
				SetChannelVolume( engine_idle, 0.5 )
				ResumeChannel( engine_idle )
			End If
		Else 'engine_start == Null
			If engine_idle = Null
				'start engine_idle
				engine_idle = AllocChannel()
				CueSound( get_sound( "engine_idle_loop" ), engine_idle )
				ResumeChannel( engine_idle )
			End If
			Local p_speed# = Sqr( Pow(game.player.vel_x,2) + Pow(game.player.vel_y,2) )
			SetChannelVolume( engine_idle, 0.5 + ( 0.5 * (p_speed / 2.0) ))
			SetChannelRate( engine_idle, 1.0 + (p_speed / 2.0) )
		End If
	Else 'Not FLAG_playing_engine_running
		If engine_start <> Null
			If Not ChannelPlaying( engine_start )
				FLAG_player_engine_running = True
			End If
		End If
		If engine_idle <> Null
			StopChannel( engine_idle )
			engine_idle = Null
		End If
	End If
End Function


