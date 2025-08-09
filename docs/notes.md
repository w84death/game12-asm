# NOTES

Real-time resource managment with tower defence twist.

Build base infrastructure for refine resources, research upgrades, unlock new buildings/features. Harvest resources on the map. Build railroad systems. Defend the infrastructure and base aginst alien creatures.


extracting and transporting resources fast is the key to survival.


## map
size: 128x128 = 16384 tiles

## enemy
aliens came from edges of the map and goes to the center where the base is located. they brake rails distrubing the rail networks. aliens cames in waves.

## rails network
slow moving pods move faster when energized by battery packs on the rail tracks.
on stright rails can build stations that spawns two foundation (second type) tiles
on those tiles can build building but can non expand those

## base
always starts at the middle of the map as the first foundation tile and main building on it
player can build acient tiles expanding the base
on the tile can build main buildings

factory uses ancient siloses to combine resources

## main buildings

main headquater
silos for resources
factory for combining resources to produce needed ingridinets to build/research
laboratory for resarch

## stations buildings
extractor
battery for boost
radar
defence building(s)

## resources combinations
red ->
yellow ->
blue ->
red + yellow
red + blue
yellow + blue


FMV
RLE algorithm.

Write a simple C program that will convert png image into compressed format that I will use in assembly program (VGA 320x200).

Images are 320x200 and 16 colors. Palette is defined in palette file. Use index of the palette when exporting.

I want a simple compression algoright that will store two one bit values: first is the color index, second how many pixels in line in that color (up to 255). Always end on 320 pixel line.

My assembly read routine will read color to AX, then number of pixels to CX and do the rep storb to VGA memory location. Prepare data to fit that.
