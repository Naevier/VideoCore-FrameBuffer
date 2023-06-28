
.equ SCREEN_WIDTH, 		640		// Ancho de la pantalla
.equ SCREEN_HEIGH, 		480		// Alto de la pantalla
.equ SQUEARE_X_POS,		150		// Posición del PJ en el mainloop
.equ BOX_SIZE,			40		// Tamaño de las cajas
.equ PJ_SIZE,			30		// Tamaño del personaje
.equ Y_FLOOR_POS,		350		// Altura hasta el piso

.globl main

/*
Contiene algunas de las funciones del Ejercicio 2 del proyecto, con algunas 
modificaciones.
*/
// -----------FUNCIONES-----------------------------------------

//Dibujar el fondo superior
draw_background:
	str x30,[sp,#-8]!

	// color
	movz x4,0x0027, lsl 16		
	movk x4,0x0404, lsl 00	
	movk x4,0x0404,lsl 32
	movk x4,0x0027, lsl 48		// se usan los 64 bits del registro para pintar de a 2px
	// counter
	mov x5,Y_FLOOR_POS			// 350*640 : Tamaño del fondo superior 
	mov x7,x29					// x7: Dirección del back framebuffer

	loopy:						// Pinta todo el fondo superior del color que está en w4
		mov x13,SCREEN_WIDTH/2
		loopx:					
			str x4,[x7],#8		// incremento pos index
			sub x13,x13,1
			cbnz x13,loopx
		sub x5,x5,1
		cbnz x5,loopy
	
	movz x4,0x43, lsl 16		// Se cambia el color para pintar las líneas
	movk x4,0x0404, lsl 00		

	// Líneas horizontales
	//posición
	mov x1,0						// coord x
	mov x2,100						// coord y
	mov x3,SCREEN_WIDTH				// largo
	mov x17,3						// cantidad de líneas

 	loop_number:					// Dibuja 3 lineas horizontales de 4px de ancho
		mov x16,4					// ancho
		loop_width:
			bl draw_hline
			add x2,x2,1
			sub x16,x16,1
			cbnz x16,loop_width
		add x2,x2,100				// separación
		sub x17,x17,1
		cbnz x17,loop_number
	
	// Líneas verticales
	mov x1,0					// posición
	mov x2,0
	mov x3,Y_FLOOR_POS-1		// largo
	mov x5,5					// ancho
	mov x9,5					// cantidad
	mov x10,#128				// separación

 	loop_rect:					   	// Dibuja 5 lineas verticales de 5px de ancho
		mul x1,x10,x9				// x10*x9 es la posición inicial de cada rectangulo
		sub x1,x1,x25				// x25: contador de movimiento del fondo
		bl draw_rectangle
		sub x9,x9,1
		cbnz x9,loop_rect

	ldr x30,[sp],#8
ret x30
//----------------------------
// Dibujar fondo inferior
draw_background_inf:
	str x30,[sp,#-8]!

	// color
	mov x4,0					// negro	
	// counter
	mov x13,SCREEN_HEIGH
	// posición inicial 
	mov x1,0							// x = 0
	mov x2,Y_FLOOR_POS					// y = 350
	bl coord_to_addr					// x12: addres del px que está en (0,350)

	loop_y3:
		mov x5,SCREEN_WIDTH/2
		loop_x3:						// pinta el fondo inferior
			str x4,[x12],#8
			sub x5,x5,1
			cbnz x5,loop_x3
		sub x13,x13,1
		cbnz x13,loop_y3

	// Cuadrados
	// color
	movz x4,0x7b, lsl 16		
	movk x4,0x0000, lsl 00
	// seteo de parámetros
	mov x1,5			// coord x		
	mov x2,360			// coord y
	mov x3,120			// tamaño
	mov x5,150
	mov x7,4			// cantidad
 loop_rect2:			// Dibuja 4 Rectangulos de 150x120 con 10px de separación 
	bl draw_rectangle
	add x1,x1,10
	sub x7,x7,1
	cbnz x7,loop_rect2

	// Dibuja línea horizontal blanca (piso)
	mov x1,0
	mov x2, Y_FLOOR_POS
	mov x3, SCREEN_WIDTH
	movz x4,0xFF, lsl 16		// blanco
	movk x4,0xFFFF, lsl 00
	bl draw_hline
	
	ldr x30,[sp],#8
ret x30
//----------------------------
// Dibuja una linea horizontal    
draw_hline:
	// parameters: x1: x, x2: y ,x3: largo, x4: color
	// Guarda x1,x2,x3,x4
	str x30,[sp,#-8]!

	mov x9,x3			// guarda x3
	bl coord_to_addr 	// x12 : address px inicial

	loop_x:
		str w4,[x12],#4
		sub x9,x9,#1
		cbnz x9,loop_x

	ldr x30,[sp],#8

ret x30
//----------------------------
// Dibuja un rectángulo desde (x,y) hasta (x+ancho,y+alto)
// Lo dibuja con líneas verticales, si  x < 0 => x := x+640
// útil para hacer lineas veriticales, poco óptima para las horizontales
draw_rectangle:	
	// parameters: 
	//	x1: x, x2: y, x3:alto, x5: ancho, x4: color
	//	Guarda x3,x5; x1 termina en la posición final
	str x30,[sp,#-8]!

	mov x13,x5								// guardar x5
	loop_xr:
		mov x16,x3							// reset alto
		bl coord_to_addr					// x12: address del píxel inicial de cada 
			loop_yr:						// línea vertical
			str w4,[x12]
			add x12,x12,#4*SCREEN_WIDTH		// calcula el píxel justo debajo
			sub x16,x16,#1
			cbnz x16,loop_yr

		add x1,x1,#1
		sub x13,x13,#1
		cbnz x13,loop_xr

	ldr x30,[sp],#8
ret x30
//--
// Dibuja un triangulo desde la base,con una base de 40px usando draw_hline
// La posición "x" está en memoria, la posición "y" es parámetro
// Actualiza la nueva posición del triangulo
draw_triangle:
	// parameters: x1: coord "x", x2:coord "y"	//	Guarda x2
	str x30,[sp,#-8]!

	// color
	movz x4,0xfa, lsl 16		// color		
	movk x4,0x1176, lsl 00

	mov x10,40		// base
	mov x11,2		// contador 
	mov x6, x2		// guarda x2
	loop_t:					// Dibuja el triangulo 
		mov x3,x10			
		bl draw_hline		
		sub x2,x2,1
		
		sub x11,x11,1
		cbnz x11,saltar
		add x1,x1,1
		mov x11,2

		saltar:
		sub x10,x10,1
		cbnz x10,loop_t

	mov x2,x6				// recupera x2

	ldr x30,[sp],#8
ret x30
//----------------------------
// parameters: x1: x, x2: y
// pasa las coordenadas (x,y) de un pixel a la dirección de memoria de dicho pixel y lo guarda en x12
// si x < 0, se cuenta desde el borde derecho de la pantalla
coord_to_addr:
	cmp x1,0						// si x < 0 => x:= x+640
	b.GE no_sum
	add x1,x1,SCREEN_WIDTH
 no_sum:		
	cmp x1,SCREEN_WIDTH				// si x > SCREEN_WIDTH => x:= x-640
	b.LT no_res
	sub x1,x1,SCREEN_WIDTH
 no_res:
	mov x12,SCREEN_WIDTH
	madd x12,x12,x2,x1 				// x12 = x1 + (Sreen_width*x2)
	add x12,x29,x12, lsl 2		    // x12 = base address + 4*(x+(y*Screen_width))

ret x30	
//----------------------------
//------------PERSONAJES--------------//
pj_original:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24

 	// size	30x30
 	mov x3,#PJ_SIZE		
	mov x5,#PJ_SIZE
	// color
	movz x4,0x2c, lsl 16		// Celeste
	movk x4,0xc8f0, lsl 00		
	bl draw_rectangle

	movz x4,0xFF, lsl 16
	movk x4,0xFFFF, lsl 00
	// Ojo izq
	add x1,x21,#5
	add x2,x24,#5
	mov x3,#5
	mov x5,#5
	bl draw_rectangle
	// Ojo der
	add x1,x1,#10
	bl draw_rectangle

	// Boca
	add x1,x21,#5
	add x2,x24,#16
	mov x5,#20
	bl draw_rectangle
	ldr x30,[sp],#8
ret x30
//----------------------------
pj_lentes:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24
	
 	mov x3,#PJ_SIZE		
	mov x5,#PJ_SIZE
	// color
	movz x4,0x2c, lsl 16		
	movk x4,0xc8f0, lsl 00		
	bl draw_rectangle

	mov x4,0

	// Ojo izq
	add x1,x21,#4
	add x2,x24,#6
	mov x3,#6
	mov x5,#9
	bl draw_rectangle
	// Ojo der
	add x1,x1,#5
	bl draw_rectangle
	//lentes
	mov x1,x21
	add x2,x24,#4
	mov x3,#2
	mov x5,#PJ_SIZE-3
	bl draw_rectangle

	// Boca
	movz x4,0xFF, lsl 16
	movk x4,0xFFFF, lsl 00
	add x1,x21,#5
	add x2,x24,#16
	mov x3,3
	mov x5,#20
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//----------------------------
pj_creeper:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24
	// size	30x30
	mov x3,#PJ_SIZE		
	mov x5,#PJ_SIZE
	// color
	movz x4,0x22, lsl 16		
	movk x4,0xb14d, lsl 00		
	bl draw_rectangle

	mov x4,0
	// Ojo izq
	add x1,x21,#6
	add x2,x24,#9
	mov x3,#5
	mov x5,#5
	bl draw_rectangle

	add x2,x24,15
	mov x3,4
	mov x5,8
	bl draw_rectangle

	// Ojo der
	add x2,x24,9
	mov x3,#5
	mov x5,#5
	bl draw_rectangle

	add x1,x21,8
	add x2,x2,8
	mov x3,10
	mov x5,14
	bl draw_rectangle

	add x1,x21,11
	add x2,x24,23
	mov x3,4
	mov x5,8
	movz x4,0x22, lsl 16		
	movk x4,0xb14d, lsl 00		
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//-----------
pj_cuadrado:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24

	mov x3,#PJ_SIZE
	mov x5,#5
	movz x4,0x1e, lsl 16		
	movk x4,0xe656, lsl 00		

	mov x1,x21
	mov x2,x24
	bl draw_rectangle

	mov x3,#5
	mov x5,PJ_SIZE-5
	bl draw_rectangle

	add x1,x21,#5
	add x2,x24,#PJ_SIZE-5
	mov x5,PJ_SIZE-10
	bl draw_rectangle

	add x2,x24,#5
	mov x5,#5
	mov x3,#PJ_SIZE-5
	bl draw_rectangle

	movz x4,0xff, lsl 16		
	movk x4,0xf200, lsl 00	
	add x1,x21,#12
	add x2,x24,#12
	mov x3,#6
	mov x5,#6
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//-------------------
pj_llorar:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24

	// size	30x30
	mov x3,#PJ_SIZE		
	mov x5,#PJ_SIZE

	movz x4,0x2c, lsl 16		// Celeste  02c8f0
	movk x4,0xc8f0, lsl 00		//a1a1a1
	bl draw_rectangle

	movz x4,0xFF, lsl 16
	movk x4,0xFFFF, lsl 00

	// Ojo izq
	add x1,x21,#5
	add x2,x24,#5
	mov x3,#5
	mov x5,#5
	bl draw_rectangle
	// Ojo der
	add x1,x1,#10
	bl draw_rectangle

	// Boca
	add x1,x21,#10
	add x2,x24,#16
	mov x5,#10
	mov x3,3
	bl draw_rectangle

	add x1,x21,10
	add x2,x24,#18
	mov x3,3
	mov x5,2
	bl draw_rectangle

	add x1,x21,18
	bl draw_rectangle

	add x1,x21,#5
	add x2,x24,10
	mov x3,20
	mov x5,5
	movz x4,0x06, lsl 16
	movk x4,0x74a3, lsl 00
	bl draw_rectangle

	add x1,x1,10
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//-----------
pj_calavera:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24

	// size	30x30
	mov x3,#PJ_SIZE/2		
	mov x5,#PJ_SIZE
	// color
	movz x4,0xFF, lsl 16		// Celeste  02c8f0
	movk x4,0xFFFF, lsl 00		//a1a1a1
	bl draw_rectangle

	add x1,x21,#4
	add x2,x24,#PJ_SIZE/2
	mov x3,PJ_SIZE/2
	mov x5,#9
	bl draw_rectangle

	movz x4,0x7f, lsl 16		// Celeste  02c8f0
	movk x4,0x7f7f, lsl 00
	bl draw_rectangle

	add x1,x21,13
	add x2,x24,15
	mov x3,12
	mov x5,15
	bl draw_rectangle
	movz x4,0xFF, lsl 16		// Celeste  02c8f0
	movk x4,0xFFFF, lsl 00

	backk:
	add x1,x21,16
	mov x3,2
	mov x5,3
	bl draw_rectangle

	add x1,x1,#3	
	mov x3,2
	mov x5,3
	bl draw_rectangle

	add x1,x1,#3	
	mov x3,2
	mov x5,2
	bl draw_rectangle	

	add x1,x21,16
	add x2,x24,25
	mov x3,2
	mov x5,3
	bl draw_rectangle

	add x1,x1,#3	
	mov x3,2
	mov x5,3
	bl draw_rectangle

	add x1,x1,#3	
	mov x3,2
	mov x5,2
	bl draw_rectangle	

	add x1,x21,13
	add x2,x24,27
	mov x3,3
	mov x5,17
	bl draw_rectangle

	//  Dibujar cara
	// color
	movz x4,0x0000,lsl 00
	movk x4,0x00, lsl 16		// Blanco

	// Ojo izq
	add x1,x21,#14
	add x2,x24,#5
	mov x3,#5
	mov x5,#5
	bl draw_rectangle
	// Ojo der
	add x1,x1,#8
	mov x3,#5
	mov x5,#3
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30
//-----------
pj_hongo:
	str x30,[sp,#-8]!

	mov x1,x21
	mov x2,x24	
	
	mov x3,PJ_SIZE/2
	mov x5,PJ_SIZE
	movz x4,0xff, lsl 16
	movk x4,0x7d27, lsl 00
	bl draw_rectangle

	add x1,x21,#4
	add x2,x24,#14
	mov x3,PJ_SIZE/2
	mov x5,#22
	movk x4,0xFFFF, lsl 00
	bl draw_rectangle

	add x1,x21,#2
	mov x3,#5
	mov x5,PJ_SIZE-4
	bl draw_rectangle

	mov x4,0
	add x1,x21,#10
	add x2,x24,#14
	mov x5,2
	bl draw_rectangle

	add x1,x1,#6
	bl draw_rectangle

	add x1,x21,#10
	add x2,x24,#22
	mov x3,#2
	mov x5,#10
	bl draw_rectangle

	movz x4,0xb9, lsl 16
	movk x4,0x7957, lsl 00

	mov x1,x21
	add x2,x24,#5
	mov x3,5
	mov x5,6
	bl draw_rectangle

	add x1,x21,PJ_SIZE-6
	bl draw_rectangle

	add x1,x21,10
	mov x2,x24
	mov x5,10
	bl draw_rectangle

	add x1,x21,10
	add x2,x24,9
	bl draw_rectangle

	ldr x30,[sp],#8
ret x30

