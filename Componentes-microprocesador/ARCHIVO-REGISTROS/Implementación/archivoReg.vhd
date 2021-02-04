----------------------------------------------------------------------------------
-- Company: ESCOM (Escuela Superior de Cómputo)
-- Engineer: Kevin García Martínez
-- Create Date: 13.01.2021 10:40:50
-- Design Name: Register File
-- Module Name: Archivo de Registros - PROGRAM
-- Project Name: Register File Implementation 
-- Device: Nexys4 DDR (Digilent) FPGA (Field Programmable Gate Array)
-- Device Model: XC7A100T -1CSG324C
-- Device Family: Artix-7
-- Speed: -1
-- Package: CSG324
-- Version: Register File 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Tenemos 3 buses en nuestro archivo de registros, ambos de 16 bits, los cuales son:
-- Un registro para escribir WRITE_DATA
-- Dos registros para leer (READ DATA 1 y READ DATA 2)
-- Por lo tanto, estamos implementando una Memoria RAM Multipuerto: 3 Puertos. 

entity REGISTROS is
    -- Constantes de 4 y 16 bits respectivamente    
    GENERIC( NADDR : INTEGER := 4 ;
             NDATA : INTEGER := 16 );
    Port ( 
           -- Señal WRITE_REGISTER: Selecciona uno de los 16 registros para almacenar un dato dentro de este. 
           WRITE_REGISTER  : in STD_LOGIC_VECTOR (NADDR-1 downto 0); 
           -- Señal READ_REGISTER1: Selecciona uno de los 16 registros para leer el dato almacenado en este.
           READ_REGISTER1  : in STD_LOGIC_VECTOR (NADDR-1 downto 0);
           -- Señal READ_REGISTER2: Selecciona uno de los 16 registros para leer el dato almacenado en este.                     
           READ_REGISTER2  : in STD_LOGIC_VECTOR (NADDR-1 downto 0); 
           -- El registro de corrimiento SHAMT contiene el número de corrimientos que se aplicarán a un dato.
           -- Es decir, el número de bits a recorrer a la izquierda o a la derecha. 
           SHAMT           : in STD_LOGIC_VECTOR (NADDR-1 DOWNTO 0);
           -- Señales de control del Archivo de Registros.
           WR, CLK         : in STD_LOGIC;
           SHE, DIR        : in STD_LOGIC;
           -- El Archivo de Registros se programa como una MEMORIA RAM MULTIPUERTO, para este caso tenemos 3 puertos:
           WRITE_DATA  : in    STD_LOGIC_VECTOR (NDATA-1 downto 0);
           -- La señal READ_DATA1 la declaramos como inout porque esta señal es entrada del bloque 'BARREL SHIFTER'
           -- Y es salida porque tiene almacenada el valor leído del registro específicado en la señal READ_REGISTER1. 
           READ_DATA1  : inout STD_LOGIC_VECTOR (NDATA-1 DOWNTO 0);
           -- La señal READ_DATA2 tiene almacenada el valor leído del registro específicado en la señal READ_REGISTER2.
           READ_DATA2  : out   STD_LOGIC_VECTOR (NDATA-1 DOWNTO 0)
          );

end REGISTROS;

architecture ARCHIVO of REGISTROS is
    
    -- El Archivo de Registros que prograremos tiene 16 registros en donde cada uno almacenará datos de hasta 16 bits.
    TYPE MEMORIA IS ARRAY ( (2**NADDR)-1 DOWNTO 0) OF STD_LOGIC_VECTOR(WRITE_DATA'RANGE);
    -- 16x16: 16 REGISTROS CON UN BUS DE 16 BITS PARA CADA REGISTRO
    SIGNAL REGISTERS: MEMORIA;
    -- La señal DATA_SHIFT es la salida del bloque 'BARREL SHIFTER' 
    SIGNAL DATA_SHIFT: STD_LOGIC_VECTOR( WRITE_DATA'RANGE ); 
    -- La señal DATA será la salida del multiplexor que recibe como entrada la señal WRITE_DATA y la señal DATA_SHIFT
    -- El selector de este multiplexor será la señal SHE.
    SIGNAL DATA      : STD_LOGIC_VECTOR( WRITE_DATA'RANGE ); 

    begin 

    -- Programación del bloque 'BARREL SHIFTER'
    -- La lista sensible de 'BARREL SHIFTER' la conformaran las señales de entrada de este bloque, las cuales son
    -- READ_DATA1: Esta señal se retroalimenta a este bloque una vez que lee el dato del registro que se le especificó.
    -- SHAMT: Esta señal indica el número de corrimientos que se aplicarán al dato almacenado en READ_DATA1.
    -- DIR: Esta señal es la encarga de indicar la dirección en la que se aplicará el corrimiento (Izquierda/Derecha).
    BARREL: PROCESS( READ_DATA1, SHAMT, DIR)
        begin
            -- Para la programación del bloque 'BARREL SHIFTER' utilizaremos instrucciones de alto nivel de VHDL
            -- Las cuales son: SLL desplazamiento lógico a la iquierda, SRL desplazamiento lógico a la derecha
            -- La operación de corrimiento recibe:
            -- Un primer argumento de tipo: BITVECTOR y el número de corrimientos como tipo INTEGER 
            -- BITVECTOR <= TIPO-BITVECTOR SRL TIPO-INTEGER
            IF( DIR = '0' ) THEN 
                -- DIR 0 = CORRIMIENTO A LA DERECHA
                DATA_SHIFT <= TO_STDLOGICVECTOR( TO_BITVECTOR(READ_DATA1) SRL CONV_INTEGER(SHAMT) );
            ELSE 
                -- DIR 1 = CORRIMIENTO A LA IZQUIERDA
                DATA_SHIFT <= TO_STDLOGICVECTOR( TO_BITVECTOR(READ_DATA1) SLL CONV_INTEGER(SHAMT) ); 
            END IF;
        end process BARREL;

    -- La salida del multiplexor 'DATA' que tiene como entradas la señal WRITE_DATA Y DATA_SHIFT 
    -- dependerá del valor de la señal SHE.
    -- Cuando SHE = '0', la salida del multiplexor 'DATA' será igual al dato que tenga almacenado el BUS WRITE_DATA
    -- Cuando SHE = '1', la salida del multiplexor 'DATA' será igual al dato que devuelva el bloque BARREL_SHIFTER 'DATA_SHIFT'
    DATA <= WRITE_DATA WHEN ( SHE = '0' ) ELSE DATA_SHIFT;

    PESCRITURA : process( CLK )
    -- El roceso de escritura se realiza de manera síncrona (depende completamente de la señal de reloj CLK)
    begin       
        IF ( RISING_EDGE(CLK) ) THEN
        -- Cuando la señal WR sea uno, se realizará la escritura en el registro específicado en WRITE_REGISTER   
            IF ( WR = '1' ) THEN
                -- El valor que se escribirá en el registro es la salida del multiplexor que tiene como entrada las
                -- señales WRITE_DATA y DATA_SHIFT, a la salida del multiplexor la declaramos como 'DATA'
                REGISTERS( CONV_INTEGER(WRITE_REGISTER) ) <= DATA;
            END IF;  
        END IF;
    end process PESCRITURA;
    -- El proceso de lectura se realiza de manera asíncrona, al no depender de la señal de reloj, este se realiza
    -- de manera inmediata, el registro del cual se va a leer el dato viene especificado en las señales:
    -- READ_REGISTER1 y READ_REGISTER2, respectivamente para READ_DATA1 y READ_DATA2
    READ_DATA1 <= REGISTERS( CONV_INTEGER(READ_REGISTER1) );
    READ_DATA2 <= REGISTERS( CONV_INTEGER(READ_REGISTER2) );

end ARCHIVO;