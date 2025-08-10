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
;   - custom tool for tileset conversion
;   - custom tool for RLE image compression
;
; ==============================================================================
; Latest revision: 06/2025
; ==============================================================================

org 0x0100

; =========================================== MEMORY LAYOUT =================|80

GAME_STACK_POINTER          equ 0xFFFE    ; Stack pointer for game code
SEGMENT_SPRITES             equ 0x5400    ; 96 tiles (6KB)
SEGMENT_TERRAIN_BACKGROUND  equ 0x6400    ; First map layer (16KB)
SEGMENT_TERRAIN_FOREGROUND  equ 0x6800    ; Second map layer (16KB)
SEGMENT_META_DATA           equ 0x6C00    ; Third map layer (16KB)
SEGMENT_MAP_ENTITIES        equ 0x7000    ; Fourth map layer (16KB)
SEGMENT_ENTITIES            equ 0x7400    ; Entities data
SEGMENT_VGA                 equ 0xA000    ; VGA memory (fixed by hardware)

; =========================================== MEMORY ALLOCATION =============|80

_BASE_                    equ _END_OF_CODE_ + 0x100
_GAME_TICK_               equ _BASE_ + 0x00   ; 4 bytes
_GAME_STATE_              equ _BASE_ + 0x04   ; 1 byte
_RNG_                     equ _BASE_ + 0x05   ; 2 bytes
_VIEWPORT_X_              equ _BASE_ + 0x07   ; 2 bytes
_VIEWPORT_Y_              equ _BASE_ + 0x09   ; 2 bytes
_CURSOR_X_                equ _BASE_ + 0x0B   ; 2 bytes
_CURSOR_Y_                equ _BASE_ + 0x0D   ; 2 bytes
_SCENE_MODE_              equ _BASE_ + 0x0F   ; 1 byte
_EMPTY_                   equ _BASE_ + 0x10   ; 2 bytes
_ECONOMY_BLUE_RES_        equ _BASE_ + 0x12   ; 2 bytes
_ECONOMY_YELLOW_RES_      equ _BASE_ + 0x14   ; 2 bytes
_ECONOMY_RED_RES_         equ _BASE_ + 0x16   ; 2 bytes
_ECONOMY_SCORE_           equ _BASE_ + 0x18   ; 2 bytes
_SFX_POINTER_             equ _BASE_ + 0x1A    ; 2 bytes

_MAP_                     equ 0x0000  ; Map data 128*128*1b= 0x4000
_METADATA_                equ 0x0000  ; Map metadata 128*128*1b= 0x4000
_ENTITIES_                equ 0x0000  ; Entities 128*128*1b= 0x4000

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

TILES_COUNT                     equ 0x56    ; 86 tiles

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

TILE_FOUNDATION                 equ 0x0A
TILE_STATION                    equ 0x0B
TILE_STATION_EXTEND             equ 0x0C

TILE_FOREGROUND_SHIFT           equ 0x0D ; pointer to first foreground tiles
TILE_RES_YELLOW_1               equ 0x0D
TILE_RES_YELLOW_2               equ 0x0E
TILE_RES_BLUE_1                 equ 0x0F
TILE_RES_BLUE_2                 equ 0x10
TILE_RES_RED_1                  equ 0x11
TILE_RES_RED_2                  equ 0x12

TILE_RAILS_1                    equ 0x13
TILE_RAILS_2                    equ 0x14
TILE_RAILS_3                    equ 0x15
TILE_RAILS_4                    equ 0x16
TILE_RAILS_5                    equ 0x17
TILE_RAILS_6                    equ 0x18
TILE_RAILS_7                    equ 0x19
TILE_RAILS_8                    equ 0x1A
TILE_RAILS_9                    equ 0x1B
TILE_RAILS_10                   equ 0x1C
TILE_RAILS_11                   equ 0x1D

TILE_ROCKET_BOTTOM              equ 0x1E
TILE_ROCKET_TOP                 equ 0x1F
TILE_BUILDING_FACTORY           equ 0x20
TILE_BUILDING_EXTRACT           equ 0x21
TILE_BUILDING_SILOS             equ 0x22
TILE_BUILDING_LAB               equ 0x23
TILE_BUILDING_RADAR             equ 0x24
TILE_BUILDING_PODS              equ 0x25
TILE_BUILDING_POWER             equ 0x26

TILE_DEFENSE_1                  equ 0x27
TILE_DEFENSE_2                  equ 0x28
TILE_DEFENSE_3                  equ 0x29

TILE_ENEMY_1                    equ 0x2A
TILE_ENEMY_2                    equ 0x2B
TILE_ENEMY_3                    equ 0x2C

TILE_CART_VERTICAL              equ 0x2D
TILE_CART_HORIZONTAL            equ 0x2E
TILE_SWITCH_LEFT                equ 0x2F
TILE_SWITCH_DOWN                equ 0x30
TILE_SWITCH_RIGHT               equ 0x31
TILE_SWITCH_UP                  equ 0x32

TILE_ORE_BLUE                   equ 0x33
TILE_ORE_YELLOW                 equ 0x34
TILE_ORE_RED                    equ 0x35

TILE_EXTRACT_BLUE               equ 0x36
TILE_EXTRACT_YELLOW             equ 0x37
TILE_EXTRACT_RED                equ 0x38

TILE_SILO_BLUE                  equ 0x39
TILE_SILO_YELLOW                equ 0x3A
TILE_SILO_RED                   equ 0x3B

TILE_CURSOR_PAN                 equ 0x3C
TILE_CURSOR_BUILD               equ 0x3D
TILE_CURSOR_EDIT                equ 0x3E
TILE_TARGET                     equ 0x3F

TILE_WINDOW_1                   equ 0x40
TILE_WINDOW_2                   equ 0x41
TILE_WINDOW_3                   equ 0x42
TILE_WINDOW_4                   equ 0x43
TILE_WINDOW_5                   equ 0x44
TILE_WINDOW_6                   equ 0x45
TILE_WINDOW_7                   equ 0x46
TILE_WINDOW_8                   equ 0x47
TILE_WINDOW_9                   equ 0x48

TILE_LOGO_1                     equ 0x49
TILE_LOGO_2                     equ 0x4A
TILE_LOGO_3                     equ 0x4B
TILE_LOGO_4                     equ 0x4C
TILE_LOGO_5                     equ 0x4D

TILE_FRAME_1                    equ 0x4E
TILE_FRAME_2                    equ 0x4F
TILE_FRAME_3                    equ 0x50
TILE_FRAME_4                    equ 0x51
TILE_FRAME_5                    equ 0x52
TILE_FRAME_6                    equ 0x53
TILE_FRAME_7                    equ 0x54
TILE_FRAME_8                    equ 0x55

