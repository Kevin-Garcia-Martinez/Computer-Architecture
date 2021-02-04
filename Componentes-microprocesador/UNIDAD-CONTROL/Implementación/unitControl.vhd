library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- En VHDL todo se ejecuta de manera concurrente (De manera simultánea).
-- Así que no importa el orden de las instrucciones, todas se ejecutan 
-- al mismo tiempo. 

entity controlUnit is

    Port (
    -- SEÑALES DE CONTROL DEL AUTÓMATA DE CONTROL
    CLR, CLK : in STD_LOGIC;
    -- Código de operación: Bits [24-20] del formato de instrucción
    OP_CODE  : in STD_LOGIC_VECTOR (4 downto 0);
    -- Código de función: Bits [3-0] del formato de instrucción    
    FUN_CODE : in STD_LOGIC_VECTOR (3 downto 0);
    -- Señales de la ALU 'LF'
    C, OV, Z, N : in STD_LOGIC;
    -- La salida de la Unidad de Control es un vector de 20 bits 'S', el cual contiene todas las microinstrucciones 
    -- que se deben activar en todo el microprocesador por cada instrucción del ensamblador que se vaya a ejecutar.
    UP, DW, WPC, SDMP, SR2, SWD, SHE, DIR, WR, SEXT, SOP1, SOP2, SDMD, WD, SR: out STD_LOGIC;
    ALUOP : out STD_LOGIC_VECTOR (3 downto 0)  
    
    );
    
end controlUnit;

architecture program of controlUnit is
-- TIPO_R: Señal que identificará si una instrucción es de tipo R
SIGNAL TIPO_R, BEQI, BNEQI, BLTI, BLETI, BGTI, BGETI : STD_LOGIC;
-- Señales para el bloque de 'REGISTRO DE ESTADOS'
SIGNAL RZ, RC, RN, ROV, LF: STD_LOGIC;
-- Señales para el bloque de 'CONDICIÓN'
SIGNAL EQ, NEQ, LT, LE, GT, GET : STD_LOGIC;

-- MEMORIA DE MICROCÓDIGO DE OPERACIÓN
TYPE MICRO_O IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR( 19 DOWNTO 0); 
CONSTANT MEM_OPC : MICRO_O := 
(                           -- INSTRUCCIÓN
    "00110000000110011001", -- BCOND: Intrucción para brincar
    "00000000100000000000", -- LI
    "00000100100000000100", -- LWI
    "00001000000000000110", -- SWI
    "00000000000000000000", -- SW
    "00000100110010011001", -- ADDI
    "00000100110010111001", -- SUBI
    "00000000000000000000", -- ANDI
    "00000000000000000000", -- ORI
    "00000000000000000000", -- XORI
    "00000000000000000000", -- NANDI
    "00000000000000000000", -- NORI
    "00000000000000000000", -- XNORI
    "00001000010000111000", -- BEQI: Se realiza la resta de los registros para saber si se activan las banderas de la ALU
    "00001000010000111000", -- BNEI
    "00001000010000111000", -- BLTI
    "00001000010000111000", -- BLETI
    "00001000010000111000", -- BGTI
    "00001000010000111000", -- BGETI
    "00100000000000000000", -- BRANCH: B
    "00000000000000000000", -- CALL
    "00000000000000000000", -- RET
    "00000000000000000000", -- NOP
    "00000000000000000000", -- LW
    OTHERS => ( OTHERS => '0' )
);

-- MEMORIA DE MICROCÓDIGO DE FUNCIÓN
TYPE MICRO_F IS ARRAY( 0 TO 15 ) OF STD_LOGIC_VECTOR( 19 DOWNTO 0); 
-- Se declaran como constantes, porque son tipo ROM, es decir, solamente de lectura
CONSTANT MEM_FUN : MICRO_F := 
(                            -- INSTRUCCIÓN                                
     "00000100110000011001", -- ADD
     "00000100110000111001", -- SUB
     "00000100110000000001", -- AND
     "00000100110000001001", -- OR
     "00000100110000010001", -- XOR
     "00000100110001101001", -- NAND
     "00000100110001100001", -- NOR
     "00000100110000110001", -- XNOR
     "00000100110001101001", -- NOT
     "00000011100000000000", -- SLL
     "00000010100000000000", -- SRL
     OTHERS => ( OTHERS => '0' )
);

-- Señal para asignar los valores de salida de la Unidad de Control
SIGNAL S: STD_LOGIC_VECTOR( 19 DOWNTO 0 );
-- Señal de entrada del multiplexor que tiene como señal de control: SDOPC 
SIGNAL A: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
-- Señales de control de los dos multiplexores del Autómata de Control
SIGNAL SM, SDOPC : STD_LOGIC;

-- Señales para los estados del autómata de control
TYPE ESTADOS IS ( EDO_A ); -- Estados del autómata, EDO_A = Estado A de la carta ASM
SIGNAL EDO_ACT, EDO_SGTE: ESTADOS;

begin

-- INICIO BLOQUE 1: DECODIFICADOR DE INSTRUCCIÓN
    
    -- Se trata de una instrucción de tipo R cuando el código de operación es cero.
    TIPO_R <= '1' WHEN ( OP_CODE = "00000" ) ELSE '0';
    BEQI   <= '1' WHEN ( OP_CODE = "01101" ) ELSE '0'; -- Código de operación Num. 13
    BNEQI  <= '1' WHEN ( OP_CODE = "01110" ) ELSE '0'; -- Código de operación Num. 14
    BLTI   <= '1' WHEN ( OP_CODE = "01111" ) ELSE '0'; -- Código de operación Num. 15
    BLETI  <= '1' WHEN ( OP_CODE = "10000" ) ELSE '0'; -- Código de operación Num. 16
    BGTI   <= '1' WHEN ( OP_CODE = "10001" ) ELSE '0'; -- Código de operación Num. 17
    BGETI  <= '1' WHEN ( OP_CODE = "10010" ) ELSE '0'; -- Código de operación Num. 18

-- FIN BLOQUE 1: DECODIFICADOR DE INSTRUCCIÓN

-- INICIO BLOQUE 5: REGISTRO DE ESTADO | REGISTRO DE BANDERAS

    -- Las salidas de este registro serán las 4 banderas de la ALU
    REG_EDO: PROCESS( CLK, CLR )
    BEGIN
        -- Si se aplica un RESET inicializamos las señales
        IF ( CLR = '1' ) THEN
            RZ  <= '0';
            RC  <= '0';
            RN  <= '0';
            ROV <= '0';
        -- Si viene un flanco de subida guardaremos las cuatro banderas de la ALU
        ELSIF( FALLING_EDGE(CLK) ) THEN
            -- Si LF es uno se realizará la carga de las banderas que mando la ALU a la Unidad de Control
            IF( LF = '1') THEN 
                RZ  <= Z;
                RC  <= C;
                RN  <= N;
                ROV <= OV;
             END IF;
        END IF;
    END PROCESS REG_EDO;

-- FIN BLOQUE 5: REGISTRO DE ESTADO

-- INICIO BLOQUE 2: BLOQUE DE CONDICIÓN
    
    -- La bandera de Z de la ALU se guardará en RZ, por lo que si dos números son iguales al hacer 
    -- la resta de estos la bandera de Z (cero) se activará, y por lo tanto la señal RZ será uno. 
    EQ  <= RZ;
    NEQ <= NOT RZ;
    LT  <= (RN XOR ROV) AND NOT(RZ);
    LE  <= (RN XOR ROV) OR RZ;
    GT  <= NOT(RN XOR ROV) AND NOT(RZ);
    GET <= NOT(RN XOR ROV) OR RZ;

-- FIN BLOQUE 2: BLOQUE DE CONDICIÓN


-- INICIO BLOQUE 3: LÓGICA DEL AUTOMÁTA DE CONTROL

-- En este proceso verificaremos el estado de la señal de reloj 'CLK', ya que 
-- esta se encargará de realizar la transición (salto) al siguiente estado del
-- autómata. 
   TRANSICION: PROCESS( CLK, CLR )
   BEGIN
    -- Si el RESET se activa
    IF ( CLR = '1' ) THEN
         -- El automáta se iniciará en el ESTADO A (EDO_A)
        EDO_ACT <= EDO_A;
    ELSIF( RISING_EDGE(CLK) ) THEN
        -- Hasta que llegue el flanco de subida es cuando actualizaremos de estado
        -- del autómata. 
        EDO_ACT <= EDO_SGTE;
    END IF; 
   END PROCESS TRANSICION;
   
-- La lista sensible del proceso tendrá todas las señales que entrán en el automáta de control
-- Recibe como señal el ESTADO ACTUAL EDO_ACT, ya que este se actualiza constantemente en el
-- proceso de TRANSICIÓN
   AUTOMATA: PROCESS( EDO_ACT, TIPO_R, CLK, BEQI, EQ, BNEQI, NEQ, BLTI, LT, BLETI, LE, BGTI, GT, BGETI, GET )
   BEGIN
   -- Inicializamos las únicas 2 dos señales de salida del automáta de control 
   SDOPC <= '0'; -- Multiplexor 1 
   SM    <= '0'; -- Multiplexor 2
    
    -- El CASE es el encargado de revisar en que estado del autómata nos encontramos
    CASE EDO_ACT IS
        -- Cuando el ESTADO ACTUAL sea igual al ESTADO A, todo lo que esta aquí dentro es lo que se verificará
        WHEN EDO_A => 
        -- El ESTADO SIGUIENTE siempre será el ESTADO A (EDO_A), por lo que no es necesario crear un case para otro estado.
        EDO_SGTE <= EDO_A;
        -- Si la instrucción NO es tipo R
            IF( TIPO_R = '0' ) THEN
                -- La señal SM siempre será uno si la instrucción NO es de tipo R
                IF( CLK = '1' ) THEN -- Si es un nivel en alto (flanco de subida)
                    SM    <= '1'; 
                    SDOPC <= '1';
                -- Si es un nivel bajo (flanco de bajada)
                ELSE 
                -- Si se trata de una instrucción de brinco condicional
                    IF( BEQI = '1') THEN 
                        IF( EQ ='1') THEN -- Si se cumple EQ
                            SM <= '1';
                        ELSE
                            SM    <= '1';  
                            SDOPC <= '1';
                        END IF;

                    ELSIF( BNEQI = '1' ) THEN
                        IF( NEQ ='1') THEN -- Si se cumple NEQ
                            SM <= '1'; 
                        ELSE
                            SM    <= '1';  
                            SDOPC <= '1';
                        END IF;
                        
                    ELSIF( BLTI  = '1' ) THEN
                        IF( LT  ='1') THEN -- Si se cumple NEQ
                            SM <= '1'; 
                        ELSE
                            SM    <= '1';  
                            SDOPC <= '1';
                        END IF;
                        
                    ELSIF( BLETI  = '1' ) THEN
                        IF( LE  ='1') THEN -- Si se cumple NEQ
                            SM <= '1'; 
                        ELSE
                            SM    <= '1';  
                            SDOPC <= '1';
                        END IF;
                    
                    ELSIF( BGTI  = '1' ) THEN
                        IF( GT  ='1') THEN -- Si se cumple NEQ
                            SM <= '1'; 
                        ELSE
                            SM    <= '1';  
                            SDOPC <= '1';
                        END IF;
                        
                    ELSIF( BGETI  = '1' ) THEN
                        IF( GET  ='1') THEN -- Si se cumple NEQ
                            SM <= '1'; 
                        ELSE
                            SM    <= '1';  
                            SDOPC <= '1';
                        END IF;
               
                    -- Si no es ninguna instrucción de brinco condicional, la instrucción sale 
                    ELSE 
                        SM    <= '1'; 
                        SDOPC <= '1';                    
                    END IF;
                END IF;
            END IF;
    END CASE;
   END PROCESS AUTOMATA; 
   
-- FIN BLOQUE 3: AUTOMÁTA DE CONTROL
   
-- La salida del multiplexor con selector 'SM' se encargará de seleccionar entre 
-- la memoria de microcódigo de función y de la memoria de microcódigo de operación

-- INICIO BLOQUE 4: BLOQUE DE MULTIPLEXORES  

    -- En este bloque se selecciona la memoria de microcódigo de función o la memoria de microcódigo de operación 
    A <= "00000" WHEN( SDOPC = '0' )ELSE OP_CODE;
    S <= MEM_FUN( conv_integer(FUN_CODE) ) WHEN (SM = '0') ELSE MEM_OPC( conv_integer(A) );

-- FIN BLOQUE 4: BLOQUE DE MULTIPLEXORES       
   
-- Asignamos los valores a las señales de control de salida de la Unidad de Control
    UP    <= S(19);
    DW    <= S(18);
    WPC   <= S(17);
    SDMP  <= S(16);        
    SR2   <= S(15); 
    SWD   <= S(14);
    SHE   <= S(13);
    DIR   <= S(12);
    WR    <= S(11);
    LF    <= S(10);
    SEXT  <= S(9);
    SOP1  <= S(8);
    SOP2  <= S(7);
    ALUOP <= S(6 DOWNTO 3);
    SDMD  <= S(2);
    WD    <= S(1);
    SR    <= S(0);

-- La señal LF la utilizaremos como una señal interna, ya que el bloque que la usa esta dentro de la Unidad de control, 
-- por lo que no hay necesidad de sacarla al resto de los bloques del microprocesador.


end program;
