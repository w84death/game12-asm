CC = gcc
CFLAGS = -Wall -O2
LDFLAGS = -lpng -lm

TARGET = fmv2asm
SOURCES = fmv2asm.c
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET) $(LDFLAGS)

%.o: %.c palette.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)

test: $(TARGET)
	@echo "Build successful. Run with:"
	@echo "  ./$(TARGET) input.png output.asm -asm image_data"
	@echo "  ./$(TARGET) input.png output.bin -bin"

.PHONY: all clean test
