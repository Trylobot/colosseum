REM
This file was created by the BLIde solution explorer and should not be modified from outside BLIde
EndRem
'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HFF Program Info
'Program: Colosseum
'Version: 0
'Subversion: 0
'Revision: 2
'#EndRegion &HFF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H01 Compile Options
SuperStrict
'#EndRegion &H01



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H0F Framework
Import brl.timer
Import brl.freetypefont
Import brl.freeaudioaudio
Import brl.oggloader
Import brl.pngloader
Import brl.standardio
'#EndRegion &H0F



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &HAF Imports

'#EndRegion &HAF



'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H04 MyNamespace
'GUI
Private
TYPE z_01b97d5b_c5fd_4334_8809_3355d48b69ac abstract  'Resource folder
End Type


TYPE z_blide_bgd435189a_8faa_431d_bc70_14c9a5b75108 Abstract
    Const Name:string = "Colosseum" 'This string contains the name of the program
    Const MajorVersion:Int = 0  'This Const contains the major version number of the program
    Const MinorVersion:Int = 0  'This Const contains the minor version number of the program
    Const Revision:Int =  2  'This Const contains the revision number of the current program version
    Const VersionString:String = MajorVersion + "." + MinorVersion + "." + Revision   'This string contains the assembly version in format (MAJOR.MINOR.REVISION)
    Const AssemblyInfo:String = Name + " " + MajorVersion + "." + MinorVersion + "." + Revision   'This string represents the available assembly info.
EndType


Type z_My_d435189a_8faa_431d_bc70_14c9a5b75108 Abstract 'This type has all the run-tima binary information of your assembly
    Global Application:z_blide_bgd435189a_8faa_431d_bc70_14c9a5b75108  'This item has all the currently available assembly version information.
    Global Resources:z_01b97d5b_c5fd_4334_8809_3355d48b69ac  'This item has all the currently available incbined files names and relative location.
End Type


Global My:z_My_d435189a_8faa_431d_bc70_14c9a5b75108 'This GLOBAL has all the run-time binary information of your assembly, and embeded resources shortcuts.
Public
'#EndRegion &H04 MyNamespace


'------------------------------------------------------------------------------------------------------------------------------------------------------
'#Region &H03 Includes
Include "load_data.bmx"
Include "basic.bmx"
Include "point.bmx"
Include "particle.bmx"
Include "pickup.bmx"
Include "force.bmx"
Include "physical_object.bmx"
Include "projectile.bmx"
Include "emitter.bmx"
Include "turret.bmx"
Include "agent.bmx"
Include "complex_agent.bmx"
Include "control_brain.bmx"
Include "archetypes.bmx"
Include "core.bmx"
Include "debug.bmx"
Include "colosseum.bmx"
 
'#EndRegion &H03

