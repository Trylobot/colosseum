Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Const TYPE_

Global hosting% = False
Global connected% = False
Global network_self:TGNetHost

Function update_network()
	If game <> Null And network_self <> Null
		
		GNetSync( network_self )
		
		
	End If
End Function

Type NETWORK_LINK
	Field class%
	Field game_obj:MANAGED_OBJECT
	Field gnet_obj:TGNetObject
	
	Global CLASS_PHYSICAL_OBJECT% = 10
	Global CLASS_PLAYER% = 100
	Global SLOT_CLASS% = 0
	
	Function Create:NETWORK_LINK( class%, game_obj:TGNetObject )
		Local netlink:NETWORK_LINK = New NETWORK_LINK
		netlink.class = class
		netlink.game_obj = game_obj
		netlink.gnet_obj = CreateGNetObject( network_self )
		netlink.gnet_obj.SetInt( SLOT_CLASS, class )
		Return netlink
	End Function
	
End Type


