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
-- Version: For-Generate
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
-- Las señales en VHDL funcionan internamente en el programa, por lo que no tenemos 
-- que declararlas en la entidad 'entity'.

-- Señales de salida de cada sumador 
   SIGNAL EB : std_logic_vector(N-1 downto 0);
-- Señales de los acarreos  C0, C1, C2, C3, C4
   SIGNAL C : std_logic_vector(N downto 0);

   begin
-- El acarreo inicial C0 se inicializa con el valor que tenga BINVERT
   C(0)  <= BINVERT;
-- Utilizaremos un ciclo for-generate para generar las ecuaciones del sumador-restador
    CICLO: FOR i IN 0 TO 3 GENERATE
    -- El cilo irá de (0 a 3), ya que el sumador-restador es de 4 bits
        EB(i)  <= B(i) XOR BINVERT;
        S(i)   <= A(i) XOR EB(i) XOR C(i); 
        C(i+1) <= ( A(i) AND C(i) ) OR ( EB(i) AND C(i) ) OR ( A(i) AND EB(i) ); 
    END GENERATE;
    
    CN <= C(N);
     
end PROGRAMA;
