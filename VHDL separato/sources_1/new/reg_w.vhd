library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_w is
  Port (
        i_rst       : in std_logic;
        i_clk       : in std_logic;
        en_reg_w    : in std_logic;
        i_mem_data  : in std_logic_vector(7 downto 0);
        out_w       : out std_logic_vector(7 downto 0)
   );
end reg_w;

architecture reg_w_arch of reg_w is
begin
    process(i_rst, i_clk)
    begin
        if(i_rst = '1') then
            out_w <= (others => '0');--idk se giusto
        elsif (i_clk'event and i_clk = '1') then
            if (en_reg_w = '1') then
                out_w <= i_mem_data;
            --else
                --out_w <= (others => '0');
            end if;
        end if;
    end process;
end reg_w_arch;
