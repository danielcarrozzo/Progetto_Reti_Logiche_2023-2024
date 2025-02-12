library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    Port (
        sel_mux     : in std_logic;
        en_mux      : in std_logic;
        out_w       : in std_logic_vector(7 downto 0);
        out_c       : in std_logic_vector(7 downto 0);
        o_mem_data  : out std_logic_vector(7 downto 0)
   );
end mux;

architecture mux_arch of mux is
begin
    process(sel_mux, en_mux, out_w, out_c)
    begin
        o_mem_data <= (others => '0');
        if(en_mux = '1') then
            case sel_mux is
                when '0' => o_mem_data <= out_w;
                when '1' => o_mem_data <= out_c;
                when others => o_mem_data <= (others => '0');
            end case;
        --else
            --o_mem_data <= (others => '0');
        end if;
    end process;
end mux_arch;
