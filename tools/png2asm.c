#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <png.h>

/* ===== Type Definitions ===== */

typedef struct {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
} RGB;

typedef struct {
    png_structp png_ptr;
    png_infop info_ptr;
    int width;
    int height;
    png_byte color_type;
    png_byte bit_depth;
    png_bytep *row_pointers;
} PNGImage;

typedef struct {
    RGB colors[4];
    bool has_black;
} Palette;

typedef struct {
    uint8_t palette_index;
    uint16_t tile_data[16][2];  // 16 rows, each with 2 words (left and right halves)
    bool is_sprite;
} Tile;

/* ===== DawnBringer 16 Palette Definition ===== */

static const RGB DAWNBRINGER_PALETTE[16] = {
    {0, 0, 0},       // 0 - Black
    {68, 32, 52},    // 1 - Deep purple
    {48, 52, 109},   // 2 - Navy blue
    {78, 74, 78},    // 3 - Dark gray
    {133, 76, 48},   // 4 - Brown
    {52, 101, 36},   // 5 - Dark green
    {208, 70, 72},   // 6 - Red
    {117, 113, 97},  // 7 - Light gray
    {89, 125, 206},  // 8 - Blue
    {210, 125, 44},  // 9 - Orange
    {133, 149, 161}, // 10 - Steel blue
    {109, 170, 44},  // 11 - Green
    {210, 170, 153}, // 12 - Pink/Beige
    {109, 194, 202}, // 13 - Cyan
    {218, 212, 94},  // 14 - Yellow
    {222, 238, 214}  // 15 - White
};

/* ===== Utility Functions ===== */

/**
 * Check if a color is black (all RGB values are zero)
 */
bool is_black(const RGB *color) {
    return color->red == 0 && color->green == 0 && color->blue == 0;
}

/**
 * Calculate squared distance between two colors in RGB space
 */
int color_distance_squared(const RGB *color1, const RGB *color2) {
    int dr = color1->red - color2->red;
    int dg = color1->green - color2->green;
    int db = color1->blue - color2->blue;
    return dr * dr + dg * dg + db * db;
}

/**
 * Find the index of a color in a palette
 * Returns -1 if not found
 */
int find_color_in_palette(const RGB *color, const RGB *palette, int palette_size) {
    for (int i = 0; i < palette_size; i++) {
        if (color->red == palette[i].red &&
            color->green == palette[i].green &&
            color->blue == palette[i].blue) {
            return i;
        }
    }
    return -1;
}

/**
 * Map an RGB color to the closest color in the DawnBringer 16 palette
 * Returns the index (0-15)
 */
int map_to_dawnbringer_index(const RGB *color) {
    int best_match = 0;
    int min_distance = INT32_MAX;

    for (int i = 0; i < 16; i++) {
        int distance = color_distance_squared(color, &DAWNBRINGER_PALETTE[i]);
        if (distance < min_distance) {
            min_distance = distance;
            best_match = i;
        }
    }

    return best_match;
}

/**
 * Check if all colors in a tile can be found in a palette
 * Returns true if all colors match, false otherwise
 */
bool palette_matches_colors(const RGB *colors, int num_colors, const Palette *palette) {
    for (int i = 0; i < num_colors; i++) {
        if (find_color_in_palette(&colors[i], palette->colors, 4) == -1) {
            return false;
        }
    }
    return true;
}

/* ===== PNG Loading Functions ===== */

/**
 * Load a PNG image from file
 * Returns NULL on error
 */
