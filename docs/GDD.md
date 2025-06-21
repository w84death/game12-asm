Game Design Document - GAME 12

## Story

In 2157, humanity discovered an extraordinary resource on the distant planet Kepler-438b, located 470 light-years from Earth. The planet harbors a unique fungal organism known as Cerebrospore - a bioluminescent mushroom-like plant that contains compounds capable of triggering neurogenesis in the human brain. When processed and consumed, Cerebrospore dramatically enhances cognitive abilities, repairs damaged neural tissue, and extends human lifespan by up to 200 years.

Kepler-438b's harsh environment makes it impossible for human colonization. The planet's toxic atmosphere, extreme radiation levels, and unpredictable electromagnetic storms would kill any human within minutes. The only viable solution is the deployment of remotely controlled robotic expeditions, operated from orbital relay stations positioned at safe distances.

You are Commander of Expedition Unit 7, tasked with establishing and managing an automated extraction facility on the planet's surface. Your mission is to build a self-sustaining robotic base capable of harvesting, processing, and launching regular shipments of Cerebrospore back to Earth. The future of human evolution depends on your success - but you're not alone. Competing nations and corporations have also deployed their own robotic expeditions, and resources on Kepler-438b are limited. Time is running out before the next solar storm season makes extraction impossible for the next decade.

## Example game play session

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
F1 - explore the map: pan satelite view using cursors
F2 - building mode: position the cursor and build
  - SPACEBAR placing rails (on clear terrain)
  - ENTER placing stations (on rails)
F3 - modifiing mode:
  - switching switches
F4 - TBD, removing terrain obstacles
F5 - TBD
ESC - back to menu
TAB - toggle mini map view

### Main Menu
- New game
- Resume / Load game from floppy
- Save game to floppy
- Quick help
- Credits
- Quit
