; P1X Bootlader for a GAME-12
; It is a simple bootloader that loads the game code from disk and jumps to it.
; Copyright (C) 2025 Krzysztof Krystian Jankowski
; This program is free software. See LICENSE for details.

org 0x7C00
use16

GAME_SIZE_KB          equ 0x20          ; Size of the game in KB
SECTORS_TO_LOAD       equ GAME_SIZE_KB*2    ; Sectors to load (512KB chunks)
GAME_STACK_POINTER    equ 0xFFFE        ; Stack pointer for the game
GAME_SEGMENT          equ 0x1000        ; Segment where game is loaded
GAME_OFFSET           equ 0x0100        ; Offset where game is loaded

; Start of the bootloader ======================================================
; This is the entry point of the bootloader.
; Expects: None
; Returns: None
boot_start:
  cli                                   ; Disable interrupts
  xor ax, ax
  mov ds, ax
  mov es, ax

  mov [floppy_drive_number], dl         ; Sace boot drive reported by BIOS

	mov ah, 0x00		                      ; Set video mode
	mov al, 0x00                          ; Set to default text mode
	int 0x10

	mov si, welcome_msg
  call boot_print_str

; Load game ==================================================================
; This function loads the game from disk into memory.
; Expects: None
; Returns: None
boot_load_game:
  mov si, loading_msg
  call boot_print_str

  .reset_disk_system:
  mov ah, 0x00                          ; Reset disk system function
  mov dl, [floppy_drive_number]         ; Drive number
  int 0x13                              ; Reset disk system
  jc boot_disk_reset_error

  mov ax, GAME_SEGMENT
  mov es, ax
  mov bx, GAME_OFFSET                   ; Offset where code will be loaded

  .setup_disk_read_parameters:
  mov ah, 0x02                          ; BIOS read sectors function
  mov al, SECTORS_TO_LOAD
  mov ch, 0                             ; Cylinder 0
  mov cl, 2                             ; Start from sector 2
  mov dh, 0                             ; Head 0
  mov dl, [floppy_drive_number]         ; Drive reported by BIOS (dl register)

  int 0x13                              ; BIOS disk interrupt
  jc boot_game_error                    ; Error if carry flag set

  cmp al, SECTORS_TO_LOAD
  jb boot_sector_count_error            ; Fewer sectors read than expected
  jmp boot_game_success

; Disk reset error =============================================================
; This function handles disk reset errors.
; Expects: None
; Returns: None
boot_disk_reset_error:
  mov si, reset_err_msg
  call boot_print_str
  jmp boot_error_recovery

; Sector count error ===========================================================
; This function handles sector count errors.
; Expects: None
; Returns: None
boot_sector_count_error:
  mov si, count_err_msg
  call boot_print_str
  jmp boot_error_recovery

; Disk error ===================================================================
; This function handles disk read errors.
; Expects: None
; Returns: None
boot_game_error:
  mov si, disk_read_error_msg
  call boot_print_str
  jmp boot_error_recovery

; Error recovery ===============================================================
; Common handler for disk errors
; Expects: None
; Returns: None
boot_error_recovery:
  mov si, floppy_drive_msg
  call boot_print_str
  mov al, [floppy_drive_number]
  add ax, '0'
  call boot_print_chr

  mov si, again_msg
  call boot_print_str

  xor ax, ax
  int 0x16                              ; Wait for key press
  jmp boot_load_game                    ; Try again
ret

; Kernel loaded successfully ===================================================
; This function is called after the game is loaded successfully.
; Expects: None
; Returns: None
boot_game_success:
  mov si, done_msg
  call boot_print_str

  ; Give visual indicator we're about to jump to game
  mov si, game_jump_msg
  call boot_print_str

  ; Pass drive number to game in DL register
  mov dl, [floppy_drive_number]

  ; Set up stack before jumping to game
  mov ax, GAME_SEGMENT
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, GAME_STACK_POINTER

  jmp GAME_SEGMENT:GAME_OFFSET

; Print character ==============================================================
; This function prints a character to the screen.
; Expects: AL = character to print
; Returns: None
boot_print_chr:
  push ax
  mov ah, 0x0e                          ; BIOS teletype output function
  int 0x10                              ; BIOS teletype output function
  pop ax
ret

; Print string =================================================================
; This function prints a string to the screen.
; Expects: DS:SI = pointer to string
; Returns: None
boot_print_str:
  mov ah, 0x0e                          ; BIOS teletype output function
  .next_char:
    lodsb                               ; Load next character from SI into AL
    or al, al                           ; Check for null terminator
    jz .terminated
    int 0x10                            ; BIOS video interrupt
  jmp near .next_char
  .terminated:
ret

; Print statements =============================================================
welcome_msg db          'P1X Bootloader Version 0.3',0x0A,0x0D,0x0
loading_msg db          'Loading game code... ',0x0A,0x0D,0x0
disk_read_error_msg db  '<!> Disk read error.',0x0A,0x0D,0x0
reset_err_msg db        '<!> Disk reset error.',0x0A,0x0D,0x0
count_err_msg db        '<!> Disk sector count error.',0x0A,0x0D,0x0
done_msg db             '\o/ Success.',0x0A,0x0D,0x0
again_msg db        0x0A,0x0D,'<*> Press any key to try again.', 0x0A, 0x0D, 0x0
game_jump_msg db        'Booting game code...',0x0A,0x0D,0x0
floppy_drive_msg db     'Floppy drive number: ',0x0
floppy_drive_number db  0x00

; Bootloader signature =========================================================
times 507 - ($ - $$) db 0               ; Pad to 510 bytes
db "P1X"                                ; P1X signature
dw 0xAA55                               ; Boot signature
