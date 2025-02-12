library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator is
    Port (
        o_counter_addr : in std_logic_vector(15 downto 0);
        final_addr      : in std_logic_vector(15 downto 0);
        control_addr    : out std_logic
   );
end comparator;

architecture comparator_arch of comparator is
begin
    process(o_counter_addr, final_addr)
    begin
        if (o_counter_addr >= final_addr) then
            control_addr <= '1';
        else 
            control_addr <= '0';
        end if;
    end process;
end comparator_arch;
