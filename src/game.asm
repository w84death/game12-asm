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
; ==============================================================================
; Latest revision: 06/2025
; ==============================================================================

org 0x0000

; =========================================== MEMORY ALLOCATION =============|80

_BASE_                    equ 0x2000          ; Memory base address
_GAME_TICK_               equ _BASE_ + 0x00   ; 2 bytes
_GAME_STATE_              equ _BASE_ + 0x02   ; 1 byte
_RNG_                     equ _BASE_ + 0x03   ; 2 bytes
_VIEWPORT_X_              equ _BASE_ + 0x05   ; 2 bytes
_VIEWPORT_Y_              equ _BASE_ + 0x07   ; 2 bytes
_CURSOR_X_                equ _BASE_ + 0x09   ; 2 bytes
_CURSOR_Y_                equ _BASE_ + 0x0B   ; 2 bytes
_INTERACTION_MODE_        equ _BASE_ + 0x0D   ; 1 byte
_ECONOMY_TRACKS_          equ _BASE_ + 0x0E   ; 2 bytes
_ECONOMY_BLUE_RES_        equ _BASE_ + 0x10   ; 2 bytes
_ECONOMY_YELLOW_RES_      equ _BASE_ + 0x12   ; 2 bytes
_ECONOMY_RED_RES_         equ _BASE_ + 0x14   ; 2 bytes
_ECONOMY_SCORE_           equ _BASE_ + 0x16   ; 2 bytes

; 25b free to use

_TILES_                   equ _BASE_ + 0x20    ; 40 tiles = 10K = 0x2800
_MAP_                     equ _BASE_ + 0x4820  ; Map data 128*128*1b= 0x4000
_METADATA_                equ _BASE_ + 0x8820  ; Map metadata 128*128*1b= 0x4000
_ENTITIES_                equ _BASE_ + 0xC820  ; Entities 128*128*1b= 0x4000
; 35.6K

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
TILE_RAILS_12                   equ 0x28

TILE_BUILDING_1                 equ 0x29
TILE_BUILDING_2                 equ 0x2A
TILE_BUILDING_3                 equ 0x2B
TILE_BUILDING_4                 equ 0x2C
TILE_BUILDING_5                 equ 0x2D
TILE_BUILDING_5_BLUE            equ 0x2E
TILE_BUILDING_5_YELLOW          equ 0x2F
TILE_BUILDING_5_RED             equ 0x30

TILE_ORE_BLUE                   equ 0x31
TILE_ORE_YELLOW                 equ 0x32
TILE_ORE_RED                    equ 0x33

TILE_SWITCH_1                   equ 0x34
TILE_SWITCH_2                   equ 0x35
TILE_SWITCH_3                   equ 0x36
TILE_SWITCH_4                   equ 0x37
TILE_SWITCH_5                   equ 0x38

TILE_CURSOR_1                   equ 0x39
TILE_CURSOR_2                   equ 0x3A
TILE_CURSOR_3                   equ 0x3B
TILE_CURSOR_4                   equ 0x3C

TILE_BUILDING_EXTRACTOR       equ 19

TILE_RESOURCE_BLUE            equ 29
TILE_RESOURCE_YELLOW          equ 30
TILE_RESOURCE_RED             equ 31

TILE_RAILROADS                equ 10
CURSOR_NORMAL                 equ 22
CURSOR_BUILD                  equ 21


META_TILES_MASK                 equ 0x1F

META_INVISIBLE_WALL           equ 0x20    ; For collision detection
META_TRANSPORT                equ 0x40    ; For railroads
META_SWITCH                   equ 0x80     ; Railroad switch

META_EMPTY                    equ 0x0
META_TRAIN                    equ 0x1
META_EMPTY_CART               equ 0x2
ENTITY_META_CART              equ 0x4
ENTITY_META_RESOURCE_BLUE     equ 0x8
ENTITY_META_RESOURCE_YELLOW   equ 0x10
ENTITY_META_RESOURCE_RED      equ 0x20

MODE_VIEWPORT_PANNING         equ 0
MODE_TRACKS_PLACING           equ 1
MODE_FOUNDATION_PLACING       equ 2
MODE_BUILDING_CONSTRUCTION    equ 3

UI_POSITION                   Equ 320*160
UI_FIRST_LINE                 equ 320*164
UI_LINES                      equ 40

DEFAULT_ECONOMY_TRACKS        equ 0x64

; =========================================== MISC SETTINGS =================|80

