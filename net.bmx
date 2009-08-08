Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

Global udp_stream:TUDPStream

Function update_network()
	If playing_multiplayer
		
		If udp_stream.RecvAvail()
			While udp_stream.RecvMsg()
			End While
			If udp_stream.Size() > 0
				Local cm:CHAT_MESSAGE = New CHAT_MESSAGE
				If Not udp_stream.Eof()
					cm.username = udp_stream.ReadLine()
					While Not udp_stream.Eof()
						cm.message :+ udp_stream.ReadLine()
					End While
				End If
				chat_message_list.AddFirst( cm )
			End If
		End If
		
	End If
End Function

Type CHAT_MESSAGE
	Field username$
	Field message$
	
	Function Create:CHAT_MESSAGE( username$, message$ )
		Local cm:CHAT_MESSAGE = New CHAT_MESSAGE
		cm.username = username
		cm.message = message
		Return cm
	End Function
	
	Method clear()
		username = ""
		message = ""
	End Method
End Type