; SEGMENT_TERRAIN_BACKGROUND
; 0 0 0 0 0000
; | | | | |
; | | | | '- background sprite id (16)
; | | | '- terrain traversal (1) (movable or forest/mountains/building)
; | | '- rail (1)
; | '- resource (1)
; '- infrastructure building, station (1)
;
BACKGROUND_SPRITE_MASK          equ 0xF
TERRAIN_TRAVERSAL_MASK          equ 0x10
TERRAIN_TRAVERSAL_SHIFT         equ 0x4
TERRAIN_SECOND_LAYER_DRAW_CLIP  equ 0xE0
RAIL_MASK                       equ 0x20
RAIL_SHIFT                      equ 0x5
RESOURCE_MASK                   equ 0x40
RESOURCE_SHIFT                  equ 0x6
INFRASTRUCTURE_MASK             equ 0x80
INFRASTRUCTURE_SHIFT            equ 0x7

; SEGMENT_TERRAIN_FOREGROUND
; 00 0 00000
; |  | |
; |  | '- sprite id (32) (rails / buildings)
; |  '- draw cart (1)
; '- cursor type (4)
;
FORGROUND_SPRITE_MASK           equ 0x1F
FOREGROUND_SPRITE_CLIP           equ 0xE0
CART_DRAW_MASK                  equ 0x20
CART_DRAW_SHIFT                 equ 0x05
CURSOR_TYPE_MASK                equ 0xC0
CURSOR_TYPE_CLIP                equ 0x3F
CURSOR_TYPE_SHIFT               equ 0x06
CURSOR_TYPE_ROL                 equ 0x02


; SEGMENT_META_DATA
; 0 00 00 00 0
; | |  |  |  |
; | |  |  |  '- switch on rail (or not initialized)
; | |  |  '- switch position (up/down/left/right)
; | |  '- resource type (4) (for source/pods cargo/buildings)
; | '- cart direction
; '- unused (1)
;
SWITCH_MASK                     equ 0x1
SWITCH_TYPE_MASK                equ 0x6
SWITCH_TYPE_SHIFT               equ 0x1
SWITCH_DATA_CLIP                equ 0xF8
RESOURCE_TYPE_MASK              equ 0x18
RESOURCE_TYPE_SHIFT             equ 0x3
CART_DIRECTION_MASK             equ 0x60
CART_DIRECTION_SHIFT            equ 0x5

CART_UP                         equ 0x00
CART_DOWN                       equ 0x01
CART_LEFT                       equ 0x02
CART_RIGHT                      equ 0x03

TERRAIN_RULES_MASK              equ 0x03

CURSOR_ICON_PAN                 equ 0x00
CURSOR_ICON_ADD                 equ 0x01
CURSOR_ICON_EDIT                equ 0x02
CURSOR_ICON_SELECTED            equ 0x03

CURSOR_MODE_PAN                 equ 0x00
CURSOR_MODE_PLACE_RAIL          equ 0x01
CURSOR_MODE_SWITCH              equ 0x02
CURSOR_MODE_PLACE_STATION       equ 0x03
CURSOR_MODE_PLACE_FOUNDATION    equ 0x04
CURSOR_MODE_PLACE_BUILDING      equ 0x05

METADATA_SWITCH_INITIALIZED     equ 0x01
METADATA_SWITCH_MASK            equ 0x06
METADATA_SWITCH_SHIFT           equ 0x01

MODE_MAIN_MENU                  equ 0x00
MODE_SETTINGS_MENU              equ 0x01
MODE_HELP_PAGE1                 equ 0x02
MODE_HELP_PAGE2                 equ 0x03

MODE_GAMEPLAY                   equ 0x00

UI_STATS_WINDOW_POS             equ 0x1502
UI_STATS_GFX_LINE               equ 320*175
UI_STATS_TXT_LINE               equ 0x16


; =========================================== MISC SETTINGS =================|80

SCREEN_WIDTH                    equ 320
SCREEN_HEIGHT                   equ 200
MAP_SIZE                        equ 128     ; Map size in cells DO NOT CHANGE
VIEWPORT_WIDTH                  equ 20      ; Size in tiles 20 = 320 pixels
VIEWPORT_HEIGHT                 equ 11      ; by 10 = 176 pixels
VIEWPORT_GRID_SIZE              equ 16      ; Individual cell size DO NOT CHANGE
SPRITE_SIZE                     equ 16      ; Sprite size 16x16 DO NOT CHANGE

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
Notes:
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
  mov ax, 0x13                          ; Init 320x200, 256 colors mode
  int 0x10                              ; Video BIOS interrupt
  cld                                   ; Clear DF to ensure forward string ops

  push SEGMENT_VGA                      ; VGA memory segment
  pop es                                ; Set ES to VGA memory segment
  xor di, di                            ; Set DI to 0

  push cs                               ; GAME CODE SEGMENT
  pop ss
  mov sp, GAME_STACK_POINTER

  call initialize_custom_palette

  mov byte [_GAME_STATE_], STATE_INIT_ENGINE

; =========================================== GAME LOOP =====================|80

main_loop:

; =========================================== GAME STATES ===================|80

  movzx bx, byte [_GAME_STATE_]         ; Load state into BX
  shl bx, 1                             ; Multiply by 2 (word size)
  call word [StateJumpTable + bx]       ; Jump to handle

game_state_satisfied:

; =========================================== KEYBOARD INPUT ================|80

check_keyboard:
  mov ah, 01h                           ; BIOS keyboard status function
  int 16h                               ; Call BIOS interrupt
  jz .keyboard_done

  mov ah, 00h                           ; BIOS keyboard read function
  int 16h                               ; Call BIOS interrupt

  ; ========================================= STATE TRANSITIONS ============|80
  mov si, StateTransitionTable
  mov cx, StateTransitionTableEnd-StateTransitionTable
  .check_transitions:
    mov bl, [_GAME_STATE_]
    cmp bl, [si]                        ; Check current state
    jne .next_entry

    cmp ah, [si+1]                      ; Check key press
    jne .next_entry

    mov bl, [si+2]                      ; Get new state
    mov [_GAME_STATE_], bl
    jmp .transitions_done

  .next_entry:
    add si, 3                           ; Move to next entry
    loop .check_transitions

.transitions_done:

; ========================================= GAME LOGIC INPUT =============|80

  mov si, InputTable
  mov cx, InputTableEnd-InputTable
  .check_input:
    mov bl, [_GAME_STATE_]
    cmp bl, [si]                        ; Check current state
    jne .next_input

    cmp byte [si+1], MODE_GAMEPLAY
    je .check_keypress
    mov bl, [_SCENE_MODE_]
    cmp bl, [si+1]                      ; Check current mode
    jne .next_input

    .check_keypress:
    cmp ah, [si+2]                      ; Check key press
    jne .next_input

    mov bx, [si+3]
    call bx
    jmp .keyboard_done

  .next_input:
    add si, 5                           ; Move to next entry
  loop .check_input

