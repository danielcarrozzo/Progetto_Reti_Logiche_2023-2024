library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator_data_zero is
    Port (
        i_mem_data : in std_logic_vector(7 downto 0);
        data_zero    : out std_logic
   );
end comparator_data_zero;

architecture comparator_data_zero_arch of comparator_data_zero is
begin
    process(i_mem_data)
    begin
        if (i_mem_data = "00000000") then
            data_zero <= '1';
        else 
            data_zero <= '0';
        end if;
    end process;
end comparator_data_zero_arch;
