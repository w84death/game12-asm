; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 968 bytes

help_image:
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 073h, 000h, 01Ah, 00Ah, 08Bh, 000h, 004h, 007h
    db 001h, 003h, 023h, 000h, 066h, 000h, 039h, 00Ah, 079h, 000h, 006h, 003h, 022h, 000h, 060h, 000h
    db 04Bh, 00Ah, 06Dh, 000h, 005h, 003h, 023h, 000h, 05Bh, 000h, 058h, 00Ah, 08Dh, 000h, 058h, 000h
    db 064h, 00Ah, 084h, 000h, 055h, 000h, 035h, 00Ah, 00Fh, 000h, 02Ah, 00Ah, 07Dh, 000h, 052h, 000h
    db 02Bh, 00Ah, 02Eh, 000h, 01Fh, 00Ah, 076h, 000h, 051h, 000h, 027h, 00Ah, 03Eh, 000h, 01Bh, 00Ah
    db 06Fh, 000h, 050h, 000h, 023h, 00Ah, 04Ch, 000h, 021h, 00Ah, 060h, 000h, 04Eh, 000h, 023h, 00Ah
    db 051h, 000h, 024h, 00Ah, 05Ah, 000h, 04Dh, 000h, 021h, 00Ah, 050h, 000h, 02Bh, 00Ah, 057h, 000h
    db 04Dh, 000h, 020h, 00Ah, 04Eh, 000h, 005h, 00Ah, 002h, 007h, 02Bh, 00Ah, 053h, 000h, 01Eh, 000h
    db 002h, 003h, 013h, 000h, 006h, 007h, 014h, 000h, 01Fh, 00Ah, 04Dh, 000h, 004h, 00Ah, 009h, 007h
    db 006h, 00Ah, 005h, 007h, 008h, 00Ah, 015h, 007h, 001h, 00Ah, 051h, 000h, 032h, 000h, 007h, 003h
    db 001h, 007h, 013h, 000h, 01Eh, 00Ah, 04Ch, 000h, 03Ah, 007h, 04Fh, 000h, 033h, 000h, 006h, 003h
    db 014h, 000h, 01Eh, 00Ah, 04Ah, 000h, 03Eh, 007h, 002h, 00Ah, 04Bh, 000h, 04Dh, 000h, 01Dh, 00Ah
    db 04Ah, 000h, 041h, 007h, 005h, 00Ah, 046h, 000h, 04Dh, 000h, 01Eh, 00Ah, 047h, 000h, 045h, 007h
    db 007h, 00Ah, 042h, 000h, 04Dh, 000h, 01Eh, 00Ah, 02Dh, 000h, 002h, 003h, 017h, 000h, 047h, 007h
    db 00Ah, 00Ah, 03Eh, 000h, 04Eh, 000h, 01Dh, 00Ah, 046h, 000h, 048h, 007h, 00Dh, 00Ah, 03Ah, 000h
    db 04Fh, 000h, 01Dh, 00Ah, 044h, 000h, 003h, 007h, 001h, 003h, 046h, 007h, 010h, 00Ah, 036h, 000h
    db 050h, 000h, 01Dh, 00Ah, 042h, 000h, 003h, 007h, 003h, 003h, 045h, 007h, 001h, 003h, 003h, 000h
    db 00Fh, 00Ah, 033h, 000h, 051h, 000h, 01Dh, 00Ah, 041h, 000h, 001h, 003h, 001h, 007h, 007h, 003h
    db 009h, 007h, 003h, 003h, 022h, 007h, 015h, 003h, 007h, 000h, 00Fh, 00Ah, 02Fh, 000h, 052h, 000h
    db 01Dh, 00Ah, 03Fh, 000h, 00Ch, 003h, 006h, 007h, 007h, 003h, 009h, 007h, 002h, 003h, 00Ah, 007h
    db 020h, 003h, 009h, 000h, 00Fh, 00Ah, 02Ch, 000h, 053h, 000h, 01Dh, 00Ah, 03Eh, 000h, 00Eh, 003h
    db 003h, 007h, 00Bh, 003h, 004h, 007h, 02Eh, 003h, 00Ch, 000h, 010h, 00Ah, 028h, 000h, 054h, 000h
    db 01Dh, 00Ah, 03Ch, 000h, 04Fh, 003h, 010h, 000h, 00Fh, 00Ah, 025h, 000h, 056h, 000h, 01Dh, 00Ah
    db 03Ah, 000h, 04Fh, 003h, 013h, 000h, 00Fh, 00Ah, 022h, 000h, 057h, 000h, 01Eh, 00Ah, 038h, 000h
    db 04Fh, 003h, 016h, 000h, 00Fh, 00Ah, 01Fh, 000h, 059h, 000h, 01Eh, 00Ah, 036h, 000h, 04Fh, 003h
    db 019h, 000h, 00Fh, 00Ah, 01Ch, 000h, 05Bh, 000h, 01Dh, 00Ah, 035h, 000h, 04Fh, 003h, 01Ch, 000h
    db 00Fh, 00Ah, 019h, 000h, 05Ch, 000h, 01Eh, 00Ah, 033h, 000h, 04Fh, 003h, 01Eh, 000h, 010h, 00Ah
    db 016h, 000h, 05Eh, 000h, 01Eh, 00Ah, 031h, 000h, 04Eh, 003h, 022h, 000h, 010h, 00Ah, 013h, 000h
    db 060h, 000h, 01Fh, 00Ah, 02Fh, 000h, 04Dh, 003h, 024h, 000h, 011h, 00Ah, 010h, 000h, 062h, 000h
    db 01Fh, 00Ah, 02Dh, 000h, 04Dh, 003h, 027h, 000h, 010h, 00Ah, 00Eh, 000h, 064h, 000h, 020h, 00Ah
    db 02Bh, 000h, 04Bh, 003h, 02Ah, 000h, 010h, 00Ah, 00Ch, 000h, 053h, 000h, 001h, 003h, 002h, 00Ah
    db 011h, 000h, 01Fh, 00Ah, 029h, 000h, 04Ah, 003h, 02Dh, 000h, 011h, 00Ah, 009h, 000h, 054h, 000h
    db 002h, 003h, 013h, 000h, 020h, 00Ah, 027h, 000h, 048h, 003h, 030h, 000h, 011h, 00Ah, 007h, 000h
    db 06Bh, 000h, 020h, 00Ah, 026h, 000h, 046h, 003h, 033h, 000h, 012h, 00Ah, 004h, 000h, 06Eh, 000h
    db 020h, 00Ah, 025h, 000h, 043h, 003h, 036h, 000h, 012h, 00Ah, 002h, 000h, 070h, 000h, 022h, 00Ah
    db 022h, 000h, 041h, 003h, 038h, 000h, 013h, 00Ah, 073h, 000h, 022h, 00Ah, 021h, 000h, 03Eh, 003h
    db 03Bh, 000h, 011h, 00Ah, 075h, 000h, 023h, 00Ah, 01Fh, 000h, 03Bh, 003h, 03Eh, 000h, 010h, 00Ah
    db 079h, 000h, 022h, 00Ah, 01Eh, 000h, 037h, 003h, 042h, 000h, 00Eh, 00Ah, 07Ch, 000h, 023h, 00Ah
    db 01Dh, 000h, 032h, 003h, 045h, 000h, 00Dh, 00Ah, 07Fh, 000h, 023h, 00Ah, 01Dh, 000h, 02Ch, 003h
    db 049h, 000h, 00Ch, 00Ah, 082h, 000h, 025h, 00Ah, 01Bh, 000h, 025h, 003h, 04Eh, 000h, 00Bh, 00Ah
    db 085h, 000h, 026h, 00Ah, 01Bh, 000h, 01Ch, 003h, 053h, 000h, 00Bh, 00Ah, 088h, 000h, 027h, 00Ah
    db 01Fh, 000h, 00Bh, 003h, 05Dh, 000h, 00Ah, 00Ah, 08Bh, 000h, 028h, 00Ah, 083h, 000h, 00Ah, 00Ah
    db 050h, 000h, 001h, 003h, 002h, 00Ah, 03Ch, 000h, 028h, 00Ah, 080h, 000h, 009h, 00Ah, 051h, 000h
    db 001h, 003h, 041h, 000h, 029h, 00Ah, 07Ah, 000h, 00Ah, 00Ah, 097h, 000h, 02Bh, 00Ah, 074h, 000h
    db 00Ah, 00Ah, 09Bh, 000h, 02Ch, 00Ah, 06Eh, 000h, 00Bh, 00Ah, 09Fh, 000h, 02Dh, 00Ah, 068h, 000h
    db 00Ch, 00Ah, 0A3h, 000h, 02Fh, 00Ah, 060h, 000h, 00Eh, 00Ah, 0A7h, 000h, 033h, 00Ah, 056h, 000h
    db 010h, 00Ah, 0ABh, 000h, 036h, 00Ah, 04Dh, 000h, 012h, 00Ah, 0AFh, 000h, 039h, 00Ah, 042h, 000h
    db 016h, 00Ah, 0B5h, 000h, 03Fh, 00Ah, 031h, 000h, 01Bh, 00Ah, 0BAh, 000h, 048h, 00Ah, 017h, 000h
    db 027h, 00Ah, 0BFh, 000h, 081h, 00Ah, 0C4h, 000h, 07Ch, 00Ah, 0CAh, 000h, 076h, 00Ah, 0CFh, 000h
    db 071h, 00Ah, 0D7h, 000h, 069h, 00Ah, 0DEh, 000h, 062h, 00Ah, 0E5h, 000h, 05Bh, 00Ah, 0ECh, 000h
    db 054h, 00Ah, 09Fh, 000h, 002h, 00Ah, 056h, 000h, 048h, 00Ah, 001h, 000h, 09Fh, 000h, 002h, 003h
    db 062h, 000h, 034h, 00Ah, 009h, 000h, 0FFh, 000h, 01Bh, 000h, 011h, 00Ah, 015h, 000h, 02Bh, 000h
    db 005h, 00Ah, 0FFh, 000h, 011h, 000h, 02Ah, 000h, 004h, 007h, 003h, 003h, 0FFh, 000h, 010h, 000h
    db 02Bh, 000h, 005h, 003h, 0E4h, 000h, 004h, 00Ah, 028h, 000h, 0FFh, 000h, 014h, 000h, 005h, 007h
    db 001h, 003h, 027h, 000h, 0FFh, 000h, 015h, 000h, 005h, 003h, 027h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h

help_scr_size equ 968
help_scr_end:
