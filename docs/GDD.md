Game Design Document for GAME 12
Krzysztof Krystian Jankowski
(C) 2025.06  P1X

## Name propostions
"Cortex Labs"

## Story

In 2157, humanity discovered an extraordinary resource on the distant planet Kepler-486i, located 486 light-years from Earth. The planet harbors a unique fungal organism known as Cerebrospore - a bioluminescent mushroom-like plant that contains compounds capable of triggering neurogenesis in the human brain. When processed and consumed, Cerebrospore dramatically enhances cognitive abilities, repairs damaged neural tissue, and extends human lifespan by up to 200 years.

Kepler-486i's harsh environment makes it impossible for human colonization. The planet's toxic atmosphere, extreme radiation levels, and unpredictable electromagnetic storms would kill any human within minutes. The only viable solution is the deployment of remotely controlled robotic expeditions, operated from orbital relay stations positioned at safe distances.

You are Commander of Expedition Unit 7, tasked with establishing and managing an automated extraction facility on the planet's surface. Your mission is to build a self-sustaining robotic base capable of harvesting, processing, and launching regular shipments of Cerebrospore back to Earth. The future of human evolution depends on your success - but you're not alone. Competing nations and corporations have also deployed their own robotic expeditions, and resources on Kepler-486i are limited. Time is running out before the next solar storm season makes extraction impossible for the next decade.

## Example game play session

In this hypothetical gameplay scenario, your expedition ship would land in the center of the map, automatically deploying silos and empty foundation blocks. As the player, you would begin by surveying the area for nearby resources, prioritizing the blue crystals needed to build complex infrastructure. Any resource would be valuable if close enough to your starting position. Once you locate a suitable resource deposit, you would need to plan the optimal rail route, navigating around obstacles. A key strategic decision would be whether to build a one-way rail line or create a circular connection that allows multiple cargo pods to operate simultaneously without collision.

You would place your first rail segment starting from the silo, which already includes a station. You would continue laying rails toward your chosen resource location. Upon reaching the destination, you would place another station, which automatically spawns two foundation blocks. You would typically place your first extraction facility on the foundation closest to the resource. To complete your first supply line, you would need two additional structures: a pod factory to manufacture cargo pods, and at least one recharging station positioned along the route. You could repurpose the empty foundation near your silo for the pod factory, then build a new station with solar panels to provide power. Each solar panel would recharge half of a pod's battery capacity, so while you could place two for full charging, resource conservation would be crucial in the early game. Once construction is complete, you would spawn your first pod and observe it traveling along the rails.

By this time, the extraction facility should have completed its first harvest cycle, indicated by a color change matching the resource type being extracted. When the pod arrives at the extraction station, it would automatically load the cargo and return to the silo for storage. If you've collected blue crystals, you would soon be able to expand your network with additional pods and rail lines.

While establishing your first supply line would be relatively straightforward, the challenge would escalate significantly as you expand. Managing multiple intersecting rail lines with numerous pods would require careful planning of junction switches. Eventually, some pods would run out of power mid-route, necessitating strategic placement of additional charging stations that could service multiple rail lines efficiently.

Players would need to balance the efficiency of long-distance routes against shorter, high-traffic lines. The ultimate pressure would come from the countdown timer - you must fill your rocket with enough Cerebrospore before the next solar storm arrives, or face mission failure.

## Elements

- main base / rocket
  - collectors
    - blue resource / cristals
      - for building infrastructure
    - yellow resource / gases
      - fuel for rocket
    - red resource / shrooms like
      - main resource to send to the planet to win the game
- rails
  - when T-junction switch is placed
  - switches can be switched by player (left-right or up-down depending on T-junction rotation)
- pods (cargo carts)
  - build in the factory
  - runs forward as long as possible
  - when on T-junction takes turn based on switch
  - each has a battery to run, stops if run out of power
  - recharges at charging station (half battery using one, full when using two)
  - takes cargo at extractor
  - delivers cargo at collector
  - moves faster when empty, slower when cargo loaded
- station
  - build on a straight rails
  - spawns two fundaments (up/down or left/right ancient tile)
