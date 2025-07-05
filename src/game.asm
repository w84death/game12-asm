; ==============================================================================
; GAME12: 2D Game Engine for x86 processors
; CODENAME: Mycelium Overlords
;
; Fast rendering of big maps with full screen viewport.
; Backend for strategic/simulation games. Based on GAME11 ideas.
;
; http://smol.p1x.in/assembly/#game12
; ==============================================================================
; Copyright (C) 2025 Krzysztof Krystian Jankowski
; This is free and open software. See LICENSE for details.
; ==============================================================================
;
; Should run on any x86 processor and system that supports legacy BIOS boot.
; Tested hardware:
; Compaq Contura 430C (FreeDOS & Boot Floppy)
; * CPU: 486 DX4, 100Mhz
; * Graphics: VGA
; * RAM: 24MB (OS recognize up to 640KB only)
;
; Theoretical minimum requirements:
; * CPU: 386 SX, 16Mhz
; * Graphics: EGA Enchanced (8x16)
; * RAM: 512KB
;
; Programs used for production:
;   - Zed IDE
;   - Pro Motion NG
;   - custom toolset for tileset conversion
;
; ==============================================================================
; Latest revision: 06/2025
; ==============================================================================

org 0x0100

GAME_STACK_POINTER        equ 0xFFFE
GAME_SEGMENT              equ 0x9000

; =========================================== MEMORY ALLOCATION =============|80

_BASE_                    equ 0x2000          ; Memory base address
_GAME_TICK_               equ _BASE_ + 0x00   ; 4 bytes
_GAME_STATE_              equ _BASE_ + 0x04   ; 1 byte
_RNG_                     equ _BASE_ + 0x05   ; 2 bytes
_VIEWPORT_X_              equ _BASE_ + 0x07   ; 2 bytes
_VIEWPORT_Y_              equ _BASE_ + 0x09   ; 2 bytes
_CURSOR_X_                equ _BASE_ + 0x0B   ; 2 bytes
_CURSOR_Y_                equ _BASE_ + 0x0D   ; 2 bytes
_SCENE_MODE_              equ _BASE_ + 0x0F   ; 1 byte
_ECONOMY_TRACKS_          equ _BASE_ + 0x10   ; 2 bytes
_ECONOMY_BLUE_RES_        equ _BASE_ + 0x12   ; 2 bytes
_ECONOMY_YELLOW_RES_      equ _BASE_ + 0x14   ; 2 bytes
_ECONOMY_RED_RES_         equ _BASE_ + 0x16   ; 2 bytes
_ECONOMY_SCORE_           equ _BASE_ + 0x18   ; 2 bytes
_SFX_POINTER_             equ _BASE_ + 0x1A    ; 2 bytes

_TILES_                   equ _BASE_ + 0x0100  ; 80 tiles = 24K
_MAP_                     equ _BASE_ + 0x5100  ; Map data 128*128*1b= 0x4000
_METADATA_                equ _BASE_ + 0x9100  ; Map metadata 128*128*1b= 0x4000
_ENTITIES_                equ _BASE_ + 0xD100  ; Entities 128*128*1b= 0x4000

; =========================================== GAME STATES ===================|80

STATE_INIT_ENGINE       equ 0
STATE_QUIT              equ 1
STATE_TITLE_SCREEN_INIT equ 2
STATE_TITLE_SCREEN      equ 3
STATE_MENU_INIT         equ 4
STATE_MENU              equ 5
STATE_GAME_NEW          equ 6
STATE_GAME_INIT         equ 7
STATE_GAME              equ 8
STATE_MAP_VIEW_INIT     equ 9
STATE_MAP_VIEW          equ 10
STATE_DEBUG_VIEW_INIT   equ 11
STATE_DEBUG_VIEW        equ 12
STATE_HELP_INIT         equ 13
STATE_HELP              equ 14
STATE_GENERATE_MAP      equ 15

; =========================================== KEYBOARD CODES ================|80

KB_ESC      equ 0x01
KB_UP       equ 0x48
KB_DOWN     equ 0x50
KB_LEFT     equ 0x4B
KB_RIGHT    equ 0x4D
KB_ENTER    equ 0x1C
KB_SPACE    equ 0x39
KB_DEL      equ 0x53
KB_BACK     equ 0x0E
KB_Q        equ 0x10
KB_W        equ 0x11
KB_M        equ 0x32
KB_TAB      equ 0x0F
KB_F1       equ 0x3B
KB_F2       equ 0x3C
KB_F3       equ 0x3D
KB_F4       equ 0x3E
KB_F5       equ 0x3F
KB_1        equ 0x02
KB_2        equ 0x03
KB_3        equ 0x04
KB_4        equ 0x05
KB_5        equ 0x06
KB_6        equ 0x07
KB_7        equ 0x08
KB_8        equ 0x09
KB_9        equ 0x0A
KB_0        equ 0x0B

; =========================================== TILES NAMES ===================|80

TILES_COUNT                     equ 0x50    ; 80 tiles

TILE_MUD_1                      equ 0x00
TILE_MUD_2                      equ 0x01
TILE_MUD_GRASS_1                equ 0x02
TILE_MUD_GRASS_2                equ 0x03
TILE_GRASS                      equ 0x04
TILE_BUSH                       equ 0x05
TILE_TREES_1                    equ 0x06
TILE_TREES_2                    equ 0x07
TILE_MOUNTAINS_1                equ 0x08
TILE_MOUNTAINS_2                equ 0x09

TILE_FOUNDATION_OFF             equ 0x0A
TILE_FOUNDATION_ON              equ 0x0B

TILE_RES_YELLOW_1               equ 0x0C
TILE_RES_YELLOW_2               equ 0x0D
TILE_RES_BLUE_1                 equ 0x0E
TILE_RES_BLUE_2                 equ 0x0F
TILE_RES_RED_1                  equ 0x10
TILE_RES_RED_2                  equ 0x11

TILE_RAILS_1                    equ 0x12
TILE_RAILS_2                    equ 0x13
TILE_RAILS_3                    equ 0x14
TILE_RAILS_4                    equ 0x15
TILE_RAILS_5                    equ 0x16
TILE_RAILS_6                    equ 0x17
TILE_RAILS_7                    equ 0x18
TILE_RAILS_8                    equ 0x19
TILE_RAILS_9                    equ 0x1A
TILE_RAILS_10                   equ 0x1B
TILE_RAILS_11                   equ 0x1C

TILE_BUILDING_LANDER            equ 0x1D
TILE_BUILDING_PODS              equ 0x1E
TILE_BUILDING_FACTORY           equ 0x1F
TILE_BUILDING_RADAR             equ 0x20
TILE_BUILDING_EXTRACT           equ 0x21
TILE_BUILDING_SILOS             equ 0x22
TILE_BUILDING_POWER             equ 0x23

TILE_PIPE_1                     equ 0x24
TILE_PIPE_2                     equ 0x25

TILE_CART_VERTICAL              equ 0x26
TILE_CART_HORIZONTAL            equ 0x27

TILE_SWITCH_LEFT                equ 0x28
TILE_SWITCH_DOWN                equ 0x29
TILE_SWITCH_RIGHT               equ 0x2A
TILE_SWITCH_UP                  equ 0x2B

TILE_ORE_BLUE                   equ 0x2C
TILE_ORE_YELLOW                 equ 0x2D
TILE_ORE_RED                    equ 0x2E

TILE_EXTRACT_BLUE               equ 0x2F
TILE_EXTRACT_YELLOW             equ 0x30
TILE_EXTRACT_RED                equ 0x31

TILE_SILO_BLUE                  equ 0x32
TILE_SILO_YELLOW                equ 0x33
TILE_SILO_RED                   equ 0x34

