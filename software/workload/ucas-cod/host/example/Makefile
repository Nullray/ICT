OUT := elf/loader_$(ROLE_ID)

SRCS := loader
OBJS := $(foreach obj,$(SRCS),$(obj).o)

CC := $(CROSS_COMPILE)gcc

all: $(OBJS)
	@mkdir -p elf
	$(CC) -o $(OUT) $(OBJS)

%.o: %.c
	$(CC) -DROLE_ID=$(ROLE_ID) -c -o $@ $<

clean:
	@rm -f $(OBJS)


