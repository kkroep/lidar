LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY datasinksource IS
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
        SIGNAL usb_data_out_busy        : IN    std_logic
    );
END ENTITY datasinksource;

ARCHITECTURE arch OF datasinksource IS
    TYPE t_state IS (IDLE, SINK_DATA, SOURCE_DATA, SEND_WORD);
    SIGNAL s_state_reg : t_state;
    SIGNAL s_word_count_reg, s_word_counter_reg : unsigned(31 DOWNTO 0);
    SIGNAL s_is_source_reg, s_wait_count_reg, s_error_reg : std_logic;
    SIGNAL s_error_count_reg, s_first_error_reg : unsigned(31 DOWNTO 0);
    SIGNAL s_cycle_counter_reg : unsigned(31 DOWNTO 0);
BEGIN
    --Data handling
    usb_data_in_ack <= '1' WHEN s_state_reg = IDLE OR s_state_reg = SINK_DATA ELSE '0';
    PROCESS(clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                s_wait_count_reg <= '0';
                s_is_source_reg <= '0';
                usb_data_out_valid <= '0';
                s_state_reg <= IDLE;
            ELSE
                CASE s_state_reg IS
                WHEN IDLE =>
                    IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        IF s_wait_count_reg = '1' THEN
                            s_wait_count_reg <= '0';
                            s_word_counter_reg <= (OTHERS=>'0');
                            s_word_count_reg <= unsigned(usb_data_in);
                            IF s_is_source_reg = '1' THEN
                                usb_data_out <= (OTHERS=>'1');
                                usb_data_out_valid <= '1';
                                s_state_reg <= SOURCE_DATA;
                            ELSE
                                s_state_reg <= SINK_DATA;
                            END IF;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"0" THEN
                            usb_data_out <= std_logic_vector(s_error_count_reg);
                            usb_data_out_valid <= '1';
                            s_state_reg <= SEND_WORD;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"1" THEN
                            usb_data_out <= std_logic_vector(s_first_error_reg);
                            usb_data_out_valid <= '1';
                            s_state_reg <= SEND_WORD;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"2" THEN
                            usb_data_out <= std_logic_vector(s_cycle_counter_reg);
                            usb_data_out_valid <= '1';
                            s_state_reg <= SEND_WORD;
                        ELSIF usb_data_in(31 DOWNTO 28) = X"3" THEN
                            s_error_reg <= '0';
                            s_error_count_reg <= (OTHERS=>'0');
                            s_cycle_counter_reg <= (OTHERS=>'0');
                        ELSIF usb_data_in(31 DOWNTO 28) = X"8" THEN
                            s_wait_count_reg <= '1';
                            s_is_source_reg <= usb_data_in(0);
                        END IF;
                    END IF;
                WHEN SINK_DATA =>
                    s_cycle_counter_reg <= s_cycle_counter_reg + 1;
                    IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        IF unsigned(usb_data_in) /= s_word_counter_reg THEN
                            s_error_reg <= '1';
                            s_error_count_reg <= s_error_count_reg + 1;
                            IF s_error_reg = '0' THEN
                                s_first_error_reg <= s_word_counter_reg;
                            END IF;
                        END IF;
                        s_word_counter_reg <= s_word_counter_reg + 1;
                        IF s_word_counter_reg = s_word_count_reg THEN
                            s_state_reg <= IDLE;
                        END IF;
                    END IF;
                WHEN SOURCE_DATA =>
                    s_cycle_counter_reg <= s_cycle_counter_reg + 1;
                    IF usb_data_out_busy = '0' THEN
                        s_word_counter_reg <= s_word_counter_reg + 1;
                        IF s_word_counter_reg = s_word_count_reg THEN
                            usb_data_out_valid <= '0';
                            s_state_reg <= IDLE;
                        ELSE
                            usb_data_out <= std_logic_vector(s_word_counter_reg);
                        END IF;
                    END IF;
                WHEN SEND_WORD =>
                    IF usb_data_out_busy = '0' THEN
                        usb_data_out_valid <= '0';
                        s_state_reg <= IDLE;
                    END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE arch;
