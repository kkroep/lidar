LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY unisim;
USE unisim.vcomponents.all;

ENTITY fx3_interface IS
    GENERIC(
        CONSTANT N_ADR_BITS                 : natural := 4;
        CONSTANT READ_FIFO                  : std_logic_vector(1 DOWNTO 0) := "11";
        CONSTANT WRITE_FIFO                 : std_logic_vector(1 DOWNTO 0) := "00"
    );
    PORT(
        SIGNAL reset                        : IN    std_logic; --logic_clk
        SIGNAL logic_clk                    : IN    std_logic;
        
        --Internal
        SIGNAL adr_out                      : OUT   std_logic_vector(N_ADR_BITS-1 DOWNTO 0);
        SIGNAL data_out                     : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL data_out_valid               : OUT   std_logic;
        SIGNAL data_out_ack                 : IN    std_logic;
        SIGNAL data_in                      : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL data_in_valid                : IN    std_logic;
        SIGNAL data_in_busy                 : OUT   std_logic;
        SIGNAL hold_pktend                  : IN    std_logic;
        
        --FX3
        --FX3 (connect to pads)
        SIGNAL fx3_pclk                     : IN    std_logic;
        SIGNAL fx3_reset_n                  : OUT   std_logic;
        SIGNAL fx3_slcs_n                   : OUT   std_logic;
        SIGNAL fx3_sloe_n                   : OUT   std_logic;
        SIGNAL fx3_slrd_n                   : OUT   std_logic;
        SIGNAL fx3_slwr_n                   : OUT   std_logic;
        SIGNAL fx3_pktend_n                 : OUT   std_logic;
        SIGNAL fx3_in_empty_n               : IN    std_logic; --FLAG C
        SIGNAL fx3_in_almost_empty_n        : IN    std_logic; --FLAG D
        SIGNAL fx3_out_full_n               : IN    std_logic; --FLAG A
        SIGNAL fx3_out_almost_full_n        : IN    std_logic; --FLAG B
        SIGNAL fx3_fifoadr                  : OUT   std_logic_vector(1 DOWNTO 0);
        SIGNAL fx3_dq                       : INOUT std_logic_vector(31 DOWNTO 0);
        
        SIGNAL fx3_clk                      : OUT   std_logic; --buffered 100MHz clock from FX3
        
        --Statistics (synchronous to fx3_clk)
        SIGNAL stats_read                   : OUT   std_logic;
        SIGNAL stats_read_single            : OUT   std_logic;
        SIGNAL stats_read_burst             : OUT   std_logic;
        SIGNAL stats_write                  : OUT   std_logic;
        SIGNAL stats_write_single           : OUT   std_logic;
        SIGNAL stats_write_burst            : OUT   std_logic;
        SIGNAL stats_pktend                 : OUT   std_logic
    );
END ENTITY fx3_interface;

