library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

-- Se pone una entidad vacía porque no utilizamos puertos
entity ALU_tb is
end;

architecture bench of ALU_tb is
-- Se hace un componente, son liberias que se crean para tomarlas y ususarlas en otros programas
  component ALU
      Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
             B : in STD_LOGIC_VECTOR (3 downto 0);
             BINVERT : in STD_LOGIC;
             S : out STD_LOGIC_VECTOR (3 downto 0);
             CN : out STD_LOGIC);  
  end component;
 -- Una señal por cada puerto
  signal A: STD_LOGIC_VECTOR (3 downto 0);
  signal B: STD_LOGIC_VECTOR (3 downto 0);
  signal BINVERT: STD_LOGIC;
  signal S: STD_LOGIC_VECTOR (3 downto 0);
  signal CN: STD_LOGIC;

begin

  uut: ALU port map ( A       => A,
                      B       => B,
                      BINVERT => BINVERT,
                      S       => S,
                      CN      => CN );


-- En los proces va una lista sensible (parámetros)
-- Un proceso que no tiene lista sensible, es un proceso que se ejecutará se manera infinita
  stimulus: process
  begin
  -- Se colocan los vectores de prueba
  A       <= "0001"; -- 1
  B       <= "1000"; -- 8
  BINVERT <= '1'; -- RESTA
  -- WAIT FOR es una sentencia para decir durante cuando tiempo se van a quedar los valores de estos vectores como entradas
  WAIT FOR 100 ns;
  -- Podemos preguntar el valor de salida después del wait for
  A       <= "0101"; -- 5
  B       <= "0010"; -- 2
  BINVERT <= '0'; -- SUMA
  -- WAIT FOR  mantiene los valores que se especifican como salidas durante cierto periodo de tiempo
  WAIT FOR 100 ns;
  A <= "0101"; -- 5
  B <= "0100"; -- 4
  BINVERT <= '0'; -- SUMA
  WAIT FOR 100 ns;
    -- wait solito hace que el proceso termine su ejecución, sino la ponemos este seguirá ejecutándose indefinidamente 
    wait;
  end process;


end;
