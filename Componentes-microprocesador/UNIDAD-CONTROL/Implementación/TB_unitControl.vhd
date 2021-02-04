library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity controlUnit_tb is
end;

architecture bench of controlUnit_tb is

  component controlUnit
      Port (
      CLR, CLK : in STD_LOGIC;
      OP_CODE  : in STD_LOGIC_VECTOR (4 downto 0);
      FUN_CODE : in STD_LOGIC_VECTOR (3 downto 0);
      ALUOP : out STD_LOGIC_VECTOR (3 downto 0);
      OV, N, Z, C : in STD_LOGIC;
      UP, DW, WPC, SDMP, SR2, SWD, SHE, DIR, WR, SEXT, SOP1, SOP2, SDMD, WD, SR: out STD_LOGIC
      
      );
  end component;

  signal CLR, CLK: STD_LOGIC;
  signal OP_CODE: STD_LOGIC_VECTOR (4 downto 0);
  signal FUN_CODE: STD_LOGIC_VECTOR (3 downto 0);
  signal ALUOP: STD_LOGIC_VECTOR (3 downto 0) ;
  signal OV, N, Z, C: STD_LOGIC;
  signal UP, DW, WPC, SDMP, SR2, SWD, SHE, DIR, WR, SEXT, SOP1, SOP2, SDMD, WD, SR: STD_LOGIC;
  

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: controlUnit port map ( CLR      => CLR,
                              CLK      => CLK,
                              OP_CODE  => OP_CODE,
                              FUN_CODE => FUN_CODE,
                              ALUOP    => ALUOP,
                              OV       => OV,
                              N        => N,
                              Z        => Z,
                              C        => C,
                              UP       => UP,
                              DW       => DW,
                              WPC      => WPC,
                              SDMP     => SDMP,
                              SR2      => SR2,
                              SWD      => SWD,
                              SHE      => SHE,
                              DIR      => DIR,
                              WR       => WR,
                              SEXT     => SEXT,
                              SOP1     => SOP1,
                              SOP2     => SOP2,
                              SDMD     => SDMD,
                              WD       => WD,
                              SR       => SR
                               );

  stimulus: process
  begin
  
    wait until RISING_EDGE(CLK);     
    -- Instr. Nothing
        CLR  <= '1';
    wait until RISING_EDGE(CLK);
    -- CONDITIONAL BRANCH INSTRUCTIONS
    
    -- Instr. ADD - CARRY
    OP_CODE  <= "00000";
    FUN_CODE <= "0000";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '1';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. ADD - ZERO
    OP_CODE  <= "00000";
    FUN_CODE <= "0000";
         OV  <= '0';
          N  <= '0';
          Z  <= '1';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. SUB
    OP_CODE  <= "00000";
    FUN_CODE <= "0001";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '1';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. AND
    OP_CODE  <= "00000";
    FUN_CODE <= "0010";
         OV  <= '0';
          N  <= '1';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. OR
    OP_CODE  <= "00000";
    FUN_CODE <= "0011";
         OV  <= '1';
          N  <= '1';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. XOR
    OP_CODE  <= "00000";
    FUN_CODE <= "0100";
         OV  <= '0';
          N  <= '0';
          Z  <= '1';
          C  <= '1';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. SLL
    OP_CODE  <= "00000";
    FUN_CODE <= "1001";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. SRL
    OP_CODE  <= "00000";
    FUN_CODE <= "1010";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. OTHER
    OP_CODE  <= "00000";
    FUN_CODE <= "1011";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- TYPE I INSTRUCTIONS
    
    -- Instr. LI
    OP_CODE  <= "00001";
    FUN_CODE <= "0111";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. SWI
    OP_CODE  <= "00011";
    FUN_CODE <= "1000";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. ADDI
    OP_CODE  <= "00101";
    FUN_CODE <= "0000";
         OV  <= '0';
          N  <= '0';
          Z  <= '1';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. SUBI
    OP_CODE  <= "00110";
    FUN_CODE <= "0110";
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '1';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);

    -- Instr. BEQI
    OP_CODE  <= "01101";
    FUN_CODE <= "1111"; -- f
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
 
    -- Instr. BEQI
    OP_CODE  <= "01101";
    FUN_CODE <= "1011"; -- b
         OV  <= '0';
          N  <= '0';
          Z  <= '1';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Falling edge
    
    -- Instr. BNEI
    OP_CODE  <= "01110";
    FUN_CODE <= "1110"; -- e
         OV  <= '0';
          N  <= '0';
          Z  <= '1';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
    
    -- Instr. BNEI
    OP_CODE  <= "01110";
    FUN_CODE <= "0011"; -- 3
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Falling edge
    
    -- Instr. BLTI
    OP_CODE  <= "01111";
    FUN_CODE <= "0001"; -- 1
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '1';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
    
    -- Instr. BLTI
    OP_CODE  <= "01111";
    FUN_CODE <= "0010"; -- 2
         OV  <= '0';
          N  <= '1';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Falling edge
    
    -- Instr. BLETI
    OP_CODE  <= "10000";
    FUN_CODE <= "0100"; -- 4
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
    
    -- Instr. BLETI
    OP_CODE  <= "10000";
    FUN_CODE <= "0101"; -- 5
         OV  <= '1';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Falling edge
    
    -- Instr. BGTI
    OP_CODE  <= "10001";
    FUN_CODE <= "0111"; -- 7
         OV  <= '1';
          N  <= '0';
          Z  <= '1';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
    
    -- Instr. BGTI
    OP_CODE  <= "10001";
    FUN_CODE <= "1000"; -- 8
         OV  <= '1';
          N  <= '1';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Falling edge
    
    -- Instr. BGETI
    OP_CODE  <= "10010";
    FUN_CODE <= "1111"; -- F
         OV  <= '1';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
    
    -- Instr. BGETI
    OP_CODE  <= "10010";
    FUN_CODE <= "1101"; -- D
         OV  <= '1';
          N  <= '1';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);  -- Rising edge
    
    -- TYPE: INCONDITIONAL BRANCH INSTRUCTIONS
    
    -- Instr. B
    OP_CODE  <= "10011"; -- 13
    FUN_CODE <= "1001"; -- 9
         OV  <= '1';
          N  <= '1';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. NOP
    OP_CODE  <= "10110"; -- 16
    FUN_CODE <= "0000"; -- 0
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    -- Instr. OTHER
    OP_CODE  <= "11000"; -- 18
    FUN_CODE <= "0000"; -- 0
         OV  <= '0';
          N  <= '0';
          Z  <= '0';
          C  <= '0';
        CLR  <= '0';
    wait until RISING_EDGE(CLK);
    
    
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