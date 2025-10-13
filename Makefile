# GAME-12 Makefile
# Builds FAT12-compatible bootable floppy with DOS-readable files

# Tools
ASM = fasm
UPX = upx
BOCHS = bochs -q -f .bochsrc
DD = dd
MKDIR = mkdir -p
RM = rm -f
RMDIR = rm -rf
MKFS = mkfs.fat
MCOPY = mcopy
MDIR = mdir
MFORMAT = mformat

# USB floppy device (change this to match your system)
USB_FLOPPY = /dev/sdb

# Directories
BUILD_DIR = build
BIN_DIR = $(BUILD_DIR)/bin
IMG_DIR = $(BUILD_DIR)/img

# Files
BOOTLOADER = $(BIN_DIR)/boot.bin
GAME = $(BIN_DIR)/game.bin
GAME_COM_RAW = $(BIN_DIR)/game12_raw.com
GAME_COM = $(BIN_DIR)/game12.com
FLOPPY_IMG = $(IMG_DIR)/floppy.img
JSDOS_ARCHIVE = jsdos/game12.jsdos
MANUAL_TXT = MANUAL.TXT

# Source files for statistics
ASM_SOURCES = src/boot.asm src/game.asm src/img_p1x.asm src/img_title.asm src/sfx.asm src/tiles.asm

# Default target
all: $(FLOPPY_IMG)

# Build development tools
tools:
	@echo "Building development tools..."
	$(MAKE) -C tools/fnt2asm
	$(MAKE) -C tools/png2asm
	$(MAKE) -C tools/rleimg2asm
	@echo "All tools built successfully"

# Create directories
$(BIN_DIR) $(IMG_DIR):
	$(MKDIR) $@

# Compile bootloader
$(BOOTLOADER): src/boot.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compile game binary
$(GAME): src/game.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compile game as uncompressed COM file
$(GAME_COM_RAW): src/game.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compress COM file with UPX
$(GAME_COM): $(GAME_COM_RAW)
	cp $(GAME_COM_RAW) $@
	$(UPX) --best $@
	echo -n "P1X" >> $@

# Build compressed COM file
com: $(GAME_COM)
	@echo "Compressed COM file built: $(GAME_COM)"

# Build uncompressed COM file
com-raw: $(GAME_COM_RAW)
	@echo "Uncompressed COM file built: $(GAME_COM_RAW)"

# Create FAT12 bootable floppy image
$(FLOPPY_IMG): $(BOOTLOADER) $(GAME_COM) | $(IMG_DIR)
	@echo "Creating FAT12 floppy image..."
	# Create blank 1.44MB floppy image
	$(DD) if=/dev/zero of=$@ bs=512 count=2880
	# Format as FAT12 using mtools (preserve space for boot sector)
	$(MFORMAT) -i $@ -f 1440 -B $(BOOTLOADER) ::
	# Copy GAME.COM first so it occupies the first data sectors
	$(MCOPY) -i $@ $(GAME_COM) ::GAME.COM
	# Create and copy manual if it exists, otherwise create a placeholder
	$(MCOPY) -i $@ $(MANUAL_TXT) ::MANUAL.TXT; \
	$(MCOPY) -i $@ /tmp/manual.txt ::MANUAL.TXT; \
	$(RM) /tmp/manual.txt; \
	# List directory contents for verification
	@echo "Floppy contents:"
	@$(MDIR) -i $@ ::

# Debug in Bochs
bochs: $(FLOPPY_IMG)
	$(BOCHS)

# Build jsdos version
jsdos: $(GAME_COM)
	@echo "Updating jsdos archive..."
	cp $(GAME_COM) game.com
	zip -u $(JSDOS_ARCHIVE) game.com
	rm game.com
	@echo "jsdos build complete: $(JSDOS_ARCHIVE)"

# Burn to physical floppy disk
burn: $(FLOPPY_IMG)
	@echo "WARNING: This will overwrite all data on $(USB_FLOPPY)!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	sudo $(DD) if=$(FLOPPY_IMG) of=$(USB_FLOPPY) bs=512 conv=notrunc,sync,fsync oflag=direct status=progress
	@echo "Successfully burned to $(USB_FLOPPY)"

