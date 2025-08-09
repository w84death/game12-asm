#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <png.h>
#include "palette.h"

#define WIDTH 320
#define HEIGHT 200

typedef struct {
    uint8_t *data;
    size_t size;
    size_t capacity;
} CompressedData;

// Find closest palette color index for RGB value
uint8_t find_closest_color(uint8_t r, uint8_t g, uint8_t b) {
    int best_index = 0;
    int best_distance = INT_MAX;
    
    for (int i = 0; i < 16; i++) {
        int dr = r - DAWNBRINGER_PALETTE[i].red;
        int dg = g - DAWNBRINGER_PALETTE[i].green;
        int db = b - DAWNBRINGER_PALETTE[i].blue;
        int distance = dr*dr + dg*dg + db*db;
        
        if (distance < best_distance) {
            best_distance = distance;
            best_index = i;
        }
    }
    
    return best_index;
}

// Initialize compressed data structure
void init_compressed_data(CompressedData *cd) {
    cd->capacity = WIDTH * HEIGHT; // Start with uncompressed size
    cd->data = malloc(cd->capacity);
    cd->size = 0;
}

// Add byte to compressed data
void add_byte(CompressedData *cd, uint8_t byte) {
    if (cd->size >= cd->capacity) {
        cd->capacity *= 2;
        cd->data = realloc(cd->data, cd->capacity);
    }
    cd->data[cd->size++] = byte;
}

// Compress a scanline using RLE
void compress_scanline(uint8_t *line, CompressedData *cd) {
    int x = 0;
    
    while (x < WIDTH) {
        uint8_t current_color = line[x];
        int run_length = 1;
        
        // Count consecutive pixels of the same color
        while (x + run_length < WIDTH && line[x + run_length] == current_color) {
            run_length++;
            // Maximum run length is 255
            if (run_length >= 255) break;
        }
        
        // Write color index (1 byte)
        add_byte(cd, current_color);
        // Write run length (1 byte)
        add_byte(cd, run_length);
        
        x += run_length;
    }
    
    // Add end-of-line marker (color 0xFF with length 0 to indicate EOL)
    // This helps the assembly code know when a line ends
    add_byte(cd, 0xFF);
    add_byte(cd, 0x00);
}

// Load PNG and convert to indexed color
uint8_t* load_png(const char *filename) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        fprintf(stderr, "Error: Cannot open file %s\n", filename);
        return NULL;
    }
    
    // Check PNG signature
    uint8_t header[8];
    fread(header, 1, 8, fp);
    if (png_sig_cmp(header, 0, 8)) {
        fprintf(stderr, "Error: Not a PNG file\n");
        fclose(fp);
        return NULL;
    }
    
    // Create PNG structures
    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png_ptr) {
        fclose(fp);
        return NULL;
    }
    
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr) {
        png_destroy_read_struct(&png_ptr, NULL, NULL);
        fclose(fp);
        return NULL;
    }
    
    if (setjmp(png_jmpbuf(png_ptr))) {
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        fclose(fp);
        return NULL;
    }
    
    // Initialize PNG reading
    png_init_io(png_ptr, fp);
    png_set_sig_bytes(png_ptr, 8);
    png_read_info(png_ptr, info_ptr);
    
    int width = png_get_image_width(png_ptr, info_ptr);
    int height = png_get_image_height(png_ptr, info_ptr);
    int color_type = png_get_color_type(png_ptr, info_ptr);
    int bit_depth = png_get_bit_depth(png_ptr, info_ptr);
    
    if (width != WIDTH || height != HEIGHT) {
        fprintf(stderr, "Error: Image must be 320x200, got %dx%d\n", width, height);
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        fclose(fp);
        return NULL;
    }
    
    // Convert to RGB if necessary
    if (color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_palette_to_rgb(png_ptr);
    if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
        png_set_expand_gray_1_2_4_to_8(png_ptr);
    if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS))
        png_set_tRNS_to_alpha(png_ptr);
    if (bit_depth == 16)
        png_set_strip_16(png_ptr);
    if (color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_gray_to_rgb(png_ptr);
    
    png_read_update_info(png_ptr, info_ptr);
    
    // Allocate memory for image data
    png_bytep *row_pointers = malloc(sizeof(png_bytep) * height);
    for (int y = 0; y < height; y++) {
        row_pointers[y] = malloc(png_get_rowbytes(png_ptr, info_ptr));
    }
    
    png_read_image(png_ptr, row_pointers);
    
    // Convert to indexed color
    uint8_t *indexed = malloc(WIDTH * HEIGHT);
    int channels = png_get_channels(png_ptr, info_ptr);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t r = row_pointers[y][x * channels];
            uint8_t g = row_pointers[y][x * channels + 1];
            uint8_t b = row_pointers[y][x * channels + 2];
            
            indexed[y * WIDTH + x] = find_closest_color(r, g, b);
        }
    }
    
    // Clean up
    for (int y = 0; y < height; y++) {
        free(row_pointers[y]);
    }
    free(row_pointers);
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fclose(fp);
    
    return indexed;
}

// Write compressed data as assembly data
void write_asm_output(CompressedData *cd, const char *output_filename, const char *label_name) {
    FILE *fp = fopen(output_filename, "w");
    if (!fp) {
        fprintf(stderr, "Error: Cannot create output file %s\n", output_filename);
        return;
    }
    
    // Write assembly header
    fprintf(fp, "; Compressed VGA image data\n");
    fprintf(fp, "; Format: [color_index][run_length] pairs\n");
    fprintf(fp, "; End of line marked with 0xFF, 0x00\n");
    fprintf(fp, "; Total size: %zu bytes\n\n", cd->size);
    
    fprintf(fp, "%s:\n", label_name);
    
    // Write data as DB statements (16 bytes per line for readability)
    for (size_t i = 0; i < cd->size; i++) {
        if (i % 16 == 0) {
            if (i > 0) fprintf(fp, "\n");
            fprintf(fp, "    db ");
        } else {
            fprintf(fp, ", ");
        }
        fprintf(fp, "0%02Xh", cd->data[i]);
    }
    fprintf(fp, "\n\n");
    
    fprintf(fp, "%s_size equ %zu\n", label_name, cd->size);
    fprintf(fp, "%s_end:\n", label_name);
    
    fclose(fp);
}

// Write raw binary output
void write_bin_output(CompressedData *cd, const char *output_filename) {
    FILE *fp = fopen(output_filename, "wb");
    if (!fp) {
        fprintf(stderr, "Error: Cannot create output file %s\n", output_filename);
        return;
    }
    
    fwrite(cd->data, 1, cd->size, fp);
    fclose(fp);
}

void print_usage(const char *program_name) {
    printf("Usage: %s <input.png> <output> [options]\n", program_name);
    printf("Options:\n");
    printf("  -asm <label>  Output as assembly file with specified label (default: image_data)\n");
    printf("  -bin          Output as raw binary file (default)\n");
    printf("  -stats        Show compression statistics\n");
    printf("\nExample:\n");
    printf("  %s input.png output.asm -asm my_image\n", program_name);
    printf("  %s input.png output.bin -bin\n", program_name);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        print_usage(argv[0]);
        return 1;
    }
    
    const char *input_file = argv[1];
    const char *output_file = argv[2];
    int output_asm = 0;
    int show_stats = 0;
    char *label_name = "image_data";
    
    // Parse command line arguments
    for (int i = 3; i < argc; i++) {
        if (strcmp(argv[i], "-asm") == 0) {
            output_asm = 1;
            if (i + 1 < argc && argv[i + 1][0] != '-') {
                label_name = argv[++i];
            }
        } else if (strcmp(argv[i], "-bin") == 0) {
            output_asm = 0;
        } else if (strcmp(argv[i], "-stats") == 0) {
            show_stats = 1;
        }
    }
    
    // Load and convert PNG
    printf("Loading PNG: %s\n", input_file);
    uint8_t *indexed_image = load_png(input_file);
    if (!indexed_image) {
        return 1;
    }
    
    // Compress the image
    printf("Compressing image...\n");
    CompressedData compressed;
    init_compressed_data(&compressed);
    
    for (int y = 0; y < HEIGHT; y++) {
        compress_scanline(&indexed_image[y * WIDTH], &compressed);
    }
    
    // Output the compressed data
    if (output_asm) {
        printf("Writing assembly output: %s\n", output_file);
        write_asm_output(&compressed, output_file, label_name);
    } else {
        printf("Writing binary output: %s\n", output_file);
        write_bin_output(&compressed, output_file);
    }
    
    // Show statistics if requested
    if (show_stats) {
        size_t uncompressed_size = WIDTH * HEIGHT;
        float compression_ratio = (float)uncompressed_size / compressed.size;
        printf("\nCompression Statistics:\n");
        printf("  Original size: %zu bytes\n", uncompressed_size);
        printf("  Compressed size: %zu bytes\n", compressed.size);
        printf("  Compression ratio: %.2f:1 (%.1f%%)\n", 
               compression_ratio, (1.0 - 1.0/compression_ratio) * 100);
    }
    
    // Clean up
    free(indexed_image);
    free(compressed.data);
    
    printf("Done!\n");
    return 0;
}