PNGImage* load_png_file(const char *file_path) {
    FILE *fp = fopen(file_path, "rb");
    if (!fp) {
        fprintf(stderr, "Error: Could not open file %s\n", file_path);
        return NULL;
    }

    // Check PNG signature
    unsigned char header[8];
    if (fread(header, 1, 8, fp) != 8 || png_sig_cmp(header, 0, 8)) {
        fprintf(stderr, "Error: %s is not a valid PNG file\n", file_path);
        fclose(fp);
        return NULL;
    }

    // Allocate image structure
    PNGImage *image = calloc(1, sizeof(PNGImage));
    if (!image) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        fclose(fp);
        return NULL;
    }

    // Create PNG read structures
    image->png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!image->png_ptr) {
        fprintf(stderr, "Error: png_create_read_struct failed\n");
        free(image);
        fclose(fp);
        return NULL;
    }

    image->info_ptr = png_create_info_struct(image->png_ptr);
    if (!image->info_ptr) {
        fprintf(stderr, "Error: png_create_info_struct failed\n");
        png_destroy_read_struct(&image->png_ptr, NULL, NULL);
        free(image);
        fclose(fp);
        return NULL;
    }

    // Set up error handling
    if (setjmp(png_jmpbuf(image->png_ptr))) {
        fprintf(stderr, "Error: Error during PNG file reading\n");
        png_destroy_read_struct(&image->png_ptr, &image->info_ptr, NULL);
        free(image);
        fclose(fp);
        return NULL;
    }

    // Read PNG info
    png_init_io(image->png_ptr, fp);
    png_set_sig_bytes(image->png_ptr, 8);
    png_read_info(image->png_ptr, image->info_ptr);

    image->width = png_get_image_width(image->png_ptr, image->info_ptr);
    image->height = png_get_image_height(image->png_ptr, image->info_ptr);
    image->color_type = png_get_color_type(image->png_ptr, image->info_ptr);
    image->bit_depth = png_get_bit_depth(image->png_ptr, image->info_ptr);

    // Convert all formats to 8-bit RGBA
    if (image->bit_depth == 16) {
        png_set_strip_16(image->png_ptr);
    }

    if (image->color_type == PNG_COLOR_TYPE_PALETTE) {
        png_set_palette_to_rgb(image->png_ptr);
    }

    if (image->color_type == PNG_COLOR_TYPE_GRAY && image->bit_depth < 8) {
        png_set_expand_gray_1_2_4_to_8(image->png_ptr);
    }

    if (png_get_valid(image->png_ptr, image->info_ptr, PNG_INFO_tRNS)) {
        png_set_tRNS_to_alpha(image->png_ptr);
    }

    if (image->color_type == PNG_COLOR_TYPE_RGB ||
        image->color_type == PNG_COLOR_TYPE_GRAY ||
        image->color_type == PNG_COLOR_TYPE_PALETTE) {
        png_set_filler(image->png_ptr, 0xFF, PNG_FILLER_AFTER);
    }

    if (image->color_type == PNG_COLOR_TYPE_GRAY ||
        image->color_type == PNG_COLOR_TYPE_GRAY_ALPHA) {
        png_set_gray_to_rgb(image->png_ptr);
    }

    png_read_update_info(image->png_ptr, image->info_ptr);

    // Allocate memory for image rows
    image->row_pointers = malloc(sizeof(png_bytep) * image->height);
    if (!image->row_pointers) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        png_destroy_read_struct(&image->png_ptr, &image->info_ptr, NULL);
        free(image);
        fclose(fp);
        return NULL;
    }

    for (int y = 0; y < image->height; y++) {
        image->row_pointers[y] = malloc(png_get_rowbytes(image->png_ptr, image->info_ptr));
        if (!image->row_pointers[y]) {
            // Clean up already allocated rows
            for (int i = 0; i < y; i++) {
                free(image->row_pointers[i]);
            }
            free(image->row_pointers);
            png_destroy_read_struct(&image->png_ptr, &image->info_ptr, NULL);
            free(image);
            fclose(fp);
            return NULL;
        }
    }

    // Read the image data
    png_read_image(image->png_ptr, image->row_pointers);
    fclose(fp);

    return image;
}

/**
 * Free PNG image resources
 */
void free_png_image(PNGImage *image) {
    if (!image) return;

    if (image->row_pointers) {
        for (int y = 0; y < image->height; y++) {
            free(image->row_pointers[y]);
        }
        free(image->row_pointers);
    }

    if (image->png_ptr && image->info_ptr) {
        png_destroy_read_struct(&image->png_ptr, &image->info_ptr, NULL);
    }

    free(image);
}

/**
 * Get RGB color from PNG image at specified coordinates
 */
RGB get_pixel_color(PNGImage *image, int x, int y) {
    RGB color;
    png_bytep row = image->row_pointers[y];
    png_bytep px = &(row[x * 4]); // Each pixel is 4 bytes (RGBA)

    color.red = px[0];
    color.green = px[1];
    color.blue = px[2];
    // Alpha channel (px[3]) is ignored

    return color;
}

/* ===== Palette Loading Functions ===== */

/**
 * Load palettes from a palette PNG file
 * Each row in the image represents one palette with 4 colors
 */
Palette* load_palettes(const char *palette_path, int *num_palettes) {
    PNGImage *palette_image = load_png_file(palette_path);
    if (!palette_image) {
        return NULL;
    }

    // Each row is one palette
    *num_palettes = palette_image->height;
    if (*num_palettes <= 0) {
        fprintf(stderr, "Error: No palettes found in palette file\n");
        free_png_image(palette_image);
        return NULL;
    }

    // Allocate palette array
    Palette *palettes = calloc(*num_palettes, sizeof(Palette));
    if (!palettes) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        free_png_image(palette_image);
        return NULL;
    }

    // Read each palette (row)
    for (int p = 0; p < *num_palettes; p++) {
        palettes[p].has_black = false;

        // Read up to 4 colors from the row
        int colors_to_read = (palette_image->width < 4) ? palette_image->width : 4;

        for (int c = 0; c < colors_to_read; c++) {
            RGB color = get_pixel_color(palette_image, c, p);
            palettes[p].colors[c] = color;

            if (is_black(&color)) {
                palettes[p].has_black = true;
            }
        }

        // Fill remaining slots with black if needed
        for (int c = colors_to_read; c < 4; c++) {
            palettes[p].colors[c] = (RGB){0, 0, 0};
            palettes[p].has_black = true;
        }
    }

    free_png_image(palette_image);
    return palettes;
}

/* ===== Tile Processing Functions ===== */

/**
 * Extract unique colors from a 16x16 tile
 * Returns the number of unique colors found
 */
int extract_tile_colors(PNGImage *image, int tile_x, int tile_y,
                       RGB *tile_pixels, RGB *unique_colors, bool *has_black) {
    int unique_count = 0;
    *has_black = false;

    // Read all pixels in the tile
    for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
            int img_x = tile_x * 16 + x;
            int img_y = tile_y * 16 + y;
            RGB color = get_pixel_color(image, img_x, img_y);

            // Store pixel color
            tile_pixels[y * 16 + x] = color;

            // Check if black
            if (is_black(&color)) {
                *has_black = true;
            }

            // Check if this color is already in our unique list
            bool found = false;
            for (int i = 0; i < unique_count; i++) {
                if (unique_colors[i].red == color.red &&
                    unique_colors[i].green == color.green &&
                    unique_colors[i].blue == color.blue) {
                    found = true;
                    break;
                }
            }

            // Add to unique colors if not found
            if (!found && unique_count < 16) {
                unique_colors[unique_count++] = color;
            }
        }
    }

    return unique_count;
}

/**
 * Find the best matching palette for a tile
 * Returns palette index or -1 if no suitable palette found
 */
int find_best_palette(const RGB *unique_colors, int num_colors, bool is_sprite,
                     const Palette *palettes, int num_palettes) {
    for (int p = 0; p < num_palettes; p++) {
        // Skip palettes with/without black based on sprite status
        if (is_sprite && !palettes[p].has_black) continue;
        if (!is_sprite && palettes[p].has_black) continue;

        // Check if all colors match this palette
        if (palette_matches_colors(unique_colors, num_colors, &palettes[p])) {
            return p;
        }
    }

    return -1; // No matching palette found
}

/**
 * Convert a tile's pixels to palette indices and encode as tile data
 */
void encode_tile_data(const RGB *tile_pixels, const Palette *palette, Tile *tile) {
    for (int row = 0; row < 16; row++) {
        uint16_t left_word = 0;
        uint16_t right_word = 0;

        // Process left half (columns 0-7)
        for (int col = 0; col < 8; col++) {
            const RGB *pixel = &tile_pixels[row * 16 + col];
            int color_index = find_color_in_palette(pixel, palette->colors, 4);
            if (color_index == -1) {
                color_index = 0; // Default to first color if not found
            }
            left_word = (left_word << 2) | color_index;
        }

        // Process right half (columns 8-15)
        for (int col = 8; col < 16; col++) {
            const RGB *pixel = &tile_pixels[row * 16 + col];
            int color_index = find_color_in_palette(pixel, palette->colors, 4);
            if (color_index == -1) {
                color_index = 0; // Default to first color if not found
            }
            right_word = (right_word << 2) | color_index;
        }

        tile->tile_data[row][0] = left_word;
        tile->tile_data[row][1] = right_word;
    }
}

/* ===== Assembly Output Functions ===== */

/**
 * Write palette definitions to assembly file
 */
void write_palette_definitions(FILE *out_file, const Palette *palettes, int num_palettes) {
    fprintf(out_file, "; Palette definitions (mapped to DawnBringer 16 indices)\n");
    fprintf(out_file, "Palettes:\n");

    for (int p = 0; p < num_palettes; p++) {
        fprintf(out_file, "db ");

        for (int c = 0; c < 4; c++) {
            int dawnbringer_index = map_to_dawnbringer_index(&palettes[p].colors[c]);
            fprintf(out_file, "0x%X", dawnbringer_index);
            if (c < 3) fprintf(out_file, ", ");
        }

        fprintf(out_file, " ; Palette %d", p);
        if (palettes[p].has_black) {
            fprintf(out_file, " (sprite palette)");
        }
        fprintf(out_file, "\n");
    }

    fprintf(out_file, "\n");
}

/**
 * Write tile data to assembly file
 * Skips the first tile as requested
 */
void write_tile_data(FILE *out_file, const Tile *tiles, int total_tiles) {
    fprintf(out_file, "; Tile data (first tile omitted)\n");
    fprintf(out_file, "Tiles:\n");

    // Start from tile 1, skipping tile 0
    for (int i = 1; i < total_tiles; i++) {
        fprintf(out_file, "; Tile %d\n", i);
        fprintf(out_file, "db 0x%02X ; palette index\n", tiles[i].palette_index);

        // Write each row of the tile
        for (int row = 0; row < 16; row++) {
            char left_bin[17], right_bin[17];

            uint16_t left = tiles[i].tile_data[row][0];
            uint16_t right = tiles[i].tile_data[row][1];

            // Convert to binary strings for readability
            for (int bit = 0; bit < 16; bit++) {
                left_bin[15 - bit] = ((left >> bit) & 1) ? '1' : '0';
                right_bin[15 - bit] = ((right >> bit) & 1) ? '1' : '0';
            }
            left_bin[16] = right_bin[16] = '\0';

            fprintf(out_file, "dw %sb, %sb ; row %d\n", left_bin, right_bin, row);
        }

        fprintf(out_file, "\n");
    }
}

/* ===== Main Conversion Function ===== */

/**
 * Convert PNG image to assembly format using provided palettes
 */
