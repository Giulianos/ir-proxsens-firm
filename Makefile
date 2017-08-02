SOURCES_C    = $(wildcard *.c)
SOURCES_ASM  = $(wildcard *.S)
OBJECTS_C    = $(SOURCES_C:.c=.o)
OBJECTS_ASM  = $(SOURCES_ASM:.S=.o)
INITFUNCTION = init
MCU      		 = attiny85
CLOCK        = 8000000
PROGRAMMER   = avrisp
SERIALPORT   = /dev/tty.usbmodem14411
BAUDRATE     = 19200
FIRMWARE     = ./build/firmware.hex
GCC       	 = avr-gcc
AS           = avr-gcc
LD           = avr-ld
OBJCPY       = avr-objcopy
CFLAGS       = -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(MCU) -o hello.o hello.c
ASMFLAGS     = -c -mmcu=$(MCU)
LDFLAGS      = -e $(INITFUNCTION) --warn-common
OBJCPYFLAGS  = -O ihex

build: $(FIRMWARE)

$(FIRMWARE) : $(OBJECTS_ASM) $(OBJECTS_C)
		$(LD) $(LDFLAGS) -o linked.elf $(OBJECTS_C) $(OBJECTS_ASM)
		$(OBJCPY) $(OBJCPYFLAGS) linked.elf $(FIRMWARE)
		rm linked.elf

%.o: %.c
		$(GCC) $(CFLAGS) $< -o $@

%.o: %.S
		$(AS) $(ASMFLAGS)  $< -o $@

upload:
		avrdude -v -F -p $(MCU) -c $(PROGRAMMER) -P $(SERIALPORT) -b $(BAUDRATE) -U flash:w:$(FIRMWARE):i -U lfuse:w:0xE2:m

clean:
	  rm -rf *.o build/*.hex *.elf

.PHONY: build upload clean
