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
	If game <> Null And network_self <> Null
		
		GNetSync( network_self )
		
		If network_host <> Null
			
		End If
		If network_client <> Null
			'assumed to be connected
			'new objects
			For Local new_gnet_obj:TGNetObject = EachIn GNetObjects( network_self, GNET_CREATED )
				
			Next
			'modified remote network objects
			For Local net_link:NETWORK_LINK = EachIn network_link_list
				For Local gnet_obj:TGNetObject = EachIn net_link.gnet_objects
					
				Next
			Next
			'this client's player object modified
			
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
	network_client.Connect( "localhost", ip_port, 3000 )
	
	main_game = Create_ENVIRONMENT( True )
	Local success% = main_game.load_level( level_file_path )
	If success
		main_game.game_in_progress = True
		Local player:COMPLEX_AGENT = create_player( player_archetype )
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		player_network_link = NETWORK_LINK.Create( NETWORK_LINK.CLASS_POINT )
		player_network_link.link( player, network_client )
		'main_game.insert_player( player, player_brain )
		'main_game.respawn_player()
		'FLAG_in_menu = False
		'FLAG_in_shop = False
		'main_game.player_in_locker = True
		'main_game.waiting_for_player_to_enter_arena = True
	Else
		main_game = Null
	End If
	
	
End Function

Type NETWORK_LINK
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
		Select class
			
			Case CLASS_POINT
				game_obj = new_game_obj
				gnet_objects = New TGNetObject[1]
				gnet_objects[0] = CreateGNetObject( network )
				gnet_objects[0].SetInt( SLOT_CLASS, class )
				update_gnet_objects()
			
			
				
		End Select
	End Method
	
	Method update_gnet_objects()
		'the game object has changed; update the gnet objects.
		Select class
			
			Case CLASS_POINT
				Local game_p = POINT( game_obj )
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
	
	Method update_game_obj()
		'the gnet objects have changed; update the game object.
		Select class
			
			Case CLASS_POINT
				Local game_p = POINT( game_obj )
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


