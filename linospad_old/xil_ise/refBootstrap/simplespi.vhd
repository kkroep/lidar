LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY simplespi IS
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
        
        --Connect to FPGA pins
        SIGNAL CSN                      : INOUT std_logic;
        SIGNAL SCK                      : INOUT std_logic;
        SIGNAL MOSI                     : INOUT std_logic;
        SIGNAL MISO                     : IN    std_logic
    );
END ENTITY simplespi;

ARCHITECTURE arch OF simplespi IS
    TYPE t_state IS (IDLE, WRITE_BYTES, READ_BYTES);
    SIGNAL s_state_reg : t_state;

    SIGNAL s_signals_driven_reg : std_logic_vector(2 DOWNTO 0); --MOSI,SCK,CSN
    SIGNAL s_clock_divider_reg : unsigned(7 DOWNTO 0);
    SIGNAL s_clock_counter_reg : unsigned(7 DOWNTO 0);
    SIGNAL s_csn_state_reg, s_clk_state_reg : std_logic;

    SIGNAL s_write_byte_counter_reg, s_read_byte_counter_reg : unsigned(11 DOWNTO 0);
    SIGNAL s_bit_counter_reg : unsigned(3 DOWNTO 0);
    SIGNAL s_byte_to_word_counter_reg : unsigned(3 DOWNTO 0);
    SIGNAL s_write_data_reg, s_read_data_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_next_write_data_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_next_write_data_ready_reg : std_logic;
    SIGNAL s_usb_data_out_valid_reg : std_logic;
    
