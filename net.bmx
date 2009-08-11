Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global udp_in:TUDPStream
'if client, this list will contain only the host
'if hosting, this list will contain all connected clients
Global remote_player_list:TList = CreateList() 'TList<REMOTE_PLAYER>

Global outgoing_messages:TList = CreateList() 'TList<CHAT_MESSAGE>
Global chat_message_list:TList = CreateList() 'TList<CHAT_MESSAGE>
Const chat_stay_time% = 8000
Const chat_fade_time% = 2000

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
					'DebugLog( " "+NET.decode( message_type )+" from "+TNetwork.StringIP( ip_address )+":"+port )
					Select message_type
						Case NET.JOIN
							Local net_id:NETWORK_ID = NETWORK_ID.Create( ip_address, network_port )
							Local username$ = udp_in.ReadLine()
							Local vehicle_data_json$ = udp_in.ReadLine()
							Local vehicle:TJSON = TJSON.Create( vehicle_data_json )
							Local rp:REMOTE_PLAYER = REMOTE_PLAYER.Create( net_id, username, vehicle )
							If add_remote_player( rp ) 'uniqueness by IP
								rp.udp_out = connect_to( rp.net_id ) 'send join message
							End If
						Case NET.QUIT
							'disconnect_from( NETWORK_ID.Create( ip_address, network_port ))
						Case NET.CHAT_MESSAGE
							Local cm:CHAT_MESSAGE = CHAT_MESSAGE.Create( udp_in.ReadLine(), udp_in.ReadLine() )
							cm.remote_player_ip = ip_address
							chat_message_list.AddFirst( cm )
							'DebugLog( "   "+cm.username+": "+cm.message )
					End Select
				End If
			End If
		End If
		
		'send any pending UDP messages
		If Not remote_player_list.IsEmpty() And Not outgoing_messages.IsEmpty()
			For Local message:Object = EachIn outgoing_messages
				If CHAT_MESSAGE(message)
					Local cm:CHAT_MESSAGE = CHAT_MESSAGE(message)
					For Local rp:REMOTE_PLAYER = EachIn remote_player_list
						If cm.remote_player_ip <> rp.net_id.ip 'broadcast chat messages to other players
							rp.udp_out.WriteByte( NET.CHAT_MESSAGE )
							rp.udp_out.WriteLine( cm.message )
							rp.udp_out.WriteLine( cm.username )
							rp.udp_out.SendMsg()
						End If
					Next
					chat_message_list.AddFirst( cm )
				End If
			Next
			outgoing_messages.Clear()
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
	'DebugLog( " Listening on port "+network_port )
End Function

Function connect_to:TUDPStream( ent:NETWORK_ID )
	If ent
		Local udp_out:TUDPStream = New TUDPStream
		udp_out.Init()
		udp_out.SetRemoteIP( ent.ip )
		udp_out.SetRemotePort( ent.port )
		udp_out.SetLocalPort()
		udp_out.WriteByte( NET.JOIN )
		udp_out.WriteLine( profile.vehicle.to_json().ToString() )
		udp_out.WriteLine( profile.name )
		'DebugLog( " Sending JOIN request to "+TNetwork.StringIP( ent.ip )+":"+ent.port )
		udp_out.SendMsg()
		Return udp_out
	End If
End Function

Function disconnect_from( ent:NETWORK_ID )
	
End Function

Function network_terminate()
	If udp_in
		udp_in.Close()
		udp_in = Null
	End If
	If udp_out	
		udp_out.Close()
		udp_out = Null
	End If
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
		If list_rp.net_id.ip = rp.net_id.ip
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
	Field remote_player_ip%
	
	Function Create:CHAT_MESSAGE( username$, message$, from_self% = False )
		Local cm:CHAT_MESSAGE = New CHAT_MESSAGE
		cm.added_ts = now()
		cm.username = username
		cm.message = message
		cm.from_self = from_self
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
			Case QUIT; Return "QUIT"
			Case CHAT_MESSAGE; Return "CHAT_MESSAGE"
			Default; Return String.FromInt( Int( code ))
		End Select
	End Function
End Type

