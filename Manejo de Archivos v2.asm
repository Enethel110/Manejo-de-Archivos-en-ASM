TITLE PRACTICA_7_MANEJO_DE_ARCHIVOS     
ORG 0100H  

.DATA
    NOMBRE   DB  "CARLOS ENETHEL MENDOZA RESENDIZ"       
    MENSAJE1 DB  "NOMBRE DEL ARCHIVO A BUSCAR. USA EL FORMATO 8.3" 
    EXCEDE_CARACTERES   DB  "EXCEDIO EL NUMERO DE CARACTERES" 
    ERROR_ARCHIVO DB "ARCHIVO NO ENCONTRADO" 
    SOBRESCRIBIR_SI_NO DB "EL ARCHIVO .LST YA EXISTE, DESEA SOBRESCRIBIRLO [Y / N]?"
    FINALIZO_PROG DB "CONTEO DE CARACTERES Y ESCRITURA EN ARCHIVO .LST FINALIZADO "
    
    NOMBRE_DEL_ARCHIVO DB  30 DUP (0)   ; NOMBRE DEL ARCHIVO A BUSCAR Y CREAR
    HANDLE_ASM DW 0
    HANDLE_LST DW 0                     ; MANEJADOR DEL ARCHIVO DE LECTURA .ASM
    LINEA_LEIDA DB 80 DUP (0)           ; MANEJADOR ARCHIVO DE ESCRITURA .LST
    TAM_LINEA_LEIDA DW 0                ; CONTADOR DE TAMANO DE LINEA QUE SE LEE
    CONT_DE_CHARS_LEIDOS DW 0           ; CONTADOR DE CARACTERES LEIDOS DEL ARCHIVO
    SALTO_DE_LINEA  DB  0DH,0AH         ; ESCRIBIMOS SALTO DE LINEA EN ARCHIVO .LST
    ESPACIO_EN_BLANCO  DB  20H          ; ESCRIBIMOS ESPACIO EN BLANCO EN ARCHIVO .LST
    CHARS_NUMEROS DB '0','0','0'        ; NUMEROS DE TRES CIFRAS EN ASCII
.CODE                               
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0DH   
    MOV CX, MENSAJE1 - NOMBRE               ; MI NOMBRE
    MOV DH, 0                               ; POSICION EN Y
    MOV DL, 24                              ; POSICION EN X
    MOV BP, OFFSET NOMBRE
    MOV AH, 13H
    INT 10H  
;------------------------------------------------------------------------------------------------
    MOV BL, 0AH 
    MOV CX, EXCEDE_CARACTERES - MENSAJE1    ; MENSAJE 1
    MOV DH, 2                               ; POSICION EN Y
    MOV DL, 0                               ; POSICION EN X
    MOV BP, OFFSET MENSAJE1
    MOV AH, 13H
    INT 10H  
;------------------------------------------------------------------------------------------------
    MOV DH, 4                               ; POSICION Y ; POSICIONAR CURSOR
    MOV DL, 0                               ; POSICION X 
    MOV AH, 02H
    MOV BH, 0
    INT 10H    
;------------------------------------------------------------------------------------------------
    LEA SI, NOMBRE_DEL_ARCHIVO 
    MOV CX, 30                              ; LEER CARACTERES DEL NOMBRE DEL ARCHIVO CON SU EXTENCION
    LECTURA:
    DEC CX
    JZ  EXCEDIO
    
    MOV AH, 0H
    INT 16H                                 ; LEER CARACTER DEL TECLADO
    
    CMP AL, 08H                             ; VERIFICAR SI ES BACKSPACE
    JE BORRAR                               ; IR A BORRAR CARACTER EN PANTALLA
    
    CMP AL, 0DH                             ; VERIFICAR SI ES ENTER
    JE FINCAD                               ; SI LO ES VAMOS A FIN DE CADENA
    MOV [SI], AL                            ; MOVEMOS EL CARACTER AL VECTOR DE ECUACION EN LA POSICION SI
    
    INC SI                                  ; INCREMENTAMOS SI
    MOV AH, 0EH
    INT 10H                                 ; MOSTRAR EL CARACTER EN LA PANTALLA
    CMP AL, 08H                             ; VERIFICAR SI ES BACKSPACE
    JNE LECTURA   
;------------------------------------------------------------------------------------------------    
BORRAR:                                     ; BORRADO DE CARACTERES
    CMP CX,29
    JNE  SEGUIR_PROC
    INC CX
    MOV AH, 02H
    MOV BH, 0
    INT 10H   
    JMP LECTURA
    
SEGUIR_PROC:
    MOV AH, 0EH
    INT 10H                                 ; MOSTRAR EL CARACTER EN LA PANTALLA
    DEC SI                                  ; DECREMENTAMOS LA POSI SI
    MOV [SI], 0         
    INC CX
    INC CX
    PUSH CX
    MOV AH, 0EH
    MOV AL, 20H
    INT 10H
    
    MOV AH, 03H                             ; FUNCION 0X03: OBTENER LA POSICION DEL CURSOR
    MOV BH, 0                               ; PAGINA DE PANTALLA (0 PARA LA PRIMERA PAGINA)
    INT 10H                                 ; LLAMAR A LA INTERRUPCION 0X10
    
    MOV AH, 02H
    SUB DL,  1
    INT 10H
    
    POP CX
    JMP LECTURA   
;------------------------------------------------------------------------------------------------
FINCAD:                                     ; SI ES FIN DE CADENA
    MOV AH, 0EH
    MOV AL, 0AH
    INT 10H                                 ; SALTO DE LINEA
    MOV AL, 0DH
    INT 10H                                 ; RETORNO DE CARRO 
    JMP EXISTE_EL_FILE
EXCEDIO:
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0BH                             ; COLOR DE TEXTO
    MOV CX, ERROR_ARCHIVO - EXCEDE_CARACTERES
    MOV DL, 15                              ; POSICION X DE LA PANTALLA
    MOV DH, 10                              ; POSICION Y DE LA PANTALLA
    MOV BP, OFFSET EXCEDE_CARACTERES
    MOV AH, 13H
    INT 10H
    JMP FIN_PROGRAMA
    
;------------------------------------------------------------------------------------------------
EXISTE_EL_FILE:                             ; VERIFICAR  SI EXSTE O NO EL ARCHIVO .ASM O X EXTENCION
    MOV AH, 43H                     
    MOV AL, 00H                    
    LEA DX, NOMBRE_DEL_ARCHIVO              ; CARGA EN DX LA DIRECCION DEL NOMBRE DEL ARCHIVO 
    INT 21H
    CMP AX, 1                      
    JE ERROR_FILE                           ; SI NO HAY ERROR 
     
ABRIR_ARCHIVO:
    MOV AH, 3DH                             ; FUNCION ABRIR ARCHIVO
    MOV AL, 0                               ; SOLO LECTURA
    LEA DX, NOMBRE_DEL_ARCHIVO              ; NOMBRE DE ARCHIVO
    INT 21H                     
    JC ERROR_FILE                           ; SI HAY ERROR, SALTAR
    MOV HANDLE_ASM, AX                      ; GUARDAR EL MANEJADOR 
    JMP NUEVO_NOM_ARCHIVO
;------------------------------------------------------------------------------------------------    
ERROR_FILE:                                    ; ERROR ARCHIVO
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0BH   
    MOV CX, SOBRESCRIBIR_SI_NO - ERROR_ARCHIVO ; ERROR ARCHIVO
    MOV DH, 10                                 ; POSICION EN Y
    MOV DL, 15                                 ; POSICION EN X
    MOV BP, OFFSET ERROR_ARCHIVO
    MOV AH, 13H
    INT 10H 
    JMP FIN_PROGRAMA 
;------------------------------------------------------------------------------------------------    
NUEVO_NOM_ARCHIVO:
    LEA SI, NOMBRE_DEL_ARCHIVO                 ; CAMBIAMOS LA EXTENCION A .LST PARA CREAR EL NUEVO ARCIVO  
ENCONTRAR_PUNTO:    
    MOV AL, [SI]            
    CMP AL, '.'             
    JE CAMBIA_EXTENCION    
    INC SI                  
    JMP ENCONTRAR_PUNTO  
CAMBIA_EXTENCION:
    INC SI                  
    MOV [SI], 'l'                               ; ASIGNAMOS LA LETRA "L"
    INC SI                  
    MOV [SI], 's'                               ; ASIGNAMOS LA LETRA "S"
    INC SI                  
    MOV [SI], 't'                               ; ASIGNAMOS LA LETRA "T" 
;-----------------------------------------------------------------------------------------------
    MOV AH, 43H                                 ; VERIFICAR  SI EXSTE O NO EL ARCHIVO .LST                   
    MOV AL, 00H                    
    LEA DX, NOMBRE_DEL_ARCHIVO                  ; CARGA EN DX LA DIRECCION DEL NOMBRE DEL ARCHIVO 
    INT 21H
    CMP AX, 1                      
    JE CREAR_ABRIR 
    
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0CH     
    MOV CX, FINALIZO_PROG - SOBRESCRIBIR_SI_NO  ; MENSAJE SOBRESCRIBIR EL ARCHIVO
    MOV DH, 6
    MOV DL, 0
    MOV BP, OFFSET SOBRESCRIBIR_SI_NO
    MOV AH, 13H
    INT 10H  
    
    MOV DL, 57                                  ; POSICION X DE LA PANTALLA
    MOV DH, 6                                   ; POSICION Y DE LA PANTALLA 
    MOV AH, 02H
    MOV BH, 0
    INT 10H 
    
SOLICITAR_LOOP:                                 ; CICLO PARA MOSTRAR CARACTERES EN PANTALLA
    MOV AH, 0H
    INT 16H                     
    CMP AL, 'N'                                 ; REALIZA COMPARACION SI ES N
    JE  SOLO_ABRIR        
    CMP AL, 'Y'                                 ; REALIZA COMPARACION SI ES Y
    JE  CREAR_ABRIR       
    CMP AL, 'n'                                 ; REALIZA COMPARACION SI ES N
    JE  SOLO_ABRIR       
    CMP AL, 'y'                                 ; REALIZA COMPARACION SI ES Y
    JE  CREAR_ABRIR       
    JMP SOLICITAR_LOOP      
;------------------------------------------------------------------------------------------------    
SOLO_ABRIR:
    MOV AH, 0EH                                 ; MOSTRAR EL CARACTER "N" EN LA PANTALLA
    INT 10H 
    LEA DX,NOMBRE_DEL_ARCHIVO                   ; SOLO ABRIMOS EL ARCHIVO SI EXISTE
    MOV AL,1
    MOV AH,3DH
    INT 21H
    MOV [HANDLE_LST],AX                         ; GUARDAMOS EL MANEJADOR                
    JMP LEER_ARCHIVO    
CREAR_ABRIR:
    MOV AH, 0EH                                 ; MOSTRAR EL CARACTER "Y" EN LA PANTALLA
    INT 10H                 
    LEA DX,NOMBRE_DEL_ARCHIVO                   ; CREAR ARCHIVO SI NO EXISTE SI EXISTE LO REEMPLAZA.
    MOV AH, 3CH                                 ; FUNCION PARA ABRIR UN ARCHIVO 
    MOV CX, 0            
    INT 21H              
    MOV [HANDLE_LST], AX                        ; GUARDAR EL MANEJADOR
;------------------------------------------------------------------------------------------------    
LEER_ARCHIVO:
    MOV TAM_LINEA_LEIDA, -1                     ; TAMANO DE LINEA LEIDA A -1
LOOP1:    
    LEA DI, LINEA_LEIDA                         ; APUNTA AL INICIO DE LA LINEA_LEIDA 
    CMP TAM_LINEA_LEIDA, -1                     ; COMPARAMOS SI LA LINEA NO TIENE CARACTERES
    JE OMITE                                    ; SI ES ASI NO NO CONVETIMOS_A_DIGITOS Y ESCRIBIMOS CHARS
    CALL CONVERTIR_NUM_A_CHARS                  ; SI CONTIENE DATOS REALIZAMOS CONVERTIR_A_DIGITOS
    CALL ESCRIBIR_LINEA                         ; Y ESCRIBIR_CARACTERES
    OMITE:                          
    CALL ESCRIBIR_NUMEROS                       ; ESCRIBIMOS EL CONTADOR DE CARACTERES
                  
    MOV TAM_LINEA_LEIDA,0                       ; RESTAURAMOS A 0 EL TAMANO DE LINEA
LOOP2: 
    MOV AH, 3FH                                 ; LEER DEL ARCHIVO
    MOV BX, HANDLE_ASM
    MOV DX, DI                                  ; LEER 1 BYTE AL BUFFER LINEA[DI]
    MOV CX, 1
    INT 21H
    
    JC CERRAR_ARCHIVO                           ; SI ERROR, CERRAR ARCHIVO Y SALIR
    CMP AX, 0
    JE CERRAR_ARCHIVO                           ; SI EOF, CERRAR ARCHIVO SALIR
        
    MOV AL, [DI]                                ; LEER EL CARACTER RECIBIDO
        
    CMP AL, 0DH                                 ; ES SALTO DE LINEA 
    JE LOOP2                                    ; SI LO ES IGNORARLO
            
    CMP AL, 0AH                                 ; ES SALTO DE LINEA 
    JE LOOP1                                    ; SI LO ES IGNORARLO
             
    INC TAM_LINEA_LEIDA
            
    INC DI                                      ; AVANZA AL SIGUIENTE BYTE DEL BUFFER
    INC CONT_DE_CHARS_LEIDOS                    ; AUMENTA CONTADOR DE CARACTERES VALIDOS
    JMP LOOP2
        
    CERRAR_ARCHIVO:                             ; CERRAMOS ARCHIVO
    MOV DI, 0
    MOV AH, 3EH
    MOV BX, HANDLE_ASM                          ; EL CUAL ES EL DE LECTURA DE CARACTERES
    INT 21H  
        
    MOV AH, 40H                                 ; ESCRIBIR EN ARCHIVO SALTO DE LINEA
    MOV CX, 2                                   ; NUMERO DE BYTES A ESCRIBIR 
    MOV BX, HANDLE_LST 
    LEA DX, SALTO_DE_LINEA                      ; DIRECCION DEL TEXTO SALTO DE LINEA
    INT 21H                     
             
    MOV DI, 0                                   ; CERRAMOS ARCHIVO
    MOV AH, 3EH
    MOV BX, HANDLE_LST                         
    INT 21H 
    JMP PROCESO_TERMINADO
;----------------------------------------------------------------------------------------------- 
ESCRIBIR_LINEA:
    MOV BX, HANDLE_LST  
    MOV AH, 40H                                 ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
    MOV CX, 1                                   ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
    LEA DX, ESPACIO_EN_BLANCO                   ; DIRECCION DEL TEXTO A ESCRIBIR
    INT 21H 
           
    MOV AH, 40H                                 ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
    MOV CX, TAM_LINEA_LEIDA                     ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
    LEA DX, LINEA_LEIDA                         ; DIRECCION DEL TEXTO A ESCRIBIR
    INT 21H                 
     
    MOV AH, 40H                                 ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
    MOV CX, 2                                   ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
    LEA DX, SALTO_DE_LINEA                      ; DIRECCION DEL TEXTO A ESCRIBIR
    INT 21H  
    RET 
;-----------------------------------------------------------------------------------------------    
CONVERTIR_NUM_A_CHARS:
    MOV AX, CONT_DE_CHARS_LEIDOS                ; AX = NUMERO
    MOV BX, 100                                 ; BX = 100 (PARA CENTENAS)
    ; CENTENAS
    XOR DX, DX
    DIV BX                                      ; AX / 100 -> AX = COCIENTE (CENTENAS), DX = RESTO
    ADD AL, '0'                                 ; CONVERTIR A ASCII
    MOV CHARS_NUMEROS[0], AL                    ; MOVEMOS A POSICION 0 EL CARACTER DE AL
                                   
    MOV AX, DX                                  ; AX = RESTO (LO QUE QUEDA POR DIVIDIR)
    MOV BX, 10                                  ; CONVERTIR A ASCII
       
    ; DECENAS
    XOR DX, DX
    DIV BX                                      ; AX / 10 -> AX = COCIENTE (DECENAS), DX = RESTO
    ADD AL, '0'                                 ; CONVERTIR A ASCII
    MOV CHARS_NUMEROS[1], AL                    ; MOVEMOS A POSICION 1 EL CARACTER DE AL
    ; UNIDADES
    ADD DL, '0'                                 ; CONVERTIR A ASCII
    MOV CHARS_NUMEROS[2], DL                    ; MOVEMOS A POSICION 0 EL CARACTER DE DL
    RET
;-----------------------------------------------------------------------------------------------    
ESCRIBIR_NUMEROS: 
    MOV BX, HANDLE_LST  
    MOV AH, 40H                                 ; FUNCION 40H DE DOS (ESCRIBIR EN ARCHIVO)
    MOV CX, 3                                   ; NUMERO DE BYTES A ESCRIBIR (LONGITUD DEL TEXTO)
    LEA DX, CHARS_NUMEROS                       ; DIRECCION DEL TEXTO A ESCRIBIR
    INT 21H 
    RET 
;-----------------------------------------------------------------------------------------------
PROCESO_TERMINADO:
    MOV AL, 1                   ; IMPRIMIMOS MENSAJE DE SUCCES
    MOV BH, 0
    MOV BL, 0BH   
    MOV CX, NOMBRE_DEL_ARCHIVO - FINALIZO_PROG  
    MOV DH, 10
    MOV DL, 12
    MOV BP, OFFSET FINALIZO_PROG
    MOV AH, 13H
    INT 10H   
;-----------------------------------------------------------------------------------------------
FIN_PROGRAMA:                                   ; FINALIZAR PROGRAMA
    MOV AH, 0     
    INT 20H 
      