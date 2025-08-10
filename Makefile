# GAME-12 Makefile
# Builds FAT12-compatible bootable floppy with DOS-readable files

# Tools
ASM = fasm
BOCHS = bochs -q -debugger -f .bochsrc
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
GAME_COM = $(BIN_DIR)/game12.com
FLOPPY_IMG = $(IMG_DIR)/floppy.img
JSDOS_ARCHIVE = jsdos/game12.jsdos
MANUAL_TXT = MANUAL.TXT

# Source files for statistics
ASM_SOURCES = src/boot.asm src/game.asm src/img_p1x.asm src/img_title.asm src/sfx.asm src/tiles.asm

# Default target
all: $(FLOPPY_IMG)

# Create directories
$(BIN_DIR) $(IMG_DIR):
	$(MKDIR) $@

# Compile bootloader
$(BOOTLOADER): src/boot.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compile game binary
$(GAME): src/game.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compile game as COM file
$(GAME_COM): src/game.asm | $(BIN_DIR)
	$(ASM) $< $@

# Build just the COM file
com: $(GAME_COM)
	@echo "COM file built: $(GAME_COM)"

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
stats: $(BOOTLOADER) $(GAME_COM)
	@echo "================================================"
	@echo "              GAME-12 PROJECT STATISTICS"
	@echo "================================================"
	@echo ""
	@echo "BINARY SIZES:"
	@echo "  Boot sector:  $$(stat -c%s $(BOOTLOADER) 2>/dev/null || stat -f%z $(BOOTLOADER) 2>/dev/null) bytes"
	@echo "  Game COM:     $$(stat -c%s $(GAME_COM) 2>/dev/null || stat -f%z $(GAME_COM) 2>/dev/null) bytes"
	@if [ -f $(FLOPPY_IMG) ]; then \
		echo "  Floppy image: $$(stat -c%s $(FLOPPY_IMG) 2>/dev/null || stat -f%z $(FLOPPY_IMG) 2>/dev/null) bytes"; \
	fi
	@echo ""
	@echo "SOURCE CODE STATISTICS:"
	@for file in $(ASM_SOURCES); do \
		if [ -f $$file ]; then \
			total=$$(grep -v '^\s*$$' $$file | grep -v '^\s*;' | wc -l); \
			code_with_comment=$$(grep -v '^\s*$$' $$file | grep -v '^\s*;' | grep -v '^\s*[a-zA-Z_][a-zA-Z0-9_]*:\s*$$' | grep ';' | wc -l); \
			if [ $$total -gt 0 ]; then \
				percent=$$((code_with_comment * 100 / total)); \
			else \
				percent=0; \
			fi; \
			echo "  $$file:"; \
			echo "    Total LOC (non-empty, non-comment-only): $$total"; \
			echo "    Code lines with comments: $$code_with_comment ($$percent%)"; \
		fi; \
	done
	@echo ""
	@echo "TOTAL PROJECT STATISTICS:"
	@total_loc=0; \
	total_commented=0; \
	for file in $(ASM_SOURCES); do \
		if [ -f $$file ]; then \
			loc=$$(grep -v '^\s*$$' $$file | grep -v '^\s*;' | wc -l); \
			commented=$$(grep -v '^\s*$$' $$file | grep -v '^\s*;' | grep -v '^\s*[a-zA-Z_][a-zA-Z0-9_]*:\s*$$' | grep ';' | wc -l); \
			total_loc=$$((total_loc + loc)); \
			total_commented=$$((total_commented + commented)); \
		fi; \
	done; \
	if [ $$total_loc -gt 0 ]; then \
		percent=$$((total_commented * 100 / total_loc)); \
	else \
		percent=0; \
	fi; \
	echo "  Total lines of code: $$total_loc"; \
	echo "  Total commented lines: $$total_commented ($$percent%)"
	@echo "================================================"

# Clean build artifacts
clean:
	$(RMDIR) $(BUILD_DIR)

# Help
help:
	@echo "GAME-12 Build Targets:"
	@echo "  all   - Build FAT12 bootable floppy image (default)"
	@echo "  com   - Build only the COM file"
	@echo "  bochs - Run in Bochs debugger"
	@echo "  jsdos - Build jsdos archive"
	@echo "  burn  - Burn to physical floppy"
	@echo "  stats - Display project statistics"
	@echo "  clean - Remove build artifacts"
	@echo ""
	@echo "The floppy image is DOS-compatible and contains:"
	@echo "  GAME.COM   - The game executable"
	@echo "  MANUAL.TXT - Game manual"

.PHONY: all com bochs jsdos burn stats clean help
