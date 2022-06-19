.data
mapa: .asciz "___________________________________________________|\n                                                   |\n     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n___________________________________________________|\n                                                   |\n                                                   |\n          +-------------+                          |\n          |             |                          |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n +-------------------------------------------+     |\n |                                           |     |\n |                                           |     |\n |                                           |     |\n +-------------------------------------------+     |\n"
mapaLen = . - mapa
personaje: .byte ' ',' ',' ',' ',' ',' ',' '

contadorParaCuerpo: .word 0


partesPersonaje: .byte '\\', '/', '|', '\\', '|', '/', 'o'
cls: .asciz "\x1b[H\x1b[2J" //una manera de borrar la pantalla usando ansi escape codes
lencls = .-cls


quedanLetrasString: .ascii "Quedan letras por adivinar: "
quedanLetrasStringLen = .- quedanLetrasString

stringCantVidas: .ascii "Cantidad de vidas:  \n"
stringCantVidasLen = . - stringCantVidas

cantVidasCaracteres: .byte '1', '2', '3', '4', '5', '6', '7' // lo uso para imprimir la cantidad de vida
 
preguntado: .word 0
palabra: .asciz "        " // reservo espacio para la palabra que va a tener que adivinar


cantidadLetrasDePalabra: .word 8 // reservo espacio para guardar la cantidad de letras de palabra que va a tener

palabras: .asciz "facultad","escalera", "paraguas", "mosquito","palabras" //posibles palabras


cantidadLetrasDePalabraModificable: .word 0x00000000 // contador que uso para saber cuantas letras tiene que adivinar

auxPalabra: .asciz "12345678" // esto es lo que se reemplaza con "@@@@@". se usa para mostrar por pantalla
cantidadLetrasDePalabraAux= .- auxPalabra

stringInicial: .asciz "___________________________________________________|\n                                                   |\n     *** EL JUEGO DEL AHORCADO - ORGA 1 ***        |\n___________________________________________________|\n\n\nIngrese un numero entre 1 y 5: "

stringInicialLen = .- stringInicial
vidas: .word 7 // cantidad de vidas

letrasTachadas: .zero 128 // reservo 32 bits para guardar las letras que va ingresando el usuario. ej ['p', 'a', 'e']

contador: .word 0x00000000

ganoString: .ascii "Felicidades! Ganaste!\n"
ganoStringLen = . - ganoString
perdioString: .ascii "Perdiste! :c\n"
perdioStringLen = . - perdioString

numeroInicial: .word 0 // numero que ingresa el usuario la primera vez para elegir la palabra

letraSeleccionada: .byte '' // se va a guardar la letra que entro por teclado con cada vuelta de ciclo

//----------------------------------------------------------
.text             @ Defincion de codigo del programa
//----------------------------------------------------------
imprimirMapa:
    .fnstart
    
    // Se encarga de imprimir el mapa
    ldr r0, =mapa

    //Posicion de la cabeza  + 447
    ldr r2, =personaje 
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#448 // llevo el puntero de mapa a la pocicion de la cabeza
    strb r3, [r0] // seteo el caracter que apunta mapa con la cabeza

    add r2, r2, #1 // paso al siguiente caracter del personaje (brazo izq)

    //Posicion del brazo izquierdo + 52
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#52 // llevo el puntero de mapa a la pocicion de la del brazo izquierdo
    strb r3, [r0] // seteo el caracter que apunta mapa con el brazo izquierdo

    add r2, r2, #1 // paso al siguiente caracter del personaje (cuerpo 1)

    //Posicion del cuerpo 1 + 1
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#1 // llevo el puntero de mapa a la pocicion de cuerpo 1
    strb r3, [r0] // seteo el caracter que apunta mapa con cuerpo 1

    add r2, r2, #1 // paso al siguiente caracter del personaje (brazo derecho)

    //Posicion del brazo derecho + 1
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#1 // llevo el puntero de mapa a la pocicion del brazo derecho
    strb r3, [r0] // seteo el caracter que apunta mapa el brazo derecho

    add r2, r2, #1 // paso al siguiente caracter del personaje (cuerpo 2)

    //Posicion del cuerpo 2 + 52
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#52 // llevo el puntero de mapa a la pocicion del cuerpo 2
    strb r3, [r0] // seteo el caracter que apunta mapa con el cuerpo 2

    add r2, r2, #1 // paso al siguiente caracter del personaje (pierna izq)

    //Posicion de la pierna izq + 51
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#52 // llevo el puntero de mapa a la pocicion de la pierna izq
    strb r3, [r0] // seteo el caracter que apunta mapa con la pierna izq

    add r2, r2, #1 // paso al siguiente caracter del personaje (pierna derecha)

    //Posicion de la pierna derecha + 2
    ldrb r3, [r2] // r2 <- caracter de personaje

    add r0,r0,#2 // llevo el puntero de mapa a la pocicion de la pierna derecha
    strb r3, [r0] // seteo el caracter que apunta mapa con la pierna derecha


    //imprimo parte de la palabra con los "@@@"
    ldr r2, =auxPalabra // traigo la direccion de memoria de la palabra a mostrar, la que tiene los "@"
    ldrb r3, [r2] // r3 <- le asigno el caracter

    add r0, r0, #300 // LLevo el puntero de mapa hasta el primer lugar donde se va a imprimir la palabra

