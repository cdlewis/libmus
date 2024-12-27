# Expects the following to be defined:
# COMPILER_DIR: path to gcc-kmc
# ULTRA_DIR: path to libultra

BUILD_DIR=build
CROSS ?= mips-linux-gnu-
BUILD_DEFINES   += -DVERSION_US=1

OBJDUMP         := $(CROSS)objdump
CC              := COMPILER_PATH=$(COMPILER_DIR) $(COMPILER_DIR)/gcc
STRIP      			:= $(CROSS)strip
IINC       			:= -I$(ULTRA_DIR)/include -I$(ULTRA_DIR)/include/gcc -I$(ULTRA_DIR)/include/PR -I$(ULTRA_DIR)/src -Ilibmus/src
ABIFLAG         ?= -mabi=32 -mgp32 -mfp32
CFLAGS          := -nostdinc -fno-PIC -mno-abicalls -G 0
MIPS_VERSION    := -mips3
WARNINGS        := -w
COMMON_DEFINES  := -D_MIPS_SZLONG=32 -D__USE_ISOC99
GBI_DEFINES     := -DF3DEX_GBI_2
RELEASE_DEFINES := -DNDEBUG -D_FINALROM
AS_DEFINES      := -D_LANGUAGE_ASSEMBLY -DMIPSEB -D_ULTRA64 -D_MIPS_SIM=1
C_DEFINES       := -D_LANGUAGE_C

LIBMUS_DIRS   += $(shell find src -type d )

O_FILES       += $(BUILD_DIR)/src/aud_dma.o \
                 $(BUILD_DIR)/src/aud_sched.o \
                 $(BUILD_DIR)/src/lib_memory.o \
                 $(BUILD_DIR)/src/player.o \
                 $(BUILD_DIR)/src/aud_samples.o \
                 $(BUILD_DIR)/src/aud_thread.o \
                 $(BUILD_DIR)/src/player_fx.o

$(BUILD_DIR)/src/%.o:   MIPS_VERSION := -mips3
$(BUILD_DIR)/src/%.o:   CFLAGS += -Wa,--force-n64align
$(BUILD_DIR)/src/player.o:     DBGFLAGS :=
$(BUILD_DIR)/src/player_fx.o:  CFLAGS += -O3 -g0

all: $(BUILD_DIR)/libmus.a

clean:
	$(RM) -r $(BUILD_DIR)

distclean: clean

.PHONY: all clean distclean
.DEFAULT_GOAL := all
# Prevent removing intermediate files
.SECONDARY:

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC) -c $(IINC) -I $(dir $*) $(WARNINGS) $(BUILD_DEFINES) $(COMMON_DEFINES) $(RELEASE_DEFINES) $(GBI_DEFINES) $(C_DEFINES) $(ABIFLAG) $(CFLAGS) $(MIPS_VERSION) $(OPTFLAGS) $(DBGFLAGS) -o $@ $<
	$(OBJDUMP_CMD)

$(BUILD_DIR)/libmus.a: $(O_FILES)
	ar rcs $(BUILD_DIR)/libmus.a $(O_FILES)