Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_host:TGNetHost = Null
Global network_client:TGNetHost = Null
Global network_link_list:TList 'TList<NETWORK_LINK>
Global player_network_link:NETWORK_LINK

Function update_network()
	If game <> Null
		
		If network_host <> Null
			GNetSync( network_host )
			'update network from network links
			For Local net_link:NETWORK_LINK = EachIn network_link_list
				net_link.update_network()
			Next
		End If
		If network_client <> Null
			GNetSync( network_client )
			'check for new remote objects created by the host (require creation of new network links)
			'For Local new_gnet_obj:TGNetObject = EachIn GNetObjects( network_self, GNET_CREATED )
				
			'Next
			'update network from networked player avatar
			player_network_link.update_network()
		End If
		
	End If
End Function

Function host_new_multiplayer_game()
	Local level_file_path$ = "data/debug.colosseum_level"
	Local player_archetype% = PLAYER_INDEX_LIGHT_TANK
	
	'the network host controls the level and npcs
	network_host = CreateGNetHost()
	network_host.Listen( ip_port )
	'the network client controls exactly one complex agent object
	'other client's avatars appear as non-player complex agents
	network_client = CreateGNetHost()
	'network_client.Connect( "localhost", ip_port, 3000 )
	
	play_level( level_file_path, player_archetype )
	
	'create network links for the host objects
	
	
	'create network link for the client avatar
	
	
End Function

Function join_existing_multiplayer_game()
	Local level_file_path$ = ""
	Local player_archetype% = PLAYER_INDEX_LIGHT_TANK
	
	'the network client controls exactly one complex agent object
	'other client's avatars appear as non-player complex agents
	network_client = CreateGNetHost()
	'network_client.Connect( ip_address, ip_port, 3000 )
	
	'determine from the host which level to use
	
	play_level( level_file_path, player_archetype )
	
	'create network link for the client avatar
	
	
End Function

Type NETWORK_LINK Extends MANAGED_OBJECT
	Field class%
	Field game_obj:Object
	Field gnet_objects:TGNetObject[]
	
	'recognized classes
	Global CLASS_LEVEL% = 100
	Global CLASS_MANAGED_OBJECT% = 1000
	Global CLASS_POINT% = 1100
	Global CLASS_PHYSICAL_OBJECT% = 1200
	Global CLASS_PROJECTILE% = 1300
	Global CLASS_AGENT% = 1400
	Global CLASS_TURRET% = 1500
	Global CLASS_COMPLEX_AGENT% = 1600
	Global CLASS_PLAYER% = 10000
	'TGNetObject slots
	Global SLOT_CLASS% = 0
	'LEVEL
	Global SLOT_LEVEL_FILE_PATH% = 1
	'POINT
	Global SLOT_POINT_POS_X% = 1
	Global SLOT_POINT_POS_Y% = 2
	Global SLOT_POINT_ANG% = 3
	Global SLOT_POINT_VEL_X% = 4
	Global SLOT_POINT_VEL_Y% = 5
	Global SLOT_POINT_ANG_VEL% = 6
	Global SLOT_POINT_ACC_X% = 7
	Global SLOT_POINT_ACC_Y% = 8
	Global SLOT_POINT_ANG_ACC% = 9
	
	Function Create:NETWORK_LINK( class% )
		Local netlink:NETWORK_LINK = New NETWORK_LINK
		netlink.class = class
		Return netlink
	End Function
	
	Method link( new_game_obj:Object, network:TGNetHost )
		'based on the type of the game object,
		'  create a set of network objects which represent it
		game_obj = new_game_obj

		Select class
			
			Case CLASS_LEVEL
				gnet_objects = New TGNetObject[1]
				gnet_objects[0] = CreateGNetObject( network )
				gnet_objects[0].SetInt( SLOT_CLASS, CLASS_LEVEL )
				update_network()
							
			Case CLASS_POINT
				gnet_objects = New TGNetObject[1]
				gnet_objects[0] = CreateGNetObject( network )
				gnet_objects[0].SetInt( SLOT_CLASS, CLASS_POINT )
				update_network()
				
		End Select
	End Method
	
	Method update_network()
		'the game object has changed; update the gnet objects.
		Select class
			
			Case CLASS_LEVEL
				Local game_lev:LEVEL = LEVEL( game_obj )
				gnet_objects[0].SetString( SLOT_LEVEL_FILE_PATH, game_lev.file_path )
			
			Case CLASS_POINT
				Local game_p:POINT = POINT( game_obj )
				gnet_objects[0].SetFloat( SLOT_POINT_POS_X,   game_p.pos_x )
				gnet_objects[0].SetFloat( SLOT_POINT_POS_Y,   game_p.pos_y )
				gnet_objects[0].SetFloat( SLOT_POINT_ANG,     game_p.ang )
				gnet_objects[0].SetFloat( SLOT_POINT_VEL_X,   game_p.vel_x )
				gnet_objects[0].SetFloat( SLOT_POINT_VEL_Y,   game_p.vel_x )
				gnet_objects[0].SetFloat( SLOT_POINT_ANG_VEL, game_p.ang_vel )
				gnet_objects[0].SetFloat( SLOT_POINT_ACC_X,   game_p.acc_x )
				gnet_objects[0].SetFloat( SLOT_POINT_ACC_Y,   game_p.acc_x )
				gnet_objects[0].SetFloat( SLOT_POINT_ANG_ACC, game_p.ang_acc )

		End Select
	End Method
	
	Method update_game()
		'the gnet objects have changed; update the game object.
		Select class
			
			Case CLASS_LEVEL
				'do nothing
			
			Case CLASS_POINT
				Local game_p:POINT = POINT( game_obj )
				game_p.pos_x =   gnet_objects[0].GetFloat( SLOT_POINT_POS_X )
				game_p.pos_y =   gnet_objects[0].GetFloat( SLOT_POINT_POS_Y )
				game_p.ang =     gnet_objects[0].GetFloat( SLOT_POINT_ANG )
				game_p.vel_x =   gnet_objects[0].GetFloat( SLOT_POINT_VEL_X )
				game_p.vel_y =   gnet_objects[0].GetFloat( SLOT_POINT_VEL_Y )
				game_p.ang_vel = gnet_objects[0].GetFloat( SLOT_POINT_ANG_VEL )
				game_p.acc_x =   gnet_objects[0].GetFloat( SLOT_POINT_ACC_X )
				game_p.acc_y =   gnet_objects[0].GetFloat( SLOT_POINT_ACC_Y )
				game_p.ang_acc = gnet_objects[0].GetFloat( SLOT_POINT_ANG_ACC )

		End Select
	End Method
	
End Type