ARCHITECTURE arch OF fx3_interface IS
    SIGNAL fx3_pclk_dcm_in, fx3_pclk_dcm_reset, fx3_pclk_dcm_fb, fx3_pclk_dcm_clk0, fx3_pclk_dcm_clkfx, fx3_pclk_dcm_locked, s_fx3_pclk, s_fx3_pclk_inv : std_logic;
    SIGNAL fx3_pclk_dcm_status : std_logic_vector(7 DOWNTO 0);
    SIGNAL s_fx3_in_empty_n_delayed, s_fx3_in_empty_n_reg, s_fx3_in_almost_empty_n_delayed, s_fx3_in_almost_empty_n_reg : std_logic;
    SIGNAL s_fx3_out_full_n_delayed, s_fx3_out_full_n_reg, s_fx3_out_almost_full_n_delayed, s_fx3_out_almost_full_n_reg : std_logic;
    SIGNAL s_fx3_slcs_n : std_logic;
    SIGNAL s_fx3_sloe_n, s_fx3_slrd_n : std_logic;
    SIGNAL s_fx3_slwr_n, s_fx3_pktend_n : std_logic;
    SIGNAL s_fx3_fifoadr : std_logic_vector(1 DOWNTO 0);
    SIGNAL s_fx3_dq_in_delayed, s_fx3_dq_in_reg, s_fx3_dq_out, s_fx3_dq_t : std_logic_vector(31 DOWNTO 0); --internal signals
    SIGNAL fx3_dq_in, fx3_dq_out, fx3_dq_t : std_logic_vector(31 DOWNTO 0); --IOBUF signals

    TYPE   t_usbside_state IS (
        USB_RESET,
        USB_IDLE,
        USB_READ_PREP,
        USB_READ_SINGLE,
        USB_READ_BURST,
        USB_READ_CAPTURE,
        USB_WRITE_PREP,
        USB_WRITE_SINGLE,
        USB_WRITE_BURST,
        USB_WRITE_FINISH );
    SIGNAL s_usbside_state_reg : t_usbside_state := USB_RESET;
    SIGNAL s_fx3_clk_reset_reg : std_logic_vector(3 DOWNTO 0) := (OTHERS=>'1');
    SIGNAL s_delay_count_reg : unsigned(3 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_read_capture_reg : unsigned(3 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_fx3_in_almost_empty_n_late_reg : std_logic;
    SIGNAL s_write_start_reg : std_logic;
    CONSTANT WRITE_START_TIMEOUT : unsigned(3 DOWNTO 0) := X"9";
    SIGNAL s_write_start_timeout_counter_reg : unsigned(3 DOWNTO 0);
    
    TYPE   t_userside_state IS (ADR, DATA);
    SIGNAL s_userside_state_reg : t_userside_state := ADR;
    SIGNAL s_data_word_counter_reg : unsigned(23 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_data_in_busy_reg : std_logic;

    SIGNAL s_fifo_from_usb_rden : std_logic;
    SIGNAL s_fifo_from_usb_wren_reg : std_logic := '0';
    SIGNAL s_fifo_from_usb_data_in_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_fifo_from_usb_data_out : std_logic_vector(35 DOWNTO 0);
    SIGNAL s_fifo_from_usb_empty, s_fifo_from_usb_almost_full : std_logic;

    SIGNAL s_fifo_to_usb_rden, s_fifo_to_usb_wren_reg : std_logic;
    SIGNAL s_fifo_to_usb_data_in_reg : std_logic_vector(35 DOWNTO 0);
    SIGNAL s_fifo_to_usb_data_out : std_logic_vector(35 DOWNTO 0);
    SIGNAL s_fifo_to_usb_empty, s_fifo_to_usb_almost_empty, s_fifo_to_usb_almost_full : std_logic;

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
    
BEGIN
    make_pclk_ibuf : IBUFG PORT MAP( I => fx3_pclk, O => fx3_pclk_dcm_in );
    make_pclk_dcm : DCM_SP
        GENERIC MAP(
            CLK_FEEDBACK => "1X",
            CLKFX_DIVIDE => 2,
            CLKFX_MULTIPLY => 2,
            CLKIN_DIVIDE_BY_2 => FALSE,
            --CLKIN_PERIOD => 10.000,
            CLKOUT_PHASE_SHIFT => "FIXED",
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
            PHASE_SHIFT => 25
        )
        PORT MAP(
            CLKIN => fx3_pclk_dcm_in,
            CLKFB => fx3_pclk_dcm_fb,
            RST => fx3_pclk_dcm_reset,
            PSEN => '0',
            PSINCDEC => '0',
            PSCLK => '0',
            CLK0 => fx3_pclk_dcm_clk0,
            CLKFX => fx3_pclk_dcm_clkfx,
            LOCKED => fx3_pclk_dcm_locked,
            STATUS => fx3_pclk_dcm_status
        );
    fx3_pclk_dcm_reset <= (NOT fx3_pclk_dcm_locked) AND fx3_pclk_dcm_status(2);
    make_fb_bufg : BUFG PORT MAP( I => fx3_pclk_dcm_clk0, O => fx3_pclk_dcm_fb );
    make_pclk_bufg : BUFG PORT MAP( I => fx3_pclk_dcm_clkfx, O => s_fx3_pclk );
    s_fx3_pclk_inv <= NOT s_fx3_pclk;
    
    --fx3 clock domain reset
    make_fx3_clk_reset : PROCESS(s_fx3_pclk, reset)
    BEGIN
        IF reset = '1' THEN
            s_fx3_clk_reset_reg <= (OTHERS=>'1');
        ELSIF rising_edge(s_fx3_pclk) THEN
            s_fx3_clk_reset_reg <= (NOT fx3_pclk_dcm_locked)&s_fx3_clk_reset_reg(3 DOWNTO 1);
        END IF;
    END PROCESS make_fx3_clk_reset;

    --fx3 outputs (delayed through output registers)
    s_fx3_slcs_n <= '0' WHEN s_usbside_state_reg /= USB_RESET
                        ELSE '1';
    s_fx3_sloe_n <= '0' WHEN s_usbside_state_reg = USB_READ_SINGLE
                          OR s_usbside_state_reg = USB_READ_BURST
                          OR s_usbside_state_reg = USB_READ_CAPTURE
                        ELSE '1';
    s_fx3_slrd_n <= '0' WHEN s_usbside_state_reg = USB_READ_SINGLE
                          OR s_usbside_state_reg = USB_READ_BURST
                        ELSE '1';
    s_fx3_dq_t <= (OTHERS=>'0') WHEN s_usbside_state_reg = USB_WRITE_SINGLE
                                  OR s_usbside_state_reg = USB_WRITE_BURST
                                ELSE (OTHERS=>'1');
    s_fx3_slwr_n <= '0' WHEN s_usbside_state_reg = USB_WRITE_SINGLE
                          OR s_usbside_state_reg = USB_WRITE_BURST
                        ELSE '1';
    s_fx3_pktend_n <= '0' WHEN s_fifo_to_usb_data_out(32) = '0' AND s_fifo_to_usb_almost_empty = '1'
                           AND (s_usbside_state_reg = USB_WRITE_SINGLE OR s_usbside_state_reg = USB_WRITE_BURST)
                          ELSE '1';
    s_fx3_fifoadr <= WRITE_FIFO WHEN s_usbside_state_reg = USB_WRITE_PREP
                                  OR s_usbside_state_reg = USB_WRITE_SINGLE
                                  OR s_usbside_state_reg = USB_WRITE_BURST
                                ELSE READ_FIFO;
    s_fx3_dq_out <= s_fifo_to_usb_data_out(31 DOWNTO 0);
    
    --USB side state-machine
    s_fifo_to_usb_rden <= '1' WHEN s_usbside_state_reg = USB_WRITE_SINGLE
                                OR s_usbside_state_reg = USB_WRITE_BURST
                              ELSE '0';
    make_usbside_state : PROCESS(s_fx3_pclk)
    BEGIN
        IF rising_edge(s_fx3_pclk) THEN
            IF s_fx3_clk_reset_reg(0) = '1' THEN
                s_usbside_state_reg <= USB_RESET;
                s_read_capture_reg <= (OTHERS=>'0');
                s_fifo_from_usb_wren_reg <= '0';
                s_write_start_reg <= '0';
                s_write_start_timeout_counter_reg <= WRITE_START_TIMEOUT;
            ELSE
                --Register and delay signals
                s_fx3_in_almost_empty_n_late_reg <= s_fx3_in_almost_empty_n_reg;
                
                --Capture data
                s_fifo_from_usb_data_in_reg <= s_fx3_dq_in_reg;
                s_fifo_from_usb_wren_reg <= s_read_capture_reg(3);
                s_read_capture_reg <= s_read_capture_reg(2 DOWNTO 0)&'0';

                --Delay first word on write
                IF s_write_start_timeout_counter_reg /= 0 AND s_write_start_reg = '0' AND s_fifo_to_usb_empty = '0' THEN
                    s_write_start_timeout_counter_reg <= s_write_start_timeout_counter_reg - 1;
                ELSIF s_write_start_timeout_counter_reg = 0 THEN
                    s_write_start_reg <= '1';
                    s_write_start_timeout_counter_reg <= WRITE_START_TIMEOUT;
                END IF;

                --Generic state machine delay
                IF s_delay_count_reg /= 0 THEN
                    s_delay_count_reg <= s_delay_count_reg - 1;
                END IF;

                CASE s_usbside_state_reg IS
                WHEN USB_RESET =>
                    s_usbside_state_reg <= USB_IDLE;
                WHEN USB_IDLE =>
                    IF s_fx3_in_empty_n_reg = '1' AND s_fifo_from_usb_almost_full = '0' THEN
                        s_usbside_state_reg <= USB_READ_PREP;
                    ELSIF s_fx3_out_full_n_reg = '1' AND s_fifo_to_usb_empty = '0' AND s_write_start_reg = '1' THEN
                        s_usbside_state_reg <= USB_WRITE_PREP;
                    END IF;
                WHEN USB_READ_PREP =>
                    IF s_fx3_in_almost_empty_n_reg = '1' THEN
                        s_usbside_state_reg <= USB_READ_BURST;
                    ELSE
                        s_usbside_state_reg <= USB_READ_SINGLE;
                    END IF;
                WHEN USB_READ_SINGLE =>
                    s_read_capture_reg(0) <= '1';
                    s_usbside_state_reg <= USB_READ_CAPTURE;
                WHEN USB_READ_BURST =>
                    s_read_capture_reg(0) <= '1';
                    IF s_fifo_from_usb_almost_full = '1' OR s_fx3_in_almost_empty_n_late_reg = '0' THEN
                        s_usbside_state_reg <= USB_READ_CAPTURE;
                    END IF;
                WHEN USB_READ_CAPTURE =>
                    IF s_read_capture_reg = 0 THEN
                        s_usbside_state_reg <= USB_IDLE;
                    END IF;
                WHEN USB_WRITE_PREP =>
                    IF s_fx3_out_almost_full_n_reg = '1' THEN
                        s_usbside_state_reg <= USB_WRITE_BURST;
                    ELSE
                        s_usbside_state_reg <= USB_WRITE_SINGLE;
                    END IF;
                WHEN USB_WRITE_SINGLE =>
                    s_delay_count_reg <= X"4";
                    s_usbside_state_reg <= USB_WRITE_FINISH;
                WHEN USB_WRITE_BURST =>
                    s_delay_count_reg <= X"4";
                    IF s_fifo_to_usb_almost_empty = '1' OR s_fx3_out_almost_full_n_reg = '0' THEN
                        s_usbside_state_reg <= USB_WRITE_FINISH;
                    END IF;
                WHEN USB_WRITE_FINISH =>
                    s_write_start_reg <= '0';
                    IF s_delay_count_reg = 0 THEN
                        s_usbside_state_reg <= USB_IDLE;
                    END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS make_usbside_state;

    --Statistics
    fx3_clk <= s_fx3_pclk;
    stats_read <= '1' WHEN s_usbside_state_reg = USB_READ_SINGLE OR s_usbside_state_reg = USB_READ_BURST ELSE '0';
    stats_read_single <= '1' WHEN s_usbside_state_reg = USB_READ_PREP AND s_fx3_in_almost_empty_n_reg = '0' ELSE '0';
    stats_read_burst <= '1' WHEN s_usbside_state_reg = USB_READ_PREP AND s_fx3_in_almost_empty_n_reg = '1' ELSE '0';
    stats_write <= '1' WHEN s_usbside_state_reg = USB_WRITE_SINGLE OR s_usbside_state_reg = USB_WRITE_BURST ELSE '0';
    stats_write_single <= '1' WHEN s_usbside_state_reg = USB_WRITE_PREP AND s_fx3_out_almost_full_n_reg = '0' ELSE '0';
    stats_write_burst <= '1' WHEN s_usbside_state_reg = USB_WRITE_PREP AND s_fx3_out_almost_full_n_reg = '1' ELSE '0';
    stats_pktend <= NOT s_fx3_pktend_n;

    --user side state-machine
    data_in_busy <= s_data_in_busy_reg;
    data_out <= s_fifo_from_usb_data_out(31 DOWNTO 0);
    data_out_valid <= '1' WHEN s_fifo_from_usb_empty = '0' AND s_userside_state_reg = DATA ELSE '0';
    s_fifo_from_usb_rden <= '1' WHEN s_fifo_from_usb_empty = '0' AND (data_out_ack = '1' OR s_userside_state_reg = ADR) ELSE '0';
    make_userside_state : PROCESS(logic_clk)
    BEGIN
        IF rising_edge(logic_clk) THEN
            IF reset = '1' THEN
                adr_out <= (OTHERS=>'0');
                s_userside_state_reg <= ADR;
                s_data_word_counter_reg <= (OTHERS=>'0');
                s_data_in_busy_reg <= '1';
            ELSE
                --Receive data for computer
                s_data_in_busy_reg <= s_fifo_to_usb_almost_full;
                s_fifo_to_usb_data_in_reg <= "000"&hold_pktend&data_in;
                s_fifo_to_usb_wren_reg <= (NOT s_data_in_busy_reg) AND data_in_valid;
                --Send data to modules
                IF s_userside_state_reg = ADR AND s_fifo_from_usb_empty = '0' THEN
                    adr_out <= s_fifo_from_usb_data_out(24+N_ADR_BITS-1 DOWNTO 24);
                    s_data_word_counter_reg <= unsigned(s_fifo_from_usb_data_out(23 DOWNTO 0));
                    IF unsigned(s_fifo_from_usb_data_out(23 DOWNTO 0)) /= 0 THEN
                        s_userside_state_reg <= DATA;
                    END IF;
                ELSIF s_userside_state_reg = DATA AND s_fifo_from_usb_empty = '0' AND data_out_ack = '1' THEN
                    s_data_word_counter_reg <= s_data_word_counter_reg - 1;
                    IF s_data_word_counter_reg = 1 THEN
                        s_userside_state_reg <= ADR;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS make_userside_state;

    --FIFO connections to user side
    fifo_from_usb : dcfifo_256x36
    PORT MAP(
        rst => reset,
        wr_clk => s_fx3_pclk,
        rd_clk => logic_clk,
        din(35 DOWNTO 32) => "0000",
        din(31 DOWNTO 0) => s_fifo_from_usb_data_in_reg,
        wr_en => s_fifo_from_usb_wren_reg,
        rd_en => s_fifo_from_usb_rden,
        dout => s_fifo_from_usb_data_out,
        full => OPEN,
        almost_full => OPEN,
        empty => s_fifo_from_usb_empty,
        almost_empty => OPEN,
        prog_full => s_fifo_from_usb_almost_full,
        prog_empty => OPEN
    );

    fifo_to_usb : dcfifo_256x36
    PORT MAP(
        rst => reset,
        wr_clk => logic_clk,
        rd_clk => s_fx3_pclk,
        din => s_fifo_to_usb_data_in_reg,
        wr_en => s_fifo_to_usb_wren_reg,
        rd_en => s_fifo_to_usb_rden,
        dout => s_fifo_to_usb_data_out,
        full => OPEN,
        almost_full => OPEN,
        empty => s_fifo_to_usb_empty,
        almost_empty => s_fifo_to_usb_almost_empty,
        prog_full => s_fifo_to_usb_almost_full,
        prog_empty => OPEN
    );

    --Instantiate IDDR2/ODDR2 to use IOB registers
    make_fx3_in_empty_n_delayed : IODELAY2
    GENERIC MAP(
        DATA_RATE => "DDR",
        DELAY_SRC => "IDATAIN",
        IDELAY_TYPE => "DEFAULT",
        IDELAY_VALUE => 0
    )
    PORT MAP(
        CAL => '0',
        CE => '0',
        CLK => '0',
        DATAOUT => s_fx3_in_empty_n_delayed,
        IDATAIN => fx3_in_empty_n,
        INC => '0',
        IOCLK0 => '0',
        IOCLK1 => '0',
        ODATAIN => '0',
        RST => '0',
        T => '1'
    );
    make_fx3_in_empty_n : IDDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT_Q0 => '0',
        INIT_Q1 => '0'
    )
    PORT MAP (
        Q0 => s_fx3_in_empty_n_reg,
        Q1 => OPEN,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D => s_fx3_in_empty_n_delayed,
        R => '0',
        S => '0'
    );

    make_fx3_in_almost_empty_n_delayed : IODELAY2
    GENERIC MAP(
        DATA_RATE => "DDR",
        DELAY_SRC => "IDATAIN",
        IDELAY_TYPE => "DEFAULT",
        IDELAY_VALUE => 0
    )
    PORT MAP(
        CAL => '0',
        CE => '0',
        CLK => '0',
        DATAOUT => s_fx3_in_almost_empty_n_delayed,
        IDATAIN => fx3_in_almost_empty_n,
        INC => '0',
        IOCLK0 => '0',
        IOCLK1 => '0',
        ODATAIN => '0',
        RST => '0',
        T => '1'
    );
    make_fx3_in_almost_empty_n : IDDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT_Q0 => '0',
        INIT_Q1 => '0'
    )
    PORT MAP (
        Q0 => s_fx3_in_almost_empty_n_reg,
        Q1 => OPEN,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D => s_fx3_in_almost_empty_n_delayed,
        R => '0',
        S => '0'
    );

    make_fx3_out_full_n_delayed : IODELAY2
    GENERIC MAP(
        DATA_RATE => "DDR",
        DELAY_SRC => "IDATAIN",
        IDELAY_TYPE => "DEFAULT",
        IDELAY_VALUE => 0
    )
    PORT MAP(
        CAL => '0',
        CE => '0',
        CLK => '0',
        DATAOUT => s_fx3_out_full_n_delayed,
        IDATAIN => fx3_out_full_n,
        INC => '0',
        IOCLK0 => '0',
        IOCLK1 => '0',
        ODATAIN => '0',
        RST => '0',
        T => '1'
    );
    make_fx3_out_full_n : IDDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT_Q0 => '0',
        INIT_Q1 => '0'
    )
    PORT MAP (
        Q0 => s_fx3_out_full_n_reg,
        Q1 => OPEN,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D => s_fx3_out_full_n_delayed,
        R => '0',
        S => '0'
    );

    make_fx3_out_almost_full_n_delayed : IODELAY2
    GENERIC MAP(
        DATA_RATE => "DDR",
        DELAY_SRC => "IDATAIN",
        IDELAY_TYPE => "DEFAULT",
        IDELAY_VALUE => 0
    )
    PORT MAP(
        CAL => '0',
        CE => '0',
        CLK => '0',
        DATAOUT => s_fx3_out_almost_full_n_delayed,
        IDATAIN => fx3_out_almost_full_n,
        INC => '0',
        IOCLK0 => '0',
        IOCLK1 => '0',
        ODATAIN => '0',
        RST => '0',
        T => '1'
    );
    make_fx3_out_almost_full_n : IDDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT_Q0 => '0',
        INIT_Q1 => '0'
    )
    PORT MAP (
        Q0 => s_fx3_out_almost_full_n_reg,
        Q1 => OPEN,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D => s_fx3_out_almost_full_n_delayed,
        R => '0',
        S => '0'
    );

    make_fx3_dq_in : FOR i IN 0 TO 31 GENERATE
        DLY : IODELAY2
        GENERIC MAP(
            DATA_RATE => "DDR",
            DELAY_SRC => "IDATAIN",
            IDELAY_TYPE => "DEFAULT",
            IDELAY_VALUE => 0
        )
        PORT MAP(
            CAL => '0',
            CE => '0',
            CLK => '0',
            DATAOUT => s_fx3_dq_in_delayed(i),
            IDATAIN => fx3_dq_in(i),
            INC => '0',
            IOCLK0 => '0',
            IOCLK1 => '0',
            ODATAIN => '0',
            RST => '0',
            T => '1'
        );
        FF : IDDR2
        GENERIC MAP (
            DDR_ALIGNMENT => "C0",
            INIT_Q0 => '0',
            INIT_Q1 => '0'
        )
        PORT MAP (
            Q0 => s_fx3_dq_in_reg(i),
            Q1 => OPEN,
            C0 => s_fx3_pclk,
            C1 => s_fx3_pclk_inv,
            CE => '1',
            D => s_fx3_dq_in_delayed(i),
            R => '0',
            S => '0'
        );
    END GENERATE make_fx3_dq_in;

    fx3_reset_n <= '1';
    
    make_fx3_slcs_n : ODDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT => '1',
        SRTYPE => "ASYNC"
    )
    PORT MAP (
        Q => fx3_slcs_n,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D0 => s_fx3_slcs_n,
        D1 => s_fx3_slcs_n,
        R => '0',
        S => '0'
    );
    
    make_fx3_sloe_n : ODDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT => '1',
        SRTYPE => "ASYNC"
    )
    PORT MAP (
        Q => fx3_sloe_n,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D0 => s_fx3_sloe_n,
        D1 => s_fx3_sloe_n,
        R => '0',
        S => '0'
    );
    
    make_fx3_slrd_n : ODDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT => '1',
        SRTYPE => "ASYNC"
    )
    PORT MAP (
        Q => fx3_slrd_n,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D0 => s_fx3_slrd_n,
        D1 => s_fx3_slrd_n,
        R => '0',
        S => '0'
    );
    
    make_fx3_slwr_n : ODDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT => '1',
        SRTYPE => "ASYNC"
    )
    PORT MAP (
        Q => fx3_slwr_n,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D0 => s_fx3_slwr_n,
        D1 => s_fx3_slwr_n,
        R => '0',
        S => '0'
    );
    
    make_fx3_pktend_n : ODDR2
    GENERIC MAP (
        DDR_ALIGNMENT => "C0",
        INIT => '1',
        SRTYPE => "ASYNC"
    )
    PORT MAP (
        Q => fx3_pktend_n,
        C0 => s_fx3_pclk,
        C1 => s_fx3_pclk_inv,
        CE => '1',
        D0 => s_fx3_pktend_n,
        D1 => s_fx3_pktend_n,
        R => '0',
        S => '0'
    );
    
    make_fx3_fifoadr : FOR i IN 0 TO 1 GENERATE
        INST : ODDR2
        GENERIC MAP (
            DDR_ALIGNMENT => "C0",
            INIT => '1',
            SRTYPE => "ASYNC"
        )
        PORT MAP (
            Q => fx3_fifoadr(i),
            C0 => s_fx3_pclk,
            C1 => s_fx3_pclk_inv,
            CE => '1',
            D0 => s_fx3_fifoadr(i),
            D1 => s_fx3_fifoadr(i),
            R => '0',
            S => '0'
        );
    END GENERATE make_fx3_fifoadr;

    make_fx3_dq_out : FOR i IN 0 TO 31 GENERATE
        INST : ODDR2
        GENERIC MAP (
            DDR_ALIGNMENT => "C0",
            INIT => '0',
            SRTYPE => "ASYNC"
        )
        PORT MAP (
            Q => fx3_dq_out(i),
            C0 => s_fx3_pclk,
            C1 => s_fx3_pclk_inv,
            CE => '1',
            D0 => s_fx3_dq_out(i),
            D1 => s_fx3_dq_out(i),
            R => '0',
            S => '0'
        );
    END GENERATE make_fx3_dq_out;
    
    make_fx3_dq_t : FOR i IN 0 TO 31 GENERATE
        INST : ODDR2
        GENERIC MAP (
            DDR_ALIGNMENT => "C0",
            INIT => '1',
            SRTYPE => "ASYNC"
        )
        PORT MAP (
            Q => fx3_dq_t(i),
            C0 => s_fx3_pclk,
            C1 => s_fx3_pclk_inv,
            CE => '1',
            D0 => s_fx3_dq_t(i),
            D1 => s_fx3_dq_t(i),
            R => '0',
            S => '0'
        );
    END GENERATE make_fx3_dq_t;

    --I/O DDR to IOBUF connection
    make_fx3_dq : FOR i IN 0 TO 31 GENERATE
        fx3_dq(i) <= fx3_dq_out(i) WHEN fx3_dq_t(i) = '0' ELSE 'Z';
    END GENERATE;
    fx3_dq_in <= fx3_dq;
END ARCHITECTURE arch;
