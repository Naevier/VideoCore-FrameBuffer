
.equ SCREEN_WIDTH, 		640		// Ancho de la pantalla
.equ SCREEN_HEIGH, 		480		// Alto de la pantalla
.equ SQUEARE_X_POS,		150		// Posición del PJ en el mainloop
.equ BOX_SIZE,			40		// Tamaño de las cajas
.equ PJ_SIZE,			30		// Tamaño del personaje
.equ Y_FLOOR_POS,		350		// Altura hasta el piso

.data
	Back_framebuff: .skip 4*(SCREEN_WIDTH*Y_FLOOR_POS)
	Aux: .skip 20000									// Memoria auxiliar para guardar píxeles
	Array_pos: .skip 5000								// Array con las posiciones de las cajas

.globl main

/* Aclaraciones
-En el back buffer solo almacena hasta Y_FLOOR_POS (piso) y no toda la pantalla, ya que
no hay objetos en movimiento por debajo de esa posición.
- El movimiento del fondo inferior se hace directamente en el front buffer.

-Registros reservados
	x19: SKIN
	x20: Jump counter
	x21: x-square position
	x23: address to Array_pos
	x24: y-square position
	x25: contador para el movimiento del fondo
	x26: contador de cajas
	x28: addres to front framebuffer
	x29: addres to back framebuffer
*/
// -----------FUNCIONES-----------------------------------------
// Llama al procedimiento que dibuja la skin elegida
draw_pj:
	str x30,[sp,#-8]!

	cmp x21,SCREEN_WIDTH-PJ_SIZE		// No dibujar el personaje si su
	b.GT end_draw						// posición esta fuera de la pantalla
	//posición
	mov x1,x21							// x1: posición x del personaje
	mov x2,x24							// x2: posición y del personaje					

	cmp x19,#0
	b.EQ pj_original

	cmp x19,#1
	b.EQ pj_lentes

	cmp x19,#2
	b.EQ pj_creeper

	cmp x19,#3
	b.EQ pj_cuadrado

	cmp x19,#4
	b.EQ pj_calavera

	cmp x19,#5
	b.EQ pj_llorar

	cmp x19,#6
	b.EQ pj_hongo

 end_draw:
	ldr x30,[sp],#8
ret x30
//----------------------------
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
// Mueve el fondo superior cada 8 frames, para simular que está mas lejos que el fondo inferior
move_background:

	cbnz x22,m_fondo			// x22: contador para el movimiento del fondo
	add x25,x25,1				// Se mueve el fondo superior		
	mov x22,8

 	m_fondo:					// por cada ciclo decremento el contador,
	sub x22,x22,1				// cada 8 se cambia la posición del fondo lejano

ret x30
//----------------------------
// Dibujar fondo inferior
draw_background_inf:
	str x30,[sp,#-8]!

	mov x29,x28				    // Se dibuja en el front framebuffer
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

	ldr x29, =Back_framebuff
	
	ldr x30,[sp],#8
ret x30
//----------------------------
// Pasa los parámetros para dibujar las cajas de cada escenario
draw_boxes:
	str x30,[sp,#-8]!
	
	mov x26,0
	//1er Escenario
	mov x2,310						// x2: coord "y", argumento para draw_box
	bl draw_box
	bl draw_box

	//2do escenario
	bl draw_box

	mov x2,350
	bl draw_triangle

	mov x2,310
	bl draw_box

	mov x2,350
	bl draw_triangle

	mov x2,310
	bl draw_box

	mov x2,350
	bl draw_triangle

	//3er escenario		
	mov x18,4
	mov x2,310
 loop_b2:
	bl draw_box
	sub x18,x18,1
	cbnz x18,loop_b2

	mov x18,4
 	mov x2,255
 loop_b3:
	bl draw_box
	sub x18,x18,1
	cbnz x18,loop_b3

	mov x2,350
	bl draw_triangle
	bl draw_triangle

	//4to escenario
	mov x18,12
	mov x2,310
 loop_b4:
	bl draw_box
	sub x18,x18,1
	cbnz x18,loop_b4

	bl draw_triangle
	bl draw_triangle

	//5to escenario
	mov x18,10
 loop_b5:
	bl draw_box
	sub x18,x18,1
	cbnz x18,loop_b5

	mov x18,3
 loop_b7:
	bl draw_triangle
	sub x18,x18,1
	cbnz x18, loop_b7

	//6to escenario
	mov x18,35
	mov x2,350
	loop_b11:
		bl draw_triangle
		sub x18,x18,1
		cbnz x18, loop_b11

	mov x2,310
	bl draw_box
	bl draw_box

	mov x2,260
	bl draw_box

	mov x2,200
	bl draw_box

	mov x2,180
	bl draw_box

	mov x2,160
	bl draw_box

	mov x2,190
	bl draw_box

	mov x2,220
	bl draw_box

	mov x2,260
	bl draw_box

	ldr x30,[sp],#8

ret x30
//----------------------------
// Dibuja GO
draw_go:
	str x30,[sp,#-8]!

	movz x4,0xFF, lsl 16		// Blanco
	movk x4,0xFFFF,lsl 00

	mov x1,#200
	mov x2,#100
	mov x3,#8
	mov x5,#100
	bl draw_rectangle

	mov x1,#350
	mov x5,#100-8
	bl draw_rectangle

	mov x3,#100
	mov x5,#8
	bl draw_rectangle
	mov x1,#200
	bl draw_rectangle	
	mov x1,#350
	bl draw_rectangle

	mov x1,#200
	mov x2,#200-8
	mov x3,#8
	mov x5,#100
	bl draw_rectangle

	mov x1,#350
	bl draw_rectangle

	mov x1,#240
	mov x2,#150
	mov x5,#60-8
	bl draw_rectangle

	mov x3,#50
	mov x5,#8
	bl draw_rectangle

	bl copyfb			

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
	// parameters: x2:coord y	//	Guarda x2
	str x30,[sp,#-8]!

	// cargar posición
	add x13,x23,x26,lsl 3	// x13 = 8*N_caja + base address array_pos
	ldur x1,[x13]			// x1: posición x del triángulo N

	cmp x1,0				// si x < 0 no se dibuja
	B.LT skip_draw_t
	// actualizar posición
	sub x14,x1,#1			// se resta 1 a la posición del triangulo			
	stur x14,[x13]			// se actualiza la posición del triangulo en la memoria

	cmp x1,SCREEN_WIDTH-BOX_SIZE		// si x > 360-40 no se dibuja 
	B.GT skip_draw_t

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

 skip_draw_t:
	add x26,x26,1  			// se aumenta el numero de la caja para la siguiente
	mov x2,x6				// recupera x2

	ldr x30,[sp],#8
ret x30
//----------------------------
// Dibuja una caja de 40x40 en (x,y) hasta (x+40,y+40)
// La posición "x" está en memoria, la posición "y" es parámetro
// Actualiza la nueva posición de la caja
draw_box:
	// parameters: x2: coord "y" 	// guarda x2
	str x30,[sp,#-8]!

	// cargar posición
	add x13,x23,x26,lsl 3	// x13 = 8*N_box + base address
	ldur x1,[x13]			// x1: posición x de la caja N

	cmp x1,0				// si x < 0 no se dibuja
	B.LT skip_draw_b
	// actualizar posición
	sub x14,x1,#1			// se resta 1 a la posición de la caja
	stur x14,[x13] 			// se actualiza la posición de la caja en la memoria

	cmp x1,SCREEN_WIDTH-BOX_SIZE		// si x > 360-40 no se dibuja 
	B.GT skip_draw_b

	mov x3,BOX_SIZE				// tamaño
	movz x4,0xfa, lsl 16		// color		
	movk x4,0x1176, lsl 00

	bl coord_to_addr			// dirección de memoria de (x,y)

	loop_box_y:					// Dibuja la caja
		mov x5,BOX_SIZE
		loop_box_x:
			str w4,[x12],#4
			sub x5,x5,1
			cbnz x5,loop_box_x

	add x12,x12,4*(SCREEN_WIDTH-BOX_SIZE)			
	sub x3,x3,1
	cbnz x3,loop_box_y

 skip_draw_b:
	add x26,x26,1 			// se aumenta el Nro de la caja para la siguiente

	ldr x30,[sp],#8
ret x30
//----------------------------
// Setea el contador si se acerca una caja
// Setea el contador si la caja está en una plataforma (para saltar entre plataformas)
set_jump:
	str x30,[sp,#-8]!

	cbnz x20,skip_jump				// si está saltando entonces no actualizo el contador

	mov x1,#SQUEARE_X_POS + 85 		// toma el px que está a 55px de distancia de la caja
	mov x2,x24						// x2: y-square position
	bl coord_to_addr				// x12: address del pixel a comprar
	movz x4,0xfa, lsl 16			// color de la caja
	movk x4,0x1176, lsl 00

	ldur w7,[x12]					// carga el color del pixel
	cmp w7,w4						// lo compara con el color de la caja
	b.NE skip_jump0					// Si es igual entonces
	mov x20,120						// resetea el contador de jump

 skip_jump0:
	
	mov x1,#SQUEARE_X_POS			// 	
	add x2,x24,#PJ_SIZE+1			// px debajo del vertice inferior izq de la caja	
	bl coord_to_addr				
	ldur w7,[x12]					// carga el color del pixel
	cmp w7,w4
	b.NE skip_jump
	ldur w8,[x12,#PJ_SIZE*4]		// px debajo del vertice inferior derecho de la caja
	cmp w7,w8						// se comparan ambos píxeles para saber si está en una 
	b.EQ skip_jump					// plataforma, si lo está entonces setea el contador de jump
	mov x20,120						// resetea el contador de jump

 skip_jump:

	ldr x30,[sp],#8
ret x30
//----------------------------
// decrementa la coordenada "y" del personaje, salta.
jump:
	cbz x20,skip2		// si el contador de jump está en cero entonces no salta.
	sub x20,x20,1

	//saltar
	cmp x20,60			// Se decrementa la coord "y" sólo en la mitad del contador de salto  
	b.LT skip2			// para producir efecto inercia
	sub x24,x24,1		// decrementa la posición y 
 skip2:

ret x30
//----------------------------
// Aumenta la coordenada "y" del personaje si se cumplen las condiciónes
caer:
	str x30,[sp,#-8]!

	cmp x24,#Y_FLOOR_POS-PJ_SIZE	// Si  y = 320 (el personaje está en el piso)
	b.EQ no_caer					// entonces no cae

	cbnz x20,no_caer				// Si el contador de jump no es cero, entonces está saltando
	//								 y no se aumenta la posición "y"
	
	mov x1,SQUEARE_X_POS+PJ_SIZE
	add x2,x24,PJ_SIZE+1			// px debajo del personaje
	bl coord_to_addr
	movz x4,0xfa, lsl 16			// color de las cajas
	movk x4,0x1176, lsl 00

	ldur w7,[x12]					// se compara si el pixel debajo del personaje 
	cmp w7,w4						// es igual al color de las boxes, si es igual
	b.EQ no_caer					// entonces no cae
	add x24,x24,1					// aumenta la coordenada "y"

 no_caer:

	ldr x30,[sp],#8
ret x30
//----------------------------
// copia el back framebuffer en el front framebuffer
copyfb:
	mov x17,Y_FLOOR_POS	

	mov x15,x29					// x15: address del back framebuffer
	mov x8, x28					// x8: address del front framebuffer

	loop_y2:
		mov x16,SCREEN_WIDTH/2
		loop_x2:
			ldr x13,[x15],#8
			str x13,[x8],#8
			sub x16,x16,1
			cbnz x16,loop_x2
	sub x17,x17,1
	cbnz x17,loop_y2

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
// Guarda las posiciones "x" de cada caja en memoria
// Se podrían guardar las posiciones en y, pero como estas no se modifican
// se pasan como parámetro y es mas rapido que leer de la memoria
set_pos_array:
	mov x16,x23					// x16: address al arreglo de posiciones
	mov x15,SCREEN_WIDTH

	// 1er escenario			
	str x15,[x16],#8
	add x15,x15,200
	str x15,[x16],#8

	// 2do escenario
	add x15,x15,SCREEN_WIDTH
	mov x14,6

 loop21:
	str x15,[x16],#8
	add x15,x15,200
	sub x14,x14,1
	cbnz x14, loop21

	//3er escenario
	mov x14,10
	add x15,x15,SCREEN_WIDTH
	
 loop22:
	str x15,[x16],#8
	add x15,x15,40
	sub x14,x14,1
	cbnz x14, loop22

	//4to escenario
	mov x14,12
	add x15,x15,SCREEN_WIDTH
	add x12,x15,150
 loop23:
	str x15,[x16],#8
	add x15,x15,40
	sub x14,x14,1
	cbnz x14, loop23

	str x12,[x16],#8
	add x12,x12,180
	str x12,[x16],#8

	//5to escenario
	add x15,x15,SCREEN_WIDTH
	mov x14,4

 loop24:
	str x15,[x16],#8
	add x15,x15,40
	sub x14,x14,1
	cbnz x14, loop24

	mov x14,6
	mov x12,x15
 loop25:
	str x15,[x16],#8
	add x15,x15,100
	sub x14,x14,1
	cbnz x14, loop25

	add x12,x12,100
	str x12,[x16],#8

	add x12,x12,200
	str x12,[x16],#8

	add x12,x12,200
	str x12,[x16],#8

	//6to escenario
	add x15,x15,SCREEN_WIDTH
	mov x12,x15
	mov x11,35
	// Triangulos
	add x15,x15,80
	loop28:
		str x15,[x16],#8
		add x15,x15,40
		sub x11,x11,1
		cbnz x11, loop28

	sub x15,x12,40
	mov x11,4

	str x15,[x16],#8
	add x15,x15,40

 	loop26:
		str x15,[x16],#8
		add x15,x15,150
		sub x11,x11,1
		cbnz x11, loop26

	add x15,x15,20
	str x15,[x16],#8

	add x15,x15,220
	str x15,[x16],#8

	add x15,x15,220
	str x15,[x16],#8

	add x15,x15,220
	str x15,[x16],#8

ret x30
//----------------------------
// Copia los px del front buffer y los mueve hacia la izquierda SIN pasar por el back buffer
// si bien no es necesaria, es más rapido que dibujar en el back y pasar al front
// usa memoria auxilar para guardar píxeles
copy_frames:
	//1) Guarda la primera columna en memoria
	ldr x10,=Aux						// x10: dirección de A

	mov x2,SCREEN_WIDTH
	mov x12,Y_FLOOR_POS					
	mul x2,x12,x2	 					// x2: 640*350 , Nro de px donde empieza el escenario inf
	add x3,x2,(SCREEN_WIDTH-1)			
	add x9,x28,x2, lsl 2		    	// x9: dirección de memoria de ese px 
	mov x12,SCREEN_HEIGH-Y_FLOOR_POS	// Contador

	loop1:
		ldr w11,[x9]
		str w11,[x10],#4
		add x9,x9,SCREEN_WIDTH*4
		sub x12,x12,1
		cbnz x12,loop1

	// copia y mueve los px del escenario inf
	add x9,x28,x2,lsl 2
	add x10,x9,4
	mov x12,SCREEN_HEIGH-Y_FLOOR_POS

	loop20:
		mov x13,SCREEN_WIDTH
		loop19:
			ldr x11, [x10],#8
			str x11, [x9],#8
			sub x13,x13,1
			cbnz x13,loop19

		sub x12,x12,#1
		cbnz x12, loop20

	//Carga la primera columna y la pega en la última
	ldr x10,=Aux
	mov x12,SCREEN_HEIGH-Y_FLOOR_POS			// counter	
	add x9,x28,x3, lsl 2

	loop3:
		ldr w11,[x10],#4
		str w11,[x9]
		add x9,x9,#SCREEN_WIDTH*4
		sub x12,x12,1
		cbnz x12,loop3

ret x30
//---------------------------------PERSONAJES-----------------------------------------------------------
pj_original:
	str x30,[sp,#-8]!
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
pj_cuadrado:

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
//
pj_calavera:
	str x30,[sp,#-8]!

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
//
pj_hongo:
	str x30,[sp,#-8]!

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

