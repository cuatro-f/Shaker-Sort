AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab2.s
OBJS = $(SRCS:.s=.o)

EXE = lab

# Параметр сортировки (по умолчанию - по возрастанию)
SORT_ORDER ?= asc

# Определение макроса для NASM
ifeq ($(SORT_ORDER), asc)
  ASFLAGS += -D SORT_ORDER_ASC
else ifeq ($(SORT_ORDER), desc)
  ASFLAGS += -D SORT_ORDER_DESC
else
  $(error Invalid SORT_ORDER. Use 'asc' or 'desc')
endif

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@
