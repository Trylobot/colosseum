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

Global server:CONNECTION
Global clients:TList = CreateList() 'TList<CONNECTION>

Global remote_players:TMap = CreateMap() 'TMap<NETWORK_ID.ToString(),REMOTE_PLAYER>

Global outgoing_messages:TList = CreateList() 'TList<CHAT_MESSAGE>
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>

Const chat_stay_time% = 8000
Const chat_fade_time% = 4000
Const min_random_port:Short = 59000
Const max_random_port:Short = 60000

'UDP periodicals
Global last_self_broadcast_avatar_state_ts%
Const delay_self_broadcast_avatar_state% = 250
Global last_self_broadcast_inputs_ts%
Const delay_self_broadcast_inputs% = 10

'______________________________________________________________________________
Function update_network()
	If playing_multiplayer
		Local client:CONNECTION
		Local rp_id:NETWORK_ID
		Local rp:REMOTE_PLAYER
		
		If network_host
			'process potential incoming client connections
			Repeat
				client = CONNECTION.Create( server.tcp.Accept() )
				If client
					'add a remote player
					rp_id = NETWORK_ID.Create( client.local_ip, client.local_port )
					DebugLog( " " + rp_id.ToString() + " connected" )
					rp = REMOTE_PLAYER.Create( rp_id )
					add_remote_player( rp )
					'send the new client all information about self and each other already connected player
					write_net_identity( client.tcp, server.local_ip, server.local_port, profile.name, TJSON.Create( profile.vehicle.to_json() ))
					For Local other:CONNECTION = EachIn clients
						rp = get_remote_player( other.local_ip, other.local_port )
						write_net_identity( client.tcp, other.local_ip, other.local_port, rp.name, rp.vehicle_json )
					Next
					clients.AddLast( client )
					client.tcp.WriteByte( NET.READY )
					While client.tcp.SendMsg() ; End While
				End If
			Until Not client
		End If
		'process each connected client
		For client = EachIn clients
			rp_id = NETWORK_ID.Create( client.local_ip, client.local_port )
			rp = get_remote_player_by_id( rp_id )
			'remove disconnected clients
			'TODO: automatic pause-game & attempt reconnect for a bit
			If client.tcp.GetState() <> 1
				remote_players.Remove( rp_id.ToString() )
				DebugLog( " " + rp_id.ToString() + " disconnected" )
				client.tcp.Close()
				clients.Remove( client )
				Continue 'next client
			End If
			'check for and process messages from this connected client
			If client.tcp.RecvAvail()
				While client.tcp.RecvMsg() ; End While
				While client.tcp.Size() > 0
					Local message_type:Byte = client.tcp.ReadByte()
					Select message_type
						
						Case NET.IDENTITY
							DebugLog( " " + NET.decode( message_type ) + " from " + rp_id.ToString() )
							Local data$[] = client.tcp.ReadLine().Split( "~t" )
							rp.name = data[0]
							rp.vehicle_json = TJSON.Create( data[1] )
							Local vd:VEHICLE_DATA = Create_VEHICLE_DATA_from_json( rp.vehicle_json )
							rp.avatar = create_player( vd, False, False )
							rp.brain = Create_CONTROL_BRAIN( rp.avatar, CONTROL_BRAIN.CONTROL_TYPE_REMOTE )
						
						Case NET.READY
							DebugLog( " " + NET.decode( message_type ) + " from " + rp_id.ToString() )
							If network_host
								'received ready signal from client
								game.insert_network_player( rp.avatar, rp.brain )
								game.respawn_network_player( rp.avatar )
								'TODO: need a way for connected players to:
								'      - choose team (friendly, hostile, spectator)
								'      - spawn in a spawn-point of the appropriate team with enough room near it
							Else 'network_client
								'received ready signal from server
								'TODO: spawn every remote player
								'      will require connections to be separated from remote players
							End If
						
						Case NET.CHAT_MESSAGE
							DebugLog( " " + NET.decode( message_type ) + " from " + rp_id.ToString() )
							Local data$[] = client.tcp.ReadLine().Split( "~t" )
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( data[0], data[1] )
							cm.originator = rp.net_id
							chat_message_list.AddFirst( cm )
							If network_host 'rebroadcast
								outgoing_messages.AddLast( cm )
							End If
							
						Default 'unknown - indicates error has occurred
							DebugLog( " WARNING: unknown message " + NET.decode( message_type ) + " received from TCP/" + rp_id.ToString() )
							
					End Select
				End While
			End If
			If client.udp.RecvAvail()
				While client.udp.RecvMsg() ; End While
				While client.udp.Size() > 0
					Local message_type:Byte = client.udp.ReadByte()
					Select message_type
						
						Case NET.AVATAR_STATE_UPDATE
							rp.avatar.read_state_from_stream( client.udp )
							If network_host
								'TODO: relay update to other players (like chat messages)
								
							End If
							
						Case NET.AVATAR_INPUTS_UPDATE
							
							If network_host
								'TODO: relay update to other players (like chat messages)
								
							End If
						
						Default 'unknown - indicates error has occurred
							DebugLog( " WARNING: unknown message " + NET.decode( message_type ) + " received from UDP/" + rp_id.ToString() )
							
					End Select
				End While
			End If
		Next

		'periodical broadcasts
		If game And game.player
			'avatar state (physical object position, velocity, acceleration)
			If (now() - last_self_broadcast_avatar_state_ts) > delay_self_broadcast_avatar_state
				last_self_broadcast_avatar_state_ts = now()
				If network_host	'server
					For client = EachIn clients
						client.tcp.WriteByte( NET.AVATAR_STATE_UPDATE )
						client.tcp.WriteInt( server.local_ip )
						client.tcp.WriteShort( server.local_port )
						game.player.write_state_to_stream( client.tcp )
						While client.tcp.SendMsg() ; End While
					Next
				Else 'client
					server.tcp.WriteByte( NET.AVATAR_STATE_UPDATE )
					server.tcp.WriteInt( server.local_ip )
					server.tcp.WriteShort( server.local_port )
					game.player.write_state_to_stream( server.tcp )
					While server.tcp.SendMsg() ; End While
				End If
			End If
			'avatar inputs (from an input device on the local player's computer)
			If (now() - last_self_broadcast_inputs_ts) > delay_self_broadcast_inputs
				last_self_broadcast_inputs_ts = now()
				If network_host	'server
					For client = EachIn clients
						
					Next
				Else 'client
					
				End If
			End If
		End If

		'relay chats to all connected players except sender
		For Local cm:CHAT_MESSAGE = EachIn outgoing_messages
			DebugLog( " outgoing chat message, " + cm.username + ": " + cm.message )
			For client = EachIn clients
				rp_id = NETWORK_ID.Create( client.local_ip, client.local_port )
				If Not rp_id.equals( cm.originator )
					client.tcp.WriteByte( NET.CHAT_MESSAGE )
					client.tcp.WriteLine( cm.username + "~t" + cm.message )
					DebugLog( "  sending to " + rp_id.ToString() )
					While client.tcp.SendMsg() ; End While
				Else
					DebugLog( "  skipping " + rp_id.ToString() )
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

