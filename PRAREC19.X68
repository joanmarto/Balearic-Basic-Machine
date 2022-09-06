*-----------------------------------------------------------
* Title      : PRAREC19
* Written by : Joan Martorell y Joan Mesquida
* Date       : 20/06/2019
* Description: Emulador de la BBMe
*-----------------------------------------------------------
    ORG $1000
EPROG: DC.W $080E,$0020,$500B,$090F,$0029,$500B,$C803
       DC.W $D8C3,$D7F9,$500B,$6007,$001D,$1910,$8000
       DC.W $0004,$0003,$0000
EIR:   DC.W 0 ;eregistro de instruccion
EPC:   DC.W 0 ;econtador de programa
ER0:   DC.W 0 ;eregistro R0
ER1:   DC.W 0 ;eregistro R1
ER2:   DC.W 0 ;eregistro R2
ER3:   DC.W 0 ;eregistro R3
EB4:   DC.W 0 ;eregistro B4
EB5:   DC.W 0 ;eregistro B5
ESR:   DC.W 0 ;eregistro de estado (00000000 00000ZNC)

START:
    CLR.W EPC
    CLR.W ESR
FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	    
    MOVE.W EPC,D0
    MULS.W #2,D0
    LEA EPROG,A0

    ADD.W D0,A0      ;Siguiente einstrucción = EPROG + 2*EPC
    MOVE.W (A0),D0
    MOVE.W D0,EIR
    ADDQ.W #1,EPC    ;Incremento del EPC

        
    ;--- FFETCH: FIN FETCH
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1
        
BRADECOD: 
    MOVE.W #0,-(A7)
    MOVE.W D0,-(A7)   ;Carga el EIR en la pila
    MOVE.W #1,D2      
    JSR DECOD
    MOVE.W (A7)+,D1
    CLR.W D1
    MOVE.W (A7)+,D1   ;D1 = Id einstrucción
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ETRA
    JMP ELD
    JMP ELDI
    JMP EST
    JMP ESTI
    JMP EJMN
    JMP EJMZ
    JMP EJMI
    JMP EHLT
    JMP ENOR
    JMP ESET
    JMP EADQ
    JMP EADD
    JMP ESUB
    JMP ETST
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
ETRA:
    MOVE.W EIR,D4
    MOVE.W #$0078,D6
    AND.W D4,D6    ;D6 = aaa
    LSR.L #3,D6
    MULU.W #2,D6
    MOVE.W #$0007,D7
    AND.W D4,D7    ;D7 = bbb
    MULU.W #2,D7
    LEA ER0,A4   
    LEA ER0,A5
    ADD.W D6,A4    ;A4 = Ra
    ADD.W D7,A5    ;A5 = Rb
    CLR.W D7
    CLR.W D4
    MOVE.W (A4),D4
    MOVE.W D4,(A5)
    MOVE.W SR,D7
    JSR NZ
    CLR.W D6
    MOVE.W #0,A4
    MOVE.W #0,A5
    JMP RETURN
ELD:
    MOVE.W EIR,D4
    MOVE.W #$00FF,D6
    AND.W D4,D6    ;D6 = M
    MULU.W #2,D6
    LEA EPROG,A5
    ADD.W D6,A5
    BTST.L #8,D4
    BEQ JLDO
    MOVE.W (A5),EB5 ;B5 = [M]
    MOVE.W SR,D7
    JSR NZ
    JMP FLD
  JLDO:
    MOVE.W (A5),EB4 ;B4 = [M]
    MOVE.W SR,D7
    JSR NZ
  FLD:
    MOVE.W #0,A5
    CLR.W D6
    JMP RETURN
ELDI:
    MOVE.W EB5,A5
    MOVE.W (A5),D4  ;D4 = [[B5]]
    MOVE.W EB4,A4   ;A4 = B4
    MOVE.W D4,A4
    MOVE.W SR,D7
    JSR NZ
    MOVE.W A4,EB4   ;B4 = [[B5]]
    MOVE.W #0,A4
    MOVE.W #0,A5
    JMP RETURN
EST:
    MOVE.W EIR,D4
    MOVE.W #$00FF,D6
    AND.W D4,D6    ;D6 = M
    MULU.W #2,D6
    LEA EPROG,A5
    ADD.W D6,A5
    BTST.L #8,D4
    BEQ JSTO
    CLR.W D4
    MOVE.W EB5,D4  ;D4 = B5
    MOVE.W D4,(A5)
    JMP FST
  JSTO:
    CLR.W D4
    MOVE.W EB4,D4  ;D4 = B4
    MOVE.W D4,(A5)
  FST:
    CLR.W D4
    CLR.W D6
    MOVE.W #0,A5
    JMP RETURN
ESTI:
    MOVE.W EB4,D4  ;D4 = B4
    MOVE.W EB5,A5  ;A5 = B5
    MOVE.W D4,(A5)
    CLR.W D4
    MOVE.W A5,EB5  ;[B5] = B4
    MOVE.W #0,A5
    JMP RETURN
EJMN:
    MOVE.W #$00FF,D4
    MOVE.W EIR,D6
    AND.W D4,D6    ;D6 = M
    CLR.W D4
    MOVE.W ESR,D4
    BTST.L #1,D4
    BEQ N0         ;Si N = 1, no salta
    MOVE.W D6,EPC
    N0:
    CLR.W D4
    CLR.W D6
    JMP RETURN
EJMZ:
    MOVE.W #$00FF,D4
    MOVE.W EIR,D6
    AND.W D4,D6    ;D6 = M
    CLR.W D4
    MOVE.W ESR,D4
    BTST.L #2,D4
    BEQ Z0         ;Si Z = 1, no salta
    MOVE.W D6,EPC
    Z0:
    CLR.W D4
    CLR.W D6
    JMP RETURN
EJMI:
    MOVE.W #$00FF,D4
    MOVE.W EIR,D6
    AND.W D4,D6    ;D6 = M
    MOVE.W D6,EPC
    CLR.W D4
    CLR.W D6
    JMP RETURN
EHLT:
    MOVE.B #9,D0
    TRAP #15
ENOR:
    MOVE.W EIR,D4
    MOVE.W #$0038,D7
    AND.W D4,D7    ;D7 = aaa
    LSR.L #3,D7
    MULS.W #2,D7
    MOVE.W #0007,D6
    AND.W D4,D6    ;D6 = bbb
    MULS.W #2,D6
    MOVE.W #$01C0,D5
    AND.W D4,D5    ;D5 = ccc
    LSR.L #6,D5
    MULS.W #2,D5
    LEA ER0,A5
    LEA ER0,A6
    LEA ER0,A4
    ADD.W D7,A5    ;A5 = Ra
    ADD.W D6,A6    ;A6 = Rb
    ADD.W D5,A4    ;A4 = Rc
    CLR.W D7
    CLR.W D6
    CLR.W D4
    CLR.W D5
    MOVE.W (A5),D4
    MOVE.W (A6),D6
    OR.W D4,D6
    NOT.W D6
    MOVE.W SR,D7
    MOVE.W D6,A4  ;Rc = Ra NOR Rb
    JSR NZ
    MOVE.W #0,A5
    MOVE.W #0,A6
    MOVE.W #0,A4
    CLR.W D6
    JMP RETURN
ESET:
    MOVE.W EIR,D4
    MOVE.W #$07F8,D6
    AND.W D4,D6
    LSR.L #3,D6    
    EXT.W D6       ;D6 = k
    MOVE.W #$0007,D7
    AND.W D4,D7    ;D7 = bbb
    MULS.W #2,D7
    LEA ER0,A5
    ADD.W D7,A5    ;A5 = Rb
    CLR.W D7
    MOVE.W D6,(A5) ;Rb = k
    MOVE.W SR,D7
    JSR NZ
    MOVE.W #0,A5
    CLR.W D6
    JMP RETURN
EADQ:
    MOVE.W EIR,D4
    MOVE.W #$07F8,D7
    AND.W D4,D7
    LSR.L #3,D7 
    EXT.W D7       ;D7 = k
    MOVE.W #$0007,D6
    AND.W D4,D6    ;D6 = bbb
    MULS.W #2,D6
    LEA ER0,A5
    ADD.W D6,A5    ;A5 = Rb
    CLR.W D6
    ADD.W D7,(A5)  ;Rb = Rb + k
    MOVE.W SR,D6
    JSR CNZ
    MOVE.W #0,A5
    CLR.W D7
    JMP RETURN
EADD:
    MOVE.W EIR,D4
    MOVE.W #$0038,D6
    AND.W D4,D6    ;D6 = aaa
    LSR.L #3,D6
    MULS.W #2,D6
    MOVE.W #$007,D7
    AND.W D4,D7    ;D7 = bbb
    MULS.W #2,D7
    MOVE.W #$01C0,D5
    AND.W D4,D5    ;D5 = ccc
    LSR.L #6,D5
    MULS.W #2,D5
    LEA ER0,A5
    LEA ER0,A6
    LEA ER0,A4
    ADD.W D6,A5    ;A5 = Ra
    ADD.W D7,A6    ;A6 = Rb
    ADD.W D5,A4    ;A4 = Rc
    CLR.W D6
    CLR.W D4
    MOVE.W (A5),D4
    MOVE.W (A6),D7
    ADD.W D4,D7    ;Ra + Rb
    MOVE.W SR,D6
    MOVE.W D7,(A4) ;Rc = Ra + Rb
    JSR CNZ
    CLR.W D7
    MOVE.W #0,A5
    MOVE.W #0,A6
    MOVE.W #0,A4
    JMP RETURN
ESUB:
    MOVE.W EIR,D4
    MOVE.W #$0038,D6
    AND.W D4,D6    ;D6 = aaa
    LSR.L #3,D6
    MULS.W #2,D6
    MOVE.W #$007,D7
    AND.W D4,D7    ;D7 = bbb
    MULS.W #2,D7
    MOVE.W #$01C0,D5
    AND.W D4,D5    ;D5 = ccc
    LSR.L #6,D5
    MULS.W #2,D5
    LEA ER0,A5
    LEA ER0,A6
    LEA ER0,A4
    ADD.W D6,A5    ;A5 = Ra
    ADD.W D7,A6    ;A6 = Rb
    ADD.W D5,A4    ;A4 = Rc
    CLR.W D6
    CLR.W D7
    CLR.W D5
    MOVE.W (A6),D7
    NOT.W D7
    ADDQ.W #1,D7
    ADD.W (A5),D7
    MOVE.W SR,D6
    MOVE.W D7,(A4)
    JSR CNZ
    CLR.W D7
    MOVE.W #0,A5
    MOVE.W #0,A6
    MOVE.W #0,A4
    JMP RETURN
ETST:
    MOVE.W EIR,D4
    MOVE.W #$0038,D6
    AND.W D4,D6    ;D6 = aaa
    LSR.L #3,D6
    MULS.W #2,D6
    MOVE.W #$007,D7
    AND.W D4,D7    ;D7 = bbb
    MULS.W #2,D7
    LEA ER0,A5
    LEA ER0,A6
    ADD.W D6,A5    ;A5 = Ra
    ADD.W D7,A6    ;A6 = Rb
    CLR.W D6
    CLR.W D7
    CLR.W D4
    MOVE.W (A5),D4
    MOVE.W (A6),D7
    CMP.W D4,D7
    MOVE.W SR,D6
    JSR CNZ
    CLR.W D7
    MOVE.W #0,A5
    MOVE.W #0,A6
    JMP RETURN
    
RETURN:
    JMP FETCH


    ;--- FEXEC: FIN EJECUCION

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

CNZ:               ;Esta subrutina actualiza los flags C, N y Z 
    CLR.W D4
    MOVE.W ESR,D4
    BSET.L #0,D4   ;Ponemos a 1 los flags del ESR
    BSET.L #1,D4
    BSET.L #2,D4
  
    BTST.L #0,D6   ;Comprobamos si se corresponde con el flag correspondiente
    BNE C          ;del 68K. En caso contrario ponemos el bit del ESR a 0
    BCLR.L #0,D4
    C:
    BTST.L #3,D6
    BNE N
    BCLR.L #1,D4
    N:
    BTST.L #2,D6
    BNE Z
    BCLR.L #2,D4
    Z:
    MOVE.W D4,ESR
    CLR.W D4
    CLR.W D6
    RTS
    
NZ:                ;Esta subrutina actualiza los flags N y Z
    CLR.W D4       ;El modo de funcionamiento es el mismo que la anterior
    MOVE.W ESR,D4  ;subrutina, a diferencia de que esta no actualiza el flag C
    BSET.L #1,D4
    BSET.L #2,D4
    
    BTST.L #3,D7
    BNE FLAGN
    BCLR.L #1,D4
    FLAGN:
    BTST.L #2,D7
    BNE FLAGZ
    BCLR.L #2,D4
    FLAGZ:
    MOVE.W D4,ESR
    CLR.W D4
    CLR.W D7
    RTS
        
        
    ;--- FSUBR: FIN SUBRUTINAS

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
    MOVE.L D2,-(A7)
    MOVE.W 8(A7),D2
    
    BTST.L #15,D2
    BEQ OXXXX
    BTST.L #14,D2
    BNE IIXXX
    MOVE.W #8,10(A7) ;einstrucción HLT
    JMP FDECOD
IIXXX:
    BTST.L #13,D2
    BEQ IIOXX
    BTST.L #11,D2
    BEQ IIIOO
    MOVE.W #14,10(A7) ;einstrucción TST
    JMP FDECOD
IIIOO:
    MOVE.W #13,10(A7) ;einstrucción SUB
    JMP FDECOD
IIOXX:
    BTST.L #12,D2
    BEQ IIOOX
    BTST.L #11,D2
    BEQ IIOIO
    MOVE.W #12,10(A7) ;einstrucción ADD
    JMP FDECOD
IIOIO:
    MOVE.W #11,10(A7) ;einstrucción ADQ
    JMP FDECOD
IIOOX:
    BTST.L #11,D2
    BEQ IIOOO
    MOVE.W #10,10(A7) ;einstrucción SET
    JMP FDECOD
IIOOO:
    MOVE.W #9,10(A7) ;einstrucción NOR
    JMP FDECOD
OXXXX:
    BTST.L #14,D2
    BEQ OOXXX
    BTST.L #13,D2
    BEQ OIOXX
    MOVE.W #7,10(A7) ;einstrucción JMI
    JMP FDECOD
OIOXX:
    BTST.L #12,D2
    BEQ OIOOX
    MOVE.W #6,10(A7) ;einstrucción JMZ
    JMP FDECOD
OIOOX:
    MOVE.W #5,10(A7) ;einstrucción JMN
    JMP FDECOD
OOXXX:
    BTST.L #13,D2
    BEQ OOOXX
    MOVE.W #4,10(A7) ;einstrucción STI
    JMP FDECOD
OOOXX:
    BTST.L #12,D2
    BEQ OOOOX
    BTST.L #11,D2
    BEQ OOOIO
    MOVE.W #3,10(A7) ;einstrucción ST
    JMP FDECOD
OOOIO:
    MOVE.W #2,10(A7) ;einstrucción LDI
    JMP FDECOD
OOOOX:
    BTST.L #11,D2
    BEQ OOOOO
    MOVE.W #1,10(A7) ;einstrucción LD
    JMP FDECOD
OOOOO:
    MOVE.W #0,10(A7) ;einstrucción TRA
    
FDECOD:
    MOVE.L (A7)+,D2
    RTS
  

    ;--- FDECOD: FIN DECOD
    END    START







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
