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
Global tcp_clients:TList = CreateList() 'TList<TTCPStream>
Global tcp_client:TTCPStream
Global remote_player_list:TList = CreateList() 'TList<REMOTE_PLAYER>

Global outgoing_messages:TList = CreateList() 'TList<CHAT_MESSAGE>
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>

Const chat_stay_time% = 8000
Const chat_fade_time% = 2000
Const min_random_port:Short = 59000
Const max_random_port:Short = 60000

Function update_network()
	If playing_multiplayer
		If network_host
		
			'add new clients
			tcp_client = Null
			Repeat
				tcp_client = tcp_in.Accept()
				If tcp_client
					tcp_clients.AddLast( tcp_client )
					Local rp:REMOTE_PLAYER = New REMOTE_PLAYER
					rp.tcp_connection = tcp_client
					remote_player_list.AddLast( rp )
				End If
			Until Not tcp_client
			
			'process each connected client
			For tcp_client = EachIn tcp_clients
				'remove disconnected clients
				If tcp_client.GetState() <> 1
					tcp_client.Close()
					tcp_clients.Remove( tcp_client )
					Continue 'next
					'TODO: automatic re-connect attempts
				End If
				'check for and process messages from this connected client
				If tcp_client.RecvAvail()
					While tcp_client.RecvMsg() ; End While
					If tcp_client.Size() > 0
						Local ip_address% = tcp_client.GetLocalIP()
						Local port:Short = tcp_client.GetLocalPort()
						Local message_type:Byte = tcp_client.ReadByte()
						DebugLog( " " + NET.decode( message_type ) + " from " + TNetwork.StringIP( ip_address ) + ":" + port )
						Select message_type
							
							Case NET.HANDSHAKE
								rem
								Local net_id:NETWORK_ID = NETWORK_ID.Create( ip_address, port )
								Local rp:REMOTE_PLAYER = REMOTE_PLAYER.Create( net_id, username, TJSON.Create( vehicle_json_string ))
								If add_remote_player( rp ) 'uniqueness by IP
									If message_type = NET.CLIENT_REQUEST_CONNECT
										rp.tcp_out = create_tcp( rp.net_id )
									Else	'message_type = NET.SERVER_CONFIRM_CONNECTED
										rp.tcp_out = tcp_in 'already created, used to connect initially
									End If
									DebugLog( " added remote player " + net_id.to_string() )
									send_system_message( rp.name + " has joined the game" )
									If message_type = NET.CLIENT_REQUEST_CONNECT
										connect( rp.tcp_out ) 'respond to client with own information
									End If
								Else
									DebugLog( " remote player " + net_id.to_string() + " could not be added; already exists" )
								End If
								endrem
							Case NET.PROFILE_NAME
								Local username$ = tcp_in.ReadLine()
								
							Case NET.VEHICLE_DATA
								Local vehicle_json_string$ = tcp_in.ReadLine()
								
						End Select
					End If
				End If
			Next
			
		Else 'Not network_host
			
			
			
		End If
		
		rem
		'receive any available messages
		If tcp_in
			If tcp_in.RecvAvail()
				While tcp_in.RecvMsg() ; End While
				If tcp_in.Size() > 0
					Local ip_address% = tcp_in.GetMsgIP()
					Local port:Short = tcp_in.GetMsgPort()
					Local message_type:Byte = tcp_in.ReadByte()
					DebugLog( " " + NET.decode( message_type ) + " from " + TNetwork.StringIP( ip_address ) + ":" + port )
					Select message_type
						Case NET.CLIENT_REQUEST_CONNECT, NET.SERVER_CONFIRM_CONNECTED
							Local vehicle_json_string$ = tcp_in.ReadLine()
							Local username$ = tcp_in.ReadLine()
							Local net_id:NETWORK_ID
							If message_type = NET.CLIENT_REQUEST_CONNECT
								net_id = NETWORK_ID.Create( ip_address, port )
							Else	'message_type = NET.SERVER_CONFIRM_CONNECTED
								net_id = NETWORK_ID.Create( ip_address, network_port )
							End If
							Local rp:REMOTE_PLAYER = REMOTE_PLAYER.Create( net_id, username, TJSON.Create( vehicle_json_string ))
							If add_remote_player( rp ) 'uniqueness by IP
								If message_type = NET.CLIENT_REQUEST_CONNECT
									rp.tcp_out = create_tcp( rp.net_id )
								Else	'message_type = NET.SERVER_CONFIRM_CONNECTED
									rp.tcp_out = tcp_in 'already created, used to connect initially
								End If
								DebugLog( " added remote player " + net_id.to_string() )
								send_system_message( rp.name + " has joined the game" )
								If message_type = NET.CLIENT_REQUEST_CONNECT
									connect( rp.tcp_out ) 'respond to client with own information
								End If
							Else
								DebugLog( " remote player " + net_id.to_string() + " could not be added; already exists" )
							End If
          Case NET.DISCONNECT
							'disconnect_from( NETWORK_ID.Create( ip_address, network_port ))
							'TODO: replace ip:port with username on file for that ip:port
							send_system_message( TNetwork.StringIP( ip_address ) + ":" + port + " has left the game" )
						Case NET.CHAT_MESSAGE
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( tcp_in.ReadLine(), tcp_in.ReadLine() )
							chat_message_list.AddFirst( cm )
							If network_host
								cm.originator = NETWORK_ID.Create( ip_address, port )
								outgoing_messages.AddLast( cm )
							End If
							DebugLog( " received chat message, "+cm.username+": "+cm.message )
					End Select
				End If
			End If
		End If
		endrem
		
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
	tcp_in = New TTCPStream
	tcp_in.Init()
	tcp_in.SetLocalPort( network_port )
  tcp_in.Listen()
	DebugLog( " listening on port " + tcp_in.GetLocalPort() )
