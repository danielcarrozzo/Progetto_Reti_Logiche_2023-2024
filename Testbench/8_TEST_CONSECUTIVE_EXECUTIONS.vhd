--- Esecuzioni consecutive multiple (3) ---

--- Librerie ---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

--- Definizione entità  ---
entity project_tb is
end project_tb;

--- Architettura TB ---
architecture project_tb_arch of project_tb is
    --- Segnali interni al TB ---
    constant CLOCK_PERIOD : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);
    signal tb_k   : std_logic_vector(9 downto 0);
    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;
    signal memory_control : std_logic := '0';
    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

	--- IMPORTANTE: Parametri di simulazione ---
		--- Simulazione 1 ---
    constant SCENARIO_LENGTH : integer := 10;
    type scenario_type is array (0 to SCENARIO_LENGTH*2-1) of integer;
	signal scenario_input : scenario_type := (51,  0,  0,  0, 57,  0, 24,  0,  0,  0, 24,  0, 126,  0,   0,  0, 192,  0,   0,  0);
	signal scenario_full  : scenario_type := (51, 31, 51, 30, 57, 31, 24, 31, 24, 30, 24, 31, 126, 31, 126, 30, 192, 31, 192, 30);    
    constant SCENARIO_ADDRESS : integer := 100;
		--- Simulazione 2 ---
	constant SCENARIO_LENGTH_2 : integer := 10;
    type scenario_type_2 is array (0 to SCENARIO_LENGTH_2*2-1) of integer;
	signal scenario_input_2 : scenario_type_2 := (255, 0 , 0  , 0 , 0  , 0 , 143, 0 , 0  , 0 , 0  , 0 , 0  , 0 , 0  , 0 , 0  , 0 , 0  , 0);
	signal scenario_full_2  : scenario_type_2 := (255, 31, 255, 30, 255, 29, 143, 31, 143, 30, 143, 29, 143, 28, 143, 27, 143, 26, 143, 25);
    constant SCENARIO_ADDRESS_2 : integer := 19;
		--- Simulazione 3 ---
	constant SCENARIO_LENGTH_3 : integer := 16;
    type scenario_type_3 is array (0 to SCENARIO_LENGTH_3*2-1) of integer;
	signal scenario_input_3 : scenario_type_3 := (255, 0 , 91, 0 , 161, 0 , 155, 0 , 178, 0 , 11, 0 , 83, 0 , 27, 0 , 57, 0 , 129, 0 , 39, 0 , 243, 0 , 158, 0 , 173, 0 , 134, 0 , 58, 0);
	signal scenario_full_3  : scenario_type_3 := (255, 31, 91, 31, 161, 31, 155, 31, 178, 31, 11, 31, 83, 31, 27, 31, 57, 31, 129, 31, 39, 31, 243, 31, 158, 31, 173, 31, 134, 31, 58, 31);    
    constant SCENARIO_ADDRESS_3 : integer := 994;

	--- Definizione componente in testing ---
    component project_reti_logiche is
        port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                o_done : out std_logic;
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
	--- Port mapping ---
    UUT : project_reti_logiche
    port map(
                i_clk   => tb_clk,
                i_rst   => tb_rst,
                i_start => tb_start,
                i_add   => tb_add,
                i_k     => tb_k,
                o_done => tb_done,
                o_mem_addr => exc_o_mem_addr,
                i_mem_data => tb_i_mem_data,
                o_mem_data => exc_o_mem_data,
                o_mem_we   => exc_o_mem_we,
                o_mem_en   => exc_o_mem_en
    );

    -- Generazione clock ---
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Implementazione della memoria ---
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
	--- Processo per passare il controllo delle porte tra testbench e componente ---
    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                    init_o_mem_en,  init_o_mem_we,   exc_o_mem_addr,
                                    exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en   <= init_o_mem_en;
        tb_o_mem_we   <= init_o_mem_we;
        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en   <= exc_o_mem_en;
            tb_o_mem_we   <= exc_o_mem_we;
        end if;
    end process;

    -- IMPORTANTE: Genera lo scenario ---
    create_scenario : process
    begin
		--- Aspetta 50ns prima di partire ---
        wait for 50 ns;
        --- Inizializza i segnali del TB ---
        tb_start <= '0';
        tb_add <= (others=>'0');
        tb_k   <= (others=>'0');
        tb_rst <= '1';
        -- Aspetta 50ns ---
        wait for 50 ns;
        --- Resetta il TB ---
        tb_rst <= '0';
        memory_control <= '0';
        --- IMPORTANTE: Copia i parametri forniti in memoria ---
        wait until falling_edge(tb_clk);
        for i in 0 to SCENARIO_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        wait until falling_edge(tb_clk);
        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_2(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
		wait until falling_edge(tb_clk);
        for i in 0 to SCENARIO_LENGTH_3*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_3(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
		--- IMPORTANTE: Inizia il test vero e proprio ---
        wait until falling_edge(tb_clk);
        memory_control <= '1'; --- Fornisco il controllo della memoria al componente
			--- Sessione 1 ---
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS, 16)); --- Fornisco i paramentri al componente
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH, 10)); --- Fornisco i paramentri al componente
        tb_start <= '1'; --- Dà il segnale di partenza al componente
        while tb_done /= '1' loop --- Attendo che il componente finisca. 5ns dopo il termine abbasso tb_start
            wait until rising_edge(tb_clk);
        end loop;
        wait for 5 ns;
        tb_start <= '0';
        wait for 20ns;
			--- Fine Sessione 1 ---
			--- Sessione 2 ---
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2, 16)); --- Fornisco i paramentri al componente
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_2, 10)); --- Fornisco i paramentri al componente
        tb_start <= '1'; --- Dà il segnale di partenza al componente
        while tb_done /= '1' loop --- Attendo che il componente finisca. 5ns dopo il termine abbasso tb_start
            wait until rising_edge(tb_clk);
        end loop;
        wait for 5 ns;
        tb_start <= '0';
        wait for 20ns;
			--- Fine Sessione 2 ---
			--- Sessione 3 ---
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3, 16)); --- Fornisco i paramentri al componente
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_3, 10)); --- Fornisco i paramentri al componente
        tb_start <= '1'; --- Dà il segnale di partenza al componente
        while tb_done /= '1' loop --- Attendo che il componente finisca. 5ns dopo il termine abbasso tb_start
            wait until rising_edge(tb_clk);
        end loop;
        wait for 5 ns;
        tb_start <= '0';
        wait for 20ns;
			--- Fine Sessione 3 ---
        wait;
    end process;

    -- IMPORTANTE: Controlla l'operato del componente ---
    test_routine : process
    begin
		--- Mi assicuro che, durante un reset, il componente non riporti di aver terminato il suo lavoro (1 ciclo di clock di tolleranza) ---
        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
        wait until tb_rst = '0';
		--- Mi assicuro che, dopo un reset, il componente non riporti di aver terminato il suo lavoro ancor prima che gli venga fornito il segnale di inizio ---
        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
			--- Sessione 1 ---
		--- Aspetto che il componente mi riporti di aver terminato l'esecuzione --- 
        wait until rising_edge(tb_start);
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		--- Mi assicuro che il componente, dopo aver terminato, non scriva in memoria ---
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST_1 FALLITO o_mem_en !=0 memory should not be written after done." severity failure;
		--- Controllo la correttezza dell'elaborazione ---
        for i in 0 to SCENARIO_LENGTH*2-1 loop
            assert RAM(SCENARIO_ADDRESS+i) = std_logic_vector(to_unsigned(scenario_full(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS+i)))) severity failure;
        end loop;
		--- Mi assicuro che il componente abbassi o_done dopo che il TB ha rimosso start. Probabile typo nell log ---
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST_1 FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);
        assert false report "Session 1 terminated! TEST 1/3 PASSED" severity note;
			--- Fine Sessione 1 ---
			--- Sessione 2 ---
		--- Aspetto che il componente mi riporti di aver terminato l'esecuzione --- 
        wait until rising_edge(tb_start);
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		--- Mi assicuro che il componente, dopo aver terminato, non scriva in memoria ---
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST_2 FALLITO o_mem_en !=0 memory should not be written after done." severity failure;
		--- Controllo la correttezza dell'elaborazione ---
        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            assert RAM(SCENARIO_ADDRESS_2+i) = std_logic_vector(to_unsigned(scenario_full_2(i),8)) report "TEST_2 FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_2(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_2+i)))) severity failure;
        end loop;
		--- Mi assicuro che il componente abbassi o_done dopo che il TB ha rimosso start. Probabile typo nell log ---
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST_2 FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);
        assert false report "Session 2 terminated! TEST 2/3 PASSED" severity note;
			--- Fine Sessione 2 ---
			--- Sessione 3 ---
		--- Aspetto che il componente mi riporti di aver terminato l'esecuzione --- 
        wait until rising_edge(tb_start);
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
		--- Mi assicuro che il componente, dopo aver terminato, non scriva in memoria ---
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST_3 FALLITO o_mem_en !=0 memory should not be written after done." severity failure;
		--- Controllo la correttezza dell'elaborazione ---
        for i in 0 to SCENARIO_LENGTH_3*2-1 loop
            assert RAM(SCENARIO_ADDRESS_3+i) = std_logic_vector(to_unsigned(scenario_full_3(i),8)) report "TEST_3 FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_3(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_3+i)))) severity failure;
        end loop;
		--- Mi assicuro che il componente abbassi o_done dopo che il TB ha rimosso start. Probabile typo nell log ---
        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST_3 FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);
        assert false report "Session 3 terminated! TEST 3/3 PASSED" severity note;
			--- Fine Sessione 3 ---

        assert false report "Simulation Ended! TEST PASSATO (MULTIPLE_CONSECUTIVE_EXECUTIONS)" severity failure;
    end process;

end architecture;