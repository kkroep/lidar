LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY module_clock_adapter IS
    GENERIC(
        CONSTANT ADR                : std_logic_vector(3 DOWNTO 0) := X"0"
    );
    PORT (
        SIGNAL usb_clk              : IN    std_logic;
        SIGNAL usb_reset            : IN    std_logic;

        SIGNAL usb_adr_in           : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_in          : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid    : IN    std_logic;
        SIGNAL usb_data_in_ack      : OUT   std_logic;
        SIGNAL usb_data_out         : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid   : OUT   std_logic;
        SIGNAL usb_data_out_busy    : IN    std_logic;
        SIGNAL usb_hold_pktend      : OUT   std_logic;

        SIGNAL mod_clk              : IN    std_logic;
        SIGNAL mod_reset            : OUT   std_logic;
        
        SIGNAL mod_adr_in           : OUT   std_logic_vector(3 DOWNTO 0);
        SIGNAL mod_data_in          : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL mod_data_in_valid    : OUT   std_logic;
        SIGNAL mod_data_in_ack      : IN    std_logic;
        SIGNAL mod_data_out         : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL mod_data_out_valid   : IN    std_logic;
        SIGNAL mod_data_out_busy    : OUT   std_logic;
        SIGNAL mod_hold_pktend      : IN    std_logic );
END ENTITY module_clock_adapter;

ARCHITECTURE arch OF module_clock_adapter IS
    COMPONENT dcfifo_256x36 IS
        PORT (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            full : OUT STD_LOGIC;
            almost_full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            almost_empty : OUT STD_LOGIC;
            prog_full : OUT STD_LOGIC;
            prog_empty : OUT STD_LOGIC
        );
    END COMPONENT;
    attribute box_type : string;
    attribute box_type of dcfifo_256x36 : component is "black_box";

    SIGNAL s_fifo_from_usb_rden, s_fifo_from_usb_wren : std_logic;
    SIGNAL s_fifo_from_usb_empty, s_fifo_from_usb_almost_full : std_logic;

    SIGNAL s_fifo_to_usb_rden, s_fifo_to_usb_wren : std_logic;
    SIGNAL s_fifo_to_usb_empty, s_fifo_to_usb_almost_full : std_logic;

    SIGNAL s_hold_pktend : std_logic;
    SIGNAL s_mod_reset_reg : std_logic_vector(3 DOWNTO 0);
BEGIN
    PROCESS(mod_clk, usb_reset)
    BEGIN
        IF usb_reset = '1' THEN
            s_mod_reset_reg <= (OTHERS=>'1');
        ELSIF rising_edge(mod_clk) THEN
            s_mod_reset_reg <= '0'&s_mod_reset_reg(3 DOWNTO 1);
        END IF;
    END PROCESS;
    mod_reset <= s_mod_reset_reg(0);

    --from USB to module
    usb_data_in_ack <= NOT s_fifo_from_usb_almost_full;
    s_fifo_from_usb_wren <=
        '1' WHEN usb_adr_in = ADR AND usb_data_in_valid = '1' AND s_fifo_from_usb_almost_full = '0'
        ELSE '0';
    mod_adr_in <= ADR;
    mod_data_in_valid <= NOT s_fifo_from_usb_empty;
    s_fifo_from_usb_rden <= mod_data_in_ack AND (NOT s_fifo_from_usb_empty);
    fifo_from_usb : dcfifo_256x36
    PORT MAP(
        rst => usb_reset,
        wr_clk => usb_clk,
        rd_clk => mod_clk,
        din => "0000"&usb_data_in,
        wr_en => s_fifo_from_usb_wren,
        rd_en => s_fifo_from_usb_rden,
        dout(35 DOWNTO 32) => OPEN,
        dout(31 DOWNTO 0) => mod_data_in,
        full => OPEN,
        almost_full => OPEN,
        empty => s_fifo_from_usb_empty,
        almost_empty => OPEN,
        prog_full => s_fifo_from_usb_almost_full,
        prog_empty => OPEN );
    --from module to USB
    mod_data_out_busy <= s_fifo_to_usb_almost_full;
    s_fifo_to_usb_wren <=
        '1' WHEN mod_data_out_valid = '1' AND s_fifo_to_usb_almost_full = '0'
        ELSE '0';
    usb_data_out_valid <= NOT s_fifo_to_usb_empty;
    usb_hold_pktend <= s_hold_pktend;
    s_fifo_to_usb_rden <= NOT usb_data_out_busy AND (NOT s_fifo_to_usb_empty);
    fifo_to_usb : dcfifo_256x36
    PORT MAP(
        rst => usb_reset,
        wr_clk => mod_clk,
        rd_clk => usb_clk,
        din => "000"&mod_hold_pktend&mod_data_out,
        wr_en => s_fifo_to_usb_wren,
        rd_en => s_fifo_to_usb_rden,
        dout(35 DOWNTO 33) => OPEN,
        dout(32) => s_hold_pktend,
        dout(31 DOWNTO 0) => usb_data_out,
        full => OPEN,
        almost_full => OPEN,
        empty => s_fifo_to_usb_empty,
        almost_empty => OPEN,
        prog_full => s_fifo_to_usb_almost_full,
        prog_empty => OPEN );
END ARCHITECTURE arch;

