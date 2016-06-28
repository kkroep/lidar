LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fx3_stats IS
    GENERIC(
        CONSTANT ADR                    : std_logic_vector(3 DOWNTO 0) := X"0"
    );
    PORT(
        SIGNAL reset                        : IN    std_logic;
        SIGNAL usb_adr_in                   : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_in                  : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid            : IN    std_logic;
        SIGNAL usb_data_in_ack              : OUT   std_logic;
        SIGNAL usb_data_out                 : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid           : OUT   std_logic;
        SIGNAL usb_data_out_busy            : IN    std_logic;
        
        --Statistics
        SIGNAL stats_clk                    : IN    std_logic;
        SIGNAL stats_read                   : IN    std_logic;
        SIGNAL stats_read_single            : IN    std_logic;
        SIGNAL stats_read_burst             : IN    std_logic;
        SIGNAL stats_write                  : IN    std_logic;
        SIGNAL stats_write_single           : IN    std_logic;
        SIGNAL stats_write_burst            : IN    std_logic;
        SIGNAL stats_pktend                 : IN    std_logic
    );
END ENTITY fx3_stats;

ARCHITECTURE arch OF fx3_stats IS
    SIGNAL s_read_counter, s_write_counter : unsigned(31 DOWNTO 0);
    SIGNAL s_read_single_counter, s_read_burst_counter : unsigned(15 DOWNTO 0);
    SIGNAL s_write_single_counter, s_write_burst_counter : unsigned(15 DOWNTO 0);
    SIGNAL s_pktend_counter : unsigned(15 DOWNTO 0);
    TYPE state_t IS (IDLE, SEND);
    SIGNAL s_state_reg : state_t := IDLE;
    SIGNAL s_soft_reset_reg : std_logic;
    SIGNAL s_output_data_reg : unsigned(127 DOWNTO 0);
    SIGNAL s_output_counter_reg : unsigned(3 DOWNTO 0);
BEGIN
    usb_data_in_ack <= '1' WHEN s_state_reg = IDLE ELSE '0';
    PROCESS(stats_clk)
    BEGIN
        IF rising_edge(stats_clk) THEN
            IF reset = '1' OR s_soft_reset_reg = '1' THEN
                s_read_counter <= (OTHERS=>'0');
                s_write_counter <= (OTHERS=>'0');
                s_read_single_counter <= (OTHERS=>'0');
                s_read_burst_counter <= (OTHERS=>'0');
                s_write_single_counter <= (OTHERS=>'0');
                s_write_burst_counter <= (OTHERS=>'0');
                s_pktend_counter <= (OTHERS=>'0');
                s_state_reg <= IDLE;
                s_soft_reset_reg <= '0';
                usb_data_out_valid <= '0';
            ELSE
                IF stats_read = '1' THEN
                    s_read_counter <= s_read_counter + 1;
                END IF;
                IF stats_read_single = '1' THEN
                    s_read_single_counter <= s_read_single_counter + 1;
                END IF;
                IF stats_read_burst = '1' THEN
                    s_read_burst_counter <= s_read_burst_counter + 1;
                END IF;
                IF stats_write = '1' THEN
                    s_write_counter <= s_write_counter + 1;
                END IF;
                IF stats_write_single = '1' THEN
                    s_write_single_counter <= s_write_single_counter + 1;
                END IF;
                IF stats_write_burst = '1' THEN
                    s_write_burst_counter <= s_write_burst_counter + 1;
                END IF;
                IF stats_pktend = '1' THEN
                    s_pktend_counter <= s_pktend_counter + 1;
                END IF;
                CASE s_state_reg IS
                WHEN IDLE =>
                    IF usb_adr_in = ADR AND usb_data_in_valid = '1' THEN
                        IF usb_data_in(31 DOWNTO 28) = X"F" THEN
                            s_soft_reset_reg <= '1';
                            s_state_reg <= SEND;
                        ELSE
                            s_output_data_reg <= s_read_counter&s_write_counter&s_read_single_counter&s_read_burst_counter&s_write_single_counter&s_write_burst_counter;
                            s_output_counter_reg <= "0100";
                            usb_data_out <= X"0000"&std_logic_vector(s_pktend_counter);
                            usb_data_out_valid <= '1';
                            s_state_reg <= SEND;
                        END IF;
                    END IF;
                WHEN SEND =>
                    IF usb_data_out_busy = '0' THEN
                        IF s_output_counter_reg = 0 THEN
                            usb_data_out_valid <= '0';
                            s_state_reg <= IDLE;
                        ELSE
                            s_output_counter_reg <= s_output_counter_reg - 1;
                            usb_data_out <= std_logic_vector(s_output_data_reg(31 DOWNTO 0));
                            s_output_data_reg <= X"00000000"&s_output_data_reg(127 DOWNTO 32);
                        END IF;
                    END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE arch;

