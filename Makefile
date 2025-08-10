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
	@if [ -f $(MANUAL_TXT) ]; then \
		$(MCOPY) -i $@ $(MANUAL_TXT) ::MANUAL.TXT; \
	else \
		echo "GAME-12 Manual" > /tmp/manual.txt; \
		echo "==============" >> /tmp/manual.txt; \
		echo "" >> /tmp/manual.txt; \
		echo "A retro game for x86 bare metal." >> /tmp/manual.txt; \
		echo "Visit: https://github.com/w84death/game12-asm" >> /tmp/manual.txt; \
		$(MCOPY) -i $@ /tmp/manual.txt ::MANUAL.TXT; \
		$(RM) /tmp/manual.txt; \
	fi
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
	@echo "  clean - Remove build artifacts"
	@echo ""
	@echo "The floppy image is DOS-compatible and contains:"
	@echo "  GAME.COM   - The game executable"
	@echo "  MANUAL.TXT - Game manual"

.PHONY: all com bochs jsdos burn clean help