SCREEN_WIDTH         equ 320
SCREEN_HEIGHT        equ 200
MAP_SIZE             equ 128     ; Map size in cells DO NOT CHANGE
VIEWPORT_WIDTH       equ 20      ; Full screen 320
VIEWPORT_HEIGHT      equ 10      ; by 192 pixels
VIEWPORT_GRID_SIZE   equ 16      ; Individual cell size DO NOT CHANGE
SPRITE_SIZE          equ 16      ; Sprite size 16x16

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
   mov ax, 0x13         ; Init 320x200, 256 colors mode
   int 0x10             ; Video BIOS interrupt

   mov ax, 0xA000       ; VGA memory segment
   mov es, ax           ; Set ES to VGA memory segment
   xor di, di           ; Set DI to 0

   mov ax, 0x9000
   mov ss, ax           ; Set stack segment to 0x9000
   mov sp, 0xFFFF       ; Set stack pointer to 0xFFFF

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
   je .viewport_panning
   cmp byte [_INTERACTION_MODE_], MODE_TRACKS_PLACING
   je .tracks_building
   jmp .done

   .viewport_panning:
      cmp ah, KB_UP
      je .move_viewport_up
      cmp ah, KB_DOWN
      je .move_viewport_down
      cmp ah, KB_LEFT
      je .move_viewport_left
      cmp ah, KB_RIGHT
      je .move_viewport_right
      cmp ah, KB_F2
      je .swap_mode
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

   .tracks_building:
      cmp ah, KB_UP
      je .move_cursor_up
      cmp ah, KB_DOWN
      je .move_cursor_down
      cmp ah, KB_LEFT
      je .move_cursor_left
      cmp ah, KB_RIGHT
      je .move_cursor_right
      cmp ah, KB_SPACE
      je .construct_railroad
      cmp ah, KB_F2
      je .swap_mode
   jmp .done

   .swap_mode:
      xor byte [_INTERACTION_MODE_], 0x1
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

   .construct_railroad:

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

wait_for_tick:
   xor ax, ax           ; Function 00h: Read system timer counter
   int 0x1a             ; Returns tick count in CX:DX
   mov bx, dx           ; Store the current tick count
   .wait_loop:
      int 0x1a          ; Read the tick count again
      cmp dx, bx
      je .wait_loop     ; Loop until the tick count changes

call stop_sound
inc word [_GAME_TICK_]  ; Increment game tick

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
   ; call init_entities
   call init_gameplay_elements

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
   ; call init_entities
   call init_gameplay_elements
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

   mov di, 320*16+16
   xor ax, ax
   mov cx, (TilesCompressedEnd-TilesCompressed)/2
   .spr:
      call draw_sprite
      inc ax
      mov bx, ax
      and bx, 0x7
      cmp bx, 0
      jne .skip_new_line
         add di, 320*SPRITE_SIZE-SPRITE_SIZE*8
      .skip_new_line:
      add di, 16
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

; =========================================== GENERATE MAP ==================|80
generate_map:
   mov di, _MAP_
   mov si, TerrainRules
   mov cx, MAP_SIZE

   .next_row:
      mov dx, MAP_SIZE
      .next_cell:
         cmp dx, MAP_SIZE
         jne .not_first
            call get_random
            and ax, 0x3
            mov [di], al
            jmp .check_top
         .not_first:

         .check_left:
         movzx bx, [di-1]
         shl bx, 2
         call get_random
         and ax, 0x3
         add bx, ax
         mov al, [si+bx]
         mov [di], al            ; Save terrain tile ID

         cmp cx, MAP_SIZE
         je .skip_first_row
         .check_top:
         movzx bx, [di-MAP_SIZE]
         shl bx, 2
         call get_random
         and ax, 0x3
         add bx, ax
         mov bl, [si+bx]

         call get_random
         test ax, 0x1
         jnz .skip_first_row
         mov [di], bl            ; Save terrain tile ID
         mov al, bl
         .skip_first_row:

         inc di
         dec dx
      jnz .next_cell
   loop .next_row

   .set_metata:
   mov di, _MAP_
   mov si, di
   mov cx, MAP_SIZE*MAP_SIZE
   .meta_next_cell:
         lodsb

         .check_invisible_walls:
         cmp al, TILE_MOUNTAINS_1
         je .set_wall
         cmp al, TILE_MOUNTAINS_2
         je .set_wall
         cmp al, TILE_TREES_1
         je .set_wall
         cmp al, TILE_TREES_2
         je .set_wall
         cmp al, TILE_BUSH

         jmp .skip_invisible_walls

         .set_wall:
            add al, META_INVISIBLE_WALL
         .skip_invisible_walls:

         stosb
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
         jz .skip_draw_transport
            call draw_transport
         .skip_draw_transport:

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
   test bl, META_TRANSPORT
   jz .skip_draw_transport
      call draw_transport
   .skip_draw_transport:
ret


draw_transport:
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
   inc si
   mov bx, RailroadsList
   xlatb
   add al, TILE_RAILROADS  ; Shift to railroad tiles
   call draw_sprite