TILE_CURSOR_PAN                 equ 0x35
TILE_CURSOR_BUILD               equ 0x36
TILE_CURSOR_EDIT                equ 0x37
TILE_CURSOR_REMOVE              equ 0x38

TILE_WINDOW_1                   equ 0x39
TILE_WINDOW_2                   equ 0x3A
TILE_WINDOW_3                   equ 0x3B
TILE_WINDOW_4                   equ 0x3C
TILE_WINDOW_5                   equ 0x3D
TILE_WINDOW_6                   equ 0x3E
TILE_WINDOW_7                   equ 0x3F
TILE_WINDOW_8                   equ 0x40
TILE_WINDOW_9                   equ 0x41

META_TILES_MASK               equ 0x1F  ; 5 bits for sprite data (32 tiles max)
META_INVISIBLE_WALL           equ 0x20  ; For collision detection
META_TRANSPORT                equ 0x40  ; For railroads

METADATA_SWITCH_INITIALIZED   equ 0x01
METADATA_SWITCH_MASK          equ 0x06
METADATA_SWITCH_SHIFT         equ 0x01
METADATA_1 equ 0x08
METADATA_1 equ 0x10
METADATA_2 equ 0x20
METADATA_3 equ 0x40

META_ENTITY_MASK              equ 0x1F  ; 5 bits for sprite data (32 tiles max)
META_CART                     equ 0x01
META_BUILDING                 equ 0x02
META_RESOURCE                 equ 0x04
META_RESOURCE_TYPE_MASK       equ 0xE7  ; 0-3 - for plants and carts
META_RESOURCE_TYPE_SHIFT      equ 0x04
META_RESOURCE_BLUE            equ 1
META_RESOURCE_YELLOW          equ 2
META_RESOURCE_RED             equ 3

META_PLANT_SIZE               equ 0x20  ; small - big
META_DIRECTION_MASK           equ 0xC0  ; for carts
META_DIRECTION_SHIFT          equ 0x06

MODE_MAIN_MENU                equ 0x00
MODE_SETTINGS_MENU            equ 0x01
MODE_HELP_PAGE1               equ 0x02
MODE_HELP_PAGE2               equ 0x03

MODE_ALL                      equ 0x00
MODE_VIEWPORT_MOVE         equ 0x01
MODE_INFRASTRUCTURE_PLACE   equ 0x02
MODE_INFRASTRUCTURE_EDIT      equ 0x03
MODE_TERRAIN_REMOVE    equ 0x04

UI_POSITION                   equ 320*160
UI_FIRST_LINE                 equ 320*164
UI_LINES                      equ 40

DEFAULT_ECONOMY_TRACKS        equ 0x64

; =========================================== MISC SETTINGS =================|80

SCREEN_WIDTH                  equ 320
SCREEN_HEIGHT                 equ 200
MAP_SIZE                      equ 128     ; Map size in cells DO NOT CHANGE
VIEWPORT_WIDTH                equ 20      ; Size in tiles 20 = 320 pixels
VIEWPORT_HEIGHT               equ 12      ; by 10 = 192 pixels
VIEWPORT_GRID_SIZE            equ 16      ; Individual cell size DO NOT CHANGE
SPRITE_SIZE                   equ 16      ; Sprite size 16x16

; =========================================== COLORS / DB16 =================|80

COLOR_BLACK         equ 0
COLOR_DEEP_PURPLE   equ 1
COLOR_NAVY_BLUE     equ 2
COLOR_DARK_GRAY     equ 3
COLOR_BROWN         equ 4
COLOR_DARK_GREEN    equ 5
COLOR_RED           equ 6
COLOR_LIGHT_GRAY    equ 7
COLOR_BLUE          equ 8
COLOR_ORANGE        equ 9
COLOR_STEEL_BLUE    equ 10
COLOR_GREEN         equ 11
COLOR_PINK          equ 12
COLOR_CYAN          equ 13
COLOR_YELLOW        equ 14
COLOR_WHITE         equ 15

; =========================================== AUDIO NOTES ===================|80
; Note values are frequency divisors for the PC speaker
; Formula: divisor = 1193180 / frequency_hz

NOTE_REST   equ 0xFF    ; Rest (silence)
NOTE_C3     equ 0x2394  ; 130.81 Hz
NOTE_CS3    equ 0x2187  ; 138.59 Hz
NOTE_D3     equ 0x1F8F  ; 146.83 Hz
NOTE_DS3    equ 0x1DA8  ; 155.56 Hz
NOTE_E3     equ 0x1BD0  ; 164.81 Hz
NOTE_F3     equ 0x1A07  ; 174.61 Hz
NOTE_FS3    equ 0x184C  ; 185.00 Hz
NOTE_G3     equ 0x169E  ; 196.00 Hz
NOTE_GS3    equ 0x14FC  ; 207.65 Hz
NOTE_A3     equ 0x1365  ; 220.00 Hz
NOTE_AS3    equ 0x11D9  ; 233.08 Hz
NOTE_B3     equ 0x1056  ; 246.94 Hz
NOTE_C4     equ 0x11CA  ; 261.63 Hz (Middle C)
NOTE_CS4    equ 0x10C4  ; 277.18 Hz
NOTE_D4     equ 0x0FC8  ; 293.66 Hz
NOTE_DS4    equ 0x0ED4  ; 311.13 Hz
NOTE_E4     equ 0x0DE8  ; 329.63 Hz
NOTE_F4     equ 0x0D04  ; 349.23 Hz
NOTE_FS4    equ 0x0C26  ; 369.99 Hz
NOTE_G4     equ 0x0B4F  ; 392.00 Hz
NOTE_GS4    equ 0x0A7E  ; 415.30 Hz
NOTE_A4     equ 0x09B3  ; 440.00 Hz
NOTE_AS4    equ 0x08ED  ; 466.16 Hz
NOTE_B4     equ 0x082B  ; 493.88 Hz
NOTE_C5     equ 0x08E5  ; 523.25 Hz
NOTE_CS5    equ 0x0862  ; 554.37 Hz
NOTE_D5     equ 0x07E4  ; 587.33 Hz
NOTE_DS5    equ 0x076A  ; 622.25 Hz
NOTE_E5     equ 0x06F4  ; 659.25 Hz
NOTE_F5     equ 0x0682  ; 698.46 Hz
NOTE_FS5    equ 0x0613  ; 739.99 Hz
NOTE_G5     equ 0x05A8  ; 783.99 Hz
NOTE_GS5    equ 0x053F  ; 830.61 Hz
NOTE_A5     equ 0x04D9  ; 880.00 Hz
NOTE_AS5    equ 0x0476  ; 932.33 Hz
NOTE_B5     equ 0x0416  ; 987.77 Hz
NOTE_C6     equ 0x0473  ; 1046.50 Hz
NOTE_E6     equ 0x037A  ; 1318.51 Hz



; =========================================== INITIALIZATION ================|80

start:
  mov ax, 0x13          ; Init 320x200, 256 colors mode
  int 0x10              ; Video BIOS interrupt

  push 0xA000           ; VGA memory segment
  pop es                ; Set ES to VGA memory segment
  xor di, di            ; Set DI to 0

  push GAME_SEGMENT
  pop ss
  mov sp, GAME_STACK_POINTER

  call initialize_custom_palette

  mov byte [_GAME_STATE_], STATE_INIT_ENGINE

; =========================================== GAME LOOP =====================|80

main_loop:

; =========================================== GAME STATES ===================|80

  movzx bx, byte [_GAME_STATE_]    ; Load state into BX
  shl bx, 1                        ; Multiply by 2 (word size)
  call word [StateJumpTable + bx]   ; Jump to handle

game_state_satisfied:

; =========================================== KEYBOARD INPUT ================|80

check_keyboard:
  mov ah, 01h         ; BIOS keyboard status function
  int 16h             ; Call BIOS interrupt
  jz .keyboard_done

  mov ah, 00h         ; BIOS keyboard read function
  int 16h             ; Call BIOS interrupt

  ; ========================================= STATE TRANSITIONS ============|80
  mov si, StateTransitionTable
  mov cx, StateTransitionTableEnd-StateTransitionTable
  .check_transitions:
    mov bl, [_GAME_STATE_]
    cmp bl, [si]        ; Check current state
    jne .next_entry

    cmp ah, [si+1]      ; Check key press
    jne .next_entry

    mov bl, [si+2]      ; Get new state
    mov [_GAME_STATE_], bl
    jmp .transitions_done

  .next_entry:
    add si, 3           ; Move to next entry
    loop .check_transitions

.transitions_done:

; ========================================= GAME LOGIC INPUT =============|80

  mov si, InputTable
  mov cx, InputTableEnd-InputTable
  .check_input:
    mov bl, [_GAME_STATE_]
    cmp bl, [si]        ; Check current state
    jne .next_input

    cmp byte [si+1], MODE_ALL
    je .check_keypress
    mov bl, [_SCENE_MODE_]
    cmp bl, [si+1]      ; Check current mode
    jne .next_input

    .check_keypress:
    cmp ah, [si+2]      ; Check key press
    jne .next_input

    mov bx, [si+3]
    call bx
    jmp .keyboard_done

  .next_input:
    add si, 5           ; Move to next entry
  loop .check_input

.keyboard_done:

; =========================================== GAME TICK =====================|80

.cpu_delay:
  xor ax, ax            ; Function 00h: Read system timer counter
  int 0x1a              ; Returns tick count in CX:DX
  mov bx, dx            ; Store low word of tick count
  mov si, cx            ; Store high word of tick count
  .wait_loop:
    xor ax, ax
    int 0x1a
    cmp cx, si          ; Compare high word
    jne .tick_changed
    cmp dx, bx          ; Compare low word
    je .wait_loop       ; If both are the same, keep waiting
  .tick_changed:

.update_system_tick:
  cmp dword [_GAME_TICK_], 0xF0000000
  jb .skip_tick_reset
    mov dword [_GAME_TICK_], 0
  .skip_tick_reset:
  inc dword [_GAME_TICK_]

call update_audio

; =========================================== ESC OR LOOP ===================|80

jmp main_loop

; =========================================== EXIT TO DOS ===================|80

exit:
  call stop_sound
  mov ax, 0x0003       ; Set video mode to 80x25 text mode
  int 0x10             ; Call BIOS interrupt
  mov si, QuitText     ; Draw message after exit
  xor dx, dx           ; At 0/0 position
  call draw_text

  mov ax, 0x4c00      ; Exit to DOS
  int 0x21            ; Call DOS
  ret                 ; Return to DOS



game_logic:

  .move_viewport_up:
    cmp word [_VIEWPORT_Y_], 0
    je .done
    dec word [_VIEWPORT_Y_]
    dec word [_CURSOR_Y_]
  jmp .redraw_terrain
  .move_viewport_down:
    cmp word [_VIEWPORT_Y_], MAP_SIZE-VIEWPORT_HEIGHT
    jae .done
    inc word [_VIEWPORT_Y_]
    inc word [_CURSOR_Y_]
  jmp .redraw_terrain
  .move_viewport_left:
    cmp word [_VIEWPORT_X_], 0
    je .done
    dec word [_VIEWPORT_X_]
    dec word [_CURSOR_X_]
  jmp .redraw_terrain
  .move_viewport_right:
    cmp word [_VIEWPORT_X_], MAP_SIZE-VIEWPORT_WIDTH
    jae .done
    inc word [_VIEWPORT_X_]
    inc word [_CURSOR_X_]
  jmp .redraw_terrain

  .move_cursor_up:
    mov ax, [_VIEWPORT_Y_]
    cmp word [_CURSOR_Y_], ax
    je .done
    dec word [_CURSOR_Y_]
  jmp .redraw_tile
  .move_cursor_down:
    mov ax, [_VIEWPORT_Y_]
    add ax, VIEWPORT_HEIGHT-1
    cmp word [_CURSOR_Y_], ax
    jae .done
    inc word [_CURSOR_Y_]
  jmp .redraw_tile
  .move_cursor_left:
    mov ax, [_VIEWPORT_X_]
    cmp word [_CURSOR_X_], ax
    je .done
    dec word [_CURSOR_X_]
  jmp .redraw_tile
  .move_cursor_right:
    mov ax, [_VIEWPORT_X_]
    add ax, VIEWPORT_WIDTH-1
    cmp word [_CURSOR_X_], ax
    jae .done
    inc word [_CURSOR_X_]
  jmp .redraw_tile

  .set_mode_panning:
    mov byte [_SCENE_MODE_], MODE_VIEWPORT_MOVE
    jmp .redraw_tile
  .set_mode_placing:
    mov byte [_SCENE_MODE_], MODE_INFRASTRUCTURE_PLACE
    jmp .redraw_tile
  .set_mode_editing:
    mov byte [_SCENE_MODE_], MODE_INFRASTRUCTURE_EDIT
    jmp .redraw_tile
  .set_mode_removing:
    mov byte [_SCENE_MODE_], MODE_TERRAIN_REMOVE
    jmp .redraw_tile

  .rails_place:
    cmp word [_ECONOMY_TRACKS_], 0      ; check economy: track count
    jz .error

    mov bx, SFX_BUILD
    call play_sfx

    mov ax, [_CURSOR_Y_]                ; calculate map position
    shl ax, 7   ; Y * 128
    add ax, [_CURSOR_X_]
    mov di, _MAP_
    add di, ax

    mov al, [di]                        ; get tile data at current place
    test al, META_TRANSPORT             ; check if empty
    jnz .done
    test al, META_INVISIBLE_WALL
    jz .done

    dec word [_ECONOMY_TRACKS_]         ; decrease track count

    and al, 0x3
    add al, META_TRANSPORT
    mov [di], al               ; set railroad tile

    call draw_ui
  jmp .redraw_tile

  .station_place:
  jmp .redraw_tile

  .cart_place:
  jmp .redraw_tile

  .infrastructure_edit:
    mov ax, [_CURSOR_Y_]                ; calculate map position
    shl ax, 7   ; Y * 128
    add ax, [_CURSOR_X_]
    mov si, _METADATA_
    add si, ax                          ; set tile position in _METADATA_
    mov al, [si]                        ; read _METADATA_ for this tile pos
    test al, METADATA_SWITCH_INITIALIZED
    jz .done                            ; not a swich, skip
    mov bl, al                          ; save the metadata value
    mov bh, 0xFF                        ; calculate the bit mask
    sub bh, METADATA_SWITCH_MASK        ; to everything beside switch
    and bl, bh                          ; clear switch data (in saved value)
    and al, METADATA_SWITCH_MASK        ; mask swich data
    shr al, METADATA_SWITCH_SHIFT       ; move to right to conv to number
    xor al, 0x2                         ; invert swich top-down or left-right
    shl al, METADATA_SWITCH_SHIFT       ; move back to left for correct position
    or bl, al                           ; set new sitch to saved metadata value
    mov [si], bl                        ; save in _METADATA_

  jmp .redraw_tile

  .terrain_remove:
  jmp .redraw_tile

  jmp .no_error
  .error:
    mov bx, SFX_ERROR
    call play_sfx
  .no_error:

  .redraw_tile:
    ; to be optimize later
    ; for now redrawn everything

    ; mov ax, [_CURSOR_Y_]
    ; mov bx, [_CURSOR_X_]
    ; call redraw_terrain_tile
    ; call draw_entities
    ; call draw_cursor
    ; jmp .done

  .redraw_terrain:
    call draw_terrain
    call draw_entities
    call draw_cursor
    jmp .done

    .done:
ret








; =========================================== LOGIC FOR GAME STATES =========|80

StateJumpTable:
  dw init_engine
  dw exit
  dw init_title_screen
  dw live_title_screen
  dw init_menu
  dw live_menu
  dw new_game
  dw init_game
  dw live_game
  dw init_map_view
  dw live_map_view
  dw init_debug_view
  dw live_debug_view
  dw init_help
  dw live_help

StateTransitionTable:
  db STATE_TITLE_SCREEN, KB_ESC,   STATE_QUIT
  db STATE_TITLE_SCREEN, KB_ENTER, STATE_MENU_INIT

  db STATE_MENU,         KB_ESC,   STATE_QUIT
  db STATE_MENU,         KB_ENTER, STATE_GAME_INIT
  db STATE_MENU,         KB_F1,    STATE_GAME_NEW
  db STATE_MENU,         KB_F2,    STATE_DEBUG_VIEW_INIT
  db STATE_MENU,         KB_F3,    STATE_DEBUG_VIEW_INIT
  db STATE_MENU,         KB_F4,    STATE_HELP_INIT

  db STATE_HELP,        KB_ESC,   STATE_MENU_INIT

  db STATE_GAME,         KB_ESC,   STATE_MENU_INIT
  db STATE_GAME,         KB_TAB,   STATE_MAP_VIEW_INIT
  db STATE_MAP_VIEW,     KB_ESC,   STATE_MENU_INIT
  db STATE_MAP_VIEW,     KB_TAB,   STATE_GAME_INIT
  db STATE_DEBUG_VIEW,   KB_ESC,   STATE_MENU_INIT
StateTransitionTableEnd:

InputTable:
  db STATE_GAME,        MODE_ALL,  KB_F1
  dw game_logic.set_mode_panning
  db STATE_GAME,        MODE_ALL,  KB_F2
  dw game_logic.set_mode_placing
  db STATE_GAME,        MODE_ALL,  KB_F3
  dw game_logic.set_mode_editing
  db STATE_GAME,        MODE_ALL,  KB_F4
  dw game_logic.set_mode_removing

  db STATE_GAME,        MODE_VIEWPORT_MOVE,  KB_UP
  dw game_logic.move_viewport_up
  db STATE_GAME,        MODE_VIEWPORT_MOVE,  KB_DOWN
  dw game_logic.move_viewport_down
  db STATE_GAME,        MODE_VIEWPORT_MOVE,  KB_LEFT
  dw game_logic.move_viewport_left
  db STATE_GAME,        MODE_VIEWPORT_MOVE,  KB_RIGHT
  dw game_logic.move_viewport_right

  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_UP
  dw game_logic.move_cursor_up
  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_DOWN
  dw game_logic.move_cursor_down
  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_LEFT
  dw game_logic.move_cursor_left
  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_RIGHT
  dw game_logic.move_cursor_right
  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_SPACE
  dw game_logic.rails_place
  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_1
  dw game_logic.station_place
  db STATE_GAME,        MODE_INFRASTRUCTURE_PLACE,  KB_2
  dw game_logic.cart_place

  db STATE_GAME,        MODE_INFRASTRUCTURE_EDIT,  KB_UP
  dw game_logic.move_cursor_up
  db STATE_GAME,        MODE_INFRASTRUCTURE_EDIT,  KB_DOWN
  dw game_logic.move_cursor_down
  db STATE_GAME,        MODE_INFRASTRUCTURE_EDIT,  KB_LEFT
  dw game_logic.move_cursor_left
  db STATE_GAME,        MODE_INFRASTRUCTURE_EDIT,  KB_RIGHT
  dw game_logic.move_cursor_right
  db STATE_GAME,        MODE_INFRASTRUCTURE_EDIT,  KB_SPACE
  dw game_logic.infrastructure_edit


  db STATE_GAME,        MODE_TERRAIN_REMOVE,  KB_UP
  dw game_logic.move_cursor_up
  db STATE_GAME,        MODE_TERRAIN_REMOVE,  KB_DOWN
  dw game_logic.move_cursor_down
  db STATE_GAME,        MODE_TERRAIN_REMOVE,  KB_LEFT
  dw game_logic.move_cursor_left
  db STATE_GAME,        MODE_TERRAIN_REMOVE,  KB_RIGHT
  dw game_logic.move_cursor_right
  db STATE_GAME,        MODE_TERRAIN_REMOVE,  KB_SPACE
  dw game_logic.terrain_remove

InputTableEnd:



; ======================================= PROCEDURES FOR GAME STATES ========|80

init_engine:
  call reset_to_default_values
  call init_audio_system
  call decompress_tiles
  call generate_map
  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN_INIT

ret

reset_to_default_values:
  mov byte [_GAME_TICK_], 0x0
  mov word [_RNG_], 0x42

  mov word [_VIEWPORT_X_], MAP_SIZE/2-VIEWPORT_WIDTH/2
  mov word [_VIEWPORT_Y_], MAP_SIZE/2-VIEWPORT_HEIGHT/2
  mov word [_CURSOR_X_], MAP_SIZE/2
  mov word [_CURSOR_Y_], MAP_SIZE/2

  mov word [_ECONOMY_BLUE_RES_], 0
  mov word [_ECONOMY_YELLOW_RES_], 0
  mov word [_ECONOMY_RED_RES_], 0
  mov word [_ECONOMY_TRACKS_], DEFAULT_ECONOMY_TRACKS
  mov word [_ECONOMY_SCORE_], 0
ret

init_title_screen:
  mov si, start       ; Points to start of this code, wil be used as RNG
  mov cx, 40*25
  .random_numbers:
    lodsb             ; load values from source code
    and ax, 0x7       ; 0-7 values
    add al, 0x30      ; move to ASCII numbers position
    mov ah, 0x0e      ; BIOS write character
    mov bh, 0         ; set page number
    mov bl, COLOR_DARK_GRAY
    int 0x10          ; draw character
  loop .random_numbers

  mov si, WelcomeText
  mov dx, 0x140B
  mov bl, COLOR_WHITE
  call draw_text

  mov bx, INTRO_JINGLE
  call play_sfx


  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN
ret

live_title_screen:
  mov si, PressEnterText
  mov dx, 0x1516
  mov bl, COLOR_WHITE
  test word [_GAME_TICK_], 0x4
  je .blink
    mov bl, COLOR_BLACK
  .blink:
  call draw_text

ret

init_menu:
  mov al, COLOR_NAVY_BLUE
  call clear_screen

  call draw_terrain

  ; draw logo sprites

  ; draw window
  mov ax, 0x090C
  mov bx, 0x1014
  call draw_window

  mov si, MainMenuText
  mov bl, COLOR_YELLOW
  mov dx, 0x0A0D
  .menu_entry:
    cmp byte [si], 0x00
    jz .done
    call draw_text
    add dh, 0x2
  jmp .menu_entry

  .done:

  mov si, MainMenuCopyText
  mov dx, 0x160D
  mov bl, COLOR_LIGHT_GRAY
  call draw_text

  mov byte [_GAME_STATE_], STATE_MENU
  mov byte [_SCENE_MODE_], MODE_MAIN_MENU
  mov bx, MENU_JINGLE
  call play_sfx