'______________________________________________________________________________
Function write_net_identity( out:TStream, ip%, port:Short, name$, vehicle:TJSON )
	out.WriteByte( NET.IDENTITY )
	out.WriteInt( ip )
	out.WriteShort( port )
	out.WriteLine( name + "~t" + vehicle.ToString() )
End Function

Function network_listen()
	Local tcp_server:TTCPStream = New TTCPStream
	tcp_server.Init()
	tcp_server.SetLocalPort( Short( network_port ))
  tcp_server.Listen()
	DebugLog( " listening on port " + tcp_server.GetLocalPort() )
	server = CONNECTION.Create( tcp_server )
End Function

Function connect_to_network_game%()
	Local server_id:NETWORK_ID = NETWORK_ID.Create( TNetwork.IntIP( network_ip_address ), Short( network_port ))
	Local server_player:REMOTE_PLAYER = REMOTE_PLAYER.Create( server_id )
	Local server_tcp:TTCPStream = New TTCPStream
	server_tcp.Init()
	server_tcp.SetRemoteIP( server_id.ip )
	server_tcp.SetRemotePort( server_id.port )
	server_tcp.SetLocalPort( Short( Rand( min_random_port, max_random_port )))
	If server_tcp.Connect()
		add_remote_player( server_player )
		server = CONNECTION.Create( server_tcp )
		write_net_identity( server.tcp, server.remote_ip, server.remote_port, profile.name, TJSON.Create( profile.vehicle.to_json() ))
		server.tcp.WriteByte( NET.READY )
		While server.tcp.SendMsg() ; End While
		Return True 'connection successfully initiated
	Else
		Return False 'connection to server failed
	End If
End Function

Function network_terminate()
	If server
		server.tcp.Close()
		server = Null
	End If
	For Local client:CONNECTION = EachIn clients
		If client And client.tcp
			client.tcp.Close()
		End If
	Next
	clients.Clear()
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
Type CONNECTION
	Field tcp:TTCPStream
	Field udp:TUDPStream
	
	Field local_ip%
	Field local_port:Short
	Field remote_ip%
	Field remote_port:Short
	
	Function Create:CONNECTION( tcp:TTCPStream )
		If Not tcp
			Return Null
		Else
			Local con:CONNECTION = New CONNECTION
			con.tcp = tcp
			con.local_ip = tcp.GetLocalIP()
			con.local_port = tcp.GetLocalPort()
			con.remote_ip = tcp.GetRemoteIP()
			con.remote_port = tcp.GetRemotePort()
			con.udp = New TUDPStream
			con.udp.Init()
			con.udp.SetLocalPort( con.local_port )
			con.udp.SetRemoteIP( con.remote_ip )
			con.udp.SetRemotePort( con.remote_port )
			Return con
		End If
	End Function
End Type

'______________________________________________________________________________
Type REMOTE_PLAYER
	Field net_id:NETWORK_ID
	Field name$
	Field vehicle_json:TJSON
	Field avatar:COMPLEX_AGENT
	Field brain:CONTROL_BRAIN
	
	Function Create:REMOTE_PLAYER( net_id:NETWORK_ID )
		Local rp:REMOTE_PLAYER = New REMOTE_PLAYER
		rp.net_id = net_id
		Return rp
	End Function
End Type

Function add_remote_player( rp:REMOTE_PLAYER )
	remote_players.Insert( rp.net_id.ToString(), rp )
End Function

Function get_remote_player:REMOTE_PLAYER( ip%, port:Short )
	Return REMOTE_PLAYER( remote_players.ValueForKey( TNetwork.StringIP( ip ) + ":" + port ))
End Function

Function get_remote_player_by_id:REMOTE_PLAYER( id:NETWORK_ID )
	If Not id Then Return Null
	Return REMOTE_PLAYER( remote_players.ValueForKey( id.ToString() ))
End Function

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
	Const AVATAR_INPUTS_UPDATE:Byte = 21
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
			Case AVATAR_INPUTS_UPDATE; Return "AVATAR_INPUTS_UPDATE"
			Case CHAT_MESSAGE; Return "CHAT_MESSAGE"
			Default; Return String.FromInt( Int( code ))
		End Select
	End Function
End Type




