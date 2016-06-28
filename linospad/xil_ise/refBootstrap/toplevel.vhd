LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

USE work.usbmux_package.ALL;

ENTITY toplevel IS
    PORT(
        SIGNAL OSC_48MHZ                    : IN    std_logic;

        SIGNAL FX3_PCLK                     : IN    std_logic;
        SIGNAL FX3_RESET_N                  : OUT   std_logic;
        SIGNAL FX3_SLCS_N                   : OUT   std_logic;
        SIGNAL FX3_SLOE_N                   : OUT   std_logic;
        SIGNAL FX3_SLRD_N                   : OUT   std_logic;
        SIGNAL FX3_SLWR_N                   : OUT   std_logic;
        SIGNAL FX3_PKTEND_N                 : OUT   std_logic;
        SIGNAL FX3_FLAG_A                   : IN    std_logic;
        SIGNAL FX3_FLAG_B                   : IN    std_logic;
        SIGNAL FX3_FLAG_C                   : IN    std_logic;
        SIGNAL FX3_FLAG_D                   : IN    std_logic;
        SIGNAL FX3_FIFOADR                  : OUT   std_logic_vector(1 DOWNTO 0);
        SIGNAL FX3_GPIO                     : IN    std_logic_vector(1 DOWNTO 0);
        SIGNAL FX3_DQ                       : INOUT std_logic_vector(31 DOWNTO 0);
        
        SIGNAL SPI_CSN                      : INOUT std_logic;
        SIGNAL SPI_SCK                      : INOUT std_logic;
        SIGNAL SPI_MOSI                     : INOUT std_logic;
        SIGNAL SPI_MISO                     : IN    std_logic;
        SIGNAL SPI_WPN                      : IN    std_logic;
        SIGNAL SPI_HOLDN                    : IN    std_logic;
        
        SIGNAL CLK100MHZ_OUT                : OUT   std_logic
    );
END ENTITY toplevel;

ARCHITECTURE arch OF toplevel IS
    COMPONENT reset_generator IS
        GENERIC(
            CONSTANT RESET_DURATION_SEC : REAL := 0.2;
            CONSTANT CLOCK_FREQUENCY_MHZ : REAL := 48.0
        );
        PORT(
            SIGNAL clk : IN std_logic;
            SIGNAL ready : IN std_logic;
            SIGNAL reset : OUT std_logic
        );
    END COMPONENT reset_generator;
    SIGNAL s_clk_48MHz : std_logic;

    component clk48to100 is
    port
     (-- Clock in ports
      CLK_IN1           : in     std_logic;
      -- Clock out ports
      CLK_OUT1          : out    std_logic;
      -- Status and control signals
      RESET             : in     std_logic;
      LOCKED            : out    std_logic
     );
    end component clk48to100;

    SIGNAL s_clk_100MHz, s_clk_100MHz_locked : std_logic;
    SIGNAL s_logic_ready, s_logic_clk, s_logic_reset : std_logic;

    COMPONENT fx3_interface IS
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
    END COMPONENT fx3_interface;
    SIGNAL s_usb_adr_out : std_logic_vector(3 DOWNTO 0);
    SIGNAL s_usb_data_out : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_usb_data_out_valid, s_usb_data_out_ack : std_logic;
    SIGNAL s_usb_data_in : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_usb_data_in_valid, s_usb_data_in_busy, s_usb_hold_pktend : std_logic;

    COMPONENT usbmux IS
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
    END COMPONENT usbmux;
    SIGNAL s_usb_adr_out_mux : std_logic_vector(3 DOWNTO 0);
    SIGNAL s_usb_data_out_mux : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_usb_data_out_valid_mux : std_logic;
    SIGNAL s_usb_data_out_ack_mux : std_logic_vector(15 DOWNTO 0) := (OTHERS=>'1');
    SIGNAL s_usb_data_in_busy_mux : std_logic_vector(15 DOWNTO 0) := (OTHERS=>'1');
    SIGNAL s_usb_hold_pktend_mux : std_logic_vector(15 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_usb_data_in_valid_mux : std_logic_vector(15 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_usb_data_in_mux : usbmux_data_in_array_t := (OTHERS=>(OTHERS=>'0'));
    
    COMPONENT systemid IS
        GENERIC (
            CONSTANT ADR        : std_logic_vector(3 DOWNTO 0);
            CONSTANT ID         : std_logic_vector(31 DOWNTO 0)
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
    END COMPONENT systemid;
    
    COMPONENT loopback IS
        GENERIC(
            CONSTANT ADR                    : std_logic_vector(3 DOWNTO 0)
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
    END COMPONENT loopback;
        
    COMPONENT simplespi IS
        GENERIC (
            CONSTANT ADR        : std_logic_vector(3 DOWNTO 0)
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
    END COMPONENT simplespi;

    COMPONENT datasinksource IS
        GENERIC(
            CONSTANT ADR                    : std_logic_vector(3 DOWNTO 0)
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
    END COMPONENT datasinksource;

    COMPONENT module_clock_adapter IS
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
    END COMPONENT module_clock_adapter;
    SIGNAL s_mod_reset : std_logic;
    SIGNAL s_mod_data_in_valid, s_mod_data_in_ack, s_mod_data_out_valid, s_mod_data_out_busy, s_mod_hold_pktend : std_logic;
    SIGNAL s_mod_adr_in : std_logic_vector(3 DOWNTO 0);
    SIGNAL s_mod_data_in, s_mod_data_out : std_logic_vector(31 DOWNTO 0);
    
    COMPONENT fx3_stats IS
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
    END COMPONENT fx3_stats;
    SIGNAL s_stats_clk, s_stats_read, s_stats_read_single, s_stats_read_burst : std_logic;
    SIGNAL s_stats_write, s_stats_write_single, s_stats_write_burst, s_stats_pktend : std_logic;
BEGIN
    clk_buf : IBUFG
        PORT MAP(
            I => OSC_48MHZ,
            O => s_clk_48MHz
        );

    dcm_48M_to_100M : clk48to100
        PORT MAP(
            CLK_IN1 => s_clk_48MHz,
            CLK_OUT1 => s_clk_100MHz,
            RESET => '0',
            LOCKED => s_clk_100MHz_locked
        );

    s_logic_clk <= s_clk_100MHz;
    s_logic_ready <= s_clk_100MHz_locked AND (NOT FX3_GPIO(0));
    logic_reset_gen : reset_generator
        GENERIC MAP(
            RESET_DURATION_SEC => 0.001,
            CLOCK_FREQUENCY_MHZ => 100.0
        )
        PORT MAP(
            clk => s_clk_100MHz,
            ready => s_logic_ready,
            reset => s_logic_reset
        );

    fx3 : fx3_interface
        GENERIC MAP(
            N_ADR_BITS => 4,
            READ_FIFO => "11",
            WRITE_FIFO => "00"
        )
        PORT MAP(
            reset => s_logic_reset,
            logic_clk => s_logic_clk,
            
            --Internal
            adr_out => s_usb_adr_out,
            data_out => s_usb_data_out,
            data_out_valid => s_usb_data_out_valid,
            data_out_ack => s_usb_data_out_ack,
            data_in => s_usb_data_in,
            data_in_valid => s_usb_data_in_valid,
            data_in_busy => s_usb_data_in_busy,
            hold_pktend => s_usb_hold_pktend,
            
            --FX3
            fx3_pclk => FX3_PCLK,
            fx3_reset_n => FX3_RESET_N,
            fx3_slcs_n => FX3_SLCS_N,
            fx3_sloe_n => FX3_SLOE_N,
            fx3_slrd_n => FX3_SLRD_N,
            fx3_slwr_n => FX3_SLWR_N,
            fx3_pktend_n => FX3_PKTEND_N,
            fx3_in_empty_n => FX3_FLAG_C,
            fx3_in_almost_empty_n => FX3_FLAG_D,
            fx3_out_full_n => FX3_FLAG_A,
            fx3_out_almost_full_n => FX3_FLAG_B,
            fx3_fifoadr => FX3_FIFOADR,
            fx3_dq => FX3_DQ,
            
            fx3_clk => s_stats_clk,
            
            --Statistics
            stats_read => s_stats_read,
            stats_read_single => s_stats_read_single,
            stats_read_burst => s_stats_read_burst,
            stats_write => s_stats_write,
            stats_write_single => s_stats_write_single,
            stats_write_burst => s_stats_write_burst,
            stats_pktend => s_stats_pktend
        );

    mux : usbmux
    PORT MAP(
        clk => s_logic_clk,
        reset => s_logic_reset,
    
        usb_adr_out => s_usb_adr_out,
        usb_data_out => s_usb_data_out,
        usb_data_out_valid => s_usb_data_out_valid,
        usb_data_out_ack => s_usb_data_out_ack,
        
        usb_data_in => s_usb_data_in,
        usb_data_in_valid => s_usb_data_in_valid,
        usb_data_in_busy => s_usb_data_in_busy,
        usb_hold_pktend => s_usb_hold_pktend,

        usb_adr_out_mux => s_usb_adr_out_mux,
        usb_data_out_mux => s_usb_data_out_mux,
        usb_data_out_valid_mux => s_usb_data_out_valid_mux,
        usb_data_out_ack_mux => s_usb_data_out_ack_mux,
        usb_data_in_busy_mux => s_usb_data_in_busy_mux,
        usb_hold_pktend_mux => s_usb_hold_pktend_mux,
        usb_data_in_valid_mux => s_usb_data_in_valid_mux,
        usb_data_in_mux => s_usb_data_in_mux
    );

    id : systemid
        GENERIC MAP(
            ADR => X"F",
            ID => X"DEADBEEF"
        )
        PORT MAP(
            clk => s_logic_clk,
            reset => s_logic_reset,
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(15),
            usb_data_out => s_usb_data_in_mux(15),
            usb_data_out_valid => s_usb_data_in_valid_mux(15),
            usb_data_out_busy => s_usb_data_in_busy_mux(15)
        );

    lb : loopback
        GENERIC MAP(
            ADR => X"E"
        )
        PORT MAP(
            clk => s_logic_clk,
            reset => s_logic_reset,
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(14),
            usb_data_out => s_usb_data_in_mux(14),
            usb_data_out_valid => s_usb_data_in_valid_mux(14),
            usb_data_out_busy => s_usb_data_in_busy_mux(14)
        );

    spi : simplespi
        GENERIC MAP(
            ADR => X"D"
        )
        PORT MAP(
            clk => s_logic_clk,
            reset => s_logic_reset,
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(13),
            usb_data_out => s_usb_data_in_mux(13),
            usb_data_out_valid => s_usb_data_in_valid_mux(13),
            usb_data_out_busy => s_usb_data_in_busy_mux(13),
            
            CSN => SPI_CSN,
            SCK => SPI_SCK,
            MOSI => SPI_MOSI,
            MISO => SPI_MISO
        );

    datagen : datasinksource
        GENERIC MAP(
            ADR => X"C"
        )
        PORT MAP(
            clk => s_logic_clk,
            reset => s_logic_reset,
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(12),
            usb_data_out => s_usb_data_in_mux(12),
            usb_data_out_valid => s_usb_data_in_valid_mux(12),
            usb_data_out_busy => s_usb_data_in_busy_mux(12)
        );

    CLKOUT : ODDR2 PORT MAP(
            Q => CLK100MHZ_OUT,
            C0 => s_clk_100MHz,
            C1 => NOT s_clk_100MHz,
            CE => '1',
            D0 => '1',
            D1 => '0',
            R => '0',
            S => '0'
        );

    clkadapter : module_clock_adapter
        GENERIC MAP(
            ADR => X"0"
        )
        PORT MAP(
            usb_clk => s_logic_clk,
            usb_reset => s_logic_reset,
            
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(0),
            usb_data_out => s_usb_data_in_mux(0),
            usb_data_out_valid => s_usb_data_in_valid_mux(0),
            usb_data_out_busy => s_usb_data_in_busy_mux(0),
            usb_hold_pktend => s_usb_hold_pktend_mux(0),
            
            mod_clk => s_stats_clk,
            mod_reset => s_mod_reset,
            
            mod_adr_in => s_mod_adr_in,
            mod_data_in => s_mod_data_in,
            mod_data_in_valid => s_mod_data_in_valid,
            mod_data_in_ack => s_mod_data_in_ack,
            mod_data_out => s_mod_data_out,
            mod_data_out_valid => s_mod_data_out_valid,
            mod_data_out_busy => s_mod_data_out_busy,
            mod_hold_pktend => s_mod_hold_pktend
        );

    s_mod_hold_pktend <= '0';
    stats : fx3_stats
        GENERIC MAP(
            ADR => X"0"
        )
        PORT MAP(
            reset => s_mod_reset,
            usb_adr_in => s_mod_adr_in,
            usb_data_in => s_mod_data_in,
            usb_data_in_valid => s_mod_data_in_valid,
            usb_data_in_ack => s_mod_data_in_ack,
            usb_data_out => s_mod_data_out,
            usb_data_out_valid => s_mod_data_out_valid,
            usb_data_out_busy => s_mod_data_out_busy,
            
            stats_clk => s_stats_clk,
            stats_read => s_stats_read,
            stats_read_single => s_stats_read_single,
            stats_read_burst => s_stats_read_burst,
            stats_write => s_stats_write,
            stats_write_single => s_stats_write_single,
            stats_write_burst => s_stats_write_burst,
            stats_pktend => s_stats_pktend
        );
END ARCHITECTURE arch;

