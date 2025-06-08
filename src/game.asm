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
_INTERACTION_MODE_        equ _BASE_ + 0x0F   ; 1 byte
_ECONOMY_TRACKS_          equ _BASE_ + 0x10   ; 2 bytes
_ECONOMY_BLUE_RES_        equ _BASE_ + 0x12   ; 2 bytes
_ECONOMY_YELLOW_RES_      equ _BASE_ + 0x14   ; 2 bytes
_ECONOMY_RED_RES_         equ _BASE_ + 0x16   ; 2 bytes
_ECONOMY_SCORE_           equ _BASE_ + 0x18   ; 2 bytes

_TILES_                   equ _BASE_ + 0x0100  ; 64 tiles = 16K
_MAP_                     equ _BASE_ + 0x4100  ; Map data 128*128*1b= 0x4000
_METADATA_                equ _BASE_ + 0x8100  ; Map metadata 128*128*1b= 0x4000
_ENTITIES_                equ _BASE_ + 0xC100  ; Entities 128*128*1b= 0x4000

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
STATE_GENERATE_MAP      equ 13

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

; =========================================== TILES NAMES ===================|80

TILES_COUNT                     equ 0x40    ; 64 tiles
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

TILE_RIVER_1                    equ 0x0A
TILE_RIVER_2                    equ 0x0B
TILE_RIVER_3                    equ 0x0C
TILE_RIVER_4                    equ 0x0D
TILE_RIVER_5                    equ 0x0E
TILE_RIVER_6                    equ 0x0F
TILE_RIVER_7                    equ 0x10
TILE_RIVER_8                    equ 0x11

TILE_FOUNDATION                 equ 0x12
TILE_FOUNDATION_STATION_1       equ 0x13
TILE_FOUNDATION_STATION_2       equ 0x14

TILE_PLANT_YELLOW_1             equ 0x15
TILE_PLANT_YELLOW_2             equ 0x16
TILE_PLANT_BLUE_1               equ 0x17
TILE_PLANT_BLUE_2               equ 0x18
TILE_PLANT_RED_1                equ 0x19
TILE_PLANT_RED_2                equ 0x1A

TILE_CART_VERTICAL              equ 0x1B
TILE_CART_HORIZONTAl            equ 0x1C

TILE_RAILS_1                    equ 0x1D
TILE_RAILS_2                    equ 0x1E
TILE_RAILS_3                    equ 0x1F
TILE_RAILS_4                    equ 0x20
TILE_RAILS_5                    equ 0x21
TILE_RAILS_6                    equ 0x22
TILE_RAILS_7                    equ 0x23
TILE_RAILS_8                    equ 0x24
TILE_RAILS_9                    equ 0x25
TILE_RAILS_10                   equ 0x26
TILE_RAILS_11                   equ 0x27

TILE_BUILDING_BARRACK           equ 0x28
TILE_BUILDING_RAFINERY          equ 0x29
TILE_BUILDING_RADAR             equ 0x2A
TILE_BUILDING_ARM               equ 0x2B
TILE_BUILDING_EXTRACT           equ 0x2C
TILE_BUILDING_EXTRACT_BLUE      equ 0x2D
TILE_BUILDING_EXTRACT_YELLOW    equ 0x2E
TILE_BUILDING_EXTRACT_RED       equ 0x2F

TILE_ORE_BLUE                   equ 0x30
TILE_ORE_YELLOW                 equ 0x31
TILE_ORE_RED                    equ 0x32

TILE_SWITCH_LEFT                equ 0x33
TILE_SWITCH_DOWN                equ 0x34
TILE_SWITCH_RIGHT               equ 0x35
TILE_SWITCH_UP                  equ 0x36
TILE_SWITCH_STOP                equ 0x37

TILE_CURSOR_BUILD               equ 0x38
TILE_CURSOR_PAN                 equ 0x39
TILE_CURSOR_EDIT                equ 0x3A
TILE_CURSOR_REMOVE              equ 0x3B

META_TILES_MASK               equ 0x1F  ; 5 bits for sprite data (32 tiles max)
META_INVISIBLE_WALL           equ 0x20  ; For collision detection
META_TRANSPORT                equ 0x40  ; For railroads
META_FOG                      equ 0x80  ; Fog of War

METADATA_SWITCH_INITIALIZED          equ 0x01  ;
METADATA_SWITCH_MASK          equ 0x0C  ; For rails
METADATA_SWITCH_SHIFT         equ 0x02
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

MODE_VIEWPORT_PANNING         equ 0x00
MODE_INFRASTRUCTURE_PLACING   equ 0x01
MODE_INFRASTRUCTURE_EDIT      equ 0x02
MODE_INFRASTRUCTURE_REMOVE    equ 0x03

