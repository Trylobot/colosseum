REM
This file was created by the BLIde solution explorer and should not be modified from outside BLIde
EndRem
'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HFF Program Info
'Program: Colosseum
'Version: 0
'Subversion: 2
'Revision: 2
'#EndRegion &HFF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H01 Compile Options
SuperStrict
'#EndRegion &H01



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H0F Framework
Import brl.freetypefont
Import brl.freeaudioaudio
Import brl.oggloader
Import brl.pngloader
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
TYPE z_e342713b_dcf9_4f7b_ba60_404fd28fc92f abstract  'Resource folder
End Type


TYPE z_blide_bg1a2b2d63_8a24_4af8_8938_1d8a51cf5998 Abstract
    Const Name:string = "Colosseum" 'This string contains the name of the program
    Const MajorVersion:Int = 0  'This Const contains the major version number of the program
    Const MinorVersion:Int = 2  'This Const contains the minor version number of the program
    Const Revision:Int =  2  'This Const contains the revision number of the current program version
    Const VersionString:String = MajorVersion + "." + MinorVersion + "." + Revision   'This string contains the assembly version in format (MAJOR.MINOR.REVISION)
    Const AssemblyInfo:String = Name + " " + MajorVersion + "." + MinorVersion + "." + Revision   'This string represents the available assembly info.
EndType


Type z_My_1a2b2d63_8a24_4af8_8938_1d8a51cf5998 Abstract 'This type has all the run-tima binary information of your assembly
    Global Application:z_blide_bg1a2b2d63_8a24_4af8_8938_1d8a51cf5998  'This item has all the currently available assembly version information.
    Global Resources:z_e342713b_dcf9_4f7b_ba60_404fd28fc92f  'This item has all the currently available incbined files names and relative location.
End Type


Global My:z_My_1a2b2d63_8a24_4af8_8938_1d8a51cf5998 'This GLOBAL has all the run-time binary information of your assembly, and embeded resources shortcuts.
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
Include "projectile.bmx"
Include "emitter.bmx"
Include "turret.bmx"
Include "agent.bmx"
Include "complex_agent.bmx"
Include "pathing.bmx"
Include "control_brain.bmx"
Include "archetypes.bmx"
Include "debug.bmx"
Include "update.bmx"
Include "draw.bmx"
Include "collide.bmx"
Include "input.bmx"
Include "audio.bmx"
Include "core.bmx"
Include "main.bmx"
 
'#EndRegion &H03

