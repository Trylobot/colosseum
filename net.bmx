Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_host% = False
Global network_ip_address$
Global network_port%
Global network_level$ = "levels/blitz.colosseum_level"

Global tcp_server:TTCPStream
Global tcp_clients:TList 'TList<TTCPStream>
Global tcp_client:TTCPStream

Global remote_players:TMap = CreateMap() 'TMap<NETWORK_ID,REMOTE_PLAYER>
Function add_remote_player( rp:REMOTE_PLAYER )
	remote_players.Insert( rp.net_id.ToString(), rp )
End Function
Function get_remote_player:REMOTE_PLAYER( net_id:NETWORK_ID )
	Return REMOTE_PLAYER( remote_players.ValueForKey( net_id.ToString() ))
End Function

Global outgoing_messages:TList = CreateList() 'TList<CHAT_MESSAGE>
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>

Const chat_stay_time% = 8000
Const chat_fade_time% = 4000
Const min_random_port:Short = 59000
Const max_random_port:Short = 60000

Global last_broadcast_ts%
Const self_broadcast_delay% = 50

Function update_network()
	If playing_multiplayer
		Local rp:REMOTE_PLAYER
		
		If network_host
			'process potential incoming connections
			Repeat
				tcp_client = tcp_server.Accept()
				If tcp_client
					rp = REMOTE_PLAYER.Create( NETWORK_ID.Create( tcp_client.GetLocalIP(), tcp_client.GetLocalPort() ), tcp_client )
					DebugLog( " " + rp.net_id.ToString() + " connected" )
					'send the client information about each other connected player, including self
					tcp_client.WriteByte( NET.IDENTITY )
					tcp_client.WriteLine( profile.name + "~t" + profile.vehicle.to_json().ToString() )
					For Local old_rp:REMOTE_PLAYER = EachIn remote_players.Values()
						tcp_client.WriteByte( NET.IDENTITY )
						tcp_client.WriteLine( old_rp.name + "~t" + old_rp.vehicle_json.ToString() )
					Next
					tcp_client.WriteByte( NET.READY )
					While tcp_client.SendMsg() ; End While
					add_remote_player( rp )
				End If
			Until Not tcp_client
		End If
		'process each connected client
		For rp = EachIn remote_players.Values()
			'remove disconnected clients
			If rp.tcp_stream.GetState() <> 1
				rp.tcp_stream.Close()
				remote_players.Remove( rp.net_id.ToString() )
				DebugLog( " " + rp.net_id.ToString() + " disconnected" )
				Continue 'next
				'TODO: automatic re-connect attempts after disconnect
			End If
			'check for and process messages from this connected client
			If rp.tcp_stream.RecvAvail()
				While rp.tcp_stream.RecvMsg() ; End While
				While rp.tcp_stream.Size() > 0
					Local message_type:Byte = rp.tcp_stream.ReadByte()
					Select message_type
						
						Case NET.IDENTITY
							DebugLog( " " + NET.decode( message_type ) + " from " + rp.net_id.ToString() )
							Local data$[] = rp.tcp_stream.ReadLine().Split( "~t" )
							rp.name = data[0]
							rp.vehicle_json = TJSON.Create( data[1] )
							Local vd:VEHICLE_DATA = Create_VEHICLE_DATA_from_json( rp.vehicle_json )
							rp.avatar = create_player( vd, False, False )
							rp.brain = Create_CONTROL_BRAIN( rp.avatar, CONTROL_BRAIN.CONTROL_TYPE_REMOTE )
						
						Case NET.READY
							DebugLog( " " + NET.decode( message_type ) + " from " + rp.net_id.ToString() )
							If network_host
								'received ready signal from client
								game.insert_network_player( rp.avatar, rp.brain )
								game.respawn_network_player( rp.avatar )
								'TODO: need a way for connected players to:
								'      - choose team (friendly, hostile, spectator)
								'      - spawn in a spawn-point of the appropriate team with enough room near it
							Else
								'received ready signal from server
								'TODO: spawn every remote player
								'      will require connections to be separated from remote players
							End If
						
						Case NET.CHAT_MESSAGE
							DebugLog( " " + NET.decode( message_type ) + " from " + rp.net_id.ToString() )
							Local data$[] = rp.tcp_stream.ReadLine().Split( "~t" )
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( data[0], data[1] )
							cm.originator = rp.net_id
							chat_message_list.AddFirst( cm )
							If network_host
								outgoing_messages.AddLast( cm )
							End If
							
						Default
							DebugLog( " WARNING: " + NET.decode( message_type ) + " from " + rp.net_id.ToString() + " sent via TCP" )
							
					End Select
				End While
			End If
			If rp.udp_stream.RecvAvail()
				While rp.udp_stream.RecvMsg() ; End While
				While rp.udp_stream.Size() > 0
					Local message_type:Byte = rp.tcp_stream.ReadByte()
					Select message_type
						
						Case NET.AVATAR_STATE_UPDATE
							rp.avatar.read_state_from_stream( rp.udp_stream )
							If network_host
								'TODO: relay update to other players (like chat messages)
								'      this will require idents to be sent with the state updates
								'      and for the client to recognize idents and distribute idents
							End If
						
						Default
							DebugLog( " WARNING: " + NET.decode( message_type ) + " from " + rp.net_id.ToString() + " sent via TCP" )
							
					End Select
				End While
			End If
		Next

		'periodical broadcast
		If game And game.player
			If (now() - last_broadcast_ts) > self_broadcast_delay
				last_broadcast_ts = now()
				For rp = EachIn remote_players.Values()
					rp.tcp_stream.WriteByte( NET.AVATAR_STATE_UPDATE )
					game.player.write_state_to_stream( rp.tcp_stream )
					While rp.tcp_stream.SendMsg() ; End While
				Next
			End If
		End If

		'relay chats to all connected players except sender
		For Local cm:CHAT_MESSAGE = EachIn outgoing_messages
			DebugLog( " outgoing chat message, " + cm.username + ": " + cm.message )
			For Local rp:REMOTE_PLAYER = EachIn remote_players.Values()
				If Not rp.net_id.equals( cm.originator )
					rp.tcp_stream.WriteByte( NET.CHAT_MESSAGE )
					rp.tcp_stream.WriteLine( cm.username + "~t" + cm.message )
					DebugLog( "  sending to " + rp.net_id.ToString() )
					While rp.tcp_stream.SendMsg() ; End While
				Else
					DebugLog( "  skipping " + rp.net_id.ToString() )
				End If
			Next
		Next
		outgoing_messages.Clear()

		'prune old chats
		If Not chat_message_list.IsEmpty()
			For Local cm:CHAT_MESSAGE = EachIn chat_message_list
				If time_alpha_pct( cm.added_ts + chat_stay_time, chat_fade_time, False ) = 0
					chat_message_list.Remove( cm )
				End If
			Next
		End If

	End If
