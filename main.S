#include <avr/io.h>

#define GLOBAL_COUNTER r25
#define TEMP_REG r24

.global vector_table

.section .text

vector_table:
.org 0x0000
rjmp init
nop
rjmp timer_handler


	;-------------- Timer1 ISR --------------

	timer_handler:
		cpi GLOBAL_COUNTER, 0x00
		breq .start_burst

		cpi GLOBAL_COUNTER, 0x01
		breq .stop_burst

		cpi GLOBAL_COUNTER, 0x02
		breq .check_sensor

		cpi GLOBAL_COUNTER, 0x0A
		breq .reset_counter

		inc GLOBAL_COUNTER
		reti

	.start_burst:
		;First, reset timer counter
		ldi TEMP_REG, 0x00
		out _SFR_IO_ADDR(TCNT0), TEMP_REG
		;Then, start timer
		ldi TEMP_REG, 0x01
		out _SFR_IO_ADDR(TCCR0B), TEMP_REG
		inc GLOBAL_COUNTER
		reti

	.stop_burst:
		;First lets check Sensor
		sbic _SFR_IO_ADDR(PORTB), 0x04
		rjmp .set_output
		cbi _SFR_IO_ADDR(PORTB), 0x02
		inc GLOBAL_COUNTER
		rjmp .stop
	.set_output:
		sbi _SFR_IO_ADDR(PORTB), 0x02
		inc GLOBAL_COUNTER
	.stop:
		;Now lets stop timer
		ldi TEMP_REG, 0x00
		out _SFR_IO_ADDR(TCCR0B), TEMP_REG
		inc GLOBAL_COUNTER
		reti

	.check_sensor:


	.reset_counter:
		ldi GLOBAL_COUNTER, 0x00
		reti


;-------------- Init routine --------------

init:
	;Configure data direction in port b
	ldi TEMP_REG, 0x05
	out _SFR_IO_ADDR(DDRB), TEMP_REG

	;Configure timer0 to CTC and toggle pin OC0A with no input clock (stopped) initially
	ldi TEMP_REG, 0x42
	out _SFR_IO_ADDR(TCCR0A), TEMP_REG
	ldi TEMP_REG, 0x00
	out _SFR_IO_ADDR(TCCR0B), TEMP_REG
	;Configure output compare register to 0x68, Output frequency of aprox. 38kHz for prescaler 1
	;Frequency equation at page 72 of the datasheet
	ldi TEMP_REG, 0x68
	out _SFR_IO_ADDR(OCR0A), TEMP_REG

	;Configure timer1 to normal mode, CTC (clear on compare match), stoped (initially), synchronous and
	;compare match interrupt enable on A.
	ldi TEMP_REG, 0x80
	out _SFR_IO_ADDR(TCCR1), TEMP_REG
	ldi TEMP_REG, 0x40
	out _SFR_IO_ADDR(TIMSK), TEMP_REG
	;Configure count to 0x15, 658us aprox for prescaler 256
	;658us was selected as stated in Vishay's application note 82741 (25/f0 --> 25/38kHz)
	ldi TEMP_REG, 0x15
	out _SFR_IO_ADDR(OCR1A), TEMP_REG

	;Initialize global counter (controls burst/sensing timing)
	ldi GLOBAL_COUNTER, 0x00


;-------------- Main routine --------------

main:
;Lets start timer1 (sort of timer tick) and enable interrupts
;Start is done in main so all intialization is already done
sei
ldi TEMP_REG, 0x00
out _SFR_IO_ADDR(TCNT1), TEMP_REG
ldi TEMP_REG, 0x09
out _SFR_IO_ADDR(TCCR1), TEMP_REG

;Then we just infinite loop and leave timer1's ISR do the stuff
.infiniteloop:
	rjmp .infiniteloop
