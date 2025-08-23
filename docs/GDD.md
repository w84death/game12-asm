Game Design Document for GAME 12
Krzysztof Krystian Jankowski
(C) 2025.06  P1X

## Name propostions
"Cortex Labs"

## Story

In 2157, humanity discovered an extraordinary resource on the distant planet Kepler-486i, located 486 light-years from Earth. The planet harbors a unique fungal organism known as Neurofung - a bioluminescent mushroom-like plant that contains compounds capable of triggering neurogenesis in the human brain. When processed and consumed, Neurofung dramatically enhances cognitive abilities, repairs damaged neural tissue, and extends human lifespan by up to 200 years.

Kepler-486i's harsh environment makes it impossible for human colonization. The planet's toxic atmosphere, extreme radiation levels, and unpredictable electromagnetic storms would kill any human within minutes. The only viable solution is the deployment of remotely controlled robotic expeditions, operated from orbital relay stations positioned at safe distances.

You are Commander of Expedition Unit 7, employed by Cortex Labs, the pioneering biotechnology corporation that first discovered Neurofung's potential. Cortex Labs has tasked you with establishing and managing an automated extraction facility on the planet's surface. Your mission is to build a self-sustaining robotic base capable of harvesting, processing, and launching regular shipments of Neurofung back to Earth. The future of human evolution depends on your success - but you're not alone. Competing nations and corporations have also deployed their own robotic expeditions, and resources on Kepler-486i are limited. Time is running out before the next solar storm season makes extraction impossible for the next decade.

## Elements

- main base / rocket
  - silos
    - blue resource / cristals
    - yellow resource / gases
    - red resource / shrooms like
- rails
  - when T-junction switch is placed
  - switches can be switched by player (left-right or up-down depending on T-junction rotation)
- pods (cargo carts)
  - build in the factory
  - runs forward as long as possible
  - when on T-junction takes turn based on switch
  - takes cargo at extractor
  - delivers cargo at collector
  - moves faster when empty, slower when cargo loaded
- station
  - build on a straight rails
  - spawns two station extends (up/down or left/right ancient tile)
- station extends fundaments
  - extractor
    - extract resources from near tiles
  - radar
  - defense turrets
- foundaments
  - silos
  - factory
  - laboratory
  - radar

## Resources

### Blue / Cristals
Located near mountains.
Main source for building new structures (rails, buildings, pods) and research.

### Yellow / Gas
Located on plain terrains.
Needs to be refined to fuel.
Source of fuel for the main rocket.

### Red / Shrooms
Grow near the forests. Grow over time. If collected all, new will not regrow.
Goal of the game, fill up collector to send rocket to the earth.

## Interface

### Interaction modes
Use cursor to move over map. Press spacebar, if cursor is:
- near rail tracks -> expand tracks
- on the (straight) tracks -> build station
- on station near tiles -> build station extension
- on the station extension -> menu: select building to build
- on building -> menu: building options, description
- on switch -> flip switch
- on foundation (base) -> menu: select building to build

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

Layer terrain forground (1b):
```
00 0 00000
|  | |
|  | '- sprite id (32) (rails / buildings)
|  '- draw cart (1)
'- cursor type (4)
```

Layer rails metadata (1b):
```
0 00 00 00 0
| |  |  |  |
| |  |  |  '- switch on rail (or not initialized)
| |  |  '- switch position (up/down/left/right)
| |  '- resource type (4) (for source/pods cargo/buildings)
| '- cart direction
'- unused (1)
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

TBC

## UI

if ARROWS
  - moves cursor
    - redraw old and new position
  - if cursor 2 tiles to the edge
    - shift view
    - update cursor position
    - redrawn full screen

if hit SPACEBAR
  - on empty terrain
    - if tile is next to rails
      - build rail
      - recalculate rails at this spot (9 tiles)
      - set cursors around to rail building
    - if on the rail
      - if not conjunction or crossing
        - build station
          - and spawn fundaments
            - up/down or left/right (if possible)
            - set non-movable bit
            - set cursor to build building
      - if switch
        - swap switch
    - if on fundament
      - [popup window] to choose type of infrastructure
      - spawn building
      - set cursor to configuration
    - if on infrastructure
      - [popup window] show building information
    - if on resource
      - [popup window] show resource information


## Rail System

## Buildings

## Pods Hangar
Keeps and spawns pods.
Each hangar can hold 5 pods. After that you need to build another fresh hangar to get more pods.

### Radar
Simple option: When clicked shows mini map of the whole map. Only one is needed.
Nice to have option: shows only map range around the radar. Forces player to spawn radars on rail system to see whole map. Clicking on any of the radars reveals whole system connected, covering the visible map by all radars. Radars placed strategicaly will eventualy shows whole map.

### Silos
Colects raw resources delivered by pods.
Must be build next to the station to work.

## Factory
Converts raw resources from silos to refined form.
Uses researched mixtures. At start only direct, 1 to 1, conversion available.
Level | Mixes
    0 | red -> red refined, blue -> blue refined, yellow -> yellow refined
    1 | red + blue -> voilet, yellow + blue -> green
    2 | red + blue + yellow -> orange
## Extractor
Extracts nearby resources.
Offload them to the pods.
Must be build next to the station to work.

## Laboratory
Researches new technologies.
Uses blue resource to start any research. Research takes time to finish.
Nice to have option: random event with overbuget resulting in more time to wait and reduction of blue resource (pauses until enough resource.)
Unlocks defensive buildings and upgrades existing:
Factory -> new mixtures unlock
Extractor -> range expand
Silo -> capacity expand, time to load decrees
Radar -> range expand
Pod Hangar -> capacity expand, time to build decrees
Defence Turret 1 -> unlock
Defence Turret 2 -> unlock
Defence Turret 3 -> unlock
