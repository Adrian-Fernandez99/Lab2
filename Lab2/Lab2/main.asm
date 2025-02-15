/*

Prelab2.asm

Created: 2/13/2025 11:07:00 PM
Author : Adrián Fernández

Descripción:
	Se realiza dos contadores binario de 4 bits.
	El conteo es visto por medio de LEDs en la protoboard.
	Se usan pushbuttons para el incremento y decrecimiento 
	de los valores.
	Por ultimo se suman ambos contadores y se muestran en 4
	leds aparte, una lad extra para mostrar overflow
*/


// Configurar la pila
.include "M328PDEF.inc"
.cseg
.org 0x0000


// Configurar el MCU
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, HIGH(RAMEND)
OUT SPH, R16

SETUP:
// Configurar pines de entrada y salida (DDRx, PORTx, PINx)
// PORTD como entrada con pull-up habilitado
	LDI		R16, 0x00
	OUT		DDRB, R16		// Setear puerto B como entrada
	LDI		R16, 0xFF
	OUT		PORTB, R16		// Habilitar pull-ups en puerto B

// PORTB como salida inicialmente encendido
	LDI		R16, 0xFF
	OUT		DDRD, R16		// Setear puerto D como salida
// PORTC como salida inicialmente encendido
	LDI		R16, 0xFF
	OUT		DDRC, R16		// Setear puerto C como salida

// Realizar variables
	LDI		R16, 0xFF		// Registro de ingresos
	LDI		R17, 0xFF		// Registro de comparación
	LDI		R18, 0xFF		// Registro del delay
	LDI		R19, 0x00		// Registro de contador1
	LDI		R20, 0x00		// Registro de display
	LDI		R21, 0x00		// Registro para la SREG

// Se realiza el main loop
CONTADOR:
	MOV		R17, R16		// movemos valor actual a calor anterior
	OUT		PORTD, R20		// Matememos salidas encendidas
	IN		R16, PINB		// leemos el PINB
	CP		R16, R17		// Comparamos si no es la misma lecura que antes
	BREQ	CONTADOR		// Si es la misma regresamos					

DECREMENTO1:
	LDI		R17, 0x1E		// Valor que esperamos para decrementar el contador 1		
	CP		R16, R17		// Comparamos con la entrada
	BRNE	INCREMENTO1		// Si no es el valor que esperamos pasamos a otra función
	CALL	DELAY			// Realizamos antirebote
	IN		R16, PINB		// Leemos otra vez
	CP		R17, R16		// Comparamos
	BRNE	CONTADOR		// Si fue una lectura falsa se regresa al contador
	CALL	BOTON_SUELTO	// Se espera a que se libere el boton
	CALL	RESTA1			// Se realiza el decremento
	CALL	UBICACION		// Se realiza la ubicación para el display 
	JMP		CONTADOR		// Se regresa al incio
// De aquí en adelante la logica es muy parecida
INCREMENTO1:				
	LDI		R17, 0x1D		// Nuevamente valor que se espera para incrementar
	CP		R16, R17		// Se compara si no es el valro se va a otra función
	BRNE	CONTADOR		// Si es el valor se realiza el mismo sistema de antirebote
	CALL	DELAY
	IN		R16, PINB
	CP		R17, R16
	BRNE	CONTADOR
	CALL	BOTON_SUELTO2	// Siempre se verifica que se suelte el botón
	CALL	SUMA1			// Se realiza el incremento
	CALL	UBICACION
	JMP		CONTADOR

// Sub-rutina (no de interrupción)
DELAY:						// Se realiza un delay
	LDI		R18, 0xFF		// Se carga el valor maximo
SUB_DELAY1:
	DEC		R18				// Se baja el valor
	CPI		R18, 0
	BRNE	SUB_DELAY1		// Esperar hasta que el valor sea 0
	LDI		R18, 0xFF		// Cuando el valor es 0 pasar y volver a cargar el maximo
SUB_DELAY2:					// Repetir cuantas veces sea necesario para el anitrebote
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY2
	LDI		R18, 0xFF
SUB_DELAY3:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY3
	LDI		R18, 0xFF
SUB_DELAY4:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY4
	RET

SUMA1:						// Función para el incremento del primer contador
	INC		R19				// Se incrementa el valor
	SBRC	R19, 4			// Se observa si tiene más de 4 bits
	LDI		R19, 0x00		// En ese caso es overflow y debe regresar a 0
	RET

RESTA1:						// Función para el decremento del primer contador
	DEC		R19				// Se decrementa el valor
	SBRC	R19, 4			// Se observa si tiene más de 4 bits
	LDI		R19, 0x0F		// En ese caso es underflow y debe regresar a F
	RET

BOTON_SUELTO:				// Función para esperar a que se suelte el boton
	CALL	DELAY			// Se espera un momento
	IN		R16, PINB		// Se lee otra vez
	SBIS	PINB, 0			// Hasta que el boton deje de estar apachado (bit = 1) se salta
	RJMP	BOTON_SUELTO	// De lo contrario se vuelve a empezar
	RET
		
BOTON_SUELTO2:				// Función para esperar a que se suelte el boton
	CALL	DELAY			// Misma logica, distinto bit verificado
	IN		R16, PINB
	SBIS	PINB, 1
	RJMP	BOTON_SUELTO2
	RET

UBICACION:
	CPI		R19, 0x00
	IN		R21, SREG
	BRNE	UNO
	LDI		R20, 0x7E
	RET
UNO:
	CPI		R19, 0x01
	IN		R21, SREG
	BRNE	DOS
	LDI		R20, 0x30
	RET
DOS:
	CPI		R19, 0x02
	IN		R21, SREG
	BRNE	TRES
	LDI		R20, 0x6D
	RET
TRES:
	CPI		R19, 0x03
	IN		R21, SREG
	BRNE	CUATRO
	LDI		R20, 0x79
	RET
CUATRO:
	CPI		R19, 0x04
	IN		R21, SREG
	BRNE	CINCO
	LDI		R20, 0x33
	RET
CINCO:
	CPI		R19, 0x05
	IN		R21, SREG
	BRNE	SEIS
	LDI		R20, 0x5B
	RET
SEIS:
	CPI		R19, 0x06
	IN		R21, SREG
	BRNE	SIETE
	LDI		R20, 0x5F
	RET
SIETE:
	CPI		R19, 0x07
	IN		R21, SREG
	BRNE	OCHO
	LDI		R20, 0x70
	RET
OCHO:
	CPI		R19, 0x08
	IN		R21, SREG
	BRNE	NUEVE
	LDI		R20, 0x7F
	RET
NUEVE:
	CPI		R19, 0x09
	IN		R21, SREG
	BRNE	A
	LDI		R20, 0x7B
	RET
A:
	CPI		R19, 0x0A
	IN		R21, SREG
	BRNE	B
	LDI		R20, 0x77
	RET
B:
	CPI		R19, 0x0B
	IN		R21, SREG
	BRNE	C
	LDI		R20, 0x7F
	RET
C:
	CPI		R19, 0x0C
	IN		R21, SREG
	BRNE	D
	LDI		R20, 0x4E
	RET
D:
	CPI		R19, 0x0D
	IN		R21, SREG
	BRNE	E
	LDI		R20, 0x7E
	RET
E:
	CPI		R19, 0x0E
	IN		R21, SREG
	BRNE	F
	LDI		R20, 0x4F
	RET
F:
	CPI		R19, 0x0F
	IN		R21, SREG
	BRNE	RETORNO
	LDI		R20, 0x47
	RET

RETORNO:
	JMP CONTADOR
// Rutinas de interrupción