UI_POSITION                   equ 320*160
UI_FIRST_LINE                 equ 320*164
UI_LINES                      equ 40

DEFAULT_ECONOMY_TRACKS        equ 0x64

; =========================================== MISC SETTINGS =================|80

SCREEN_WIDTH                  equ 320
SCREEN_HEIGHT                 equ 200
MAP_SIZE                      equ 128     ; Map size in cells DO NOT CHANGE
VIEWPORT_WIDTH                equ 20      ; Size in tiles 20 = 320 pixels
VIEWPORT_HEIGHT               equ 10      ; by 10 = 192 pixels
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
  jmp word [StateJumpTable + bx]   ; Jump to handle

game_state_satisfied:

; =========================================== KEYBOARD INPUT ================|80

check_keyboard:
  mov ah, 01h         ; BIOS keyboard status function
  int 16h             ; Call BIOS interrupt
  jz .done

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

  cmp byte [_GAME_STATE_], STATE_GAME
  jne .done

  cmp byte [_INTERACTION_MODE_], MODE_VIEWPORT_PANNING
  je .viewport_panning_mode
  cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_PLACING
  je .interactive_mode
  cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_EDIT
  je .interactive_mode
  cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_REMOVE
  je .interactive_mode
  jmp .done

  .viewport_panning_mode:
    cmp ah, KB_UP
    je .move_viewport_up
    cmp ah, KB_DOWN
    je .move_viewport_down
    cmp ah, KB_LEFT
    je .move_viewport_left
    cmp ah, KB_RIGHT
    je .move_viewport_right
    cmp ah, KB_F2
    je .change_mode
  jmp .done

  .interactive_mode:
    cmp ah, KB_UP
    je .move_cursor_up
    cmp ah, KB_DOWN
    je .move_cursor_down
    cmp ah, KB_LEFT
    je .move_cursor_left
    cmp ah, KB_RIGHT
    je .move_cursor_right
    cmp ah, KB_SPACE
    je .do_interaction
    cmp ah, KB_F2
    je .change_mode
  jmp .done

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

  .change_mode:
    inc byte [_INTERACTION_MODE_]
    and byte [_INTERACTION_MODE_], 0x3  ; 0-3
    call draw_ui
    jmp .redraw_tile

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

  .do_interaction:
    ; if tracks building
    cmp word [_ECONOMY_TRACKS_], 0      ; check economy: track count
    jz .done

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

call stop_sound

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

StateTransitionTable:
    db STATE_TITLE_SCREEN, KB_ESC,   STATE_QUIT
    db STATE_TITLE_SCREEN, KB_ENTER, STATE_MENU_INIT
    db STATE_MENU,         KB_ESC,   STATE_QUIT
    db STATE_MENU,         KB_F1,    STATE_GAME_NEW
    db STATE_MENU,         KB_ENTER, STATE_GAME_INIT
    db STATE_MENU,         KB_F2,    STATE_DEBUG_VIEW_INIT
    db STATE_GAME,         KB_ESC,   STATE_MENU_INIT
    db STATE_GAME,         KB_TAB,   STATE_MAP_VIEW_INIT
    db STATE_MAP_VIEW,     KB_ESC,   STATE_MENU_INIT
    db STATE_MAP_VIEW,     KB_TAB,   STATE_GAME_INIT
    db STATE_DEBUG_VIEW,   KB_ESC,   STATE_MENU_INIT
StateTransitionTableEnd:

; ======================================= PROCEDURES FOR GAME STATES ========|80

init_engine:
  call reset_to_default_values
  call init_sound
  call decompress_tiles
  call generate_map
  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN_INIT

jmp game_state_satisfied

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
  mov si, start
  mov cx, 40*25
  .random_numbers:
    lodsb
    and ax, 0x1
    add al, 0x30
    mov ah, 0x0e
    mov bh, 0
    mov bl, COLOR_DARK_GRAY
    int 0x10
  loop .random_numbers

  mov si, WelcomeText
  mov dx, 0x140B
  mov bl, COLOR_WHITE
  call draw_text

  mov ax, 4560        ; Middle C frequency divisor
  call play_sound
  mov byte [_GAME_STATE_], STATE_TITLE_SCREEN
jmp game_state_satisfied

live_title_screen:
  mov si, PressEnterText
  mov dx, 0x1516
  mov bl, COLOR_WHITE
  test word [_GAME_TICK_], 0x4
  je .blink
    mov bl, COLOR_BLACK
  .blink:
  call draw_text

jmp game_state_satisfied

