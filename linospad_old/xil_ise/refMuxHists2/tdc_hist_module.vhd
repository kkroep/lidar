LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tdc_hist_module IS
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
END ENTITY tdc_hist_module;

ARCHITECTURE arch OF tdc_hist_module IS
    SIGNAL pixel_mux_sel_reg : unsigned(1 DOWNTO 0);
    SIGNAL trigger : std_logic;
    
    COMPONENT tdc_core IS
        GENERIC(
            TDC_MAX_CODE : integer );
        PORT(
            SIGNAL trigger      : IN    std_logic;
            SIGNAL clk_tdc      : IN    std_logic;

            SIGNAL clk_mod      : IN    std_logic;
            SIGNAL clk_mul      : IN    std_logic_vector(1 DOWNTO 0);
            SIGNAL valid_out    : OUT   std_logic;
            SIGNAL code_out     : OUT   std_logic_vector(10 DOWNTO 0) );
    END COMPONENT tdc_core;
    
    SIGNAL s_red_valid : std_logic;
    SIGNAL s_red_code : std_logic_vector(10 DOWNTO 0);
    SIGNAL clk_mul_reg : std_logic_vector(1 DOWNTO 0);
    
    TYPE t_correction IS ARRAY (0 TO 4) OF unsigned(9 DOWNTO 0);
    CONSTANT monotonous : t_correction := (
        0 => to_unsigned(TDC_MAX_CODE,10),
        1 => to_unsigned((2*(TDC_MAX_CODE+1))-1,10),
        2 => to_unsigned((3*(TDC_MAX_CODE+1))-1,10),
        3 => to_unsigned((4*(TDC_MAX_CODE+1))-1,10),
        4 => to_unsigned((5*(TDC_MAX_CODE+1))-1,10) );
    SIGNAL s_red_valid_reg : std_logic;
    SIGNAL s_red_code_reg : unsigned(9 DOWNTO 0);
    
    SIGNAL clk_ref_en_reg : std_logic;
    SIGNAL s_ref_increment : unsigned(9 DOWNTO 0);
    SIGNAL s_ref_counter_reg : unsigned(27 DOWNTO 0);
    SIGNAL tdc_config_reg : std_logic_vector(3 DOWNTO 0) := (OTHERS=>'0');
    TYPE pixel_delay_offset_array_t IS ARRAY (3 DOWNTO 0) OF unsigned(11 DOWNTO 0);
    SIGNAL pixel_delay_offset_reg : pixel_delay_offset_array_t := (OTHERS=>(OTHERS=>'0'));
    SIGNAL global_offset_reg : unsigned(4 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_ref_code_reg : unsigned(27 DOWNTO 0);
    SIGNAL s_ref_valid_reg : std_logic;
    SIGNAL s_hist_inc_addr : unsigned(9 DOWNTO 0);
    
    COMPONENT hist_tdc IS
        PORT(
            SIGNAL clk      : IN    std_logic;
            SIGNAL switch   : IN    std_logic;
            SIGNAL stw      : IN    std_logic;
            SIGNAL stw_addr : IN    std_logic_vector(27 DOWNTO 0);
            SIGNAL inc      : IN    std_logic;
            SIGNAL inc_addr : IN    std_logic_vector(9 DOWNTO 0);
            SIGNAL get      : IN    std_logic;
            SIGNAL get_addr : IN    std_logic_vector(8 DOWNTO 0);
            SIGNAL count    : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL valid    : OUT   std_logic
        );
    END COMPONENT hist_tdc;
    SIGNAL hist_acq_reg, hist_switch_reg, s_hist_inc, s_hist_store, s_store_valid_reg : std_logic;
    SIGNAL hist_length_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'1');
    SIGNAL hist_read_next_reg : std_logic;
    SIGNAL s_hist_count, hist_count_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_hist_valid, hist_count_valid_reg : std_logic := '0';
    SIGNAL hist_stall_reg : std_logic;
    SIGNAL hist_get_idle_reg, hist_idle_reg : std_logic := '1';
    SIGNAL s_hist_next_triggered_reg, s_hist_readout_done_reg : std_logic := '1';
    SIGNAL s_hist_get_reg, s_hist_get_last_reg, s_hist_read_end_reg : std_logic := '0';
    SIGNAL s_hist_get_addr_reg : unsigned(8 DOWNTO 0);

BEGIN    
    chainregs : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            pixel_mux_sel_reg <= unsigned(pixel_mux_sel);
            clk_mul_reg <= clk_mul_in;
            
            IF config_load_in = '1' THEN
                tdc_config_reg <= tdc_config_reg(2 DOWNTO 0)&tdc_config_in;
                pixel_delay_offset_reg(3 DOWNTO 1) <= pixel_delay_offset_reg(2 DOWNTO 0);
                pixel_delay_offset_reg(0) <= unsigned(pixel_delay_offset_in);
            END IF;
            tdc_config_out <= tdc_config_reg(3);
            pixel_delay_offset_out <= std_logic_vector(pixel_delay_offset_reg(3));
            config_load_out <= config_load_in;
            
            clk_ref_en_reg <= clk_ref_en;
            global_offset_reg <= unsigned(global_offset_in);
            
            hist_acq_reg <= hist_acq;
            hist_switch_reg <= hist_switch;
            hist_length_reg <= unsigned(hist_length_in);
            hist_stall_reg <= hist_stall;
        END IF;
    END PROCESS chainregs;
    clk_mul_out <= clk_mul_reg;
    global_offset_out <= std_logic_vector(global_offset_reg);
    hist_length_out <= std_logic_vector(hist_length_reg);
    hist_read_out <= hist_read_next_reg;
    hist_count_out <= hist_count_reg;
    hist_count_valid_out <= hist_count_valid_reg;
    hist_idle_out <= hist_idle_reg;
    
    mux : trigger <= pixel_inputs(to_integer(pixel_mux_sel_reg));
    
    make_tdc : IF NOT IS_DUMMY GENERATE
        core : tdc_core
        GENERIC MAP(
            TDC_MAX_CODE => TDC_MAX_CODE )
        PORT MAP(
            trigger => trigger,
            clk_tdc => clk_tdc,
            clk_mod => clk_mod,
            clk_mul => clk_mul_reg,
            valid_out => s_red_valid,
            code_out => s_red_code );
    END GENERATE make_tdc;
    
    make_dummy : IF IS_DUMMY GENERATE
        s_red_valid <= '1';
        s_red_code <= "00001000000";
    END GENERATE make_dummy;
    
    make_red_correction : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            s_red_code_reg <= monotonous(to_integer(unsigned(s_red_code(10 DOWNTO 8))))-unsigned(s_red_code(7 DOWNTO 0));
            s_red_valid_reg <= s_red_valid;
        END IF;
    END PROCESS make_red_correction;
    
    WITH clk_mul_reg SELECT s_ref_increment <= 
        to_unsigned((3*(TDC_MAX_CODE+1)),10) WHEN "00",
        to_unsigned((4*(TDC_MAX_CODE+1)),10) WHEN "01",
        to_unsigned((5*(TDC_MAX_CODE+1)),10) WHEN OTHERS;

    ref_code : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF clk_ref_en_reg = '1' THEN
                s_ref_counter_reg <= (OTHERS=>'0');
            ELSE
                s_ref_counter_reg <= s_ref_counter_reg + s_ref_increment;
            END IF;
            s_ref_code_reg <= s_ref_counter_reg +
                ( ("00"&s_red_code_reg) + pixel_delay_offset_reg(to_integer(pixel_mux_sel_reg)) + (global_offset_reg&"0000000") );
            IF hist_acq_reg = '1' AND s_red_valid_reg = '1' THEN
                s_ref_valid_reg <= NOT tdc_config_reg(0);
                s_store_valid_reg <= tdc_config_reg(0);
            ELSE
                s_ref_valid_reg <= '0';
                s_store_valid_reg <= '0';
            END IF;
        END IF;
    END PROCESS ref_code;
    
    s_hist_inc <= s_ref_valid_reg WHEN s_ref_code_reg(11 DOWNTO 10) = "00" OR tdc_config_reg(1) = '1' ELSE '0';
    s_hist_inc_addr <= s_ref_code_reg(11 DOWNTO 2) WHEN tdc_config_reg(1) = '1' ELSE s_ref_code_reg(9 DOWNTO 0);
    s_hist_store <= s_store_valid_reg;
    hist_module : hist_tdc PORT MAP(
        clk => clk_mod,
        switch => hist_switch_reg,
        stw => s_hist_store,
        stw_addr => std_logic_vector(s_ref_code_reg),
        inc => s_hist_inc,
        inc_addr => std_logic_vector(s_hist_inc_addr),
        get => s_hist_get_reg,
        get_addr => std_logic_vector(s_hist_get_addr_reg),
        count => s_hist_count,
        valid => s_hist_valid );
    
    hist_output : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF hist_switch_reg = '1' THEN
                --abort readout
                s_hist_get_reg <= '0';
                s_hist_readout_done_reg <= '1';
            ELSIF hist_read_in = '1' THEN
                s_hist_get_addr_reg <= (OTHERS=>'0');
                s_hist_read_end_reg <= '0';
                s_hist_get_last_reg <= '0';
                s_hist_next_triggered_reg <= '0';
                --start readout
                s_hist_get_reg <= NOT hist_stall_reg;
                s_hist_readout_done_reg <= '0';
            ELSIF s_hist_readout_done_reg = '0' THEN
                --continue readout
                s_hist_get_reg <= (NOT hist_stall_reg) OR s_hist_read_end_reg;
                IF s_hist_get_reg = '1' THEN
                    s_hist_get_addr_reg <= s_hist_get_addr_reg + 1;
                    IF s_hist_get_addr_reg = hist_length_reg - 3 THEN
                        s_hist_read_end_reg <= '1';
                    END IF;
                    IF s_hist_get_addr_reg = hist_length_reg - 1 THEN
                        s_hist_get_last_reg <= '1';
                    END IF;
                    IF s_hist_get_last_reg = '1' THEN
                        s_hist_get_reg <= '0';
                        s_hist_readout_done_reg <= '1';
                    END IF;
                END IF;
            END IF;
            
            IF tdc_config_reg(0) = '1' AND tdc_config_reg(2) = '1' AND s_hist_valid = '1' AND s_hist_count(31) = '0' THEN
                s_hist_read_end_reg <= '1';
                s_hist_get_last_reg <= '1';
            END IF;
            
            --trigger next module
            IF
                (s_hist_read_end_reg = '1' AND s_hist_next_triggered_reg = '0') --start next
            THEN
                s_hist_next_triggered_reg <= '1';
                hist_read_next_reg <= '1';
            ELSE
                hist_read_next_reg <= '0';
            END IF;
            
            --generate idle
            IF hist_switch_reg = '1' OR hist_read_in = '1' THEN
                hist_idle_reg <= '0';
                hist_get_idle_reg <= '0';
            ELSIF hist_read_next_reg = '1' THEN
                hist_get_idle_reg <= '1';
            ELSIF hist_get_idle_reg = '1' THEN
                hist_idle_reg <= hist_idle_in;
            END IF;
            
            --forward output
            IF (s_hist_valid = '1' AND (tdc_config_reg(2) = '0' OR s_hist_get_last_reg = '0'))  OR hist_count_valid_in = '1' THEN
                hist_count_valid_reg <= '1';
            ELSE
                hist_count_valid_reg <= '0';
            END IF;
            IF s_hist_valid = '1' THEN
                hist_count_reg <= s_hist_count;
            ELSE
                hist_count_reg <= hist_count_in;
            END IF;
        END IF;
    END PROCESS hist_output;
END ARCHITECTURE arch;

