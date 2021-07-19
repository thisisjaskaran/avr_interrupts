
/*
	for XTAL=8MHz, time period=0.125 microsecond
	
	----------Timer 0--------------------------
	taking prescalar 1:1024, number of cycles=10000/(0.125*1024)=79
	
	----------Timer 1--------------------------
	taking prescalar 1:256, number of cycles=1500000/(0.125*256)=46875
	
*/

.INCLUDE "M32DEF.INC"															//0 microseconds
.ORG 0x0						;location for reset								//0 microseconds
	JMP MAIN					;bypass interrupt vector table					//0.375 microseconds
.ORG 0x12						;ISR location for Timer1 overflow				//0 microseconds
	JMP T1_OV_ISR				;go to an address with more space				//0.375 microseconds
.ORG 0x16						;ISR location for Timer0 overflow				//0 microseconds
	JMP T0_OV_ISR				;go to an address with more space				//0.375 microseconds

;	---main program for initialising and keeping CPU busy---

.ORG 0x40																		//0 microseconds
MAIN:	LDI R20,HIGH(RAMEND)													//0.125 microseconds
		OUT SPH,R20																//0.125 microseconds
		LDI R20,LOW(RAMEND)														//0.125 microseconds
		OUT SPL,R20				;initialise SP									//0.125 microseconds

		LDI R18,0				;R18=0											//0.125 microseconds
		OUT PORTC,R18			;PORTC=0										//0.125 microseconds
		LDI R20,0																//0.125 microseconds
		OUT DDRA,R20			;PORTA as input									//0.125 microseconds
		LDI R20,0xFF															//0.125 microseconds
		OUT DDRC,R20			;PORTC as output								//0.125 microseconds
		OUT DDRB,R20			;PORTB as output								//0.125 microseconds
		OUT DDRD,R20			;PORTD as output								//0.125 microseconds

		LDI R20,0x05															//0.125 microseconds
		OUT TCCR0,R20			;Normal, prescaler 1:1024						//0.125 microseconds
		LDI R16,0xB1			;0xB1=177										//0.125 microseconds
		OUT TCNT0,R16			;load Timer0 with 177							//0.125 microseconds
		LDI R19,HIGH(0xFFFF)	;timer value for 1.5 seconds					//0.125 microseconds
		OUT TCNT1H,R19			;load Timer1 high byte							//0.125 microseconds
		LDI R19,LOW(0xFFFF)		;0x48E5=18661									//0.125 microseconds
		OUT TCNT1L,R19			;load Timer1 low byte							//0.125 microseconds
		LDI R20,0x00															//0.125 microseconds
		OUT TCCR1A,R20			;Timer1 Normal mode								//0.125 microseconds
		LDI R20,0x04															//0.125 microseconds
		OUT TCCR1B,R20			;initialise clock, prescaler 1:256				//0.125 microseconds
		LDI R20,(1<<TOIE0)|(1<<TOIE1)											//0.125 microseconds
		OUT TIMSK,R20			;enable Timer0 and Timer1 overflow ints			//0.125 microseconds
		SEI						;set I (enable interrupts globally)				//0.125 microseconds

;	---infinite loop---

HERE:	JMP HERE				;waiting for interrupt							//0.375 microseconds

;	---ISR for Timer0 to toggle after 10ms---

.ORG 0x200																		//0 microseconds
T0_OV_ISR:	LDI R16,0x00		;R16=0x00										//0.125 microseconds
			LDI R17,0x0A		;counter										//0.125 microseconds
			LDI R21,0x10														//0.125 microseconds
			LABEL:	OUT PORTD,R16												//0.125 microseconds
					ADD R16,R21													//0.125 microseconds
					DEC R17														//0.125 microseconds
					BRNE LABEL													//0.125 microseconds every time the loop executes
																				//0.25 microseconds when branching
			LDI R16,0xB1														//0.125 microseconds
			OUT TCNT0,R16														//0.125 microseconds
			RETI																//0.5 microseconds

;	---ISR for Timer1 (it comes here after elapse of 1.5s time)---

.ORG 0x300																		//0 microseconds

T1_OV_ISR:	INC R18				;increment upon overflow						//0.125 microseconds
			OUT PORTC,R18														//0.125 microseconds
			LDI R19,HIGH(0x48E5)												//0.125 microseconds
			OUT TCNT1H,R19		;load Timer1 high byte							//0.125 microseconds
			LDI R19,LOW(0x48E5)													//0.125 microseconds
			OUT TCNT1L,R19		;load Timer1 low byte  (for next round)			//0.125 microseconds
			RETI				;return from interrupt							//0.5 microseconds
