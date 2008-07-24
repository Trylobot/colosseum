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
TYPE z_e9fd20f2_9a94_4d4f_8046_c8dc64dd17cf abstract  'Resource folder
End Type


TYPE z_blide_bg1c989950_f0c1_41c7_9e51_9a1a47acd6ae Abstract
    Const Name:string = "colosseum" 'This string contains the name of the program
    Const MajorVersion:Int = 0  'This Const contains the major version number of the program
    Const MinorVersion:Int = 0  'This Const contains the minor version number of the program
    Const Revision:Int =  1  'This Const contains the revision number of the current program version
    Const VersionString:String = MajorVersion + "." + MinorVersion + "." + Revision   'This string contains the assembly version in format (MAJOR.MINOR.REVISION)
    Const AssemblyInfo:String = Name + " " + MajorVersion + "." + MinorVersion + "." + Revision   'This string represents the available assembly info.
EndType


Type z_My_1c989950_f0c1_41c7_9e51_9a1a47acd6ae Abstract 'This type has all the run-tima binary information of your assembly
    Global Application:z_blide_bg1c989950_f0c1_41c7_9e51_9a1a47acd6ae  'This item has all the currently available assembly version information.
    Global Resources:z_e9fd20f2_9a94_4d4f_8046_c8dc64dd17cf  'This item has all the currently available incbined files names and relative location.
End Type


Global My:z_My_1c989950_f0c1_41c7_9e51_9a1a47acd6ae 'This GLOBAL has all the run-time binary information of your assembly, and embeded resources shortcuts.
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
Include "core.bmx"
Include "debug.bmx"
Include "colosseum.bmx"
 
'#EndRegion &H03

