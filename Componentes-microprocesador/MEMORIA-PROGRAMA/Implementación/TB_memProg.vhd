library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
-- Libreria para utilizar el '+' y la función CONV_INTEGER 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memProg_tb is
end;

architecture bench of memProg_tb is

  component memProg
      Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);   -- Bus de Direcciones de 16 bits
             D : out STD_LOGIC_VECTOR (24 downto 0) ); -- Bus de Datos de 25 bits
  end component;
  -- Inicializaremos el bus de direcciones con la dirección cero
  -- La cual indica el inicio del programa almacenado en la ROM.
  signal A: STD_LOGIC_VECTOR (15 downto 0) := X"0000";
  signal D: STD_LOGIC_VECTOR (24 downto 0) ;

begin

  uut: memProg port map ( A => A,
                          D => D );
  
  -- Cuando un proceso no tiene lista sensible este se ejecutará indefinidamente, hasta que se 
  -- ejecute la llamada a 'wait'. 
  stimulus: process
  begin
   -- Mantendremos el valor que se lea de memoria ROM por 200 ns a la salida
    wait for 200 ns;
    -- Pasamos a la siguiente dirección de memoria
    A <= A + 1;
    -- Si la dirección de memoria es la X"0005", entonces detenemos la simulación
    if( A = X"0005" ) then
        -- La llamada a 'wait' detendrá el ciclo infinito del proceso
        wait;
    end if;
    
  end process;


end;