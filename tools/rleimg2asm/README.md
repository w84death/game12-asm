# PNG to VGA Compressed Image Converter (Interlaced)

This tool converts 320x200 PNG images to a compressed interlaced format optimized for VGA mode 13h (320x200, 256 colors) display in assembly programs.

## Features

- Converts PNG images to 16-color indexed format using the DawnBringer16 palette
- Run-Length Encoding (RLE) compression with interlacing (even lines only)
- No EOL markers for maximum compression
- Outputs either assembly source code or binary format
- Designed for efficient decompression in x86 assembly using `rep stosb`
- Assembly code renders each line twice to reconstruct full image

## Building

Requirements:
- GCC compiler
- libpng development libraries

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get install libpng-dev

# Build the converter
make

# Or manually:
gcc -Wall -O2 fmv2asm.c -o fmv2asm -lpng -lm
```

## Usage

```bash
# Convert to assembly source file
./fmv2asm input.png output.asm -asm image_data

# Convert to binary file
./fmv2asm input.png output.bin -bin

# Show compression statistics
./fmv2asm input.png output.bin -bin -stats
```

### Command Line Options

- `-asm <label>` - Output as assembly source file with specified label name
- `-bin` - Output as raw binary file (default)
- `-stats` - Display compression statistics

## Compression Format

The compression uses interlaced Run-Length Encoding with the following structure:

```
[run_length:1 byte][color_index:1 byte]...
```

- **run_length**: Number of consecutive pixels (1-255)
- **color_index**: Palette index (0-15) for the DawnBringer16 palette
- **Interlaced**: Only even lines (0, 2, 4, ..., 198) are encoded
- **No EOL markers**: Lines are not terminated with markers
- **Line guarantee**: Each scanline is guaranteed to encode exactly 320 pixels
- **Boundary clipping**: The compressor automatically clips runs at line boundaries

The interlaced format stores only half the lines, requiring the assembly code to render each line twice. This provides approximately 50% base compression before RLE.

## Assembly Integration

The output assembly file contains:
- Compressed interlaced image data as `db` statements
- Label for the data start (e.g., `image_data:`)
- Size constant (e.g., `image_data_size equ XXXX`)
- End label (e.g., `image_data_end:`)
- Header comments indicating interlaced format

### Example Assembly Decompression Routine

```asm
; Interlaced rendering - each line is rendered twice
; SI points to compressed data
; DI points to VGA memory (0 for top-left)
mov si, offset image_data
xor di, di
xor dx, dx          ; Line pixel counter
xor bx, bx          ; Total pixel counter

decompress_loop:
    lodsb           ; AL = run length
    movzx cx, al    ; CX = run length
    add dx, ax      ; Track pixels in line
    add bx, ax      ; Track total pixels
    
    lodsb           ; AL = color index
    rep stosb       ; Write CX pixels of color AL
    
    cmp dx, 320     ; Check if line complete
    jl decompress_loop
    
    add di, 320     ; Render line twice (interlaced)
    xor dx, dx      ; Reset line counter
    
    cmp bx, 320*100 ; 100 lines (half of 200)
    jl decompress_loop
```

## DawnBringer16 Palette

The tool uses the DawnBringer16 palette, a carefully crafted 16-color palette ideal for pixel art:

| Index | Color | RGB Values |
|-------|-------|------------|
| 0 | Black | (0, 0, 0) |
| 1 | Deep Purple | (68, 32, 52) |
| 2 | Navy Blue | (48, 52, 109) |
| 3 | Dark Gray | (78, 74, 78) |
| 4 | Brown | (133, 76, 48) |
| 5 | Dark Green | (52, 101, 36) |
| 6 | Red | (208, 70, 72) |
| 7 | Light Gray | (117, 113, 97) |
| 8 | Blue | (89, 125, 206) |
| 9 | Orange | (210, 125, 44) |
| 10 | Steel Blue | (133, 149, 161) |
| 11 | Green | (109, 170, 44) |
| 12 | Pink/Beige | (210, 170, 153) |
| 13 | Cyan | (109, 194, 202) |
| 14 | Yellow | (218, 212, 94) |
| 15 | White | (222, 238, 214) |

## Input Requirements

- Image must be exactly 320x200 pixels
- PNG format (any color depth - will be converted)
- Best results with images already using limited colors

## Compression Performance

Typical compression ratios (interlaced mode):
- Images with large solid areas: 6:1 to 20:1
- Detailed pixel art: 3:1 to 6:1
- Base interlacing provides 2x compression (stores only even lines)
- Additional RLE compression on top of interlacing
- Uncompressed size: 64,000 bytes (320×200)
- Typical compressed size: 10,000-20,000 bytes

## Example Files

- `fmv2asm.c` - Main converter source code
- `palette.h` - DawnBringer16 palette definition
- `Makefile` - Build configuration

## Tips for Best Results

1. **Prepare your images**: Pre-process images to use colors close to the DawnBringer16 palette
2. **Optimize for horizontal runs**: The compression works best with horizontal bands of color
3. **Consider dithering**: For photographic images, apply dithering before conversion
4. **Test compression**: Use `-stats` to check compression efficiency
5. **Vertical detail**: Interlacing works best when adjacent horizontal lines are similar
6. **Memory efficient**: Ideal for animations where multiple frames need to fit in memory

## Troubleshooting

### "Image must be 320x200"
Resize your image to exactly 320×200 pixels before conversion.

### Poor color matching
The tool finds the nearest color in the DawnBringer16 palette. For best results, create or edit your images using these 16 colors.

### Large output files
Images with high detail or noise compress poorly. Consider simplifying the image or using solid color areas where possible.

## License

This tool is provided as-is for use in retro computing and game development projects.