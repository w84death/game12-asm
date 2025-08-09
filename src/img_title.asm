; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 1194 bytes

title_image:
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 02Eh, 000h, 001h, 003h, 012h, 000h
    db 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h
    db 0FFh, 000h, 041h, 000h, 020h, 000h, 003h, 003h, 0FFh, 000h, 01Eh, 000h, 04Fh, 000h, 003h, 00Ah
    db 0EEh, 000h, 046h, 000h, 006h, 00Ah, 005h, 000h, 004h, 00Ah, 0EBh, 000h, 043h, 000h, 005h, 007h
    db 001h, 00Ah, 003h, 007h, 006h, 000h, 002h, 00Ah, 0ECh, 000h, 041h, 000h, 001h, 00Ah, 002h, 003h
    db 002h, 007h, 003h, 003h, 004h, 007h, 004h, 000h, 002h, 00Ah, 0ADh, 000h, 003h, 003h, 03Dh, 000h
    db 03Eh, 000h, 002h, 00Ah, 002h, 000h, 008h, 003h, 001h, 007h, 002h, 003h, 002h, 000h, 002h, 00Ah
    db 0B0h, 000h, 001h, 003h, 03Eh, 000h, 03Ch, 000h, 002h, 00Ah, 005h, 000h, 009h, 003h, 002h, 00Ah
    db 0F2h, 000h, 03Bh, 000h, 002h, 00Ah, 007h, 000h, 005h, 003h, 002h, 00Ah, 0F5h, 000h, 03Ah, 000h
    db 004h, 00Ah, 006h, 000h, 003h, 00Ah, 0F9h, 000h, 03Ch, 000h, 005h, 00Ah, 0FFh, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h
    db 041h, 000h, 0FFh, 000h, 041h, 000h, 0FFh, 000h, 041h, 000h, 01Ah, 000h, 003h, 00Ch, 001h, 00Eh
    db 0F8h, 000h, 002h, 00Ah, 001h, 007h, 027h, 000h, 019h, 000h, 007h, 00Ch, 0F4h, 000h, 007h, 007h
    db 025h, 000h, 018h, 000h, 00Ah, 00Ch, 001h, 00Eh, 0F1h, 000h, 007h, 003h, 025h, 000h, 018h, 000h
    db 002h, 00Eh, 00Ah, 00Ch, 001h, 00Eh, 0F1h, 000h, 004h, 003h, 026h, 000h, 015h, 000h, 009h, 00Eh
    db 009h, 00Ch, 0FFh, 000h, 01Ah, 000h, 00Ah, 000h, 004h, 00Ch, 004h, 000h, 010h, 00Eh, 005h, 00Ch
    db 002h, 001h, 0FFh, 000h, 018h, 000h, 009h, 000h, 00Ch, 00Ch, 011h, 00Eh, 004h, 001h, 0FFh, 000h
    db 017h, 000h, 008h, 000h, 011h, 00Ch, 012h, 00Eh, 0FFh, 000h, 016h, 000h, 007h, 000h, 016h, 00Ch
    db 012h, 00Eh, 0FFh, 000h, 012h, 000h, 00Bh, 000h, 010h, 00Ch, 002h, 001h, 004h, 00Ch, 012h, 00Eh
    db 0FFh, 000h, 00Eh, 000h, 00Ch, 000h, 00Eh, 00Ch, 002h, 001h, 009h, 00Ch, 012h, 00Eh, 0FFh, 000h
    db 00Ah, 000h, 00Ch, 000h, 003h, 001h, 00Ah, 00Ch, 002h, 001h, 00Fh, 00Ch, 011h, 00Eh, 0FFh, 000h
    db 006h, 000h, 00Ch, 000h, 007h, 001h, 005h, 00Ch, 002h, 001h, 014h, 00Ch, 012h, 00Eh, 0FFh, 000h
    db 001h, 000h, 00Ch, 000h, 00Bh, 001h, 01Bh, 00Ch, 011h, 00Eh, 0FDh, 000h, 00Bh, 000h, 010h, 001h
    db 01Bh, 00Ch, 010h, 00Eh, 0FAh, 000h, 00Ah, 000h, 002h, 00Ch, 013h, 001h, 01Bh, 00Ch, 00Fh, 00Eh
    db 0AAh, 000h, 015h, 00Dh, 038h, 000h, 009h, 000h, 007h, 00Ch, 013h, 001h, 01Bh, 00Ch, 00Dh, 00Eh
    db 0A0h, 000h, 030h, 00Dh, 025h, 000h, 008h, 000h, 00Ch, 00Ch, 013h, 001h, 01Ah, 00Ch, 00Bh, 00Eh
    db 098h, 000h, 001h, 008h, 03Dh, 00Dh, 01Eh, 000h, 006h, 000h, 012h, 00Ch, 014h, 001h, 018h, 00Ch
    db 009h, 00Eh, 093h, 000h, 007h, 008h, 007h, 007h, 03Ah, 00Dh, 018h, 000h, 00Bh, 000h, 005h, 001h
    db 008h, 00Ch, 018h, 001h, 016h, 00Ch, 008h, 00Eh, 08Eh, 000h, 007h, 008h, 00Dh, 007h, 024h, 00Dh
    db 01Ah, 008h, 012h, 000h, 016h, 000h, 005h, 001h, 005h, 000h, 014h, 001h, 015h, 00Ch, 006h, 00Eh
    db 089h, 000h, 007h, 008h, 014h, 007h, 01Ah, 00Dh, 024h, 008h, 00Fh, 000h, 025h, 000h, 013h, 001h
    db 013h, 00Ch, 006h, 00Eh, 083h, 000h, 007h, 008h, 01Ah, 007h, 010h, 00Dh, 02Fh, 008h, 00Ch, 000h
    db 029h, 000h, 015h, 001h, 010h, 00Ch, 004h, 00Eh, 07Fh, 000h, 006h, 008h, 01Eh, 007h, 002h, 004h
    db 007h, 00Dh, 039h, 008h, 009h, 000h, 02Dh, 000h, 018h, 001h, 00Bh, 00Ch, 001h, 00Eh, 002h, 00Ch
    db 07Bh, 000h, 005h, 008h, 01Eh, 007h, 006h, 004h, 043h, 008h, 006h, 000h, 031h, 000h, 01Ch, 001h
    db 005h, 00Ch, 07Ah, 000h, 006h, 008h, 01Bh, 007h, 006h, 004h, 04Ah, 008h, 003h, 000h, 035h, 000h
    db 01Ah, 001h, 002h, 00Ch, 078h, 000h, 00Ah, 008h, 016h, 007h, 006h, 004h, 051h, 008h, 039h, 000h
    db 010h, 001h, 07Eh, 000h, 00Dh, 008h, 011h, 007h, 006h, 004h, 03Fh, 008h, 001h, 004h, 015h, 00Bh
    db 0C4h, 000h, 010h, 008h, 00Dh, 007h, 006h, 004h, 044h, 008h, 002h, 004h, 013h, 00Bh, 01Bh, 000h
    db 001h, 007h, 002h, 003h, 0A5h, 000h, 012h, 008h, 008h, 007h, 006h, 004h, 04Ah, 008h, 001h, 004h
    db 012h, 00Bh, 0C1h, 000h, 001h, 002h, 014h, 008h, 003h, 007h, 006h, 004h, 050h, 008h, 001h, 004h
    db 010h, 00Bh, 0C0h, 000h, 001h, 002h, 014h, 008h, 001h, 00Bh, 005h, 004h, 055h, 008h, 002h, 004h
    db 00Eh, 00Bh, 0BEh, 000h, 002h, 002h, 013h, 008h, 004h, 00Bh, 001h, 005h, 02Ah, 008h, 004h, 00Bh
    db 02Ch, 008h, 001h, 004h, 00Dh, 00Bh, 0BCh, 000h, 003h, 002h, 011h, 008h, 008h, 00Bh, 026h, 008h
    db 00Ah, 00Bh, 02Bh, 008h, 002h, 004h, 00Bh, 00Bh, 0BBh, 000h, 004h, 002h, 00Eh, 008h, 00Ch, 00Bh
    db 021h, 008h, 00Fh, 00Bh, 02Ch, 008h, 002h, 004h, 009h, 00Bh, 0BAh, 000h, 004h, 002h, 00Dh, 008h
    db 00Fh, 00Bh, 01Ch, 008h, 014h, 00Bh, 02Dh, 008h, 001h, 004h, 008h, 00Bh, 0B9h, 000h, 005h, 002h
    db 00Ah, 008h, 013h, 00Bh, 017h, 008h, 01Ah, 00Bh, 02Ch, 008h, 002h, 004h, 006h, 00Bh, 0B7h, 000h
    db 007h, 002h, 007h, 008h, 016h, 00Bh, 001h, 005h, 012h, 008h, 01Fh, 00Bh, 02Dh, 008h, 002h, 004h
    db 004h, 00Bh, 0B6h, 000h, 008h, 002h, 005h, 008h, 019h, 00Bh, 001h, 005h, 00Dh, 008h, 024h, 00Bh
    db 02Eh, 008h, 001h, 00Bh, 003h, 004h, 0B5h, 000h, 008h, 002h, 003h, 008h, 01Dh, 00Bh, 001h, 005h
    db 008h, 008h, 02Ah, 00Bh, 026h, 008h, 008h, 00Bh, 002h, 008h, 0B4h, 000h, 009h, 002h, 021h, 00Bh
    db 004h, 008h, 02Fh, 00Bh, 01Eh, 008h, 010h, 00Bh, 001h, 008h, 0B3h, 000h, 008h, 002h, 057h, 00Bh
    db 016h, 008h, 018h, 00Bh, 0B2h, 000h, 00Ah, 002h, 058h, 00Bh, 00Eh, 008h, 01Eh, 00Bh, 0B1h, 000h
    db 00Bh, 002h, 059h, 00Bh, 006h, 008h, 025h, 00Bh, 0B1h, 000h, 00Bh, 002h, 084h, 00Bh, 0B0h, 000h
    db 00Dh, 002h, 083h, 00Bh, 0B0h, 000h, 00Dh, 002h, 083h, 00Bh, 0AFh, 000h, 00Eh, 002h, 083h, 00Bh
    db 0AFh, 000h, 00Fh, 002h, 082h, 00Bh, 0AEh, 000h, 010h, 002h, 082h, 00Bh, 039h, 000h, 001h, 007h
    db 001h, 003h, 073h, 000h, 010h, 002h, 082h, 00Bh, 0ADh, 000h, 011h, 002h, 082h, 00Bh, 035h, 000h
    db 004h, 00Ah, 074h, 000h, 012h, 002h, 081h, 00Bh, 034h, 000h, 003h, 007h, 003h, 003h, 073h, 000h
    db 011h, 002h, 001h, 005h, 081h, 00Bh, 034h, 000h, 005h, 003h, 073h, 000h, 010h, 002h, 004h, 005h
    db 080h, 00Bh, 0ACh, 000h, 00Eh, 002h, 007h, 005h, 028h, 00Bh, 004h, 005h, 053h, 00Bh, 0ABh, 000h
    db 00Eh, 002h, 009h, 005h, 024h, 00Bh, 008h, 005h, 04Eh, 00Bh, 004h, 004h, 0ABh, 000h, 00Ch, 002h
    db 00Bh, 005h, 021h, 00Bh, 00Ch, 005h, 047h, 00Bh, 006h, 004h, 004h, 002h, 0AAh, 000h, 00Bh, 002h
    db 00Eh, 005h, 01Eh, 00Bh, 00Fh, 005h, 040h, 00Bh, 006h, 004h, 00Ah, 002h, 0AAh, 000h, 00Ah, 002h
    db 010h, 005h, 01Ah, 00Bh, 013h, 005h, 039h, 00Bh, 006h, 004h, 010h, 002h, 0AAh, 000h, 008h, 002h
    db 013h, 005h, 016h, 00Bh, 017h, 005h, 033h, 00Bh, 003h, 005h, 002h, 004h, 016h, 002h, 0AAh, 000h
    db 006h, 002h, 015h, 005h, 013h, 00Bh, 01Ch, 005h, 02Dh, 00Bh, 008h, 005h, 017h, 002h, 0AAh, 000h
    db 004h, 002h, 018h, 005h, 00Fh, 00Bh, 020h, 005h, 027h, 00Bh, 00Eh, 005h, 016h, 002h, 0AAh, 000h
    db 003h, 002h, 01Ah, 005h, 00Bh, 00Bh, 024h, 005h, 022h, 00Bh, 012h, 005h, 016h, 002h, 0AAh, 000h
    db 003h, 002h, 01Ah, 005h, 008h, 00Bh, 028h, 005h, 01Dh, 00Bh, 017h, 005h, 015h, 002h, 0AAh, 000h
    db 003h, 002h, 01Bh, 005h, 004h, 00Bh, 02Ch, 005h, 018h, 00Bh, 01Ch, 005h, 014h, 002h, 0AAh, 000h
    db 004h, 002h, 04Bh, 005h, 013h, 00Bh, 021h, 005h, 013h, 002h, 0AAh, 000h, 005h, 002h, 018h, 005h
    db 003h, 004h, 030h, 005h, 00Eh, 00Bh, 026h, 005h, 012h, 002h

title_image_size equ 1194
title_image_end:
