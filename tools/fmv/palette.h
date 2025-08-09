typedef struct {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
} RGB;

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
