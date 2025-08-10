# GAME-12 Makefile
# Builds bootloader, game code, and bootable floppy image

# Tools
ASM = fasm
BOCHS = bochs -q -debugger -f .bochsrc
DD = dd
MKDIR = mkdir -p
RM = rm -f
RMDIR = rm -rf

# USB floppy device (change this to match your system)
USB_FLOPPY = /dev/sdb

# Directories
BUILD_DIR = build
BIN_DIR = $(BUILD_DIR)/bin
IMG_DIR = $(BUILD_DIR)/img

# Files
BOOTLOADER = $(BIN_DIR)/boot.bin
GAME = $(BIN_DIR)/game.bin
GAME_COM = $(BIN_DIR)/game.com
FLOPPY_IMG = $(IMG_DIR)/floppy.img
JSDOS_ARCHIVE = jsdos/game12.jsdos

# Floppy parameters
FLOPPY_SECTORS = 2880  # 1.44MB
GAME_SECTORS = 32      # 16KB for game

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

# Create bootable floppy image
$(FLOPPY_IMG): $(BOOTLOADER) $(GAME) | $(IMG_DIR)
	$(DD) if=/dev/zero of=$@ bs=512 count=$(FLOPPY_SECTORS)
	$(DD) if=$(BOOTLOADER) of=$@ bs=512 count=1 conv=notrunc
	$(DD) if=$(GAME) of=$@ bs=512 seek=1 count=$(GAME_SECTORS) conv=notrunc

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
	@echo "  all   - Build bootable floppy image (default)"
	@echo "  com   - Build only the COM file"
	@echo "  bochs - Run in Bochs debugger"
	@echo "  jsdos - Build jsdos archive"
	@echo "  burn  - Burn to physical floppy"
	@echo "  clean - Remove build artifacts"

.PHONY: all com bochs jsdos burn clean help
