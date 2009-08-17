Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_host% = False
Global network_ip_address$
Global network_port%
Global network_level$ = "levels/duel.colosseum_level"

Global tcp_server:TTCPStream
Global tcp_client:TTCPStream

Global remote_players:TMap = CreateMap() 'TMap<NETWORK_ID,REMOTE_PLAYER>
Function get_remote_player:REMOTE_PLAYER( net_id:NETWORK_ID )
	Return REMOTE_PLAYER( remote_players.ValueForKey( net_id.to_string() ))
End Function

Global outgoing_messages:TList = CreateList() 'TList<CHAT_MESSAGE>
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>

Const chat_stay_time% = 8000
Const chat_fade_time% = 2000
Const min_random_port:Short = 59000
Const max_random_port:Short = 60000

Function update_network()
	If playing_multiplayer
		Local net_id:NETWORK_ID
		Local rp:REMOTE_PLAYER
		
		If network_host
			
			'add new clients
			tcp_client = Null
			Repeat
				tcp_client = tcp_server.Accept()
				If tcp_client
					net_id = NETWORK_ID.Create( tcp_client.getlocalip(), tcp_client.getlocalport() )
					rp = REMOTE_PLAYER.Create( tcp_client, net_id )
					remote_players.Insert( net_id.to_string(), rp )
					'send the client information about each other connected player, including self
						tcp_server.WriteByte( NET.PROFILE_NAME )
						tcp_server.WriteLine( profile.name )
						tcp_server.SendMsg()
						tcp_server.WriteByte( NET.VEHICLE_DATA )
						tcp_server.WriteLine( profile.vehicle.to_json().ToString() )
						tcp_server.SendMsg()
						For rp = EachIn remote_players.Values()
							tcp_server.WriteByte( NET.PROFILE_NAME )
							tcp_server.WriteLine( rp.name )
							tcp_server.SendMsg()
							tcp_server.WriteByte( NET.VEHICLE_DATA )
							tcp_server.WriteLine( rp.vehicle_json.ToString() )
							tcp_server.SendMsg()
						Next
						tcp_server.WriteByte(NET.READY)
						tcp_server.SendMsg()
				End If
			Until Not tcp_client
			'process each connected client
			For rp = EachIn remote_players.Values()
				tcp_client = rp.tcp_stream
				net_id = rp.net_id
				'remove disconnected clients
				If tcp_client.GetState() <> 1
					tcp_client.Close()
					tcp_clients.Remove( tcp_client )
					Continue 'next
					'TODO: automatic re-connect attempts after disconnect
				End If
				'check for and process messages from this connected client
				If tcp_client.RecvAvail()
					While tcp_client.RecvMsg() ; End While
					If tcp_client.Size() > 0
						Local message_type:Byte = tcp_client.ReadByte()
						DebugLog( " " + NET.decode( message_type ) + " from " + net_id.to_string() )
						Select message_type
							
							Case NET.PROFILE_NAME
								Local remote_player_name$ = tcp_client.ReadLine()
								rp.name = remote_player_name
								
							Case NET.VEHICLE_DATA
								Local vehicle_json_string$ = tcp_client.ReadLine()
								Local vehicle_data_json:TJSON = TJSON.Create( vehicle_json_string )
								rp.vehicle_json = vehicle_data_json
								Local vd:VEHICLE_DATA = Create_VEHICLE_DATA_from_json( vehicle_data_json )
								rp.avatar = create_player( vd, False, False )
								rp.brain = Create_CONTROL_BRAIN( rp.agent, CONTROL_BRAIN.CONTROL_TYPE_REMOTE )
								
							Case NET.READY
								'?
								
							Case NET.VEHICLE_STATE_UPDATE
								rp.avatar.read_from_stream( tcp_client )
								
							Case NET.CHAT_MESSAGE
								Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( tcp_client.ReadLine(), tcp_client.ReadLine() )
								cm.originator = net_id
								chat_message_list.AddFirst( cm )
								outgoing_messages.AddLast( cm )
								
						End Select
					End If
				End If
			Next

		Else 'Not network_host
			
			'check if disconnected from server
			If tcp_server.GetState() <> 1
				tcp_server.Close()
			End If
			If tcp_server.RecvAvail()
				While tcp_server.RecvMsg() ; End While
			End If
			'check for and process messages from the server
			If tcp_server.RecvAvail()
				While tcp_server.RecvMsg() ; End While
				If tcp_server.Size() > 0
					Local message_type:Byte = tcp_server.ReadByte()
					DebugLog( " " + NET.decode( message_type ) + " from " + net_id.to_string() )
					Select message_type
						
						Case NET.PROFILE_NAME
							Local remote_player_name$ = tcp_server.ReadLine()
							'rp.name = remote_player_name
							
						Case NET.VEHICLE_DATA
							Local vehicle_json_string$ = tcp_server.ReadLine()
							Local vehicle_data_json:TJSON = TJSON.Create( vehicle_json_string )
							'rp.vehicle_json = vehicle_data_json
							Local vd:VEHICLE_DATA = Create_VEHICLE_DATA_from_json( vehicle_data_json )
							'rp.avatar = create_player( vd, False, False )
							'rp.brain = Create_CONTROL_BRAIN( rp.agent, CONTROL_BRAIN.CONTROL_TYPE_REMOTE )
							
						Case NET.READY
							'?
							
						Case NET.VEHICLE_STATE_UPDATE
							'rp.avatar.read_from_stream( tcp_server )
							
						Case NET.CHAT_MESSAGE
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( tcp_server.ReadLine(), tcp_server.ReadLine() )
							chat_message_list.AddFirst( cm )
							
					End Select
				End If
			End If
				
		End If
		
		'send any pending messages
		If Not remote_player_list.IsEmpty() And Not outgoing_messages.IsEmpty()
			For Local message:Object = EachIn outgoing_messages
				If CHAT_MESSAGE(message)
					'broadcast the outgoing chat message to all connected clients, except the originator
					Local cm:CHAT_MESSAGE = CHAT_MESSAGE(message)
					DebugLog( " outgoing chat message, " + cm.username + ": " + cm.message )
					For Local rp:REMOTE_PLAYER = EachIn remote_player_list
						If Not rp.net_id.equals( cm.originator )
							rp.tcp_out.WriteByte( NET.CHAT_MESSAGE )
							rp.tcp_out.WriteLine( cm.message )
							rp.tcp_out.WriteLine( cm.username )
							DebugLog( "  sending to " + rp.net_id.to_string() )
							rp.tcp_out.SendMsg()
						Else
							DebugLog( "  skipping " + rp.net_id.to_string() )
						End If
					Next
				End If
			Next
		End If
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

