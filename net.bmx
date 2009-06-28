Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_UDP_stream:TUDPStream
Global network_TCP_stream:TTCPStream

Global network_client_ip_address%[] = New Int[32]
Global network_client_port:Short[] = New Short[32]
Global network_clients_connected% = 0

Type NETWORK_PACKET
	'valid packet classes
	Const JOIN:Byte = 10
	Const QUIT:Byte = 11
	Const CHAT_MESSAGE:Byte = 20
	Const PHYSICAL_OBJECT:Byte = 100
	
	'instance object fields
	Field packet_class:Byte
	Field data:Object
	
	Function Create:NETWORK_PACKET( packet_class:Byte, data:Object = Null )
		If network_UDP_stream
			Local p:NETWORK_PACKET = New NETWORK_PACKET
			p.packet_class = packet_class
			p.data = data
			Return p
		End If
		Return Null
	End Function
	
	Method send()
		Select packet_class
			Case JOIN, QUIT, CHAT_MESSAGE
				send_tcp()
			Case PHYSICAL_OBJECT
				send_udp( network_UDP_stream, 0, 0 )
		End Select
		Rem
		If network_stream
			If network_host And network_clients_connected > 0
				For Local i% = 0 Until network_clients_connected
					send_driver( network_stream, network_client_ip_address[i], network_client_port[i] )
				Next
			Else 'Not network_host
				send_driver( network_stream, IntIP( network_ip_address ), network_port )
			End If
		End If
		EndRem
	End Method
	
	Method send_udp( stream:TStream, ip%, port% )
		Rem
		network_stream.WriteInt( send_id )
		network_stream.WriteByte( packet_class )
		Select packet_class
			Case PHYSICAL_OBJECT
				write_PHYSICAL_OBJECT_to_stream( network_stream, PHYSICAL_OBJECT( data ))
			Case CHAT_MESSAGE
				stream.WriteString( String(data) )
		End Select
		SendUDPMsg( network_stream, ip, port )
		EndRem
	End Method
	
	Method send_tcp()
		
	End Method

End Type

Function update_network()
	Rem
	If network_stream
		If network_host
			
			
		Else 'Not network_host
			
			
		End If
	End If
	EndRem
	
	Rem
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
					DebugLog "NET_MSG.JOIN"
					
				Case NET_MSG.PING
					network_stream.WriteInt( send_id )
					network_stream.WriteByte( NET_MSG.PONG )
					send_udp()
					DebugLog "NET_MSG.PING"
					
				Case NET_MSG.PONG
					network_host_ping = (now() - last_network_ping_ts) / 2
					DebugLog "NET_MSG.PONG"
					
				Case NET_MSG.ACK
					remove_net_msg( network_stream.ReadInt() )
					DebugLog "NET_MSG.ACK"
					
				Case NET_MSG.PHYSICAL_OBJECT_STATE
					If game And game.network_players And Not game.network_players.IsEmpty()
						Local obj:PHYSICAL_OBJECT = PHYSICAL_OBJECT( game.network_players.First() )
						read_PHYSICAL_OBJECT_from_stream( network_stream, obj )
					End If
					DebugLog "NET_MSG.PHYSICAL_OBJECT_STATE"
					
				Case NET_MSG.QUIT
					'what to do?
					net_ack( receive_id )
					DebugLog "NET_MSG.QUIT"
				
			End Select
		End If
	End If
	EndRem
End Function



