.include "funciones.s"

.equ UPPER_SIZE,		50		// Tamaño de las letras del título
.equ UPPER_THICKNESS, 	8		// Grosor de las letras del título
.equ SMALL_SIZE,		20		// Tamaño de las letras del menú
.equ SMALL_THICKNESS, 	3		// Grosor de las letras del menú


.globl main
main:

 	mov x29, x0					// Save framebuffer base address to x29
	
//----------------------------------Imágen----------------------------------

	bl draw_background				// Dibuja el fondo superior
	bl draw_background_inf			// Dibuja el fondo inferior

	// Dibujar Triangulo
	mov x1,#20						// x1: coord "x" del triangulo
	mov x2,Y_FLOOR_POS-1			// x2: coord "y" del triangulo
	bl draw_triangle				

	// Dibujar Personajes

	/*
	Se dibujan los personajes en 
	distintas posiciones de la imagen
	*/										// Parámetros para los procedimientos que dibujan personajes
	// Cuadrado								// 	x21: coord "x" del personaje
	mov x21,#200							//	x24: coord "y" del personaje
	mov x24,Y_FLOOR_POS-PJ_SIZE
	bl pj_cuadrado

	// Original
	mov x21,#250
	bl pj_original

	// Calavera
	mov x21,#450
	bl pj_calavera

	// Creeper
	mov x21,#490
	bl pj_creeper

	// Llorando
	mov x21,#580
	bl pj_llorar

	// Hongo
	mov x21,#200
	mov x24,Y_FLOOR_POS-2*PJ_SIZE			// Se dibuja encima del cuadrado
	bl pj_hongo

	mov x21,#225
	mov x24,#70
	bl pj_lentes

	// Dibujar Título
	/*
	Para poder dibujar las mismas letras en
	distintos tamaños se pasan como argumento
	el tamano de la letra y su grosor
	*/
	mov x25,UPPER_SIZE					// x25: Tamaño de la letra
	mov x26,UPPER_THICKNESS				// x26: grosor
	mov x27,UPPER_SIZE/2				// x27: Tamaño/2 (útil para muchas letras)

	movz x4,0xFF, lsl 16				// Color de la letra
	movk x4,0xFFFF, lsl 00				// Blanco

	mov x1,#80						// x1: coord "x"
	mov x2,#50						// x2: coord "y"
	bl draw_G

	mov x1,#145
	bl draw_E

	mov x1,#210
	bl draw_O

	mov x1,#310
	bl draw_D

	mov x1,#375
	bl draw_A

	mov x1,#440
	mov x2,#50
	bl draw_S

	mov x1,#500
	mov x2,#50
	bl draw_H

	// NEW GAME
	mov x25,SMALL_SIZE				// Se cambian el tamaño y grosor de la letra
	mov x26,SMALL_THICKNESS			// para dibujar el menú
	mov x27,SMALL_SIZE/2

	mov x1,#210
	mov x2,#150
	bl draw_N

	mov x1,#235
	bl draw_E

	mov x1,#260
	bl draw_W

	mov x1,#300
	bl draw_G

	mov x1,#325
	bl draw_A

	mov x1,#350
	mov x2,#150
	bl draw_M

	mov x1,#375
	bl draw_E

	// CONTINUE
	mov x1,#210
	mov x2,#190
	bl draw_C

	mov x1,#235
	mov x2,#190
	bl draw_O

	mov x1,#265
	mov x2,#190
	bl draw_N

	mov x1,#290
	bl draw_T

	mov x1,#315
	bl draw_I

	mov x1,#325
	bl draw_N

	mov x1,#350
	bl draw_U

	mov x1,#378
	mov x2,#190
	bl draw_E

	// Cuadradito (selector de opciones)
	mov x1,#180
	mov x2,#152
	mov x3,#18
	mov x5,#18
	bl draw_rectangle

InfLoop: 
	b InfLoop
//-----------------Fin Imagen---------------------------------------------------------

