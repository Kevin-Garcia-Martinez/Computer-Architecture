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
-- Version: Carry Look-Ahead
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
-- Lista Sensible del proceso: A, B, BINVERT
PROCESS_ALU: PROCESS( A, B, BINVERT )
-- Sección de variables
variable  C: std_logic_vector(N downto 0);
-- EB es la salida dle multiplexor que realiza automáticamente el complemento a uno
variable EB, P, G: std_logic_vector(N-1 downto 0);
-- Variable para el término 2 (Sumatoria * Multiplicatoria) y 3 del Acarreo Siguiente
variable T2, T3, PK : std_logic;
-- T1 y T2 son variables ya que su valor se tiene que actualizar constantemente

-- Comienzo del proceso
begin
    -- Acarreo inicial se inicializa con el valor de BINVERT
    C(0) := BINVERT;

    -- Generamos las ecuaciones del sumador-restador con Acarreo Anticipado
    FOR i IN 0 TO N-1 LOOP
        EB(i)  := B(i) XOR BINVERT;
        P(i)   := A(i) XOR EB(i);    -- P(0)  P(1)  P(2)  P(3)
        G(i)   := A(i) AND EB(i);
        S(i)   <= A(i) XOR EB(i) XOR C(i); 
        -- T2 lo tenemos que inicializar con cero, ya que esta variable efectua una compuerta OR.
        T2 := '0';
        -- Cálculamos el término 2 de la ecuación del acarreo Ci+1
        FOR j IN 0 TO i-1 LOOP
            -- Inicializamos la variable que va acumular las AND
            PK := '1';
            -- Multiplicatoria de puras compuertas AND
            FOR k IN j+1 TO i LOOP
                -- Acumulación de las compuertas AND  
                PK := PK AND P(k);
            END LOOP;
            -- En T2 se deja el resultado de la sumatoria por el producto
            T2 := T2 OR ( G(j) AND PK );
        END LOOP;
        -- Cálculo de T3
        T3 := C(0);
        -- Si la condición no se cumple no se entra al ciclo FOR
        FOR l IN 0 TO i LOOP
            -- Acumulación de la operación Multiplicatoria de PL
            T3 := T3 AND P(l);
        END LOOP;
        -- Calculamos el acarreo siguiente
        C(i+1) := G(i) OR T2 OR T3;
    END LOOP;

    -- Asignamos el bit más significativo de C a C4
    CN <= C(N);

-- Fin del proceso 
end PROCESS PROCESS_ALU;
     
end PROGRAMA;