End Function

Function connect_to_network_game()
	Local server:NETWORK_ID = NETWORK_ID.Create( TNetwork.IntIP( network_ip_address ), Short( network_port ))
	Local server_stream:TTCPStream = create_tcp( server )
	connect( server_stream )
	tcp_in = server_stream 'experimental
End Function

Function create_tcp:TTCPStream( ent:NETWORK_ID )
	If ent
		Local tcp_out:TTCPStream = New TTCPStream
		tcp_out.Init()
		tcp_out.SetRemoteIP( ent.ip )
		tcp_out.SetRemotePort( ent.port )
		DebugLog( " created outgoing UDP stream for " + ent.to_string() )
		If Not network_host
			tcp_out.SetLocalPort( Rand( min_random_port, max_random_port ))
			DebugLog( " listening for server reply on " + tcp_out.GetLocalPort() )
		End If
		Return tcp_out
	End If
End Function

Function connect( tcp_out:TTCPStream )
	If tcp_out
		If Not network_host 'client
			tcp_out.WriteByte( NET.CLIENT_REQUEST_CONNECT )
			DebugLog( " sending CLIENT_REQUEST_CONNECT to server" )
		Else
			tcp_out.WriteByte( NET.SERVER_CONFIRM_CONNECTED )
			DebugLog( " sending SERVER_CONFIRM_CONNECTED to client" )
		End If
		tcp_out.WriteLine( profile.vehicle.to_json().ToString() )
		tcp_out.WriteLine( profile.name )
		tcp_out.SendMsg()
	End If
End Function

Function network_terminate()
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
	Field tcp_connection:TTCPStream
	Field name$
	Field brain:CONTROL_BRAIN
	Field agent:COMPLEX_AGENT
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
	Const HANDSHAKE:Byte = 1
	Const PROFILE_NAME:Byte = 5
	Const VEHICLE_DATA:Byte = 10
	Const VEHICLE_STATE_UPDATE:Byte = 11
	Const CHAT_MESSAGE:Byte = 100
	
	Function decode$( code:Byte )
		Select code
			Case CLIENT_REQUEST_CONNECT; Return "CLIENT_REQUEST_CONNECT"
			Case SERVER_CONFIRM_CONNECTED; Return "SERVER_CONFIRM_CONNECTED"
			Case DISCONNECT; Return "DISCONNECT"
			Case CHAT_MESSAGE; Return "CHAT_MESSAGE"
			Default; Return String.FromInt( Int( code ))
		End Select
	End Function
End Type