End Function

Function network_listen()
	tcp_server = New TTCPStream
	tcp_server.Init()
	tcp_server.SetLocalPort( network_port )
  tcp_server.Listen()
	DebugLog( " listening on port " + tcp_server.GetLocalPort() )
End Function

Function connect_to_network_game()
	Local server_id:NETWORK_ID = NETWORK_ID.Create( TNetwork.IntIP( network_ip_address ), Short( network_port ))
	Local server:REMOTE_PLAYER = REMOTE_PLAYER.Create( server_id, New TTCPStream )
	server.tcp_stream.Init()
	server.tcp_stream.SetRemoteIP( server_id.ip )
	server.tcp_stream.SetRemotePort( server_id.port )
	server.tcp_stream.SetLocalPort( Short( Rand( min_random_port, max_random_port )))
	server.tcp_stream.Connect()
	server.tcp_stream.WriteByte( NET.IDENTITY )
	server.tcp_stream.WriteLine( profile.name + "~t" + profile.vehicle.to_json().ToString() )
	server.tcp_stream.WriteByte( NET.READY )
	While server.tcp_stream.SendMsg() ; End While
	add_remote_player( server )
End Function

Function network_terminate()
	If tcp_server
		tcp_server.Close()
		tcp_server = Null
	End If
	For Local rp:REMOTE_PLAYER = EachIn remote_players.Values()
		If rp And rp.tcp_stream
			rp.tcp_stream.Close()
			rp.tcp_stream = Null
		End If
	Next
	remote_players.Clear()