- fundaments
  - charging station / solar panels
    - re-charges pods that stops on that station
    - one solar power charges half of pod battery
    - can be combined to charge full
  - extractor
    - extract resources 2 tiles away (5x5 grid)
  - factory
    - spawning/maintanance for pods
    - each factory supports X number of pods at once
    - build using blue resource

## Resources

### Blue / Cristals
Located near mountains.
Main source for building new structures (rails, buildings, pods)

### Yellow / Gas
Located on plain terrains.
Source of fuel for the main rocket.

### Red / Shrooms
Grow near the forests. Grow over time. It collected all, new will not regrow.
Goal of the game, fill up collector to send rocket to the earth.

## Interface

### Interaction modes
Use cursor to move over map. Press spacebar, if cursor is:
- near rail trakcs -> expand tracks
- on the tracks -> build station (if horizontal/vertical)
- on the foudation -> selec building to build
- on building -> settings
- on switch -> flip switch

TAB - toggle mini map view
ESC - back to menu

### Main Menu
- New game
- Resume / Load game from floppy
- Save game to floppy
- Quick help
- Credits
- Quit

## Data organization

### Map
The map consists of 16,384 tiles arranged in a 128x128 grid, with four data layers (each 1 byte) resulting in a total map size of 65,536 bytes or 64KB in memory.

BACKGROUND_SPRITE_MASK equ 0x15
TERRAIN_TRAVERSAL_MASK equ  0x16
TERRAIN_TRAVERSAL_SHIFT equ 0x4
RAIL_MASK equ 0x32
RAIL_SHIFT equ 0x5
RESOURCE_MASK equ 0x40
RESOURCE_SHIFT equ 0x6
INFRASTRUCTURE_MASK equ 0x80
INFRASTRUCTURE_SHIFT equ 0x7

Layer terrain background (1b):
```
0 0 0 0 0000
| | | | |
| | | | '- background sprite id (16)
| | | '- terrain traversal (1) (movable or forest/mountains/building)
| | '- rail (1)
| '- resource (1)
'- infrastructure building, station (1)
```

FORGROUND_SPRITE_MASK equ 0x31
CART_ORIENT_MASK equ 0x32
CART_ORIENT_SHIFT equ 0x5
CURSOR_TYPE_MASK equ 0x33
CURSOR_TYPE_SHIFT equ 0x6

Layer terrain forground (1b):
```
00 0 00000
|  | |
|  | '- sprite id (32) (rails / buildings)
|  '- cart (1) (horizontal/vertical)
'- cursor type (4)
```

Layer metadata (1b):
```
000 00 00 0
|   |  |  |
|   |  |  '- switch on rail (or not initialized)
|   |  '- switch position (up/down/left/right)
|   '- resource type (4) (for source/pods cargo/buildings)
'- unused (8)
```

Layer entity id (1b):
```
00000000
|
'- id (256)
```

### Entites

Position & direction 2b:
```
00 0000000 0000000
|  |       |
|  |       '- position x 128
|  '- position y 128
'- direction (4) (up/down/left/right)
```

Metadata 2b:
```
0000 0000 0000  0000
                |
                '- sprite id (16)
```

## Terrain rendering
- render background sprite
- render forground sprite(s):
  - check type
  - rail station
  - rail
  - rail switch
  - resource
  - building

## Rail System

Calculate once
set sprites as needed

when expanding:
  - recaclulate type:
    - for all near 8 tiles
  - update sprites
  - check if switch needed
    - put proper switch
    - set switch bit to initialized
    - if not needed set switch bit to 0


## UI

if ARROWS
  - moves cursor
  - if cursor 4 tiles to the edge
    - shift view
    - update cursor position

if hit SPACEBAR
  - on empty terrain
    - if tile is next to rails
      - build rail
      - recalculate rails at this spot (9 tiles)
    - if on the rail
      - if not conjunction or crossing
        - build station
          - and spawn fundaments
            - up/down or left/right (if possible)
            - set non-movable bit
      - if switch
        - swap switch
    - if on fundament
      - [popup window] to choose type of infrastructure
      - spawn building
    - if on infrastructure
      - [popup window] show building information
    - if on resource
      - [popup window] show resource information

if hit TAB
  - [popup window] show map
