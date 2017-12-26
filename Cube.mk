# STM32 Makefile for GNU toolchain and openocd
#
# This makefile builds a static library from HAL sources


TARGET     = libstm32f3.a

###############################################################################
# Architecture definitions

# Take a look into $(CUBE_DIR)/Drivers/BSP for available BSPs
BOARD      = STM32F3-Discovery
BOARD_UC   = STM32F3-Discovery
BOARD_LC   = stm32f3_discovery
BSP_BASE   = $(BOARD_LC)

# MCU family and type in various capitalizations o_O
MCU_FAMILY_LC = stm32f3xx
MCU_FAMILY_UC = STM32F3xx
MCU_LC     = stm32f303xc
MCU_MC     = STM32F303xC
MCU_UC     = STM32F303VC

###############################################################################
# Dirs

CUBE_DIR   = cube
INIT_DIR   = init
BSP_DIR    = $(CUBE_DIR)/Drivers/BSP/$(BOARD_UC)
HAL_DIR    = $(CUBE_DIR)/Drivers/$(MCU_FAMILY_UC)_HAL_Driver
CMSIS_DIR  = $(CUBE_DIR)/Drivers/CMSIS
DEV_DIR    = $(CMSIS_DIR)/Device/ST/$(MCU_FAMILY_UC)

###############################################################################
# Build sources
# Basic hal files

SRCS      += stm32f3xx_hal_rcc.c stm32f3xx_hal_rcc_ex.c stm32f3xx_hal.c stm32f3xx_hal_cortex.c stm32f3xx_hal_gpio.c stm32f3xx_hal_pwr_ex.c $(BSP_BASE).c
SRCS      += system_$(MCU_FAMILY_LC).c $(MCU_FAMILY_LC)_it.c clock_init.c 
###############################################################################
# Include search paths (-I)

INCS      += -I$(BSP_DIR)
INCS      += -I$(CMSIS_DIR)/Include
INCS      += -I$(DEV_DIR)/Include
INCS      += -I$(HAL_DIR)/Inc
INCS      += -I$(INIT_DIR)

###############################################################################
# Library search paths

LIBS       = -L$(CMSIS_DIR)/Lib

###############################################################################
# Source search paths
VPATH     += $(BSP_DIR)
VPATH     += $(HAL_DIR)/Src
VPATH     += $(DEV_DIR)/Source/
VPATH     += $(INIT_DIR)

###############################################################################
# Toolchain

PREFIX     = arm-none-eabi
CC         = $(PREFIX)-gcc
AR         = $(PREFIX)-ar
OBJCOPY    = $(PREFIX)-objcopy
OBJDUMP    = $(PREFIX)-objdump
SIZE       = $(PREFIX)-size
GDB        = $(PREFIX)-gdb

OCD        = openocd

###############################################################################
# Build options

# Defines
DEFS       = -D$(MCU_MC) -DUSE_HAL_DRIVER

# Debug specific definitions for semihosting
DEFS       += -DUSE_DBPRINTF

# Compiler flags
CFLAGS     = -Wall -g -std=c99 -Os
CFLAGS    += -mlittle-endian -mcpu=cortex-m4 -march=armv7e-m -mthumb
CFLAGS    += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS    += -ffunction-sections -fdata-sections
CFLAGS    += $(INCS) $(DEFS)

# Linker flags
LDFLAGS    = -Wl,--gc-sections -Wl,-Map=$(TARGET).map $(LIBS)

# Enable Semihosting
LDFLAGS   += --specs=rdimon.specs -lc -lrdimon

OBJS       = $(addprefix obj/,$(SRCS:.c=.o))
DEPS       = $(addprefix dep/,$(SRCS:.c=.d))

# Prettify output
V = 0
ifeq ($V, 0)
	Q = @
	P = > /dev/null
endif

###################################################
# Build

.PHONY: all dirs program debug initialize clean

all: initialize $(TARGET)

-include $(DEPS)

dirs: dep obj

dep obj:
	@echo "[MKDIR]   $@"
	$Qmkdir -p $@

obj/%.o : %.c | dirs
	@echo "[CC]      $(notdir $<)"
	$Q$(CC) $(CFLAGS) -c -o $@ $< -MMD -MF dep/$(*F).d

$(TARGET): $(OBJS)
	@echo "[AR] $(TARGET)"
	$(AR) -r $@ $(OBJS)

initialize:
	cp $(HAL_DIR)/Inc/$(MCU_FAMILY_LC)_hal_conf_template.h $(HAL_DIR)/Inc/$(MCU_FAMILY_LC)_hal_conf.h
	@echo "[CP]   $(CUBE_DIR)/Projects/$(BOARD_UC)/Templates/Src/*.c" ; cp $(CUBE_DIR)/Projects/$(BOARD_UC)/Templates/Src/*.c $(INIT_DIR)
	@echo "[CP]   $(CUBE_DIR)/Projects/$(BOARD_UC)/Templates/Inc/*.h" ; cp $(CUBE_DIR)/Projects/$(BOARD_UC)/Templates/Inc/*.h    $(INIT_DIR)

clean:
	@echo "[RM]      $(TARGET).bin"; rm -f $(TARGET).bin
	@echo "[RM]      $(TARGET).elf"; rm -f $(TARGET).elf
	@echo "[RM]      $(TARGET).map"; rm -f $(TARGET).map
	@echo "[RM]      $(TARGET).lst"; rm -f $(TARGET).lst
	@echo "[RM]      $(TARGET)"    ; rm -f $(TARGET)
	@echo "[RMDIR]   dep"          ; rm -fr dep
	@echo "[RMDIR]   obj"          ; rm -fr obj