init_menu:
  mov al, COLOR_DEEP_PURPLE
  call clear_screen

  mov di, SCREEN_WIDTH*48
  mov al, COLOR_DEEP_PURPLE
  call draw_gradient

  mov si, MainMenuTitleText
  mov dx, 0x090A
  mov bl, COLOR_WHITE
  call draw_text

  mov si, MainMenuText
  mov dx, 0x0C01
  mov bl, COLOR_YELLOW
  call draw_text

  mov si, MainMenuCopyText
  mov dx, 0x140D
  mov bl, COLOR_LIGHT_GRAY
  call draw_text

  mov byte [_GAME_STATE_], STATE_MENU
jmp game_state_satisfied

live_menu:
  nop
jmp game_state_satisfied

new_game:
  call generate_map
  call reset_to_default_values

  mov byte [_GAME_STATE_], STATE_MENU_INIT

jmp game_state_satisfied

init_game:
  call draw_terrain
  call draw_entities
  call draw_cursor
  call draw_ui
  mov byte [_GAME_STATE_], STATE_GAME
jmp game_state_satisfied

live_game:
  nop
jmp game_state_satisfied

init_map_view:
  call draw_minimap
  mov byte [_GAME_STATE_], STATE_MAP_VIEW
jmp game_state_satisfied

live_map_view:
  nop
jmp game_state_satisfied

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
jmp game_state_satisfied

live_debug_view:
  nop
jmp game_state_satisfied


























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
  mov dl, al              ; Save connection pattern

  inc si
  mov bx, RailroadsList
  xlatb
  add al, TILE_RAILS_1  ; Shift to railroad tiles
  call draw_sprite

  cmp dl, 0x7
  je .draw_switch_lr
  cmp dl, 0xB
  je .draw_switch_ud
  cmp dl, 0x0D
  je .draw_switch_lr
  cmp dl, 0x0E
  je .draw_switch_ud
  jmp .done

  .draw_switch_lr:
    mov dl, 0   ; left
    mov dh, METADATA_SWITCH_INITIALIZED
    jmp .draw_switch
  .draw_switch_ud:
    mov dl, 1   ; down
    mov dh, 1+METADATA_SWITCH_INITIALIZED
  .draw_switch:
  push si
  sub si, _MAP_
  add si, _METADATA_
  mov al, [si]
  test al, METADATA_SWITCH_INITIALIZED
  jnz .switch_initialized
    and al, METADATA_SWITCH_MASK
    shr al, METADATA_SWITCH_SHIFT
    mov byte [si], dh
    mov al, dl
  jmp .draw_initialized_switch
  .switch_initialized:
  and al, METADATA_SWITCH_MASK
  shr al, METADATA_SWITCH_SHIFT
  .draw_initialized_switch:
  add al, TILE_SWITCH_LEFT
  pop si
  call draw_sprite
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


  cmp byte [_INTERACTION_MODE_], MODE_VIEWPORT_PANNING
  jz .panning_cursor
  cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_PLACING
  jz .placing_cursor
  cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_EDIT
  jz .edit_cursor
  cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_REMOVE
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

   cmp byte [_INTERACTION_MODE_], MODE_VIEWPORT_PANNING
   jz .panning_mode
   cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_PLACING
   jz .placing_mode
   cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_EDIT
   jz .edit_mode
   cmp byte [_INTERACTION_MODE_], MODE_INFRASTRUCTURE_REMOVE
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

init_sound:
   mov al, 182         ; Binary mode, square wave, 16-bit divisor
   out 43h, al         ; Write to PIT command register[2]
ret

play_sound:
   out 42h, al         ; Low byte first
   mov al, ah
   out 42h, al         ; High byte[2]

   in al, 61h          ; Read current port state
   or al, 00000011b    ; Set bits 0 and 1
   out 61h, al         ; Enable speaker output[2][3]
ret

stop_sound:
   in al, 61h
   and al, 11111100b   ; Clear bits 0-1
   out 61h, al
   ret










; =========================================== TEXT DATA =====================|80

WelcomeText db 'P1X ASSEMBLY ENGINE V12.02', 0x0
PressEnterText db 'PRESS ENTER', 0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in for more games..', 0x0D, 0x0A, 0x0
MainMenuTitleText db '"Mycelium Overlords"',0x0
MainMenuText db 'F1: New Map | ENTER: Play | ESC: Quit',0x0
MainMenuCopyText db '(C) 2025 P1X',0x0
FakeNumberText db '0000', 0x0
UIExploreModeText db 'F2: Explore Mode', 0x0
UIBuildModeText db 'F2: Build Mode', 0x0
UIEditModeText db 'F2: Edit Mode', 0x0
UIRemoveModeText db 'F2: Remove Mode', 0x0
UIScoreText db 'Score:', 0x0

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

include 'tiles.asm'

; =========================================== THE END =======================|80
; Thanks for reading the source code!
; Visit http://smol.p1x.in/assembly/ for more.

Logo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary
