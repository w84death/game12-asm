; P1X FAT12-compatible Bootloader for GAME-12
; This bootloader preserves FAT12 BPB for DOS compatibility
; and loads game code from the first data sectors
; Copyright (C) 2025 Krzysztof Krystian Jankowski
; This program is free software. See LICENSE for details.

org 0x7C00
use16

GAME_SIZE_KB          equ 0x10          ; Size of the game in KB
SECTORS_TO_LOAD       equ GAME_SIZE_KB*2 ; Sectors to load (512 byte chunks)
GAME_STACK_POINTER    equ 0xFFFE        ; Stack pointer for the game
GAME_SEGMENT          equ 0x1000        ; Segment where game is loaded
GAME_OFFSET           equ 0x0100        ; Offset where game is loaded
DATA_START_SECTOR     equ 33            ; First data sector in FAT12 (after boot + FATs + root dir)

; Jump over BPB ================================================================
jmp short boot_start
nop

; FAT12 BIOS Parameter Block (BPB) ============================================
; This must be preserved for DOS compatibility
OEMLabel        db "P1X     "           ; 8 bytes
BytesPerSector  dw 512
SectorsPerCluster db 1
ReservedSectors dw 1
NumberOfFATs    db 2
RootDirEntries  dw 224
TotalSectors    dw 2880
MediaDescriptor db 0xF0                 ; 3.5" floppy
SectorsPerFAT   dw 9
SectorsPerTrack dw 18
NumberOfHeads   dw 2
HiddenSectors   dd 0
LargeSectors    dd 0
DriveNumber     db 0
Reserved        db 0
BootSignature   db 0x29
VolumeSerial    dd 0x12345678
VolumeLabel     db "GAME-12    "        ; 11 bytes
FileSystem      db "FAT12   "           ; 8 bytes

; Start of the bootloader ======================================================
boot_start:
  cli                                   ; Disable interrupts
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00                        ; Stack grows down from bootloader

  mov [DriveNumber], dl                 ; Save boot drive reported by BIOS

  mov ah, 0x00                          ; Set video mode
  mov al, 0x03                          ; 80x25 color text mode
  int 0x10

  mov si, welcome_msg
  call boot_print_str

; Load game from data area =====================================================
boot_load_game:
  mov si, loading_msg
  call boot_print_str

  ; Reset disk system
  .reset_disk:
  mov ah, 0x00                          ; Reset disk system function
  mov dl, [DriveNumber]                 ; Drive number
  int 0x13                              ; Reset disk system
  jc boot_disk_reset_error

  ; Set up destination for game code
  mov ax, GAME_SEGMENT
  mov es, ax
  mov bx, GAME_OFFSET                   ; ES:BX = destination

  ; Calculate CHS from LBA sector 33 (first data sector)
  ; For standard 1.44MB floppy: 18 sectors/track, 2 heads, 80 cylinders
  ; LBA = (C * Heads * SectorsPerTrack) + (H * SectorsPerTrack) + (S - 1)
  ; Sector 33: C=0, H=1, S=16 (sectors are 1-based)

  mov ah, 0x02                          ; BIOS read sectors function
  mov al, SECTORS_TO_LOAD               ; Number of sectors to read
  mov ch, 0                             ; Cylinder 0 (low 8 bits)
  mov cl, 16                            ; Sector 16 (sectors are 1-based)
  mov dh, 1                             ; Head 1
  mov dl, [DriveNumber]                 ; Drive number

  int 0x13                              ; BIOS disk interrupt
  jc boot_game_error                    ; Error if carry flag set

  cmp al, SECTORS_TO_LOAD
  jb boot_sector_count_error            ; Fewer sectors read than expected
  jmp boot_game_success

; Disk reset error =============================================================
boot_disk_reset_error:
  mov si, reset_err_msg
  call boot_print_str
  jmp boot_error_recovery

; Sector count error ===========================================================
boot_sector_count_error:
  mov si, count_err_msg
  call boot_print_str
  jmp boot_error_recovery

; Disk error ===================================================================
boot_game_error:
  mov si, disk_err_msg
  call boot_print_str
  jmp boot_error_recovery

; Error recovery ===============================================================
boot_error_recovery:
  mov si, retry_msg
  call boot_print_str

  xor ax, ax
  int 0x16                              ; Wait for key press
  jmp boot_load_game                    ; Try again

; Game loaded successfully =====================================================
boot_game_success:
  mov si, done_msg
  call boot_print_str

  mov si, jump_msg
  call boot_print_str

  ; Pass drive number to game in DL register
  mov dl, [DriveNumber]

  ; Set up segments and stack for game
  mov ax, GAME_SEGMENT
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, GAME_STACK_POINTER

  ; Jump to game
  jmp GAME_SEGMENT:GAME_OFFSET

; Print character ==============================================================
boot_print_chr:
  push ax
  mov ah, 0x0E                          ; BIOS teletype output
  int 0x10
  pop ax
  ret

; Print string =================================================================
boot_print_str:
  push ax
  mov ah, 0x0E                          ; BIOS teletype output
  .next_char:
    lodsb                               ; Load next character
    or al, al                           ; Check for null terminator
    jz .done
    int 0x10
    jmp .next_char
  .done:
  pop ax
  ret

; Messages =====================================================================
welcome_msg     db 'P1X FAT12 Bootloader v1.0', 0x0D, 0x0A, 0
loading_msg     db 'Loading GAME-12...', 0x0D, 0x0A, 0
disk_err_msg    db 'Disk read error!', 0x0D, 0x0A, 0
reset_err_msg   db 'Disk reset error!', 0x0D, 0x0A, 0
count_err_msg   db 'Sector count error!', 0x0D, 0x0A, 0
retry_msg       db 'Press any key to retry...', 0x0D, 0x0A, 0
done_msg        db 'Game loaded.', 0x0D, 0x0A, 0
jump_msg        db 'Starting...', 0x0D, 0x0A, 0

; Boot signature ===============================================================
times 510 - ($ - $$) db 0              ; Pad to 510 bytes
dw 0xAA55                               ; Boot signature
