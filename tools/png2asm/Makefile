# Makefile for PNG to Assembly converter tool
# Requires libpng development libraries

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
LIBS = -lpng -lm
TARGET = png2asm
SOURCE = png2asm.c

# Default target
all: $(TARGET)

# Build the png2asm tool
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE) $(LIBS)

# Clean built files
clean:
	rm -f $(TARGET)

# Install libpng development libraries (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install libpng-dev

# Install libpng development libraries (CentOS/RHEL/Fedora)
install-deps-rpm:
	sudo yum install libpng-devel || sudo dnf install libpng-devel

# Test if the tool works (requires test files)
test: $(TARGET)
	@echo "Testing png2asm tool..."
	@if [ -f test_input.png ] && [ -f test_palette.png ]; then \
		./$(TARGET) test_input.png test_palette.png test_output.asm; \
		echo "Test completed. Check test_output.asm"; \
	else \
		echo "Test files not found. Create test_input.png and test_palette.png to run tests."; \
	fi

# Show usage information
help:
	@echo "PNG to Assembly Converter Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Build the png2asm tool (default)"
	@echo "  clean         - Remove built files"
	@echo "  install-deps  - Install libpng development libraries (Debian/Ubuntu)"
	@echo "  install-deps-rpm - Install libpng development libraries (CentOS/RHEL/Fedora)"
	@echo "  test          - Test the tool (requires test files)"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make                    # Build the tool"
	@echo "  make clean              # Clean build files"
	@echo "  make install-deps       # Install dependencies"
	@echo "  ./png2asm input.png palettes.png output.asm"

.PHONY: all clean install-deps install-deps-rpm test help