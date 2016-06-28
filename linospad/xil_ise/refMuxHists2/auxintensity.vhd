LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY auxintensity IS
    GENERIC (
        CONSTANT ADR        : std_logic_vector(3 DOWNTO 0) := X"0"
    );
    PORT (
        SIGNAL clk, reset               : IN    std_logic;
        SIGNAL usb_adr_in               : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_in              : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid        : IN    std_logic;
        SIGNAL usb_data_in_ack          : OUT   std_logic;
        SIGNAL usb_data_out             : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid       : OUT   std_logic;
        SIGNAL usb_data_out_busy        : IN    std_logic;
        SIGNAL usb_hold_pktend          : OUT   std_logic;
        
        SIGNAL trigger                  : IN    std_logic;
        SIGNAL aux_pixels               : IN    std_logic_vector(7 DOWNTO 0)
    );
END ENTITY auxintensity;

ARCHITECTURE arch OF auxintensity IS
    TYPE t_counter_mem IS ARRAY(0 TO 7) OF unsigned(32 DOWNTO 0);
    SIGNAL s_high_counter_mem, s_edge_counter_mem : t_counter_mem := (OTHERS=>(OTHERS=>'0'));
    SIGNAL s_read_addr_reg : unsigned(2 DOWNTO 0) :=  to_unsigned(0,3);
    SIGNAL s_write_addr_reg : unsigned(2 DOWNTO 0) :=  to_unsigned(6,3);
    SIGNAL s_high_read_data_reg, s_high_write_data_reg, s_high_mem_in_data_reg : unsigned(32 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_edge_read_data_reg, s_edge_write_data_reg, s_edge_mem_in_data_reg : unsigned(32 DOWNTO 0) := (OTHERS=>'0');
    
    TYPE t_counter_array IS ARRAY(0 TO 7) OF unsigned(2 DOWNTO 0);
    SIGNAL s_high_counter_array, s_edge_counter_array : t_counter_array := (OTHERS=>(OTHERS=>'0'));
    SIGNAL s_counter_addr_reg : unsigned(2 DOWNTO 0) :=  to_unsigned(0,3);
    SIGNAL s_high_counter_data_reg, s_edge_counter_data_reg : unsigned(2 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_high_counter_extra_reg, s_edge_counter_extra_reg : std_logic := '0';
    SIGNAL s_high_counter_extra, s_edge_counter_extra : unsigned(3 DOWNTO 0) := (OTHERS=>'0');
    
    SIGNAL s_pixel_sample, s_pixel_sample_previous, s_pixel_rising_edge, s_pixel_off_reg : std_logic_vector(7 DOWNTO 0) := (OTHERS=>'0');
    
    SIGNAL s_cycle_start_reg, s_reset_counters_reg, s_trigger_update_reg, s_start_update_reg, s_write_update_reg, s_clear_output_reg : std_logic := '0';
    SIGNAL s_update_output_reg, s_output_almost_ready_reg, s_output_ready_reg, s_auto_update_reg, s_auto_trigger_reg : std_logic := '0';
    SIGNAL s_update_counter_reg : unsigned(3 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_high_output_mem, s_edge_output_mem : t_counter_mem := (OTHERS=>(OTHERS=>'0'));

    SIGNAL s_output_read : std_logic := '0';
    SIGNAL s_output_read_addr_reg : unsigned(2 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_high_output_write_data_reg, s_edge_output_write_data_reg : unsigned(32 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_high_output_read_data_reg, s_edge_output_read_data_reg : unsigned(32 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_output_counter_reg : unsigned(4 DOWNTO 0) := (OTHERS=>'0');
    
    SIGNAL s_cycle_counter_reg : unsigned(28 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_auto_update_delay_reg, s_cycle_count_output_reg : unsigned(27 DOWNTO 0) := (OTHERS=>'0');
    
    TYPE t_state IS (IDLE, WAIT_OUTPUT, SEND_OUTPUT, SEND_CYCLES, WAIT_TRIGGER, TRIGGER_DELAY, START_ACQ, ACQ);
    SIGNAL s_state_reg : t_state := IDLE;
    SIGNAL s_reset_reg, s_acq_off_idle_reg, s_acq_off_reg, s_usb_data_out_valid_reg : std_logic := '0';
    SIGNAL s_trigger_delay_reg, s_acq_time_reg, s_delay_counter_reg : unsigned(27 DOWNTO 0);
BEGIN
    --Memory
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            s_high_counter_mem(to_integer(s_write_addr_reg)) <= s_high_write_data_reg;
            s_edge_counter_mem(to_integer(s_write_addr_reg)) <= s_edge_write_data_reg;
            s_high_read_data_reg <= s_high_counter_mem(to_integer(s_read_addr_reg));
            s_edge_read_data_reg <= s_edge_counter_mem(to_integer(s_read_addr_reg));
        END IF;
    END PROCESS;
    
    --Counter mux
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            s_high_counter_data_reg <= s_high_counter_array(to_integer(s_counter_addr_reg));
            s_high_counter_extra_reg <= (NOT s_pixel_off_reg(to_integer(s_counter_addr_reg))) AND s_pixel_sample(to_integer(s_counter_addr_reg));
            s_edge_counter_data_reg <= s_edge_counter_array(to_integer(s_counter_addr_reg));
            s_edge_counter_extra_reg <= (NOT s_pixel_off_reg(to_integer(s_counter_addr_reg))) AND s_pixel_rising_edge(to_integer(s_counter_addr_reg));
        END IF;
    END PROCESS;
    s_high_counter_extra(0) <= s_high_counter_extra_reg;
    s_edge_counter_extra(0) <= s_edge_counter_extra_reg;
    
    --Counters to memory
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF s_reset_reg = '1' THEN
                s_read_addr_reg <= to_unsigned(0,3);
                s_counter_addr_reg <= to_unsigned(0,3);
                s_write_addr_reg <= to_unsigned(6,3);
            ELSE
                IF s_high_read_data_reg(32) = '0' THEN
                    s_high_write_data_reg <= s_high_read_data_reg + s_high_counter_data_reg + s_high_counter_extra;
                    s_high_output_write_data_reg <= s_high_read_data_reg + s_high_counter_data_reg + s_high_counter_extra;
                ELSE
                    s_high_write_data_reg <= s_high_read_data_reg;
                    s_high_output_write_data_reg <= s_high_read_data_reg;
                END IF;
                IF s_edge_read_data_reg(32) = '0' THEN
                    s_edge_write_data_reg <= s_edge_read_data_reg + s_edge_counter_data_reg + s_edge_counter_extra;
                    s_edge_output_write_data_reg <= s_edge_read_data_reg + s_edge_counter_data_reg + s_edge_counter_extra;
                ELSE
                    s_edge_write_data_reg <= s_edge_read_data_reg;
                    s_edge_output_write_data_reg <= s_edge_read_data_reg;
                END IF;
                IF s_reset_counters_reg = '1' THEN
                    s_high_write_data_reg <= (OTHERS=>'0');
                    s_edge_write_data_reg <= (OTHERS=>'0');
                END IF;
                s_read_addr_reg <= s_read_addr_reg + 1;
                s_counter_addr_reg <= s_counter_addr_reg + 1;
                s_write_addr_reg <= s_write_addr_reg + 1;
            END IF;
        END IF;
    END PROCESS;
    
    --Counters
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            FOR i IN 0 TO 7 LOOP
                s_pixel_off_reg(i) <= s_acq_off_reg;
                IF i = s_counter_addr_reg THEN
                    s_high_counter_array(i) <= (OTHERS=>'0');
                    s_edge_counter_array(i) <= (OTHERS=>'0');
                ELSE
                    IF s_pixel_off_reg(i) = '0' AND s_pixel_sample(i) = '1' THEN
                        s_high_counter_array(i) <= s_high_counter_array(i) + 1;
                    END IF;
                    IF s_pixel_off_reg(i) = '0' AND s_pixel_rising_edge(i) = '1' THEN
                        s_edge_counter_array(i) <= s_edge_counter_array(i) + 1;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END PROCESS;
    
    --Sampling
    s_pixel_rising_edge <= s_pixel_sample AND (NOT s_pixel_sample_previous);
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            s_pixel_sample_previous <= s_pixel_sample;
            s_pixel_sample <= aux_pixels;
        END IF;
    END PROCESS;
    
    --Memory to output
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF s_state_reg = IDLE THEN
                s_output_read_addr_reg <= (OTHERS=>'0');
            ELSIF s_output_read = '1' THEN
                s_output_read_addr_reg <= s_output_read_addr_reg + 1;
            END IF;
            s_write_update_reg <= s_update_output_reg;
            IF s_write_update_reg = '1' THEN
                s_high_output_mem(to_integer(s_write_addr_reg)) <= s_high_output_write_data_reg;
                s_edge_output_mem(to_integer(s_write_addr_reg)) <= s_edge_output_write_data_reg;
            END IF;
            IF s_output_read = '1' THEN
                s_high_output_read_data_reg <= s_high_output_mem(to_integer(s_output_read_addr_reg));
                s_edge_output_read_data_reg <= s_edge_output_mem(to_integer(s_output_read_addr_reg));
            END IF;
        END IF;
    END PROCESS;
    
    --Data handling
    usb_data_in_ack <= '1' WHEN s_state_reg = IDLE ELSE '0';
    usb_data_out_valid <= s_usb_data_out_valid_reg;
    s_output_read <= '1' WHEN (s_state_reg = WAIT_OUTPUT AND s_output_ready_reg = '1')
        OR (s_state_reg = SEND_OUTPUT AND (usb_data_out_busy = '0' OR s_usb_data_out_valid_reg = '0'))
        ELSE '0';
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            s_reset_reg <= '0';
            
            IF s_write_addr_reg = 5 THEN
                s_cycle_start_reg <= '1';
            ELSE
                s_cycle_start_reg <= '0';
            END IF;
            
            IF s_cycle_counter_reg(28) = '0' AND s_cycle_start_reg = '1' THEN
                s_cycle_counter_reg <= s_cycle_counter_reg + 1;
            END IF;
            
            IF s_auto_update_delay_reg <= s_cycle_counter_reg THEN
                s_auto_trigger_reg <= s_auto_update_reg;
            ELSE
                s_auto_trigger_reg <= '0';
            END IF;
            
            IF s_start_update_reg = '1' THEN
                s_start_update_reg <= '0';
                s_cycle_counter_reg <= (OTHERS=>'0');
                IF s_update_output_reg = '1' THEN
                    IF s_cycle_counter_reg(28) = '1' THEN
                        s_cycle_count_output_reg <= (OTHERS=>'1');
                    ELSE
                        s_cycle_count_output_reg <= s_cycle_counter_reg(27 DOWNTO 0);
                    END IF;
                    s_output_almost_ready_reg <= '1';
                END IF;
            END IF;
            IF s_output_almost_ready_reg = '1' THEN
                s_output_almost_ready_reg <= '0';
                s_output_ready_reg <= '1';
            END IF;
            IF s_reset_counters_reg = '1' THEN
                s_update_counter_reg <= s_update_counter_reg + 1;
                IF s_update_counter_reg(3) = '1' THEN
                    s_reset_counters_reg <= '0';
                    s_update_output_reg <= '0';
                END IF;
            END IF;
            IF s_cycle_start_reg = '1' THEN
                IF s_trigger_update_reg = '1' OR s_auto_trigger_reg = '1' THEN
                    s_trigger_update_reg <= '0';
                    s_update_counter_reg <= (0=>'1', OTHERS=>'0');
                    s_reset_counters_reg <= '1';
                    IF s_state_reg /= SEND_OUTPUT THEN
                        s_output_ready_reg <= '0';
                        s_update_output_reg <= '1';
                    END IF;
                    s_start_update_reg <= '1';
                END IF;
            END IF;
            
            CASE s_state_reg IS
            WHEN IDLE =>
                s_acq_off_reg <= s_acq_off_idle_reg;
                IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                    IF usb_data_in(31 DOWNTO 28) = X"0" THEN
                        s_output_ready_reg <= '0';
                        s_trigger_update_reg <= '1';
                        s_state_reg <= WAIT_OUTPUT;
                    ELSIF usb_data_in(31 DOWNTO 28) = X"1" THEN
                        s_auto_update_reg <= '1';
                        s_state_reg <= WAIT_OUTPUT;
                    ELSIF usb_data_in(31 DOWNTO 28) = X"2" THEN
                        s_auto_update_delay_reg <= unsigned(usb_data_in(27 DOWNTO 0));
                    ELSIF usb_data_in(31 DOWNTO 28) = X"3" THEN
                        s_reset_reg <= usb_data_in(0);
                        s_auto_update_reg <= usb_data_in(1);
                        s_clear_output_reg <= usb_data_in(2);
                        s_acq_off_idle_reg <= usb_data_in(3);
                    ELSIF usb_data_in(31 DOWNTO 28) = X"4" THEN
                        s_state_reg <= WAIT_TRIGGER;
                    ELSIF usb_data_in(31 DOWNTO 28) = X"5" THEN
                        s_trigger_delay_reg <= unsigned(usb_data_in(27 DOWNTO 0));
                    ELSIF usb_data_in(31 DOWNTO 28) = X"6" THEN
                        s_acq_time_reg <= unsigned(usb_data_in(27 DOWNTO 0));
                    END IF;
                END IF;
            WHEN WAIT_TRIGGER =>
                s_delay_counter_reg <= s_trigger_delay_reg;
                IF trigger = '1' THEN
                    s_state_reg <= TRIGGER_DELAY;
                END IF;
            WHEN TRIGGER_DELAY =>
                s_delay_counter_reg <= s_delay_counter_reg - 1;
                IF s_delay_counter_reg = 0 THEN
                    s_state_reg <= START_ACQ;
                END IF;
            WHEN START_ACQ =>
                s_acq_off_reg <= '0';
                s_delay_counter_reg <= s_acq_time_reg;
                s_state_reg <= ACQ;
            WHEN ACQ =>
                s_delay_counter_reg <= s_delay_counter_reg - 1;
                IF s_delay_counter_reg = 0 THEN
                    s_state_reg <= IDLE;
                END IF;
            WHEN WAIT_OUTPUT =>
                s_output_counter_reg <= (OTHERS=>'0');
                IF s_output_ready_reg = '1' THEN
                    s_output_ready_reg <= s_clear_output_reg;
                    s_state_reg <= SEND_OUTPUT;
                END IF;
            WHEN SEND_OUTPUT =>
                s_usb_data_out_valid_reg <= '1';
                IF usb_data_out_busy = '0' OR s_usb_data_out_valid_reg = '0' THEN
                    s_output_counter_reg <= s_output_counter_reg + 1;
                    IF s_output_counter_reg(4 DOWNTO 3) = "00" THEN
                        usb_hold_pktend <= '1';
                        IF s_high_output_read_data_reg(32) = '1' THEN
                            usb_data_out <= (OTHERS=>'1');
                        ELSE
                            usb_data_out <= std_logic_vector(s_high_output_read_data_reg(31 DOWNTO 0));
                        END IF;
                    ELSIF s_output_counter_reg(4 DOWNTO 3) = "01" THEN
                        usb_hold_pktend <= '1';
                        IF s_edge_output_read_data_reg(32) = '1' THEN
                            usb_data_out <= (OTHERS=>'1');
                        ELSE
                            usb_data_out <= std_logic_vector(s_edge_output_read_data_reg(31 DOWNTO 0));
                        END IF;
                    ELSE
                        usb_hold_pktend <= '0';
                        usb_data_out <= "0000"&std_logic_vector(s_cycle_count_output_reg);
                        s_state_reg <= SEND_CYCLES;
                    END IF;
                END IF;
            WHEN SEND_CYCLES =>
                IF usb_data_out_busy = '0' THEN
                    s_usb_data_out_valid_reg <= '0';
                    s_state_reg <= IDLE;
                END IF;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE arch;

