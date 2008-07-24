REM
This file was created by the BLIde solution explorer and should not be modified from outside BLIde
EndRem
'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HFF Program Info
'Program: colosseum
'Version: 0
'Subversion: 0
'Revision: 1
'#EndRegion &HFF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H01 Compile Options
SuperStrict
'#EndRegion &H01



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H0F Framework

'#EndRegion &H0F



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HAF Imports

'#EndRegion &HAF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H04 MyNamespace
'GUI
Private
TYPE z_3ba570ad_eb4b_4ae0_8d23_e616eb836dfa abstract  'Resource folder
End Type


TYPE z_blide_bgfc75cc6c_b2a0_4b5a_a001_b191a7e17b59 Abstract
    Const Name:string = "colosseum" 'This string contains the name of the program
    Const MajorVersion:Int = 0  'This Const contains the major version number of the program
    Const MinorVersion:Int = 0  'This Const contains the minor version number of the program
    Const Revision:Int =  1  'This Const contains the revision number of the current program version
    Const VersionString:String = MajorVersion + "." + MinorVersion + "." + Revision   'This string contains the assembly version in format (MAJOR.MINOR.REVISION)
    Const AssemblyInfo:String = Name + " " + MajorVersion + "." + MinorVersion + "." + Revision   'This string represents the available assembly info.
EndType


Type z_My_fc75cc6c_b2a0_4b5a_a001_b191a7e17b59 Abstract 'This type has all the run-tima binary information of your assembly
    Global Application:z_blide_bgfc75cc6c_b2a0_4b5a_a001_b191a7e17b59  'This item has all the currently available assembly version information.
    Global Resources:z_3ba570ad_eb4b_4ae0_8d23_e616eb836dfa  'This item has all the currently available incbined files names and relative location.
End Type


Global My:z_My_fc75cc6c_b2a0_4b5a_a001_b191a7e17b59 'This GLOBAL has all the run-time binary information of your assembly, and embeded resources shortcuts.
Public
'#EndRegion &H04 MyNamespace


'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H03 Includes
Include "globals.bmx"
Include "load_images.bmx"
Include "managed_object.bmx"
Include "point.bmx"
Include "particle.bmx"
Include "projectile.bmx"
Include "agent.bmx"
Include "turret.bmx"
Include "emitter.bmx"
Include "complex_agent.bmx"
Include "archetypes.bmx"
Include "debug.bmx"
Include "colosseum.bmx"
 
'#EndRegion &H03

