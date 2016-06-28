LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tdc_hist_module_tb IS
END ENTITY tdc_hist_module_tb;

ARCHITECTURE arch OF tdc_hist_module_tb IS
    SIGNAL reset : std_logic := '1';
    SIGNAL clk, clk_ref, clk_80MHz, clk_400MHz : std_logic := '1';

    SIGNAL sim_done : std_logic := '0';
    SIGNAL sim_words_in, sim_words_out : integer := 0;

    COMPONENT variable_clk_en IS
        PORT (
            SIGNAL clk_base                 : IN    std_logic;
            SIGNAL clk_mul                  : IN    std_logic;
            SIGNAL clk_mul_en_delay         : IN    std_logic_vector(2 DOWNTO 0);
            SIGNAL clk_mul_en               : OUT   std_logic
        );
    END COMPONENT variable_clk_en;
    COMPONENT tdc_hist_module IS
        GENERIC (
            CONSTANT IS_DUMMY                               :       boolean := FALSE;
            CONSTANT TDC_MAX_CODE                           :       integer := 139 --Code from 0 to TDC_MAX_CODE, chain length TDC_MAX_CODE+1 bits
        );
        PORT (
            SIGNAL clk_mod, clk_tdc                         : IN    std_logic;

            SIGNAL pixel_inputs                             : IN    std_logic_vector(3 DOWNTO 0);
            SIGNAL pixel_mux_sel                            : IN    std_logic_vector(1 DOWNTO 0);
            
            SIGNAL clk_mul_in                               : IN    std_logic_vector(1 DOWNTO 0);  --"00" = 1to3, "01" = 1to4, "11" = 1to5
            SIGNAL clk_mul_out                              : OUT   std_logic_vector(1 DOWNTO 0);

            SIGNAL clk_ref_en                               : IN    std_logic;

            SIGNAL tdc_config_in                            : IN    std_logic;
            SIGNAL tdc_config_out                           : OUT   std_logic;
            SIGNAL pixel_delay_offset_in                    : IN    std_logic_vector(11 DOWNTO 0);
            SIGNAL pixel_delay_offset_out                   : OUT   std_logic_vector(11 DOWNTO 0);
            SIGNAL config_load_in                           : IN    std_logic;
            SIGNAL config_load_out                          : OUT   std_logic;

            SIGNAL global_offset_in                         : IN    std_logic_vector(4 DOWNTO 0);
            SIGNAL global_offset_out                        : OUT   std_logic_vector(4 DOWNTO 0);

            SIGNAL hist_acq, hist_switch                    : IN    std_logic;
            SIGNAL hist_length_in                           : IN    std_logic_vector(8 DOWNTO 0);
            SIGNAL hist_length_out                          : OUT   std_logic_vector(8 DOWNTO 0);
            SIGNAL hist_read_in                             : IN    std_logic;
            SIGNAL hist_read_out                            : OUT   std_logic;
            SIGNAL hist_count_in                            : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL hist_count_out                           : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL hist_count_valid_in                      : IN    std_logic;
            SIGNAL hist_count_valid_out                     : OUT   std_logic;
            SIGNAL hist_stall                               : IN    std_logic;
            SIGNAL hist_idle_in                             : IN    std_logic;
            SIGNAL hist_idle_out                            : OUT   std_logic
        );
    END COMPONENT tdc_hist_module;
    
    SIGNAL pixel_inputs : std_logic_vector(7 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL pixel_mux_sel, clk_mul_in, clk_mul_out : std_logic_vector(1 DOWNTO 0) := "00";
    SIGNAL clk_ref_en : std_logic := '0';
    SIGNAL tdc_config_in, tdc_config_out, config_load_in, config_load_out : std_logic := '0';
    SIGNAL pixel_delay_offset_in, pixel_delay_offset_out : std_logic_vector(11 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL global_offset_in, global_offset_out : std_logic_vector(4 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL hist_acq, hist_switch, hist_read_in, hist_read_out, hist_stall : std_logic := '0';
    SIGNAL hist_length_in, hist_length_out : std_logic_vector(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL hist_count_in, hist_count_out : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL hist_count_valid_in, hist_count_valid_out, hist_idle_in, hist_idle_out : std_logic := '0';

BEGIN
    clk_80MHz <= NOT clk_80MHz AFTER 6.25 ns WHEN sim_done = '0';
    clk_400MHz <= NOT clk_400MHz AFTER 1.25 ns WHEN sim_done = '0';

    clk_ref <= clk_80MHz;
    clk <= clk_80MHz;

    MAIN : PROCESS
    BEGIN
        clk_mul_in <= "11";
        hist_length_in <= "000001000";
        WAIT FOR 100 ns;
        
        WAIT UNTIL falling_edge(clk);
        hist_acq <= '1';
        FOR i IN 0 TO 20 LOOP
            WAIT FOR 6.25 ns;
            pixel_inputs(0) <= '1';
            WAIT FOR 15 ns;
            pixel_inputs(0) <= '0';
            WAIT FOR 28.75 ns;
        END LOOP;
        WAIT UNTIL falling_edge(clk);
        hist_acq <= '0';
        
        WAIT UNTIL falling_edge(clk);
        hist_switch <= '1';
        WAIT UNTIL falling_edge(clk);
        hist_switch <= '0';

        WAIT UNTIL falling_edge(clk);
        hist_read_in <= '1';
        WAIT UNTIL falling_edge(clk);
        hist_read_in <= '0';
        
        WAIT UNTIL falling_edge(clk) AND hist_idle_out = '1';
        sim_done <= '1';
        WAIT;
    END PROCESS MAIN;

	STATS : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF hist_acq = '1' THEN
				sim_words_in <= sim_words_in + 1;
			END IF;
			IF hist_count_valid_out = '1' THEN
				sim_words_out <= sim_words_out + 1;
			END IF;
		END IF;
	END PROCESS STATS;

	DUT0 : tdc_hist_module
	GENERIC MAP(
	    IS_DUMMY => FALSE )
	PORT MAP(
	    clk_mod => clk_80MHz,
	    clk_tdc => clk_400MHz,
	    pixel_inputs => pixel_inputs(3 DOWNTO 0),
	    pixel_mux_sel => pixel_mux_sel,
	    clk_mul_in => clk_mul_in,
	    clk_mul_out => clk_mul_out,
	    clk_ref_en => clk_ref_en,
	    tdc_config_in => tdc_config_in,
	    tdc_config_out => tdc_config_out,
	    pixel_delay_offset_in => pixel_delay_offset_in,
	    pixel_delay_offset_out => pixel_delay_offset_out,
	    config_load_in => config_load_in,
	    config_load_out => config_load_out,
	    global_offset_in => global_offset_in,
	    global_offset_out => global_offset_out,
	    hist_acq => hist_acq,
	    hist_switch => hist_switch,
	    hist_length_in => hist_length_in,
	    hist_length_out => hist_length_out,
	    hist_read_in => hist_read_in,
	    hist_read_out => hist_read_out,
	    hist_count_in => hist_count_in,
	    hist_count_out => hist_count_out,
	    hist_count_valid_in => hist_count_valid_in,
	    hist_count_valid_out => hist_count_valid_out,
	    hist_stall => hist_stall,
	    hist_idle_in => hist_idle_in,
	    hist_idle_out => hist_idle_out
	);

	DUT1 : tdc_hist_module
	GENERIC MAP(
	    IS_DUMMY => FALSE )
	PORT MAP(
	    clk_mod => clk_80MHz,
	    clk_tdc => clk_400MHz,
	    pixel_inputs => pixel_inputs(7 DOWNTO 4),
	    pixel_mux_sel => pixel_mux_sel,
	    clk_mul_in => clk_mul_out,
	    clk_mul_out => OPEN,
	    clk_ref_en => clk_ref_en,
	    tdc_config_in => tdc_config_out,
	    tdc_config_out => OPEN,
	    pixel_delay_offset_in => pixel_delay_offset_out,
	    pixel_delay_offset_out => OPEN,
	    config_load_in => config_load_out,
	    config_load_out => OPEN,
	    global_offset_in => global_offset_out,
	    global_offset_out => OPEN,
	    hist_acq => hist_acq,
	    hist_switch => hist_switch,
	    hist_length_in => hist_length_out,
	    hist_length_out => OPEN,
	    hist_read_in => hist_read_out,
	    hist_read_out => OPEN,
	    --reverse
	    hist_count_in => X"00000000",
	    hist_count_out => hist_count_in,
	    hist_count_valid_in => '0',
	    hist_count_valid_out => hist_count_valid_in,
	    hist_stall => hist_stall,
	    hist_idle_in => '1',
	    hist_idle_out => hist_idle_in
	);

    enabler : variable_clk_en
    PORT MAP(
        clk_base => clk_ref,
        clk_mul => clk_80MHz,
        clk_mul_en_delay => "000",
        clk_mul_en => clk_ref_en );

END ARCHITECTURE arch;

