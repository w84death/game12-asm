# PNG to VGA Compressed Image Converter

This tool converts 320x200 PNG images to a compressed format optimized for VGA mode 13h (320x200, 256 colors) display in assembly programs.

## Features

- Converts PNG images to 16-color indexed format using the DawnBringer16 palette
- Run-Length Encoding (RLE) compression optimized for horizontal scanlines
- Outputs either assembly source code or binary format
- Designed for efficient decompression in x86 assembly using `rep stosb`

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

# Optimized mode (skip odd lines, no EOL markers)
./fmv2asm input.png output.asm -asm image_data -opt

# Show compression statistics
./fmv2asm input.png output.bin -bin -stats
```

### Command Line Options

- `-asm <label>` - Output as assembly source file with specified label name
- `-bin` - Output as raw binary file (default)
- `-opt` - Optimized mode: skip odd lines and EOL markers (for double-line rendering)
- `-stats` - Display compression statistics

## Compression Format

The compression uses Run-Length Encoding with the following structure:

```
[color_index:1 byte][run_length:1 byte]...
```

- **color_index**: Palette index (0-15) for the DawnBringer16 palette
- **run_length**: Number of consecutive pixels (1-255)
- **End of line marker**: `0xFF, 0x00` marks the end of each scanline (standard mode only)

Each scanline is compressed independently, always ending at exactly 320 pixels.

### Optimized Mode (`-opt`)

When using the `-opt` flag:
- Only even lines (0, 2, 4, ..., 198) are encoded
- No EOL markers are added
- Output is approximately 50% smaller
- Assembly code should render each line twice to reconstruct full image
- Ideal for animations or when memory is critical

## Assembly Integration

The output assembly file contains:
- Compressed image data as `db` statements
- Label for the data start (e.g., `image_data:`)
- Size constant (e.g., `image_data_size equ XXXX`)
- End label (e.g., `image_data_end:`)

### Example Assembly Decompression Routine

```asm
; Set ES to VGA segment (0xA000)
mov ax, 0A000h
mov es, ax

; SI points to compressed data
; DI points to VGA memory (0 for top-left)
mov si, offset image_data
xor di, di

decompress_loop:
    lodsb           ; AL = color index
    cmp al, 0FFh    ; Check for EOL marker
    je end_of_line
    
    mov ah, al      ; Save color
    lodsb           ; AL = run length
    movzx cx, al    ; CX = run length
    
    mov al, ah      ; Restore color
    rep stosb       ; Write CX pixels
    
    jmp decompress_loop
    
end_of_line:
    lodsb           ; Skip the 0x00
    ; Continue with next line or exit
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

Typical compression ratios:
- Standard mode with large solid areas: 3:1 to 10:1
- Standard mode with detailed pixel art: 1.5:1 to 3:1
- Optimized mode adds ~2x additional compression (only stores half the lines)
- Uncompressed size: 64,000 bytes (320×200)

## Example Files

- `fmv2asm.c` - Main converter source code
- `palette.h` - DawnBringer16 palette definition
- `Makefile` - Build configuration

## Tips for Best Results

1. **Prepare your images**: Pre-process images to use colors close to the DawnBringer16 palette
2. **Optimize for horizontal runs**: The compression works best with horizontal bands of color
3. **Consider dithering**: For photographic images, apply dithering before conversion
4. **Test compression**: Use `-stats` to check compression efficiency
5. **Use optimized mode**: For animations or low-memory situations, use `-opt` flag
6. **Vertical detail**: Optimized mode works best when adjacent horizontal lines are similar

## Troubleshooting

### "Image must be 320x200"
Resize your image to exactly 320×200 pixels before conversion.

### Poor color matching
The tool finds the nearest color in the DawnBringer16 palette. For best results, create or edit your images using these 16 colors.

### Large output files
Images with high detail or noise compress poorly. Consider simplifying the image or using solid color areas where possible.

## License

This tool is provided as-is for use in retro computing and game development projects.