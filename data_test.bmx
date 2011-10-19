
SuperStrict
Import TWRC.rJSON
Import "data_structures.bmx"

Local all_gibsets:gibset_meta[] = gibset_meta[]( gibset_meta.decode( LoadString( "data/gibs.media.json" )))

Local images:TImage[][all_gibsets.length]
For Local i% = 0 Until all_gibsets.length
	images[i] = New TImage[all_gibsets[i].object_.gibs.length]
	For Local j% = 0 Until all_gibsets[i].object_.gibs.length
		images[i][j] = LoadImage( all_gibsets[i].object_.gibs[j].image_path )
	Next
Next

Graphics( 1024, 768 )
SetBlend( ALPHABLEND )

Repeat
	Cls

	For Local i% = 0 Until images.length
		For Local j% = 0 Until images[i].length
			DrawImage( images[i][j], 25*j + 5, 25*i + 5 )
		Next
	Next

	Flip
Until AppTerminate()

