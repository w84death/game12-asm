; Compressed VGA image data (interlaced)
; Format: [run_length][color_index] pairs
; Contains only even lines (0, 2, 4...), no EOL markers
; Assembly code should render each line twice
; Total size: 1342 bytes

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
    db 017h, 000h, 008h, 000h, 011h, 00Ch, 012h, 00Eh, 0C1h, 000h, 01Ah, 00Dh, 03Ah, 000h, 007h, 000h
    db 016h, 00Ch, 012h, 00Eh, 0B7h, 000h, 003h, 008h, 010h, 00Dh, 008h, 008h, 00Ch, 00Dh, 001h, 008h
    db 032h, 000h, 00Bh, 000h, 010h, 00Ch, 002h, 001h, 004h, 00Ch, 012h, 00Eh, 0ADh, 000h, 006h, 008h
    db 009h, 00Dh, 024h, 008h, 001h, 00Dh, 001h, 008h, 003h, 000h, 004h, 00Bh, 024h, 000h, 00Ch, 000h
    db 00Eh, 00Ch, 002h, 001h, 009h, 00Ch, 012h, 00Eh, 0A3h, 000h, 009h, 008h, 001h, 00Dh, 036h, 008h
    db 006h, 00Bh, 020h, 000h, 00Ch, 000h, 003h, 001h, 00Ah, 00Ch, 002h, 001h, 00Fh, 00Ch, 011h, 00Eh
    db 09Ah, 000h, 049h, 008h, 006h, 00Bh, 01Ch, 000h, 00Ch, 000h, 007h, 001h, 005h, 00Ch, 002h, 001h
    db 014h, 00Ch, 012h, 00Eh, 093h, 000h, 04Fh, 008h, 006h, 00Bh, 018h, 000h, 00Ch, 000h, 00Bh, 001h
    db 01Bh, 00Ch, 011h, 00Eh, 08Dh, 000h, 023h, 008h, 01Dh, 007h, 016h, 008h, 006h, 00Bh, 014h, 000h
    db 00Bh, 000h, 010h, 001h, 01Bh, 00Ch, 010h, 00Eh, 087h, 000h, 025h, 008h, 020h, 007h, 018h, 008h
    db 004h, 00Bh, 012h, 000h, 00Ah, 000h, 002h, 00Ch, 013h, 001h, 01Bh, 00Ch, 00Fh, 00Eh, 082h, 000h
    db 026h, 008h, 023h, 007h, 012h, 008h, 002h, 005h, 008h, 00Bh, 010h, 000h, 009h, 000h, 007h, 00Ch
    db 013h, 001h, 01Bh, 00Ch, 00Dh, 00Eh, 07Dh, 000h, 028h, 008h, 026h, 007h, 010h, 008h, 004h, 005h
    db 008h, 00Bh, 00Eh, 000h, 008h, 000h, 00Ch, 00Ch, 013h, 001h, 01Ah, 00Ch, 00Bh, 00Eh, 079h, 000h
    db 02Ah, 008h, 029h, 007h, 010h, 008h, 003h, 005h, 009h, 00Bh, 00Ch, 000h, 006h, 000h, 012h, 00Ch
    db 014h, 001h, 018h, 00Ch, 009h, 00Eh, 076h, 000h, 02Bh, 008h, 02Ch, 007h, 00Fh, 008h, 004h, 005h
    db 009h, 00Bh, 00Ah, 000h, 00Bh, 000h, 005h, 001h, 008h, 00Ch, 018h, 001h, 016h, 00Ch, 008h, 00Eh
    db 073h, 000h, 02Ch, 008h, 02Fh, 007h, 00Eh, 008h, 004h, 005h, 00Ah, 00Bh, 008h, 000h, 016h, 000h
    db 005h, 001h, 005h, 000h, 014h, 001h, 015h, 00Ch, 006h, 00Eh, 071h, 000h, 02Ch, 008h, 017h, 007h
    db 009h, 00Bh, 012h, 007h, 00Eh, 008h, 004h, 005h, 00Bh, 00Bh, 005h, 000h, 025h, 000h, 013h, 001h
    db 013h, 00Ch, 006h, 00Eh, 06Dh, 000h, 001h, 002h, 02Dh, 008h, 008h, 007h, 02Bh, 00Bh, 00Eh, 008h
    db 004h, 005h, 00Ch, 00Bh, 003h, 000h, 029h, 000h, 015h, 001h, 010h, 00Ch, 004h, 00Eh, 06Bh, 000h
    db 001h, 002h, 02Bh, 008h, 035h, 00Bh, 002h, 002h, 00Fh, 008h, 004h, 005h, 00Bh, 00Bh, 002h, 000h
    db 02Dh, 000h, 018h, 001h, 00Bh, 00Ch, 001h, 00Eh, 002h, 00Ch, 068h, 000h, 002h, 002h, 025h, 008h
    db 03Bh, 00Bh, 005h, 002h, 00Eh, 008h, 002h, 005h, 00Dh, 00Bh, 001h, 000h, 031h, 000h, 01Ch, 001h
    db 005h, 00Ch, 068h, 000h, 002h, 002h, 020h, 008h, 041h, 00Bh, 007h, 002h, 00Dh, 008h, 00Fh, 00Bh
    db 035h, 000h, 01Ah, 001h, 002h, 00Ch, 067h, 000h, 019h, 002h, 005h, 008h, 046h, 00Bh, 009h, 002h
    db 00Ch, 008h, 00Fh, 00Bh, 039h, 000h, 010h, 001h, 06Eh, 000h, 01Dh, 002h, 047h, 00Bh, 00Ch, 002h
    db 009h, 008h, 010h, 00Bh, 0B6h, 000h, 01Dh, 002h, 047h, 00Bh, 001h, 004h, 00Dh, 002h, 008h, 008h
    db 010h, 00Bh, 01Bh, 000h, 001h, 007h, 002h, 003h, 097h, 000h, 01Dh, 002h, 048h, 00Bh, 010h, 002h
    db 006h, 008h, 010h, 00Bh, 0B4h, 000h, 01Ch, 002h, 049h, 00Bh, 012h, 002h, 005h, 008h, 010h, 00Bh
    db 0B4h, 000h, 01Bh, 002h, 049h, 00Bh, 001h, 004h, 014h, 002h, 003h, 008h, 010h, 00Bh, 0B3h, 000h
    db 01Ah, 002h, 02Bh, 00Bh, 020h, 005h, 016h, 002h, 001h, 008h, 002h, 00Bh, 001h, 004h, 00Eh, 005h
    db 0B2h, 000h, 01Ah, 002h, 01Fh, 00Bh, 02Ch, 005h, 019h, 002h, 004h, 004h, 00Ch, 005h, 0B2h, 000h
    db 018h, 002h, 013h, 00Bh, 039h, 005h, 01Bh, 002h, 004h, 004h, 00Bh, 005h, 0B1h, 000h, 018h, 002h
    db 04Ch, 005h, 01Dh, 002h, 004h, 004h, 00Ah, 005h, 0B0h, 000h, 003h, 002h, 001h, 007h, 003h, 005h
    db 003h, 00Bh, 010h, 002h, 04Ah, 005h, 01Fh, 002h, 004h, 004h, 009h, 005h, 0AEh, 000h, 00Ah, 005h
    db 002h, 00Bh, 011h, 002h, 048h, 005h, 022h, 002h, 003h, 004h, 008h, 005h, 0ADh, 000h, 00Bh, 005h
    db 003h, 00Bh, 011h, 002h, 046h, 005h, 024h, 002h, 004h, 004h, 006h, 005h, 0ADh, 000h, 00Bh, 005h
    db 003h, 00Bh, 012h, 002h, 044h, 005h, 026h, 002h, 004h, 004h, 005h, 005h, 0ACh, 000h, 00Dh, 005h
    db 003h, 00Bh, 012h, 002h, 042h, 005h, 001h, 004h, 027h, 002h, 004h, 004h, 004h, 005h, 0ACh, 000h
    db 00Dh, 005h, 003h, 00Bh, 013h, 002h, 040h, 005h, 001h, 004h, 02Ah, 002h, 003h, 004h, 003h, 005h
    db 0ACh, 000h, 00Eh, 005h, 003h, 00Bh, 013h, 002h, 03Fh, 005h, 02Ch, 002h, 003h, 004h, 002h, 005h
    db 0ACh, 000h, 00Eh, 005h, 003h, 00Bh, 014h, 002h, 03Dh, 005h, 02Eh, 002h, 004h, 004h, 0ABh, 000h
    db 010h, 005h, 003h, 00Bh, 014h, 002h, 03Bh, 005h, 033h, 002h, 0ABh, 000h, 010h, 005h, 003h, 00Bh
    db 015h, 002h, 03Bh, 005h, 032h, 002h, 0ABh, 000h, 011h, 005h, 003h, 00Bh, 015h, 002h, 03Bh, 005h
    db 031h, 002h, 0ABh, 000h, 011h, 005h, 003h, 004h, 017h, 002h, 03Ah, 005h, 030h, 002h, 0ABh, 000h
    db 005h, 004h, 00Ch, 005h, 002h, 004h, 019h, 002h, 03Bh, 005h, 02Eh, 002h, 0ABh, 000h, 006h, 004h
    db 00Ah, 005h, 003h, 004h, 01Ah, 002h, 001h, 004h, 03Ah, 005h, 02Dh, 002h, 039h, 000h, 001h, 007h
    db 001h, 003h, 071h, 000h, 005h, 004h, 00Ah, 005h, 003h, 004h, 01Ch, 002h, 03Ah, 005h, 02Ch, 002h
    db 0ACh, 000h, 006h, 004h, 009h, 005h, 002h, 004h, 01Eh, 002h, 03Ah, 005h, 02Bh, 002h, 035h, 000h
    db 004h, 00Ah, 073h, 000h, 007h, 004h, 007h, 005h, 003h, 004h, 020h, 002h, 03Ah, 005h, 029h, 002h
    db 034h, 000h, 003h, 007h, 003h, 003h, 073h, 000h, 007h, 004h, 006h, 005h, 002h, 004h, 022h, 002h
    db 03Ah, 005h, 028h, 002h, 034h, 000h, 005h, 003h, 074h, 000h, 008h, 004h, 004h, 005h, 003h, 004h
    db 023h, 002h, 03Ah, 005h, 027h, 002h, 0AEh, 000h, 008h, 004h, 003h, 005h, 003h, 004h, 025h, 002h
    db 039h, 005h, 026h, 002h, 0AEh, 000h, 008h, 004h, 003h, 005h, 002h, 004h, 027h, 002h, 02Ah, 005h
    db 00Fh, 004h, 025h, 002h, 0AEh, 000h, 009h, 004h, 001h, 005h, 003h, 004h, 028h, 002h, 001h, 004h
    db 010h, 005h, 026h, 004h, 026h, 002h, 0AFh, 000h, 009h, 004h, 003h, 00Bh, 02Ah, 002h, 033h, 004h
    db 028h, 002h, 0B0h, 000h, 00Ah, 004h, 003h, 00Bh, 02Ah, 002h, 030h, 004h, 029h, 002h, 0B1h, 000h
    db 00Ah, 004h, 003h, 00Bh, 02Ah, 002h, 02Dh, 004h, 02Bh, 002h, 0B1h, 000h, 00Bh, 004h, 003h, 00Bh
    db 02Bh, 002h, 02Ah, 004h, 02Ch, 002h, 0B2h, 000h, 00Bh, 004h, 004h, 00Bh, 02Bh, 002h, 026h, 004h
    db 02Eh, 002h, 0B3h, 000h, 00Ch, 004h, 003h, 00Bh, 02Ch, 002h, 023h, 004h, 02Fh, 002h, 0B4h, 000h
    db 00Ch, 004h, 003h, 00Bh, 02Dh, 002h, 01Fh, 004h, 031h, 002h, 0B5h, 000h, 00Ch, 004h, 004h, 00Bh
    db 02Ch, 002h, 01Dh, 004h, 032h, 002h, 0B6h, 000h, 00Dh, 004h, 003h, 00Bh, 02Dh, 002h, 015h, 004h
    db 038h, 002h, 0B7h, 000h, 00Dh, 004h, 003h, 00Bh, 02Eh, 002h, 00Bh, 004h, 040h, 002h

title_image_size equ 1342
title_image_end:
