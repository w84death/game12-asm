# GAME-12 Makefile
# This file compiles the GAME-12 bootloader and game code
# and builds a bootable floppy image.

# Tools
ASM = fasm
BOCHS = bochs -q -debugger -f .bochsrc
QEMU = qemu-system-i386 -m 1 -k en-us -rtc base=localtime -vga std -cpu 486 -boot order=a -drive format=raw,file=$(FLOPPY_IMG)
FLATPAL_86BOX = flatpak run net._86box._86Box
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

# Floppy image size (1.44MB = 2880 sectors * 512 bytes/sector)
FLOPPY_SECTORS = 2880

# Kernel details
GAME_SECTORS = 32 # Allocate 16KB (32 sectors) for the game game

# Default target
all: $(FLOPPY_IMG)

# Create directories
$(BIN_DIR) $(IMG_DIR):
	$(MKDIR) $@

# Compile bootloader
$(BOOTLOADER): src/boot.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compile game (game)
$(GAME): src/game.asm | $(BIN_DIR)
	$(ASM) $< $@

# Compile game as COM file for DOS/jsdos
$(GAME_COM): src/game.asm | $(BIN_DIR)
	$(ASM) $< $@

# Create empty floppy image
$(IMG_DIR)/floppy_empty.img: | $(IMG_DIR)
	$(DD) if=/dev/zero of=$@ bs=512 count=$(FLOPPY_SECTORS)

# Write to floppy image
$(FLOPPY_IMG): $(BOOTLOADER) $(GAME) $(IMG_DIR)/floppy_empty.img | $(IMG_DIR)
	cp $(IMG_DIR)/floppy_empty.img $(FLOPPY_IMG)
	$(DD) if=$(BOOTLOADER) of=$(FLOPPY_IMG) bs=512 count=1 conv=notrunc
	$(DD) if=$(GAME) of=$(FLOPPY_IMG) bs=512 seek=1 count=$(GAME_SECTORS) conv=notrunc

# Run game in 86Box emulator
run: $(FLOPPY_IMG)
	$(FLATPAL_86BOX)

# Run game in QEMU
qemu: $(FLOPPY_IMG)
	$(QEMU)

# Debug game in Bochs
debug: $(FLOPPY_IMG)
	$(BOCHS)

# Build jsdos version
jsdos: $(GAME_COM)
	@echo "Updating jsdos archive with new game.com..."
	cp $(GAME_COM) game.com
	zip -u $(JSDOS_ARCHIVE) game.com
	$(RM) game.com
	@echo "jsdos build complete! Updated $(JSDOS_ARCHIVE)"

# Burn game to physical floppy disk
burn: $(FLOPPY_IMG)
	@echo "WARNING: This will overwrite all data on $(USB_FLOPPY)!"
	@echo "Make sure $(USB_FLOPPY) is your USB floppy drive, not another drive!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	sudo $(DD) if=$(FLOPPY_IMG) of=$(USB_FLOPPY) bs=512 conv=notrunc,sync,fsync oflag=direct status=progress
	@echo "Game image successfully burned to $(USB_FLOPPY)"
	@echo "You may now safely eject the floppy disk."

# Clean build artifacts
clean:
	$(RM) $(BOOTLOADER) $(GAME) $(GAME_COM) $(FLOPPY_IMG) $(IMG_DIR)/floppy_empty.img game.com
	$(RMDIR) $(BUILD_DIR)

# Test floppy drive
test-floppy:
	@echo "Testing floppy drive $(USB_FLOPPY)..."
	@if sudo fdisk -l $(USB_FLOPPY) 2>/dev/null; then \
		echo "Drive detected successfully"; \
	else echo "Drive not detected or accessible"; fi

# Display help information
help:
	@echo "GAME-12 Makefile - Available targets:"
	@echo ""
	@echo "  all         - Build bootable floppy image (default)"
	@echo "  run         - Run game in 86Box emulator"
	@echo "  qemu        - Run game in QEMU"
	@echo "  debug       - Debug game in Bochs"
	@echo "  jsdos       - Build jsdos version (updates jsdos/game12.jsdos)"
	@echo "  burn        - Burn game to physical floppy disk"
	@echo "  test-floppy - Test floppy drive accessibility"
	@echo "  clean       - Clean build artifacts"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Build outputs:"
	@echo "  $(FLOPPY_IMG) - Bootable floppy image"
	@echo "  $(JSDOS_ARCHIVE) - jsdos archive with game.com"

.PHONY: all run qemu debug clean burn test-floppy jsdos help
