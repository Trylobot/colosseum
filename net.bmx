Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_host% = False 'can be set with command line argument
Global network_connected_to_host% = False
Global network_host_ping% 

Global network_host_ip_address% = IntIP( "127.0.0.1" ) 'ip_address )
Global network_host_port:Short = 6112
Global network_client_ip_address%[] = New Int[32]
Global network_client_port:Short[] = New Short[32]
Global network_client_ping%[] = New Int[32]
Global network_clients_connected% = 0

Global current_net_msg:NET_MSG
Global network_messages:TList = CreateList()

Global network_stream:TUDPStream
Global last_network_update_ts%
Global last_network_ping_ts%
Global send_id%
Global receive_id%
Global last_received%[32]

Type NET_MSG
	Const ACK:Short = 1
	Const PING:Short = 5
	Const PONG:Short = 6
	Const JOIN:Short = 10
	Const QUIT:Short = 11
	Const PHYSICAL_OBJECT_STATE:Short = 20
	
	Field packet_id%
	Field send_id%
	Field ts%
	Field retry%
	
	Function Create:NET_MSG( packet_id% )
		If network_stream
			Local n:NET_MSG = New NET_MSG
			n.packet_id = packet_id
			n.send_id = send_id
			Select packet_id
				Case JOIN
					network_stream.WriteInt( n.send_id )
					network_stream.WriteByte( JOIN )
				Case QUIT
					network_stream.WriteInt( n.send_id )
					network_stream.WriteByte( QUIT )
			End Select
			send_udp()
			n.ts = now()
			Return n
		End If
		Return Null
	End Function
	
	Method handle() 're-sends packets
		If network_stream
			Select packet_id
				
				Case JOIN
					If now() - ts > 100
						network_stream.WriteInt( send_id )
						network_stream.WriteByte( JOIN )
						send_udp()
						ts = now()
						If retry < 20
							retry :+ 1
						Else 'give up
							network_messages.Remove( current_net_msg )
						End If
					End If
					
				Case QUIT
					If now() - ts > 100
						network_stream.WriteInt( current_net_msg.send_id )
						network_stream.WriteByte( QUIT )
						send_udp()
						ts = now()
					End If
					
			End Select
		End If
	End Method
End Type

Function clear_last_received()
	For Local i% = 0 To last_received.length - 1
		last_received[i] = -1
	Next
End Function

Function update_network()
	If network_connected_to_host
		'ping
		If now() - last_network_ping_ts > 1000
			network_stream.WriteInt( send_id )
			network_stream.WriteByte( NET_MSG.PING )
			send_udp()
			last_network_ping_ts = now()
		End If
		'inform network of local player's state
		If now() - last_network_update_ts > 100
			If game And game.player
				network_stream.WriteInt( send_id )
				network_stream.WriteByte( NET_MSG.PHYSICAL_OBJECT_STATE )
				write_PHYSICAL_OBJECT_to_stream( network_stream, game.player )
				send_udp()
			End If
			last_network_update_ts = now()
		End If
	End If
	
	If RecvUDPMsg( network_stream )
		receive_id      = network_stream.ReadInt()
		Local data:Byte = network_stream.ReadByte()
		Local ip%       = UDPMsgIP( network_stream )
		Local port%     = UDPMsgPort( network_stream )
		
		If net_msg_is_new( receive_id, data )
			Select data
				
				Case NET_MSG.JOIN
					If network_host
						network_client_ip_address[network_clients_connected] = ip
						network_client_port[network_clients_connected] = port
						net_ack( receive_id )
						'network_clients_connected :+ 1
					End If
					
				Case NET_MSG.PING
					network_stream.WriteInt( send_id )
					network_stream.WriteByte( NET_MSG.PONG )
					send_udp()
					
				Case NET_MSG.PONG
					network_host_ping = (now() - last_network_ping_ts) / 2
					
				Case NET_MSG.ACK
					remove_net_msg( network_stream.ReadInt() )
					
				Case NET_MSG.PHYSICAL_OBJECT_STATE
					If game And game.network_players And Not game.network_players.IsEmpty()
						Local obj:PHYSICAL_OBJECT = PHYSICAL_OBJECT( game.network_players.First() )
						read_PHYSICAL_OBJECT_from_stream( network_stream, obj )
					End If
					
				Case NET_MSG.QUIT
					'what to do?
					net_ack( receive_id )
				
			End Select
		End If
	End If
End Function

