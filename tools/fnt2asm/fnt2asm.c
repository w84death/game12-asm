#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// STB_IMAGE_IMPLEMENTATION should be defined before including stb_image.h
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG  // Only support PNG for simplicity, you can remove this for more formats
#include "stb_image.h"

#define CHAR_WIDTH 8
#define CHAR_HEIGHT 8

#ifndef CHARS_PER_ROW
#define CHARS_PER_ROW 16
#endif

#ifndef TOTAL_CHARS
#define TOTAL_CHARS 43
#endif

// Character names for comments starting from '0'
const char* get_char_name(int index) {
    static char buffer[32];

    // Tileset starts from character '0' (ASCII 48)
    char actual_char = '0' + index;

    if (actual_char >= '0' && actual_char <= '9') {
        // Digits 0-9
        sprintf(buffer, "'%c'", actual_char);
    } else if (actual_char >= 'A' && actual_char <= 'Z') {
        // Uppercase letters
        sprintf(buffer, "'%c'", actual_char);
    } else if (actual_char >= 'a' && actual_char <= 'z') {
        // Lowercase letters
        sprintf(buffer, "'%c'", actual_char);
    } else if (actual_char >= 32 && actual_char <= 126) {
        // Other printable ASCII
        sprintf(buffer, "'%c'", actual_char);
    } else {
        // Non-printable or extended
        sprintf(buffer, "Char %d", index);
    }

    return buffer;
}

int main(int argc, char* argv[]) {
    if (argc < 3 || argc > 6) {
        fprintf(stderr, "Usage: %s <input_image.png> <output.asm> [debug] [chars_per_row] [total_chars]\n", argv[0]);
        fprintf(stderr, "Input should be a spritesheet with grid of 8x8 characters\n");
        fprintf(stderr, "  debug         - Add 'debug' as third argument for debug output\n");
        fprintf(stderr, "  chars_per_row - Number of characters per row (default: %d)\n", CHARS_PER_ROW);
        fprintf(stderr, "  total_chars   - Total number of characters (default: %d)\n", TOTAL_CHARS);
        fprintf(stderr, "First tile in spritesheet is always skipped\n");
        return 1;
    }

    int debug_mode = 0;
    int chars_per_row = CHARS_PER_ROW;
    int total_chars = TOTAL_CHARS;

    // Parse arguments
    for (int i = 3; i < argc; i++) {
        if (strcmp(argv[i], "debug") == 0) {
            debug_mode = 1;
        } else {
            // Try to parse as numbers
            int val = atoi(argv[i]);
            if (val > 0) {
                if (chars_per_row == CHARS_PER_ROW) {
                    chars_per_row = val;
                } else {
                    total_chars = val;
                }
            }
        }
    }

    const char* input_filename = argv[1];
    const char* output_filename = argv[2];

    // Load the image
    int width, height, channels;
    unsigned char* image_data = stbi_load(input_filename, &width, &height, &channels, 0);

    if (!image_data) {
        fprintf(stderr, "Error: Failed to load image '%s'\n", input_filename);
        return 1;
    }

    // Verify image dimensions (add 1 to total_chars to account for skipping first tile)
    int expected_width = chars_per_row * CHAR_WIDTH;
    int expected_height = ((total_chars + 1) / chars_per_row + (((total_chars + 1) % chars_per_row) ? 1 : 0)) * CHAR_HEIGHT;

    if (width < expected_width || height < expected_height) {
        fprintf(stderr, "Error: Image dimensions should be at least %dx%d, but got %dx%d\n",
                expected_width, expected_height, width, height);
        stbi_image_free(image_data);
        return 1;
    }

    if (debug_mode) {
        printf("Image loaded: %dx%d, %d channels\n", width, height, channels);
        printf("Expected minimum: %dx%d\n", expected_width, expected_height);
        printf("Configuration: %d chars per row, %d total chars\n", chars_per_row, total_chars);
    }

    // Open output file
    FILE* output = fopen(output_filename, "w");
    if (!output) {
        fprintf(stderr, "Error: Failed to create output file '%s'\n", output_filename);
        stbi_image_free(image_data);
        return 1;
    }

    // Write header
    fprintf(output, "; Font data generated from %s\n", input_filename);
    fprintf(output, "; %d characters, 8x8 pixels per character\n", total_chars);
    fprintf(output, "; Each character is 8 bytes, one byte per row\n");
    fprintf(output, "; Bit 7 = leftmost pixel, Bit 0 = rightmost pixel\n");
    fprintf(output, "; First tile in spritesheet is skipped\n\n");
    fprintf(output, "Font:\n");

    // Process each character (skip first tile by adding 1)
    for (int char_index = 0; char_index < total_chars; char_index++) {
        // Calculate position of this character in the spritesheet (skip first tile)
        int sprite_index = char_index + 1;
        int char_col = sprite_index % chars_per_row;
        int char_row = sprite_index / chars_per_row;

        int start_x = char_col * CHAR_WIDTH;
        int start_y = char_row * CHAR_HEIGHT;

        if (debug_mode) {
            printf("Processing character %d (sprite %d) at (%d,%d)\n",
                   char_index, sprite_index, start_x, start_y);
        }

        // Extract 8 bytes for this character
        uint8_t char_data[8];

        for (int y = 0; y < CHAR_HEIGHT; y++) {
            uint8_t row_byte = 0;

            for (int x = 0; x < CHAR_WIDTH; x++) {
                int pixel_x = start_x + x;
                int pixel_y = start_y + y;
                int pixel_index = (pixel_y * width + pixel_x) * channels;

                // Determine if pixel is "on" or "off"
                int pixel_on = 0;

                if (channels == 1) {
                    // Grayscale - pixel is on if brightness < 127 (dark pixels)
                    pixel_on = image_data[pixel_index] < 127;
                } else if (channels == 3) {
                    // RGB - pixel is on if it's dark (sum of channels < threshold)
                    int brightness = image_data[pixel_index] +
                                   image_data[pixel_index + 1] +
                                   image_data[pixel_index + 2];
                    pixel_on = brightness < 384; // 3 * 128
                } else if (channels == 4) {
                    // RGBA - pixel is on if alpha > 127 and it's dark
                    int alpha = image_data[pixel_index + 3];
                    if (alpha > 127) {
                        int brightness = image_data[pixel_index] +
                                       image_data[pixel_index + 1] +
                                       image_data[pixel_index + 2];
                        pixel_on = brightness < 384; // 3 * 128
                    }
                }

                if (debug_mode && char_index == 0 && y < 2 && x < 4) {
                    printf("  Pixel (%d,%d): ", x, y);
                    if (channels == 1) {
                        printf("Gray=%d ", image_data[pixel_index]);
                    } else if (channels >= 3) {
                        printf("RGB=(%d,%d,%d) ",
                               image_data[pixel_index],
                               image_data[pixel_index + 1],
                               image_data[pixel_index + 2]);
                    }
                    if (channels == 4) {
                        printf("Alpha=%d ", image_data[pixel_index + 3]);
                    }
                    printf("-> %s\n", pixel_on ? "ON" : "OFF");
                }

                // Set bit in row_byte (bit 7 is leftmost)
                if (pixel_on) {
                    row_byte |= (1 << (7 - x));
                }
            }

            char_data[y] = row_byte;
        }

        // Write the character data
        fprintf(output, "  db ");
        for (int i = 0; i < 8; i++) {
            fprintf(output, "0x%02X", char_data[i]);
            if (i < 7) {
                fprintf(output, ",");
            }
        }
        fprintf(output, "  ; %d - %s", char_index, get_char_name(char_index));

        if (debug_mode) {
            // Show binary representation
            fprintf(output, " [");
            for (int i = 0; i < 8; i++) {
                for (int bit = 7; bit >= 0; bit--) {
                    fprintf(output, "%c", (char_data[i] & (1 << bit)) ? '#' : '.');
                }
                if (i < 7) fprintf(output, " ");
            }
            fprintf(output, "]");
        }

        fprintf(output, "\n");
    }

    // Clean up
    fclose(output);
    stbi_image_free(image_data);

    printf("Successfully converted %d characters from '%s' to '%s'\n",
           total_chars, input_filename, output_filename);

    return 0;
}