void convert_png_to_assembly(const char *png_path, const char *palette_path,
                           const char *output_path) {
    // Load palettes
    int num_palettes = 0;
    Palette *palettes = load_palettes(palette_path, &num_palettes);
    if (!palettes) {
        return;
    }

    printf("Loaded %d palettes from %s\n", num_palettes, palette_path);

    // Load main image
    PNGImage *image = load_png_file(png_path);
    if (!image) {
        free(palettes);
        return;
    }

    // Validate dimensions
    if (image->width % 16 != 0 || image->height % 16 != 0) {
        fprintf(stderr, "Error: Image dimensions must be multiples of 16\n");
        fprintf(stderr, "Current dimensions: %dx%d\n", image->width, image->height);
        free_png_image(image);
        free(palettes);
        return;
    }

    // Calculate tile counts
    int tiles_x = image->width / 16;
    int tiles_y = image->height / 16;
    int total_tiles = tiles_x * tiles_y;

    printf("Processing %dx%d tiles (%d total)\n", tiles_x, tiles_y, total_tiles);

    // Allocate tile array
    Tile *tiles = calloc(total_tiles, sizeof(Tile));
    if (!tiles) {
        fprintf(stderr, "Error: Memory allocation failed\n");
        free_png_image(image);
        free(palettes);
        return;
    }

    // Process each tile
    int failed_tiles = 0;
    RGB *tile_pixels = malloc(16 * 16 * sizeof(RGB));
    RGB *unique_colors = malloc(16 * sizeof(RGB));

    for (int ty = 0; ty < tiles_y; ty++) {
        for (int tx = 0; tx < tiles_x; tx++) {
            int tile_index = ty * tiles_x + tx;
            bool has_black;

            // Extract tile colors
            int unique_count = extract_tile_colors(image, tx, ty,
                                                  tile_pixels, unique_colors, &has_black);

            // Determine if this is a sprite tile
            tiles[tile_index].is_sprite = has_black;

            // Find best matching palette
            int best_palette = find_best_palette(unique_colors, unique_count, has_black,
                                               palettes, num_palettes);

            if (best_palette == -1) {
                fprintf(stderr, "Warning: No matching palette for tile (%d,%d), "
                       "using palette 0\n", tx, ty);
                best_palette = 0;
                failed_tiles++;
            }

            tiles[tile_index].palette_index = best_palette;

            // Encode tile data
            encode_tile_data(tile_pixels, &palettes[best_palette], &tiles[tile_index]);
        }
    }

    free(tile_pixels);
    free(unique_colors);

    // Write output file
    FILE *out_file = fopen(output_path, "w");
    if (!out_file) {
        fprintf(stderr, "Error: Cannot open output file %s\n", output_path);
        free(tiles);
        free_png_image(image);
        free(palettes);
        return;
    }

    // Write assembly header
    fprintf(out_file, "; Generated from %s\n", png_path);
    fprintf(out_file, "; Total tiles: %d (first tile omitted)\n", total_tiles - 1);
    fprintf(out_file, "; Tiles with palette issues: %d\n\n", failed_tiles);

    // Write palette definitions
    write_palette_definitions(out_file, palettes, num_palettes);

    // Write tile data (skipping first tile)
    write_tile_data(out_file, tiles, total_tiles);

    // Write terminator as the very last line
    fprintf(out_file, "db 0xFF ; Terminator\n");

    // Clean up
    fclose(out_file);
    free(tiles);
    free_png_image(image);
    free(palettes);

    printf("\nConversion complete!\n");
    printf("- Tiles processed: %d\n", total_tiles);
    printf("- Tiles output: %d (first tile omitted)\n", total_tiles - 1);
    printf("- Tiles with palette issues: %d\n", failed_tiles);
    printf("- Output written to: %s\n", output_path);
}

/* ===== Main Function ===== */

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("PNG to Assembly Converter\n");
        printf("Usage: %s <input.png> <palettes.png> <output.asm>\n", argv[0]);
        printf("\n");
        printf("Arguments:\n");
        printf("  input.png     - Tileset image (dimensions must be multiples of 16)\n");
        printf("  palettes.png  - Palette definitions (4 colors per row)\n");
        printf("  output.asm    - Output assembly file\n");
        printf("\n");
        printf("Notes:\n");
        printf("  - First tile in the tileset will be omitted from output\n");
        printf("  - Tiles with black color are treated as sprites\n");
        printf("  - Colors are mapped to DawnBringer 16 palette indices\n");
        return 1;
    }

    convert_png_to_assembly(argv[1], argv[2], argv[3]);
    return 0;
}