Function write_PHYSICAL_OBJECT_to_stream( stream:TStream, obj:PHYSICAL_OBJECT )
	If obj
		stream.WriteInt( obj.pos_x )
		stream.WriteInt( obj.pos_y )
		stream.WriteInt( obj.ang )
		stream.WriteInt( obj.vel_x )
		stream.WriteInt( obj.vel_y )
		stream.WriteInt( obj.ang_vel )
		stream.WriteInt( obj.acc_x )
		stream.WriteInt( obj.acc_y )
		stream.WriteInt( obj.ang_acc )
	End If
End Function

Function read_PHYSICAL_OBJECT_from_stream( stream:TStream, obj:PHYSICAL_OBJECT )
	If obj
		obj.pos_x = stream.ReadInt()
		obj.pos_y = stream.ReadInt()
		obj.ang = stream.ReadInt()
		obj.vel_x = stream.ReadInt()
		obj.vel_y = stream.ReadInt()
		obj.ang_vel = stream.ReadInt()
		obj.acc_x = stream.ReadInt()
		obj.acc_y = stream.ReadInt()
		obj.ang_acc = stream.ReadInt()
	End If
End Function

Function send_udp()
	If network_host
		SendUDPMsg( network_stream, network_client_ip_address[network_clients_connected], network_client_port[network_clients_connected] )
	Else
		SendUDPMsg( network_stream, network_host_ip_address, network_host_port )
	End If
	send_id :+ 1
End Function

Function net_msg_is_new%( packet_id%, data% = 0 )
	For Local i% = last_received.length - 1 To 0 Step -1
		last_received[i + 1] = last_received[i]
	Next
	last_received[0] = packet_id
	For Local i% = 1 Until last_received.length
		If last_received[i] = last_received[0] 'dupe
			Select data
				Case NET_MSG.JOIN, NET_MSG.QUIT
					net_ack( packet_id )
			End Select
			Return False
		End If
	Next
	Return True
End Function

Function net_connect_to_host()
	Local connect_attempt_ts% = now()
	network_messages.AddLast( NET_MSG.Create( NET_MSG.JOIN ))
	clear_last_received()

	Local bitch_fucking_connected% = 0
	Repeat
		If RecvUDPMsg( network_stream )
			receive_id      = network_stream.ReadInt()
			Local data:Byte = network_stream.ReadByte()
			Local ip%       = UDPMsgIP( network_stream )
			Local port%     = UDPMsgPort( network_stream )
			If data = NET_MSG.ACK
				remove_net_msg( network_stream.ReadInt() )
				bitch_fucking_connected = 1
			End If
		End If
		
		For Local n:NET_MSG = EachIn network_messages
			n.handle()
		Next
		
		If (now() - connect_attempt_ts) > 2000
			bitch_fucking_connected = -1
		End If
	Until bitch_fucking_connected <> 0
	
	For Local n:NET_MSG = EachIn network_messages
		network_messages.Remove( n )
	Next
	
	If bitch_fucking_connected = 1
		network_connected_to_host = True
	Else
		network_connected_to_host = False
	End If
End Function

Function net_disconnect()
	network_messages.AddLast( NET_MSG.Create( NET_MSG.QUIT ))
	
	Local bitch_fucking_disconnected% = 0
	Repeat
		If RecvUDPMsg( network_stream )
			receive_id      = network_stream.ReadInt()
			Local data:Byte = network_stream.ReadByte()
			Local ip%       = UDPMsgIP( network_stream )
			Local port%     = UDPMsgPort( network_stream )
			If data = NET_MSG.ACK
				remove_net_msg( network_stream.ReadInt() )
				bitch_fucking_disconnected = 1
			End If
		End If
		
		For Local n:NET_MSG = EachIn network_messages
			n.handle()
		Next
	Until bitch_fucking_disconnected <> 0
	
	For Local n:NET_MSG = EachIn network_messages
		network_messages.Remove( n )
	Next
	network_connected_to_host = False
	network_stream.close()
	network_stream = Null
End Function

Function remove_net_msg( ack_id% )
	For Local n:NET_MSG = EachIn network_messages
		If n.send_id = ack_id
			Local temp_id% = n.packet_id
			network_messages.Remove( n )
			For Local n:NET_MSG = EachIn network_messages
				If n.packet_id = temp_id And n.send_id <= ack_id
					network_messages.Remove( n )
				End If
			Next
			Exit
		End If
	Next
End Function

Function net_ack( receive_id% )
	network_stream.WriteInt( send_id )
	network_stream.WriteByte( NET_MSG.ACK )
	network_stream.WriteInt( receive_id )
	send_udp()
End Function

