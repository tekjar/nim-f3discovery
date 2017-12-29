# nim-f3discovery
Highlevel pacakge to play with f3 discovery board using nim lang


#### DEMO INSTRUCTIONS
---------------------

* Clone this repo run these commands to setup the directory for development

```
make download
make initialize
make cube
```

Also change `NIM_PATH` to your nim installation path in `Makefile`

* Compile blinky

```
nim c -c --gc:none --cpu:arm --os:standalone --deadCodeElim:on --dynlibOverride:stm32f3 blinky.nim
```

* Create binary to flash from generated c sources

```
make
```

* Flash

```
st-flash write blinky.bin 0x8000000
```
