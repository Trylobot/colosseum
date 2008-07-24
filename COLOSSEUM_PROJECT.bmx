REM
This file was created by the BLIde solution explorer and should not be modified from outside BLIde
EndRem
'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HFF Program Info
'Program: Colosseum
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
Framework brl.d3d7max2d
Import brl.font
Import brl.freetypefont
Import brl.math
Import brl.pngloader
Import brl.pixmap
Import brl.ramstream
Import brl.random
Import brl.timer
'#EndRegion &H0F



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HAF Imports

'#EndRegion &HAF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H04 MyNamespace
'GUI
Private
TYPE z_fb4dc2e3_d5a7_42c4_9441_73855e4b2de0 abstract  'Resource folder
End Type


TYPE z_blide_bgddef4ae4_ded5_47b9_ab6f_25d249a1051d Abstract
    Const Name:string = "Colosseum" 'This string contains the name of the program
    Const MajorVersion:Int = 0  'This Const contains the major version number of the program
    Const MinorVersion:Int = 0  'This Const contains the minor version number of the program
    Const Revision:Int =  1  'This Const contains the revision number of the current program version
    Const VersionString:String = MajorVersion + "." + MinorVersion + "." + Revision   'This string contains the assembly version in format (MAJOR.MINOR.REVISION)
    Const AssemblyInfo:String = Name + " " + MajorVersion + "." + MinorVersion + "." + Revision   'This string represents the available assembly info.
EndType


Type z_My_ddef4ae4_ded5_47b9_ab6f_25d249a1051d Abstract 'This type has all the run-tima binary information of your assembly
    Global Application:z_blide_bgddef4ae4_ded5_47b9_ab6f_25d249a1051d  'This item has all the currently available assembly version information.
    Global Resources:z_fb4dc2e3_d5a7_42c4_9441_73855e4b2de0  'This item has all the currently available incbined files names and relative location.
End Type


Global My:z_My_ddef4ae4_ded5_47b9_ab6f_25d249a1051d 'This GLOBAL has all the run-time binary information of your assembly, and embeded resources shortcuts.
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

