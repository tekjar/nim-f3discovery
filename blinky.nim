import wrapper/f3discovery

discard initHAL()
discard initClock()

enableGPIOEClock()

var gpio* = GPIOSetup(
    pin: (GPIO_PIN_15 or GPIO_PIN_14 or GPIO_PIN_13 or GPIO_PIN_12 or GPIO_PIN_11 or GPIO_PIN_10 or GPIO_PIN_9 or GPIO_PIN_8),
    mode: GPIO_MODE_OUTPUT_PP,
    pull: GPIO_PULLUP,
    speed: GPIO_SPEED_FREQ_HIGH
)

initGPIO(GPIOE, addr(gpio))

while true:
  toggleGPIO(GPIOE, GPIO_PIN_15)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_14)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_13)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_12)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_11)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_10)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_9)
  delay(50)
  toggleGPIO(GPIOE, GPIO_PIN_8)
  delay(50)