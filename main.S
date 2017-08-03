#include <avr/io.h>

#define ir_led 0
#define ir_recv 4
#define ouput_pin 2

.global init

.section .text

.org 0


init:
	;Configure data direction in port b
	ldi r24, 0x05
	out _SFR_IO_ADDR(DDRB), r24
	;Configure timer0 to CTC and toggle pin OC0A with no input clock (stopped)
	ldi r24, 0x42
	out _SFR_IO_ADDR(TCCR0A), r24
	ldi r24, 0x00
	out _SFR_IO_ADDR(TCCR0B), r24
	;Configure output compare register to 0x68, Output frequency of aprox. 38kHz for prescaler 1
	;Frequency equation at page 72 of the datasheet
	ldi r24, 0x68
	out _SFR_IO_ADDR(OCR0A), r24

;-------------- Main routine --------------

main:
	rcall start38khz
.infiniteloop:
	rjmp .infiniteloop

;-------------- Burst routine --------------

start38khz:
	;First, reset timer counter
	ldi r24, 0x00
	out _SFR_IO_ADDR(TCNT0), r24
	;Then, start timer
	ldi r24, 0x01
	out _SFR_IO_ADDR(TCCR0B), r24
	ret
