----------------------------------------------------------------------------------
-- Company: ESCOM (Escuela Superior de Cómputo -IPN)
-- Engineer: Kevin García Martínez
-- Create Date: 06.11.2020 11:08:42
-- Design Name: Computer Processing Unit
-- Module Name: ALU - PROGRAM
-- Project Name: Aritmetic Logic Unit 
-- Device: Nexys4 DDR (Digilent) FPGA (Field Programmable Gate Array)
-- Device Model: XC7A100T -1CSG324C
-- Device Family: Artix-7
-- Speed: -1
-- Package: CSG324
-- Version: Aritmetic Logic Unit Complete Desing 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
     -- 'GENERIC' nos sirve para definir una constante en VHDL (así como un lenguaje de alto nivel)
    GENERIC( N: INTEGER := 4);
    Port ( A     : in STD_LOGIC_VECTOR (N-1 downto 0);
           B     : in STD_LOGIC_VECTOR (N-1 downto 0);
           -- El BUS ALUOP siempre será constante (Será siempre de 4 bits)
           ALUOP : in STD_LOGIC_VECTOR (3 downto 0);
           RES   : inout STD_LOGIC_VECTOR (N-1 downto 0);
           -- Banderas de la ALU
           Z     : out STD_LOGIC;
           CARRY : out STD_LOGIC;
           NEG   : out STD_LOGIC;
           OV    : out STD_LOGIC 
        );
end ALU;

architecture PROGRAMA of ALU is
begin
    -- ALUOP : ALUOP(3), ALUOP(2), ALUOP(1), ALUOP(0), donde: 
    -- ALUOP(3) : AINVERT 
    -- ALUOP(2) : BINVERT
    -- ALUOP(1) : OP(1)
    -- ALUOP(0) : OP(0)
    -- OP(1) y OP(0) son los selectores del multiplexor para seleccionar la operación que se realizará en la ALU  
    
    -- En cualquier circuito combinatorio que se diseñe debemos de colocar en la lista sensible del
    -- proceso todas las entradas que este tendrá. 
    PALU: PROCESS( A, B, ALUOP)
        -- Variables para los Acarreos del Sumador-Restador
        VARIABLE  C: STD_LOGIC_VECTOR (N downto 0);
        -- Variables para el segundo término (Sumatoria * Multiplicatoria) y 
        -- para el tercer término (Multiplicatorias) del Acarreo Siguiente
        VARIABLE T2, T3, PK : STD_LOGIC;
        -- Variables para acumular los valores del Sumdor-Restador 
        VARIABLE P, G : STD_LOGIC_VECTOR (N-1 downto 0);
        -- Salidas de los multiplexores para AINVERT y BINVERT
        VARIABLE MUXA, MUXB : STD_LOGIC_VECTOR (N-1 downto 0);
        
        BEGIN
            -- Inicializamos el Acarreo Inicial con BINVERT
            C(0) := ALUOP(2);
            -- Inicializamos los acarreos C1, C2, C3, C4 con cero '0'
            C(4 DOWNTO 1) := "0000";
        
            FOR i IN 0 TO N-1 LOOP
                -- Ecuación del multiplexor A | ALUOP(3) : AINVERT
                MUXA(i) := A(i) XOR ALUOP(3);  -- Ai XOR AINVERT
                -- Ecuación del multiplexor B | ALUOP(2) : BINVERT
                MUXB(i) := B(i) XOR ALUOP(2);  -- Bi XOR BINVERT
                -- Dentro del CASE se especifica la señal que vamos a revisar (pueden ser incluso dos Bits)
                CASE ALUOP(1 DOWNTO 0) IS 
                -- Al indicar '1 DOWNTO 0' estamos tomando secciones de Bits de un vector, en este caso 
                -- tomamos el Bit 1 y el Bit 0 de ALUPOP. Una vez en el CASE podemos indicar los valores 
                -- que tendrán los bits que queremos revisar: Bits ALUOP(1) y ALUOP(0) 

                    -- Compuerta AND del circuito
                    WHEN "00"   =>
                        RES(i) <= MUXA(i) AND MUXB(i);
                    -- Compuerta OR del circuito
                    WHEN "01"   =>
                        RES(i) <= MUXA(i) OR MUXB(i); 
                    -- Compuerta XOR del circuito
                    WHEN "10"   =>
                        RES(i) <= MUXA(i) XOR MUXB(i);
                    -- Circuito Sumador-Restador de 4 bits 
                    WHEN OTHERS =>
                        -- Pi = Ai XOR (Bi XOR BINVERT)
                        P(i)   := A(i) XOR MUXB(i);
                        -- Gi = Ai AND (Bi XOR BINVERT)
                        G(i)   := A(i) AND MUXB(i);
                        -- RESi = Ai XOR (Bi XOR BINVERT) XOR Ci
                        RES(i) <= A(i) XOR MUXB(i) XOR C(i); 
                        -- T2 lo tenemos que inicializar con cero, ya que esta variable efectua una compuerta OR
                        T2 := '0';
                        -- Cálculo del término 2 de la ecuación del acarreo Ci+1
                        FOR j IN 0 TO i-1 LOOP
                            -- Inicializamos la variable que almacenará el acumulado de las compuertas AND
                            PK := '1';
                            -- Multiplicatoria de solamente compuertas AND
                            FOR k IN j+1 TO i LOOP
                                -- Acumulación de las compuertas AND  
                                PK := PK AND P(k);
                            END LOOP;
                            -- En T2 se deja el resultado de la sumatoria por el producto y se acumula
                            T2 := T2 OR ( G(j) AND PK );
                        END LOOP;

                        -- Cálculo del término 3 de la ecuación del acarreo Ci+1
                        T3 := C(0);
                        -- Si la condición no se cumple no se entra al ciclo FOR
                        FOR l IN 0 TO i LOOP
                            -- Acumulación de la operación Multiplicatoria de Pl
                            T3 := T3 AND P(l);
                        END LOOP;
                        -- Cálculo del Acarreo Siguiente
                        C(i+1) := G(i) OR T2 OR T3;
                END CASE;
            END LOOP;
        
        -- Generación de las banderas de la ALU
        CARRY <= C(4);          -- Bandera de Acarreo
        OV    <= C(4) XOR C(3); -- Bandera de OverFlow 
    
    END PROCESS PALU; 

    -- RES debe de ser inout para que podamos utilizar su valor para generar la bandera Z
    Z   <= '1' WHEN RES = "0000" ELSE '0'; -- Bandera de Cero
    NEG <= RES(3);        -- Bandera de Negativo

end PROGRAMA;