End Function

'______________________________________________________________________________
Type NETWORK_ID
	Field ip%
	Field port:Short
	
	Function Create:NETWORK_ID( ip%, port:Short )
		Local ent:NETWORK_ID = New NETWORK_ID
		ent.ip = ip
		ent.port = port
		Return ent
	End Function
	
	Method ToString$()
		Return TNetwork.StringIP( ip ) + ":" + port
	End Method
	
	Method equals%( other:NETWORK_ID )
		Return (other And ip = other.ip And port = other.port)
	End Method
End Type

'______________________________________________________________________________
Type REMOTE_PLAYER
	Field net_id:NETWORK_ID
	
	'TODO: Remove these streams; The association between remote players and network streams is not 1:1
	Field tcp_stream:TTCPStream
	Field udp_stream:TUDPStream
	
	Field name$
	Field vehicle_json:TJSON
	Field avatar:COMPLEX_AGENT
	Field brain:CONTROL_BRAIN
	
	Function Create:REMOTE_PLAYER( net_id:NETWORK_ID, tcp_stream:TTCPStream )
		Local rp:REMOTE_PLAYER = New REMOTE_PLAYER
		rp.net_id = net_id
		rp.tcp_stream = tcp_stream
		rp.udp_stream = New TUDPStream
		rp.udp_stream.Init()
		rp.udp_stream.SetLocalPort( rp.tcp_stream.GetLocalPort() )
		rp.udp_stream.SetRemoteIP( rp.tcp_stream.GetRemoteIP() )
		rp.udp_stream.SetRemotePort( rp.tcp_stream.GetRemotePort() )
		Return rp
	End Function
End Type

'______________________________________________________________________________
Type CHAT_MESSAGE
	Field added_ts%
	Field username$
	Field message$
	Field from_self%
	Field originator:NETWORK_ID
	Field is_system_message%
	
	Function Create:CHAT_MESSAGE( username$, message$, from_self% = False, is_system_message% = False )
		Local cm:CHAT_MESSAGE = New CHAT_MESSAGE
		cm.added_ts = now()
		cm.username = username
		cm.message = message
		cm.from_self = from_self
		cm.is_system_message = is_system_message
		Return cm
	End Function
End Type

Function send_chat( message$ )
	Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( profile.name, message, True, False )
	chat_message_list.AddFirst( cm )
	outgoing_messages.AddLast( cm )
End Function

Function send_system_message( message$ )
	Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( "", message, True, True )
	chat_message_list.AddFirst( cm )
	outgoing_messages.AddLast( cm )
End Function

'______________________________________________________________________________
Type NET
	Const READY:Byte = 1
	Const IDENTITY:Byte = 5
	'Const LEVEL_NAME:Byte = 10
	'Const ENVIRONMENT_STATE:Byte = 15
	Const AVATAR_STATE_UPDATE:Byte = 20
	Const SPAWN_AGENT:Byte = 30
	Const AGENT_STATE_UPDATE:Byte = 31
	Const CHAT_MESSAGE:Byte = 100

	Function decode$( code:Byte )
		Select code
			Case READY; Return "READY"
			Case IDENTITY; Return "IDENTITY"
			'Case LEVEL_NAME; Return "LEVEL_NAME"
			'Case ENVIRONMENT_STATE; Return "ENVIRONMENT_STATE"
			Case AVATAR_STATE_UPDATE; Return "AVATAR_STATE_UPDATE"
			Case CHAT_MESSAGE; Return "CHAT_MESSAGE"
			Default; Return String.FromInt( Int( code ))
		End Select
	End Function
End Type




