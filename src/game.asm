; ===========================================================================|80
; CORTEX LABS - 2D Strategic game for x86 processors (and MS-DOS)
;
; Real-time strategy, economic game about extracting and managing resources.
; Havely based on building optimized train (pods) lines.
;
; http://smol.p1x.in/assembly/#game12
; ===========================================================================|80
; Copyright (C) 2025 Krzysztof Krystian Jankowski
; This is free and open software. See LICENSE for details.
; ===========================================================================|80
;
; Should run on any x86 processor and system that supports legacy BIOS boot.
; Tested hardware:
; Compaq Contura 430C (FreeDOS & Boot Floppy)
; * CPU: 486 DX4, 100Mhz
; * Graphics: VGA
; * RAM: 24MB
;
; Theoretical minimum requirements:
; * CPU: 386 SX, 16Mhz
; * Graphics: VGA
; * RAM: 512KB
;
; Programs used for production:
;   - Zed IDE
;   - Pro Motion NG
;   - bochs
;   - custom tool for tileset conversion
;   - custom tool for RLE image compression
;
; ===========================================================================|80
; Latest revision: 10/2025
; ===========================================================================|80

org 0x0100

; =========================================== MEMORY LAYOUT =================|80

GAME_STACK_POINTER          equ 0xFFFE    ; Stack pointer for game code
SEGMENT_SPRITES             equ 0x5400    ; 96 tiles (6KB)
SEGMENT_TERRAIN_BACKGROUND  equ 0x6400    ; First map layer (16KB)
SEGMENT_TERRAIN_FOREGROUND  equ 0x6800    ; Second map layer (16KB)
SEGMENT_META_DATA           equ 0x6C00    ; Third map layer (16KB)
SEGMENT_RESERVED            equ 0x7000    ; Fourth map layer (16KB)
SEGMENT_ENTITIES            equ 0x7400    ; Entities data
SEGMENT_VGA                 equ 0xA000    ; VGA memory (fixed by hardware)

OFFSET_ENTITIES_PODS        equ 0x0000
OFFSET_ENTITIES_RESOURCES   equ 0x0400

; =========================================== MEMORY ALLOCATION =============|80

_BASE_                    equ _END_OF_CODE_ + 0x100
_GAME_TICK_               equ _BASE_ + 0x00   ; 4 bytes
_GAME_STATE_              equ _BASE_ + 0x04   ; 1 byte
_RNG_                     equ _BASE_ + 0x05   ; 2 bytes
_VIEWPORT_X_              equ _BASE_ + 0x07   ; 2 bytes
_VIEWPORT_Y_              equ _BASE_ + 0x09   ; 2 bytes
_CURSOR_X_                equ _BASE_ + 0x0B   ; 2 bytes
_CURSOR_Y_                equ _BASE_ + 0x0D   ; 2 bytes
_CURSOR_X_OLD_            equ _BASE_ + 0x0F   ; 2 bytes
_CURSOR_Y_OLD_            equ _BASE_ + 0x11   ; 2 bytes
_SCENE_MODE_              equ _BASE_ + 0x13   ; 1 byte
_GAME_TURN_               equ _BASE_ + 0x14   ; 1 bytes
_XXX_                     equ _BASE_ + 0x15   ; 1 bytes
_ECONOMY_BLUE_RES_        equ _BASE_ + 0x16   ; 2 bytes
_ECONOMY_YELLOW_RES_      equ _BASE_ + 0x18   ; 2 bytes
_ECONOMY_RED_RES_         equ _BASE_ + 0x1A   ; 2 bytes
_UPGRADES_                equ _BASE_ + 0x1C   ; 2 bytes
_MENU_SELECTION_POS_      equ _BASE_ + 0x1E   ; 1 byte
_MENU_SELECTION_MAX_      equ _BASE_ + 0x1F   ; 1 byte
_SFX_POINTER_             equ _BASE_ + 0x20   ; 2 bytes
_SFX_NOTE_INDEX_          equ _BASE_ + 0x22   ; 1 byte
_SFX_NOTE_DURATION_       equ _BASE_ + 0x23   ; 1 byte
_SFX_IRQ_OFFSET_          equ _BASE_ + 0x24   ; 2 bytes
_SFX_IRQ_SEGMENT_         equ _BASE_ + 0x26   ; 2 bytes
_AUDIO_ENABLED_           equ _BASE_ + 0x28   ; 1 byte
_LAST_ENT_POD_ID_         equ _BASE_ + 0x29   ; 2 bytes


; =========================================== ENGINE SETTINGS ===============|80
;

TRUE                            equ 1
FALSE                           equ 0
SCREEN_WIDTH                    equ 320
SCREEN_HEIGHT                   equ 200
MAP_SIZE                        equ 128     ; Map size in cells DO NOT CHANGE
VIEWPORT_WIDTH                  equ 20      ; Size in tiles 20 = 320 pixels
VIEWPORT_HEIGHT                 equ 11      ; by 10 = 176 pixels
VIEWPORT_GRID_SIZE              equ 16      ; Individual cell size DO NOT CHANGE
SPRITE_SIZE                     equ 16      ; Sprite size 16x16 DO NOT CHANGE
FONT_SIZE                       equ 8
GAME_TURN_LENGTH                equ 4

; =========================================== GAME STATES ===================|80

; Check StateJumpTable for functions IDs (n-th in a table)
STATE_INIT_ENGINE       equ 0
STATE_QUIT              equ 1
STATE_P1X_SCREEN_INIT   equ 2
STATE_P1X_SCREEN        equ 3
STATE_TITLE_SCREEN_INIT equ 4
STATE_TITLE_SCREEN      equ 5
STATE_MENU_INIT         equ 6
STATE_MENU              equ 7
STATE_GAME_NEW          equ 8
STATE_GAME_INIT         equ 9
STATE_GAME              equ 10
STATE_MAP_VIEW_INIT     equ 11
STATE_MAP_VIEW          equ 12
STATE_DEBUG_VIEW_INIT   equ 13
STATE_DEBUG_VIEW        equ 14
STATE_HELP_INIT         equ 15
STATE_HELP              equ 16
STATE_WINDOW_INIT       equ 17
STATE_WINDOW            equ 18
STATE_BRIEFING_INIT equ 19
STATE_BRIEFING   equ 20


; =========================================== TILES NAMES ===================|80

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
TILE_EXTRACTION                 equ 0x0D
TILE_RES_YELLOW_1               equ 0x0E
TILE_RES_YELLOW_2               equ 0x0F
TILE_RES_BLUE_1                 equ 0x10
TILE_RES_BLUE_2                 equ 0x11
TILE_RES_RED_1                  equ 0x12
TILE_RES_RED_2                  equ 0x13
TILE_RAILS_1                    equ 0x14
TILE_RAILS_2                    equ 0x15
TILE_RAILS_3                    equ 0x16
TILE_RAILS_4                    equ 0x17
TILE_RAILS_5                    equ 0x18
TILE_RAILS_6                    equ 0x19
TILE_RAILS_7                    equ 0x1A
TILE_RAILS_8                    equ 0x1B
TILE_RAILS_9                    equ 0x1C
TILE_RAILS_10                   equ 0x1D
TILE_RAILS_11                   equ 0x1E
TILE_ROCKET_BOTTOM              equ 0x1F
TILE_ROCKET_TOP                 equ 0x20
TILE_BUILDING_RAFINERY           equ 0x21
TILE_BUILDING_COLECTOR          equ 0x22
TILE_BUILDING_SILOS             equ 0x23
TILE_BUILDING_LAB               equ 0x24
TILE_BUILDING_RADAR             equ 0x25
TILE_BUILDING_PODS              equ 0x26
TILE_BUILDING_POWER             equ 0x27
TILE_IO_RIGHT                   equ 0x28
TILE_IO_UP                      equ 0x29
TILE_IO_DOWN                    equ 0x2A
TILE_IO_LEFT                    equ 0x2B
TILE_UFO_FLY                    equ 0x2C
TILE_UFO_ATTACK                 equ 0x2D
TILE_CART_VERTICAL              equ 0x2E
TILE_CART_HORIZONTAL            equ 0x2F
TILE_SWITCH_LEFT                equ 0x30
TILE_SWITCH_DOWN                equ 0x31
TILE_SWITCH_RIGHT               equ 0x32
TILE_SWITCH_UP                  equ 0x33
TILE_ORE_BLUE                   equ 0x34
TILE_ORE_YELLOW                 equ 0x35
TILE_ORE_RED                    equ 0x36
TILE_EXTRACT_BLUE               equ 0x37
TILE_EXTRACT_YELLOW             equ 0x38
TILE_EXTRACT_RED                equ 0x39
TILE_SILO_BLUE                  equ 0x3A
TILE_SILO_YELLOW                equ 0x3B
TILE_SILO_RED                   equ 0x3C
TILE_CURSOR_PAN                 equ 0x3D
TILE_CURSOR_BUILD               equ 0x3E
TILE_CURSOR_EDIT                equ 0x3F
TILE_CURSOR_BUILDING            equ 0x40
TILE_CURSOR_SELECTOR            equ 0x41
TILE_WINDOW_1                   equ 0x42
TILE_WINDOW_2                   equ 0x43
TILE_WINDOW_3                   equ 0x44
TILE_WINDOW_4                   equ 0x45
TILE_WINDOW_5                   equ 0x46
TILE_WINDOW_6                   equ 0x47
TILE_WINDOW_7                   equ 0x48
TILE_WINDOW_8                   equ 0x49
TILE_WINDOW_9                   equ 0x4A
TILE_FRAME_1                    equ 0x4B
TILE_FRAME_2                    equ 0x4C
TILE_FRAME_3                    equ 0x4D
TILE_FRAME_4                    equ 0x4E
TILE_FRAME_5                    equ 0x4F
TILE_FRAME_6                    equ 0x50
TILE_FRAME_7                    equ 0x51
TILE_FRAME_8                    equ 0x52

