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
Global send_id%, receive_id%, last_received%[32]

Type NET_MSG
	Const ACK = 10
	Const PING = 20
	Const PONG = 21
	Const JOIN = 100
	Const QUIT = 110
	Const PHYSICAL_OBJECT_STATE = 1000
	
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
					WriteInt( network_stream, n.send_id )
					WriteByte( network_stream, JOIN )
				Case QUIT
					WriteInt( network_stream, n.send_id )
					WriteByte( network_stream, QUIT )
			End Select
			SendUDP
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
						WriteInt( network_stream, send_id )
						WriteByte( network_stream, JOIN )
						SendUDP
						ts = now()
						If retry < 20
							retry :+ 1
						Else 'give up
							network_messages.Remove( current_net_msg )
						End If
					End If
					
				Case QUIT
					If now() - ts > 100
						WriteInt( network_stream, n.send_id )
						WriteByte( network_stream, QUIT )
						SendUDP
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
	
End Function



