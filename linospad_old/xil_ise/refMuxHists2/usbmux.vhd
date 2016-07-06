LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE usbmux_package IS
    TYPE usbmux_data_in_array_t IS ARRAY (0 TO 15) OF std_logic_vector(31 DOWNTO 0);
END PACKAGE;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.usbmux_package.ALL;

ENTITY usbmux IS
    PORT(
        SIGNAL clk, reset           : IN    std_logic;
    
        --To/From USB controller
        SIGNAL usb_adr_out          : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_out         : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid   : IN    std_logic;
        SIGNAL usb_data_out_ack     : OUT   std_logic;
        
        SIGNAL usb_data_in          : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid    : OUT   std_logic;
        SIGNAL usb_data_in_busy     : IN    std_logic;
        SIGNAL usb_hold_pktend      : OUT   std_logic;
        
        --To/From internal modules
        SIGNAL usb_adr_out_mux      : OUT   std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_out_mux     : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid_mux : OUT std_logic;
        SIGNAL usb_data_out_ack_mux : IN    std_logic_vector(15 DOWNTO 0);
        SIGNAL usb_data_in_busy_mux : OUT   std_logic_vector(15 DOWNTO 0);
        SIGNAL usb_hold_pktend_mux  : IN    std_logic_vector(15 DOWNTO 0);
        SIGNAL usb_data_in_valid_mux: IN    std_logic_vector(15 DOWNTO 0);
        SIGNAL usb_data_in_mux      : IN    usbmux_data_in_array_t
    );
END ENTITY usbmux;

ARCHITECTURE arch OF usbmux IS
    SIGNAL s_usb_adr_in_reg : unsigned(3 DOWNTO 0);
    SIGNAL s_usb_adr_out : unsigned(3 DOWNTO 0);
BEGIN
    s_usb_adr_out <= "0000" WHEN reset = '1' ELSE unsigned(usb_adr_out);
    usb_data_out_ack <= usb_data_out_ack_mux(to_integer(s_usb_adr_out));

    usb_adr_out_mux <= std_logic_vector(s_usb_adr_out);
    usb_data_out_mux <= usb_data_out;
    usb_data_out_valid_mux <= usb_data_out_valid;

    busy_mux : FOR i IN 0 TO 15 GENERATE
        usb_data_in_busy_mux(i) <= usb_data_in_busy WHEN i = to_integer(s_usb_adr_in_reg) ELSE '1';
    END GENERATE;
    usb_data_in_valid <= usb_data_in_valid_mux(to_integer(s_usb_adr_in_reg));
    usb_data_in <= usb_data_in_mux(to_integer(s_usb_adr_in_reg));
    usb_hold_pktend <= usb_hold_pktend_mux(to_integer(s_usb_adr_in_reg));
    
    priority_encoder : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                s_usb_adr_in_reg <= "0000";
            ELSE
                FOR i IN 15 DOWNTO 0 LOOP
                    IF usb_data_in_valid_mux(i) = '1' THEN
                        s_usb_adr_in_reg <= to_unsigned(i, 4);
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE arch;