.keyboard_done:

; =========================================== GAME TICK =====================|80

.cpu_delay:
  xor ax, ax                            ; 00h: Read system timer counter
  int 0x1a                              ; Returns tick count in CX:DX
  mov bx, dx                            ; Store low word of tick count
  mov si, cx                            ; Store high word of tick count
  .wait_loop:
    xor ax, ax
    int 0x1a
    cmp cx, si                          ; Compare high word
    jne .tick_changed
    cmp dx, bx                          ; Compare low word
    je .wait_loop                       ; If both are the same, keep waiting
  .tick_changed:

.update_system_tick:
  inc dword [_GAME_TICK_]               ; overflow naturally

call update_audio

; =========================================== ESC OR LOOP ===================|80

jmp main_loop

; =========================================== EXIT TO DOS ===================|80

exit:
  call stop_sound
  mov ax, 0x0003                        ; Set video mode to 80x25 text mode
  int 0x10                              ; Call BIOS interrupt
  mov si, QuitText                      ; Draw message after exit
  xor dx, dx                            ; At 0/0 position
  call draw_text

  mov ax, 0x4c00                        ; Exit to DOS
  int 0x21                              ; Call DOS
ret                                     ; Return to DOS

; =========================================== GAME LOGIC ====================|80

game_logic:


; =========================================== VIEWPORT MOVE =================|80

  .move_cursor_up:
    mov ax, [_VIEWPORT_Y_]              ; viewport top position
    inc ax                              ; one tile before
    cmp word [_CURSOR_Y_], ax           ; check if cursor at the top edge
    je .move_viewport_up                ; try move the viewport up
    dec word [_CURSOR_Y_]               ; or just move the cursor up
  jmp .redraw_tile

  .move_cursor_down:
    mov ax, [_VIEWPORT_Y_]              ; viewport top position
    add ax, VIEWPORT_HEIGHT-2           ; get viewport bottom
    cmp word [_CURSOR_Y_], ax           ; check if cursro at the bottom
    jae .move_viewport_down             ; try to move viewport down
    inc word [_CURSOR_Y_]               ; or just move the cursor down
  jmp .redraw_tile

  .move_cursor_left:
    mov ax, [_VIEWPORT_X_]              ; viewport left position
    inc ax                              ; one tile before
    cmp word [_CURSOR_X_], ax           ; check if cursor at the left edge
    je .move_viewport_left              ; try to move viewport left
    dec word [_CURSOR_X_]               ; or just move the cursor left
  jmp .redraw_tile

  .move_cursor_right:
    mov ax, [_VIEWPORT_X_]              ; viewport left position
    add ax, VIEWPORT_WIDTH-2            ; get viewport right
    cmp word [_CURSOR_X_], ax           ; check if cursor at the right edge
    jae .move_viewport_right            ; try to move viewport right
    inc word [_CURSOR_X_]               ; or just move the cursor right
  jmp .redraw_tile

  .move_viewport_up:
    cmp word [_VIEWPORT_Y_], 0          ; check if viewport at the top edge
    je .done                            ; do nothing if on edge
    dec word [_VIEWPORT_Y_]             ; move viewport up
    dec word [_CURSOR_Y_]               ; move cursor up
  jmp .redraw_terrain

  .move_viewport_down:
    cmp word [_VIEWPORT_Y_], MAP_SIZE-VIEWPORT_HEIGHT ; check if viewport at the bottom edge of map
    jae .done                           ; do nothing if on edge
    inc word [_VIEWPORT_Y_]             ; move viewport down
    inc word [_CURSOR_Y_]               ; move cursor down
  jmp .redraw_terrain

  .move_viewport_left:
    cmp word [_VIEWPORT_X_], 0          ; check if viewport at the left edge of map
    je .done                            ; do nothing if on edge
    dec word [_VIEWPORT_X_]             ; move viewport left
    dec word [_CURSOR_X_]               ; move cursor left
  jmp .redraw_terrain

  .move_viewport_right:
    cmp word [_VIEWPORT_X_], MAP_SIZE-VIEWPORT_WIDTH ; check if viewport at the right edge of map
    jae .done                           ; do nothing if on edge
    inc word [_VIEWPORT_X_]             ; move viewport right
    inc word [_CURSOR_X_]               ; move cursor right
  jmp .redraw_terrain

  .switch_change:
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

  .build_action:
    push es
    push ds

    mov bx, SFX_BUILD
    call play_sfx

    mov di, [_CURSOR_Y_]                ; calculate map position
    shl di, 7   ; Y * 128
    add di, [_CURSOR_X_]

    mov al, [_GAME_TICK_]

    push SEGMENT_TERRAIN_BACKGROUND
    pop es
    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    .place_rail:
      and al, 0x1                       ; TILE_MUD_1 or TILE_MUD_2
      mov byte [es:di], al
      add byte [es:di], RAIL_MASK
      add byte [ds:di], TILE_RAILS_1-TILE_FOREGROUND_SHIFT

      call recalculate_rails
      dec di
      call recalculate_rails
      add di, 2
      call recalculate_rails
      sub di, MAP_SIZE+1
      call recalculate_rails
      add di, MAP_SIZE*2
      call recalculate_rails
    .skip_place_rail:

    .toggle_switch:
    .place_station:
    .place_foundation:
    .place_building:

    pop ds
    pop es
  jmp .redraw_tile

  jmp .no_error
  .error:
    mov bx, SFX_ERROR
    call play_sfx
  .no_error:

  .redraw_tile:
    ; to be optimize later
    ; for now redrawn everything
    ; jmp .done

  .redraw_terrain:
    call draw_terrain
    call draw_cursor
    call draw_frame
    call draw_ui
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
  db STATE_TITLE_SCREEN,  KB_ESC,   STATE_QUIT
  db STATE_TITLE_SCREEN,  KB_ENTER, STATE_MENU_INIT

  db STATE_MENU,          KB_ESC,   STATE_QUIT
  db STATE_MENU,          KB_ENTER, STATE_GAME_INIT
  db STATE_MENU,          KB_F1,    STATE_GAME_NEW
  db STATE_MENU,          KB_F2,    STATE_DEBUG_VIEW_INIT
  db STATE_MENU,          KB_F3,    STATE_DEBUG_VIEW_INIT
  db STATE_MENU,          KB_F4,    STATE_HELP_INIT

  db STATE_HELP,          KB_ESC,   STATE_MENU_INIT

  db STATE_GAME,          KB_ESC,   STATE_MENU_INIT
  db STATE_GAME,          KB_TAB,   STATE_MAP_VIEW_INIT
  db STATE_MAP_VIEW,      KB_ESC,   STATE_MENU_INIT
  db STATE_MAP_VIEW,      KB_TAB,   STATE_GAME_INIT
  db STATE_DEBUG_VIEW,    KB_ESC,   STATE_MENU_INIT
