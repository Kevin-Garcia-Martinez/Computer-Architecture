----------------------------------------------------------------------------------
-- Company: ESCOM (Escuela Superior de Cómputo)
-- Engineer: Kevin García Martínez
-- Create Date: 06.11.2020 11:08:42
-- Design Name: Computer Processing Unit
-- Module Name: memProg - PROGRAM
-- Project Name: Aritmetic Logic Unit - Adder and Subtractor Circuit
-- Device: Nexys4 DDR (Digilent) FPGA (Field Programmable Gate Array)
-- Device Model: XC7A100T -1CSG324C
-- Device Family: Artix-7
-- Speed: -1
-- Package: CSG324
-- Version: Program Memory 
----------------------------------------------------------------------------------
-- La memoria de programa que se implementará tendrá las siguientes características:
-- Un BUS de direcciones de 16 bits
-- Un BUS de datos de 25 bits
-- El tamaño del BUS de la memoria será igual a 2^(Número de bits del BUS de direcciones) 
-- Para este caso son 16 Bits = 2^16 = 65,536 localidades de memoria en donde cada una de 
-- estas localidades almacenará un dato de 25 bits (24 donwto 0) : 65,536 x 25 bits
-- No tiene señal Chip Select, lo que significa que el BUS de datos siempre estará 
-- disponible para lectura y el bus de direcciones simpre estará disponible para escritura.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Libreria para utilizar el '+' y la función CONV_INTEGER 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memProg is
-- Para fines prácticos pondremos el bus de direcciones de 8 bits
    Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
           D : out STD_LOGIC_VECTOR (24 downto 0) );  
end memProg;

architecture programa of memProg is
    -- INSTRUCCIONES DE CARGA Y ALMACENAMIENTO
    CONSTANT OPCODE_TIPO_R: STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000"; -- Código de operación de cualquier Instrucción Tipo R
    CONSTANT OPCODE_LI    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001"; -- Código de operación de la Instrucción LI
    CONSTANT OPCODE_LWI   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00010"; -- Código de operación de la Instrucción LWI
    CONSTANT OPCODE_SWI   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00011"; -- Código de operación de la Instrucción SWI
    CONSTANT OPCODE_SW    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00100"; -- Código de operación de la Instrucción SW
    -- INSTRUCCIONES ARITMÉTICAS
    CONSTANT OPCODE_ADDI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00101"; -- Código de operación de la Instrucción ADDI
    CONSTANT OPCODE_SUBI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00110"; -- Código de operación de la Instrucción SUBI
    -- INSTRUCCIONES LÓGICAS
    CONSTANT OPCODE_ANDI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00111"; -- Código de operación de la Instrucción ANDI
    CONSTANT OPCODE_ORI   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01000"; -- Código de operación de la Instrucción ORI
    CONSTANT OPCODE_XORI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01001"; -- Código de operación de la Instrucción XORI
    CONSTANT OPCODE_NANDI : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01010"; -- Código de operación de la Instrucción NANDI
    CONSTANT OPCODE_NORI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01011"; -- Código de operación de la Instrucción NORI
    CONSTANT OPCODE_XNORI : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01100"; -- Código de operación de la Instrucción XNORI
    -- INSTRUCCIONES DE SALTOS CONDICIONALES E INCONDICIONALES
    CONSTANT OPCODE_BEQI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01101"; -- Código de operación de la Instrucción BEQI
    CONSTANT OPCODE_BNEI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01110"; -- Código de operación de la Instrucción BNEI
    CONSTANT OPCODE_BLTI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01111"; -- Código de operación de la Instrucción BLTI
    CONSTANT OPCODE_BLETI : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10000"; -- Código de operación de la Instrucción BLETI
    CONSTANT OPCODE_BGTI  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10001"; -- Código de operación de la Instrucción BGTI
    CONSTANT OPCODE_BGETI : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10010"; -- Código de operación de la Instrucción BGETI
    CONSTANT OPCODE_B     : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10011"; -- Código de operación de la Instrucción BRANCH
    -- INSTRUCCIONES DE MANEJO DE SUBRUTINAS
    CONSTANT OPCODE_CALL  : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10100"; -- Código de operación de la Instrucción CALL
    CONSTANT OPCODE_RET   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10101"; -- Código de operación de la Instrucción RET
    -- OTRAS INSTRUCCIONES
    CONSTANT OPCODE_NOP   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10110"; -- Código de operación de la Instrucción NOP
    CONSTANT OPCODE_LW    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10111"; -- Código de operación de la Instrucción LW

    -- El Código de Función (4 bits) sirve para diferenciar las Instrucciones de Tipo R unas de otras, ya que 
    -- como todas tienen el mismo código de operación "00000"
    
    -- CÓDIGO DE FUNCIONES DE INSTRUCCIONES ARTIMÉTICAS
    CONSTANT FUNCODE_ADD  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT FUNCODE_SUB  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    -- CÓDIGO DE FUNCIONES DE INSTRUCCIONES LÓGICAS 
    CONSTANT FUNCODE_AND  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT FUNCODE_OR   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT FUNCODE_XOR  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT FUNCODE_NAND : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT FUNCODE_NOR  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT FUNCODE_XNOR : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
    CONSTANT FUNCODE_NOT  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
    -- CÓDIGO DE FUNCIONES DE INSTRUCCIONES DE CORRIMIENTO
    CONSTANT FUNCODE_SLL  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    CONSTANT FUNCODE_SRL  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
    -- REGISTROS QUE SERÁN OPERANDOS EN LAS INSTRUCCIONES
    CONSTANT R0  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT R1  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT R2  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT R3  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT R4  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT R5  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT R6  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT R7  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
    CONSTANT R8  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
    CONSTANT R9  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    CONSTANT R10 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
    CONSTANT R11 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
    CONSTANT R12 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
    CONSTANT R13 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
    CONSTANT R14 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
    CONSTANT R15 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    -- Constante para declarar bits que estén sin uso en las Instrucciones SU: Sin USO
    CONSTANT SU: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"; -- XXXX
    -- Aquí colcamos el tipo de dato TYPE, entre 'architecture' y 'begin'
    TYPE MEMORIA IS ARRAY ( 0 TO 2**16-1 ) OF STD_LOGIC_VECTOR(D'RANGE);    
    -- Definimos nuestra memoria ROM
    CONSTANT ROM : MEMORIA := (
        -- Aquí colocaremos los programas que diseñemos en lenguaje Ensamblador, es decir, colocaremos todo el Formato de Instrucción de 25 bits
        -- Código de Operación (5 bits) Registro Operando (4 bits) Número que se cargará en el Registro Operando (16 bits) 
        -- Con el '&' podemos concatenar bits de distintas constantes que se hayan declarado e incluso valores hexadecimales. 
        -- INSTRUCCIÓN                       DIRECCION MEMORIA   SIGNIFICADO
        OPCODE_LI&R0&X"0001",                  --   0             LI R0, #1
        OPCODE_LI&R1&X"0007",                  --   1             LI R1, #7
        OPCODE_TIPO_R&R1&R1&R0&SU&FUNCODE_ADD, --   2             ADD R1, R1, R0
        OPCODE_SWI&R1&X"0005",                 --   3             SW1 R1, #5
        -- El código hexadecimal hare referencia a la dirección de memoria a la que quiero saltar
        OPCODE_B&SU&X"0002",                   --   4:            B CICLO
        -- El primer OTHERS recorrerá todas las direcciones desde la 4 hasta la dirección 65,535, 
        -- y el 'OTHERS' de dentro se encargará de recorrer el bus de datos de 25 bits y lo 
        -- llenará solamente con ceros, así ya no tenemos que ponder 25 ceros para inicializarlo.
        OTHERS => ( OTHERS =>'0' )
    );

    begin
        -- Colocaremos la sentencia que se encargará de leer las instrucciones de nuestro programa
        -- escrito en lenguaje Ensamblador que están dentro de la Memoria de Programa. 
        -- El índice para leer datos/instrucciones de la Memoria de Programa nos lo indica el 
        -- BUS de direcciones que declaramos como 'A' -> Address, y este debe ser un tipo de dato
        -- entero, es por eso que utilizamos la función CONV_INTEGER(A) para convertir una señal
        -- de tipo STD_LOGIC a un valor entero 
        D <= ROM( CONV_INTEGER(A) );

end programa;

