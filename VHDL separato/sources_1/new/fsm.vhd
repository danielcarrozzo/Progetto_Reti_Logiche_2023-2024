library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is
    Port(
        i_start         : in std_logic;
        i_clk           : in std_logic;
        i_rst           : in std_logic;
        
        en_start_addr   : out std_logic;
        en_counter_addr : out std_logic;
        control_addr    : in std_logic;
        en_reg_w        : out std_logic;
        rst_c           : out std_logic;
        en_counter_c    : out std_logic;
        en_mux          : out std_logic;
        sel_mux         : out std_logic;
        
        data_zero       : in std_logic;
        o_mem_en        : out std_logic;
        o_mem_we        : out std_logic;
        o_done          : out std_logic
    );
end fsm;

architecture fsm_arch of fsm is
type S is (WAIT_START, WAIT_ADD, READING_PREFIX_W_C, WAITING_DELAY_PREFIX_W_C, READ_PREFIX_W_C, NEXT_ADDR_CASE_0, CONTROL_CASE_0, NEXT_ADDR_PREFIX, COPY_W, W_TO_CRED_31, WRITE_CRED_31, CONTROL, CRED_TO_W, WAITING_DELAY_W,READ_W, NEXT_ADDR, WRITE_SAVED_W, W_TO_CRED_DEC, WRITE_CRED_DEC, DONE );
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
                    curr_state <= WRITE_CRED_31;
                when WRITE_CRED_31 =>
                    curr_state <= CONTROL;
                when CONTROL =>
                    if control_addr = '0' then-- eventualmente mettere in una variabile
                        curr_state <= CRED_TO_W;
                    else
                        curr_state <= DONE;
                    end if;
                when CRED_TO_W =>
                    curr_state <= WAITING_DELAY_W;
                when WAITING_DELAY_W =>
                    curr_state <= READ_W;
                when READ_W =>
                    if data_zero = '1' then --TODO qua forse registro
                        curr_state <= WRITE_SAVED_W;
                    else
                        curr_state <= NEXT_ADDR;
                    end if;
                when NEXT_ADDR =>
                     curr_state <= COPY_W;
                when WRITE_SAVED_W =>
                    curr_state <= W_TO_CRED_DEC;
                when W_TO_CRED_DEC =>
                    curr_state <= WRITE_CRED_DEC;      
                when WRITE_CRED_DEC =>
                    curr_state <= CONTROL;
                when DONE =>
                    if i_start = '0' then
                        curr_state <= WAIT_START;
                    else
                        curr_state <= DONE;
                    end if;
            end case;
        end if;
    end process;
    
    -- persistenza:
    --         -         Scrittura memoria
    -- --------|---      enable dei mutex agiscono anche se la memoria ha ritardo
    -- /---\___/---\___
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
            when NEXT_ADDR_CASE_0 =>
                o_mem_en <= '1';
            when CONTROL_CASE_0 =>
                en_counter_addr <= '1';
            when NEXT_ADDR_PREFIX =>
                o_mem_en <= '1';
            when COPY_W =>
                en_reg_w <= '1';
            when W_TO_CRED_31 =>
                en_mux <= '1';
                sel_mux <= '1';
                rst_c <= '1';
            when WRITE_CRED_31 =>
                en_mux <= '1';-- persistenza
                sel_mux <= '1';--persistenza
                o_mem_en <= '1';
                o_mem_we <= '1';
            when CONTROL =>
                en_counter_addr <= '1';
            when CRED_TO_W =>
                o_mem_en <= '1';
            when READ_W =>
                en_mux <= '1';--non è il top ma vabbè
                --sel_mux <= '0';
            when NEXT_ADDR =>
                en_counter_addr <= '1';
            when WRITE_SAVED_W =>
                en_mux <= '1';--persistenza
                --sel_demux <= '0';--persistenza
                o_mem_en <= '1';
                o_mem_we <= '1';
            when W_TO_CRED_DEC =>
                en_mux <= '1';
                sel_mux <= '1';
                en_counter_addr <= '1';
                en_counter_c <= '1';--a differenza di prima qua decrementiamo anche questo
            when WRITE_CRED_DEC =>
                en_mux <= '1';--persistenza
                sel_mux <= '1';--persistenza
                o_mem_en <= '1';
                o_mem_we <= '1';
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
