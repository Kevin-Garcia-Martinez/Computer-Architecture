----------------------------------------------------------------------------------
-- Company: ESCOM (Escuela Superior de Cómputo)
-- Engineer: Kevin García Martínez
-- Create Date: 06.11.2020 11:08:42
-- Design Name: Computer Processing Unit
-- Module Name: memData - PROGRAM
-- Project Name: Aritmetic Logic Unit - Adder and Subtractor Circuit
-- Device: Nexys4 DDR (Digilent) FPGA (Field Programmable Gate Array)
-- Device Model: XC7A100T -1CSG324C
-- Device Family: Artix-7
-- Speed: -1
-- Package: CSG324
-- Version: Data Memory - RAM 
----------------------------------------------------------------------------------
-- La memoria de datos (Memoria RAM) que se implementará tendrá las siguientes características:
-- Bus de direcciones de 16 bits = 2^16 = 64K localidades de memoria
-- Bus de datos de entrada y bus de datos de salida ambos de 16 bits
-- WD: la bandera 'Write Data' se asegura de que se realice la escritura de la instrucción en 
-- la memoria de datos en la dirección de memoria especificada en el bus de direcciones 'ADR'
-- Si WD = '1' se realiza la escritura en la memoria.
-- La escritura en la memoria RAM es de manera síncrona, ya que depende del flanco de subida 
-- del reloj así como del valor de la bandera WD.
-- La lectura en la memoria RAM es de manera asíncrona, es decir, no depende de la señal de 
-- reloj ni de la bandera wd, lo que significa que el valor que es leído de la memoria RAM
-- estará inmediatemente a la salida en el bus de datos de salida.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Libreria para utilizar el operador '+' y la función CONV_INTEGER 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memData is
    GENERIC( NADDR : INTEGER := 16 ;
             NDATA : INTEGER := 16 );

    Port ( ADDR   : in  STD_LOGIC_VECTOR (NADDR-1 downto 0);
           -- Señal de reloj y write-data
           WD, CLK: in STD_LOGIC;
           -- Bus de datos de entrada
           DIN  : in  STD_LOGIC_VECTOR (NDATA-1 downto 0); 
           -- Bus de datos de salida
           DOUT : out STD_LOGIC_VECTOR (NDATA-1 downto 0) );
end memData;

architecture programa of memData is
    -- La memoria RAM a implementar tiene una organización de 2^NADDR x 2^NDATA = 65,536 x 65,536
    -- 65, 536 localidades de memoria donde cada una almacenará un dato de 65,536 bits
    TYPE MEMORIA IS ARRAY (0 TO 2**NADDR-1) OF STD_LOGIC_VECTOR(DIN'RANGE);
    -- Se pueden realizar tanto escritura como lectura en la memoria RAM, por lo que no puede ser 
    -- Una declara como una constante 'CONSTANT', sino como una señal 'SIGNAL'
    SIGNAL M_DATOS : MEMORIA;

    begin 
    -- Lista sensible del proceso: Señal de reloj 'CLK' para la operación de escritura y señal de CLEAR 'CLR'
    -- Cuando tenemos un circuito secuencial que utiliza una señal de reloj 'clk', la lista sensible del proceso
    -- solamente tendrá como señales de entrada (únicamente estas):
    -- Señal de Reloj 'clk' y señales de control del reloj, como CLEAR, etc.
    PMEMDAT : process( CLK )
    -- Cuando diseñamos una memoria RAM con:
    -- Escritura síncrona sin CLR y Lectura asíncorna 
    -- Cuando utilizamos esta forma, la herramienta (Vivado) detecta que queremos utilizar un recurso de 
    -- dedicado de la FPGA, en este caso, queremos utilizar la memoria distribuida que tienen las LUTS.
    begin
        -- PROBLEMA DE DECLARAR LA SEÑAL CLEAR EN EL DISEÑO DE LA MEMORIA DE DATOS
        -- En el momento que se declara la señal del reloj CLEAR 'CLR', el único dispositivo del 
        -- slice dentro de la FPGA que ocupa un RESET es el FLIP FLOP. Por lo tanto la herramienta 
        -- detectará que queremos utilizar FLIP FLOPS ya que las LUTS no utilizan RESET CLR, entonces 
        -- la FPGA se llenará solamente de FLIP FLOPS
        -- Por lo tanto, concluimos que la memoria RAM distribuida no utiliza la señal CLEAR 'CLR'
        -- IF ( CLR = '1' ) THEN
        -- Inicializamos la memoria de datos si la señal CLEAR del reloj esta activada
        --    M_DATOS <= (OTHERS => (OTHERS=>'0'));

        -- Si se presento un evento en la señal CLK (cambio de valor) y además el valor resultante 
        -- de ese evento fue un '1', significa que se presento un flanco de subida de la señal 'clk'        
        IF ( CLK'EVENT AND CLK='1') THEN
            -- IMPORTANTE: Todas las operaciones/instrucciones que se coloquen cuando preguntamos 
            -- por el flanco de subida del reloj son sínncronas
            IF ( WD = '1' ) THEN -- Escritura síncrona
                -- Si esta activada la señal de escritura de la memoria RAM WD = '1'
                -- Colocamos el valor que tenga el bus de datos de entrada 'DIN' dentro dentro de la 
                -- memoria RAM en la dirección de memoria especificada en el bus de direcciones 'ADDR'
                M_DATOS( CONV_INTEGER(ADDR) ) <= DIN;
            END IF;  
        END IF;

    end process PMEMDAT;

    -- La lectura se realiza de manera asíncrona, es decir, no depende de la señal del reloj
    -- Realizamos la lectura de la memoria RAM en la dirección de memoria que se especifico 
    -- en el bus de direcciones 'ADDR' y el dato leído lo colocamos en el bus de datos de 
    -- salida 'DOUT'
    DOUT <= M_DATOS( CONV_INTEGER(ADDR) );
    -- La forma de en la que programamos el dispositivo/diseño es la manera de indicarle al
    -- programador (Ambiente de Desarrollo de Vivado) que me asigne un recurso dedicado de la FPGA

end programa;