StateTransitionTableEnd:

InputTable:
  db STATE_GAME,          MODE_GAMEPLAY,  KB_UP
  dw game_logic.move_cursor_up
  db STATE_GAME,          MODE_GAMEPLAY,  KB_DOWN
  dw game_logic.move_cursor_down
  db STATE_GAME,          MODE_GAMEPLAY,  KB_LEFT
  dw game_logic.move_cursor_left
  db STATE_GAME,          MODE_GAMEPLAY,  KB_RIGHT
  dw game_logic.move_cursor_right
  db STATE_GAME,          MODE_GAMEPLAY,  KB_SPACE
  dw game_logic.build_action
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
  mov word [_GAME_TICK_], 0x0
  mov word [_RNG_], 0x42

  mov word [_VIEWPORT_X_], MAP_SIZE/2-VIEWPORT_WIDTH/2
  mov word [_VIEWPORT_Y_], MAP_SIZE/2-VIEWPORT_HEIGHT/2
  mov word [_CURSOR_X_], MAP_SIZE/2
  mov word [_CURSOR_Y_], MAP_SIZE/2

  mov word [_ECONOMY_BLUE_RES_], 0
  mov word [_ECONOMY_YELLOW_RES_], 0
  mov word [_ECONOMY_RED_RES_], 0
  mov word [_ECONOMY_SCORE_], 0
ret

init_title_screen:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, p1x_logo_image
  call draw_rle_image

  mov bx, INTRO_JINGLE
  call play_sfx

  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN
ret

live_title_screen:
  mov si, PressEnterText
  mov dx, 0x180F
  mov bl, COLOR_WHITE
  test word [_GAME_TICK_], 0x4
  je .blink
    mov bl, COLOR_BLACK
  .blink:
  call draw_text
ret

init_menu:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, title_image
  call draw_rle_image

  mov ax, 0x040C
  mov bx, 0x0207
  call draw_window

  mov di, 112+39*320
  mov ax, TILE_LOGO_1
  mov cx, 5
  .logo_loop:
    call draw_sprite
    inc ax
    add di, 0x10
  loop .logo_loop

  mov ax, 0x090C
  mov bx, 0x0607
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
  call build_initial_base
  call reset_to_default_values

  mov byte [_GAME_STATE_], STATE_MENU_INIT
  mov byte [_SCENE_MODE_], MODE_GAMEPLAY
ret

init_game:
  call draw_terrain
  ;call draw_entities
  call draw_cursor
  call draw_frame
  call draw_ui
  mov byte [_GAME_STATE_], STATE_GAME
  mov byte [_SCENE_MODE_], MODE_GAMEPLAY
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

  .draw_loaded_sprites:
  mov di, 320*16+16                     ; Position on screen
  xor ax, ax                            ; Sprite ID 0
  mov cx, TILES_COUNT
  .spr:
    call draw_sprite
    inc ax                              ; Next prite ID

    .test_new_line:
    mov bx, ax
    and bx, 0xF
    cmp bx, 0
    jne .skip_new_line
      add di, SCREEN_WIDTH*SPRITE_SIZE-SPRITE_SIZE*18 + 320*2 ; New line + 2px
    .skip_new_line:

    add di, 18                          ; Move to next slot + 2px
  loop .spr

  .draw_color_palette:
  mov di, SCREEN_WIDTH*160+32           ; Position on screen
  mov cx, 16                            ; 16 lines
  .colors_loop:
    push cx
    xor ax, ax

    mov cx, 16                          ; 16 colors
    .line_loop:
      push cx
      mov cx, 8
      rep stosw
      inc al
      inc ah
      pop cx
    loop .line_loop

    add di, SCREEN_WIDTH-(SPRITE_SIZE*SPRITE_SIZE)  ; wrap to next line
    pop cx
  loop .colors_loop

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
  mov si, CustomPalette                 ; Palette data pointer
  mov dx, 03C8h                         ; DAC Write Port (start at index 0)
  xor al, al                            ; Start with color index 0
  out dx, al                            ; Send color index to DAC Write Port
  mov dx, 03C9h                         ; DAC Data Port
  mov cx, 16*3                          ; 16 colors × 3 bytes (R, G, B)
  rep outsb                             ; Send all RGB values
ret

CustomPalette:
; DawnBringer 16 color palette
; https://github.com/geoffb/dawnbringer-palettes
; Converted from 8-bit to 6-bit for VGA
db  0,  0,  0                           ; #000000 - Black
db 17,  8, 13                           ; #442434 - Deep purple
db 12, 13, 27                           ; #30346D - Navy blue
db 19, 18, 19                           ; #4E4A4E - Dark gray
db 33, 19, 12                           ; #854C30 - Brown
db 13, 25,  9                           ; #346524 - Dark green
db 52, 17, 18                           ; #D04648 - Red
db 29, 28, 24                           ; #757161 - Light gray
db 22, 31, 51                           ; #597DCE - Blue
db 52, 31, 11                           ; #D27D2C - Orange
db 33, 37, 40                           ; #8595A1 - Steel blue
db 27, 42, 11                           ; #6DAA2C - Green
db 52, 42, 38                           ; #D2AA99 - Pink/Beige
db 27, 48, 50                           ; #6DC2CA - Cyan
db 54, 53, 23                           ; #DAD45E - Yellow
db 55, 59, 53                           ; #DEEED6 - White

; =========================================== DRAW TEXT =====================|80
; IN:
;  SI - Pointer to text
;  DL - X position
;  DH - Y position
;  BX - Color
draw_text:
  mov ah, 0x02                          ; Set cursor
  xor bh, bh                            ; Page 0
  int 0x10

  .next_char:
    lodsb                               ; Load next character from SI into AL
    test al, al                         ; Check for string terminator
    jz .done                            ; If terminator, we're done

    mov ah, 0x0E                        ; Teletype output
    mov bh, 0                           ; Page 0
    int 0x10                            ; BIOS video interrupt

    jmp .next_char                      ; Process next character

  .done:
ret

