const libName* = "libstm32f3.a"

const
  GPIO_PIN_0* = (0x00000001)    ##  Pin 0 selected
  GPIO_PIN_1* = (0x00000002)    ##  Pin 1 selected
  GPIO_PIN_2* = (0x00000004)    ##  Pin 2 selected
  GPIO_PIN_3* = (0x00000008)    ##  Pin 3 selected
  GPIO_PIN_4* = (0x00000010)    ##  Pin 4 selected
  GPIO_PIN_5* = (0x00000020)    ##  Pin 5 selected
  GPIO_PIN_6* = (0x00000040)    ##  Pin 6 selected
  GPIO_PIN_7* = (0x00000080)    ##  Pin 7 selected
  GPIO_PIN_8* = (0x00000100)    ##  Pin 8 selected
  GPIO_PIN_9* = (0x00000200)    ##  Pin 9 selected
  GPIO_PIN_10* = (0x00000400)   ##  Pin 10 selected
  GPIO_PIN_11* = (0x00000800)   ##  Pin 11 selected
  GPIO_PIN_12* = (0x00001000)   ##  Pin 12 selected
  GPIO_PIN_13* = (0x00002000)   ##  Pin 13 selected
  GPIO_PIN_14* = (0x00004000)   ##  Pin 14 selected
  GPIO_PIN_15* = (0x00008000)   ##  Pin 15 selected

const
  GPIO_MODE_INPUT* = (0x00000000) ## !< Input Floating Mode
  GPIO_MODE_OUTPUT_PP* = (0x00000001) ## !< Output Push Pull Mode
  GPIO_MODE_OUTPUT_OD* = (0x00000011) ## !< Output Open Drain Mode
  GPIO_MODE_AF_PP* = (0x00000002) ## !< Alternate Function Push Pull Mode
  GPIO_MODE_AF_OD* = (0x00000012) ## !< Alternate Function Open Drain Mode
  GPIO_MODE_ANALOG* = (0x00000003) ## !< Analog Mode
  GPIO_MODE_IT_RISING* = (0x10110000) ## !< External Interrupt Mode with Rising edge trigger detection
  GPIO_MODE_IT_FALLING* = (0x10210000) ## !< External Interrupt Mode with Falling edge trigger detection
  GPIO_MODE_IT_RISING_FALLING* = (0x10310000) ## !< External Interrupt Mode with Rising/Falling edge trigger detection
  GPIO_MODE_EVT_RISING* = (0x10120000) ## !< External Event Mode with Rising edge trigger detection
  GPIO_MODE_EVT_FALLING* = (0x10220000) ## !< External Event Mode with Falling edge trigger detection
  GPIO_MODE_EVT_RISING_FALLING* = (0x10320000) ## !< External Event Mode with Rising/Falling edge trigger detection

const
  GPIO_SPEED_FREQ_LOW* = (0x00000000) ## !< range up to 2 MHz, please refer to the product datasheet
  GPIO_SPEED_FREQ_MEDIUM* = (0x00000001) ## !< range  4 MHz to 10 MHz, please refer to the product datasheet
  GPIO_SPEED_FREQ_HIGH* = (0x00000003) ## !< range 10 MHz to 50 MHz, please refer to the product datasheet

## *
##  @}
## 
## * @defgroup GPIO_pull GPIO pull
##  @brief GPIO Pull-Up or Pull-Down Activation
##  @{
## 

const
  GPIO_NOPULL* = (0x00000000)   ## !< No Pull-up or Pull-down activation
  GPIO_PULLUP* = (0x00000001)   ## !< Pull-up activation
  GPIO_PULLDOWN* = (0x00000002) ## !< Pull-down activation

const
  FLASH_BASE* = (0x08000000) ## !< FLASH base address in the alias region
  CCMDATARAM_BASE* = (0x10000000) ## !< CCM(core coupled memory) data RAM base address in the alias region
  SRAM_BASE* = (0x20000000) ## !< SRAM base address in the alias region
  PERIPH_BASE* = (0x40000000) ## !< Peripheral base address in the alias region
  SRAM_BB_BASE* = (0x22000000) ## !< SRAM base address in the bit-band region
  PERIPH_BB_BASE* = (0x42000000) ## !< Peripheral base address in the bit-band region

## !< Peripheral memory map

const
  APB1PERIPH_BASE* = PERIPH_BASE
  APB2PERIPH_BASE* = (PERIPH_BASE + 0x00010000)
  AHB1PERIPH_BASE* = (PERIPH_BASE + 0x00020000)
  AHB2PERIPH_BASE* = (PERIPH_BASE + 0x08000000)
  AHB3PERIPH_BASE* = (PERIPH_BASE + 0x10000000)

const
  GPIOA_BASE* = (AHB2PERIPH_BASE + 0x00000000)
  GPIOB_BASE* = (AHB2PERIPH_BASE + 0x00000400)
  GPIOC_BASE* = (AHB2PERIPH_BASE + 0x00000800)
  GPIOD_BASE* = (AHB2PERIPH_BASE + 0x00000C00)
  GPIOE_BASE* = (AHB2PERIPH_BASE + 0x00001000)
  GPIOF_BASE* = (AHB2PERIPH_BASE + 0x00001400)

type
  GPIO* {.importc: "GPIO_TypeDef", header: "stm32f303xc.h".} = object

const
  GPIOA* = (cast[ptr GPIO](GPIOA_BASE))
  GPIOB* = (cast[ptr GPIO](GPIOB_BASE))
  GPIOC* = (cast[ptr GPIO](GPIOC_BASE))
  GPIOD* = (cast[ptr GPIO](GPIOD_BASE))
  GPIOE* = (cast[ptr GPIO](GPIOE_BASE))
  GPIOF* = (cast[ptr GPIO](GPIOF_BASE))

type
  GPIOSetup* {.importc: "GPIO_InitTypeDef", header: "stm32f3xx_hal_gpio.h".} = object
    pin* {.importc: "Pin".}: uint32
    mode* {.importc: "Mode".}: uint32
    pull* {.importc: "Pull".}: uint32
    speed* {.importc: "Speed".}: uint32
    alternate {.importc: "Alternate".}: uint32

type
  Status* = enum
    HAL_OK = 0x00000000, HAL_ERROR = 0x00000001, HAL_BUSY = 0x00000002,
    HAL_TIMEOUT = 0x00000003

proc initHAL*(): Status {.importc: "HAL_Init", dynlib: libName.}
proc initClock*(): int32 {.importc: "systemclock_init", dynlib: libName.}
proc enableGPIOEClock*() {.importc: "gpioe_clock_enable", dynlib: libName.}
proc initGPIO*(GPIOx: ptr GPIO; GPIO_Init: ptr GPIOSetup) {.importc: "HAL_GPIO_Init", dynlib: libName.}
proc toggleGPIO*(GPIOx: ptr GPIO; pin: uint16) {.importc: "HAL_GPIO_TogglePin", dynlib: libName.}
proc delay*(millis : uint32) {.importc: "HAL_Delay", dynlib: libName.}

proc handleError*() =
  ##  User may add here some code to deal with this error
  while true: discard
  