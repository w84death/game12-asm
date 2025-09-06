; Note values are frequency divisors for the PC speaker
; Formula: divisor = 1193180 / frequency_hz
NoteDict:
  dw 0xFFFF      ; ID 1: REST (silence)
  dw 0x2394      ; ID 2: NOTE_C3  (130.81 Hz)
  dw 0x1F8F      ; ID 4: NOTE_D3  (146.83 Hz)
  dw 0x1BD0      ; ID 6: NOTE_E3  (164.81 Hz)
  dw 0x1A07      ; ID 7: NOTE_F3  (174.61 Hz)
  dw 0x169E      ; ID 9: NOTE_G3  (196.00 Hz))
  dw 0x1365      ; ID 11: NOTE_A3  (220.00 Hz)
  dw 0x1056      ; ID 13: NOTE_B3  (246.94 Hz)
  dw 0x11CA      ; ID 14: NOTE_C4  (261.63 Hz)
  dw 0x0FC8      ; ID 16: NOTE_D4  (293.66 Hz)
  dw 0x0DE8      ; ID 18: NOTE_E4  (329.63 Hz)
  dw 0x0D04      ; ID 19: NOTE_F4  (349.23 Hz)
  dw 0x0B4F      ; ID 21: NOTE_G4  (392.00 Hz)
  dw 0x09B3      ; ID 23: NOTE_A4  (440.00 Hz)
  dw 0x082B      ; ID 25: NOTE_B4  (493.88 Hz)
  dw 0x08E5      ; ID 26: NOTE_C5  (523.25 Hz)
  dw 0x07E4      ; ID 28: NOTE_D5  (587.33 Hz)
  dw 0x06F4      ; ID 30: NOTE_E5  (659.25 Hz)
  dw 0x0682      ; ID 31: NOTE_F5  (698.46 Hz)
  dw 0x05A8      ; ID 33: NOTE_G5  (783.99 Hz)
  dw 0x04D9      ; ID 35: NOTE_A5  (880.00 Hz)
  dw 0x0416      ; ID 37: NOTE_B5  (987.77 Hz)
  dw 0x0473      ; ID 38: NOTE_C6  (1046.50 Hz)

SFX_NULL:
  db 0x0

INTRO_JINGLE:
  db NOTE_A3
  db 0x0

SFX_MENU_ENTER:
  db NOTE_C5
  db NOTE_E5
  db NOTE_G5
  db 0x0

SFX_MENU_DOWN:
  db NOTE_C6
  db NOTE_C3
  db 0x0

SFX_MENU_UP:
  db NOTE_C3
  db NOTE_C6
  db 0x0


SFX_COLLECT:
  db NOTE_C5
  db NOTE_E5
  db NOTE_G5
  db 0x0

SFX_BUILD:
  db NOTE_C4
  db NOTE_F4
  db NOTE_A4
  db 0x0

SFX_ERROR:
  db NOTE_F3
  db NOTE_E3
  db 0x0