; =========================================== DRAW NUMBER ===================|80
; IN:
;   SI - Value to display (decimal)
;   DL - X position
;   DH - Y position
;   BX - Color
;   CX - digits length
draw_number:
  mov ah, 0x02                          ; Set cursor
  xor bh, bh                            ; Page 0
  int 0x10

  ;mov cx, 10000                         ; Divisor for 5 digits
  mov ax, si                            ; Copy the number to AX for division

  .next_digit:
    xor dx, dx                          ; Clear DX for division
    div cx                              ; Divide, remainder in DX
    add al, '0'                         ; Convert to ASCII

    mov ah, 0x0E                        ; Teletype output
    push dx                             ; Save remainder
    push cx                             ; Save divisor
    mov bh, 0                           ; Page 0
    int 0x10                            ; BIOS video interrupt
    pop cx                              ; Restore divisor
    pop dx                              ; Restore remainder


    mov ax, dx                          ; Save remainder to AX

    push ax                             ; Save current remainder
    mov ax, cx                          ; Get current divisor in AX
    xor dx, dx                          ; Clear DX for division
    push bx
    mov bx, 10                          ; Divide by 10
    div bx                              ; AX = AX/10
    pop bx
    mov cx, ax                          ; Set new divisor
    pop ax                              ; Restore current remainder

    cmp cx, 0                           ; If divisor is 0, we're done
    jne .next_digit

ret

; =========================================== GET RANDOM ====================|80
; OUT: AX - Random number
get_random:
  push es
  push si
  push di

  push cs                               ; GAME CODE SEGMENT
  pop es

  mov si, _RNG_
  mov di, _GAME_TICK_

  mov ax, [es:si]
  inc ax
  rol ax, 1
  xor ax, 0x1337
  add ax, [es:di]
  mov si, _RNG_
  mov [es:si], ax

  pop di
  pop si
  pop es
ret

; =========================================== CLEAR SCREEN ==================|80
; IN:
;   AL - Color
clear_screen:
  mov ah, al
  mov cx, SCREEN_WIDTH*SCREEN_HEIGHT/2  ; Number of pixels
  xor di, di                            ; Start at 0
  rep stosw                             ; Write to the VGA memory
ret

; =========================================== DRAW GRADIENT =================|80
; IN:
;   DI - Position
;   AL - Color
draw_gradient:
  mov ah, al
  mov dl, 0xD                           ; Number of bars to draw
  .draw_gradient:
    mov cx, SCREEN_WIDTH*4              ; Number of pixels high for each bar
    rep stosw                           ; Write to the VGA memory
    cmp dl, 0x8                         ; Check if we are in the middle
    jl .down                            ; If not, decrease
    inc al                              ; Increase color in right pixel
    jmp .up
    .down:
    dec al                              ; Decrease color in left pixel
    .up:
    xchg al, ah                         ; Swap colors (left/right pixel)
    dec dl                              ; Decrease number of bars to draw
    jg .draw_gradient                   ; Loop until all bars are drawn
ret

; =========================================== DRAW RLE IMAGE ================|80
; IN:
;   SI - Image data address
draw_rle_image:
  push es
  push ds

  push cs                               ; Code segment
  pop ds

  push SEGMENT_VGA
  pop es

  xor di, di
  xor bx, bx
  xor dx, dx
  .image_loop:
    lodsb                               ; Load number of pixels to repeat
    mov cx, ax                          ; Save to CX
    add bx, ax                          ; Add to overall pixels counter
    add dx, ax                          ; Add to line pixel counter

    lodsb                               ; Load pixel color
    rep stosb                           ; Push pixels (CX times)

    cmp dx, SCREEN_WIDTH                ; Check if we fill full line
    jl .continue                        ; Continue if not
    add di, SCREEN_WIDTH                ; Jump interlaced line
    xor dx, dx                          ; Zero line counter
    .continue:

    cmp bx, SCREEN_WIDTH*(SCREEN_HEIGHT/2)  ; Check if full image drown
    jl .image_loop                      ; Continu if not

    pop ds
    pop es
ret

; =========================================== DRAW WINDOW ===================|80
; Window is drown over 8x8 grid in sprites size (16px each). Uses 9 tiles for
; drawing the window.
; IN:
;   AX - Position of top/left corner; high:Y, low:X
;   BX - Size of window; high: height, low: width
draw_window:

  .calculate_window_position:
  push bx                               ; Save the size
  xor di, di
  xor bx, bx
  mov bl, ah                            ; Y coord from high bits
  shl bx, 0x3                           ; Y * 8 (grid size)
  imul bx, SCREEN_WIDTH                 ; Multiply by vertical lines
  and ax, 0x00FF                        ; X, remove high bits, keep low bits
  shl ax, 0x3                           ; X * 8 (grid size)
  add bx, ax                            ; Add X to coords
  add di, bx                            ; Move to destination index

  .draw_widow:
  pop bx                                ; Restore size

  .top_left_corner:
  mov ax, TILE_WINDOW_1                 ; Set first sprite (top/left corner)
  call draw_sprite
  add di, SPRITE_SIZE                   ; Move index by sprite size

  .top_border:
  inc ax                                ; Set next sprite (top border)
  movzx cx, bl                          ; Set width
  sub cx, 2                             ; Minus corners
  .draw_top_sprite:             ; Draw the sprites
    call draw_sprite
    add di, SPRITE_SIZE                 ; Move index by sprite size
  loop .draw_top_sprite

  .top_right_corner:
  inc ax                                ; Set next sprite (top/right corner)
  call draw_sprite
  add di, SPRITE_SIZE                   ; Move index by sprite size

  .top_middle:
  movzx dx, bl                          ; Save the window width
  shl dx, 0x4                           ; Multiply by sprite size (16)

  movzx cx, bh                          ; Get the height
  cmp cx, 0x2                           ; Check if less than 2
  jle .skip_middle                      ; Skip middle drawing if true
  sub cx, 0x2                           ; Reduce height by top and bottom part

  .draw_middle_row:
    push cx                             ; Save height (rows)

    add di, SCREEN_WIDTH*SPRITE_SIZE    ; Move to the next line below
    sub di, dx                          ; Back to left side of window

    .left_border:
    mov ax, TILE_WINDOW_4               ; Set sprite (left border)
    call draw_sprite
    add di, SPRITE_SIZE                 ; Move index by sprite size

    .middle:
    inc ax                              ; Set next sprite (inside of window)
    movzx cx, bl                        ; Set width
    sub cx, 2                           ; Minus left/right sprites
    .draw_middle_sprite:
      call draw_sprite
      add di, SPRITE_SIZE               ;  Move index by sprite size
    loop .draw_middle_sprite

    .middle_right:
    inc ax                              ; Set next sprite (right border)
    call draw_sprite
    add di, SPRITE_SIZE                 ; Move index by sprite size

    pop cx                              ; Restor ros counter
  loop .draw_middle_row

  .skip_middle:

  .draw_bottom:
  add di, SCREEN_WIDTH*SPRITE_SIZE      ; Move to the next line below
  sub di, dx                            ; Back to left side of window

  .bottom_left_corner:
  mov ax, TILE_WINDOW_7                 ; Set sprite (bottom left corner)
  call draw_sprite
  add di, SPRITE_SIZE                   ; Move index by sprite size

  .bottom_middle:
  inc ax                                ; Set next sprite (bottom border)
  movzx cx, bl                          ; Set width
  sub cx, 2                             ; Minus left/right sprites
  .draw_bottom_sprite:
    call draw_sprite
    add di, SPRITE_SIZE                 ; Move index by sprite size
  loop .draw_bottom_sprite

  .bottom_right:
  inc ax                                ; Set next sprite (bottom right corner)
  call draw_sprite
