REM script for making a texture atlas from myriad individual files
REM   original version
REM     http://atlasgen.sourceforge.net/

REM dependencies:
REM   Python 2.6.5 
REM     http://www.python.org/download/
REM   Python Imaging Library (PIL) 1.1.7
REM     http://www.pythonware.com/products/pil/REMpil117
REM   argparse 1.1
REM     http://pypi.python.org/pypi/argparse

set name=atlas
del art\%name%.png
dir art\*.png /s /b > atlasgen\%name%.dat
python atlasgen\create_texture_atlas.py -o art\%name%.png -c data\%name%.colosseum_data < atlasgen\%name%.dat

