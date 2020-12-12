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
    Port ( A     : in STD_LOGIC_VECTOR (N-1 downto 0);
           B     : in STD_LOGIC_VECTOR (N-1 downto 0);
           -- ALUOP siempre será constante, siempre serán 4 bits
           ALUOP : in STD_LOGIC_VECTOR (3 downto 0);
           RES   : inout STD_LOGIC_VECTOR (N-1 downto 0);
           -- Banderas que tendrá la ALU
           Z     : out STD_LOGIC;
           CARRY : out STD_LOGIC;
           NEG   : out STD_LOGIC;
           OV    : out STD_LOGIC;
           -- DISPLAY de 7 Segmentos
           DISPLAY : out STD_LOGIC_VECTOR (6 downto 0); 
                AN : out STD_LOGIC_VECTOR (7 downto 0) );
end ALU;

architecture PROGRAMA of ALU is
begin
    -- Encendemos el Display que utilizaremos con un '0'
    AN <= "01111111";
    -- ALUOP(3), ALUOP(2), ALUOP(1), ALUOP(0)
    -- AINVERT , BINVERT,  OP(1),   OP(0) ---> OP(1) y OP(0) son los selectores del mux para la operación  
    -- En todo circuito combinatorio debemos de poner en la lista sensible del
    -- proceso todas sus entradas que tenga
    PALU: PROCESS( A, B, ALUOP)
        -- Acarreos del Sumador-Restador
        VARIABLE  C: STD_LOGIC_VECTOR(N downto 0);
        -- Variable para el término 2 (Sumatoria * Multiplicatoria) y término 3 del Acarreo Siguiente
        VARIABLE T2, T3, PK : STD_LOGIC;
        -- Salidas de los multiplexores de nuestro diagrama
        VARIABLE MUXA, MUXB, P, G : STD_LOGIC_VECTOR(N-1 downto 0);
        
        BEGIN
            -- Inicializamos el Acarreo Inicial con BINVERT
            C(0) := ALUOP(2);
            -- Inicializamos los demas Acarreos con Cero C1, C2, C3, C4
            C(4 DOWNTO 1) := "0000";
        
            FOR i IN 0 TO N-1 LOOP
                -- Ecuación del multiplexor A | ALUOP(3) : AINVERT
                MUXA(i) := A(i) XOR ALUOP(3);
                -- Ecuación del multiplexor B | ALUOP(2) : BINVERT
                MUXB(i) := B(i) XOR ALUOP(2);
                -- CASE Señal que vamos a revisar (pueden ser dos bits)
                CASE ALUOP(1 DOWNTO 0) IS -- Con 1 downto 0 estamos tomando secciones de bit de un vector, en este caso tomamos el bit 1 y el bit 0
                    -- Aquí podemos poner los valores que tendrán los bits que queremos revisar en el case
                    -- Compuerta AND del circuito
                    WHEN "00"   =>
                        RES(i) <= MUXA(i) AND MUXB(i);
                    -- Compuerta OR del circuito
                    WHEN "01"   =>
                        RES(i) <= MUXA(i) OR MUXB(i); 
                    -- Compuerta XOR del circuito
                    WHEN "10"   =>
                        RES(i) <= MUXA(i) XOR MUXB(i);
                    -- Circuito Sumador-Restador 4 bits 
                    WHEN OTHERS =>
                        P(i)   := A(i) XOR MUXB(i);   
                        G(i)   := A(i) AND MUXB(i);
                        RES(i) <= A(i) XOR MUXB(i) XOR C(i); 
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
                END CASE;
            END LOOP;
        
        -- Generando las demás banderas de la ALU
        CARRY <= C(4);          -- Bandera de Acarreo
        OV    <= C(4) XOR C(3); -- Bandera de OverFlow 
    
    END PROCESS PALU; 
    -- RES debe de ser inout para que podamos utilizar su valor para generar la bandera Z
    Z   <= '1' WHEN RES = "0000" ELSE '0';
    NEG <= RES(3);        -- Bandera de Negativo
    
    -- El display es ánodo común, por lo que para encender cada LED necesitaremos un nivel lógico bajo '0'
	-- Y para seleccionar el display que se utilizará de la FPGA utilizaremos un vector de 8 bits llamado AN  
	          -- ABCDEFG
	DISPLAY <=  "0000001" WHEN (RES = "0000") ELSE -- 0
		   	    "1001111" WHEN (RES = "0001") ELSE -- 1
		   	  	"0010010" WHEN (RES = "0010") ELSE -- 2
		   		"0000110" WHEN (RES = "0011") ELSE -- 3
		  	 	"1001100" WHEN (RES = "0100") ELSE -- 4
		   		"0100100" WHEN (RES = "0101") ELSE -- 5
		   		"0100000" WHEN (RES = "0110") ELSE -- 6
		   		"0001100" WHEN (RES = "0111") ELSE -- 7
		   		"0000000" WHEN (RES = "1000") ELSE -- 8
				"0001100" WHEN (RES = "1001") ELSE -- 9
				"0001000" WHEN (RES = "1010") ELSE -- A
				"1100000" WHEN (RES = "1011") ELSE -- B
				"0110001" WHEN (RES = "1100") ELSE -- C
				"1000010" WHEN (RES = "1101") ELSE -- D
				"0110000" WHEN (RES = "1110") ELSE -- E
				"0111000" ;                        -- F
end PROGRAMA;