ret


; =========================================== GENERATE MAP ==================|80
; Generates the procedural map using simple rules (TerrainRules)
; Rules defines what type of tiles can be generated next to each other
; Fore each tile type 4 corresponding types are defined.
; For 10 tiles, 10 entries are defined (each holding 4 bytes)
; Algorithm selects for each cell up or left tile next to it and checks in the
; defined array what can be placed. Selects randomly new tile. Moves to next.
; First tile in a colum is selected randomely as there is nothing on the left.
; Same for the first top row of tiles.
; Lastly it goes thru newely generated map and sets metadata (traversal cells)
; and clears other data layers for safety (if generated on populated memory)
generate_map:
  push es
  push ds

  push SEGMENT_TERRAIN_BACKGROUND
  pop es

  push cs                               ; GAME CODE SEGMENT
  pop ds

  xor di, di
  mov si, TerrainRules
  mov cx, MAP_SIZE                      ; Height
  .next_row:
    mov dx, MAP_SIZE                    ; Width
    .next_col:
      call get_random                   ; AX is random value
      and ax, TERRAIN_RULES_MASK        ; Crop to 0-3
      mov [es:di], al                   ; Save terrain tile
      cmp dx, MAP_SIZE                  ; Check if first col
      je .skip_cell
      cmp cx, MAP_SIZE                  ; Check if first row
      je .skip_cell
      movzx bx, [es:di-1]               ; Get left tile
      test al, 0x1                      ; If odd value skip checking top
      jz .skip_top
      movzx bx, [es:di-MAP_SIZE]        ; Get top tile
      .skip_top:
      shl bx, 2                         ; Mul by 4 to fit rules table
      add bx, ax                        ; Get random rule for the tile ID
      mov al, [ds:si+bx]                ; Get the tile ID from rules table
      mov [es:di], al                   ; Save terrain tile
      .skip_cell:
      inc di                            ; Next map tile cell
      dec dx                            ; Next column (couner is top-down)
    jnz .next_col
  loop .next_row

  .set_background_metadata:
    xor si, si
    xor di, di
    mov cx, MAP_SIZE*MAP_SIZE
    .background_cell:
      cmp byte [es:si], TILE_TREES_1    ; Last traversal sprite id
      jge .skip_traversal               ; If greater, skip
      add byte [es:di], TERRAIN_TRAVERSAL_MASK
      .skip_traversal:
      inc si
      inc di
    loop .background_cell

  .clear_rest_metadata:
    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    push SEGMENT_ENTITIES
    pop es

    xor di, di
    mov cx, MAP_SIZE*MAP_SIZE
    .map_cell:
      mov byte [ds:di], 0x0             ; Clear foreground data
      mov byte [es:di], 0x0             ; Clear entities data
      inc di
    loop .map_cell

  pop ds
  pop es
ret

; =========================================== BUILD INITIAL BASE FOUNDATIONS |80
; Sets up initial base foundations, rocket
build_initial_base:
  push es
  push ds

  push SEGMENT_TERRAIN_BACKGROUND
  pop es

  push SEGMENT_TERRAIN_FOREGROUND
  pop ds

  .set_center_position:
  mov di, MAP_SIZE*MAP_SIZE/2 + MAP_SIZE/2  ; Center of the map

  .build_base:
  mov ax, TILE_FOUNDATION
  mov byte [es:di+1], al
  mov byte [es:di-1], al
  mov byte [es:di+MAP_SIZE], al
  mov byte [es:di-MAP_SIZE], al
  add ax, INFRASTRUCTURE_MASK
  mov byte [es:di], al
  mov byte [es:di-MAP_SIZE], al

  mov ax, CURSOR_ICON_ADD
  ror al, CURSOR_TYPE_ROL
  mov byte [ds:di+1], al
  mov byte [ds:di-1], al
  mov byte [ds:di+MAP_SIZE], al
  mov byte [ds:di-MAP_SIZE], al

  mov ax, CURSOR_ICON_EDIT
  ror al, CURSOR_TYPE_ROL
  push ax
  add ax, TILE_ROCKET_BOTTOM-TILE_FOREGROUND_SHIFT
  mov byte [ds:di], al
  pop ax
  add ax, TILE_ROCKET_TOP-TILE_FOREGROUND_SHIFT
  mov byte [ds:di-MAP_SIZE], al

  pop ds
  pop es
ret

