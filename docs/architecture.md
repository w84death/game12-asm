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

Player chooses a best spot and start building rails (tracks). Rails can be only placed on clean tiles (no trees or mountains). Player can clean terrain using one of the resources. Number of rails is limited starting with 100. New rails can be produced in the rafinery building using resource.

### Strategy Design

The rocket lands n the middle of the map. This is the main building where the blue resoure is collected to gain score points. Build rails to the closest blue resource.

Rails are the main infrastructure. Build stations on the rails. Foundations will spawn next to the station. Place new buildings on those fundations.

Resouce plant -> Extraction Facility -> Station -> Cart -> Station (next to) -> Rafinery -> Resource increased.

Placing rafineries is very costly. Build them in strategic place to and bring ore from closes resource source.

    (R)---+
          |   (*)
          +-(#)|
               +----(B)
               |
              (G)

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


0 0000
2 0010

1 0001
3 0011

## no ECS but lists

thing that needs to be check every game tick:
- pods
- resources
- collectors
- lab
- rafinery

### PODs likes to move.
- is on station
  - has cargo
    - check near tiles for collection port
      - unload resource (based on upgrade level speed)
      - wait
  - has no cargo / empty
    - check near tiles for collector
      - check if has resource amount > 0
        - load resource (based on upgrade level speed)
        - wait
- move
  - check tile in front of direction
    - go if empty
    - ocupied by pod
      - check if oposing directions
        - revert and move
      - wait if same directions (will be empty in next turn)
    - end of the road
      - revert and move

### Resource source
- shrooms
  - not collected
    - increase resource amount
    - if overgrow then dies and spawns 4x new around
  - is collected
    - decrease resouce amount
    - if zero then dies
- crystals
  - not collected
    - randomely increase resource amount or do nothing
  - is collected
    - decrease resouce amount
    - if zero then it disapear
- gas
  - not collected
    - no nohing
  - is collected
    - increase resouce amount
    - does not go to zero

### collectors
- needs to know the target
  - has pointer to target resource?
  - check target if still exists (has resource amount > 0)
    - exists then increase own resource amount
    - empty then remove pointer (zero)
  res 1: pos
  res 2: pos
  res n: pos

  collector 1: pos, ptr_resource
  collector 2: pos, ptr_resource
  collector n: pos, ptr_resource


## Upgrades
  - pods
    - faster movement 1x 2x 4x
    - more storage 4-8-16
    - faster load/unload 1-2-4