//-----Letras-------------
/*	
Parámetros de todas los procedimientos que dibujan letras:
x1 : coordenada "x"
x2 : coordenada "y"
x4 : Color
x25: Tamaño
x26: Grosor
x27: Tamaño/2

- Para acortar(mucho) el código se usan letras como componentes para dibujar otras letras,
por ejemplo, la I o la C son parte de muchas otras letras.
*/
draw_I:
	str x30,[sp,#-8]!

	add x3,x25,x26
	mov x5,x26
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//------
draw_C:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_I			// Segmento izq	-->C

	sub x5,x25,x26		// Segmento de arriba
	mov x3,x26
	bl draw_rectangle

	mov x1,x15			// Segmento de abajo
	add x2,x17,x25
	add x5,x5,x26
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//-----------
draw_G:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_C

	add x1,x15,x27		// Segmento central
	add x2,x17,x27
	mov x3,x26
	sub x5,x27,x26
	bl draw_rectangle

	mov x3,x27			// Segmento derecho G<--
	mov x5,x26
	bl draw_rectangle

	mov x2,x17

	ldr x30,[sp],#8
ret x30
//-----------
draw_E:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_C

	mov x1,x15			// Segmento central E<--
	add x2,x17,x27
	mov x3,x26
	mov x5,x25
	bl draw_rectangle

	mov x2,x17

	ldr x30,[sp],#8
ret x30
//-----------------
draw_O:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_C

	add x1,x15,x25		// Segmento derecho O<--
	mov x2,x17
	bl draw_I

	ldr x30,[sp],#8
ret x30
//---
draw_N:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_I			// Segmento izq ->N

	add x1,x15,x25		// Segmento derecho N<-
	sub x1,x1,x26
	bl draw_I

	mov x1,x15			// Segmento superior
	mov x2,x17
	mov x3,x26
	mov x5,x25
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

draw_A:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_N

	mov x1,x15			// Segmento central
	add x2,x17,x27
	mov x3,x26
	mov x5,x25
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

draw_H:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_I			// Segmento izq ->H

	add x1,x15,x25		// Segmento derecho H<--
	sub x1,x1,x26
	bl draw_I

	mov x1,x15			// Segmento central
	add x2,x17,x27
	mov x3,x26
	mov x5,x25
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

draw_M:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_N

	add x1,x15,x27		// Segmento central 
	sub x1,x1,#1
	mov x3,x27
	mov x5,x26
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

draw_U:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	bl draw_I			// Segmento izq ->U
	add x1,x15,x25
	bl draw_I			// Segmento der U<-

	mov x1,x15			// Segmento inferior
	add x2,x17,x25
	mov x3,x26
	mov x5,x25
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

draw_W:
	str x30,[sp,#-8]!

	mov x17,x2			// x17: y inicial
	mov x15,x1			// x15: x inicial

	bl draw_U
	add x1,x15,x27
	mov x2,x17
	bl draw_I			// Segmento central

	ldr x30,[sp],#8
ret x30

draw_T:
	str x30,[sp,#-8]!

	mov x17,x2			// x17: y inicial
	mov x15,x1			// x15: x inicial

	mov x3,x26				// Segmento superior
	mov x5,x25
	bl draw_rectangle

	add x1,x15,x27			// Segmento central
	sub x1,x1,#2
	bl draw_I

	ldr x30,[sp],#8
ret x30

draw_D:
	str x30,[sp,#-8]!

	mov x17,x2			// x17: y inicial
	mov x15,x1			// x15: x inicial

	mov x3,x26				// Segmento superior
	mov x5,x25
	bl draw_rectangle

	mov x1,x15				// Segmento inferior
	add x2,x17,x25
	bl draw_rectangle

	mov x2,x17				// Segmento derecho D<-
	add x1,x15,x25
	sub x1,x1,x26
	bl draw_I

	add x1,x15,#10			// Segmento izq ->D
	bl draw_I

	ldr x30,[sp],#8
ret x30

draw_S:
	str x30,[sp,#-8]!

	// se guardan las posiciones iniciales
	mov x15,x1			// x15: x inicial
	mov x17,x2			// x17: y inicial

	mov x8,3
	mov x3,x26
	mov x5,x25
 loop1:						// Se dibujan los 3 segmentos horizontales
	bl draw_rectangle
	mov x1,x15	
	add x2,x2,x27
	sub x8,x8,1
	cbnz x8,loop1

	mov x2,x17			// Segmento izq superior->S
	mov x3,x27
	mov x5,x26
	bl draw_rectangle

	add x1,x15,x25		// Segmento derecho inferior S<-
	sub x1,x1,x26
	add x2,x17,x27
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

