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

Global udp_in:TUDPStream
'if client, this list will contain only the host
'if hosting, this list will contain all connected clients
Global remote_player_list:TList = CreateList() 'TList<REMOTE_PLAYER>

Global outgoing_messages:TList = CreateList() 'TList<CHAT_MESSAGE>
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>
Const chat_stay_time% = 8000
Const chat_fade_time% = 2000
Const min_random_port:Short = 59000
Const max_random_port:Short = 60000

Function update_network()
	If playing_multiplayer
		'receive any available UDP messages
		If udp_in
			If udp_in.RecvAvail()
				While udp_in.RecvMsg() ; End While
				If udp_in.Size() > 0
					Local ip_address% = udp_in.GetMsgIP()
					Local port:Short = udp_in.GetMsgPort()
					Local message_type:Byte = udp_in.ReadByte()
					DebugLog( " " + NET.decode( message_type ) + " from " + TNetwork.StringIP( ip_address ) + ":" + port )
					Select message_type
						Case NET.CLIENT_REQUEST_CONNECT, NET.SERVER_CONFIRM_CONNECTED
							Local vehicle_json_string$ = udp_in.ReadLine()
							Local username$ = udp_in.ReadLine()
							Local net_id:NETWORK_ID
							If message_type = NET.CLIENT_REQUEST_CONNECT
								net_id = NETWORK_ID.Create( ip_address, port )
							Else	'message_type = NET.SERVER_CONFIRM_CONNECTED
								net_id = NETWORK_ID.Create( ip_address, network_port )
							End If
							Local rp:REMOTE_PLAYER = REMOTE_PLAYER.Create( net_id, username, TJSON.Create( vehicle_json_string ))
							If add_remote_player( rp ) 'uniqueness by IP
								If message_type = NET.CLIENT_REQUEST_CONNECT
									rp.udp_out = create_udp( rp.net_id )
								Else	'message_type = NET.SERVER_CONFIRM_CONNECTED
									rp.udp_out = udp_in 'already created, used to connect initially
								End If
								DebugLog( " added remote player " + net_id.to_string() )
								send_system_message( rp.name + " has joined the game" )
								If message_type = NET.CLIENT_REQUEST_CONNECT
									connect( rp.udp_out ) 'respond to client with own information
								End If
							Else
								DebugLog( " remote player " + net_id.to_string() + " could not be added; already exists" )
							End If
          Case NET.DISCONNECT
							'disconnect_from( NETWORK_ID.Create( ip_address, network_port ))
							'TODO: replace ip:port with username on file for that ip:port
							send_system_message( TNetwork.StringIP( ip_address ) + ":" + port + " has left the game" )
						Case NET.CHAT_MESSAGE
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( udp_in.ReadLine(), udp_in.ReadLine() )
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
		
		'send any pending UDP messages
		If Not remote_player_list.IsEmpty() And Not outgoing_messages.IsEmpty()
			For Local message:Object = EachIn outgoing_messages
				If CHAT_MESSAGE(message)
					'broadcast the outgoing chat message to all connected clients, except the originator
					Local cm:CHAT_MESSAGE = CHAT_MESSAGE(message)
					DebugLog( " outgoing chat message, " + cm.username + ": " + cm.message )
					For Local rp:REMOTE_PLAYER = EachIn remote_player_list
						If Not rp.net_id.equals( cm.originator )
							rp.udp_out.WriteByte( NET.CHAT_MESSAGE )
							rp.udp_out.WriteLine( cm.message )
							rp.udp_out.WriteLine( cm.username )
							DebugLog( "  sending to " + rp.net_id.to_string() )
							rp.udp_out.SendMsg()
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
			Local cm:CHAT_MESSAGE
			Local cm_link:TLink = chat_message_list.FirstLink()
			Local del_target:TLink
			Repeat
				cm = CHAT_MESSAGE( cm_link.Value() )
				If time_alpha_pct( cm.added_ts + chat_stay_time, chat_fade_time, False ) = 0
					del_target = cm_link
					cm_link = cm_link.NextLink()
					del_target.Remove()
				Else
					cm_link = cm_link.NextLink()
				End If
			Until Not cm_link
		End If

	End If
End Function

Function network_listen()
	udp_in = New TUDPStream
	udp_in.Init()
	udp_in.SetLocalPort( network_port )
	DebugLog( " listening on port " + udp_in.GetLocalPort() )
End Function

Function connect_to_network_game()
	Local server:NETWORK_ID = NETWORK_ID.Create( TNetwork.IntIP( network_ip_address ), Short( network_port ))
	Local server_stream:TUDPStream = create_udp( server )
	connect( server_stream )
	udp_in = server_stream 'experimental
End Function

Function create_udp:TUDPStream( ent:NETWORK_ID )
	If ent
		Local udp_out:TUDPStream = New TUDPStream
		udp_out.Init()
		udp_out.SetRemoteIP( ent.ip )
		udp_out.SetRemotePort( ent.port )
		DebugLog( " created outgoing UDP stream for " + ent.to_string() )
		If Not network_host
			udp_out.SetLocalPort( Rand( min_random_port, max_random_port ))
			DebugLog( " listening for server reply on " + udp_out.GetLocalPort() )
		End If
		Return udp_out
	End If
End Function

Function connect( udp_out:TUDPStream )
	If udp_out
		If Not network_host 'client
			udp_out.WriteByte( NET.CLIENT_REQUEST_CONNECT )
			DebugLog( " sending CLIENT_REQUEST_CONNECT to server" )
		Else
			udp_out.WriteByte( NET.SERVER_CONFIRM_CONNECTED )
			DebugLog( " sending SERVER_CONFIRM_CONNECTED to client" )
		End If
		udp_out.WriteLine( profile.vehicle.to_json().ToString() )
		udp_out.WriteLine( profile.name )
		udp_out.SendMsg()
	End If
End Function

Function network_terminate()
	If udp_in
		udp_in.Close()
		udp_in = Null
	End If
	If Not remote_player_list.IsEmpty()
		For Local rp:REMOTE_PLAYER = EachIn remote_player_list
			If rp.udp_out
				rp.udp_out.Close()
				rp.udp_out = Null
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
	Field net_id:NETWORK_ID
	Field name$
	Field brain:CONTROL_BRAIN
	Field agent:COMPLEX_AGENT
	Field udp_out:TUDPStream
	
	Function Create:REMOTE_PLAYER( net_id:NETWORK_ID, name$, vehicle_json:TJSON )
		Local rp:REMOTE_PLAYER = New REMOTE_PLAYER
		rp.net_id = net_id
		rp.name = name
		rp.agent = create_player( Create_VEHICLE_DATA_from_json( vehicle_json ), False, False )
		rp.brain = Create_CONTROL_BRAIN( rp.agent, CONTROL_BRAIN.CONTROL_TYPE_REMOTE )
		Return rp
	End Function
End Type

Function add_remote_player%( rp:REMOTE_PLAYER )
	For Local list_rp:REMOTE_PLAYER = EachIn remote_player_list
		If rp.net_id.equals( list_rp.net_id )
			Return False
		End If
	Next
	rp.manage( remote_player_list )
	Return True
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
	Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( "server", message, True, True )
	chat_message_list.AddFirst( cm )
	outgoing_messages.AddLast( cm )
End Function

'______________________________________________________________________________
Type NET
	Const CLIENT_REQUEST_CONNECT:Byte = 1
	Const SERVER_CONFIRM_CONNECTED:Byte = 2
	Const DISCONNECT:Byte = 5
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

