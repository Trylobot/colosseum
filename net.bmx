Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_host% = False 'can be set with command line argument
Global network_connected% = False

Global current_net_msg:NET_MSG
Global network_messages:TList = CreateList()

Global network_stream:TUDPStream
Global last_network_update_ts%
Global last_network_ping_ts%
Global send_id%, receive_id%, last_received%[32]

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
						network_stream.WriteInt( n.send_id )
						network_stream.WriteByte( QUIT )
						send_udp()
						ts = now()
					End If
					
			End Select
		End If
	End Method
End Type

Function clear_last_received()
	For i = 0 To last_received.length - 1
		last_received[i] = -1
	Next
End Function

Function update_network()
	If network_connected
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
					If Not network_connected And network_host
						
					End If
				
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

