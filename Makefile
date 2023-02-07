ASM=nasm
# GCC=x86_64-elf-gcc
GCC=i386-elf-gcc

SRCDIR = src
BUILD_DIR = dist

# Source files
# SOURCES = $(wildcard $(SRCDIR)/*.c)
SOURCES := $(shell find src/kernel -name '*.c')
ASMSOURCES = $(shell find src/kernel -name '*.asm')
ASMDIRS = $(sort $(dir $(ASMSOURCES)))
DIRS = $(sort $(dir $(SOURCES)))

OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(patsubst %.c, %.o, $(SOURCES))))
ASMOBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(patsubst %.asm, %_asm.o, $(ASMSOURCES))))

vpath %.asm $(ASMDIRS)
vpath %.c $(DIRS)


#Flags
CFLAGS = -std=c99 -g -ffreestanding -nostdlib
ASFLAGS = -f elf32
LDFLAGS = -T $(SRCDIR)/kernel/linker.ld -nostdlib

.PHONY: all clean

all: $(BUILD_DIR)/kernel.bin
        $(ASM) ./src/bootloader/boot.asm -f bin -o ./dist/boot.bin
        cat ./dist/boot.bin ./dist/kernel.bin >> "./dist/OS.bin"
        dd if=/dev/zero of=./dist/main.img bs=512 count=2880
        dd if=./dist/OS.bin of=./dist/main.img conv=notrunc



info: $(ASMOBJECTS)
        # @echo "sources $(SOURCES)"
        @echo "sources $(ASMOBJECTS)"

$(BUILD_DIR)/kernel.bin: $(OBJECTS) $(ASMOBJECTS)
        i386-elf-ld -o $@ $(LDFLAGS) $(OBJECTS) $(ASMOBJECTS)


$(OBJECTS): $(BUILD_DIR)/%.o : %.c
        $(GCC) $(CFLAGS) -c $< -o $@ -m32

# $(ASMOBJECTS): $(BUILD_DIR)/%_asm.o : $(ASMSOURCES)

$(ASMOBJECTS): $(BUILD_DIR)/%_asm.o : %.asm
        $(ASM) $(ASFLAGS) $< -o $@

clean:
        rm -rf $(BUILD_DIR)/*