; Helpers
TILES_COUNT                     equ 95
TILE_FOREGROUND_SHIFT           equ 0x0E    ; pointer to first foreground tiles
TILE_ROCKET_BOTTOM_ID           equ TILE_ROCKET_BOTTOM-TILE_FOREGROUND_SHIFT
TILE_ROCKET_TOP_ID              equ TILE_ROCKET_TOP-TILE_FOREGROUND_SHIFT
TILE_BUILDING_RAFINERY_ID       equ TILE_BUILDING_RAFINERY-TILE_FOREGROUND_SHIFT
TILE_BUILDING_COLECTOR_ID      equ TILE_BUILDING_COLECTOR-TILE_FOREGROUND_SHIFT
TILE_BUILDING_SILOS_ID          equ TILE_BUILDING_SILOS-TILE_FOREGROUND_SHIFT
TILE_BUILDING_LAB_ID            equ TILE_BUILDING_LAB-TILE_FOREGROUND_SHIFT
TILE_BUILDING_RADAR_ID          equ TILE_BUILDING_RADAR-TILE_FOREGROUND_SHIFT
TILE_BUILDING_PODS_ID           equ TILE_BUILDING_PODS-TILE_FOREGROUND_SHIFT
TILE_BUILDING_POWER_ID          equ TILE_BUILDING_POWER-TILE_FOREGROUND_SHIFT

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
BACKGROUND_SPRITE_CLIP          equ 0xF0
TERRAIN_TRAVERSAL_MASK          equ 0x10
TERRAIN_TRAVERSAL_SHIFT         equ 0x4
TERRAIN_TRAVERSAL_CLIP          equ 0xEF
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
FOREGROUND_SPRITE_MASK          equ 0x1F
FOREGROUND_SPRITE_CLIP          equ 0xE0
CART_DRAW_MASK                  equ 0x20
CART_DRAW_CLIP                  equ 0xDF
CURSOR_TYPE_MASK                equ 0xC0
CURSOR_TYPE_CLIP                equ 0x3F
CURSOR_TYPE_SHIFT               equ 0x06
CURSOR_TYPE_ROL                 equ 0x02

; SEGMENT_META_DATA
; 0 00 0 00 00
; | |  | |  |
; | |  | |  |
; | |  | |  '- tile direction (4): switch, building
; | |  | '- resource type (4) (for source/pods cargo/buildings)
; | |  '- switch on rail (or not initialized)
; | '- cart drive direction (4)
; '- empty
;
; if building/resource then least significant bits are used for:
; 0000 00 00
; '- resource amount (16)
;
TILE_DIRECTION_MASK             equ 0x3
SWITCH_DATA_CLIP                equ 0xEC
RESOURCE_TYPE_MASK              equ 0xC
RESOURCE_TYPE_SHIFT             equ 0x2
SWITCH_MASK                     equ 0x10
CART_DIRECTION_MASK             equ 0x60
CART_DIRECTION_SHIFT            equ 0x5
CART_DIRECTION_CLIP             equ 0x9F
RESOURCE_AMOUNT_MASK            equ 0xF0
RESOURCE_AMOUNT_SHIFT           equ 0x4

; UPGRADES
; **** . . . . * * ** .. ..
; 0000 0 0 0 0 0 0 00 00 00 (16)
; |    | | | | | | |  |  |
; |    | | | | | | |  |  '- pods: faster movement 1x-2x-4x-(TBD)
; |    | | | | | | |  '- pods: more storage 4-8-16-(TBD)
; |    | | | | | | '- pods: faster load/unload 1x-2x-4x-(TBD)
; |    | | | | | '- rafinery: speed of refining 1x-2x
; |    | | | | '- rafinery: efficient of refining 1x-2x
; |    | | | '- rafinery: lower cost of refining 1x-2x
; |    | | '- silosL double capacity 1x-2x
; |    | '- pods factory: lower cost of production 1x-2x
; |    '- TBD
; '- TBD
UPGRADE_PODS_SPEED_MASK         equ 0x3
UPGRADE_PODS_STORAGE_MASK       equ 0xC
UPGRADE_PODS_STORAGE_SHIFT      equ 0x2
UPGRADE_PODS_LOAD_MASK          equ 0x30
UPGRADE_PODS_LOAD_SHIFT         equ 0x4
UPGRADE_RAFINERY_SPEED_MASK     equ 0x40
UPGRADE_RAFINERY_EFFICIENCY_MASK equ 0x80
UPGRADE_RAFINERY_COST_MASK      equ 0x100
UPGRADE_SILOS_CAPACITY_MASK     equ 0x200
UPGRADE_PODS_FACTORY_COST_MASK  equ 0x400
UPGRADE_SILOS_SPEED_MASK        equ 0x800
UPGRADE_PODS_FACTORYCOST_MASK   equ 0x1000

; MISC
;
CART_LEFT                       equ 0x00
CART_DOWN                       equ 0x01
CART_RIGHT                      equ 0x02
CART_UP                         equ 0x03
TERRAIN_RULES_CROP              equ 0x03
CURSOR_ICON_POINTER             equ 0x00
CURSOR_ICON_PLACE_RAIL          equ 0x01
CURSOR_ICON_EDIT                equ 0x02
CURSOR_ICON_PLACE_BUILDING      equ 0x03
SCENE_MODE_ANY                  equ 0x00
SCENE_MODE_MAIN_MENU            equ 0x00
SCENE_MODE_BASE_BUILDINGS       equ 0x01
SCENE_MODE_REMOTE_BUILDINGS     equ 0x02
SCENE_MODE_STATION              equ 0x03
SCENE_MODE_BRIEFING             equ 0x04
SCENE_MODE_UPGRADE_BUILDINGS    equ 0x05
UI_STATS_GFX_LINE               equ 320*175
UI_STATS_TXT_LINE               equ 0x16
UI_BOTTOM_FRAME                 equ 320*176

; =========================================== COLORS / DB16 =================|80

COLOR_BLACK         equ 0x00
COLOR_DEEP_PURPLE   equ 0x01
COLOR_NAVY_BLUE     equ 0x02
COLOR_DARK_GRAY     equ 0x03
COLOR_BROWN         equ 0x04
COLOR_DARK_GREEN    equ 0x05
COLOR_RED           equ 0x06
COLOR_LIGHT_GRAY    equ 0x07
COLOR_BLUE          equ 0x08
COLOR_ORANGE        equ 0x09
COLOR_STEEL_BLUE    equ 0x0A
COLOR_GREEN         equ 0x0B
COLOR_PINK          equ 0x0C
COLOR_CYAN          equ 0x0D
COLOR_YELLOW        equ 0x0E
COLOR_WHITE         equ 0x0F

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
  int 16h

; Call BIOS interrupt

  ; ========================================= STATE TRANSITIONS ============|80
  ; Main state game changer. Changes states like intro, menu, game.
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

    cmp byte [si+1], SCENE_MODE_ANY
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

.update_game_logic:
  cmp byte [_GAME_STATE_], STATE_GAME
  jnz .skip_turn
  dec byte [_GAME_TURN_]
  cmp byte [_GAME_TURN_], 0x0
  jg .skip_turn
    call game_logic.calculate_pods
    mov byte [_GAME_TURN_], GAME_TURN_LENGTH
  .skip_turn:

; =========================================== ESC OR LOOP ===================|80

jmp main_loop

; =========================================== EXIT TO DOS ===================|80

exit:
  call audio.destroy
  mov ax, 0x0003                        ; Set video mode to 80x25 text mode
  int 0x10                              ; Call BIOS interrupt
  mov si, QuitText                      ; Draw message after exit
  xor dx, dx                            ; At 0/0 position
  call terminal.draw_text

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
  jmp .redraw_old_tile

  .move_cursor_down:
    mov ax, [_VIEWPORT_Y_]              ; viewport top position
    add ax, VIEWPORT_HEIGHT-2           ; get viewport bottom
    cmp word [_CURSOR_Y_], ax           ; check if cursro at the bottom
    jae .move_viewport_down             ; try to move viewport down

    inc word [_CURSOR_Y_]               ; or just move the cursor down
  jmp .redraw_old_tile

  .move_cursor_left:
    mov ax, [_VIEWPORT_X_]              ; viewport left position
    inc ax                              ; one tile before
    cmp word [_CURSOR_X_], ax           ; check if cursor at the left edge
    je .move_viewport_left              ; try to move viewport left

    dec word [_CURSOR_X_]               ; or just move the cursor left
  jmp .redraw_old_tile

  .move_cursor_right:
    mov ax, [_VIEWPORT_X_]              ; viewport left position
    add ax, VIEWPORT_WIDTH-2            ; get viewport right
    cmp word [_CURSOR_X_], ax           ; check if cursor at the right edge
    jae .move_viewport_right            ; try to move viewport right

    inc word [_CURSOR_X_]               ; or just move the cursor right
  jmp .redraw_old_tile

  .move_viewport_up:
    cmp word [_VIEWPORT_Y_], 0          ; check if viewport at the top edge
    je .done                            ; do nothing if on edge
    dec word [_VIEWPORT_Y_]             ; move viewport up
    dec word [_CURSOR_Y_]               ; move cursor up
    mov bx, [_CURSOR_Y_]
    mov word [_CURSOR_Y_OLD_], bx
  jmp .redraw_terrain

  .move_viewport_down:
    cmp word [_VIEWPORT_Y_], MAP_SIZE-VIEWPORT_HEIGHT ; check if viewport at the bottom edge of ma26p
    jae .done                           ; do nothing if on edge
    inc word [_VIEWPORT_Y_]             ; move viewport down
    inc word [_CURSOR_Y_]               ; move cursor down
    mov bx, [_CURSOR_Y_]
    mov word [_CURSOR_Y_OLD_], bx
  jmp .redraw_terrain

  .move_viewport_left:
    cmp word [_VIEWPORT_X_], 0          ; check if viewport at the left edge of map
    je .done                            ; do nothing if on edge
    dec word [_VIEWPORT_X_]             ; move viewport left
    dec word [_CURSOR_X_]               ; move cursor left
    mov ax, [_CURSOR_X_]
    mov word [_CURSOR_X_OLD_], ax
  jmp .redraw_terrain

  .move_viewport_right:
    cmp word [_VIEWPORT_X_], MAP_SIZE-VIEWPORT_WIDTH ; check if viewport at the right edge of map
    jae .done                           ; do nothing if on edge
    inc word [_VIEWPORT_X_]             ; move viewport right
    inc word [_CURSOR_X_]               ; move cursor right
    mov ax, [_CURSOR_X_]
    mov word [_CURSOR_X_OLD_], ax
  jmp .redraw_terrain


  .change_action:
    push es
    push ds

    mov bx, SFX_BUILD
    call audio.play_sfx

    mov di, [_CURSOR_Y_]                ; Calculate map position
    shl di, 7   ; Y * 128
    add di, [_CURSOR_X_]               ; For quick random number

    push SEGMENT_TERRAIN_BACKGROUND
    pop es
    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    mov al, [es:di]
    test al, RAIL_MASK
    jnz .switch_change
    test al, INFRASTRUCTURE_MASK
    jnz .building_exit_rotate
    jmp .change_action_done

    .switch_change:
      push SEGMENT_META_DATA
      pop es

      test byte [es:di], SWITCH_MASK
      jz .change_action_done

      mov al, [es:di]
      and al, TILE_DIRECTION_MASK
      xor al, 0x2                       ; invert swich top-down or left-right
      add al, SWITCH_MASK
      and byte [es:di], SWITCH_DATA_CLIP
      add byte [es:di], al
    jmp .change_action_done

    .building_exit_rotate:
      push SEGMENT_META_DATA
      pop es
      mov al, [es:di]
      and al, TILE_DIRECTION_MASK
      inc al
      and al, 0x3                       ; Clip to 0-3
      and byte [es:di], SWITCH_DATA_CLIP
      add byte [es:di], al
    jmp .change_action_done

    .change_action_done:
    pop ds
    pop es
  jmp .redraw_tile

  .build_action:
    push es
    push ds

    mov bx, SFX_BUILD
    call audio.play_sfx

    mov di, [_CURSOR_Y_]                ; Calculate map position
    shl di, 7   ; Y * 128
    add di, [_CURSOR_X_]               ; For quick random number

    push SEGMENT_TERRAIN_BACKGROUND
    pop es
    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    .decide_on_action:
      mov bl, [ds:di]
      and bl, CURSOR_TYPE_MASK
      rol bl, CURSOR_TYPE_ROL

      cmp bl, CURSOR_ICON_PLACE_BUILDING
      jz .place_building
      cmp bl, CURSOR_ICON_PLACE_RAIL
      jz .place_rail
    jmp .build_action_done

    .place_rail:
      mov al, [_GAME_TICK_]
      and al, 0x1                       ; TILE_MUD_1 or TILE_MUD_2
      add al, RAIL_MASK
      mov byte [es:di], al
      mov byte [ds:di], TILE_RAILS_1-TILE_FOREGROUND_SHIFT

      call recalculate_rails

      dec di
      call recalculate_rails
      add di, 2
      call recalculate_rails
      sub di, MAP_SIZE+1
      call recalculate_rails
      add di, MAP_SIZE*2
      call recalculate_rails

      pop ds
      pop es
      jmp .redraw_four_tiles

    .place_building:
      mov al, [es:di]
      test al, RAIL_MASK
      jnz .station

      test al, INFRASTRUCTURE_MASK
      jnz .upgrade_building

      and al, BACKGROUND_SPRITE_MASK
      cmp al, TILE_STATION_EXTEND
      jz .remote_building


      .base_building:
        mov bx, SCENE_MODE_BASE_BUILDINGS
        jmp .pop_window

      .remote_building:
        mov bx, SCENE_MODE_REMOTE_BUILDINGS
        jmp .pop_window

      .upgrade_building:
        mov bx, SCENE_MODE_UPGRADE_BUILDINGS
        jmp .pop_window

      .station:
        mov bx, SCENE_MODE_STATION
        jmp .pop_window

    .pop_window:
      pop ds
      pop es
      mov byte [_GAME_STATE_], STATE_WINDOW_INIT
      mov byte [_SCENE_MODE_], bl
      mov byte [_MENU_SELECTION_POS_], 0x0
      jmp .done

    .build_action_done:
    pop ds
    pop es
  jmp .redraw_tile

  .calculate_pods:
    push es
    push ds

    push SEGMENT_ENTITIES
    pop es

    xor si, si
    .ent_loop:
      mov di, [es:si]                   ; SEGMENT_ENTITIES
      cmp di, 0x0
      jz .done_ent_loop

      .calculate_cart_direction:
        push SEGMENT_META_DATA
        pop ds
        mov al, [ds:di]                 ; SEGMENT_META_DATA
        and al, CART_DIRECTION_MASK
        shr al, CART_DIRECTION_SHIFT

        mov cl, al                      ; save initial cart direction
        mov bx, di                      ; Save original position

        .test_forward_move:
          push SEGMENT_TERRAIN_BACKGROUND
          pop ds
          call calculate_directed_tile
          test byte [ds:di], RAIL_MASK  ; SEGMENT_TERRAIN_BACKGROUND
          jnz .check_forward_move

        .test_if_switch:
          push SEGMENT_META_DATA
          pop ds

          mov di, bx                    ; restore position
          mov al, [ds:di]               ; SEGMENT_META_DATA
          test al, SWITCH_MASK          ; check if its stay on a switch
          jz .test_other_axis_turn_move ; if not then left or right turn

          mov al, [ds:di]               ; SEGMENT_META_DATA
          and al, TILE_DIRECTION_MASK
          call calculate_directed_tile  ; check target position tile
          jmp .check_forward_move       ; try move forward

        .test_other_axis_turn_move:
          push SEGMENT_TERRAIN_BACKGROUND
          pop ds
          mov al, cl
          xor ax, 0x1                   ; rotate target (up-down to left-right)
          call calculate_directed_tile
          test byte [ds:di], RAIL_MASK  ; SEGMENT_TERRAIN_BACKGROUND
          jnz .check_forward_move

          mov di, bx
          xor ax, 0x2                   ; mirror left/right or up/down
          call calculate_directed_tile
          test byte [ds:di], RAIL_MASK  ; SEGMENT_TERRAIN_BACKGROUND
          jnz .check_forward_move

        mov al, cl                      ; restore initial direction
        jmp .revert_move

        .check_forward_move:
          push SEGMENT_TERRAIN_FOREGROUND
          pop ds
          test byte [ds:di], CART_DRAW_MASK ; SEGMENT_TERRAIN_FOREGROUND
          jz .save_pod_move

        .pod_meet:
          push SEGMENT_META_DATA
          pop ds
          mov ah, [ds:di]               ; SEGMENT_META_DATA
          and ah, CART_DIRECTION_MASK
          shr ah, CART_DIRECTION_SHIFT

          cmp al, ah                    ; check if same dir
          je .next_pod                  ; not in collision, wait

          xor ah, 0x2
          cmp al, ah                    ; check if pointing at each other
        jne .next_pod                   ; not in collision, wait

      .revert_move:
        mov al, cl                      ; restore initial direction
        xor ax, 0x2                     ; mirror direction
        push SEGMENT_META_DATA
        pop ds
        and byte [ds:bx], CART_DIRECTION_CLIP ; SEGMENT_META_DATA
        shl al, CART_DIRECTION_SHIFT
        add byte [ds:bx], al            ; SEGMENT_META_DATA
      jmp .next_pod

      .save_pod_move:
        ; ES = ENTITIES SEGMENT
        ; DS = FOREGROIND
        mov word [es:si], di            ; update entitie pointer to new pos
        and byte [ds:bx], CART_DRAW_CLIP  ; remove cart drawing from old pos
        add byte [ds:di], CART_DRAW_MASK  ; draw cart on new pos

        ; TODO: move also resources and cursor!

        push SEGMENT_META_DATA
        pop ds
        and byte [ds:di], CART_DIRECTION_CLIP ; SEGMENT_META_DATA
        shl al, CART_DIRECTION_SHIFT
        add byte [ds:di], al            ; SEGMENT_META_DATA

      .redraw_tiles:
        push si
        push di

        mov di, bx
        mov si, bx
        call draw_single_cell

        pop di

        mov si, di
        call draw_single_cell

        pop si

      .next_pod:
      add si, 0x2
    jmp .ent_loop
    .done_ent_loop:

    pop ds
    pop es
  jmp .done

  .redraw_four_tiles:
    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    dec ax
    call draw_selected_cell

    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    inc ax
    call draw_selected_cell

    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    inc bx
    call draw_selected_cell

    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    dec bx
    call draw_selected_cell
    jmp .redraw_tile

  .redraw_old_tile:
    mov ax, [_CURSOR_X_OLD_]
    mov bx, [_CURSOR_Y_OLD_]
    call draw_selected_cell

  .redraw_tile:
    mov ax, [_CURSOR_X_]
    mov bx, [_CURSOR_Y_]
    mov word [_CURSOR_X_OLD_], ax
    mov word [_CURSOR_Y_OLD_], bx
    call draw_selected_cell
    call ui.draw_cursor
    jmp .done

  .redraw_terrain:
    call draw_terrain
    call ui.draw_cursor
    call ui.draw_footer
    jmp .done

  .done:
  call ui.draw_screen_frame