BEGIN
    --Data handling
    usb_data_in_ack <= '1' WHEN 
        s_state_reg = IDLE
        OR (s_state_reg = WRITE_BYTES AND s_write_byte_counter_reg /= 0 AND s_byte_to_word_counter_reg = 0 AND s_next_write_data_ready_reg = '0')
        ELSE '0';
    usb_data_out_valid <= s_usb_data_out_valid_reg;
    CSN <= s_csn_state_reg WHEN s_signals_driven_reg(0) = '1' ELSE 'Z';
    SCK <= s_clk_state_reg WHEN s_signals_driven_reg(1) = '1' ELSE 'Z';
    MOSI <= s_write_data_reg(31) WHEN s_signals_driven_reg(2) = '1' ELSE 'Z';
    PROCESS(clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                s_usb_data_out_valid_reg <= '0';
                s_state_reg <= IDLE;
            ELSE
                CASE s_state_reg IS
                WHEN IDLE =>
                    s_csn_state_reg <= '1';
                    s_clk_state_reg <= '1';
                    s_bit_counter_reg <= (OTHERS=>'0');
                    s_byte_to_word_counter_reg <= (OTHERS=>'0');
                    IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        IF usb_data_in(31 DOWNTO 28) = X"0" THEN
                            s_signals_driven_reg <= usb_data_in(10 DOWNTO 8);
                            s_clock_divider_reg <= unsigned(usb_data_in(7 DOWNTO 0));
                        ELSIF usb_data_in(31 DOWNTO 28) = X"1" THEN
                            s_write_byte_counter_reg <= unsigned(usb_data_in(23 DOWNTO 12));
                            s_read_byte_counter_reg <= unsigned(usb_data_in(11 DOWNTO 0));
                            s_clock_counter_reg <= s_clock_divider_reg;
                            s_state_reg <= WRITE_BYTES;
                        END IF;
                    END IF;
                WHEN WRITE_BYTES =>
                    IF s_write_byte_counter_reg /= 0 AND s_byte_to_word_counter_reg = 0 AND s_next_write_data_ready_reg = '0' AND usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        s_next_write_data_reg <= usb_data_in(7 DOWNTO 0)&usb_data_in(15 DOWNTO 8)&usb_data_in(23 DOWNTO 16)&usb_data_in(31 DOWNTO 24);
                        s_next_write_data_ready_reg <= '1';
                    END IF;
                    IF s_csn_state_reg = '1' THEN
                        IF s_clock_counter_reg = 0 THEN
                            s_csn_state_reg <= '0';
                            s_clock_counter_reg <= s_clock_divider_reg;
                        ELSE
                            s_clock_counter_reg <= s_clock_counter_reg-1;
                        END IF;
                    ELSIF s_clock_counter_reg = 0 THEN
                        s_clock_counter_reg <= s_clock_divider_reg;
                        IF s_clk_state_reg = '1' THEN
                            IF s_bit_counter_reg /= 0 THEN
                                s_bit_counter_reg <= s_bit_counter_reg-1;
                                s_write_data_reg <= s_write_data_reg(30 DOWNTO 0)&'0';
                                s_clk_state_reg <= '0';
                            ELSIF s_byte_to_word_counter_reg /= 0 THEN
                                s_write_byte_counter_reg <= s_write_byte_counter_reg-1;
                                s_byte_to_word_counter_reg <= s_byte_to_word_counter_reg-1;
                                s_bit_counter_reg <= "0111";
                                s_write_data_reg <= s_write_data_reg(30 DOWNTO 0)&'0';
                                s_clk_state_reg <= '0';
                            ELSIF s_next_write_data_ready_reg = '1' THEN
                                s_write_byte_counter_reg <= s_write_byte_counter_reg-1;
                                s_byte_to_word_counter_reg <= "0011";
                                s_bit_counter_reg <= "0111";
                                s_write_data_reg <= s_next_write_data_reg;
                                s_next_write_data_ready_reg <= '0';
                                s_clk_state_reg <= '0';
                            END IF;
                        ELSE
                            IF s_write_byte_counter_reg = 0 AND s_bit_counter_reg = 0 THEN
                                s_byte_to_word_counter_reg <= (OTHERS=>'0');
                                s_state_reg <= READ_BYTES;
                             END IF;
                             s_clk_state_reg <= '1';
                        END IF;
                    ELSE
                        s_clock_counter_reg <= s_clock_counter_reg - 1;
                    END IF;
                WHEN READ_BYTES =>
                    IF s_usb_data_out_valid_reg = '1' AND usb_data_out_busy = '0' THEN
                        s_usb_data_out_valid_reg <= '0';
                    END IF;
                    IF s_csn_state_reg = '1' THEN
                        IF s_clock_counter_reg = 0 THEN
                            IF s_usb_data_out_valid_reg = '0' THEN
                                IF s_byte_to_word_counter_reg /= 0 THEN
                                    usb_data_out <= s_read_data_reg(7 DOWNTO 0)&s_read_data_reg(15 DOWNTO 8)&s_read_data_reg(23 DOWNTO 16)&s_read_data_reg(31 DOWNTO 24);
                                    s_usb_data_out_valid_reg <= '1';
                                    s_byte_to_word_counter_reg <= (OTHERS=>'0');
                                ELSE
                                    s_state_reg <= IDLE;
                                END IF;
                            END IF;
                        ELSE
                            s_clock_counter_reg <= s_clock_counter_reg-1;
                        END IF;
                    ELSIF s_clock_counter_reg = 0 THEN
                        s_clock_counter_reg <= s_clock_divider_reg;
                        IF s_clk_state_reg = '1' THEN
                            IF s_read_byte_counter_reg = 0 AND s_bit_counter_reg = 0 THEN
                                s_csn_state_reg <= '1';
                            ELSE
                                s_clk_state_reg <= '0';
                            END IF;
                        ELSE
                            IF s_bit_counter_reg /= 0 THEN
                                s_bit_counter_reg <= s_bit_counter_reg-1;
                                s_read_data_reg <= s_read_data_reg(30 DOWNTO 0)&MISO;
                                s_clk_state_reg <= '1';
                            ELSIF s_byte_to_word_counter_reg < 4 THEN
                                s_read_byte_counter_reg <= s_read_byte_counter_reg-1;
                                s_byte_to_word_counter_reg <= s_byte_to_word_counter_reg+1;
                                s_bit_counter_reg <= "0111";
                                s_read_data_reg <= s_read_data_reg(30 DOWNTO 0)&MISO;
                                s_clk_state_reg <= '1';
                            ELSIF s_usb_data_out_valid_reg = '0' THEN
                                usb_data_out <= s_read_data_reg(7 DOWNTO 0)&s_read_data_reg(15 DOWNTO 8)&s_read_data_reg(23 DOWNTO 16)&s_read_data_reg(31 DOWNTO 24);
                                s_usb_data_out_valid_reg <= '1';                                
                                s_read_byte_counter_reg <= s_read_byte_counter_reg-1;
                                s_byte_to_word_counter_reg <= "0001";
                                s_bit_counter_reg <= "0111";
                                s_read_data_reg <= s_read_data_reg(30 DOWNTO 0)&MISO;
                                s_clk_state_reg <= '1';
                            END IF;
                        END IF;
                    ELSE
                        s_clock_counter_reg <= s_clock_counter_reg-1;
                    END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    
END ARCHITECTURE arch;