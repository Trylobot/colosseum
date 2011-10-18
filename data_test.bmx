
SuperStrict
Import TWRC.rJSON
Import "data_structures.bmx"

Local json_str$ = LoadString( "data/gibs.media.json" )
Local md:meta_data[] = meta_data[](JSON.Decode( json_str ))

print JSON.Encode( md )
