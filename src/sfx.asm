; =========================================== ENHANCED NOTE TABLE ============|80
; Fully precomputed frequency divisors for all notes from C2 to B7
; Formula: divisor = 1193180 / frequency_hz

NoteTable:
  dw 0xFFFF      ; 0: REST (silence)
  ; Octave 2
  dw 0x4698      ; 1: C2  (65.41 Hz)
  dw 0x3F1D      ; 2: C#2 (69.30 Hz)
  dw 0x38FF      ; 3: D2  (73.42 Hz)
  dw 0x33A1      ; 4: D#2 (77.78 Hz)
  dw 0x2F01      ; 5: E2  (82.41 Hz)
  dw 0x2A0F      ; 6: F2  (87.31 Hz)
  dw 0x25C7      ; 7: F#2 (92.50 Hz)
  dw 0x221B      ; 8: G2  (98.00 Hz)
  dw 0x1F02      ; 9: G#2 (103.83 Hz)
  dw 0x1C70      ; 10: A2  (110.00 Hz)
  dw 0x1A52      ; 11: A#2 (116.54 Hz)
  dw 0x189F      ; 12: B2  (123.47 Hz)
  ; Octave 3
  dw 0x234C      ; 13: C3  (130.81 Hz)
  dw 0x1F8F      ; 14: C#3 (138.59 Hz)
  dw 0x1C80      ; 15: D3  (146.83 Hz)
  dw 0x19D1      ; 16: D#3 (155.56 Hz)
  dw 0x1781      ; 17: E3  (164.81 Hz)
  dw 0x1508      ; 18: F3  (174.61 Hz)
  dw 0x12E4      ; 19: F#3 (185.00 Hz)
  dw 0x110E      ; 20: G3  (196.00 Hz)
  dw 0x0F81      ; 21: G#3 (207.65 Hz)
  dw 0x0E38      ; 22: A3  (220.00 Hz)
  dw 0x0D29      ; 23: A#3 (233.08 Hz)
  dw 0x0C50      ; 24: B3  (246.94 Hz)
  ; Octave 4
  dw 0x11A6      ; 25: C4  (261.63 Hz)
  dw 0x0FC8      ; 26: C#4 (277.18 Hz)
  dw 0x0E40      ; 27: D4  (293.66 Hz)
  dw 0x0CE9      ; 28: D#4 (311.13 Hz)
  dw 0x0BC1      ; 29: E4  (329.63 Hz)
  dw 0x0A84      ; 30: F4  (349.23 Hz)
  dw 0x0972      ; 31: F#4 (369.99 Hz)
  dw 0x0887      ; 32: G4  (392.00 Hz)
  dw 0x07C1      ; 33: G#4 (415.30 Hz)
  dw 0x071C      ; 34: A4  (440.00 Hz)
  dw 0x0695      ; 35: A#4 (466.16 Hz)
  dw 0x0628      ; 36: B4  (493.88 Hz)
  ; Octave 5
  dw 0x08D3      ; 37: C5  (523.25 Hz)
  dw 0x07E4      ; 38: C#5 (554.37 Hz)
  dw 0x0720      ; 39: D5  (587.33 Hz)
  dw 0x0675      ; 40: D#5 (622.25 Hz)
  dw 0x05E1      ; 41: E5  (659.25 Hz)
  dw 0x0542      ; 42: F5  (698.46 Hz)
  dw 0x04B9      ; 43: F#5 (739.99 Hz)
  dw 0x0444      ; 44: G5  (783.99 Hz)
  dw 0x03E1      ; 45: G#5 (830.61 Hz)
  dw 0x038E      ; 46: A5  (880.00 Hz)
  dw 0x034B      ; 47: A#5 (932.33 Hz)
  dw 0x0314      ; 48: B5  (987.77 Hz)
  ; Octave 6
  dw 0x046A      ; 49: C6  (1046.50 Hz)
  dw 0x03F2      ; 50: C#6 (1108.73 Hz)
  dw 0x0390      ; 51: D6  (1174.66 Hz)
  dw 0x033B      ; 52: D#6 (1244.51 Hz)
  dw 0x02F1      ; 53: E6  (1318.51 Hz)
  dw 0x02A1      ; 54: F6  (1396.91 Hz)
  dw 0x025D      ; 55: F#6 (1479.98 Hz)
  dw 0x0222      ; 56: G6  (1567.98 Hz)
  dw 0x01F1      ; 57: G#6 (1661.22 Hz)
  dw 0x01C7      ; 58: A6  (1760.00 Hz)
  dw 0x01A6      ; 59: A#6 (1864.66 Hz)
  dw 0x018A      ; 60: B6  (1975.53 Hz)
  ; Octave 7
  dw 0x0235      ; 61: C7  (2093.00 Hz)
  dw 0x01F9      ; 62: C#7 (2217.46 Hz)
  dw 0x01C8      ; 63: D7  (2349.32 Hz)

; Enhanced note name constants for all octaves
NOTE_REST     equ 0
; Octave 2
NOTE_C2       equ 1
NOTE_CS2      equ 2
NOTE_D2       equ 3
NOTE_DS2      equ 4
NOTE_E2       equ 5
NOTE_F2       equ 6
NOTE_FS2      equ 7
NOTE_G2       equ 8
NOTE_GS2      equ 9
NOTE_A2       equ 10
NOTE_AS2      equ 11
NOTE_B2       equ 12
; Octave 3
NOTE_C3       equ 13
NOTE_CS3      equ 14
NOTE_D3       equ 15
NOTE_DS3      equ 16
NOTE_E3       equ 17
NOTE_F3       equ 18
NOTE_FS3      equ 19
NOTE_G3       equ 20
NOTE_GS3      equ 21
NOTE_A3       equ 22
NOTE_AS3      equ 23
NOTE_B3       equ 24
; Octave 4
NOTE_C4       equ 25
NOTE_CS4      equ 26
NOTE_D4       equ 27
NOTE_DS4      equ 28
NOTE_E4       equ 29
NOTE_F4       equ 30
NOTE_FS4      equ 31
NOTE_G4       equ 32
NOTE_GS4      equ 33
NOTE_A4       equ 34
NOTE_AS4      equ 35
NOTE_B4       equ 36
; Octave 5
NOTE_C5       equ 37
NOTE_CS5      equ 38
NOTE_D5       equ 39
NOTE_DS5      equ 40
NOTE_E5       equ 41
NOTE_F5       equ 42
NOTE_FS5      equ 43
NOTE_G5       equ 44
NOTE_GS5      equ 45
NOTE_A5       equ 46
NOTE_AS5      equ 47
NOTE_B5       equ 48
; Octave 6
NOTE_C6       equ 49
NOTE_CS6      equ 50
NOTE_D6       equ 51
NOTE_DS6      equ 52
NOTE_E6       equ 53
NOTE_F6       equ 54
NOTE_FS6      equ 55
NOTE_G6       equ 56
NOTE_GS6      equ 57
NOTE_A6       equ 58
NOTE_AS6      equ 59
NOTE_B6       equ 60
; Octave 7
NOTE_C7       equ 61
NOTE_CS7      equ 62
NOTE_D7       equ 63

; Enhanced sound effects with new note range
SFX_NULL:
  db 0x0

INTRO_JINGLE:
  db NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5
  db NOTE_G4, NOTE_E4, NOTE_C4
  db 0x0

SFX_MENU_ENTER:
  db NOTE_C5, NOTE_E5, NOTE_G5
  db 0x0

SFX_MENU_DOWN:
  db NOTE_C6, NOTE_C3
  db 0x0

SFX_MENU_UP:
  db NOTE_C3, NOTE_C6
  db 0x0

SFX_COLLECT:
  db NOTE_C5, NOTE_D5, NOTE_E5, NOTE_G5
  db 0x0

SFX_BUILD:
  db NOTE_C4, NOTE_F4, NOTE_A4
  db 0x0

SFX_ERROR:
  db NOTE_F3, NOTE_E3, NOTE_DS3
  db 0x0

SFX_POWERUP:
  db NOTE_C4, NOTE_G4, NOTE_C5, NOTE_G5, NOTE_C6
  db 0x0

SFX_EXPLOSION:
  db NOTE_B2, NOTE_G2, NOTE_E2, NOTE_C2
  db 0x0
