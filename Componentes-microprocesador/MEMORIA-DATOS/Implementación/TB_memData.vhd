library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity memData_tb is
end;

architecture bench of memData_tb is

  component memData
  
      Port ( ADDR   : in  STD_LOGIC_VECTOR (7 downto 0);
             WD, CLK: in STD_LOGIC;
             DIN  : in  STD_LOGIC_VECTOR (15 downto 0);
             DOUT : out STD_LOGIC_VECTOR (15 downto 0) );
  end component;

  signal ADDR: STD_LOGIC_VECTOR (7 downto 0);
  signal WD, CLK: STD_LOGIC;
  signal DIN: STD_LOGIC_VECTOR (15 downto 0);
  signal DOUT: STD_LOGIC_VECTOR (15 downto 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: memData
                  port map ( ADDR  => ADDR,
                             WD    => WD,
                             CLK   => CLK,
                             DIN   => DIN,
                             DOUT  => DOUT );

  stimulus: process
  begin
      DIN  <= X"A25B";  -- Bus de datos de entrada
      ADDR <= X"23";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"A25B";  -- Bus de datos de entrada
      ADDR <= X"23";    -- Dirección de Memoria que se escribirá
      WD   <= '1';      -- Escritura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"1234";  -- Bus de datos de entrada
      ADDR <= X"24";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"1234";  -- Bus de datos de entrada
      ADDR <= X"24";    -- Dirección de Memoria que se escribirá
      WD   <= '1';      -- Escritura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"9875";  -- Bus de datos de entrada
      ADDR <= X"25";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"9875";  -- Bus de datos de entrada
      ADDR <= X"25";    -- Dirección de Memoria que se escribirá
      WD   <= '1';      -- Escritura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"ABCD";  -- Bus de datos de entrada
      ADDR <= X"26";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"ABCD";  -- Bus de datos de entrada
      ADDR <= X"26";    -- Dirección de Memoria que se escribirá
      WD   <= '1';      -- Escritura de la Memoria RAM
     
     -- Lectura de las Direcciones Escritas
     
      wait for 50 ns;
      
      DIN  <= X"B832";  -- Bus de datos de entrada
      ADDR <= X"23";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"ABCD";  -- Bus de datos de entrada
      ADDR <= X"24";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"A268";  -- Bus de datos de entrada
      ADDR <= X"25";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM
      
      wait for 50 ns;
      
      DIN  <= X"8736";  -- Bus de datos de entrada
      ADDR <= X"26";    -- Dirección de Memoria que se leerá.
      WD   <= '0';      -- Lectura de la Memoria RAM

    -- Se detiene el reloj 
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      CLK <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  