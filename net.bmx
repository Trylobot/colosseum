Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global udp_in:TUDPStream
Global udp_out:TUDPStream

Global outgoing_messages:TList = CreateList()
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>
Const chat_stay_time% = 8000
Const chat_fade_time% = 2000

Function update_network()
	If playing_multiplayer
		
		'receive any available UDP messages
		If udp_in
			If udp_in.RecvAvail()
DebugLog( " udp_in.RecvAvail()" )
				While udp_in.RecvMsg() ; End While
				If udp_in.Size() > 0
DebugLog( " udp_in.Size() > 0" )
					Local ip_address% = udp_in.GetMsgIP()
					Local port:Short = udp_in.GetMsgPort()
					Local message_type:Byte = udp_in.ReadByte()
DebugLog( " "+NET.decode( message_type )+" from "+TNetwork.StringIP( ip_address )+":"+port )
					Select message_type
						Case NET.JOIN
							connect_to( NETWORK_ENTITY.Create( ip_address, port ))
						Case NET.QUIT
							disconnect_from( NETWORK_ENTITY.Create( ip_address, port ))
						Case NET.CHAT_MESSAGE
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( udp_in.ReadLine(), udp_in.ReadLine() )
							chat_message_list.AddFirst( cm )
DebugLog( "   "+cm.username+": "+cm.message )
					End Select
				End If
			End If
		End If
		
		'send any pending UDP messages
		If udp_out
			If Not outgoing_messages.IsEmpty()
				For Local message:Object = EachIn outgoing_messages
					If CHAT_MESSAGE(message)
						Local cm:CHAT_MESSAGE = CHAT_MESSAGE(message)
						udp_out.WriteByte( NET.CHAT_MESSAGE )
						udp_out.WriteLine( cm.message )
						udp_out.WriteLine( cm.username )
						udp_out.SendMsg()
						chat_message_list.AddFirst( cm )
					End If
				Next
				outgoing_messages.Clear()
			End If
		End If
		
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
End Function

Function connect_to( ent:NETWORK_ENTITY )
	If Not udp_out
		udp_out = New TUDPStream
		udp_out.Init()
		udp_out.SetLocalPort()
		udp_out.SetRemoteIP( ent.ip )
		udp_out.SetRemotePort( ent.port )
		udp_out.WriteByte( NET.JOIN )
		udp_out.SendMsg()
	End If
End Function

function disconnect_from( ent:NETWORK_ENTITY )
	
End Function

Function network_terminate()
	udp_in.Close()
	udp_in = Null
	udp_out.Close()
	udp_out = Null
End Function

'______________________________________________________________________________
Type NETWORK_ENTITY
	Field ip%
	Field port:Short
	
	Function Create:NETWORK_ENTITY( ip%, port:Short )
		Local ent:NETWORK_ENTITY = New NETWORK_ENTITY
		ent.ip = ip
		ent.port = port
		Return ent
	End Function
End Type

'______________________________________________________________________________
Type CHAT_MESSAGE
	Field added_ts%
	Field username$
	Field message$
	
	Function Create:CHAT_MESSAGE( username$, message$ )
		Local cm:CHAT_MESSAGE = New CHAT_MESSAGE
		cm.added_ts = now()
		cm.username = username
		cm.message = message
		Return cm
	End Function
End Type

'______________________________________________________________________________
Type NET
	Const JOIN:Byte = 1
	Const QUIT:Byte = 2
	Const CHAT_MESSAGE:Byte = 10
	
	Function decode$( code:Byte )
		Select code
			Case JOIN; Return "JOIN"
			Case CHAT_MESSAGE; Return "CHAT_MESSAGE"
			Default; Return String.FromInt( Int( code ))
		End Select
	End Function
End Type