ret

; =========================================== DECOMPRESS SPRITE ============|80
; IN: SI - Compressed sprite data
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
         mov byte [_TILES_+di], bl  ; Write pixel color
         inc di           ; Move destination to next pixel
      loop .draw_pixel

   pop cx                   ; Restore line counter
   loop .plot_line
ret

; =========================================== DECOMPRESS TILES ============|80
; OUT: Tiles decompressed to _TILES_
decompress_tiles:
   xor di, di
   mov si, Tiles
   .decompress_next:
      cmp byte [si], 0xFF
      jz .done

      call decompress_sprite
      add di, SPRITE_SIZE*SPRITE_SIZE
   jmp .decompress_next
   .done:
ret

; =========================================== DRAW TILE =====================|80
; IN: SI - Tile data
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
   shl ax, 8         ; Multiply by 256 (tile size in array)
   mov si, _TILES_   ; Point to tile data
   add si, ax        ; Point to sprite data
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
         add ax, 0x7          ; Skip ground tiles id's
         call draw_sprite

      .check_if_cart:
         lodsb                ; Load META data
         test al, ENTITY_META_CART
         jz .next_entity

         test al, ENTITY_META_RESOURCE_BLUE
         jnz .draw_blue_cart
         test al, ENTITY_META_RESOURCE_YELLOW
         jnz .draw_yellow_cart
         test al, ENTITY_META_RESOURCE_RED
         jnz .draw_red_cart
         jmp .next_entity

         .draw_yellow_cart:
            mov al, TILE_RESOURCE_YELLOW
            call draw_sprite
            jmp .next_entity

         .draw_blue_cart:
            mov al, TILE_RESOURCE_BLUE
            call draw_sprite
            jmp .next_entity

         .draw_red_cart:
            mov al, TILE_RESOURCE_RED
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

   mov al, CURSOR_NORMAL
   cmp byte [_INTERACTION_MODE_], MODE_TRACKS_PLACING
   jne .skip_build_cursor
      mov al, CURSOR_BUILD
   .skip_build_cursor:


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

init_gameplay_elements:
   mov di, _MAP_ + 128*64+64
   mov cx, 8
   .add_meta:
      and byte [di], 3
      add byte [di], META_TRANSPORT
      inc di
   loop .add_meta
   mov byte [di-MAP_SIZE-8], TILE_MUD_1+META_TRANSPORT
   mov byte [di-MAP_SIZE*2-8], TILE_MUD_1+META_TRANSPORT
   mov byte [di+MAP_SIZE-2], TILE_MUD_2+META_TRANSPORT
   mov byte [di+MAP_SIZE*2-2], TILE_MUD_1+META_TRANSPORT


   mov di, _MAP_ + 128*63+66
   mov cx, 6
   .add_meta2:
      mov byte [di], TILE_FOUNDATION
      inc di
   loop .add_meta2

   mov di, _MAP_ + 128*64+66
   mov cx, 4
   .add_meta3:
      mov byte [di], TILE_FOUNDATION_STATION_2+META_TRANSPORT
      inc di
   loop .add_meta3

   mov di, _MAP_ + 128*64+65
   mov byte [di], TILE_FOUNDATION_STATION_2+META_TRANSPORT

   mov di, _ENTITIES_
   mov word [di], 0x4042 ; 64x64
   mov byte [di+2], TILE_CART_HORIZONTAl
   mov byte [di+3], META_EMPTY_CART

   add di, 4
   mov word [di], 0x4043
   mov byte [di+2], TILE_CART_HORIZONTAl
   mov byte [di+3], META_EMPTY_CART+ENTITY_META_CART+ENTITY_META_RESOURCE_BLUE

   add di, 4
   mov word [di], 0x4044
   mov byte [di+2], TILE_CART_HORIZONTAl
   mov byte [di+3], META_EMPTY_CART+ENTITY_META_CART+ENTITY_META_RESOURCE_YELLOW

   add di, 4
   mov word [di], 0x4045
   mov byte [di+2], TILE_CART_HORIZONTAl
   mov byte [di+3], META_EMPTY_CART+ENTITY_META_CART+ENTITY_META_RESOURCE_RED


   ; add di, 4
   ; mov word [di], 0x3F44 ; 64x64
   ; mov byte [di+2], TILE_BUILDING_1
   ; mov byte [di+3], META_EMPTY
   ; add di, 4
   ; mov word [di], 0x3F45 ; 64x64
   ; mov byte [di+2], TILE_BUILDING_2
   ; mov byte [di+3], META_EMPTY
   ; add di, 4
   ; mov word [di], 0x3F47 ; 64x64
   ; mov byte [di+2], TILE_BUILDING_3
   ; mov byte [di+3], META_EMPTY
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
   mov al, TILE_RAILROADS+10  ; Crossing
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
   mov al, TILE_RESOURCE_BLUE
   call draw_sprite

   mov si, [_ECONOMY_BLUE_RES_]  ; Blue resource count
   mov dx, 0x0150C
   mov bl, COLOR_WHITE
   call draw_number

   mov di, UI_FIRST_LINE+140
   mov al, TILE_RESOURCE_YELLOW
   call draw_sprite

   mov si, [_ECONOMY_YELLOW_RES_]  ; Yellow resource count
   mov dx, 0x01514
   mov bl, COLOR_WHITE
   call draw_number

   mov di, UI_FIRST_LINE+204
   mov al, TILE_RESOURCE_RED
   call draw_sprite

   mov si, [_ECONOMY_RED_RES_]  ; Red resource count
   mov dx, 0x0151C
   mov bl, COLOR_WHITE
   call draw_number

   mov si, UIExploreModeText
   cmp byte [_INTERACTION_MODE_], MODE_TRACKS_PLACING
   jne .skip_build_mode
      mov si, UIBuildModeText
   .skip_build_mode:
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

init_sound:
   mov al, 182         ; Binary mode, square wave, 16-bit divisor
   out 43h, al         ; Write to PIT command register[2]
ret

play_sound:
   mov ax, 4560        ; Middle C frequency divisor
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











; ==============================================================================
;
; DATA SECTION
;
; ==============================================================================

WelcomeText db 'P1X ASSEMBLY ENGINE V12.02', 0x0
PressEnterText db 'PRESS ENTER', 0x0
QuitText db 'Thanks for playing!',0x0D,0x0A,'Visit http://smol.p1x.in for more games..', 0x0D, 0x0A, 0x0
MainMenuTitleText db '"Mycelium Overlords"',0x0
MainMenuText db 'F1: New Map | ENTER: Play | ESC: Quit',0x0
MainMenuCopyText db '(C) 2025 P1X',0x0
FakeNumberText db '0000', 0x0
UIBuildModeText db 'F2: Build Mode', 0x0
UIExploreModeText db 'F2: Explore Mode', 0x0
UIScoreText db 'Score:', 0x0

AudioSamples:
db 0x80, 0x8C, 0x98, 0xA4, 0xAF, 0xB9, 0xC1, 0xC7
db 0xCB, 0xCD, 0xCC, 0xC9, 0xC4, 0xBD, 0xB3, 0xA8
db 0x9C, 0x8F, 0x83, 0x77, 0x6D, 0x65, 0x5F, 0x5B
db 0x5A, 0x5B, 0x5F, 0x65, 0x6D, 0x77, 0x83, 0x8F
db 0x9C, 0xA8, 0xB3, 0xBD, 0xC4, 0xC9, 0xCC, 0xCD
db 0xCB, 0xC7, 0xC1, 0xB9, 0xAF, 0xA4, 0x98, 0x8C
db 0x80, 0x74, 0x68, 0x5C, 0x51, 0x47, 0x3F, 0x39
db 0x35, 0x33, 0x34, 0x37, 0x3C, 0x43, 0x4D, 0x58
db 0x64, 0x71, 0x7D, 0x89, 0x93, 0x9B, 0xA1, 0xA5
db 0xA6, 0xA5, 0xA1, 0x9B, 0x93, 0x89, 0x7D, 0x71
db 0x64, 0x58, 0x4D, 0x43, 0x3C, 0x37, 0x34, 0x33
db 0x35, 0x39, 0x3F, 0x47, 0x51, 0x5C, 0x68, 0x74

; =========================================== TERRAIN GEN RULES =============|80

TerrainRules:
db 0, 1, 1, 1  ; Swamp
db 0, 1, 2, 2  ; Mud
db 1, 2, 2, 3  ; Some Grass
db 2, 3, 3, 4  ; Dense Grass
db 2, 3, 4, 5  ; Bush
db 4, 5, 5, 6  ; Tree
db 5, 5, 5, 6  ; Mountain

TerrainColors:
db 0x4         ; Swamp
db 0x4         ; Mud
db 0x4         ; Some Grass
db 0x5         ; Dense Grass
db 0x5         ; Bush
db 0x5         ; Forest
db 0xA         ; Mountain

; =========================================== TILES =========================|80

RailroadsList:
db 1, 1, 5, 0
db 1, 1, 2, 3
db 5, 4, 5, 6
db 7, 8, 9, 10, 11

TilesCompressed:

TilesCompressedEnd:

include 'tiles.asm'

; =========================================== THE END =======================|80
; Thanks for reading the source code!
; Visit http://smol.p1x.in/assembly/ for more.

Logo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary
