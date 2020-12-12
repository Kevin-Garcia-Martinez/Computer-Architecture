library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

-- Se pone una entidad vacía porque no utilizamos puertos
entity ALU_tb is
end;

architecture bench of ALU_tb is
-- Se hace un componente, son liberias que se crean para tomarlas y ususarlas en otros programas
  component ALU
      Port ( A     : in STD_LOGIC_VECTOR (3 downto 0);
             B     : in STD_LOGIC_VECTOR (3 downto 0);
             -- ALUOP siempre será constante, siempre serán 4 bits
             ALUOP : in STD_LOGIC_VECTOR (3 downto 0);
             RES   : inout STD_LOGIC_VECTOR (3 downto 0);
             -- Banderas que tendrá la ALU
             Z     : out STD_LOGIC;
             CARRY : out STD_LOGIC;
             NEG   : out STD_LOGIC;
             OV    : out STD_LOGIC;
             -- Display de 7 segmentos
             DISPLAY : out STD_LOGIC_VECTOR (6 downto 0); 
             AN : out STD_LOGIC );
  end component;
 -- Una señal por cada puerto
  signal A:       STD_LOGIC_VECTOR (3 downto 0);
  signal B:       STD_LOGIC_VECTOR (3 downto 0);
  signal ALUOP:   STD_LOGIC_VECTOR (3 downto 0);
  signal RES:     STD_LOGIC_VECTOR (3 downto 0);
  signal DISPLAY: STD_LOGIC_VECTOR (6 downto 0);
  -- Señales para las banderas de salida
  signal Z:     STD_LOGIC;
  signal CARRY: STD_LOGIC;
  signal NEG:   STD_LOGIC;
  signal OV:    STD_LOGIC;
  signal AN:    STD_LOGIC;

begin

  uut: ALU port map ( A     => A,
                      B     => B,
                      ALUOP => ALUOP,
                      RES   => RES,
                      DISPLAY => DISPLAY,
                      -- Banderas de salida de la ALU
                      Z     => Z,
                      CARRY => CARRY,
                      NEG   => NEG,
                      OV    => OV,
                      AN    => AN );

-- En los proces va una lista sensible (parámetros)
-- Un proceso que no tiene lista sensible, es un proceso que se ejecutará se manera infinita
  stimulus: process
  begin
  -- Se colocan los vectores de prueba, no es necesario colocar los valores para los
  -- vectores A y B después de cada WAIT FOR 50 ns, ya que estos se conservarán hasta
  -- que indiquemos que se tienen que cambiar 
  
  A       <= "0101"; --  5
  B       <= "1110"; -- -2
  ALUOP   <= "0011"; -- SUMA
  
  -- WAIT FOR es una sentencia para decir durante cuando tiempo se van a quedar los valores de estos vectores como entradas
  WAIT FOR 50 ns;
  -- Podemos preguntar el valor de salida después del wait for
  
  ALUOP   <= "0111"; -- RESTA
  
  -- WAIT FOR  mantiene los valores que se especifican como salidas durante cierto periodo de tiempo
  WAIT FOR 50 ns;
  
  ALUOP   <= "0000"; -- AND
  
  WAIT FOR 50 ns;
  
  ALUOP   <= "1101"; -- NAND
  
  WAIT FOR 50 ns;
  
  ALUOP   <= "0001"; -- OR
  
  WAIT FOR 50 ns;
  
  ALUOP   <= "1100"; -- NOR
  
  WAIT FOR 50 ns;
  
  ALUOP   <= "0010"; -- XOR
  
  WAIT FOR 50 ns;
  
  ALUOP   <= "1010"; -- XNOR
  
  WAIT FOR 50 ns;
  
  A       <= "0101"; --  5
  B       <= "0111"; --  7
  ALUOP   <= "0011"; -- SUMA 
  
  WAIT FOR 50 ns;
  
  A       <= "0101"; --  5
  B       <= "0101"; --  5
  ALUOP   <= "0111"; -- RESTA
  
  WAIT FOR 50 ns;
  
  A       <= "0101"; --  5
  B       <= "0101"; --  5
  ALUOP   <= "1101"; -- NAND (NOT)
  
  WAIT FOR 50 ns;
  
    -- wait solito hace que el proceso termine su ejecución, sino la ponemos este seguirá ejecutándose indefinidamente 
    wait;
  end process;


end;
