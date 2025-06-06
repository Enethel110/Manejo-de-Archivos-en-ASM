              
TITLE PRACTICA_7:_MANEJO DE ARCHIVOS     
ORG     0100H

.DATA  
    
    MSGE01          DB  "  -------DEVELOPED BY: MARIN MARIN DANIEL ALEJANDRO------"
    MSGE02          DB  "DAME EL NOMBRE DEL ARCHIVO A BUSCAR. USA EL FORMATO 8.3",0DH,0AH
    MSGE03          DB  "EXCEDE EL NUMERO DE CARACTERES",0DH,0AH
    MSJ_ERR_1       DB  "ARCHIVO NO ENCONTRADO"
    PREGUNTA        DB  "DESEAS SOBRESCRIBIR EL ARCHIVO S/N ?"
    SUCCES_FILE     DB  "****** PROCESO REALIZADO EXITOSAMENTE ******" 
    
    NOMBRE_ARCH     DB  30 DUP (0)  ; NOMBRE DE ARCHIVO A BUSCAR .ASM Y SIRVE PARA EL NOMBRE DE .LST
    HANNDLER        DW  0           ; PARA EL MANEJADOR DEL ARCIVO .ASM LECTURA
    HANNDLEW        DW  0           ; PARA EL MANEJADOR DEL ARCIVO .LST ESCRITURA
    LINEA           DB  81 DUP (0)  ; TAMANO MAXIMO DE CARACTERES A LEER DEL ARCHIVO POR LINEA
    TAMANO_DE_LINEA DW  0           ; CONTADOR DE TAMANO DE LINEA
    FINPROG         DB  0           ; VARIABLE PARA MANTENER EL CONTROL DEL CIERRE DEL PROGRAMA
    NUEVA_LINE      DB  0DH,0AH     ; RETORNO DE CRRRO Y SALTO DE LINEA PARA ESCRIBIRLO EN EL ARCIVO .LST AL FINAL DE CADA LINEA ESCRITA
    CONTADOR_CHARS  DW  0           ; CONTADOR GLOBAL DE CARACTERES LEIDOS DEL ARCIVO
    ESPACIO_BLANCO  DB  20H         ; ESPACIO EN BLANCO PARA ESCRIBIRLO EN EL ARCHIVO, ENTRE EL NUMERO DE CHARS Y LINEA
    DIGITS          DB  '0','0','0' ; PARA GUARDAR LOS DIGITOS DEL TOTAL DE CARACTERES LEIDOS Y ESCRIBIRLO EN EL ARCHIVO
    
.CODE 
    MAIN PROC FAR
        REPEAT:
        CALL IMPRIMIR_MENSAJES   ; MOSTRAR MENSAJES EN PANTALLA LIMPIAR PANTALLA
      
        CALL LEER_CARACTERES     ; LEEMOS CARACTERES DEDE TECLADO
        CMP FINPROG, 1           ; COMPARAMOS SI HAY UN ERROR O FIN DE PROG CON 1
        JE FINPRO                ; SI LO HAY BRINCAMOS A FINALIZAR PROG
        CMP TAMANO_DE_LINEA, 0
        JE REPEAT
        
        CALL ABRIR_FILE          ; DE LO CONTRARIO ABRIMOS ARCHIVO
        CMP FINPROG, 1           ; COMPARAMOS SI HAY UN ERROR O FIN DE PROG CON 1
        JE REPEAT                ; SI LO HAY BRINCAMOS A FINALIZAR PROG
                         
        CALL SAVE_CHARS_COUNT    ; SI NO LLAMAMOS EL CONTADOR Y GUARDADO DE CHARS  
                           
        FINPRO:  
        MOV AH, 0                ; FINALIZAR PROGRAMA
        INT 20H

        ;---------------------------------------------------------------------;
        ;                        IMPRIMIR MENSAJES EN PANTALLA                ;
        ;---------------------------------------------------------------------;
        IMPRIMIR_MENSAJES PROC   
            MOV AL, 1
            MOV BH, 0
            MOV BL, 0EH   
            MOV CX, MSGE02 - MSGE01        ; IMPRIMIMOS MI NOMBRE DANIEL
            MOV DH, 23
            MOV DL, 10
            MOV BP, OFFSET MSGE01
            MOV AH, 13H
            INT 10H    
            
            MOV BL, 0AH   
            MOV CX, MSGE03 - MSGE02        ; IMPRIMIMOS EL MENSAJE QUE SOLICITA EL NOMBRE DEL ARCHIVO
            MOV DH, 0
            MOV DL, 0
            MOV BP, OFFSET MSGE02
            MOV AH, 13H
            INT 10H  
            
            MOV DL, 0                      ; POSICION X DE LA PANTALLA
            MOV DH, 3                      ; POSICION Y DE LA PANTALLA   
            CALL POSICIONAR_CURSOR         ; LLAMAMOS A POSICIONAR CURSOR
            
            MOV BL, 00H   
            MOV CX, HANNDLER - NOMBRE_ARCH ; MOSTAMOS EN NEGRO EL NOMBRE DEL ARCHIVO PARA LIMPIAR PANTALLA
            MOV DH, 3
            MOV DL, 0
            MOV BP, OFFSET NOMBRE_ARCH
            MOV AH, 13H
            INT 10H  
             
            MOV BL, 0FH                    ; CAMBIAMOS EL COLOR DE CRACTERES
            MOV DH, 3                      ; PARA ESCRIBIR
            MOV DL, 0
            INT 10H  
            
            MOV DL, 0                      ; POSICION X DE LA PANTALLA
            MOV DH, 3                      ; POSICION Y DE LA PANTALLA   
            CALL POSICIONAR_CURSOR         ; LLAMAMOS A POSICIONAR CURSOR
            
            MOV FINPROG, 0                 ; LIMPIAMOS A 0 FINPROG POR QUE NO SE LIMPIO PANTALLA Y YA NO SE TERMINE EL PROGRAMA
            CMP TAMANO_DE_LINEA,0          ; LIMPIAMOS TAMANO_DE_LINEA A 0
            RET 
        ENDP 
            
        ;---------------------------------------------------------------------;
        ;                        FUNCION PARA POSICIONAR CURSOR               ;
        ;---------------------------------------------------------------------;
        POSICIONAR_CURSOR PROC
            MOV AH, 02H
            MOV BH, 0
            INT 10H
            RET  
        ENDP 
        
        ;---------------------------------------------------------------------;
        ;                        LEER CARACTERES MEDIANTE TECLADO             ;
        ;---------------------------------------------------------------------;
        LEER_CARACTERES PROC
            LEA SI, NOMBRE_ARCH
            MOV CX, 30       ; LIMITE DE CARACTERES  
            LECTURA: 
            DEC CX 
            JZ  EXCEDIO 
 
            MOV AH, 0H
            INT 16H          ; LEER CARACTER DEL TECLADO 
            
            CMP AL, 08H      ; VERIFICAR SI ES BACKSPACE
            JE BORRAR        ; IR A BORRAR CARACTER EN PANTALLA
            
            CMP AL, 0DH      ; VERIFICAR SI ES ENTER
            JE FINCAD        ; SI LO ES VAMOS A FIN DE CADENA
            MOV [SI], AL     ; MOVEMOS EL CARACTER AL VECTOR DE ECUACION EN LA POSICION SI
            INC [TAMANO_DE_LINEA]
            INC SI           ; INCREMENTAMOS SI
            MOV AH, 0EH
            INT 10H          ; MOSTRAR EL CARACTER EN LA PANTALLA
            CMP AL, 08H      ; VERIFICAR SI ES BACKSPACE
            JNE LECTURA
           
        ; PROCESO DE BORRAR CARACTERES
        BORRAR:
            CMP CX,29
            JNE  SEGUIR_PROC
            INC CX 
            MOV DL, 0       ; POSICION X DE LA PANTALLA
            MOV DH, 3       ; POSICION Y DE LA PANTALLA
            CALL POSICIONAR_CURSOR   
            JMP LECTURA   
            
            SEGUIR_PROC: 
            DEC TAMANO_DE_LINEA
            MOV AH, 0EH
            INT 10H          ; MOSTRAR EL CARACTER EN LA PANTALLA
            DEC SI           ; DECREMENTAMOS LA POSI SI 
            MOV [SI], 0
            INC CX 
            INC CX 
            PUSH CX 
            MOV AH, 0EH
            MOV AL, 20H
            INT 10H 
        
            MOV AH, 03H       ; FUNCION 0X03: OBTENER LA POSICION DEL CURSOR
            MOV BH, 0         ; PAGINA DE PANTALLA (0 PARA LA PRIMERA PAGINA)
            INT 10H           ; LLAMAR A LA INTERRUPCION 0X10
        
            MOV AH, 02H
            SUB DL,  1
            INT 10H      
            
            POP CX
            JMP LECTURA
        FINCAD: 
            MOV AH, 0EH
            MOV AL, 0AH
            INT 10H           ; SALTO DE LINEA
            MOV AL, 0DH
            INT 10H           ; RETORNO DE CARRO 
            RET
        EXCEDIO:                    
            MOV AL, 1
            MOV BH, 0
            MOV BL, 0BH       ; COLOR DE TEXTO
            MOV CX, MSJ_ERR_1 - MSGE03 
            MOV DL, 17        ; POSICION X DE LA PANTALLA
            MOV DH, 18        ; POSICION Y DE LA PANTALLA
            MOV BP, OFFSET MSGE03
            MOV AH, 13H
            INT 10H   
            MOV FINPROG, 1
            RET
        ENDP   
        
        ;---------------------------------------------------------------------;
        ;          VALIDAR SI EL ARCHIVO EXISTE PARA ABRIRLO EN LECTURA       ;
        ;---------------------------------------------------------------------;      
        ABRIR_FILE PROC 
            MOV AH, 43H             ; "VERIFICAR ATRIBUTOS DE ARCHIVO"  SI ESISTE O NO ARCIVO 
            MOV AL, 00H             ; SIN O CON EXTENCION .ASM
            LEA DX, NOMBRE_ARCH     ; CARGA EN DX LA DIRECCION DEL NOMBRE DEL ARCHIVO 
            INT 21H
            CMP AX, 1               ; SI HAY ERROR 1
            JNE NEXT                ; SI NO HAY ERROR BRNCAMOS A NEXT
             
            CALL ADD_EXTENCION      ; AGREGAMOS LA EXTENCION .ASM
            MOV AH, 43H             ; "VERIFICAR ATRIBUTOS DE ARCHIVO"  SI ESISTE O NO 
            MOV AL, 00H            
            INT 21H 
            CMP AX, 1               ; SI HAY ERROR 1
            JNE NEXT                ; SI NO HAY ERROR BRNCAMOS A NEXT
            
            ERROR_FIND:        
            MOV BL, 0CH 
            CALL ERROR_ARCHIVO      ; IMPRIMOS MENSAJE EN PANTALL ARCHIVO NO ENCONTRADO
            MOV FINPROG, 1          ; MARCAMOS COMO TERMINADO EL PROGRAMA PARA VOLVER A 
            CALL LIMPIAR_VARIABLES  ; LIMPIAR PANTALLA Y PREGUNTA DE NUEVO EL ARCHIVO
            RET
         
            NEXT:
            MOV AH, 3DH             ; FUNCION DOS: ABRIR ARCHIVO
            MOV AL, 0               ; MODO: SOLO LECTURA
            LEA DX, NOMBRE_ARCH     ; DIRECCION DEL NOMBRE DE ARCHIVO
            INT 21H
            JC ERROR_FIND           ; SI HAY ERROR, SALTAR
            MOV HANNDLER, AX        ; GUARDAR EL MANEJADOR
            CALL CAMBIAR_EXTENSION 
            RET    
        ENDP    
        
        ;---------------------------------------------------------------------;
        ;          AGREGAR EXTENCION .ASM AL ARCHIVO SI NO SE ENCONTRO        ;
        ;---------------------------------------------------------------------;   
        ADD_EXTENCION PROC
            XOR AX, AX              ; SE LIMPIA AX
            LEA SI, NOMBRE_ARCH     ; APUNTAR AL INICIO DE LA CADENA  NOMBRE_ARCH
            MOV AX, [TAMANO_DE_LINEA]; MOVEMOS EL TAMANO DE LINEA DE CARACTERES A AX 
            ADD SI, AX              ; INCREMENTASMOS LAS POSCIONES DE CARACTERE DE ACUERDO A AX  
            MOV [SI], '.'           ; ASIGNAMOS EL  CARACTER "."
            INC SI                  ; INCREMENTASMOS LAS POSCION DE NOMBRE_ARCH
            MOV [SI], 'a'           ; ASIGNAMOS LA LETRA "A"
            INC SI                  ; INCREMENTASMOS LAS POSCION DE NOMBRE_ARCH
            MOV [SI], 's'           ; ASIGNAMOS LA LETRA "S"
            INC SI                  ; INCREMENTASMOS LAS POSCION DE NOMBRE_ARCH
            MOV [SI], 'm'           ; ASIGNAMOS LA LETRA "M"
            RET
        ENDP 
            
        ;---------------------------------------------------------------------;
        ;                   CAMBIAR EXTENCION .ASM A .LST                     ;
        ;---------------------------------------------------------------------; 
        CAMBIAR_EXTENSION PROC
            LEA SI, NOMBRE_ARCH     ; APUNTAR AL INICIO DE LA CADENA  NOMBRE_ARCH
        
        BUSCAR_PUNTO:
            MOV AL, [SI]            ; MOVEMOS EL PRIMER CHAR A AL
            CMP AL, '.'             ; COMPARAMOS SI ES "."
            JE COPIAR_SIGUIENTES    ; SI ES IGUAL YA BRINCAMOS A COPIAR NUEVA EXTENCION
            INC SI                  ; DE LO CONTRARIO INCREMENTAMOS LA POSICION DE SI A OTRO CARACTER
            JMP BUSCAR_PUNTO        ; Y REPETIMOS EL BUCLE INFINITO
        
        COPIAR_SIGUIENTES:
            INC SI                  ; INCREMENTAMOS LA POSICION DE SI EN NOMBRE_ARCH
            MOV [SI], 'l'           ; ASIGNAMOS LA LETRA "L"
            INC SI                  ; INCREMENTAMOS LA POSICION DE SI NOMBRE_ARCH
            MOV [SI], 's'           ; ASIGNAMOS LA LETRA "S"
            INC SI                  ; INCREMENTAMOS LA POSICION DE SI NOMBRE_ARCH
            MOV [SI], 't'           ; ASIGNAMOS LA LETRA "T"
            RET                     ; RETORNAMOS A DONDE SE LLAMO EL PROC
         ENDP 
     
        ;---------------------------------------------------------------------;
        ;          MENSAJE ERROR ARCHIVO NO ENCINTRADO SE IMPRIME             ;
        ;---------------------------------------------------------------------;   
        ERROR_ARCHIVO PROC
            MOV AL, 1
            MOV BH, 0  
            MOV CX, PREGUNTA - MSJ_ERR_1 
            MOV DH, 17
            MOV DL, 18
            MOV BP, OFFSET MSJ_ERR_1
            MOV AH, 13H
            INT 10H    
            RET
        ENDP    
        
        ;---------------------------------------------------------------------;
        ;   LIMPIEZA DE VARIABLES Y PANTALLA SI NO SE ENCUENTRA EL ARCHIVO    ;
        ;---------------------------------------------------------------------;   
        PROC LIMPIAR_VARIABLES
            MOV CX, [TAMANO_DE_LINEA]   ; CANTIDAD DE CARACTERES A LIMPIAR
            ADD CL, 4                   ; AGREGAMOS 4 CARACTERES MAS A LIMPIAR POR LA EXTENCION
            XOR CH, CH                  ; LIMPIAMOS PARTE ALTA
       
            MOV DI, OFFSET NOMBRE_ARCH  ; ASIGNAMOS LA POSICION INICIAL DE VECTOR NOMBRE_ARCH
        
            ; LIMPIEZA CON CICLO
            XOR AL, AL                  ; LIMPIAMOS AL
        CICLO_LIMPIAR:
            CMP CX, 0                   ; SI YA NO HAY QUE LIMPIAR
            JE FIN_LIMPIEZA             ; SE BRINCA A TERMINAR DE LIMPIAR
            STOSB                       ; [DI] = AL (0), DI++, CX--
            LOOP CICLO_LIMPIAR
        
        FIN_LIMPIEZA:                   ; FIN DE LA LIMPIEZA DEL VECTOR TAMANO_DE_LINEA
            MOV TAMANO_DE_LINEA, 0      ; LIMPIAMOS A 0  EL TAMANO_DE_LINEA
            MOV AX, 0    
            MOV BL, 00H 
            CALL ERROR_ARCHIVO          ; IMPRIMIMOS MENSAJE DE ARCHIVO NO ENCONTRADO
            RET
        ENDP 

        ;---------------------------------------------------------------------;
        ;                   LEER Y CONTAR CARACTERES DE ARCHIVO               ;
        ;---------------------------------------------------------------------;   
        SAVE_CHARS_COUNT PROC 
            CALL CREAR_ARCHIVO          ; LLAMAMOS AL PROC PARA CREAR ARCHIVO 
            MOV TAMANO_DE_LINEA, -1     ; RESTAURAMOS EL TAMANO DE LINEA A 0
        READ_LOOP1:
            LEA DI, LINEA               ; APUNTA AL INICIO DE LINEA 
            CMP TAMANO_DE_LINEA, -1     ; COMPARAMOS SI LA LINEA NO TIENE CARACTERES
            JE OMITE                    ; SI ES ASI NO NO CONVETIMOS_A_DIGITOS Y ESCRIBIMOS CHARS
            CALL CONVERTIR_A_DIGITOS    ; SI CONTIENE DATOS REALIZAMOS CONVERTIR_A_DIGITOS
            CALL ESCRIBIR_CARACTERES    ; Y ESCRIBIR_CARACTERES
            OMITE: 
            
            CALL ESCRIBIR_DIGITOS       ; ESCRIBIMOS EL CONTADOR DE CARACTERES
            MOV  TAMANO_DE_LINEA,0      ; RESTAURAMOS A 0 EL TAMANO DE LINEA
        READ_LOOP2: 
            MOV AH, 3FH                 ; LEER DEL ARCHIVO
            MOV BX, HANNDLER
            MOV DX, DI                  ; LEER 1 BYTE AL BUFFER LINEA[DI]
            MOV CX, 1
            INT 21H
            JC CERRAR_FILE              ; SI ERROR, CERRAR ARCHIVO Y SALIR
            CMP AX, 0
            JE CERRAR_FILE              ; SI EOF, CERRAR ARCHIVO SALIR
        
            MOV AL, [DI]                ; LEER EL CARACTER RECIBIDO
        
            CMP AL, 0DH                 ; ES SALTO DE LINEA 
            JE READ_LOOP2               ; SI LO ES IGNORARLO
            
            CMP AL, 0AH                 ; ES SALTO DE LINEA 
            JE READ_LOOP1               ; SI LO ES IGNORARLO
             
            INC TAMANO_DE_LINEA
            
            INC DI                      ; AVANZA AL SIGUIENTE BYTE DEL BUFFER
            INC CONTADOR_CHARS          ; AUMENTA CONTADOR DE CARACTERES VALIDOS
            JMP READ_LOOP2
        
        CERRAR_FILE:                    ; CERRAMOS ARCHIVO
            MOV DI, 0
            MOV AH, 3EH
            MOV BX, HANNDLER            ; EL CUAL ES EL DE LECTURA DE CARACTERES
            INT 21H  
            
            CALL ESCRIBIR_SALTO_LINEA
             
            MOV DI, 0                   ; CERRAMOS ARCHIVO
            MOV AH, 3EH
            MOV BX, HANNDLEW            ; EL CUAL ES EL DE ESCRITURA DE CARACTERES
            INT 21H
            
            MOV AL, 1                   ; IMPRIMIMOS MENSAJE DE SUCCES
            MOV BH, 0
            MOV BL, 0BH   
            MOV CX, NOMBRE_ARCH - SUCCES_FILE  
            MOV DH, 12
            MOV DL, 18
            MOV BP, OFFSET SUCCES_FILE
            MOV AH, 13H
            INT 10H   
            RET
        SAVE_CHARS_COUNT ENDP 
        
        ;---------------------------------------------------------------------;
        ;               VERIFICAR SI EXISTE ARCHIVO CREAR ARCHIVO             ;
        ;---------------------------------------------------------------------;   
        CREAR_ARCHIVO PROC
            MOV AH, 43H        ; SABER SI EXISTE EL ARCHIVO 
            MOV AL, 00H 
            LEA DX, NOMBRE_ARCH
            INT 21H  
            CMP AX, 1          ; SI NO EXISTE 
            JE SEGIR           ; SOLO BRINCO A SEGUIR Y LO CREAMOS

            MOV AL, 1
            MOV BH, 0
            MOV BL, 0CH     
            MOV CX, SUCCES_FILE - PREGUNTA  ; MOSTRAR MENSAJE DE SI QUIERE SOBRESCRIBIR EL ARCHIVO
            MOV DH, 5
            MOV DL, 0
            MOV BP, OFFSET PREGUNTA
            MOV AH, 13H
            INT 10H      
            
            MOV DL, 37               ; POSICION X DE LA PANTALLA
            MOV DH, 5                ; POSICION Y DE LA PANTALLA   
            CALL POSICIONAR_CURSOR   ; LLAMAMOS A POSICIONAR CURSOR
            
            CICLO:                   ; CICLO PARA RECIBIR CARACTERES EN PANTALLA
                MOV AH, 0H
                INT 16H                     
                CMP AL, 'N'        ; REALIZA COMPARACION SI ES N
                JE  NOCOOSE        ; SI ES LA LETRA N SE VA A REALIZAR LO DE NOCHOOSE
                CMP AL, 'S'        ; REALIZA COMPARACION SI ES S
                JE  SICHOOSE       ; SI ES LA LETRA S SE VA A REALIZAR LO DE SICHOOSE
                CMP AL, 'n'        ; REALIZA COMPARACION SI ES N
                JE  NOCOOSE        ; SI ES LA LETRA N SE VA A REALIZAR LO DE NOCHOOSE
                CMP AL, 's'        ; REALIZA COMPARACION SI ES S
                JE  SICHOOSE       ; SI ES LA LETRA S SE VA A REALIZAR LO DE SICHOOSE
            JMP CICLO              ; REALIZAMOS UN CICLO INFINITO HASTA QUE DIGITE ESOS CARACTERES
      
            SEGIR: ; SE CREA EL ARCHIVO SI NO EXISTE
                CALL NOMARCHIVO    
            RET
            
            NOCOOSE:
            MOV AH, 0EH            ; MOSTRAR EL CARACTER "N" EN LA PANTALLA
            INT 10H                
            ;--- SOLO ABRE EL ARCHIVO POR QUE YA EXISTE
            LEA DX,NOMBRE_ARCH
            MOV AL,1
            MOV AH,3DH
            INT 21H
            MOV [HANNDLEW],AX      ; GUARDAMOS EL MANEJADOR EN HANNDLEW
            
            ; MOVER EL PUNTERO AL FINAL DEL ARCHIVO PARA ESCRIBIR DESDE ESA POSICION
            MOV BX, HANNDLEW    
            MOV AH, 42H            ; FUNCION 42H DE DOS (MOVER PUNTERO DE ARCHIVO)
            MOV AL, 2              ; 2 = MOVER EL PUNTERO AL FINAL
            MOV CX, 0              ; NUMERO DE BYTES A MOVER (0 = MOVER AL FINAL)
            XOR DX, DX             ; SIN DESPLAZAMIENTO ADICIONAL
            INT 21H                ; LLAMADA A LA INTERRUPCION DOS         
            RET
            
            SICHOOSE:
            MOV AH, 0EH            ; MOSTRAR EL CARACTER "S" EN LA PANTALLA
            INT 10H                 
            CALL NOMARCHIVO        ; CREA ARCHIVO NUEVO SI DATOS PARA ESCRIBIR NUEVOS 
            RET    
        ENDP  
        
        ;---------------------------------------------------------------------;
        ;          CREA UN NUEVO ARCHIVO SI EXISTE LO REEPLAZA "SIN DATOS"    ;
        ;---------------------------------------------------------------------;   
        NOMARCHIVO PROC 
            LEA DX,NOMBRE_ARCH   ; CREAR ARCHIVO SI NO EXISTE SI EXISTE LO REEMPLAZA.
            MOV AH, 3CH          ; FUNCION PARA ABRIR UN ARCHIVO 
            MOV CX, 0            ; MODO NORMAL
            INT 21H              ; LLAMAR A LA INTERRUPCION 21H PARA ABRIR EL ARCHIVO
            MOV [HANNDLEW], AX   ; GUARDAR EL MANEJADOR
            RET
        ENDP 
        
        ;---------------------------------------------------------------------;
        ;          ESCRIBIMOS LA CANTIDAD DE CARACTERES ENCONTRADOS           ;
        ;---------------------------------------------------------------------;         
        ESCRIBIR_DIGITOS PROC
            MOV BX, HANNDLEW  
            MOV AH, 40H              ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
            MOV CX, 3                ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
            LEA DX, DIGITS           ; DIRECCION DEL TEXTO A ESCRIBIR
            INT 21H 
            RET
        ENDP         
        
        ;---------------------------------------------------------------------;
        ;          ESCRIBIMOS LOS CARACTERES DE ACUERDO AL TAMANO DE LINEA    ;
        ;---------------------------------------------------------------------;   
        ESCRIBIR_CARACTERES PROC 
            MOV BX, HANNDLEW  
            
            MOV AH, 40H              ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
            MOV CX, 1                ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
            LEA DX, ESPACIO_BLANCO   ; DIRECCION DEL TEXTO A ESCRIBIR
            INT 21H 
            
            MOV AH, 40H              ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
            MOV CX, TAMANO_DE_LINEA  ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
            LEA DX, LINEA            ; DIRECCION DEL TEXTO A ESCRIBIR
            INT 21H                  ; LLAMADA A LA INTERRUPCION DOS 
            
            CALL ESCRIBIR_SALTO_LINEA; ESCRIBIMOS SALTO DE LINEA
            RET
        ENDP    
        
        ;---------------------------------------------------------------------;
        ;          ESCRIBIMOS EL LOS CARACTERES PARA EL SALTO DE LINEA        ;
        ;---------------------------------------------------------------------;   
        ESCRIBIR_SALTO_LINEA PROC
            MOV BX, HANNDLEW 
            MOV AH, 40H              ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
            MOV CX, 2                ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
            LEA DX, NUEVA_LINE       ; DIRECCION DEL TEXTO A ESCRIBIR
            INT 21H                  ; LLAMADA A LA INTERRUPCION DOS
            RET                  
        ENDP
       
        ;---------------------------------------------------------------------;
        ;  COMVETIMOS EL NUMERO ENTERO A DIGITOS CHAR PARA ESCRIBIRLOS        ;
        ;---------------------------------------------------------------------;   
        CONVERTIR_A_DIGITOS PROC
            MOV AX, CONTADOR_CHARS    ; AX = NUMERO
            MOV BX, 100               ; BX = 100 (PARA CENTENAS)
        
            ; CENTENAS
            XOR DX, DX
            DIV BX                    ; AX / 100 -> AX = COCIENTE (CENTENAS), DX = RESTO
            ADD AL, '0'               ; CONVERTIR A ASCII
            MOV DIGITS[0], AL         ; MOVEMOS A POSICION 0 EL CARACTER DE AL
                                    
            MOV AX, DX                ; AX = RESTO (LO QUE QUEDA POR DIVIDIR)
            MOV BX, 10                ; CONVERTIR A ASCII
        
            ; DECENAS
            XOR DX, DX
            DIV BX                    ; AX / 10 -> AX = COCIENTE (DECENAS), DX = RESTO
            ADD AL, '0'               ; CONVERTIR A ASCII
            MOV DIGITS[1], AL         ; MOVEMOS A POSICION 1 EL CARACTER DE AL
        
            ; UNIDADES
            ADD DL, '0'               ; CONVERTIR A ASCII
            MOV DIGITS[2], DL         ; MOVEMOS A POSICION 0 EL CARACTER DE DL
            RET
        ENDP
        
    ENDP MAIN      