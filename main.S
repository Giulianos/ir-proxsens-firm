#include <avr/io.h>

#define ir_led 0
#define ir_recv 4
#define ouput_pin 2
#define high_time 34
#define low_time 16
#define delay_times 200
#define burst_times 250

.global init

.section .text

.org 0


init:
	ldi r24, 0x05
	out _SFR_IO_ADDR(DDRB), r24

;-------------- Main routine --------------

main:
	rcall burst
	rcall delay
	rjmp main
.clear_output:
	cbi _SFR_IO_ADDR(PORTB), ouput_pin
	rjmp main

;-------------- Burst routine --------------

burst:
	ldi r23, burst_times

.burst_loop:
	dec r23
	breq .end_burst

.single_cycle:
  sbi _SFR_IO_ADDR(PORTB), ir_led
  ldi r24, high_time

.high_stateWait:
  dec r24
  breq .low_state
  rjmp .high_stateWait

.low_state:
  cbi _SFR_IO_ADDR(PORTB), ir_led
  ldi r24, low_time

.low_stateWait:
  dec r24
  breq .burst_loop
  rjmp .low_stateWait

.end_burst:
	ret

;-------------- Delay routine --------------

delay:
	ldi r24, delay_times
.delay_check:
	dec r24
	breq .end_delay
	rjmp .delay_check
.end_delay:
	ret
