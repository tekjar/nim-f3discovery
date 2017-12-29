# A name common to all output files (elf, map, hex, bin, lst)
TARGET     = blinky
NIM_PATH   = /usr/local/Cellar/nim/0.17.2/nim
###############################################################################
# Architecture definitions

# Take a look into $(CUBE_DIR)/Drivers/BSP for available BSPs
BOARD      = STM32F3-Discovery
BOARD_UC   = STM32F3-Discovery
BOARD_LC   = stm32f3_discovery
BSP_BASE   = $(BOARD_LC)

OCDFLAGS   = -f board/stm32f3discovery.cfg
GDBFLAGS   =

# MCU family and type in various capitalizations o_O
MCU_FAMILY_LC = stm32f3xx
MCU_FAMILY_UC = STM32F3xx
MCU_LC     = stm32f303xc
MCU_MC     = STM32F303xC
MCU_UC     = STM32F303VC

###############################################################################
# Directories & cube sources url

OCD_DIR    = /usr/share/openocd/scripts
CUBE_DIR   = cube
INIT_DIR   = init
BSP_DIR    = $(CUBE_DIR)/Drivers/BSP/$(BOARD_UC)
HAL_DIR    = $(CUBE_DIR)/Drivers/$(MCU_FAMILY_UC)_HAL_Driver
CMSIS_DIR  = $(CUBE_DIR)/Drivers/CMSIS
DEV_DIR    = $(CMSIS_DIR)/Device/ST/$(MCU_FAMILY_UC)

CUBE_URL   = www.st.com/resource/en/firmware/stm32cubef3.zip

###############################################################################
# Linker file

LDFILE = $(MCU_UC)Tx_FLASH.ld
STARTUPFILE = startup_$(MCU_LC).s

###############################################################################
# Hard includes. Other header files depends on some definitions in these headers

HARD_INCLUDE = -include stm32f3xx_hal.h -include stm32f3_discovery.h
###############################################################################
# Build sources
# Your C files from the /src directory

SRCS       = blinky.c f3discovery.c stdlib_system.c
SRCS      += system_$(MCU_FAMILY_LC).c
SRCS      += $(MCU_FAMILY_LC)_it.c

###############################################################################
# Include search paths (-I)

INCS      += -I$(BSP_DIR)
INCS      += -I$(CMSIS_DIR)/Include
INCS      += -I$(DEV_DIR)/Include
INCS      += -I$(HAL_DIR)/Inc
INCS      += -I$(NIM_PATH)/lib

###############################################################################
# Source search paths

VPATH      = nimcache
VPATH     += $(BSP_DIR)
VPATH     += $(HAL_DIR)/Src
VPATH     += $(DEV_DIR)/Source/

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

# Make sure that nimbase.h user stdint definitions from arm gcc stdint.h
# https://github.com/nim-lang/Nim/blob/devel/lib/nimbase.h#L311
DEFS       += -D HAVE_STDINT_H


# Compiler flags
CFLAGS     = -Wall -g -std=c99 -Os
CFLAGS    += -mlittle-endian -mcpu=cortex-m4 -march=armv7e-m -mthumb
CFLAGS    += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS    += -ffunction-sections -fdata-sections
CFLAGS    += $(INCS) $(DEFS)

# Linker flags
LDFLAGS    = -Wl,--gc-sections -Wl,-Map=$(TARGET).map $(LIBS) -T$(MCU_LC).ld

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

.PHONY: all cube dirs program debug template clean

all: cube $(TARGET).bin

-include $(DEPS)

cube:
	$(MAKE) -f Cube.mk

dirs: dep obj cube
dep obj:
	@echo "[MKDIR]   $@"
	$Qmkdir -p $@

obj/%.o : %.c | dirs
	@echo "[CC] $(CC) $(CFLAGS) $(notdir $<)"
	$Q$(CC) $(CFLAGS) $(HARD_INCLUDE) -c -o $@ $< -MMD -MF dep/$(*F).d

$(TARGET).elf: $(OBJS)
	@echo "[LD]      $(TARGET).elf"
	$Q$(CC) $(CFLAGS) $(LDFLAGS) startup_$(MCU_LC).s $^ -o $@ -L. -lstm32f3
	@echo "[OBJDUMP] $(TARGET).lst"
	$Q$(OBJDUMP) -St $(TARGET).elf >$(TARGET).lst
	@echo "[SIZE]    $(TARGET).elf"
	$(SIZE) $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	@echo "[OBJCOPY] $(TARGET).bin"
	$Q$(OBJCOPY) -O binary $< $@

openocd:
	$(OCD) -s $(OCD_DIR) $(OCDFLAGS)

program: all
	$(OCD) -s $(OCD_DIR) $(OCDFLAGS) -c "program $(TARGET).elf verify reset"

debug:
	@if ! nc -z localhost 3333; then \
		echo "\n\t[Error] OpenOCD is not running! Start it with: 'make openocd'\n"; exit 1; \
	else \
		$(GDB)  -ex "target extended localhost:3333" \
			-ex "monitor arm semihosting enable" \
			-ex "monitor reset halt" \
			-ex "load" \
			-ex "monitor reset init" \
			$(GDBFLAGS) $(TARGET).elf; \
	fi

download: erase
	wget -O /tmp/cube.zip $(CUBE_URL)
	unzip /tmp/cube.zip
	mv STM32Cube* $(CUBE_DIR)
	chmod -R u+w $(CUBE_DIR)
	rm -f /tmp/cube.zip

initialize:
	@echo "[CP]      Cube.mk"        ; cp Cube.mk cube
	@echo "[CP]      $(STARTUPFILE)" ; cp -i $(DEV_DIR)/Source/Templates/gcc/$(STARTUPFILE) .
	@echo "[CP]      $(LDFILE)"      ; cp -i $(CUBE_DIR)/Projects/$(BOARD)/Examples/GPIO/GPIO_IOToggle/SW4STM32/$(BOARD_UC)/$(LDFILE) $(MCU_LC).ld

clean:
	@echo "[RM]      $(TARGET).bin"  ; rm -f $(TARGET).bin
	@echo "[RM]      $(TARGET).elf"  ; rm -f $(TARGET).elf
	@echo "[RM]      $(TARGET).map"  ; rm -f $(TARGET).map
	@echo "[RM]      $(TARGET).lst"  ; rm -f $(TARGET).lst
	@echo "[RMDIR]   dep"            ; rm -fr dep
	@echo "[RMDIR]   obj"            ; rm -fr obj
	@echo "[RM]      $(STARTUPFILE)" ; rm -fr $(STARTUPFILE)
	@echo "[RM]      $(MCU_LC).ld"      ; rm -fr $(MCU_LC).ld
	@echo "[RM]      libstm32f3.a"      ; rm -fr libstm32f3.a


erase: clean
	@echo "[RMDIR]      $(CUBE_DIR)"      ; rm -fr $(CUBE_DIR)
	