ret

; in:
; DI position
; AL direction
; out:
; DI changed
calculate_directed_tile:
  .check_up:
  cmp al, CART_UP
    jnz .check_left
    sub di, MAP_SIZE
    ret
  .check_left:
  cmp al, CART_LEFT
    jnz .check_down
    dec di
    ret
  .check_down:
  cmp al, CART_DOWN
    jnz .check_right
    add di, MAP_SIZE
    ret
  .check_right:
    inc di
ret

actions_logic:

  .expand_foundation:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    push es
    push ds

    push SEGMENT_TERRAIN_BACKGROUND
    pop es

    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    mov ax, TILE_FOUNDATION
    mov bx, CURSOR_ICON_PLACE_BUILDING
    ror bl, CURSOR_TYPE_ROL
    test byte [es:di+1], TERRAIN_TRAVERSAL_MASK
    jz .skip_right
      mov byte [es:di+1], al
      mov byte [ds:di+1], bl
    .skip_right:
    test byte [es:di-1], TERRAIN_TRAVERSAL_MASK
    jz .skip_left
      mov byte [es:di-1], al
      mov byte [ds:di-1], bl
    .skip_left:
    test byte [es:di-MAP_SIZE], TERRAIN_TRAVERSAL_MASK
    jz .skip_up
      mov byte [es:di-MAP_SIZE], al
      mov byte [ds:di-MAP_SIZE], bl
    .skip_up:
    test byte [es:di+MAP_SIZE], TERRAIN_TRAVERSAL_MASK
    jz .skip_down
      mov byte [es:di+MAP_SIZE], al
      mov byte [ds:di+MAP_SIZE], bl
    .skip_down:

  pop ds
  pop es
  jmp .done

  .place_station:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    push es
    push ds

    push SEGMENT_TERRAIN_BACKGROUND
    pop es

    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    mov al, [es:di]
    and al, BACKGROUND_SPRITE_CLIP
    add al, TILE_STATION
    or al, RAIL_MASK
    mov byte [es:di], al
    and byte [ds:di], CURSOR_TYPE_CLIP

    mov bl, TILE_STATION_EXTEND
    mov cx, CURSOR_ICON_PLACE_BUILDING
    ror cl, CURSOR_TYPE_ROL
    mov al, [ds:di]
    and al, FOREGROUND_SPRITE_MASK
    cmp al, TILE_RAILS_1-TILE_FOREGROUND_SHIFT  ; horizontal
    jz .build_horizontal

    .build_vertical:
      test byte [es:di-1], TERRAIN_TRAVERSAL_MASK
      jz .skip_left2
        mov [es:di-1], bl
        mov [ds:di-1], cl
      .skip_left2:
      test byte [es:di+1], TERRAIN_TRAVERSAL_MASK
      jz .build_done
        mov [es:di+1], bl
        mov [ds:di+1], cl
    jmp .build_done

    .build_horizontal:
      test byte [es:di-MAP_SIZE], TERRAIN_TRAVERSAL_MASK
      jz .skip_up2
        mov [es:di-MAP_SIZE], bl
        mov [ds:di-MAP_SIZE], cl
      .skip_up2:
      test byte [es:di+MAP_SIZE], TERRAIN_TRAVERSAL_MASK
      jz .build_done
        mov [es:di+MAP_SIZE], bl
        mov [ds:di+MAP_SIZE], cl
    .build_done:

    pop ds
    pop es
  jmp .done

  .place_building:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    push es
    push ds

    push SEGMENT_TERRAIN_BACKGROUND
    pop es

    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    mov bx, ax ; sprite
    mov al, [es:di]
    or al, INFRASTRUCTURE_MASK
    mov byte [es:di], al

    mov al, CURSOR_ICON_PLACE_BUILDING
    ror al, CURSOR_TYPE_ROL
    add ax, bx
    mov byte [ds:di], al

    pop ds
    pop es
  jmp .done

  .inspect_building:
  jmp .done

  .build_pods_station:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    push es
    push ds

    push SEGMENT_TERRAIN_BACKGROUND
    pop es

    push SEGMENT_META_DATA
    pop ds

    mov al, [ds:di]
    and al, TILE_DIRECTION_MASK

    call get_target_tile

    test byte [es:di], TERRAIN_TRAVERSAL_MASK
    jz .skip_station

    .set_rail_tile:
      and al, 0x1           ; horizontal or vertical initial rails
      mov bl, TILE_RAILS_2
      sub bl, al
      sub bl, TILE_FOREGROUND_SHIFT

    .set_station_tile:
      mov al, TILE_STATION
      add al, RAIL_MASK
      mov byte [es:di], al

      push SEGMENT_TERRAIN_FOREGROUND
      pop ds

      mov byte [ds:di], bl

    .recalculate_near_rails:
      dec di
      call recalculate_rails
      add di, 2
      call recalculate_rails
      dec di
      add di, MAP_SIZE
      call recalculate_rails
      sub di, MAP_SIZE*2
      call recalculate_rails

    .skip_station:
    pop ds
    pop es
  jmp .done

  .build_pod:
    mov di, [_CURSOR_Y_]    ; Absolute Y map coordinate
    shl di, 7               ; Y * 128 (optimized shl for *128)
    add di, [_CURSOR_X_]    ; + absolute X map coordinate

    push es
    push ds

    push SEGMENT_TERRAIN_BACKGROUND
    pop es

    push SEGMENT_META_DATA
    pop ds

    mov al, [ds:di]
    and al, TILE_DIRECTION_MASK

    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    call get_target_tile
    .check_for_station:
      mov al, [es:di]
      and al, BACKGROUND_SPRITE_MASK
      cmp al, TILE_STATION
      jnz .skip_build_pod

    .pod_on_station:
      mov al, [ds:di]
      or al, CART_DRAW_MASK
      mov byte [ds:di], al

      ; TODO: temporary for debug
      push SEGMENT_META_DATA
      pop ds
      call get_random
      and ax, 0x3
      shl ax, RESOURCE_TYPE_SHIFT
      or byte [ds:di], al
      ; END TODO

    pop ds
    pop es

    mov si, [_LAST_ENT_POD_ID_]
    inc word [_LAST_ENT_POD_ID_]
    shl si, 1

    push es
    push SEGMENT_ENTITIES
    pop es
    mov [es:si], di
    pop es
  jmp .done

  .done:
ret

  .skip_build_pod:
  pop ds
  pop es
ret

; DI current
; al direction
; out di of target
get_target_tile:
  .test_right:
  cmp al, 0x0
  jnz .test_up
    inc di
    jmp .test_done
  .test_up:
  cmp al, 0x1
  jnz .test_left
    sub di, MAP_SIZE
    jmp .test_done
  .test_left:
  cmp al, 0x2
  jnz .test_down
    dec di
    jmp .test_done
  .test_down:
    add di, MAP_SIZE
  .test_done:
ret

window_logic:
  .create_window:
  .redraw_window:
    mov si, WindowDefinitionsArray
    xor ax, ax
    mov al, [_SCENE_MODE_]
    imul ax, 0xA
    add si, ax

    mov bx, [si]         ; height:width
    mov ax, [si+2]
    call draw_window

    mov ax, [si+4]
    mov dx, [si+2]
    push si
    mov si, ax

    inc dl
    mov bl, COLOR_BLACK
    call font.draw_string

    pop si
    mov ax, [si+6]
    mov dx, [si+2]
    mov si, ax
    inc dh
    inc dh
    inc dl

    xor cx, cx
    .menu_array:

      cmp byte [si], 0x00
      jz .done_menu_array

      mov bl, COLOR_WHITE
      cmp byte [_MENU_SELECTION_POS_], cl
      jne .skip_color_highlight
        mov bl, COLOR_YELLOW
      .skip_color_highlight:
      push cx
      call font.draw_string
      pop cx
      inc dh
      inc dh
      inc cx
    jmp .menu_array
    .done_menu_array:
    dec cl
    mov byte [_MENU_SELECTION_MAX_], cl
  jmp .done

  .done:
ret

menu_logic:
  .selection_up:
    cmp byte [_MENU_SELECTION_POS_], 0x0
    je .done
    dec byte [_MENU_SELECTION_POS_]
    mov bx, SFX_MENU_UP
    call audio.play_sfx
  jmp window_logic.redraw_window

  .selection_down:
    mov al, [_MENU_SELECTION_POS_]
    cmp al, [_MENU_SELECTION_MAX_]
    je .done
    inc byte [_MENU_SELECTION_POS_]
    mov bx, SFX_MENU_DOWN
    call audio.play_sfx
  jmp window_logic.redraw_window

  .game_menu_enter:
    mov byte [_GAME_STATE_], STATE_GAME_INIT
  .main_menu_enter:
    mov bx, SFX_MENU_ENTER
    call audio.play_sfx
    mov si, WindowDefinitionsArray
    xor ax, ax
    mov al, [_SCENE_MODE_]
    imul ax, 0xA
    add si, ax

    mov si, [si+8]
    mov al, [_MENU_SELECTION_POS_]
    shl al, 2
    add si, ax
    mov ax, [si+2]
    call word [si]
  jmp .done

  .start_game:
    mov byte [_GAME_STATE_], STATE_GAME_INIT
  jmp .done

  .generate_new_map:
    mov byte [_GAME_STATE_], STATE_GAME_NEW
  jmp .done

  .tailset_preview:
    mov byte [_GAME_STATE_], STATE_DEBUG_VIEW_INIT
  jmp .done

  .help:
    mov byte [_GAME_STATE_], STATE_HELP_INIT
  jmp .done

  .quit:
    mov byte [_GAME_STATE_], STATE_QUIT
  jmp .done

  .close_window:
    mov byte [_GAME_STATE_], STATE_GAME_INIT
  jmp .done

  .show_brief:
    mov byte [_GAME_STATE_], STATE_BRIEFING_INIT
  jmp .done

  .back_to_menu:
    mov byte [_GAME_STATE_], STATE_MENU_INIT
  jmp .done

  .done:
ret

; ======================================= PROCEDURES FOR GAME STATES ===C====|80

init_engine:
  call reset_to_default_values
  call audio.init
  call decompress_tiles
  call generate_map
  call build_initial_base
  mov byte [_GAME_STATE_], STATE_P1X_SCREEN_INIT
ret

reset_to_default_values:
  mov dword [_GAME_TICK_], 0x0
  mov byte [_GAME_TURN_], 0x0
  mov word [_RNG_], 0x42

  mov word [_VIEWPORT_X_], MAP_SIZE/2-VIEWPORT_WIDTH/2
  mov word [_VIEWPORT_Y_], MAP_SIZE/2-VIEWPORT_HEIGHT/2
  mov word [_CURSOR_X_], MAP_SIZE/2
  mov word [_CURSOR_Y_], MAP_SIZE/2
  mov word [_CURSOR_X_OLD_], MAP_SIZE/2
  mov word [_CURSOR_Y_OLD_], MAP_SIZE/2

  mov word [_SFX_POINTER_], SFX_NULL
  mov word [_LAST_ENT_POD_ID_], 0

  mov word [_ECONOMY_BLUE_RES_], 0xF
  mov word [_ECONOMY_YELLOW_RES_], 0xF
  mov word [_ECONOMY_RED_RES_], 0xF
ret

init_p1x_screen:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, p1x_logo_image
  call draw_rle_image

  ;mov bx, INTRO_JINGLE
 ; call audio.play_sfx

  mov byte [_GAME_STATE_], STATE_P1X_SCREEN
ret

live_p1x_screen:
  mov si, PressEnterText
  mov dx, 0x170F
  mov bl, COLOR_WHITE
  test word [_GAME_TICK_], 0x4
  je .blink
    mov bl, COLOR_BLACK
  .blink:
  call font.draw_string
ret

init_title_screen:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, title_image
  call draw_rle_image

  mov si, CreatedByText
  mov dx, 0x1508
  mov bl, COLOR_WHITE
  call font.draw_string

  mov si, KKJText
  mov dx, 0x1606
  mov bl, COLOR_WHITE
  call font.draw_string

  ;mov bx, INTRO_JINGLE
  ;call audio.play_sfx

  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN
ret

init_briefing:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, landing_image
  call draw_rle_image

  call ui.draw_map
  mov byte [_GAME_STATE_], STATE_BRIEFING
  mov byte [_SCENE_MODE_], SCENE_MODE_BRIEFING
  call window_logic.create_window
ret

live_briefing:
nop
ret

live_title_screen:
  mov si, PressEnterText
  mov dx, 0x170F
  mov bl, COLOR_WHITE
  test word [_GAME_TICK_], 0x4
  je .blink
    mov bl, COLOR_BLACK
  .blink:
  call font.draw_string
ret

init_menu:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, menu_image
  call draw_rle_image

  mov byte [_GAME_STATE_], STATE_MENU
  mov byte [_SCENE_MODE_], SCENE_MODE_MAIN_MENU
  mov byte [_MENU_SELECTION_POS_], 0x0
  call window_logic.create_window

  mov si, MainMenuCopyText
  mov dx, 0x170D
  mov bl, COLOR_LIGHT_GRAY
  call font.draw_string

  ;mov bx, MENU_JINGLE
  ;call audio.play_sfx
ret

live_menu:
  nop
ret

init_help:

  mov byte [_SCENE_MODE_], 0x0
  call draw_help_page
  mov byte [_GAME_STATE_], STATE_HELP
ret

draw_help_page:
  mov al, COLOR_BLACK
  call clear_screen

  mov si, help_image
  call draw_rle_image

  mov di, HelpArrayText
  movzx ax, byte [_SCENE_MODE_]
  shl ax, 1
  add di, ax
  mov si, [di]

  mov bl, COLOR_WHITE
  mov dx, 0x0102
  .help_entry:
    cmp byte [si], 0x00
    jz .done
    call font.draw_string
    inc dh
  jmp .help_entry
  .done:


  mov bl, COLOR_WHITE
  mov dx, 0x1502
  mov si, HelpFooter1Text
  call font.draw_string
  mov si, HelpFooter2Text
  inc dh
  call font.draw_string

ret

ror_help_page:
  inc byte [_SCENE_MODE_]
  and byte [_SCENE_MODE_], 0x07
  call draw_help_page
ret

live_help:
ret

new_game:
  call generate_map
  call build_initial_base
  call reset_to_default_values

  mov byte [_GAME_STATE_], STATE_BRIEFING_INIT
  mov byte [_SCENE_MODE_], SCENE_MODE_BRIEFING
ret

init_game:
  call draw_terrain
  call ui.draw_cursor
  call ui.draw_screen_frame
  call ui.draw_footer
  mov byte [_GAME_STATE_], STATE_GAME
  mov byte [_SCENE_MODE_], SCENE_MODE_ANY

  ;mov bx, GAME_JINGLE
  ;call audio.play_sfx
ret

live_game:
  nop
ret

init_map_view:
  call ui.draw_map
  mov byte [_GAME_STATE_], STATE_MAP_VIEW

  ;mov bx, MAP_JINGLE
  ;call audio.play_sfx
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


  mov si, Fontset1Text
  mov bl, COLOR_WHITE
  mov dx, 0x1002
  call font.draw_string

  mov si, Fontset2Text
  mov bl, COLOR_RED
  mov dx, 0x1102
  call font.draw_string

  mov si, Fontset3Text
  mov bl, COLOR_BLUE
  mov dx, 0x1202
  call font.draw_string

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


init_window:
  call window_logic.create_window
  mov byte [_GAME_STATE_], STATE_WINDOW
ret

live_window:

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

terminal:
  ; =========================================== DRAW TEXT ====================|80
  ;  SI - Pointer to text
  ;  DL - X position
  ;  DH - Y position
  ;  BX - Color
  .draw_text:
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


; =========================================== FONT SUBSYSTEM ===============|80
font:
  ; =========================================== DRAW STRING ================|80
  ;  SI - Pointer to text string
  ;  DL - X position (in character font size)
  ;  DH - Y position (in character font size)
  ;  BX - Color
  .draw_string:
    .calculate_vga_pointer:
      push bx                             ; Save color
      movzx ax, dl                        ; Extract X
      movzx bx, dh                        ; Extract Y
      shl ax, 3                           ; X * 8
      shl bx, 3                           ; Y * 8
      imul bx, SCREEN_WIDTH               ; Y * 8 * 320
      add bx, ax                          ; Y * 8 * 320 + X * 8
      mov di, bx                          ; Move result to DI
      pop bx                              ; Restore color

    .next_char_loop:
      xor ax, ax                          ; Clear leftover in ax
      lodsb
      test al, al                         ; Test for 0x0 terminator in text string
      jz .done
      cmp ax, 32                          ; space
      jnz .is_not_space
        add di,FONT_SIZE
        jmp .next_char_loop
      .is_not_space:
      push si                             ; Save string pointer
      push di

      call font.draw_character

      pop di
      pop si                              ; Restore string pointer
      add di,FONT_SIZE                    ; Next char
    jmp .next_char_loop
    .done:
  ret

  .draw_character:
    .calculate_character_font_pointer:
      sub ax, ' '                       ; Char index
      shl ax, 3                         ; Font offset (8 bytes)
      mov si, Font
      add si, ax

    mov cx, FONT_SIZE
    .char_line:
      lodsb                             ; Load font byte
      push cx
      mov cx, FONT_SIZE
      .pixel:
        shl al, 1
        jc .draw_px                     ; Transparent
        inc di                          ; Skip pixel
      loop .pixel
        jmp .next_line                  ; Jump to next line on last pixel
        .draw_px:
        mov [es:di], bl                 ; Color pixel
        inc di
      loop .pixel                       ; Next pixel
      .next_line:
      add di, SCREEN_WIDTH-FONT_SIZE
      pop cx
    loop .char_line
  ret

  ; =========================================== DRAW NUMBER ===================|80
  ; IN:
  ;   SI - Value to display (decimal)
  ;   DL - X position
  ;   DH - Y position
  ;   BX - Color
  ;   CX - digits length
  .draw_number:
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

  .calculate_uposition:
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
      and ax, TERRAIN_RULES_CROP        ; Crop to 0-3
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
  mov byte [es:di], al
  mov byte [es:di+1], al
  mov byte [es:di-1], al
  mov byte [es:di+MAP_SIZE], al
  mov byte [es:di-MAP_SIZE], al

  add ax, INFRASTRUCTURE_MASK
  mov byte [es:di], al
  mov byte [es:di-MAP_SIZE], al

  mov ax, CURSOR_ICON_PLACE_BUILDING
  ror al, CURSOR_TYPE_ROL
  mov byte [ds:di+1], al
  mov byte [ds:di-1], al
  mov byte [ds:di+MAP_SIZE], al

  .place_rocket:
  mov ax, CURSOR_ICON_POINTER
  ror al, CURSOR_TYPE_ROL
  mov bx, ax
  add ax, TILE_ROCKET_BOTTOM_ID
  mov byte [ds:di], al
  add bx, TILE_ROCKET_TOP_ID
  mov byte [ds:di-MAP_SIZE], bl

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
      call draw_cell
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


draw_selected_cell:
  push si
  push di

  mov si, bx                ; Calculate map position
  shl si, 7   ; Y * 128
  add si, ax

  sub bx, [_VIEWPORT_Y_]  ; Y - Viewport Y
  shl bx, 4               ; Y * 16
  sub ax, [_VIEWPORT_X_]  ; X - Viewport X
  shl ax, 4               ; X * 16
  imul bx, SCREEN_WIDTH   ; Y * 16 * 320
  add bx, ax              ; Y * 16 * 320 + X * 16
  mov di, bx              ; Move result to DI

  push es
  push ds

  push SEGMENT_TERRAIN_BACKGROUND
  pop es

  push SEGMENT_TERRAIN_FOREGROUND
  pop ds

  call draw_cell

  pop ds
  pop es
  pop di
  pop si
ret

draw_single_cell:
  push si
  push di
  push es
  push ds

  push cs
  pop es

  .calculate_position:
    mov ax, di
    mov bx, di
    shr bx, 7
    push bx
    shl bx, 7
    sub ax, bx ; ax = x
    pop bx  ; bx = y

  .clip_viewport:
    cmp ax, [es:_VIEWPORT_X_]
    jb .skip_drawing                    ; x < viewport x
    cmp bx, [es:_VIEWPORT_Y_]
    jb .skip_drawing                    ; y < viewport y
    mov cx, [es:_VIEWPORT_X_]
    add cx, VIEWPORT_WIDTH
    cmp ax, cx
    jae .skip_drawing                    ; x >= viewport x
    mov cx, [es:_VIEWPORT_Y_]
    add cx, VIEWPORT_HEIGHT
    cmp bx, cx
    jae .skip_drawing                    ; y >= viewport y

  .calculate_memory_position:
    sub bx, [es:_VIEWPORT_Y_]
    shl bx, 4
    sub ax, [es:_VIEWPORT_X_]
    shl ax, 4
    imul bx, SCREEN_WIDTH
    add bx, ax
    mov di, bx

  push SEGMENT_TERRAIN_BACKGROUND
  pop es

  push SEGMENT_TERRAIN_FOREGROUND
  pop ds

  call draw_cell

  .skip_drawing:
  pop ds
  pop es
  pop di
  pop si
ret

draw_cell:
  mov al, [es:si]                   ; SEGMENT_TERRAIN_BACKGROUND
  mov bl, al
  and al, BACKGROUND_SPRITE_MASK
  call draw_tile
  and bl, TERRAIN_SECOND_LAYER_DRAW_CLIP
  cmp bl, 0x0
  jz .skip_foreground
  .draw_forground:

    mov al, [ds:si]                 ; SEGMENT_TERRAIN_FOREGROUND
    and al, FOREGROUND_SPRITE_MASK
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
          and al, TILE_DIRECTION_MASK
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
ret

; =================================== RECALCULATE RAILS =====================|80
; di: pos
; es background
; ds foreground
recalculate_rails:
  xor ax, ax
  test byte [es:di], RAIL_MASK
  jz .update_cursor

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
    mov bx, RailroadsDict
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
    cmp dl, 0x05
    je .prepare_station
    cmp dl, 0x0A
    je .prepare_station
    jmp .prepare_no_switch

  .prepare_switch_horizontal:
    mov dl, SWITCH_MASK                 ; 0 for left switch ID + enable switch
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_switch_vertical:
    mov dl, 1                           ; down switch ID
    add dl, SWITCH_MASK                 ; enable switch
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_station:
    mov dl, 0                           ; No switch
    mov ax, CURSOR_ICON_PLACE_BUILDING
    test byte [es:di], INFRASTRUCTURE_MASK  ; Check if its a station
    jz  .save_switch
    mov ax, CURSOR_ICON_EDIT
    jmp .save_switch
  .prepare_no_switch:
    mov dl, 0                           ; No switch, or last rail (no station)
    mov ax, CURSOR_ICON_POINTER

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
    jmp .done

  .update_cursor:
    mov byte al, [es:di]
    test al, TERRAIN_TRAVERSAL_MASK
    jz .done
    mov bl, al
    and bl, TERRAIN_SECOND_LAYER_DRAW_CLIP
    cmp bl, 0x0
    jnz .done

    mov ax, CURSOR_ICON_PLACE_RAIL
    ror al, CURSOR_TYPE_ROL
    mov byte [ds:di], al

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



; =========================================== UI SUBSYSTEM ==================|80
ui:
  .draw_screen_frame:
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

    ret

  .draw_footer_background:
    mov di, UI_BOTTOM_FRAME

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

  .draw_footer:
    call ui.draw_footer_background

    mov di, UI_STATS_GFX_LINE+90   ; Resource blue icon
    mov al, TILE_ORE_BLUE
    call draw_sprite

    mov si, [_ECONOMY_BLUE_RES_]  ; Blue resource count
    mov dh, UI_STATS_TXT_LINE
    mov dl, 0x0D
    mov bl, COLOR_WHITE
    mov cx, 10000
    call font.draw_number

    mov di, UI_STATS_GFX_LINE+154
    mov al, TILE_ORE_YELLOW
    call draw_sprite

    mov si, [_ECONOMY_YELLOW_RES_]  ; Yellow resource count
    mov dh, UI_STATS_TXT_LINE
    mov dl, 0x15
    mov bl, COLOR_WHITE
    mov cx, 10000
    call font.draw_number

    mov di, UI_STATS_GFX_LINE+218
    mov al, TILE_ORE_RED
    call draw_sprite

    mov si, [_ECONOMY_RED_RES_]  ; Red resource count
    mov dh, UI_STATS_TXT_LINE
    mov dl, 0x1D
    mov bl, COLOR_WHITE
    mov cx, 10000
    call font.draw_number

    ret

  .draw_cursor:
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

    push es
    push ds

    push SEGMENT_TERRAIN_BACKGROUND
    pop es

    push SEGMENT_TERRAIN_FOREGROUND
    pop ds

    mov al, [ds:si]
    and al, CURSOR_TYPE_MASK
    rol al, CURSOR_TYPE_ROL
    add al, TILE_CURSOR_PAN
    mov bl, al

    test byte [es:si], INFRASTRUCTURE_MASK ; If not a building then skip arrows
    jz .no_infra

    test byte [ds:si], CURSOR_TYPE_MASK   ; If it's a pointer then skip arrows
    jz .no_infra

    push SEGMENT_META_DATA
    pop ds

    mov al, [ds:si]
    and al, TILE_DIRECTION_MASK
    add al, TILE_IO_RIGHT

    pop ds
    pop es

    call draw_sprite                      ; draw the in/out arrow

    mov al, bl
    call draw_sprite                      ; draw cursor
    jmp .done

    .no_infra:
      pop ds
      pop es
      call draw_sprite                    ; draw cursor
    .done:
    ret

  .draw_map:
    push es
    push ds

    push SEGMENT_VGA
    pop es

    mov ax, 0x0602
    mov bx, 0x0909
    call draw_window

    mov si, WindowMinimapText
    mov dx, 0x0603
    mov bl, COLOR_BLACK
    call font.draw_string
    push SEGMENT_TERRAIN_BACKGROUND
    pop ds
    .draw_mini_map:
    xor si, si
    mov di, SCREEN_WIDTH*59+39-16          ; Map position on screen
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
        mov [es:di], al      ; Draw 1 pixels
        add di, 1            ; Move to next column
      loop .draw_row
      pop cx
      add di, 320-MAP_SIZE    ; Move to next row
    loop .draw_loop

    pop ds
    pop es
    ret

; =========================================== AUDIO SYSTEM ==================|80
audio:
  .init:
    push es
    push bx

    mov byte [_SFX_NOTE_INDEX_], 0
    mov byte [_SFX_NOTE_DURATION_], 0
    mov byte [_AUDIO_ENABLED_], TRUE
    mov word [_SFX_POINTER_], SFX_NULL

    mov al, 182                          ; Binary mode, square wave, 16-bit divisor
    out 43h, al                          ; Write to PIT command register

    xor ax, ax
    mov es, ax
    mov bx, [es:08h*4]                  ; Get offset
    mov [_SFX_IRQ_OFFSET_], bx
    mov bx, [es:08h*4+2]                ; Get segment
    mov [_SFX_IRQ_SEGMENT_], bx

    cli                                  ; Disable interrupts
    mov word [es:08h*4], audio.irq_handler
    mov [es:08h*4+2], cs
    sti                                  ; Enable interrupts

    pop bx
    pop es
    ret

  .destroy:
    call audio.stop_sound_irq

    xor ax, ax
    mov es, ax
    cli                                   ; Atomic operation
      mov ax, [_SFX_IRQ_OFFSET_]
      mov [es:08h*4], ax
      mov ax, [_SFX_IRQ_SEGMENT_]
      mov [es:08h*4+2], ax
    sti
    ret

  .irq_handler:
    push ds

    push cs
    pop ds

    cmp byte [_AUDIO_ENABLED_], FALSE
    je .skip_audio
      call audio.irq_update
    .skip_audio:
      pop ds

      jmp far [cs:_SFX_IRQ_OFFSET_]

  .irq_update:
    push ax
    push bx
    push si

    mov si, [_SFX_POINTER_]
    cmp si, SFX_NULL
    je .stop_all_sound

    mov bl, [_SFX_NOTE_INDEX_]
    xor bh, bh
    add si, bx
    mov al, [si]

    test al, al
    jz .end_sfx

  .play_note:
    test al, al
    jz .rest

    movzx bx, al
    shl bx, 1                             ; Multiply by 2 (word size)
    mov si, NoteTable
    add si, bx
    mov ax, [si]

    cmp ax, 0xFFFF
    je .rest

    push ax
    mov al, 182                           ; Prepare timer
    out 43h, al
    pop ax

    out 42h, al                           ; Low byte
    mov al, ah
    out 42h, al                           ; High byte

    in al, 61h
    or al, 00000011b
    out 61h, al
    jmp .done_play

    .rest:
      call audio.stop_sound_irq

    .done_play:

    inc byte [_SFX_NOTE_INDEX_]
    jmp .done_irq_update

    .end_sfx:
      mov word [_SFX_POINTER_], SFX_NULL
      mov byte [_SFX_NOTE_INDEX_], 0

    .stop_all_sound:
      call audio.stop_sound_irq

    .done_irq_update:
    pop si
    pop bx
    pop ax
    ret

  .stop_sound_irq:
    in al, 61h
    and al, 11111100b                    ; Clear bits 0-1
    out 61h, al
    ret

  .play_sfx:
    cli                                  ; Atomic operation
    mov [_SFX_POINTER_], bx
    mov byte [_SFX_NOTE_INDEX_], 0
    mov byte [_SFX_NOTE_DURATION_], 0
    sti
    ret




; =========================================== LOGIC FOR GAME STATES =========|80

; This table needs to corespond to the STATE_ variables IDs
StateJumpTable:
  dw init_engine
  dw exit
  dw init_p1x_screen
  dw live_p1x_screen
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
  dw init_window
  dw live_window
  dw init_briefing
  dw live_briefing

; Transition between major states
StateTransitionTable:
  db STATE_P1X_SCREEN,    KB_ESC,   STATE_QUIT
  db STATE_P1X_SCREEN,    KB_ENTER, STATE_TITLE_SCREEN_INIT
  db STATE_TITLE_SCREEN,  KB_ESC,   STATE_QUIT
  db STATE_TITLE_SCREEN,  KB_ENTER, STATE_MENU_INIT
  db STATE_MENU,          KB_ESC,   STATE_TITLE_SCREEN_INIT
  db STATE_BRIEFING,      KB_ESC,   STATE_MENU_INIT
  db STATE_HELP,          KB_ESC,   STATE_MENU_INIT
  db STATE_GAME,          KB_ESC,   STATE_MENU_INIT
  db STATE_DEBUG_VIEW,    KB_ESC,   STATE_MENU_INIT
StateTransitionTableEnd:

; In state keyboard handling
InputTable:
  db STATE_GAME,                        SCENE_MODE_ANY, KB_UP
  dw game_logic.move_cursor_up
  db STATE_GAME,                        SCENE_MODE_ANY, KB_DOWN
  dw game_logic.move_cursor_down
  db STATE_GAME,                        SCENE_MODE_ANY, KB_LEFT
  dw game_logic.move_cursor_left
  db STATE_GAME,                        SCENE_MODE_ANY, KB_RIGHT
  dw game_logic.move_cursor_right
  db STATE_GAME,                        SCENE_MODE_ANY, KB_SPACE
  dw game_logic.build_action
  db STATE_GAME,                        SCENE_MODE_ANY, KB_ENTER
  dw game_logic.change_action

  db STATE_MENU,                        SCENE_MODE_ANY, KB_UP
  dw menu_logic.selection_up
  db STATE_MENU,                        SCENE_MODE_ANY, KB_DOWN
  dw menu_logic.selection_down
  db STATE_MENU,                        SCENE_MODE_ANY, KB_ENTER
  dw menu_logic.main_menu_enter

  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_UP
  dw menu_logic.selection_up
  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_DOWN
  dw menu_logic.selection_down
  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_SPACE
  dw menu_logic.game_menu_enter
  db STATE_WINDOW,                      SCENE_MODE_ANY, KB_ENTER
  dw menu_logic.game_menu_enter

  db STATE_BRIEFING,                    SCENE_MODE_ANY, KB_UP
  dw menu_logic.selection_up
  db STATE_BRIEFING,                    SCENE_MODE_ANY, KB_DOWN
  dw menu_logic.selection_down
  db STATE_BRIEFING,                    SCENE_MODE_ANY, KB_ENTER
  dw menu_logic.game_menu_enter

  db STATE_HELP,                        SCENE_MODE_ANY, KB_ENTER
  dw ror_help_page
InputTableEnd:

; =========================================== TEXT DATA =====================|80

CreatedByText db 'HUMAN CODED ASSEMBLY BY',0x0
KKJText db 'KRZYSZTOF KRYSTIAN JANKOWSKI',0x0
PressEnterText db 'PRESS ENTER', 0x0
MainMenuCopyText db '(MIT) 2025 P1X',0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in/assembly for more...', 0x0D, 0x0A, 0x0

Fontset1Text db ' !',34,'#$%&',39,'()*+,-./:;<=>?',0x0
Fontset2Text db '@ 0123456789',0x0
Fontset3Text db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0x0


HelpFooter1Text db '> PRESS ENTER FOR NEXT PAGE',0x0
HelpFooter2Text db '< PRESS ESC TO BACK TO MAIN MENU',0x0

HelpPage0Text:
  db 'CORTEX LABS - QUICK HELP!',0x0
  db ' ',0x0
  db '-------------------------------------',0x0
  db 'FOR FULL MANUAL CHECK @ FLOPPY IN DOS',0x0
  db 'READ > MANUAL.TXT < FILE',0x0
  db '-------------------------------------',0x0
  db ' ',0x0
  db 'TABLE OF CONTENT',0x0
  db '- GAME IDEA',0x0
  db '- BASE EXPANSION & BUILDINGS',0x0
  db '- RAILS MANAGEMENT',0x0
  db '- RESOURCES & UPGRADES',0x0
  db '- PAGE 5',0x0
  db '- PAGE 6',0x0
  db '- PAGE 7',0x0
  db 0x00

HelpPage1Text:
  db 'GAME IDEA',0x0
  db ' ',0x0
  db 'CORTEX LABS IS A STRATEGY PUZZLE GAME.',0x00
  db 'YOUR MISSION IS TO EXTRACT, REFINE,',0x0
  db 'AND RETURN RESOURCES ON OTHER PLANET.',0x0
  db '-------------------------------------',0x0
  db 0x00

HelpPage2Text:
  db 'BASE EXPANSION & BUILDINGS',0x0
  db ' ',0x0
  db 'PAGE 2 OF 7',0x0
  db 0x00

HelpPage3Text:
  db 'RAILS MANAGEMENT',0x0
  db ' ',0x0
  db 'PAGE 3 OF 7',0x0
  db 0x00

HelpPage4Text:
  db 'RESOURCES & UPGRADES',0x0
  db ' ',0x0
  db 'PAGE 4 OF 7',0x0
  db 0x00

HelpPage5Text:
db 'PAGE 5',0x0
db ' ',0x0
db 'PAGE 5 OF 7',0x0
db 0x00
HelpPage6Text:
db 'PAGE 6',0x0
db ' ',0x0
db 'PAGE 6 OF 7',0x0
db 0x00
HelpPage7Text:
  db 'PAGE 7',0x0
  db ' ',0x0
  db 'PAGE 7 OF 7',0x0
  db 0x00

HelpArrayText:
  dw HelpPage0Text
  dw HelpPage1Text
  dw HelpPage2Text
  dw HelpPage3Text
  dw HelpPage4Text
  dw HelpPage5Text
  dw HelpPage6Text
  dw HelpPage7Text

; =========================================== WINDOWS DEFINITIONS ===========|80

; height/width, Y/X, title, menu entry array, corresponding logic array
WindowDefinitionsArray:
dw 0x050A, 0x0C0A, WindowMainMenuText, MainMenuSelectionArrayText, MainMenuLogicArray
dw 0x080A, 0x040A, WindowBaseBuildingsText, WindowBaseSelectionArrayText, WindowBaseLogicArray
dw 0x040A, 0x0A0A, WindowRemoteBuildingsText, WindowRemoteSelectionArrayText, WindowRemoteLogicArray
dw 0x030A, 0x0A0A, WindowStationText, WindowStationSelectionArrayText, WindowStationLogicArray
dw 0x0409, 0x1015, WindowBriefingText, WindowBriefingSelectionArrayText, WindowBriefingLogicArray
dw 0x050F, 0x0A07, WindowPODsText, WindowPODSSelectionArrayText, WindowPODSSelectionArray


WindowMainMenuText          db 'MAIN MANU',0x0
MainMenuSelectionArrayText:
  db '> NEW GAME',0x0
  db '# PREVIEW TILESETS',0x0
  db '? QUICK HELP',0x0
  db '< QUIT',0x0
  db 0x00

MainMenuLogicArray:
  dw menu_logic.show_brief, 0x0
  dw menu_logic.tailset_preview, 0x0
  dw menu_logic.help, 0x0
  dw menu_logic.quit, 0x0

WindowBaseBuildingsText     db 'BASE BUILDING',0x0
WindowBaseSelectionArrayText:
  db '< CLOSE WINDOW',0x0
  db 'EXPAND BASE FOUNDATIONS',0x0
  db 'BUILD POD STATION',0x0
  db 'BUILD SILOS',0x0
  db 'BUILD RAFINERY',0x0
  db 'BUILD RADAR',0x0
  db 'BUIILD LABORATORY',0x0
  db 0x00
  WindowBaseLogicArray:
    dw menu_logic.close_window, 0x0
    dw actions_logic.expand_foundation, 0x0
    dw actions_logic.place_building, TILE_BUILDING_PODS_ID
    dw actions_logic.place_building, TILE_BUILDING_SILOS_ID
    dw actions_logic.place_building, TILE_BUILDING_RAFINERY_ID
    dw actions_logic.place_building, TILE_BUILDING_RADAR_ID
    dw actions_logic.place_building, TILE_BUILDING_LAB_ID

WindowRemoteBuildingsText   db 'REMOTE BUILDINGS',0x0
WindowRemoteSelectionArrayText:
  db '< CLOSE WINDOW',0x0
  db 'BUILD EXTRACTOR',0x0
  db 'BUILD RADAR',0x0
  db 0x00
WindowRemoteLogicArray:
  dw menu_logic.close_window, 0x0
  dw actions_logic.place_building, TILE_BUILDING_COLECTOR_ID
  dw actions_logic.place_building, TILE_BUILDING_RADAR_ID

WindowStationText           db 'STATION',0x0
WindowStationSelectionArrayText:
  db '< CLOSE WINDOW',0x0
  db 'BUILD STATION',0x0
  db 0x00
WindowStationLogicArray:
  dw menu_logic.close_window, 0x0
  dw actions_logic.place_station, 0x0

WindowMinimapText           db 'TERRAIN',0x0
WindowBriefingText           db 'BRIEFING',0x0
WindowBriefingSelectionArrayText:
  db '> ACCEPT MISSION',0x0
  db 'GENERATE NEW MAP',0x0
  db '< REJECT',0x0
  db 0x00
WindowBriefingLogicArray:
  dw menu_logic.start_game, 0x0
  dw new_game, 0x0
  dw menu_logic.back_to_menu, 0x0

WindowPODsText              db 'PODS RAFINERY',0x0
WindowPODSSelectionArrayText:
  db '< CLOSE WINDOW',0x0
  db 'BUILD STATION AT TARGET TILE',0x0
  db 'DEPLOY NEW POD AT STATION',0x0
  db 0x00
WindowPODSSelectionArray:
  dw menu_logic.close_window, 0x0
  dw actions_logic.build_pods_station, 0x0
  dw actions_logic.build_pod, 0x0

WindowInspectText              db 'BUILDING INSPECTION',0x0

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
db 7, 8, 8, 9   ; 8 Mountains/Rocks 1
db 9, 8, 8, 7   ; 9 Mountains/Rocks 2

TerrainColors:
db 0x4          ; Mud 1
db 0x4          ; Mud 2
db 0x4          ; Mud Grass 1
db 0x4          ; Mud Grass 2
db 0x4          ; Grass
db 0x4          ; Bush
db 0x5          ; Trees 1
db 0x5          ; Trees 2
db 0x5          ; Mountains/Rocks 1
db 0x5          ; Mountains/Rocks 2

; =========================================== DICTS =========================|80

RailroadsDict:
db 0, 0, 1, 4, 0, 0, 3, 9, 1, 6, 1, 10, 5, 7, 8, 2

; =========================================== INCLUDES ======================|80

include 'font.asm'
include 'sfx.asm'
include 'tiles.asm'
include 'img_p1x.asm'
include 'img_menu.asm'
include 'img_help.asm'
include 'img_title.asm'
include 'img_landing.asm'

; =========================================== THE END =======================|80
; Thanks for reading the source code!
; Visit http://smol.p1x.in/assembly/ for more.

BitLogo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary

; Label marking the end of all code and data
_END_OF_CODE_:
