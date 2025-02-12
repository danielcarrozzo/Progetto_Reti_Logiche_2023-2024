library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port(
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_add : in std_logic_vector(15 downto 0);
    i_k : in std_logic_vector(9 downto 0);
    
    o_done : out std_logic;
    
    o_mem_addr : out std_logic_vector(15 downto 0);
    i_mem_data : in  std_logic_vector(7 downto 0);
    o_mem_data : out std_logic_vector(7 downto 0);
    o_mem_we   : out std_logic;
    o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

    component comparator is
        Port (
            o_counter_addr : in std_logic_vector(15 downto 0);
            final_addr      : in std_logic_vector(15 downto 0);
            control_addr    : out std_logic
       );
    end component comparator;
    
    component comparator_data_zero is
        Port (
            i_mem_data   : in std_logic_vector(7 downto 0);
            data_zero    : out std_logic
       );
    end component comparator_data_zero;
    
    component counter_addr is
        Port (
            i_clk               : in std_logic;
            i_start               : in std_logic;
            en_start_addr       : in std_logic;
            en_counter_addr     : in std_logic;
            i_add_reg            : in std_logic_vector(15 downto 0);
            o_counter_addr             : out std_logic_vector(15 downto 0);
            o_mem_addr  : out std_logic_vector(15 downto 0)
       );
    end component counter_addr;
    
    component counter_c is
      Port (
            i_clk        : in std_logic;
            i_rst        : in std_logic;
            rst_c        : in std_logic;
            en_counter_c : in std_logic;
            out_c        : out std_logic_vector(7 downto 0)
       );
    end component counter_c;
    
    component final_addr is
      Port ( 
            i_add : in std_logic_vector(15 downto 0);
            i_k : in std_logic_vector(9 downto 0);
            final_addr : out std_logic_vector(15 downto 0)
      );
    end component final_addr;
    
    component fsm is
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
    end component fsm;
    
    component mux is
        Port (
            sel_mux     : in std_logic;
            en_mux      : in std_logic;
            out_w       : in std_logic_vector(7 downto 0);
            out_c       : in std_logic_vector(7 downto 0);
            o_mem_data  : out std_logic_vector(7 downto 0)
       );
    end component mux;
    
    component reg_w is
      Port (
            i_rst       : in std_logic;
            i_clk       : in std_logic;
            en_reg_w    : in std_logic;
            i_mem_data  : in std_logic_vector(7 downto 0);
            out_w       : out std_logic_vector(7 downto 0)
       );
    end component reg_w;
    
--Addresses
signal s_en_start_addr : std_logic;
signal s_en_counter_addr : std_logic;
signal s_final_addr : std_logic_vector(15 downto 0);
signal s_control_addr : std_logic;
signal s_o_counter_addr : std_logic_vector(15 downto 0);

--Counter C
signal s_rst_c : std_logic;
signal s_en_counter_c : std_logic;
signal s_out_c : std_logic_vector(7 downto 0);
--Reg W
signal s_en_reg_w : std_logic;
signal s_out_w : std_logic_vector(7 downto 0);
--Mux
signal s_en_mux : std_logic;
signal s_sel_mux : std_logic;
--Comparator
signal s_data_zero : std_logic;

begin

    comparator_1 : comparator port map(
            o_counter_addr  => s_o_counter_addr,
            final_addr      => s_final_addr,
            control_addr    => s_control_addr
       );
    
    comparator_data_zero_1 : comparator_data_zero port map(
            i_mem_data      => i_mem_data,
            data_zero       => s_data_zero
       );
    
    counter_addr_1 : counter_addr port map(
            i_clk                => i_clk,
            i_start              => i_start,
            en_start_addr        => s_en_start_addr,
            en_counter_addr      => s_en_counter_addr,
            i_add_reg            => i_add,--we are not using register anymore
            o_counter_addr       => s_o_counter_addr,
            o_mem_addr           => o_mem_addr
       );
    
    counter_c_1 : counter_c port map(
            i_clk        => i_clk,
            i_rst        => i_rst,
            rst_c        => s_rst_c,
            en_counter_c => s_en_counter_c,
            out_c        => s_out_c
       );
       
    final_addr_1 : final_addr port map( 
            i_add       => i_add,
            i_k         => i_k,
            final_addr  => s_final_addr
      );
       
    fsm_1 : fsm port map(        
            i_start         => i_start,
            i_clk           => i_clk,
            i_rst           =>  i_rst,
            
            en_start_addr   => s_en_start_addr,
            en_counter_addr => s_en_counter_addr,
            control_addr    => s_control_addr,
            en_reg_w        => s_en_reg_w,
            rst_c           => s_rst_c,
            en_counter_c    => s_en_counter_c,
            en_mux          => s_en_mux,
            sel_mux         => s_sel_mux,
            
            data_zero      => s_data_zero,
            o_mem_en        => o_mem_en,
            o_mem_we        => o_mem_we,
            o_done          => o_done
        );
     
     
    mux_1 : mux port map(
            sel_mux         => s_sel_mux,
            en_mux          => s_en_mux,
            out_w           => s_out_w,
            out_c           => s_out_c,
            o_mem_data      => o_mem_data
       );
    
    reg_w_1 : reg_w port map(
            i_rst       => i_rst,
            i_clk       => i_clk,
            en_reg_w    => s_en_reg_w,
            i_mem_data  => i_mem_data,
            out_w       => s_out_w
       );
 
end project_reti_logiche_arch;
