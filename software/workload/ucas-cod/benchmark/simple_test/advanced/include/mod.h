#pragma once

static inline int mod(int x, int y)
{
    if (y <= 0) {
        return 0;
    }

    while (x >= y) {
        x -= y;
    }

    return x;
}
