library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity counter_c is
  Port (
        i_clk        : in std_logic;
        i_rst        : in std_logic;
        rst_c        : in std_logic;
        en_counter_c : in std_logic;
        out_c        : out std_logic_vector(7 downto 0)
   );
end counter_c;

architecture counter_c_arch of counter_c is
    signal temp_c: std_logic_vector(7 downto 0);    
begin
    out_c <= temp_c;
    process(i_clk, i_rst, rst_c)
    begin
        if(i_rst = '1' or rst_c = '1') then
            temp_c <= "00011111";
        elsif (i_clk'event and i_clk = '1') then
            if(en_counter_c = '1') then
                if (temp_c = "00000000") then
                    temp_c <= "00000000";
                else
                    temp_c <= std_logic_vector(signed(temp_c) - 1);
                end if;
            --else
                --temp_c <= "00011111";
            end if;
        end if;
     end process;
end counter_c_arch;