# Display project statistics
stats: $(BOOTLOADER) $(GAME_COM) $(GAME_COM_RAW)
	@echo "================================================"
	@echo "              GAME-12 PROJECT STATISTICS"
	@echo "================================================"
	@echo ""
	@echo "BINARY SIZES:"
	@echo "  Boot sector:     $$(stat -c%s $(BOOTLOADER) 2>/dev/null || stat -f%z $(BOOTLOADER) 2>/dev/null) bytes"
	@raw_size=$$(stat -c%s $(GAME_COM_RAW) 2>/dev/null || stat -f%z $(GAME_COM_RAW) 2>/dev/null); \
	compressed_size=$$(stat -c%s $(GAME_COM) 2>/dev/null || stat -f%z $(GAME_COM) 2>/dev/null); \
	ratio=$$((100 - (compressed_size * 100 / raw_size))); \
	echo "  Game COM (raw):  $$raw_size bytes"; \
	echo "  Game COM (UPX):  $$compressed_size bytes ($$ratio% reduction)"
	@if [ -f $(FLOPPY_IMG) ]; then \
		echo "  Floppy image:    $$(stat -c%s $(FLOPPY_IMG) 2>/dev/null || stat -f%z $(FLOPPY_IMG) 2>/dev/null) bytes"; \
	fi
	@echo ""
	@echo "Lines of Code (all files in /src/):"
	@for file in src/*.asm; do \
		if [ -f "$$file" ]; then \
			lines=$$(wc -l < "$$file"); \
			basename=$$(basename "$$file"); \
			printf "  %-20s %5d lines\n" "$$basename" "$$lines"; \
		fi; \
	done
	@echo ""
	@echo "Total LOC:" $$(cat src/*.asm | wc -l)
	@echo ""
	@echo "Comment Coverage (main files only):"
	@for file in src/boot.asm src/game.asm; do \
		if [ -f "$$file" ]; then \
			basename=$$(basename "$$file"); \
			total_lines=$$(wc -l < "$$file"); \
			comment_lines=$$(grep -c "^[[:space:]]*;" "$$file" || true); \
			if [ "$$total_lines" -gt 0 ]; then \
				coverage=$$((comment_lines * 100 / total_lines)); \
				printf "  %-20s %5d/%5d (%d%%)\n" "$$basename" "$$comment_lines" "$$total_lines" "$$coverage"; \
			fi; \
		fi; \
	done
	@echo "================================================"

# Decompress COM file for debugging
decompress: $(GAME_COM)
	@if upx -t $(GAME_COM) >/dev/null 2>&1; then \
		echo "Decompressing $(GAME_COM)..."; \
		upx -d $(GAME_COM); \
		echo "File decompressed successfully"; \
	else \
		echo "$(GAME_COM) is not UPX compressed"; \
	fi

# Test UPX compression on current COM file
test-upx: $(GAME_COM_RAW)
	@echo "Testing UPX compression ratios..."
	@cp $(GAME_COM_RAW) /tmp/test_upx.com
	@echo "Original size: $$(stat -c%s /tmp/test_upx.com 2>/dev/null || stat -f%z /tmp/test_upx.com 2>/dev/null) bytes"
	@echo ""
	@echo "UPX --fast:"
	@cp $(GAME_COM_RAW) /tmp/test_upx_fast.com && upx --fast /tmp/test_upx_fast.com 2>/dev/null
	@echo "UPX --best:"
	@cp $(GAME_COM_RAW) /tmp/test_upx_best.com && upx --best /tmp/test_upx_best.com 2>/dev/null
	@echo "UPX --ultra-brute:"
	@cp $(GAME_COM_RAW) /tmp/test_upx_ultra.com && upx --ultra-brute /tmp/test_upx_ultra.com 2>/dev/null || echo "Ultra-brute compression failed or not supported"
	@rm -f /tmp/test_upx*.com

# Check if file is UPX compressed
check-upx: $(GAME_COM)
	@if upx -t $(GAME_COM) >/dev/null 2>&1; then \
		echo "$(GAME_COM) is UPX compressed"; \
		upx -l $(GAME_COM); \
	else \
		echo "$(GAME_COM) is not UPX compressed"; \
	fi

# Clean build artifacts
clean:
	$(RMDIR) $(BUILD_DIR)

# Clean tools
clean-tools:
	$(MAKE) -C tools/fnt2asm clean
	$(MAKE) -C tools/png2asm clean
	$(MAKE) -C tools/rleimg2asm clean

# Help
help:
	@echo "GAME-12 Build Targets:"
	@echo "  all         - Build FAT12 bootable floppy image (default)"
	@echo "  com         - Build compressed COM file with UPX"
	@echo "  com-raw     - Build uncompressed COM file"
	@echo "  bochs       - Run in Bochs debugger"
	@echo "  jsdos       - Build jsdos archive"
	@echo "  burn        - Burn to physical floppy"
	@echo "  stats       - Display project statistics"
	@echo "  tools       - Build all development tools"
	@echo "  clean       - Remove build artifacts"
	@echo "  clean-tools - Clean development tools"
	@echo ""
	@echo "UPX Compression Targets:"
	@echo "  decompress  - Decompress COM file for debugging"
	@echo "  test-upx    - Test different UPX compression levels"
	@echo "  check-upx   - Check if COM file is UPX compressed"
	@echo ""
	@echo "Development Tools:"
	@echo "  fnt2asm     - Convert PNG fonts to assembly data"
	@echo "  png2asm     - Convert PNG images to assembly data"
	@echo "  rleimg2asm  - Convert images to RLE-compressed assembly"
	@echo ""
	@echo "The floppy image is DOS-compatible and contains:"
	@echo "  GAME.COM   - The game executable"
	@echo "  MANUAL.TXT - Game manual"

.PHONY: all com com-raw bochs jsdos burn stats tools decompress test-upx check-upx clean clean-tools help
