-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity REGISTROS_tb is
end;

architecture bench of REGISTROS_tb is

  component REGISTROS
      --GENERIC( NADDR : INTEGER := 8;
      --         NDATA : INTEGER := 16);
               
      Port ( CLK, WR        : in STD_LOGIC;
             SHE, DIR       : in STD_LOGIC;
             WRITE_REGISTER : in  STD_LOGIC_VECTOR (3 downto 0);
             READ_REGISTER1 : in  STD_LOGIC_VECTOR (3 downto 0);
             READ_REGISTER2 : in  STD_LOGIC_VECTOR (3 downto 0);
             SHAMT          : in  STD_LOGIC_VECTOR (3 downto 0);
             WRITE_DATA     : in  STD_LOGIC_VECTOR (15 downto 0); 
             READ_DATA1     : inout STD_LOGIC_VECTOR (15 downto 0);
             READ_DATA2     : out STD_LOGIC_VECTOR (15 downto 0) 
             );
  end component;

  signal CLK, WR: STD_LOGIC;
  signal SHE, DIR: STD_LOGIC;
  signal WRITE_REGISTER: STD_LOGIC_VECTOR (3 downto 0);
  signal READ_REGISTER1: STD_LOGIC_VECTOR (3 downto 0);
  signal READ_REGISTER2: STD_LOGIC_VECTOR (3 downto 0);
  signal SHAMT: STD_LOGIC_VECTOR (3 downto 0);
  signal WRITE_DATA: STD_LOGIC_VECTOR (15 downto 0);
  signal READ_DATA1: STD_LOGIC_VECTOR (15 downto 0);
  signal READ_DATA2: STD_LOGIC_VECTOR (15 downto 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: REGISTROS 
                    port map ( CLK            => CLK,
                               WR             => WR,
                               SHE            => SHE,
                               DIR            => DIR,
                               WRITE_REGISTER => WRITE_REGISTER,
                               READ_REGISTER1 => READ_REGISTER1,
                               READ_REGISTER2 => READ_REGISTER2,
                               SHAMT          => SHAMT,
                               WRITE_DATA     => WRITE_DATA,
                               READ_DATA1     => READ_DATA1,
                               READ_DATA2     => READ_DATA2 );

  stimulus: process
  begin
    --ESCRITURA DE DATOS
    wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0000";
      READ_REGISTER2 <= "0000";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0000";
      WRITE_DATA <= X"0000";
      WR <= '1';
      SHE <= '0';
      DIR <= '0';
      
    wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0000";
      READ_REGISTER2 <= "0000";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0010";
      WRITE_DATA <= X"2381";
      WR <= '1';
      SHE <= '0';
      DIR <= '0';
      
    wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0000";
      READ_REGISTER2 <= "0000";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0100";
      WRITE_DATA <= X"7652";
      WR <= '1';
      SHE <= '0';
      DIR <= '0';
      
   wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0000";
      READ_REGISTER2 <= "0000";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0101";
      WRITE_DATA <= X"1A4E";
      WR <= '1';
      SHE <= '0';
      DIR <= '0';
      
    -- LECTURA DE DATOS
    wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0101";
      READ_REGISTER2 <= "0000";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0000";
      WRITE_DATA <= X"0000";
      WR <= '0';
      SHE <= '0';
      DIR <= '0';
      
    wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0010";
      READ_REGISTER2 <= "0100";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0000";
      WRITE_DATA <= X"0000";
      WR <= '0';
      SHE <= '0';
      DIR <= '0';
      
    wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0100";
      READ_REGISTER2 <= "0101";
      SHAMT <= "0010";
      WRITE_REGISTER <= "0100";
      WRITE_DATA <= X"0000";
      WR <= '1';
      SHE <= '1'; -- >>
      DIR <= '0';
      
   wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0010";
      READ_REGISTER2 <= "0010";
      SHAMT <= "0100";
      WRITE_REGISTER <= "1000";
      WRITE_DATA <= X"0000";
      WR <= '1';
      SHE <= '1';
      DIR <= '1';

   wait until RISING_EDGE(CLK);
      READ_REGISTER1 <= "0100";
      READ_REGISTER2 <= "1000";
      SHAMT <= "0000";
      WRITE_REGISTER <= "0000";
      WRITE_DATA <= X"0000";
      WR <= '0';
      SHE <= '0';
      DIR <= '0';
      
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