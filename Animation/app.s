.include "funciones.s"

.equ DELAY_MAIN,	24		// Change the animation speed
.equ SKIN,			0 		// Select the character desing (using a number between 0 and 6)
/* 
Diseños: 
 0: Original
 1: Con lentes
 2:	Creeper (minecraft)
 3: Cuadrado
 4: Calavera
 5: Llorando
 6: Hongo
*/
/*
-Duración esperada de la animación: 25s aprox
- La idea de la animación es leer píxeles específicos para determinar cuándo tiene que salta o caer el personaje, 
además de saltar automaticamente entre plataformas.
-Cada frame de la animación se dibuja en el back_framebuff(definido en funciones.s), cuando la imagen 
ya está terminada se pasa al front_framebuff esto es para que la imagen que se ve en pantalla 
no cambie mientras se dibuja la siguiente.

Registros reservados
	x19: SKIN
	x20: Jump counter
	x21: x-square position
	x23: address to Array_pos
	x24: y-square position
	x25: contador para el movimiento del fondo
	x26: contador de cajas
	x27: Multiplicador de delay
	x28: addres to front framebuffer
	x29: addres to back framebuffer
*/

.globl main
main:
	// Seteo de parámetros y memoria
 	mov x28, x0						// Save framebuffer base address to x28
	mov x19,SKIN					// Guarda el número de la skin en x19
	mov x24,Y_FLOOR_POS-PJ_SIZE		// Setea la posición "y" de la caja
	mov x22,#8						// Contador para el movimiento del fondo						
	mov x20,#0						// Set jump counter 
	mov x21,#0						// Setea la coordenada "x" del personaje 
	ldr x23,=Array_pos				// x23 : address to Array_pos
	mov x27,#3					
	bl set_pos_array 				// Escribe en el array_pos las coord "x" de los obstáculos

//----------------------------------Animación ----------------------------------
	// Escenario inicial - fondo estático
	bl draw_background_inf				// Dibujar el fondo inferior

 	loop_ini:										
		bl draw_background				// Dibuja el fondo
		bl draw_pj						// Dibuja el personaje
		add x21,x21,#1					// Mueve el personaje 
		bl copyfb						// Copia el back framebuff en el front
		bl delay
		cmp x21,SQUEARE_X_POS			// Se mueve hasta la posición inicial
		b.NE loop_ini
	
	// Dibujar GO
	mov x27,#800					// Multiplicador de delay
	bl delay						// Añade delay
	bl draw_go						// Dibuja GO 
	bl delay
	mov x27,#1

 // Escenario en movimiento 
mainloop:	
	bl draw_background		// Dibuja el fondo superior

	bl draw_boxes			// Dibuja los obstáculos que esten en el rango de la pantalla	

	bl set_jump				// Calcula si hay que setear el contador de salto

	bl jump					// Salta si el contador de salto es distinto de cero

	bl caer					// Cae por gravedad

	bl draw_pj				// Dibuja el personaje

	bl copy_frames			// copia y mueve los pixeles del fondo inferior

	bl copyfb				// Copia el back framebuff en el front

	bl delay				// Añadir delay

	bl move_background		// Actualiza contadores para el movimiento del fondo superior

	// Animación de salida
	cmp x25,1200			// usando a x25 como un contador
	b.LE mainloop			// cuando es igual a 1200 se mueve el personaje
	add x21,x21,1			// hasta el final de la pantalla

	cmp x25,1400			// cuando llega a 1400 se termina la animación
	b.EQ InfLoop			// y se pinta la pantalla de negro

	b mainloop

//------------------ FIN animación ---------------------------------
// Infinite Loop 
InfLoop: 		// Pinta la pantalla de negro
	mov x10,0
	mov x2, SCREEN_HEIGH          
 loop_inf1:
	mov x1, SCREEN_WIDTH/2   
 loop_inf0:
	str x10,[x0],#8
	sub x1,x1,1	   
	cbnz x1,loop_inf0	   
	sub x2,x2,1	   
	cbnz x2,loop_inf1	   

	b InfLoop
//--
// Agrega delay al mainloop
delay: 
	mov x9, DELAY_MAIN 		// set counter
	mul x9,x9,x9
	mul x9,x9,x9
	mul x9,x9,x27			

 	dloop:
		sub x9,x9,1
		cbnz x9, dloop

ret x30
 