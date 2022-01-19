#pragma once

#include <stdint.h>

enum {
  AND = 0, OR = 1, ADD = 2, SUB = 6, SLT = 7
};

struct ALU_result {
  int type;
  uint32_t a;
  uint32_t b;
  uint32_t result;
  uint32_t overflow;
  uint32_t carry;
  uint32_t zero;
};