; =========================================== DRAW TERRAIN ==================|80
; OUT: Terrain drawn on the screen
draw_terrain:
  push es
  push ds

  mov si, [_VIEWPORT_Y_]                ; Y coordinate
  shl si, 7                             ; Y * 128
  add si, [_VIEWPORT_X_]                ; Y * 128 + X

  push SEGMENT_TERRAIN_BACKGROUND
  pop es

  push SEGMENT_TERRAIN_FOREGROUND
  pop ds

  xor di, di

  mov cx, VIEWPORT_HEIGHT
  .draw_line:
    push cx

    mov cx, VIEWPORT_WIDTH
    .draw_cell:
      mov al, [es:si]                   ; SEGMENT_TERRAIN_BACKGROUND
      mov bl, al
      and al, BACKGROUND_SPRITE_MASK
      call draw_tile

      and bl, TERRAIN_SECOND_LAYER_DRAW_CLIP
      cmp bl, 0x0
      jz .skip_foreground
      .draw_forground:

        mov al, [ds:si]                 ; SEGMENT_TERRAIN_FOREGROUND
        and al, FORGROUND_SPRITE_MASK
        add al, TILE_FOREGROUND_SHIFT
        call draw_sprite

        mov dl, [es:si]                 ; SEGMENT_TERRAIN_BACKGROUND
        .draw_rails_stuff:
          test dl, RAIL_MASK
          jz .skip_rails_stuff

          push es
          push SEGMENT_META_DATA
          pop es

          .draw_switch:
            mov al, [es:si]             ; SEGMENT_META_DATA
            test al, SWITCH_MASK
            jz .skip_switch
              and al, SWITCH_TYPE_MASK
              shr al, SWITCH_TYPE_SHIFT
              add al, TILE_SWITCH_LEFT
              call draw_sprite
            .skip_switch:

          .draw_cart:
            test byte [ds:si], CART_DRAW_MASK  ; SEGMENT_TERRAIN_FOREGROUND
            jz .skip_cart
              mov bl, [es:si]           ; SEGMENT_META_DATA
              and bl, CART_DIRECTION_MASK
              shr bl, CART_DIRECTION_SHIFT
              mov al, TILE_CART_HORIZONTAL
              cmp bl, CART_DOWN
              jg .skip_vertical
              mov al, TILE_CART_VERTICAL
              .skip_vertical:

              call draw_sprite

              .draw_cart_resource:
                mov bl, [es:si]               ; SEGMENT_META_DATA
                and bl, RESOURCE_TYPE_MASK
                cmp bl, 0x0
                jz .skip_resource
                  shr bl, RESOURCE_TYPE_SHIFT
                  mov al, TILE_ORE_BLUE-1
                  add al, bl
                  call draw_sprite
                .skip_resource:
            .skip_cart:

            pop es
        .skip_rails_stuff:

      .skip_foreground:

      add di, SPRITE_SIZE
      inc si
    loop .draw_cell

    add di, SCREEN_WIDTH*(SPRITE_SIZE-1)
    add si, MAP_SIZE-VIEWPORT_WIDTH
    pop cx
    dec cx
  jnz .draw_line

  pop ds
  pop es
ret

; =================================== RECALCULATE RAILS =====================|80
; di: pos
; es background
; ds foreground
recalculate_rails:
  xor ax, ax
  test byte [es:di], RAIL_MASK
  jz .done

  .test_up:
    test byte [es:di-MAP_SIZE], RAIL_MASK
    jz .test_right
    add al, 0x8
  .test_right:
    test byte [es:di+1], RAIL_MASK
    jz .test_down
    add al, 0x4
  .test_down:
  test byte [es:di+MAP_SIZE], RAIL_MASK
  jz .test_left
    add al, 0x2
  .test_left:
  test byte [es:di-1], RAIL_MASK
  jz .done_calculating
    add al, 0x1
  .done_calculating:
  mov dl, al                            ; Save connection pattern for switch

  .get_correct_rail_sprite:
    push ds
    push cs                             ; GAME CODE SEGMENT
    pop ds
    mov bx, RailroadsList
    xlatb                               ;  DS:[BX + AL]
    pop ds
    add al, TILE_RAILS_1                ; Shift to first railroad tiles
    sub al, TILE_FOREGROUND_SHIFT

  .save_rail_sprite:
    and byte [ds:di], FOREGROUND_SPRITE_CLIP
    add byte [ds:di], al

  .calculate_correct_switch:
    cmp dl, 0x7
    je .prepare_switch_horizontal
    cmp dl, 0xB
    je .prepare_switch_vertical
    cmp dl, 0x0D
    je .prepare_switch_horizontal
    cmp dl, 0x0E
    je .prepare_switch_vertical
    jmp .prepare_no_switch

  .prepare_switch_horizontal:
    mov dl, SWITCH_MASK                 ; 0 for left switch ID + initialization
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_switch_vertical:
    mov dl, 1                           ; down switch ID
    shl dl, SWITCH_TYPE_SHIFT
    add dl, SWITCH_MASK
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_no_switch:
    mov dl, 0
    mov ax, CURSOR_ICON_ADD

  .save_switch:
    push es
    push SEGMENT_META_DATA
    pop es
    and byte [es:di], SWITCH_DATA_CLIP
    add byte [es:di], dl
    pop es

    and byte [ds:di], CURSOR_TYPE_CLIP  ; clear cursor
    ror al, CURSOR_TYPE_ROL
    add byte [ds:di], al
  .done:
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
      push es
      push SEGMENT_SPRITES
      pop es
      mov byte [es:di], bl  ; Write pixel color
      inc di
      pop es      ; Move destination to next pixel
    loop .draw_pixel

  pop cx                   ; Restore line counter
  loop .plot_line
ret

; =========================================== DECOMPRESS TILES ============|80
; OUT: Tiles decompressed to _TILES_
decompress_tiles:
  push es
  push cs                               ; GAME CODE SEGMENT
  pop es
  mov si, Tiles
  .decompress_next:
    cmp byte [es:si], 0xFF
    jz .done
    call decompress_sprite
  jmp .decompress_next
  .done:
  pop es
ret

; =========================================== DRAW TILE =====================|80
; IN: SI - Tile data
; AL - Tile ID
; DI - Position
; OUT: Tile drawn on the screen
draw_tile:
  pusha

  push ds
  push es

  push SEGMENT_SPRITES
  pop ds

  push SEGMENT_VGA
  pop es

  mov ah, al        ; Multiply by 256 (tile size in array) by swapping nibles
  xor al, al        ; clear low nibble
  mov si, ax        ; Point to tile data
  mov bx, SPRITE_SIZE
  .draw_tile_line:
    mov cx, SPRITE_SIZE/4
    rep movsd       ; Move 4px at a time
    add di, SCREEN_WIDTH-SPRITE_SIZE ; Next line
    dec bx
  jnz .draw_tile_line

  pop es
  pop ds
  popa
ret

; =========================================== DRAW SPRITE ===================|80
; IN:
; AL - Sprite ID
; DI - Position
; OUT: Sprite drawn on the screen
draw_sprite:
  pusha
  push ds
  push es

  push SEGMENT_SPRITES
  pop ds

  push SEGMENT_VGA
  pop es

  mov ah, al        ; Multiply by 256 (tile size in array) by swapping nibles
  xor al, al        ; clear low nibble
  mov si, ax        ; Point to tile data
  mov bx, SPRITE_SIZE
  .draw_tile_line:
    mov cx, SPRITE_SIZE/2
    .draw_next_pixel:
      lodsw
      test al, al
      jz .skip_transparent_pixel
        mov byte [es:di], al
      .skip_transparent_pixel:
      inc di
      test ah, ah
      jz .skip_transparent_pixel2
        mov byte [es:di], ah
      .skip_transparent_pixel2:
      inc di
    loop .draw_next_pixel
    add di, SCREEN_WIDTH-SPRITE_SIZE ; Next line
    dec bx
  jnz .draw_tile_line

  pop es
  pop ds
  popa
ret

; =========================================== INIT ENTITIES =================|80
init_entities:
  ; TODO: revrite
  push es
  push SEGMENT_ENTITIES
  pop es

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
  pop es