ret

live_menu:
  nop
ret

init_help:
  mov al, COLOR_DARK_GRAY
  call clear_screen

  mov si, HelpText
  mov bl, COLOR_YELLOW
  xor dx, dx
  .help_entry:
    cmp byte [si], 0x00
    jz .done
    call draw_text
    inc dh
  jmp .help_entry
  .done:
  mov byte [_GAME_STATE_], STATE_HELP
  mov byte [_SCENE_MODE_], MODE_HELP_PAGE1
ret

live_help:
ret

new_game:
  call generate_map
  call reset_to_default_values

  mov byte [_GAME_STATE_], STATE_MENU_INIT
  mov byte [_SCENE_MODE_], MODE_VIEWPORT_MOVE
ret

init_game:
  call draw_terrain
  call draw_entities
  call draw_cursor
  call draw_ui
  mov byte [_GAME_STATE_], STATE_GAME
  mov byte [_SCENE_MODE_], MODE_VIEWPORT_MOVE
  mov bx, GAME_JINGLE
  call play_sfx
ret

live_game:
  nop
ret

init_map_view:
  call draw_minimap
  mov byte [_GAME_STATE_], STATE_MAP_VIEW
  mov bx, MAP_JINGLE
  call play_sfx
ret

live_map_view:
  nop
ret

init_debug_view:
  mov al, COLOR_BLACK
  call clear_screen

  mov di, 320*16+16        ; Position on screen
  xor ax, ax               ; Sprite ID 0
  mov cx, TILES_COUNT
  .spr:
    call draw_sprite
    inc ax                ; Next prite ID

    .test_new_line:
    mov bx, ax
    and bx, 0xF
    cmp bx, 0
    jne .skip_new_line
      add di, 320*SPRITE_SIZE-SPRITE_SIZE*18 + 320*2 ; New line + 2px
    .skip_new_line:

    add di, 18        ; Move to next slot + 2px
  loop .spr

  mov byte [_GAME_STATE_], STATE_DEBUG_VIEW
ret

live_debug_view:
  nop
ret


























; =========================================== PROCEDURES ====================|80

; =========================================== CUSTOM PALETTE ================|80
; IN: Palette data in RGB format
; OUT: VGA palette initialized
initialize_custom_palette:
  mov si, CustomPalette      ; Palette data pointer
  mov dx, 03C8h        ; DAC Write Port (start at index 0)
  xor al, al           ; Start with color index 0
  out dx, al           ; Send color index to DAC Write Port
  mov dx, 03C9h        ; DAC Data Port
  mov cx, 16*3         ; 16 colors × 3 bytes (R, G, B)
  rep outsb            ; Send all RGB values
ret

CustomPalette:
; DawnBringer 16 color palette
; https://github.com/geoffb/dawnbringer-palettes
; Converted from 8-bit to 6-bit for VGA
db  0,  0,  0    ; #000000 - Black
db 17,  8, 13    ; #442434 - Deep purple
db 12, 13, 27    ; #30346D - Navy blue
db 19, 18, 19    ; #4E4A4E - Dark gray
db 33, 19, 12    ; #854C30 - Brown
db 13, 25,  9    ; #346524 - Dark green
db 52, 17, 18    ; #D04648 - Red
db 29, 28, 24    ; #757161 - Light gray
db 22, 31, 51    ; #597DCE - Blue
db 52, 31, 11    ; #D27D2C - Orange
db 33, 37, 40    ; #8595A1 - Steel blue
db 27, 42, 11    ; #6DAA2C - Green
db 52, 42, 38    ; #D2AA99 - Pink/Beige
db 27, 48, 50    ; #6DC2CA - Cyan
db 54, 53, 23    ; #DAD45E - Yellow
db 55, 59, 53    ; #DEEED6 - White

; =========================================== DRAW TEXT =====================|80
; IN:
;  SI - Pointer to text
;  DL - X position
;  DH - Y position
;  BX - Color
draw_text:
  mov ah, 0x02   ; Set cursor
  xor bh, bh     ; Page 0
  int 0x10

  .next_char:
    lodsb          ; Load next character from SI into AL
    test al, al    ; Check for string terminator
    jz .done       ; If terminator, we're done

    mov ah, 0x0E   ; Teletype output
    mov bh, 0      ; Page 0
    int 0x10       ; BIOS video interrupt

    jmp .next_char ; Process next character

  .done:
ret

; =========================================== DRAW NUMBER ===================|80
; IN:
;  SI - Value to display (decimal)
;  DL - X position
;  DH - Y position
;  BX - Color
draw_number:
  mov ah, 0x02   ; Set cursor
  xor bh, bh     ; Page 0
  int 0x10

  mov cx, 10000  ; Divisor starting with 10000 (for 5 digits)
  mov ax, si     ; Copy the number to AX for division

  .next_digit:
    xor dx, dx     ; Clear DX for division
    div cx         ; Divide AX by CX, quotient in AX, remainder in DX

    ; Convert digit to ASCII
    add al, '0'    ; Convert to ASCII

    ; Print the character
    mov ah, 0x0E   ; Teletype output
    push dx        ; Save remainder
    push cx        ; Save divisor
    mov bh, 0      ; Page 0
    int 0x10       ; BIOS video interrupt
    pop cx         ; Restore divisor
    pop dx         ; Restore remainder

    ; Move remainder to AX for next iteration
    mov ax, dx

    ; Update divisor
    push ax        ; Save current remainder
    mov ax, cx     ; Get current divisor in AX
    xor dx, dx     ; Clear DX for division
    push bx
    mov bx, 10     ; Divide by 10
    div bx         ; AX = AX/10
    pop bx
    mov cx, ax     ; Set new divisor
    pop ax         ; Restore current remainder

    ; Check if we're done
    cmp cx, 0      ; If divisor is 0, we're done
    jne .next_digit

ret

; =========================================== GET RANDOM ====================|80
; OUT: AX - Random number
get_random:
  mov ax, [_RNG_]
  inc ax
  rol ax, 1
  xor ax, 0x1337
  add ax, [_GAME_TICK_]
  mov [_RNG_], ax
ret

; =========================================== CLEAR SCREEN ==================|80
; IN: AL - Color
; OUT: VGA memory cleared (fullscreen)
clear_screen:
  mov ah, al
  mov cx, SCREEN_WIDTH*SCREEN_HEIGHT/2    ; Number of pixels
  xor di, di           ; Start at 0
  rep stosw            ; Write to the VGA memory
ret

; =========================================== DRAW GRADIENT =================|80
; IN:
; DI - Position
; AL - Color
; OUT: VGA memory filled with gradient
draw_gradient:
  mov ah, al
  mov dl, 0xD                ; Number of bars to draw
  .draw_gradient:
    mov cx, SCREEN_WIDTH*4           ; Number of pixels high for each bar
    rep stosw               ; Write to the VGA memory
    cmp dl, 0x8             ; Check if we are in the middle
    jl .down                ; If not, decrease
    inc al                  ; Increase color in right pixel
    jmp .up
    .down:
    dec al                  ; Decrease color in left pixel
    .up:
    xchg al, ah             ; Swap colors (left/right pixel)
    dec dl                  ; Decrease number of bars to draw
    jg .draw_gradient       ; Loop until all bars are drawn
ret

; =========================================== DRAW WINDOW ===================|80
; IN:
; AX - Position
; BX - size
draw_window:

  xor di, di
  xor bx, bx
  mov bl, ah        ; Y coordinate
  shl bx, 0x3
  imul bx, SCREEN_WIDTH
  and ax, 0x00FF
  shl ax, 0x3
  add bx, ax        ; Y * 64 + X
  add di, bx

  mov ax, TILE_WINDOW_1
  call draw_tile

