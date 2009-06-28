Rem
	messaging.bmx
	This is a COLOSSEUM project BlitzMax source file.
EndRem

Type MESSAGING_SYSTEM
	Field size% 'number of chat messages in the list
	Field messages:TList 'TList<String> message list
	
	Method New()
		size = 0
		messages = CreateList()
	End Method
	
	Method add_message( msg$ )
		size :+ 1
		messages.AddLast( MSG )
	End Method
End Type
