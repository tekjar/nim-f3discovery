# nim-f3discovery
Highlevel pacakge to play with f3 discovery board using nim lang


#### DEMO INSTRUCTIONS
---------------------

Clone this repo run these commands to setup the directory for development

```
make download
make initialize
make cube
```

Compile blinky

```
nim c -c --gc:none --cpu:arm --os:standalone --deadCodeElim:on --dynlibOverride:stm32f3 --passL:../cube/libstm32f3.a blinky.nim
```

Create binary to flash from generated c sources

NOTE: Do below steps first. These need to be fixed and I don't know how yet. Please help me if you are an experienced nim programmer

Add these header files at the top in `blinky.c`
```
#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"
```

Change `HAL_Delay` declaration to (Replace `NU32` with `uint32_t`)

```
N_CDECL(void, HAL_Delay)(uint32_t millis);
``


```
make
```

Flash

```
st-flash write demo.bin 0x8000000
```