ret

draw_cursor:
  mov si, [_CURSOR_Y_]    ; Absolute Y map coordinate
  shl si, 7               ; Y * 128 (optimized shl for *128)
  add si, [_CURSOR_X_]    ; + absolute X map coordinate

  mov bx, [_CURSOR_Y_]    ; Y coordinate
  sub bx, [_VIEWPORT_Y_]  ; Y - Viewport Y
  shl bx, 4               ; Y * 16
  mov ax, [_CURSOR_X_]    ; X coordinate
  sub ax, [_VIEWPORT_X_]  ; X - Viewport X
  shl ax, 4               ; X * 16
  imul bx, SCREEN_WIDTH   ; Y * 16 * 320
  add bx, ax              ; Y * 16 * 320 + X * 16
  mov di, bx              ; Move result to DI

  push ds
  push SEGMENT_TERRAIN_FOREGROUND
  pop ds

  mov al, [ds:si]
  and al, CURSOR_TYPE_MASK
  rol al, CURSOR_TYPE_ROL
  add al, TILE_CURSOR_PAN

  pop ds

  call draw_sprite
ret

draw_minimap:
  push es
  push ds

  push SEGMENT_TERRAIN_BACKGROUND
  pop ds

  push SEGMENT_VGA
  pop es

  mov ax, 0x040B
  mov bx, 0x0909
  call draw_window

  .draw_mini_map:
  xor si, si
  mov di, SCREEN_WIDTH*40+94          ; Map position on screen
  mov bx, TerrainColors      ; Terrain colors array
  mov cx, MAP_SIZE           ; Columns
  .draw_loop:
    push cx
    mov cx, MAP_SIZE        ; Rows
    .draw_row:
      mov al, [ds:si]                ; Load map cell
      inc si
      and al, BACKGROUND_SPRITE_MASK ; Clear metadata
      ; TODO: colors
      mov ah, al           ; Copy color for second pixel
      mov [es:di], al      ; Draw 1 pixels
      add di, 1            ; Move to next column
    loop .draw_row
    pop cx
    add di, 320-MAP_SIZE    ; Move to next row
  loop .draw_loop

  xor ax, ax


  push SEGMENT_ENTITIES
  pop ds

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

  pop ds
  pop es
ret

; =========================================== DRAW UI =======================|80

draw_frame:
  xor di, di                            ; start at top-left corner

  mov al, TILE_FRAME_1                  ; left-top corner
  call draw_sprite

  add di, SPRITE_SIZE
  mov al, TILE_FRAME_2                  ; top frame
  mov cx, 18
  .top_loop:
    call draw_sprite
    add di, SPRITE_SIZE
  loop .top_loop

  mov al, TILE_FRAME_3                  ; right-top corner
  call draw_sprite

  add di, 320*SPRITE_SIZE+SPRITE_SIZE-320
  mov cx, 9
  .vertical_loop:
    mov al, TILE_FRAME_4                  ; left frame
    call draw_sprite
    add di, 19*SPRITE_SIZE
    mov al, TILE_FRAME_5                  ; right frame
    call draw_sprite
    add di, 320*SPRITE_SIZE+SPRITE_SIZE-320
  loop .vertical_loop

  mov al, TILE_FRAME_6                  ; left-bottom corner
  call draw_sprite

  add di, SPRITE_SIZE
  mov al, TILE_FRAME_7                  ; bottom frame
  mov cx, 18
  .bottom_loop:
    call draw_sprite
    add di, SPRITE_SIZE
  loop .bottom_loop

  mov al, TILE_FRAME_8                  ; right-bottom corner
  call draw_sprite

  add di, 320*SPRITE_SIZE+SPRITE_SIZE-320

  mov dx, 12
  .stripes_loop:
    mov cx, 320/2
    mov al, COLOR_DEEP_PURPLE
    mov ah, al
    rep stosw
    mov cx, 320/2
    mov al, COLOR_NAVY_BLUE
    mov ah, al
    rep stosw
  dec dx
  jnz .stripes_loop
ret

draw_ui:

  mov si, [_CURSOR_X_]  ; Blue resource count
  mov dh, UI_STATS_TXT_LINE
  mov dl, 0x04
  mov bl, COLOR_WHITE
  mov cx, 100
  call draw_number

  mov si, [_CURSOR_Y_]  ; Blue resource count
  mov dh, UI_STATS_TXT_LINE+1
  mov dl, 0x04
  mov bl, COLOR_WHITE
  mov cx, 100
  call draw_number

  mov di, UI_STATS_GFX_LINE+90   ; Resource blue icon
  mov al, TILE_ORE_BLUE
  call draw_sprite

  mov si, [_ECONOMY_BLUE_RES_]  ; Blue resource count
  mov dh, UI_STATS_TXT_LINE
  mov dl, 0x0D
  mov bl, COLOR_WHITE
  mov cx, 10000
  call draw_number

   mov di, UI_STATS_GFX_LINE+154
   mov al, TILE_ORE_YELLOW
   call draw_sprite

   mov si, [_ECONOMY_YELLOW_RES_]  ; Yellow resource count
   mov dh, UI_STATS_TXT_LINE
   mov dl, 0x15
   mov bl, COLOR_WHITE
   mov cx, 10000
   call draw_number

   mov di, UI_STATS_GFX_LINE+218
   mov al, TILE_ORE_RED
   call draw_sprite

   mov si, [_ECONOMY_RED_RES_]  ; Red resource count
   mov dh, UI_STATS_TXT_LINE
   mov dl, 0x1D
   mov bl, COLOR_WHITE
   mov cx, 10000
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

WelcomeText db 'P1X ASSEMBLY ENGINE V12.05', 0x0
PressEnterText db 'PRESS ENTER', 0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in/assembly for more games...', 0x0D, 0x0A, 0x0
FakeNumberText db '0000', 0x0

MainMenuText:
  db 'ENTER: Play',0x0
  db 'F1: New map',0x0
  db 'F2: Tileset',0x0
  db 'F4: Help',0x0
  db 'ESC: Quit',0x0
  db 0x00

HelpText:
  db '------== HOW TO PLAY THE GAME ==-----',0x0
  db 'Here will be the final help menu with',0x0
  db 'actual help text. Describing gameplay',0x0
  db 'and controls.',0x0
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

; =========================================== INCLUDES ======================|80

include 'sfx.asm'
include 'tiles.asm'
include 'img_p1x.asm'
include 'img_title.asm'


; =========================================== THE END =======================|80
; Thanks for reading the source code!
; Visit http://smol.p1x.in/assembly/ for more.

Logo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary

; Label marking the end of all code and data
_END_OF_CODE_:
