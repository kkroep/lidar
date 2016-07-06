LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tdc_array IS
    GENERIC (
        CONSTANT ADR        : std_logic_vector(3 DOWNTO 0)
    );
    PORT (
        SIGNAL clk_mod, reset           : IN    std_logic;
        SIGNAL usb_adr_in               : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_in              : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid        : IN    std_logic;
        SIGNAL usb_data_in_ack          : OUT   std_logic;
        SIGNAL usb_data_out             : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid       : OUT   std_logic;
        SIGNAL usb_data_out_busy        : IN    std_logic;
        SIGNAL usb_hold_pktend          : OUT   std_logic;
        
        SIGNAL trigger                  : IN    std_logic;
        SIGNAL clk_ref                  : IN    std_logic;
        SIGNAL clk_tdc                  : IN    std_logic;
        SIGNAL inputs                   : IN    std_logic_vector(255 DOWNTO 0)
   );
END ENTITY tdc_array;

ARCHITECTURE arch OF tdc_array IS
    COMPONENT variable_clk_en IS
        PORT (
            SIGNAL clk_base                 : IN    std_logic;
            SIGNAL clk_mul                  : IN    std_logic;
            SIGNAL clk_mul_en_delay         : IN    std_logic_vector(2 DOWNTO 0);
            SIGNAL clk_mul_en               : OUT   std_logic
        );
    END COMPONENT variable_clk_en;
    SIGNAL clk_ref_en_delay_reg : std_logic_vector(2 DOWNTO 0);
    SIGNAL clk_mul_en : std_logic;

    COMPONENT tdc_hist_module IS
        GENERIC(
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
    SIGNAL pixel_inputs : std_logic_vector(255 DOWNTO 0);
    SIGNAL mux_sel_reg : unsigned(1 DOWNTO 0);
    SIGNAL clk_mul_chain : std_logic_vector(65*2-1 DOWNTO 0);
    SIGNAL clk_ref_en : std_logic;
    SIGNAL tdc_config_chain : std_logic_vector(64 DOWNTO 0);
    SIGNAL pixel_delay_offset_chain : std_logic_vector(65*12-1 DOWNTO 0);
    SIGNAL config_load_chain : std_logic_vector(64 DOWNTO 0);
    SIGNAL global_offset_chain : std_logic_vector(65*5-1 DOWNTO 0);
    SIGNAL hist_acq_reg, hist_switch_reg : std_logic := '0';
    SIGNAL hist_length_chain : std_logic_vector(65*9-1 DOWNTO 0);
    SIGNAL hist_read_chain : std_logic_vector(64 DOWNTO 0);
    SIGNAL hist_count_chain : std_logic_vector(65*32-1 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL hist_count_valid_chain : std_logic_vector(64 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL hist_stall_reg : std_logic := '0';
    SIGNAL hist_idle_chain : std_logic_vector(64 DOWNTO 0) := (OTHERS=>'1');

    COMPONENT hist_equalizer IS
        PORT(
            SIGNAL clk                      : IN    std_logic;
            SIGNAL init                     : IN    std_logic;
            SIGNAL counts_in                : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL counts_in_valid          : IN    std_logic;
            SIGNAL counts_out               : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL counts_out_valid         : OUT   std_logic;
            SIGNAL cmd_mem_wr               : IN    std_logic;
            SIGNAL cmd_mem_wr_addr          : IN    std_logic_vector(13 DOWNTO 0);
            SIGNAL cmd_mem_wr_data          : IN    std_logic_vector(71 DOWNTO 0);
            SIGNAL tdc_coarse_count_max     : IN    std_logic_vector(2 DOWNTO 0);
            SIGNAL idle                     : OUT   std_logic
        );
    END COMPONENT hist_equalizer;
    SIGNAL s_eq_init : std_logic := '0';
    SIGNAL hist_counts_in_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL hist_counts_in_valid_reg : std_logic;
    SIGNAL s_eq_counts_in, s_eq_counts_out : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_eq_counts_in_valid, s_eq_counts_out_valid, s_eq_idle : std_logic;
    SIGNAL s_eq_cmd_mem_write : std_logic := '0';
    SIGNAL s_eq_cmd_mem_addr : std_logic_vector(13 DOWNTO 0);
    SIGNAL s_eq_cmd_mem_data : std_logic_vector(71 DOWNTO 0);
    SIGNAL s_eq_tdc_coarse_count_max_reg : std_logic_vector(2 DOWNTO 0);

    COMPONENT hist_rotate IS
        PORT(
            SIGNAL clk                      : IN    std_logic;
            SIGNAL init                     : IN    std_logic;
            SIGNAL counts_in                : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL counts_in_valid          : IN    std_logic;
            SIGNAL counts_out               : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL counts_out_valid         : OUT   std_logic;
            SIGNAL rot_mem_wr               : IN    std_logic;
            SIGNAL rot_mem_wr_addr          : IN    std_logic_vector(7 DOWNTO 0);
            SIGNAL rot_mem_wr_data          : IN    std_logic_vector(11 DOWNTO 0); --11 skip flag 10 zero flag 9:0 rotate amount
            SIGNAL hist_length              : IN    std_logic_vector(8 DOWNTO 0);
            SIGNAL idle                     : OUT   std_logic
        );
    END COMPONENT hist_rotate;
    SIGNAL s_pre_rot_init, s_post_rot_init : std_logic := '0';
    SIGNAL s_pre_rot_mem_wr, s_post_rot_mem_wr : std_logic := '0';
    SIGNAL s_pre_rot_mem_wr_addr, s_post_rot_mem_wr_addr : std_logic_vector(7 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_pre_rot_mem_wr_data, s_post_rot_mem_wr_data : std_logic_vector(11 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_pre_rot_hist_length, s_post_rot_hist_length : std_logic_vector(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_pre_rot_idle, s_post_rot_idle : std_logic;
    SIGNAL pre_rot_counts_in, pre_rot_counts_out, post_rot_counts_in, post_rot_counts_out : std_logic_vector(31 DOWNTO 0);
    SIGNAL pre_rot_counts_in_valid, pre_rot_counts_out_valid, post_rot_counts_in_valid, post_rot_counts_out_valid : std_logic;

    TYPE t_state IS (IDLE, ACQ_SAMPLES, SWITCH_MUX, WAIT_IDLE, DO_RESET, WAIT_SEND, WRITE_CMD_MEM, WAIT_TRIGGER, DELAY_TRIGGER);--, READ_INTENSITY);
    SIGNAL s_state_reg : t_state;
    SIGNAL s_mem_write_select_reg : std_logic_vector(2 DOWNTO 0);
    SIGNAL s_mem_write_counter_reg : unsigned(13 DOWNTO 0);
    SIGNAL s_mem_write_mod_counter_reg : unsigned(1 DOWNTO 0);
    SIGNAL s_sample_count_reg, s_sample_counter_reg : unsigned(27 DOWNTO 0);
    SIGNAL s_cycle_counter_reg : unsigned(15 DOWNTO 0);
    SIGNAL s_timeout_counter_reg : unsigned(3 DOWNTO 0) := (OTHERS=>'0');

    COMPONENT genfifo_fwft IS
        GENERIC(
            CONSTANT FIFOWIDTH              : natural := 32;
            CONSTANT LOG2_FIFODEPTH         : natural := 11 );
        PORT(
            SIGNAL clk, reset               : IN    std_logic;
            SIGNAL full, empty              : OUT   std_logic;
            SIGNAL wr, rd                   : IN    std_logic;
            SIGNAL data_in                  : IN    std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
            SIGNAL data_out                 : OUT   std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
            SIGNAL count                    : OUT   std_logic_vector(LOG2_FIFODEPTH DOWNTO 0) );
    END COMPONENT genfifo_fwft;
    SIGNAL out_fifo_empty, out_fifo_read, out_fifo_write : std_logic;
    SIGNAL out_fifo_readdata, out_fifo_writedata : std_logic_vector(31 DOWNTO 0);
    SIGNAL out_fifo_count : std_logic_vector(11 DOWNTO 0);
    SIGNAL s_usb_data_out_valid_reg : std_logic;
    SIGNAL s_usb_hold_pktend_main_reg, s_usb_hold_pktend_aux_reg : std_logic;

    SIGNAL s_aux_out_ack, s_aux_out_valid_reg : std_logic;
    SIGNAL s_aux_out_data_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_wait_cycles_counter_reg : unsigned(31 DOWNTO 0);
    SIGNAL s_data_counter_reg : unsigned(27 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_data_counter_zero_reg : std_logic := '0';
    
    SIGNAL s_use_slow_trigger_reg, s_use_slow_ref_reg, block_mux_reg, block_switch_reg, block_read_reg : std_logic := '0';
    SIGNAL s_trigger_delay_reg, s_delay_counter_reg : unsigned(27 DOWNTO 0);
BEGIN
    enabler : variable_clk_en
    PORT MAP(
        clk_base => clk_ref,
        clk_mul => clk_mod,
        clk_mul_en_delay => clk_ref_en_delay_reg,
        clk_mul_en => clk_mul_en );
    
    make_slow_trigger : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF s_use_slow_ref_reg = '1' THEN
                clk_ref_en <= trigger;
            ELSE
                clk_ref_en <= clk_mul_en;
            END IF;
        END IF;
    END PROCESS make_slow_trigger;
    
    tdc_array : FOR i IN 0 TO 63 GENERATE
    BEGIN
        pixel_inputs(i*4+3 DOWNTO i*4) <= inputs(i+192)&inputs(i+128)&inputs(i+64)&inputs(i);
        tdc : tdc_hist_module
            GENERIC MAP(
            IS_DUMMY => FALSE )
            PORT MAP(
            clk_mod => clk_mod,
            clk_tdc => clk_tdc,
            pixel_inputs => pixel_inputs(i*4+3 DOWNTO i*4),
            pixel_mux_sel => std_logic_vector(mux_sel_reg),
            clk_mul_in => clk_mul_chain(i*2+1 DOWNTO i*2),
            clk_mul_out => clk_mul_chain(i*2+3 DOWNTO i*2+2),
            clk_ref_en => clk_ref_en,
            tdc_config_in => tdc_config_chain(i),
            tdc_config_out => tdc_config_chain(i+1),
            pixel_delay_offset_in => pixel_delay_offset_chain(i*12+11 DOWNTO i*12),
            pixel_delay_offset_out => pixel_delay_offset_chain(i*12+23 DOWNTO i*12+12),
            config_load_in => config_load_chain(i),
            config_load_out => config_load_chain(i+1),
            global_offset_in => global_offset_chain(i*5+4 DOWNTO i*5),
            global_offset_out => global_offset_chain(i*5+9 DOWNTO i*5+5),
            hist_acq => hist_acq_reg,
            hist_switch => hist_switch_reg,
            hist_length_in => hist_length_chain(i*9+8 DOWNTO i*9),
            hist_length_out => hist_length_chain(i*9+17 DOWNTO i*9+9),
            hist_read_in => hist_read_chain(i),
            hist_read_out => hist_read_chain(i+1),
            hist_count_in => hist_count_chain(i*32+63 DOWNTO i*32+32),
            hist_count_out => hist_count_chain(i*32+31 DOWNTO i*32),
            hist_count_valid_in => hist_count_valid_chain(i+1),
            hist_count_valid_out => hist_count_valid_chain(i),
            hist_stall => hist_stall_reg,
            hist_idle_in => hist_idle_chain(i+1),
            hist_idle_out => hist_idle_chain(i) );
    END GENERATE tdc_array;
    
    make_processing_decouple : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            hist_counts_in_reg <= hist_count_chain(31 DOWNTO 0);
            hist_counts_in_valid_reg <= hist_count_valid_chain(0);
            s_pre_rot_hist_length <= hist_length_chain(64*9+8 DOWNTO 64*9);
        END IF;
    END PROCESS make_processing_decouple;
    
    pre_rotate : hist_rotate PORT MAP(
        clk => clk_mod,
        init => s_pre_rot_init,
        counts_in => hist_counts_in_reg,
        counts_in_valid => hist_counts_in_valid_reg,
        counts_out => pre_rot_counts_out,
        counts_out_valid => pre_rot_counts_out_valid,
        rot_mem_wr => s_pre_rot_mem_wr,
        rot_mem_wr_addr => s_pre_rot_mem_wr_addr,
        rot_mem_wr_data => s_pre_rot_mem_wr_data,
        hist_length => s_pre_rot_hist_length,
        idle => s_pre_rot_idle );
    
    make_rot_to_eq : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            s_eq_counts_in <= pre_rot_counts_out;
            s_eq_counts_in_valid <= pre_rot_counts_out_valid;
        END IF;
    END PROCESS make_rot_to_eq;
    
    equalizer : hist_equalizer PORT MAP(
        clk => clk_mod,
        init => s_eq_init,
        counts_in => s_eq_counts_in,
        counts_in_valid => s_eq_counts_in_valid,
        counts_out => s_eq_counts_out,
        counts_out_valid => s_eq_counts_out_valid,
        cmd_mem_wr => s_eq_cmd_mem_write,
        cmd_mem_wr_addr => s_eq_cmd_mem_addr,
        cmd_mem_wr_data => s_eq_cmd_mem_data,
        tdc_coarse_count_max => s_eq_tdc_coarse_count_max_reg,
        idle => s_eq_idle );
    
    make_eq_to_rot : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            post_rot_counts_in <= s_eq_counts_out;
            post_rot_counts_in_valid <= s_eq_counts_out_valid;
        END IF;
    END PROCESS make_eq_to_rot;
    
    post_rotate : hist_rotate PORT MAP(
        clk => clk_mod,
        init => s_post_rot_init,
        counts_in => post_rot_counts_in,
        counts_in_valid => post_rot_counts_in_valid,
        counts_out => post_rot_counts_out,
        counts_out_valid => post_rot_counts_out_valid,
        rot_mem_wr => s_post_rot_mem_wr,
        rot_mem_wr_addr => s_post_rot_mem_wr_addr,
        rot_mem_wr_data => s_post_rot_mem_wr_data,
        hist_length => s_post_rot_hist_length,
        idle => s_post_rot_idle );
    
    make_output_fifo_write : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF post_rot_counts_out_valid = '1' THEN
                out_fifo_write <= '1';
                out_fifo_writedata <= post_rot_counts_out;
            ELSE
                out_fifo_write <= '0';
                out_fifo_writedata <= (OTHERS=>'-');
            END IF;
        END IF;
    END PROCESS make_output_fifo_write;
    
    hist_out_fifo : genfifo_fwft
        GENERIC MAP( FIFOWIDTH => 32, LOG2_FIFODEPTH => 11 )
        PORT MAP( clk => clk_mod, reset => reset,
            full => OPEN,
            empty => out_fifo_empty,
            wr => out_fifo_write,
            rd => out_fifo_read,
            data_in => out_fifo_writedata,
            data_out => out_fifo_readdata,
            count => out_fifo_count );
    
    make_output_stall : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            hist_stall_reg <= out_fifo_count(11) OR out_fifo_count(10) OR out_fifo_count(9);
        END IF;
    END PROCESS make_output_stall;

    --Data handling
    usb_data_out_valid <= s_usb_data_out_valid_reg;
    out_fifo_read <= '1' WHEN out_fifo_empty = '0' AND (usb_data_out_busy = '0' OR s_usb_data_out_valid_reg = '0') ELSE '0';
    s_aux_out_ack <= '1' WHEN out_fifo_read = '0' AND (usb_data_out_busy = '0' OR s_usb_data_out_valid_reg = '0') ELSE '0';
    make_data_to_usb : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF usb_data_out_busy = '0' THEN
                s_usb_data_out_valid_reg <= '0';
            END IF;
            IF out_fifo_read = '1' THEN
                usb_data_out <= out_fifo_readdata;
                s_usb_data_out_valid_reg <= '1';
                usb_hold_pktend <= '1';
            ELSIF s_aux_out_valid_reg = '1' THEN
                usb_data_out <= s_aux_out_data_reg;
                s_usb_data_out_valid_reg <= '1';
                usb_hold_pktend <= '0';
            END IF;
        END IF;
    END PROCESS make_data_to_usb;
    
    --Control handling
    usb_data_in_ack <= '1' WHEN s_state_reg = IDLE OR s_state_reg = WRITE_CMD_MEM ELSE '0';
    control : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF reset = '1' THEN
                clk_ref_en_delay_reg <= "000";
                clk_mul_chain(1 DOWNTO 0) <= "01";
                config_load_chain(0) <= '0';
                global_offset_chain(4 DOWNTO 0) <= (OTHERS=>'0');
                hist_length_chain(8 DOWNTO 0) <= (OTHERS=>'1');
                hist_read_chain(0) <= '0';
                s_eq_tdc_coarse_count_max_reg <= "111";
                s_post_rot_hist_length <= (OTHERS=>'1');
                s_state_reg <= IDLE;
            ELSE
                config_load_chain(0) <= '0';
                IF s_data_counter_reg /= 0 AND out_fifo_read = '1' THEN
                    s_data_counter_reg <= s_data_counter_reg - 1;
                END IF;
                IF s_data_counter_reg = 0 THEN
                    s_data_counter_zero_reg <= '1';
                END IF;
                --Auto-increment addresses
                IF s_eq_cmd_mem_write = '1' THEN
                    s_eq_cmd_mem_write <= '0';
                    s_eq_cmd_mem_addr <= std_logic_vector(unsigned(s_eq_cmd_mem_addr)+1);
                END IF;
                IF s_pre_rot_mem_wr = '1' THEN
                    s_pre_rot_mem_wr <= '0';
                    s_pre_rot_mem_wr_addr <= std_logic_vector(unsigned(s_pre_rot_mem_wr_addr)+1);
                END IF;
                IF s_post_rot_mem_wr = '1' THEN
                    s_post_rot_mem_wr <= '0';
                    s_post_rot_mem_wr_addr <= std_logic_vector(unsigned(s_post_rot_mem_wr_addr)+1);
                END IF;
                hist_switch_reg <= '0';
                hist_read_chain(0) <= '0';
                CASE s_state_reg IS
                WHEN IDLE =>
                    IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        IF usb_data_in(31 DOWNTO 28) = X"0" THEN
                            s_cycle_counter_reg <= unsigned(usb_data_in(15 DOWNTO 0));
                            s_timeout_counter_reg <= (OTHERS=>'0');
                            s_state_reg <= SWITCH_MUX;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"1" THEN
                            s_wait_cycles_counter_reg <= (OTHERS=>'0');
                        ELSIF usb_data_in(31 DOWNTO 28) = X"2" THEN
                            mux_sel_reg <= unsigned(usb_data_in(1 DOWNTO 0));
                            hist_switch_reg <= usb_data_in(2);
                            hist_read_chain(0) <= usb_data_in(3);
                            IF usb_data_in(3) = '1' THEN
                                s_state_reg <= WAIT_IDLE;
                            END IF;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"3" THEN
                            s_aux_out_data_reg <= std_logic_vector(s_wait_cycles_counter_reg);
                            s_aux_out_valid_reg <= '1';
                            s_state_reg <= WAIT_SEND;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"4" THEN
                            tdc_config_chain(0) <= usb_data_in(16);
                            pixel_delay_offset_chain(11 DOWNTO 0) <= usb_data_in(11 DOWNTO 0);
                            config_load_chain(0) <= '1';
                        ELSIF usb_data_in(31 DOWNTO 28) = X"5" THEN
                            clk_mul_chain(1 DOWNTO 0) <= usb_data_in(1 DOWNTO 0);
                            global_offset_chain(4 DOWNTO 0) <= usb_data_in(6 DOWNTO 2);
                            hist_length_chain(8 DOWNTO 0) <= usb_data_in(15 DOWNTO 7);
                            clk_ref_en_delay_reg <= usb_data_in(18 DOWNTO 16);
                            s_eq_tdc_coarse_count_max_reg <= usb_data_in(21 DOWNTO 19);
                            s_use_slow_ref_reg <= usb_data_in(22);
                            s_use_slow_trigger_reg <= usb_data_in(23);
                            block_mux_reg <= usb_data_in(24);
                            block_switch_reg <= usb_data_in(25);
                            block_read_reg <= usb_data_in(26);
                        ELSIF usb_data_in(31 DOWNTO 28) = X"6" THEN
                            s_sample_count_reg <= unsigned(usb_data_in(27 DOWNTO 0));
                        ELSIF usb_data_in(31 DOWNTO 28) = X"7" THEN
                            s_eq_init <= '1';
                            s_pre_rot_init <= '1';
                            s_post_rot_init <= '1';
                            s_state_reg <= DO_RESET;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"8" THEN
                            s_eq_cmd_mem_addr <= usb_data_in(13 DOWNTO 0);
                            s_pre_rot_mem_wr_addr <= usb_data_in(7 DOWNTO 0);
                            s_post_rot_mem_wr_addr <= usb_data_in(7 DOWNTO 0);
                        ELSIF usb_data_in(31 DOWNTO 28) = X"9" THEN
                            s_state_reg <= WRITE_CMD_MEM;
                            s_mem_write_select_reg <= usb_data_in(18 DOWNTO 16);
                            s_mem_write_counter_reg <= unsigned(usb_data_in(13 DOWNTO 0));
                            s_mem_write_mod_counter_reg <= "10";
                        ELSIF usb_data_in(31 DOWNTO 28) = X"A" THEN
                            s_data_counter_reg <= unsigned(usb_data_in(27 DOWNTO 0));
                            s_data_counter_zero_reg <= '0';
                        ELSIF usb_data_in(31 DOWNTO 28) = X"B" THEN
                            s_post_rot_hist_length <= usb_data_in(8 DOWNTO 0);
                        ELSIF usb_data_in(31 DOWNTO 28) = X"C" THEN
                            s_trigger_delay_reg <= unsigned(usb_data_in(27 DOWNTO 0));
                        END IF;
                    END IF;
                WHEN WRITE_CMD_MEM =>
                    IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        s_eq_cmd_mem_data <= s_eq_cmd_mem_data(39 DOWNTO 0)&usb_data_in;
                        s_pre_rot_mem_wr_data <= usb_data_in(11 DOWNTO 0);
                        s_post_rot_mem_wr_data <= usb_data_in(11 DOWNTO 0);
                        s_mem_write_mod_counter_reg <= s_mem_write_mod_counter_reg - 1;
                        IF s_mem_write_select_reg(0) = '0' OR s_mem_write_mod_counter_reg = "00" THEN
                            s_mem_write_mod_counter_reg <= "10";
                            s_eq_cmd_mem_write <= s_mem_write_select_reg(0);
                            s_pre_rot_mem_wr <= s_mem_write_select_reg(1);
                            s_post_rot_mem_wr <= s_mem_write_select_reg(2);
                            s_mem_write_counter_reg <= s_mem_write_counter_reg - 1;
                            IF s_mem_write_counter_reg = 0 THEN
                                s_state_reg <= IDLE;
                            END IF;
                        END IF;
                    END IF;
                WHEN ACQ_SAMPLES =>
                    s_sample_counter_reg <= s_sample_counter_reg - 1;
                    IF s_sample_counter_reg = 0 THEN
                        hist_acq_reg <= '0';
                        IF block_mux_reg = '0' THEN
                            mux_sel_reg <= mux_sel_reg + 1;
                        END IF;
                        s_timeout_counter_reg <= X"7";
                        s_state_reg <= SWITCH_MUX;
                    END IF;
                WHEN SWITCH_MUX =>
                    s_sample_counter_reg <= s_sample_count_reg;
                    s_timeout_counter_reg <= s_timeout_counter_reg - 1;
                    IF s_timeout_counter_reg = 3 THEN
                        IF hist_idle_chain(0) = '1' THEN
                            hist_switch_reg <= NOT block_switch_reg;
                        ELSE
                            s_wait_cycles_counter_reg <= s_wait_cycles_counter_reg + 1;
                            s_timeout_counter_reg <= X"3";
                        END IF;
                    ELSIF s_timeout_counter_reg = 1 THEN
                        hist_read_chain(0) <= NOT block_read_reg;
                    ELSIF s_timeout_counter_reg = 0 THEN
                        s_cycle_counter_reg <= s_cycle_counter_reg - 1;
                        IF s_cycle_counter_reg = 0 THEN
                            s_state_reg <= WAIT_IDLE;
                        ELSE
                            IF s_use_slow_trigger_reg = '1' THEN
                                s_state_reg <= WAIT_TRIGGER;
                            ELSE
                                hist_acq_reg <= '1';
                                s_state_reg <= ACQ_SAMPLES;
                            END IF;
                        END IF;
                    END IF;
                WHEN WAIT_TRIGGER =>
                    s_delay_counter_reg <= s_trigger_delay_reg;
                    IF clk_ref_en = '1' THEN
                        s_state_reg <= DELAY_TRIGGER;
                    END IF;
                WHEN DELAY_TRIGGER => 
                    s_delay_counter_reg <= s_delay_counter_reg - 1;
                    IF s_delay_counter_reg = 0 THEN
                        hist_acq_reg <= '1';
                        s_state_reg <= ACQ_SAMPLES;
                    END IF;
                WHEN WAIT_IDLE =>
                    IF s_data_counter_zero_reg = '1' THEN
                        s_state_reg <= IDLE;
                    END IF;
                WHEN DO_RESET =>
                    s_eq_init <= '0';
                    s_pre_rot_init <= '0';
                    s_post_rot_init <= '0';
                    s_state_reg <= WAIT_IDLE;
                WHEN WAIT_SEND =>
                    IF s_aux_out_ack = '1' THEN
                        s_aux_out_valid_reg <= '0';
                        s_state_reg <= IDLE;
                    END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS control;
    
END ARCHITECTURE arch;