ret

TERRAIN_RULES_MASK equ 0x03
; =========================================== GENERATE MAP ==================|80
generate_map:
  mov di, _MAP_
  mov si, TerrainRules
  mov cx, MAP_SIZE                      ; Height
  .next_row:
    mov dx, MAP_SIZE                    ; Width
    .next_col:
      call get_random                   ; AX is random value
      and ax, TERRAIN_RULES_MASK        ; Crop to 0-3
      mov [di], al                      ; Save terrain tile
      cmp dx, MAP_SIZE                  ; Check if first col
      je .skip_cell
      cmp cx, MAP_SIZE                  ; Check if first row
      je .skip_cell
      movzx bx, [di-1]                  ; Get left tile
      test al, 0x1                      ; If odd value skip checking top
      jz .skip_top
      movzx bx, [di-MAP_SIZE]           ; Get top tile
      .skip_top:
      shl bx, 2                         ; Mul by 4 to fit rules table
      add bx, ax                        ; Get random rule for the tile ID
      mov al, [si+bx]                   ; Get the tile ID from rules table
      mov [di], al                      ; Save terrain tile
      .skip_cell:
      inc di                            ; Next map tile cell
      dec dx                            ; Next column (couner is top-down)
    jnz .next_col
  loop .next_row

  .set_metadata:
    mov si, _MAP_
    mov cx, MAP_SIZE*MAP_SIZE
    .meta_next_cell:
      cmp byte [si], TILE_TREES_1
      jge .skip
      add byte [si], META_INVISIBLE_WALL
      .skip:
      inc si
    loop .meta_next_cell
ret

; =========================================== DRAW TERRAIN ==================|80
; OUT: Terrain drawn on the screen
draw_terrain:
  xor di, di
  mov si, _MAP_
  mov ax, [_VIEWPORT_Y_]  ; Y coordinate
  shl ax, 7               ; Y * 64
  add ax, [_VIEWPORT_X_]  ; Y * 64 + X
  add si, ax
  xor ax, ax
  mov cx, VIEWPORT_HEIGHT
  .draw_line:
    push cx
    mov cx, VIEWPORT_WIDTH
    .draw_cell:
      lodsb
      mov bl, al
      and al, META_TILES_MASK ; clear metadata
      call draw_tile

      test bl, META_TRANSPORT
      jz .skip_rails
        call caculate_and_draw_rails
      .skip_rails:

      add di, SPRITE_SIZE
    loop .draw_cell
    add di, SCREEN_WIDTH*(SPRITE_SIZE-1)
    add si, MAP_SIZE-VIEWPORT_WIDTH
    pop cx
  loop .draw_line

  xor di, di
  mov cx, 320
  mov al, COLOR_WHITE
  rep stosb
  mov cx, 320
  mov al, COLOR_NAVY_BLUE
  rep stosb
ret

; =========================================== DRAW TERRAIN TILE ============|80
; IN: AX/BX - Y/X
; OUT: Tile drawn on the screen
redraw_terrain_tile:
  push si
  shl ax, 8
  add ax, bx
  mov si, _MAP_
  add si, ax
  lodsb
  mov bl, al
  and al, META_TILES_MASK ; clear metadata
  call draw_tile
  pop si
ret


caculate_and_draw_rails:
  xor ax, ax
  dec si
  .test_up:
    test byte [si-MAP_SIZE], META_TRANSPORT
    jz .test_right
    add al, 0x8
  .test_right:
    test byte [si+1], META_TRANSPORT
    jz .test_down
    add al, 0x4
  .test_down:
  test byte [si+MAP_SIZE], META_TRANSPORT
  jz .test_left
    add al, 0x2
  .test_left:
  test byte [si-1], META_TRANSPORT
  jz .done_calculating
    add al, 0x1
  .done_calculating:
  mov dl, al                            ; Save connection pattern

  inc si
  mov bx, RailroadsList
  xlatb
  add al, TILE_RAILS_1                  ; Shift to first railroad tiles
  call draw_sprite

  .calculate_correct_switch:
    cmp dl, 0x7
    je .prepare_switch_horizontal
    cmp dl, 0xB
    je .prepare_switch_vertical
    cmp dl, 0x0D
    je .prepare_switch_horizontal
    cmp dl, 0x0E
    je .prepare_switch_vertical
    jmp .no_switch

  .prepare_switch_horizontal:
    mov dl, 0                           ; left switch ID
    mov dh, METADATA_SWITCH_INITIALIZED ; data for saving in _METADATA_
    jmp .draw_switch
  .prepare_switch_vertical:
    mov dl, 1                           ; down switch ID
    mov dh, 1
    shl dh, METADATA_SWITCH_SHIFT
    add dh, METADATA_SWITCH_INITIALIZED ; data for saving in _METADATA_
  .draw_switch:
  push si                               ; save tile position
  dec si
  sub si, _MAP_                         ; calculate position in _MAP_
  add si, _METADATA_                    ; add it to the _METADATA_ for same pos
  mov al, [si]                          ; read _METADATA_ for this tile
  test al, METADATA_SWITCH_INITIALIZED
  jnz .switch_initialized
  .initialize_switch:
    mov byte [si], dh                   ; save horizontal/vertical to _METADATA_
    mov al, dl                          ; save switch ID for drawing
  jmp .draw_initialized_switch
  .switch_initialized:
  and al, METADATA_SWITCH_MASK
  shr al, METADATA_SWITCH_SHIFT
  .draw_initialized_switch:
  add al, TILE_SWITCH_LEFT              ; shift to first switch sprite data
  pop si                                ; load tile position
  call draw_sprite
  .no_switch:
ret

; =========================================== DECOMPRESS SPRITE ============|80
; IN: SI - Compressed sprite data address
; DI - sprites memory data address
; OUT: Sprite decompressed to _TILES_
decompress_sprite:
  lodsb
  movzx dx, al   ; save palette
  shl dx, 2      ; multiply by 4 (palette size)

  mov cx, SPRITE_SIZE   ; Sprite width
.plot_line:
    push cx           ; Save lines
    lodsw             ; Load 16 pixels

    mov cx, SPRITE_SIZE      ; 16 pixels in line
    .draw_pixel:
      cmp cx, SPRITE_SIZE/2
      jnz .cont
        lodsw
      .cont:
      rol ax, 2        ; Shift to next pixel

      mov bx, ax     ; Saves word
      and bx, 0x3    ; Cut last 2 bits
      add bx, dx     ; add palette shift
      mov byte bl, [Palettes+bx] ; get color from palette
      mov byte [di], bl  ; Write pixel color
      inc di           ; Move destination to next pixel
    loop .draw_pixel

  pop cx                   ; Restore line counter
  loop .plot_line
ret

; =========================================== DECOMPRESS TILES ============|80
; OUT: Tiles decompressed to _TILES_
decompress_tiles:
  xor di, _TILES_
  mov si, Tiles
  .decompress_next:
    cmp byte [si], 0xFF
    jz .done
    call decompress_sprite
  jmp .decompress_next
  .done:
ret

