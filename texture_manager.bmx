Rem
	graphics_base.bmx
	This is a COLOSSEUM project BlitzMax source file.
	author: Tyler W Cole
EndRem
SuperStrict
Import "image_atlas.bmx"

'______________________________________________________________________________
Type IMAGE_ATLAS_REFERENCE
  Field atlas%
  Field frame%
End Type

'______________________________________________________________________________
Type TEXTURE_MANAGER
  Global textures:TImageAtlas[]
  Global path_map:TMap
  
  Function Draw( ref:IMAGE_ATLAS_REFERENCE, x#, y# )
    'no bounds checking for now
    textures[ ref.atlas ].SetFrame( ref.frame )
    DrawImage( textures[ ref.atlas ], ref.frame, x, y )
  End Function
  
  'Function LoadFromJSON(...)
  'End Function
  
  'Function GetImageRef(...)
  'End Function
  
End Type

'______________________________________________________________________________
Function DrawImageRef( ref:IMAGE_ATLAS_REFERENCE, x#, y# )
  TEXTURE_MANAGER.Draw( ref, x, y )
End Function

