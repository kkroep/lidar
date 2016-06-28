LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY loopback IS
    GENERIC(
        CONSTANT ADR                    : std_logic_vector(3 DOWNTO 0) := X"0"
    );
    PORT(
        SIGNAL clk, reset               : IN    std_logic;
        SIGNAL usb_adr_in               : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_in              : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid        : IN    std_logic;
        SIGNAL usb_data_in_ack          : OUT   std_logic;
        SIGNAL usb_data_out             : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid       : OUT   std_logic;
        SIGNAL usb_data_out_busy        : IN    std_logic
    );
END ENTITY loopback;

ARCHITECTURE arch OF loopback IS
    TYPE   t_buffer_mem IS ARRAY (0 TO 511) OF std_logic_vector(31 DOWNTO 0);
    SIGNAL s_buffer_mem : t_buffer_mem;
    SIGNAL s_read_ptr_reg, s_write_ptr_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_read_reg, s_write_reg : std_logic := '0';
    SIGNAL s_readdata_reg, s_writedata_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_element_count_reg : unsigned(9 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_usb_data_out_valid_reg : std_logic := '0';
BEGIN
    make_memory : PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            s_write_ptr_reg <= (OTHERS=>'0');
            s_read_ptr_reg <= (OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF s_write_reg = '1' THEN
                s_buffer_mem(to_integer(s_write_ptr_reg)) <= s_writedata_reg;
                s_write_ptr_reg <= s_write_ptr_reg + 1;
            END IF;
            IF s_read_reg = '1' THEN
                s_readdata_reg <= s_buffer_mem(to_integer(s_read_ptr_reg));
                s_read_ptr_reg <= s_read_ptr_reg + 1;
            END IF;
        END IF;
    END PROCESS make_memory;

    make_element_count : PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            s_element_count_reg <= (OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF s_write_reg = '1' AND s_read_reg = '0' THEN
                s_element_count_reg <= s_element_count_reg + 1;
            ELSIF s_write_reg = '0' AND s_read_reg = '1' THEN
                s_element_count_reg <= s_element_count_reg - 1;
            END IF;
        END IF;
    END PROCESS make_element_count;

    usb_data_in_ack <= '1' WHEN usb_adr_in = ADR AND usb_data_in_valid = '1' AND s_element_count_reg(s_element_count_reg'HIGH) = '0' ELSE '0';
    usb_data_out <= s_readdata_reg;
    usb_data_out_valid <= s_usb_data_out_valid_reg;
    PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            s_usb_data_out_valid_reg <= '0';
            s_read_reg <= '0';
            s_write_reg <= '0';
        ELSIF rising_edge(clk) THEN
            IF s_read_reg = '1' THEN
                s_usb_data_out_valid_reg <= '1';
            ELSIF usb_data_out_busy = '0' THEN
                s_usb_data_out_valid_reg <= '0';
            END IF;
            s_read_reg <= '0';
            IF (s_element_count_reg > 1 OR (s_element_count_reg = 1 AND s_read_reg = '0')) AND ((s_usb_data_out_valid_reg = '0' AND s_read_reg = '0') OR usb_data_out_busy = '0') THEN
                s_read_reg <= '1';
            END IF;
            s_write_reg <= '0';
            IF usb_adr_in = ADR AND usb_data_in_valid = '1' THEN
                IF s_element_count_reg(s_element_count_reg'HIGH) = '0' THEN
                    s_write_reg <= '1';
                    s_writedata_reg <= usb_data_in;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE arch;
