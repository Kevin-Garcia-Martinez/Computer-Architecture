----------------------------------------------------------------------------------
-- Company: ESCOM (Escuela Superior de Cómputo)
-- Engineer: Kevin García Martínez
-- Create Date: 06.11.2020 11:08:42
-- Design Name: Computer Processing Unit
-- Module Name: ALU - PROGRAM
-- Project Name: Aritmetic Logic Unit - Adder and Subtractor Circuit
-- Device: Nexys4 DDR (Digilent) FPGA (Field Programmable Gate Array)
-- Device Model: XC7A100T -1CSG324C
-- Device Family: Artix-7
-- Speed: -1
-- Package: CSG324
-- Version: For-Loop
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
     -- Declarar 'GENERIC' es lo mismo que definir una constante en un lenguaje de alto nivel
    GENERIC( N: INTEGER := 4);
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           B : in STD_LOGIC_VECTOR (N-1 downto 0);
           BINVERT : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (N-1 downto 0);
           -- C4 es el acarreo de salida del sumador-restador
           CN : out STD_LOGIC);  
end ALU;

architecture PROGRAMA of ALU is
begin

-- ASPECTOS A TOMAR ENCUENTA EN LA EJECUCIÓN DE UN PROCESO 'PROCESS':

-- 1. En un proceso la ejecución del código es de manera secuencial.
-- 2. Las señales 'signals' se actualizan al terminar el proceso. 
-- 3. El resultado de las sentencias se coloca en los DRIVERS de las señales y no en la señal como tal.
-- 4. Debemos indicarle al proceso que se comporte como un programa secuencial, de tal modo que los 
-- valores no se almacenen en los driver de las señales.


-- Si queremos utilizar el ciclo for-loop, es necesario que creemos un 'PROCESS' para su implementación.
-- Cuando se trata de un circuito combinatorio los parámetros que recibe la lista sensible de un 'PROCESS'
-- son las entradas que recibe directamente el circuito, para este caso son: A, B, BINVERT. 
PROCESS_ALU: PROCESS( A, B, BINVERT )
-- Para asignar un valor a una variable utilizaremos el operador ':=' 
-- Las variables que se creen solamente existirán dentro del proceso. 
variable  C: std_logic_vector(N downto 0);
variable EB: std_logic_vector(N-1 downto 0);

begin 
    -- A   =    (0, 1, 0, 1)
    -- B   =    (0, 0, 1, 0)
    -- BINVERT = 0
    
    -- Si 'C' fuese una señal, en el momento en que entra al proceso todos sus bits tienen 'UNDEFINED'
    -- C( U, U, U, U, U ) incluso los de su DRIVER C( U, U, U, U, U ).
    C(0)  := BINVERT;
    -- Si 'C' fuese una señal, el valor que tendría 'C' después de ejecutar la sentencia anterior seguiría
    -- siendo el mismo valor con el que entro C( U, U, U, U, U ), ya que el valor de BINVERT se colocaría 
    -- en el DRIVER de 'C', y no en la señal de accarreo 'C' como tal, entonces lo que tendríamos sería:
    --                      
    --                          C( U, U, U, U, U )  DRIVER C( U, U, U, U, BINVERT )
    -- 
    -- Entonces, si nosotros queremos que el valor del bit menos significativo de 'C' (0) se actualice en 
    -- el momento en que se ejecute la sentencia 'C(0)  := BINVERT;', lo que debemos hacer es declarar a C 
    -- como una variable y no como una señal. De tal modo que ahora que C es una variable, los valores de 
    -- sus bits serán actualizados en el momento en que sean utilizados en alguna sentencia de nuestro código.
   
    -- Utilizaremos un ciclo for-loop para generar las ecuaciones del sumador-restador
    FOR i IN 0 TO N-1 LOOP         -- EB (U, U, U, 0)
    -- El resultado de la compuerta XOR se alamcena en el DRIVER EB (U, U, U, 0) y no en la señal EB 
        EB(i)  := B(i) XOR BINVERT;   
     -- S debería de ser una señal, ya que no utilizamos su valor en una sentencia inmediata/posterior, 
     -- es decir, no necesita ser actualizada en el momento en que se utilice en una sentencia de nuestro 
     -- código, ya que su valor no se utilizará en la sentencia inmediata, por lo que no necesita actualizarse, 
     -- entonces, podemos decir que sí necesito actualizar el valor de alguna 'variable' porque necesitaré 
     -- ese valor en en la sentencia siguiente de mi código, entonces forzosamente tendrá que ser una variable,
     -- de no ser así, puede quedar perfectamente como una señal. 
        S(i)   <= A(i) XOR EB(i) XOR C(i); 
        C(i+1) := ( A(i) AND C(i) ) OR ( EB(i) AND C(i) ) OR ( A(i) AND EB(i) ); 
    
    END LOOP;

    CN <= C(N);
    
end PROCESS PROCESS_ALU;
     
end PROGRAMA;
