library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port(
    i_clk                       : in std_logic;
    i_rst                       : in std_logic;
    i_start                     : in std_logic;
    i_add                       : in std_logic_vector(15 downto 0);
    i_k                         : in std_logic_vector(9 downto 0);
    
    o_done                      : out std_logic;
    
    o_mem_addr                  : out std_logic_vector(15 downto 0);
    i_mem_data                  : in  std_logic_vector(7 downto 0);
    o_mem_data                  : out std_logic_vector(7 downto 0);
    o_mem_we                    : out std_logic;
    o_mem_en                    : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

    component comparator_addr is
        Port (
            o_counter_addr      : in std_logic_vector(15 downto 0);
            final_addr          : in std_logic_vector(15 downto 0);
            control_addr        : out std_logic
       );
    end component comparator_addr;
    
    component comparator_data_zero is
        Port (
            i_mem_data          : in std_logic_vector(7 downto 0);
            data_zero           : out std_logic
       );
    end component comparator_data_zero;
    
    component counter_addr is
        Port (
            i_clk               : in std_logic;
            i_start             : in std_logic;
            en_start_addr       : in std_logic;
            en_counter_addr     : in std_logic;
            i_add               : in std_logic_vector(15 downto 0);
            o_counter_addr      : out std_logic_vector(15 downto 0);
            o_mem_addr          : out std_logic_vector(15 downto 0)
       );
    end component counter_addr;
    
    component counter_c is
      Port (
            i_clk               : in std_logic;
            i_rst               : in std_logic;
            rst_c               : in std_logic;
            en_counter_c        : in std_logic;
            out_c               : out std_logic_vector(7 downto 0)
       );
    end component counter_c;
    
    component final_addr is
      Port ( 
            i_add               : in std_logic_vector(15 downto 0);
            i_k                 : in std_logic_vector(9 downto 0);
            final_addr          : out std_logic_vector(15 downto 0)
      );
    end component final_addr;
    
    component fsm is
        Port(
            i_start             : in std_logic;
            i_clk               : in std_logic;
            i_rst               : in std_logic;
            
            en_start_addr       : out std_logic;
            en_counter_addr     : out std_logic;
            control_addr        : in std_logic;
            en_reg_w            : out std_logic;
            rst_c               : out std_logic;
            en_counter_c        : out std_logic;
            en_mux              : out std_logic;
            sel_mux             : out std_logic;
            
            data_zero           : in std_logic;
            o_mem_en            : out std_logic;
            o_mem_we            : out std_logic;
            o_done              : out std_logic
        );
    end component fsm;
    
    component mux is
        Port (
            sel_mux             : in std_logic;
            en_mux              : in std_logic;
            out_w               : in std_logic_vector(7 downto 0);
            out_c               : in std_logic_vector(7 downto 0);
            o_mem_data          : out std_logic_vector(7 downto 0)
       );
    end component mux;
    
    component reg_w is
      Port (
            i_rst               : in std_logic;
            i_clk               : in std_logic;
            en_reg_w            : in std_logic;
            i_mem_data          : in std_logic_vector(7 downto 0);
            out_w               : out std_logic_vector(7 downto 0)
       );
    end component reg_w;
    
    --Addresses
    signal s_en_start_addr          : std_logic;
    signal s_en_counter_addr        : std_logic;
    signal s_final_addr             : std_logic_vector(15 downto 0);
    signal s_control_addr           : std_logic;
    signal s_o_counter_addr         : std_logic_vector(15 downto 0);
    --Counter C
    signal s_rst_c                  : std_logic;
    signal s_en_counter_c           : std_logic;
    signal s_out_c                  : std_logic_vector(7 downto 0);
    --Reg W
    signal s_en_reg_w               : std_logic;
    signal s_out_w                  : std_logic_vector(7 downto 0);
    --Mux
    signal s_en_mux                 : std_logic;
    signal s_sel_mux                : std_logic;
    --Comparator Data Zero
    signal s_data_zero              : std_logic;

begin

    comparator_addr_1 : comparator_addr port map(
            o_counter_addr      => s_o_counter_addr,
            final_addr          => s_final_addr,
            control_addr        => s_control_addr
       );
    
    comparator_data_zero_1 : comparator_data_zero port map(
            i_mem_data          => i_mem_data,
            data_zero           => s_data_zero
       );
    
    counter_addr_1 : counter_addr port map(
            i_clk               => i_clk,
            i_start             => i_start,
            en_start_addr       => s_en_start_addr,
            en_counter_addr     => s_en_counter_addr,
            i_add               => i_add,
            o_counter_addr      => s_o_counter_addr,
            o_mem_addr          => o_mem_addr
       );
    
    counter_c_1 : counter_c port map(
            i_clk               => i_clk,
            i_rst               => i_rst,
            rst_c               => s_rst_c,
            en_counter_c        => s_en_counter_c,
            out_c               => s_out_c
       );
       
    final_addr_1 : final_addr port map( 
            i_add               => i_add,
            i_k                 => i_k,
            final_addr          => s_final_addr
      );
       
    fsm_1 : fsm port map(        
            i_start             => i_start,
            i_clk               => i_clk,
            i_rst               =>  i_rst,
            
            en_start_addr       => s_en_start_addr,
            en_counter_addr     => s_en_counter_addr,
            control_addr        => s_control_addr,
            en_reg_w            => s_en_reg_w,
            rst_c               => s_rst_c,
            en_counter_c        => s_en_counter_c,
            en_mux              => s_en_mux,
            sel_mux             => s_sel_mux,
            
            data_zero           => s_data_zero,
            o_mem_en            => o_mem_en,
            o_mem_we            => o_mem_we,
            o_done              => o_done
        );
     
     
    mux_1 : mux port map(
            sel_mux             => s_sel_mux,
            en_mux              => s_en_mux,
            out_w               => s_out_w,
            out_c               => s_out_c,
            o_mem_data          => o_mem_data
       );
    
    reg_w_1 : reg_w port map(
            i_rst               => i_rst,
            i_clk               => i_clk,
            en_reg_w            => s_en_reg_w,
            i_mem_data          => i_mem_data,
            out_w               => s_out_w
       );
 
end project_reti_logiche_arch;


--Comparator Address
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator_addr is
    Port (
        o_counter_addr          : in std_logic_vector(15 downto 0);
        final_addr              : in std_logic_vector(15 downto 0);
        control_addr            : out std_logic
   );
end comparator_addr;

architecture comparator_addr_arch of comparator_addr is
begin
    process(o_counter_addr, final_addr)
    begin
        if (o_counter_addr >= final_addr) then
            control_addr <= '1';
        else 
            control_addr <= '0';
        end if;
    end process;
end comparator_addr_arch;


--Comparator Data Zero
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator_data_zero is
    Port (
        i_mem_data              : in std_logic_vector(7 downto 0);
        data_zero               : out std_logic
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


--Counter Address
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity counter_addr is
    Port (
        i_clk                   : in std_logic;
        i_start                 : in std_logic;
        en_start_addr           : in std_logic;
        en_counter_addr         : in std_logic;
        i_add                   : in std_logic_vector(15 downto 0);
        o_counter_addr          : out std_logic_vector(15 downto 0);
        o_mem_addr              : out std_logic_vector(15 downto 0)
   );
end counter_addr;

architecture counter_addr_arch of counter_addr is
    signal temp_addr: std_logic_vector(15 downto 0) := (others => '0');
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (en_start_addr = '1' and i_start = '1') then
                temp_addr <= i_add;
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


--Counter C
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity counter_c is
  Port (
        i_clk                   : in std_logic;
        i_rst                   : in std_logic;
        rst_c                   : in std_logic;
        en_counter_c            : in std_logic;
        out_c                   : out std_logic_vector(7 downto 0)
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
            end if;
        end if;
     end process;
end counter_c_arch;


--Final Address
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity final_addr is
  Port ( 
        i_add                   : in std_logic_vector(15 downto 0);
        i_k                     : in std_logic_vector(9 downto 0);
        final_addr              : out std_logic_vector(15 downto 0)
  );
end final_addr;

architecture final_addr_arch of final_addr is
begin
    process(i_add, i_k)
    begin
        final_addr <= std_logic_vector(unsigned(i_add) + unsigned(i_k) + unsigned(i_k)); --Confrontiamo l'indirizzo dopo che è stato incrementato
    end process;
end final_addr_arch;


--FSM
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is
    Port(
        i_start                 : in std_logic;
        i_clk                   : in std_logic;
        i_rst                   : in std_logic;
        
        en_start_addr           : out std_logic;
        en_counter_addr         : out std_logic;
        control_addr            : in std_logic;
        en_reg_w                : out std_logic;
        rst_c                   : out std_logic;
        en_counter_c            : out std_logic;
        en_mux                  : out std_logic;
        sel_mux                 : out std_logic;
        
        data_zero               : in std_logic;
        o_mem_en                : out std_logic;
        o_mem_we                : out std_logic;
        o_done                  : out std_logic
    );
end fsm;

architecture fsm_arch of fsm is
    type S is (WAIT_START, WAIT_ADD, READING_PREFIX_W_C, WAITING_DELAY_PREFIX_W_C, READ_PREFIX_W_C, NEXT_ADDR_CASE_0, CONTROL_CASE_0, NEXT_ADDR_PREFIX, COPY_W, W_TO_CRED_31, WRITE_CRED, CONTROL, CRED_TO_W, WAITING_DELAY_W,READ_W, NEXT_ADDR, WRITE_SAVED_W, W_TO_CRED_DEC, DONE );
    signal curr_state, next_state   : S;
begin
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            curr_state <= WAIT_START;
        elsif (i_clk'event and i_clk = '1') then
            case curr_state is
                when WAIT_START =>
                    if i_start = '1' then
                        curr_state <= WAIT_ADD;
                    else
                        curr_state <= WAIT_START;
                    end if;
                when WAIT_ADD =>
                        curr_state <= READING_PREFIX_W_C;
                when READING_PREFIX_W_C =>
                    curr_state <= WAITING_DELAY_PREFIX_W_C;
                when WAITING_DELAY_PREFIX_W_C =>
                    curr_state <= READ_PREFIX_W_C;
                when READ_PREFIX_W_C =>
                    if data_zero = '1' then
                        curr_state <= NEXT_ADDR_CASE_0;
                    else
                        curr_state <= COPY_W;
                    end if;
                when NEXT_ADDR_CASE_0 =>
                    curr_state <= CONTROL_CASE_0;
                when CONTROL_CASE_0 =>
                    if control_addr = '0' then
                        curr_state <= NEXT_ADDR_PREFIX;
                    else
                        curr_state <= DONE;
                    end if;
                when NEXT_ADDR_PREFIX =>
                    curr_state <= READ_PREFIX_W_C;
                when COPY_W =>
                    curr_state <= W_TO_CRED_31;
                when W_TO_CRED_31 =>
                    curr_state <= WRITE_CRED;
                when WRITE_CRED =>
                    curr_state <= CONTROL;
                when CONTROL =>
                    if control_addr = '0' then
                        curr_state <= CRED_TO_W;
                    else
                        curr_state <= DONE;
                    end if;
                when CRED_TO_W =>
                    curr_state <= WAITING_DELAY_W;
                when WAITING_DELAY_W =>
                    curr_state <= READ_W;
                when READ_W =>
                    if data_zero = '1' then
                        curr_state <= WRITE_SAVED_W;
                    else
                        curr_state <= NEXT_ADDR;
                    end if;
                when NEXT_ADDR =>
                     curr_state <= COPY_W;
                when WRITE_SAVED_W =>
                    curr_state <= W_TO_CRED_DEC;
                when W_TO_CRED_DEC =>
                    curr_state <= WRITE_CRED;
                when DONE =>
                    if i_start = '0' then
                        curr_state <= WAIT_START;
                    else
                        curr_state <= DONE;
                    end if;
            end case;
        end if;
    end process;
    
    process(curr_state)
    begin
        en_mux <= '0';
        sel_mux <= '0';
        en_start_addr <= '0';
        en_counter_addr <= '0';
        en_reg_w <= '0';
        en_counter_c <= '0';
        rst_c <= '0';
        o_done <= '0';
        o_mem_en <= '0';
        o_mem_we <= '0';
        case curr_state is
            when WAIT_ADD =>
                en_start_addr <= '1';
            when READING_PREFIX_W_C =>
                o_mem_en <= '1';
            when READ_PREFIX_W_C =>
                en_counter_addr <= '1';
            --when NEXT_ADDR_CASE_0 => --Non ci serve controllare che sia effettivamente zero perché da specifica è sempre pari a 0
                --o_mem_en <= '1';
            when CONTROL_CASE_0 =>
                en_counter_addr <= '1';
            when NEXT_ADDR_PREFIX =>
                o_mem_en <= '1';
            when COPY_W =>
                en_reg_w <= '1';
            when W_TO_CRED_31 =>
                en_mux <= '1'; --Abilitiamo e selezioniamo in anticipo per evitare ritardi
                sel_mux <= '1'; --Abilitiamo e selezioniamo in anticipo per evitare ritardi
                rst_c <= '1';
            when WRITE_CRED =>
                en_mux <= '1';
                sel_mux <= '1';
                o_mem_en <= '1';
                o_mem_we <= '1';
            when CONTROL =>
                en_counter_addr <= '1';
            when CRED_TO_W =>
                o_mem_en <= '1';
            when READ_W =>
                en_mux <= '1'; --Abilitiamo e selezioniamo in anticipo per evitare ritardi
                --sel_mux <= '0'; --Abilitiamo e selezioniamo in anticipo per evitare ritardi
            when NEXT_ADDR =>
                en_counter_addr <= '1';
            when WRITE_SAVED_W =>
                en_mux <= '1';
                --sel_demux <= '0';
                o_mem_en <= '1';
                o_mem_we <= '1';
            when W_TO_CRED_DEC =>
                en_mux <= '1'; --Abilitiamo e selezioniamo in anticipo per evitare ritardi
                sel_mux <= '1'; --Abilitiamo e selezioniamo in anticipo per evitare ritardi
                en_counter_addr <= '1';
                en_counter_c <= '1'; --A differenza di prima qua decrementiamo anche questo
            when DONE =>
                o_done <= '1';
            when others =>
                en_mux <= '0';
                sel_mux <= '0';
                en_start_addr <= '0';
                en_counter_addr <= '0';
                en_reg_w <= '0';
                en_counter_c <= '0';
                rst_c <= '0';
                o_done <= '0';
                o_mem_en <= '0';
                o_mem_we <= '0';
        end case;
    end process;
end fsm_arch;


--Mutex
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    Port (
        sel_mux                 : in std_logic;
        en_mux                  : in std_logic;
        out_w                   : in std_logic_vector(7 downto 0);
        out_c                   : in std_logic_vector(7 downto 0);
        o_mem_data              : out std_logic_vector(7 downto 0)
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
        end if;
    end process;
end mux_arch;


--Register W
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_w is
  Port (
        i_rst                   : in std_logic;
        i_clk                   : in std_logic;
        en_reg_w                : in std_logic;
        i_mem_data              : in std_logic_vector(7 downto 0);
        out_w                   : out std_logic_vector(7 downto 0)
   );
end reg_w;

architecture reg_w_arch of reg_w is
begin
    process(i_rst, i_clk)
    begin
        if(i_rst = '1') then
            out_w <= (others => '0');
        elsif (i_clk'event and i_clk = '1') then
            if (en_reg_w = '1') then
                out_w <= i_mem_data;
            end if;
        end if;
    end process;
end reg_w_arch;