; =========================================== DRAW TILE =====================|80
; `: SI - Tile data
; AL - Tile ID
; DI - Position
; OUT: Tile drawn on the screen
draw_tile:
  pusha
  shl ax, 8         ; Multiply by 256 (tile size in array)
  mov si, _TILES_   ; Point to tile data
  add si, ax        ; Point to tile data
  mov bx, SPRITE_SIZE
  .draw_tile_line:
    mov cx, SPRITE_SIZE/4
    rep movsd      ; Move 2px at a time
    add di, SCREEN_WIDTH-SPRITE_SIZE ; Next line
    dec bx
  jnz .draw_tile_line
  popa
ret

; =========================================== DRAW SPRITE ===================|80
; IN:
; AL - Sprite ID
; DI - Position
; OUT: Sprite drawn on the screen
draw_sprite:
  pusha
  mov si, _TILES_   ; Point to tile data
  shl ax, 8
  add si, ax
  mov bx, SPRITE_SIZE
  .draw_tile_line:
    mov cx, SPRITE_SIZE
    .draw_next_pixel:
      lodsb
      test al, al
      jz .skip_transparent_pixel
        mov byte [es:di], al
      .skip_transparent_pixel:
      inc di
    loop .draw_next_pixel
    add di, SCREEN_WIDTH-SPRITE_SIZE ; Next line
    dec bx
  jnz .draw_tile_line
  popa
ret

; =========================================== INIT ENTITIES =================|80
init_entities:
  mov di, _ENTITIES_
  mov cx, 0x80
  .next_entity:
    call get_random
    and al, MAP_SIZE-1    ; X position (0-127)
    and ah, MAP_SIZE-1    ; Y position (0-127)
    mov word [di], ax     ; Store X,Y position
    add di, 2

    call get_random
    and ax, 0x7           ; Entity type (0-7)
    mov byte [di], al     ; Store entity type
    inc di                ; Move to next entity

    mov byte [di], 0x0   ; META data
    inc di
    loop .next_entity

  mov word [di], 0x0      ; Terminator
ret

; =========================================== DRAW ENTITIES =================|80
; OUT: Entities drawn on the screen
draw_entities:
  mov si, _ENTITIES_
  .next_entity:
    lodsw
    test ax, ax
    jz .done

    .check_bounds:
      movzx bx, ah
      sub bx, [_VIEWPORT_Y_]
      jc .skip_entity
      cmp bx, VIEWPORT_HEIGHT
      jge .skip_entity

      movzx cx, al
      sub cx, [_VIEWPORT_X_]
      jc .skip_entity
      cmp cx, VIEWPORT_WIDTH
      jge .skip_entity

    .calculate_position:
      shl bx, 4
      shl cx, 4
      imul bx, SCREEN_WIDTH
      add bx, cx               ; AX = Y * 16 * 320 + X * 16
      mov di, bx               ; Move result to DI

    .draw_on_screen:
      lodsb                ; Load tile ID
      call draw_sprite

    .check_if_cart:
      lodsb                ; Load META data
      test al, META_CART
      jz .next_entity

      and al, META_RESOURCE_TYPE_MASK
      shr al, META_RESOURCE_TYPE_SHIFT
      cmp al, META_RESOURCE_BLUE
      jnz .draw_blue_cart
      cmp al, META_RESOURCE_YELLOW
      jnz .draw_yellow_cart
      cmp al, META_RESOURCE_RED
      jnz .draw_red_cart
      jmp .next_entity

      .draw_yellow_cart:
        mov al, TILE_ORE_YELLOW
        call draw_sprite
        jmp .next_entity

      .draw_blue_cart:
        mov al, TILE_ORE_BLUE
        call draw_sprite
        jmp .next_entity

      .draw_red_cart:
        mov al, TILE_ORE_RED
        call draw_sprite
        jmp .next_entity

    jmp .next_entity
    .skip_entity:
      add si, 2
      jmp .next_entity
  .done:
ret

draw_cursor:
  mov bx, [_CURSOR_Y_]    ; Y coordinate
  sub bx, [_VIEWPORT_Y_]  ; Y - Viewport Y
  shl bx, 4               ; Y * 16
  mov ax, [_CURSOR_X_]    ; X coordinate
  sub ax, [_VIEWPORT_X_]  ; X - Viewport X
  shl ax, 4               ; X * 16
  imul bx, SCREEN_WIDTH   ; Y * 16 * 320
  add bx, ax              ; Y * 16 * 320 + X * 16
  mov di, bx              ; Move result to DI


  cmp byte [_SCENE_MODE_], MODE_VIEWPORT_MOVE
  jz .panning_cursor
  cmp byte [_SCENE_MODE_], MODE_INFRASTRUCTURE_PLACE
  jz .placing_cursor
  cmp byte [_SCENE_MODE_], MODE_INFRASTRUCTURE_EDIT
  jz .edit_cursor
  cmp byte [_SCENE_MODE_], MODE_TERRAIN_REMOVE
  jz .remove_cursor

  .panning_cursor:
    mov al, TILE_CURSOR_PAN
    jmp .draw_selected_cursor
  .placing_cursor:
    mov al, TILE_CURSOR_BUILD
    jmp .draw_selected_cursor
  .edit_cursor:
    mov al, TILE_CURSOR_EDIT
    jmp .draw_selected_cursor
  .remove_cursor:
    mov al, TILE_CURSOR_REMOVE

  .draw_selected_cursor:
  call draw_sprite
ret

draw_minimap:
  .draw_frame:
    mov di, SCREEN_WIDTH*30+90
    mov ax, COLOR_BROWN
    mov cx, 140
    .draw_line:
      push cx
      mov cx, 70
      rep stosw
      pop cx
      add di, 320-140
    loop .draw_line

   .draw_mini_map:
    mov si, _MAP_              ; Map data
    mov di, SCREEN_WIDTH*36+96          ; Map position on screen
    mov bx, TerrainColors      ; Terrain colors array
    mov cx, MAP_SIZE           ; Columns
    .draw_loop:
      push cx
      mov cx, MAP_SIZE        ; Rows
      .draw_row:
        lodsb                ; Load map cell
        and al, META_TILES_MASK ; Clear metadata
        xlatb                ; Translate to color
        mov ah, al           ; Copy color for second pixel
        mov [es:di], al      ; Draw 1 pixels
        add di, 1            ; Move to next column
      loop .draw_row
      pop cx
      add di, 320-MAP_SIZE    ; Move to next row
    loop .draw_loop

    xor ax, ax

   mov si, _ENTITIES_
   .next_entity:
      lodsw
      test ax, ax
      jz .end_entities
      movzx bx, ah
      imul bx, SCREEN_WIDTH
      movzx cx, al
      add bx, cx
      mov di, SCREEN_WIDTH*35+96
      add di, bx
      inc si
      mov byte [es:di], COLOR_WHITE
   loop .next_entity
   .end_entities:

   .draw_viewport_box:
      mov di, SCREEN_WIDTH*35+96
      mov ax, [_VIEWPORT_Y_]  ; Y coordinate
      imul ax, 320
      add ax, [_VIEWPORT_X_]  ; Y * 64 + X
      add di, ax
      mov ax, COLOR_WHITE
      mov ah, al
      mov cx, VIEWPORT_WIDTH/2
      rep stosw
      add di, SCREEN_WIDTH*VIEWPORT_HEIGHT-VIEWPORT_WIDTH
      mov cx, VIEWPORT_WIDTH/2
      rep stosw
ret

; =========================================== DRAW UI =======================|80

draw_ui:
   mov di, UI_POSITION
   mov cx, 160*UI_LINES
   mov ax, COLOR_BLACK
   rep stosw

   mov di, UI_POSITION
   mov cx, 320
   mov al, COLOR_NAVY_BLUE
   rep stosb
   mov cx, 320
   mov al, COLOR_WHITE
   rep stosb
   mov cx, 320
   add di, 320*37
   rep stosb

   mov di, UI_FIRST_LINE+8
   mov al, TILE_RAILS_3     ; Crossing
   call draw_sprite

   mov si, [_ECONOMY_TRACKS_]  ; Railroad tracks count
   mov dx, 0x01504
   mov bl, COLOR_WHITE
   cmp si, 0x0A
   jg .skip_red
      mov bl, COLOR_RED
   .skip_red:
   call draw_number

   mov di, UI_FIRST_LINE+76   ; Resource blue icon
   mov al, TILE_ORE_BLUE
   call draw_sprite

   mov si, [_ECONOMY_BLUE_RES_]  ; Blue resource count
   mov dx, 0x0150C
   mov bl, COLOR_WHITE
   call draw_number

   mov di, UI_FIRST_LINE+140
   mov al, TILE_ORE_YELLOW
   call draw_sprite

   mov si, [_ECONOMY_YELLOW_RES_]  ; Yellow resource count
   mov dx, 0x01514
   mov bl, COLOR_WHITE
   call draw_number

   mov di, UI_FIRST_LINE+204
   mov al, TILE_ORE_RED
   call draw_sprite

   mov si, [_ECONOMY_RED_RES_]  ; Red resource count
   mov dx, 0x0151C
   mov bl, COLOR_WHITE
   call draw_number

   cmp byte [_SCENE_MODE_], MODE_VIEWPORT_MOVE
   jz .panning_mode
   cmp byte [_SCENE_MODE_], MODE_INFRASTRUCTURE_PLACE
   jz .placing_mode
   cmp byte [_SCENE_MODE_], MODE_INFRASTRUCTURE_EDIT
   jz .edit_mode
   cmp byte [_SCENE_MODE_], MODE_TERRAIN_REMOVE
   jz .remove_mode

  .panning_mode:
    mov si, UIExploreModeText
    jmp .write_mode
  .placing_mode:
    mov si, UIBuildModeText
    jmp .write_mode
  .edit_mode:
    mov si, UIEditModeText
    jmp .write_mode
  .remove_mode:
    mov si, UIRemoveModeText


   .write_mode:
   mov dx, 0x01714
   mov bl, COLOR_NAVY_BLUE
   call draw_text

   mov si, UIScoreText
   mov dx, 0x01701
   mov bl, COLOR_NAVY_BLUE
   call draw_text

   mov si, [_ECONOMY_SCORE_]  ; Score value
   mov dx, 0x01708
   mov bl, COLOR_WHITE
   call draw_number

ret






; =========================================== AUDIO SYSTEM ==================|80

init_audio_system:
  mov byte [_SFX_POINTER_], 0

  mov al, 182         ; Binary mode, square wave, 16-bit divisor
  out 43h, al         ; Write to PIT command register[2]
ret

; Input: BX = pointer to sound effect data
play_sfx:
  mov [_SFX_POINTER_], bx
ret

update_audio:



  mov si, [_SFX_POINTER_]
  mov ax, [si]
  test ax, ax
  jz .stop_audio

  cmp ax, NOTE_REST
  jz .skip_note

  mov bx, [_GAME_TICK_]
  and bx, 0x1
  dec bx
  jz .play_pitched



  call play_sound
  .skip_note:
  add word [_SFX_POINTER_], 2
ret
  .play_pitched:
   shl ah, 3
   call play_sound
ret
  .stop_audio:
  call stop_sound
ret

; IN: AX - Low byte of frequency, AH - High byte of frequency
play_sound:
  out 42h, al         ; Low byte
  mov al, ah
  out 42h, al         ; High byte

  in al, 61h          ; Read current port state
  or al, 00000011b    ; Set bits 0 and 1
  out 61h, al         ; Enable speaker output
ret

stop_sound:
  in al, 61h
  and al, 11111100b   ; Clear bits 0-1
  out 61h, al
ret











; =========================================== TEXT DATA =====================|80

WelcomeText db 'P1X ASSEMBLY ENGINE V12.03', 0x0
PressEnterText db 'PRESS ENTER', 0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in for more games...', 0x0D, 0x0A, 0x0
FakeNumberText db '0000', 0x0
UIExploreModeText db 'F2: Explore Mode', 0x0
UIBuildModeText db 'F2: Build Mode', 0x0
UIEditModeText db 'F2: Edit Mode', 0x0
UIRemoveModeText db 'F2: Remove Mode', 0x0
UIScoreText db 'Score:', 0x0

MainMenuTitleText:
db 0x2F,0x20,0x27,0x20,0x2F,0x27,0x5C,0x20,0x7C,0x5F,0x29,0x20,0x2D,0x2D,0x2D,0x20,0x5C,0x27,0x5F,0x20,0x5C,0x20,0x2F,0x20,0x20,0x20,0x7C,0x20,0x20,0x2F,0x5F,0x5C,0x20,0x7C,0x5F,0x29,0x20,0x28,0x5F,0x20
db 0x5C,0x5F,0x5F,0x20,0x5C,0x5F,0x27,0x20,0x7C,0x20,0x5C,0x20,0x20,0x7C,0x20,0x20,0x2F,0x5F,0x5F,0x20,0x2F,0x20,0x5C,0x20,0x20,0x20,0x7C,0x5F,0x20,0x7C,0x20,0x7C,0x20,0x7C,0x5F,0x29,0x20,0x2E,0x5F,0x29,0x0

MainMenuText:
  db 'ENTER: Play',0x0
  db 'F2: Save',0x0
  db 'F6: Load',0x0
  db 'F1: Help',0x0
  db 'ESC: Quit',0x0
  db 0x00

HelpText:
  db '      -== HOW TO PLAY THE GAME ==-      ',0x0
  db 'Get as much points by refining blue ore.',0x0
  db 'Collect resources using extraction',0x0
  db 'facility and refine it in the rafinery.',0x0
  db 'Transport goods using carts on rails.',0x0
  db 'Build stations on rals. Building on the',0x0
  db 'fundation blocks, next to the stations.',0x0
  db '        -== INTERACTION MODES ==-       ',0x0
  db 'F1: Move map using arrows',0x0
  db 'F2: Move cursor, build rails using SPACE',0x0
  db 'F3: Swap switches, rafinery type',0x0
  db 'F4: Clear trees, rocks for rails placing',0x0
  db '           -== RESOURCES ==-            ',0x0
  db 'Refine red and green ore to get resource',0x0
  db 'Red: to build rails (1) and stations (10)',0x0
  db 'Yellow: buidings(50), clearing (5)',0x0
  db 'Blue ore: increase overall score.',0x0
  db 0x00

MainMenuCopyText db '(C) 2025 P1X',0x0

; =========================================== TERRAIN GEN RULES =============|80

TerrainRules:
db 0, 1, 1, 2   ; 0 Mud 1
db 1, 1, 2, 3   ; 1 Mud 2
db 2, 2, 1, 3   ; 2 Mud Grass 1
db 2, 3, 4, 4   ; 3 Mud Grass 2
db 3, 4, 4, 5   ; 4 Grass
db 4, 3, 5, 6   ; 5 Bush
db 6, 7, 7, 4   ; 6 Trees 1
db 7, 6, 4, 8   ; 7 Trees 2
db 7, 8, 8, 9   ; 8 Mountains 1
db 9, 8, 8, 7   ; 9 Mountain 2

TerrainColors:
db 0x4         ; Mud 1
db 0x4         ; Mud 2
db 0x4         ; Some Grass
db 0x5         ; Dense Grass
db 0x5         ; Bush
db 0x5         ; Forest
db 0xA         ; Mountain

; =========================================== TILES =========================|80

RailroadsList:
db 0, 0, 1, 4, 0, 0, 3, 9, 1, 6, 1, 10, 5, 7, 8, 2

include 'sfx.asm'

include 'tiles.asm'

; =========================================== THE END =======================|80
; Thanks for reading the source code!
; Visit http://smol.p1x.in/assembly/ for more.

Logo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary
