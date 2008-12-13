Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network_host:TGNetHost = Null
Global network_client:TGNetHost = Null
Global network_link_list:TList 'TList<NETWORK_LINK>

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
			'modified objects
			For Local net_link:NETWORK_LINK = EachIn network_link_list
				For Local gnet_obj:TGNetObject = EachIn net_link.gnet_objects
					
				Next
			Next
		End If
		
	End If
End Function

Function start_new_multiplayer_game()
	'"data/debug.colosseum_level"
	'PLAYER_INDEX_LIGHT_TANK
	Rem
	main_game = Create_ENVIRONMENT( True )
	Local success% = main_game.load_level( level_file_path )
	main_game.level_enemies_killed = 0
	If success
		main_game.game_in_progress = True
		Local player:COMPLEX_AGENT = create_player( player_archetype )
		Local player_brain:CONTROL_BRAIN = create_player_brain( player )
		main_game.insert_player( player, player_brain )
		main_game.respawn_player()
		FLAG_in_menu = False
		FLAG_in_shop = False
		main_game.player_in_locker = True
		main_game.waiting_for_player_to_enter_arena = True
	Else
		main_game = Null
	End If
	EndRem
	
	
End Function

Type NETWORK_LINK
	Field class%
	Field game_obj:Object
	Field gnet_objects:TGNetObject[]
	
	'classes
	Global CLASS_LEVEL% = 100
	Global CLASS_MANAGED_OBJECT% = 1000
	Global CLASS_POINT% = 1100
	Global CLASS_PHYSICAL_OBJECT% = 1200
	Global CLASS_PROJECTILE% = 1300
	Global CLASS_AGENT% = 1400
	Global CLASS_TURRET% = 1500
	Global CLASS_COMPLEX_AGENT% = 1600
	Global CLASS_PLAYER% = 10000
	'TGNetObject data slots
	'ALL
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
	
	Function link( class%, game_obj:Object )
		'based on the type of the game object,
		'  create a set of network objects which represent it
		
	End Function
	
	Function update_gnet_objects()
		'the game object has changed; update the gnet objects.
		
	End Function
	
	Function update_game_obj()
		'the gnet objects have changed; update the game object.
		
	End Function
	
End Type


