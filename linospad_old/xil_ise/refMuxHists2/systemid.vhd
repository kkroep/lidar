LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY systemid IS
    GENERIC (
        CONSTANT ADR        : std_logic_vector(3 DOWNTO 0) := X"0";
        CONSTANT ID         : std_logic_vector(31 DOWNTO 0) := X"20140630"
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
END ENTITY systemid;

ARCHITECTURE arch OF systemid IS
    TYPE t_state IS (IDLE, SEND_WORD);
    SIGNAL s_state_reg : t_state;
BEGIN
    --Data handling
    usb_data_in_ack <= '1' WHEN s_state_reg = IDLE ELSE '0';
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                usb_data_out_valid <= '0';
                s_state_reg <= IDLE;
            ELSE
                CASE s_state_reg IS
                WHEN IDLE =>
                    IF usb_data_in_valid = '1' AND usb_adr_in = ADR THEN
                        usb_data_out <= ID;
                        usb_data_out_valid <= '1';
                        s_state_reg <= SEND_WORD;
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
