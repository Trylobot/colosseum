Rem
	net.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem

'______________________________________________________________________________
Global network:TGNetHost = Null
Global local_network_links:TList = CreateList() 'TList<NETWORK_LINK>
Global remote_network_links:TList = CreateList() 'TList<NETWORK_LINK>

Function update_network()
	If network <> Null
		network.Sync()
		Select network_mode
			
			Case NETWORK_MODE_SERVER
				
				
			Case NETWORK_MODE_CLIENT
				'client uninitialized
				If game = Null
					For Local gnet_obj:TGNetObject = EachIn network.ObjectsCreated()
						If gnet_obj.GetInt( NETWORK_LINK.SLOT_CLASS ) = NETWORK_LINK.CLASS_LEVEL
							'level name is retrieved from server
							'play_level( gnet_obj.GetString( NETWORK_LINK.SLOT_SOURCE ), PLAYER_CHASSIS_INDEX_LIGHT_TANK )  
						End If
					Next
				End If
				'normal client update
				For Local gnet_obj:TGNetObject = EachIn network.Objects()
					Select gnet_obj.State()
						Case GNET_CREATED
							NETWORK_LINK.Create_remote( gnet_obj ).manage( remote_network_links )
						Case GNET_CLOSED
							'..?
					End Select
				Next
				
		End Select

		For Local net_link:NETWORK_LINK = EachIn remote_network_links
			net_link.read_from_network()
		Next
		For Local net_link:NETWORK_LINK = EachIn local_network_links
			net_link.write_to_network()
		Next

	End If
End Function

'______________________________________________________________________________
Function host_game()
	Local level_file_path$ = "data/debug.colosseum_level"
	network = CreateGNetHost()
	GNetListen( network, ip_port )
	
	main_game = Create_ENVIRONMENT()
	Local success% = main_game.load_level( level_file_path, False )
	If success
		main_game.game_in_progress = True
		FLAG_in_menu = False
	Else
		main_game = Null
	End If
	
	Local level_link:NETWORK_LINK = ..
		NETWORK_LINK.Create_local( NETWORK_LINK.CLASS_LEVEL, main_game.lev, level_file_path )
	level_link.manage( local_network_links )
End Function

'______________________________________________________________________________
Function join_game()
	network = CreateGNetHost()
	GNetConnect( network, ip_address, ip_port, 10000 )
End Function

'______________________________________________________________________________
Type NETWORK_LINK Extends MANAGED_OBJECT
	Field class%
	Field game_obj:Object
	Field gnet_obj:TGNetObject
	
	'recognized classes
	Global CLASS_LEVEL% = 100
	Global CLASS_PROJECTILE% = 1300
	Global CLASS_COMPLEX_AGENT% = 1600
	Global CLASS_PLAYER% = 10000
	'TGNetObject slots
	Global SLOT_CLASS% = 0 'switches network_link create/update behavior
	Global SLOT_SOURCE% = 1 'file path for a level, or archetype number for a complex agent
	'LEVEL
	'...
	'POINT
	Global SLOT_POINT_POS_X%   =  2
	Global SLOT_POINT_POS_Y%   =  3
	Global SLOT_POINT_ANG%     =  4
	Global SLOT_POINT_VEL_X%   =  5
	Global SLOT_POINT_VEL_Y%   =  6
	Global SLOT_POINT_ANG_VEL% =  7
	Global SLOT_POINT_ACC_X%   =  8
	Global SLOT_POINT_ACC_Y%   =  9
	Global SLOT_POINT_ANG_ACC% = 10
	
	Function Create_local:NETWORK_LINK( class%, game_obj:Object, source_str$ = Null, source_int% = -1 )
		'create a new network link from a game object
		Local net_link:NETWORK_LINK = New NETWORK_LINK
		net_link.class = class
		net_link.game_obj = game_obj
		net_link.gnet_obj = CreateGNetObject( network )
		net_link.gnet_obj.SetInt( SLOT_CLASS, class )
		Select class
			Case CLASS_LEVEL
				'the source is a string path
				net_link.gnet_obj.SetString( SLOT_SOURCE, source_str )
			Default
				'the source is an archetype index
				net_link.gnet_obj.SetInt( SLOT_SOURCE, source_int )
		End Select
		net_link.write_to_network()
		Return net_link
	End Function
	
	Function Create_remote:NETWORK_LINK( gnet_obj:TGNetObject )
		'create a new network link from a network object
		'use its source ID to copy a projectile from one of the archetype maps
		'insert it into the appropriate managed environment list
		'set its initial physical state
		Local net_link:NETWORK_LINK = New NETWORK_LINK
		net_link.class = gnet_obj.GetInt( SLOT_CLASS )
		Select net_link.class
			Case CLASS_PROJECTILE
				
			Case CLASS_COMPLEX_AGENT
				
			Case CLASS_PLAYER
				
		End Select
	End Function
	
	Method write_to_network()
		Select class
			Case CLASS_PROJECTILE, CLASS_COMPLEX_AGENT, CLASS_PLAYER
				Local p:POINT = POINT( game_obj )
				gnet_obj.SetFloat( SLOT_POINT_POS_X,   p.pos_x )
				gnet_obj.SetFloat( SLOT_POINT_POS_Y,   p.pos_y )
				gnet_obj.SetFloat( SLOT_POINT_ANG,     p.ang )
				gnet_obj.SetFloat( SLOT_POINT_VEL_X,   p.vel_x )
				gnet_obj.SetFloat( SLOT_POINT_VEL_Y,   p.vel_x )
				gnet_obj.SetFloat( SLOT_POINT_ANG_VEL, p.ang_vel )
				gnet_obj.SetFloat( SLOT_POINT_ACC_X,   p.acc_x )
				gnet_obj.SetFloat( SLOT_POINT_ACC_Y,   p.acc_x )
				gnet_obj.SetFloat( SLOT_POINT_ANG_ACC, p.ang_acc )  
		End Select
	End Method
	
	Method read_from_network()
		Select class
			Case CLASS_PROJECTILE, CLASS_COMPLEX_AGENT, CLASS_PLAYER
				Local p:POINT = POINT( game_obj )
				p.pos_x =   gnet_obj.GetFloat( SLOT_POINT_POS_X )
				p.pos_y =   gnet_obj.GetFloat( SLOT_POINT_POS_Y )
				p.ang =     gnet_obj.GetFloat( SLOT_POINT_ANG )
				p.vel_x =   gnet_obj.GetFloat( SLOT_POINT_VEL_X )
				p.vel_y =   gnet_obj.GetFloat( SLOT_POINT_VEL_Y )
				p.ang_vel = gnet_obj.GetFloat( SLOT_POINT_ANG_VEL )
				p.acc_x =   gnet_obj.GetFloat( SLOT_POINT_ACC_X )
				p.acc_y =   gnet_obj.GetFloat( SLOT_POINT_ACC_Y )
				p.ang_acc = gnet_obj.GetFloat( SLOT_POINT_ANG_ACC )
		End Select
	End Method
	
End Type

