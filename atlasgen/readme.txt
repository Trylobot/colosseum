dir art\*.png /s /b > atlasgen\image_list.dat
python atlasgen\create_texture_atlas.py -o data\textures.png -c data\atlas.json < atlasgen\image_list.dat
