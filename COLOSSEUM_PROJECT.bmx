Rem
This file was created by the BLIde solution explorer and should not be modified from outside BLIde
EndRem
'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HFF Program Info
'Program: Colosseum
'Version: 0
'Subversion: 2
'Revision: 5
'#EndRegion &HFF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H01 Compile Options
SuperStrict
'#EndRegion &H01



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H0F Framework
Framework BRL.GLMax2D
Import BRL.FreeTypeFont
Import BRL.FreeAudioAudio
Import BRL.OGGLoader
Import BRL.PNGLoader
Import BRL.Random
Import BRL.Timer

'#EndRegion &H0F



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HAF Imports

'#EndRegion &HAF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H04 MyNamespace
'GUI
'guid:e2f17149_9a68_460c_a3de_03fd0d792659
Private
TYPE z_e2f17149_9a68_460c_a3de_03fd0d792659_3_0 abstract  'Resource folder
End Type


TYPE z_blide_bge2f17149_9a68_460c_a3de_03fd0d792659 Abstract
    Const Name:string = "Colosseum" 'This string contains the name of the program
    Const MajorVersion:Int = 0  'This Const contains the major version number of the program
    Const MinorVersion:Int = 2  'This Const contains the minor version number of the program
    Const Revision:Int =  5  'This Const contains the revision number of the current program version
    Const VersionString:String = MajorVersion + "." + MinorVersion + "." + Revision   'This string contains the assembly version in format (MAJOR.MINOR.REVISION)
    Const AssemblyInfo:String = Name + " " + MajorVersion + "." + MinorVersion + "." + Revision   'This string represents the available assembly info.
    ?win32
    Const Platform:String = "Win32" 'This constant contains "Win32", "MacOs" or "Linux" depending on the current running platoform for your game or application.
    ?
    ?MacOs
    Const Platform:String = "MacOs"
    ?
    ?Linux
    Const Platform:String = "Linux"
    ?
    ?PPC
    Const Architecture:String = "PPC" 'This const contains "x86" or "Ppc" depending on the running architecture of the running computer. x64 should return also a x86 value
    ?
    ?x86
    Const Architecture:String = "x86" 
    ?
    ?debug
    Const DebugOn : Int = True    'This const will have the integer value of TRUE if the application was build on debug mode, or false if it was build on release mode
    ?
    ?not debug
    Const DebugOn : Int = False
    ?
EndType


Type z_My_e2f17149_9a68_460c_a3de_03fd0d792659 Abstract 'This type has all the run-tima binary information of your assembly
    Global Application:z_blide_bge2f17149_9a68_460c_a3de_03fd0d792659  'This item has all the currently available assembly version information.
    Global Resources:z_e2f17149_9a68_460c_a3de_03fd0d792659_3_0  'This item has all the currently available incbined files names and relative location.
End Type


Global My:z_My_e2f17149_9a68_460c_a3de_03fd0d792659 'This GLOBAL has all the run-time binary information of your assembly, and embeded resources shortcuts.
Public
'#EndRegion &H04 MyNamespace


'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H03 Includes
Include "load_data.bmx"
Include "basic.bmx"
Include "particle.bmx"
Include "widget.bmx"
Include "pickup.bmx"
Include "force.bmx"
Include "physical_object.bmx"
Include "audio.bmx"
Include "projectile.bmx"
Include "emitter.bmx"
Include "turret.bmx"
Include "agent.bmx"
Include "complex_agent.bmx"
Include "pathing.bmx"
Include "control_brain.bmx"
Include "archetypes.bmx"
Include "environment.bmx"
Include "update.bmx"
Include "draw.bmx"
Include "collide.bmx"
Include "input.bmx"
Include "core.bmx"
Include "debug.bmx"
Include "menu.bmx"
Include "main.bmx"
 
'#EndRegion &H03

