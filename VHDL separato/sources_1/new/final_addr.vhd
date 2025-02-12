library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity final_addr is
  Port ( 
        i_add : in std_logic_vector(15 downto 0);
        i_k : in std_logic_vector(9 downto 0);
        final_addr : out std_logic_vector(15 downto 0)
  );
end final_addr;

architecture final_addr_arch of final_addr is
begin
    process(i_add, i_k)
    begin
        final_addr <= std_logic_vector(unsigned(i_add) + unsigned(i_k) + unsigned(i_k));--maybe add -1
    end process;
end final_addr_arch;