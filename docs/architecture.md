# Architecture of the game code

## Memory layout

### First 32 bytes:

- Game tick - byte
- game state - byte
  - INIT_ENGINE
  - QUIT
  - STATE_TITLE_SCREEN_INIT
  - STATE_TITLE_SCREEN
  - STATE_MENU_INIT
  - STATE_MENU
  - STATE_GAME_NEW
  - STATE_GAME_INIT
  - STATE_GAME
  - STATE_MAP_VIEW_INIT
  - STATE_MAP_VIEW
  - STATE_DEBUG_VIEW_INIT
  - STATE_DEBUG_VIEW
  - STATE_GENERATE_MAP
- rng number - word
- viewport x/y - 2x words
- cursor x/y - 2x words
- interaction mode - byte
- economy values - word each
  - tracks
  - resources blue, yellow, red
  - overall score

### rest of memory layout

- tiles - 64 tiles - 16K
- map data - 128*128 - 32K
- metadata for map - 32K
- entites - byte for each entity

## Map generation

Very simplified WFC (Wave Function Collapse) algorithm. Using rules for each next tile based on (randomely selected) left or top ancient tile.

Rules:
 - ancient tile ID -> 4x possible new tiles (randomely selected)

## Game logic

### Main Goal

Gain as much points and conquer whole map. Waisting resources, bad track management results in unable to proceed and gain more points.

### Building a rails network

Player chooses a best spot and start building rails (tracks). Rails can be only placed on clean tiles (no trees or mountains). Player can clean terrain using one of the resources. Number of rails is limited starting with 100. New rails can be produced in the factory building using resource.

### Resources

- Red ore - for producing new rails
- Yellow ore - for constructing buildings, carts, and removal of terrain obstacles
- Blue ore - main goal of the game, increase score and expand map view

### Buildings

- foundation - for placing buildings
- barracs - for producing new rails and carts
- radar - for detecting nearby resources
- rafinery - for changing ore into resource
- arm - not needed...
- extraction facility - for extracting nearby resources
- station - for rails to stop and take resources


### Rails
  8
1   4
  2

1,2,4,8,5,10,12,15- no switch
7,11,13,14 - switch

7, 13 left/right     0111 1101
14, 11 up/down 1110 1011

  3
0   2
  1
