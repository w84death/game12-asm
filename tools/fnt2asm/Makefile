# Makefile for Font to Assembly converter tool
# Uses stb_image.h for PNG loading (header-only library)

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
LIBS = -lm
TARGET = fnt2asm
SOURCE = fnt2asm.c
STB_HEADER = stb_image.h
STB_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image.h

# Default target
all: $(TARGET)

# Build the fnt2asm tool
$(TARGET): $(SOURCE) $(STB_HEADER)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE) $(LIBS)

# Download stb_image.h if it doesn't exist
$(STB_HEADER):
	@echo "Downloading stb_image.h..."
	@if command -v curl >/dev/null 2>&1; then \
		curl -L -o $(STB_HEADER) $(STB_URL); \
	elif command -v wget >/dev/null 2>&1; then \
		wget -O $(STB_HEADER) $(STB_URL); \
	else \
		echo "Error: Neither curl nor wget found. Please install one of them or download $(STB_HEADER) manually from:"; \
		echo "$(STB_URL)"; \
		exit 1; \
	fi
	@echo "Downloaded $(STB_HEADER)"

# Clean built files
clean:
	rm -f $(TARGET) test_font.asm test_font_debug.asm

# Clean everything including downloaded headers
distclean: clean
	rm -f $(STB_HEADER)

# Force download of stb_image.h (even if it exists)
download-stb:
	rm -f $(STB_HEADER)
	$(MAKE) $(STB_HEADER)

# Test if the tool works (requires font.png)
test: $(TARGET)
	@echo "Testing fnt2asm tool..."
	@if [ -f font.png ]; then \
		echo "Testing normal mode:"; \
		./$(TARGET) font.png test_font.asm; \
		echo "Testing debug mode:"; \
		./$(TARGET) font.png test_font_debug.asm debug; \
		echo "Test completed. Check test_font.asm and test_font_debug.asm"; \
		echo "Normal output contains $$(wc -l < test_font.asm) lines"; \
		echo "Debug output contains $$(wc -l < test_font_debug.asm) lines"; \
	else \
		echo "Test file font.png not found. Cannot run test."; \
		echo "Expected: PNG with grid of 8x8 characters (first tile will be skipped)"; \
		echo "Default: expects 16x16 grid (128x128 pixels total) for 256 chars"; \
	fi

# Show usage information
help:
	@echo "Font to Assembly Converter Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Build the fnt2asm tool (default)"
	@echo "  clean         - Remove built files"
	@echo "  distclean     - Remove built files and downloaded headers"
	@echo "  download-stb  - Force download of stb_image.h"
	@echo "  test          - Test the tool (requires font.png)"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Dependencies:"
	@echo "  - gcc or compatible C compiler"
	@echo "  - curl or wget (for downloading stb_image.h)"
	@echo ""
	@echo "Usage:"
	@echo "  make                                          # Build the tool"
	@echo "  make clean                                    # Clean build files"
	@echo "  ./fnt2asm input.png output.asm                # Convert font (default 16x256)"
	@echo "  ./fnt2asm input.png output.asm debug          # Convert with debug output"
	@echo "  ./fnt2asm input.png output.asm 5 4            # Convert 5 chars/row, 4 total"
	@echo "  ./fnt2asm input.png output.asm debug 8 64     # Debug mode, 8x64 config"
	@echo ""
	@echo "Arguments:"
	@echo "  input.png     - PNG spritesheet with 8x8 pixel characters"
	@echo "  output.asm    - Output assembly file"
	@echo "  debug         - Optional: enable debug output and visual representation"
	@echo "  chars_per_row - Optional: characters per row (default: 16)"
	@echo "  total_chars   - Optional: total characters to extract (default: 256)"
	@echo ""
	@echo "Input format:"
	@echo "  - PNG image with grid of 8x8 pixel characters"
	@echo "  - First tile is always skipped (empty tile convention)"
	@echo "  - Dark pixels (< 50% brightness) become 1 bits, light pixels become 0 bits"
	@echo "  - Supports grayscale, RGB, and RGBA formats"

.PHONY: all clean distclean download-stb test help
