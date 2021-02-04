library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Este pquete nos permitira utilizar el '
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- DOS ESQUEMAS PARA DISEÑAR LA PILA DEL PROCESADOR:

-- UNA PILA EN HARDWARE 
-- UNA PILA EN MEMORIA (RAM)
-- EN TODO PROCESADOR EXISTE AL MENOS UN CONTADOR DE PROGRAMA
-- CUANDO SE DISEÑA UNA PILA LO QUE SE HACE ES IMPLEMENTAR VARIOS CONTADORES DE PROGRAMA
-- uNA PILA EN HARDWARE DE 8 NIVELES SIGNIFICA QUE TENEMOS 8 CONTADORES DE PROGRAMA IMPLEMENTADOS. 

-- DISEÑO DE RAM DISTRIBUIDA. 
-- LA OTRA FORMA QUE PODEMOS HACER ES TENER TODOS LOS CONTADORES DE PROGRAMA EN UNA RAM DISTRIBUIDA. 
-- Y AL FINAL SOLAMENTE TENEMOS UN SOLO CONTADOR DE PROGRAMA


entity PILA is
    -- Constantes de 4 y 16 bits respectivamente    
    GENERIC( NADDR : INTEGER := 4 ;
             NDATA : INTEGER := 16 );
    Port ( 
           -- Señal de entrada del contador de programa
           D: in  STD_LOGIC_VECTOR (NDATA-1 DOWNTO 0);
           -- Señal de salida del contador de programa
           Q: inout STD_LOGIC_VECTOR (NDATA-1 DOWNTO 0);
           -- Señales de Control del Contador de Programa
           WPC, CLK, CLR : in STD_LOGIC );
           -- WPC es una señal de control que me permite cargar el valor que esta en el BUS de entrada D 
end PILA;

-- Cuando una señal esta del lado izquiero y derecho de la sentencia de VHDL, significa que esta se leerá y se escribirá
-- por lo tanto tiene que ser INOUT
architecture PILA of PROGRAMA is
BEGIN
    -- WPC no depende el if del ciclo del reloj, por lo tanto es una señal asíncrona
    -- por lo tanto no se coloca en la lista sensible del proceso. 
    PC: PROCESS( CLK, CLR )
    begin
        -- Al tener una señal de CLR este hará uso de los FLIPFLOPS de la FPGA
        -- Si CLR = '1', el bus de salida del contador de programa 'Q' lo inicializamos con ceros.
        IF( CLR = '1' ) THEN
            Q <= (OTHERS => '0');
        -- Preguntamos por el flanco de subida de la señal de reloj
        -- TODA ESTA PARTE DONDE PREGUNTAMOS POR EL FLANCO DE SUBIDA DEL RELOJ SE CONOCE COMO
        --  LA SECCIÓN SÍNCRONA DEL PROGRAMA QUE SE VA A EJECUTAR
        ELSIF( RISING_EDGE(CLK) ) THEN -- ES LO MISMO QUE PONER: ELSIF ( CLK'EVENT AND CLK = '1' ) THEN
            IF ( WPC = '1' )THEN
                -- SI WPC = '0', SE HACE LA CARGA DEL DATO QUE ESTA EN EL BUS 'D' EN EL BUS DE SALIDA 'Q' DEL CONTADOR DE PROGRAMA
                Q <= D;
                -- LA SALIDA SERÁ LA DIRECCIÓN DE MEMORIA QUE SE LEERÁ O ESCRIBIRÁ DE LA MEMORIA DE PROGRAMA
            ELSE
                -- SI WPC = '0', EL CONTADOR DE PROGRAMA SE INCREMENTA A LA SIGUIENTE DIRECCIÓN DE MEMORIA
                Q <= Q + 1;
            END IF;
        END IF;

    END PROCESS PC;
END PROGRAMA;