cicloImprimir:
    
    strb r3, [r0] // seteo la la direccion que apunta r0 con el caracter dentro de r3
    add r0,r0,#1 // voy al sigugiente caracter de mapa

    add r2,r2, #1 // voy al siguiente caracter de la palabra
    ldrb r3, [r2] // r3 <- le asigno el caracter

    cmp r3,#00 // fin de cadena?
    beq fin_de_cadena_imprimir_mapa
    bal cicloImprimir

fin_de_cadena_imprimir_mapa:

    mov r1, #0 // limpio registros
    mov r2, #0

    ldr r1, =mapa
    ldr r2, =mapaLen
    
    push {lr}

    bl imprimirString // imprimo el mapa

    pop {lr}

    bx lr

    .fnend
//---------------------------------------------------

actualizarCuerpo:
    // Se encarga de actualizar el vector que contiene el cuerpo del muñeco dependiendo las vidas
    // inputs 
    // r0 = cantidad de vidas
    .fnstart

    // Limpio registros
    mov r1, #0
    mov r2, #0
    mov r3, #0 
    mov r4, #0

    ldr r4, =contadorParaCuerpo
    ldr r5, [r4] // r5 = contador

    ldr r1, =personaje // direccion al primer caracter de personaje
    ldr r2, =partesPersonaje // direccion al vector con las partes del personaje que va a dibujar
    

    add r2, r2, r0 // a la direccion de memoria del vector de partes del cuerpo le sumo la cantidad de vidas
    
    ldrb r3, [r2] // me traigo el caracter que hay que dibujar

    add r1,r1,r5 // muevo la direccion de personaje la cantidad de veces que tiene el contadorParaCuerpo

    strb r3,[r1] // seteo un nuevo caracter en personaje

    add r5, r5, #1 // contador++
    str r5, [r4] // actualizo el contador en memoria

    bx lr
    
    
    .fnend

//---------------------------------------------------
imprimirString:
      .fnstart
    //imprime una cadena por pantalla
      //inputs
      //r1=puntero al string que queremos imprimir
      //r2=longitud de lo que queremos imprimir
      mov r7, #4 // Salida por pantalla
      mov r0, #1 // Indicamos a SWI que sera una cadena
      swi 0      // SWI, Software interrup

      bx lr

      .fnend

//----------------------------------------------------------

setearStringArrobas:
        .fnstart
        // r0 = direccion al primer caracter de la palabra
        
        // r2 = caracter que se va a usar para reemplazar
        mov r4, r0 // Guardo la direccion del primer caracter en r4
ciclo_setearStringArrobas:
        mov r5, #0 // limpio registro
        ldrb r5, [r0] // guardo el caracter
        cmp r5, #00 // es final de la palabra?
        beq es_final_palabra // salta al la etiqueta que termina la funcion

        strb r2, [r0] // al caracter de la direccion apauntada por r0 le asigno lo que hay en r3 = @
        add r0, r0, #1 // sumo un byte, para que vaya al siguiente caracter
        bal ciclo_setearStringArrobas

es_final_palabra:
        mov r0, r4 // r0 <- primer caracter de la palabra ya modificada
        bx lr // salgo de la funcion

        .fnend
//-----------------------------------------------------------
clearScreen:
      .fnstart
      mov r0, #1
      ldr r1, =cls
      ldr r2, =lencls
      mov r7, #4
      swi #0

      bx lr //salimos de la funcion mifuncion
      .fnend

//----------------------------------------------------------
imprimirVidas: 
    .fnstart
    // Se encarga de imprimir el string que dice cuantas vidas restantes tiene
    //inputs
    // r3 = cantidad vidas 7
    
    ldr r1, =cantVidasCaracteres

    
    sub r3, #1
    ldr r0, =stringCantVidas // puntero al string que tiene que imprimir

    add r0, r0, #19 // Apunto el puntero al final del string
    
    add r1, r1, r3 // le sumo al puntero del vector de caracteres de vidas la cantidad de vidas.

    ldrb r2, [r1] // r2 <- un caracter del vector cantVidasCaracteres

    strb r2, [r0] // seteo lo que apunta r0 (el final del string) con el caracter de r2 (un caracter dependiendo las vidas)

    push {lr}

    // imprimo el string
    ldr r1, =stringCantVidas
    ldr r2, =stringCantVidasLen
    bl imprimirString

    pop {lr}

    bx lr

    .fnend

//----------------------------------------------------------

leerLetrasPorTeclado:

    //Lee una letra por teclado para guardarla en el puntero de letraSeleccionada
    
    .fnstart
    
    mov r7, #3 // Lectura x teclado
    mov r0, #0 // Ingreso de cadena
    mov r2, #3 // Leer cant caracteres
    ldr r1, =letraSeleccionada // Donde se guarda lo ingresado
    swi 0 
    
    bx lr

    .fnend

//--------------------------------------------------------------

yaIngresoLetra:
    // Se encarga de chequear si el usuario ya habia ingresado la letra que ingreso nueva
    // verifica en el vector "letrasTachadas" si ya existe la letra o no
    // Si la letra no existe, la agrega al vector
    // Devuelve 0 o 1, 0 si la letra no existia, 1 si la letra existia

    // inputs 
    // r0 = caracter ingresado

    //outputs
    // r1 = 0/1
    
    .fnstart
    
    ldr r1, =contador 
    ldr r1, [r1] // r1 lo uso como contador. Inicia en 0

    ldr r2, =letrasTachadas // r2 <- direccion de memoria del vector donde guardo las letras que ya ingreso
    

ciclo_yaIngresoLetra:

    ldr r3, [r2] // r3 <- caracter de esa direccion de memoria

    cmp r3, #0x00000000 // es un espacio vacio ?
    beq guardarCaracter 

    cmp r3, r0 // el caracter ingresado es igual al caracter traido del vector?
    beq existeCaracter // salta si existe el caracter

    add r2, r2, #4 // voy a la siguiente pocicion

    bal ciclo_yaIngresoLetra

guardarCaracter: // guarda el caracter en el vector

    str r0, [r2] // guardo el caracter en la direccion de memoria apuntada actualmente
    mov r1, #0 // devuelvo 0, porque no existia el caracter
    bx lr // salgo de la funcion

existeCaracter:

    mov r1, #1 // devuelvo 1, porque el caracter ya existe
    bx lr

    .fnend

//--------------------------------------------------------------
adivinoLetra:
    // Se encarga de chequear si la letra ingresada pertenece a la palabra
    // Si pertenece, reemplaza el arroba de la letra encontrada por la letra
    // Si no encontro una letra, hace vidas=vidas-1
    // ej: palabra "ave" = "@@@""; letraIngresada = 'a' -> palabra = "a@@"
    // Devuelve 0 o 1, 1=true 0=false en r1

    // inputs
    // r0 = caracter ingresado
    // outputs 
    // r1 = 0 o 1

    .fnstart

    mov r1, #0
    
    ldr r4, =contador 
    ldr r4, [r4] // r3 <- 0

    ldr r5, =palabra // r5 <- puntero a la palabra que tiene que adivinar


ciclo_adivinoLetra:

    mov r2, #0 // limpio r2
    ldrb r2, [r5] // r2 <- el contenido de lo que apunta r5 (caracter de la palabra)

    cmp r2,#00 // es final de palabra?
    beq termino

    cmp r2, r0 // el caracter de r2 es igual al caracter ingresado ?
    beq reemplazarCaracter

sigo_adivinoLetra:

    add r4, r4, #1 // contador++
    add r5, r5, #1 // voy a la siguiente posicion de palabra
    bal ciclo_adivinoLetra
termino: // sale de la funcion

    bx lr

reemplazarCaracter:

    ldr r3, =auxPalabra // r3 <- la direccion de auxPalabra, la que contiene los @
    add r3, r3, r4 // A la direccion de memoria de auxPalabra le sumo el contador, para guardar el caracter en la pocicion correspondiente
    strb r0, [r3] // a la direccion apuntada por r3 le asigno el caracter

    //Resto uno a la cantidadLetrasDePalabraModificable, que cuando llega a cero siginifica que gano
    ldr r3, =cantidadLetrasDePalabraModificable 
    ldr r2, [r3] // r2 <- el valor
    
    sub r2, #1 // cantidadLetrasDePalabraModificable <- cantidadLetrasDePalabraModificable - 1
    str r2, [r3] // seteo el nuevo valor en memoria

    mov r1, #1 // devuelve 1 porque encontro letra
    bal sigo_adivinoLetra

    .fnend

//------------------------------------------------------
restarVidaE:
    // Resta una vida

    .fnstart

    ldr r2, =vidas 
    ldr r3, [r2] // r3 <- cantidad de vidas

    sub r3, #1 
    str r3, [r2] // Al puntero de vidas le asigno el nuevo valor
    bx lr

    .fnend
//----------------------------------------------------------------
configuracionesIniciales:
    // Se encarga de pedir un valor al usuarios para elegir la palabra
    // Setea todos los caracteres de la palabra con el caracter '@'

    .fnstart

    
    push {lr} 

    // Pido al usuario que ingrese un valor, para luego elegir una palabra y setearla en palabra
    ldr r1, =stringInicial
    ldr r2, =stringInicialLen
    bl imprimirString // Imprimo "Ingrese un numero entre 1 y 5";

    // leo un valor por teclado
    mov r7, #3 // Lectura x teclado
    mov r0, #0 // Ingreso de cadena
    mov r2, #2 // Leer cant caracteres
    ldr r1, =numeroInicial // Donde se guarda lo ingresado
    swi 0 

    ldr r2, =numeroInicial
    ldrb r1, [r2] // r1 <- el numero ingresado

    sub r1,#0x00000030 // Transformo el caracter en entero restandole 30
 
    ldr r3, =palabras // r3 <-  puntero a las posibles palabras
    bl moverPuntero // llamo a una funcion que mueve el puntero dependiendo el valor ingresado

 
    ldr r2, =palabra // r2 <- puntero a palabra
    
    ldr r4, =contador
    ldr r4, [r4] // r4 <- contador 

cicloConfg: 
    
   
    ldrb r5, [r3] // r5 <- el caracter de la palabra escogida 

    cmp r5, #00 // es fin de cadena?
    beq fin_de_cadena_seteo_palabra

    strb r5, [r2] // guardo en "palabra" el caracter de r5

    add r4,r4,#1 // contador++
    add r3,r3,#1 // aumento un byte a la direccion de memoria de palabras para que apunte al siguiente caracter
    add r2,r2,#1 // aumento un byte a la direccion de memoria de palabra, que apunta a palabra, para guardar el siguiente caracter alado del anterior

    bal cicloConfg

fin_de_cadena_seteo_palabra: 

    
    ldr r5, =cantidadLetrasDePalabra
    str r4, [r5] // guardo el valor del contador en cantidadLetrasDePalabra, que tiene el largo de la palabra


    // seteo el largo de la palabra en cantidadLetrasDePalabraModificable
    ldr r2, =cantidadLetrasDePalabraModificable // traigo la direccion de memoria de donde va a guardarse el largo de la palabra
    str r4, [r2]

    
    //Seteo todos los caracteres del string a ´@´
    ldr r0, =auxPalabra // r0 <- direccion de memoria de palabra aux
    mov r2, #'@' // r2 <- el caracter que se va a usar para reemplazar las letras
    bl setearStringArrobas 

    pop {lr}

    bx lr

    .fnend

//---------------------------------------------------------------
moverPuntero:
    // mueve el puntero de r3
    // esta funcion la uso para escoger una palabra, dependiendo el numero que ingresa el usuario.
    // inputs 
    // r3 = puntero 
    // r1 = numero

    .fnstart
ciclo_mover_puntero:

    sub r1, #1 // le resto uno al numero ingresado para luego saber cuantas veces tengo que sumarle 9 bytes al puntero para que vaya variando entre las palabras

    cmp r1, #0 // numero de r1 = 0? significa que no tengo que moverlo, ya que eligio la primer palabra
    beq fin_mover_puntero 

    add r3,r3,#9 // al puntero de r3, lo corro 9 bytes, ya que toda las palabras ocupan 9 bytes
    
    bal ciclo_mover_puntero
     

fin_mover_puntero: // sale de la funcion
    
    bx lr

    .fnend
//---------------------------------------------------------------


.global main        @ global, visible en todo el programa
main:

    bl configuracionesIniciales // Aplico configuraciones iniciales antes de empezar a jugar


    /* <CODIGO CICLO> */
mainCiclo:
    

    bl clearScreen 

    bl imprimirMapa

    ldr r2, =vidas 
    ldr r3, [r2] // r3 <- cantidad de vidas

    // Imprimo "Cantidad de vidas: [cantidadDeVidas]"
    bl imprimirVidas 

    // Imprimo "Quedan letras por adivinar: "
    ldr r1, =quedanLetrasString
    ldr r2, =quedanLetrasStringLen
    bl imprimirString

    // Leo la letra por teclado
    bl leerLetrasPorTeclado

    
    ldr r0, =letraSeleccionada
    ldrb r0, [r0] 

    bl yaIngresoLetra // chequea si la letra que eligio, ya la habia elegido. Si no, la guarda en un vector
    cmp r1, #1 // Si es 1 salta a mainCiclo, y pide otro caracter porque el anterior ya la habia ingresado
    beq mainCiclo // salta si es igual

    // chequea si la letra ingresada pertenece a la palabra
    bl adivinoLetra
    // r1 = 0 o 1 | dependiendo si pertenecia o no la letra 0 = false 1 = true

    cmp r1, #0 // no encontro letra?
    beq noEncontroLetra 


encontroLetra: // sigue aca si encontro la letra

    ldr r0, =cantidadLetrasDePalabraModificable 
    ldr r0, [r0] // Obtengo este valor para saber si aun quedan letras por adivinar
    cmp r0, #0 // no le quedan letras por divinar ?
    beq gano 

    bal mainCiclo

noEncontroLetra:
    
    
    bl restarVidaE // Resta una vida
    
    ldr r0, =vidas
    ldr r0, [r0]

    bl actualizarCuerpo // Actualiza el vector del cuerpo

    cmp r0, #0 // tiene 0 vidas?
    beq perdio

    bal mainCiclo

    /* </CODIGO DE MAIN CICLO> */
gano: // salta cuando gana

    ldr r2, =ganoStringLen // r2 = tamaño de la cadena ganoString
    ldr r1, =ganoString   // r1 = puntero a la cadena ganoString
    bl imprimirString

    bal fin

perdio:  // salta cuando pierde

    bl clearScreen 
    bl imprimirMapa 

    ldr r2, =perdioStringLen // r2 = Tamaño de la cadena perdioString
    ldr r1, =perdioString // r1 = puntero a la cadena perdioString
    bl imprimirString
    bal fin

fin:
    mov r7, #1    // Salida al sistema
    swi 0
