library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity counter_addr is
    Port (
        i_clk               : in std_logic;
        i_start             : in std_logic;
        en_start_addr       : in std_logic;
        en_counter_addr     : in std_logic;
        i_add_reg           : in std_logic_vector(15 downto 0);
        o_counter_addr      : out std_logic_vector(15 downto 0);
        o_mem_addr          : out std_logic_vector(15 downto 0)
   );
end counter_addr;

architecture counter_addr_arch of counter_addr is
    signal temp_addr: std_logic_vector(15 downto 0) := (others => '0');
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (en_start_addr = '1' and i_start = '1') then
                temp_addr <= i_add_reg;
            elsif (i_start = '1') then
                if (en_counter_addr = '1') then
                    temp_addr <= std_logic_vector(signed(temp_addr) + 1);
                end if;
            end if;
        end if;
    end process;
    
    o_counter_addr <= temp_addr;
    o_mem_addr <= temp_addr;
end counter_addr_arch;