Function connect_to_network_game%()
	tcp_server = New TTCPStream
	tcp_server.Init()
	tcp_server.SetRemoteIP( TNetwork.IntIP( network_ip_address ))
	tcp_server.SetRemotePort( Short( network_port ))
	tcp_server.SetLocalPort( Short( Rand( min_random_port, max_random_port )))
	If tcp_server.Connect()
		'send the server all the data it needs
		tcp_server.WriteByte( NET.PROFILE_NAME )
		tcp_server.WriteLine( profile.name )
		tcp_server.SendMsg()
		tcp_server.WriteByte( NET.VEHICLE_DATA )
		tcp_server.WriteLine( profile.vehicle.to_json().ToString() )
		tcp_server.SendMsg()
		tcp_server.WriteByte( NET.READY )
		tcp_server.SendMsg()
		Return True
	Else
		'could not connect
		Return False
	End If
End Function

Function network_terminate()
	Rem
	If tcp_in
		tcp_in.Close()
		tcp_in = Null
	End If
	If Not remote_player_list.IsEmpty()
		For Local rp:REMOTE_PLAYER = EachIn remote_player_list
			If rp.tcp_out
				rp.tcp_out.Close()
				rp.tcp_out = Null
			End If
		Next
	End If
	remote_player_list.Clear()
	End Rem
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
	
	Method to_string$()
		Return TNetwork.StringIP( ip ) + ":" + port
	End Method
	
	Method equals%( other:NETWORK_ID )
		Return (other And ip = other.ip And port = other.port)
	End Method
End Type

'______________________________________________________________________________
Type REMOTE_PLAYER Extends MANAGED_OBJECT
	Field tcp_stream:TTCPStream
	Field net_id:NETWORK_ID
	
	Field name$
	Field vehicle_json:TJSON
	Field avatar:COMPLEX_AGENT
	Field brain:CONTROL_BRAIN
	
	Function Create:REMOTE_PLAYER( net_id:NETWORK_ID, tcp_stream:TTCPStream )
		Local rp:REMOTE_PLAYER = New REMOTE_PLAYER
		rp.tcp_stream = tcp_client
		rp.net_id = net_id
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
	Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( "server", message, True, True )
	chat_message_list.AddFirst( cm )
	outgoing_messages.AddLast( cm )
End Function

'______________________________________________________________________________
Type NET
	Const READY:Byte = 1
	Const PROFILE_NAME:Byte = 5
	Const VEHICLE_DATA:Byte = 10
	Const VEHICLE_STATE_UPDATE:Byte = 11
	Const LEVEL_NAME:Byte = 15
	Const ENVIRONMENT_STATE_UPDATE:Byte = 16
	Const CHAT_MESSAGE:Byte = 100

	Function decode$( code:Byte )
		Select code
			Case READY; Return "READY"
			Case PROFILE_NAME; Return "PROFILE_NAME"
			Case VEHICLE_DATA; Return "VEHICLE_DATA"
			Case VEHICLE_STATE_UPDATE; Return "VEHICLE_STATE_UPDATE"
			Case LEVEL_NAME; Return "LEVEL_NAME"
			Case ENVIRONMENT_STATE_UPDATE; Return "ENVIRONMENT_STATE_UPDATE"
			Case CHAT_MESSAGE; Return "CHAT_MESSAGE"
			Default; Return String.FromInt( Int( code ))
		End Select
	End Function
End Type

'______________________________________________________________________________
Type NET_MSG
	Field code:Byte
	Function Create:NET_MSG( code:Byte )
		Local nm:NET_MSG = New NET_MSG
		nm.code = code
		Return nm
	End Function
End Type













