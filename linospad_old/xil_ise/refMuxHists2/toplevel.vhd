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
        
        SIGNAL GFZ_LP                       : IN    std_logic_vector(1 TO 70);
        SIGNAL GFZ_LN                       : IN    std_logic_vector(1 TO 70);
        SIGNAL GFZ_RP                       : IN    std_logic_vector(1 TO 70);
        SIGNAL GFZ_RN                       : IN    std_logic_vector(1 TO 70);
        
        SIGNAL CLK_OUT                      : OUT   std_logic;
        SIGNAL CLK_IN                       : IN    std_logic;
        SIGNAL TRIGGER_IN                   : IN    std_logic
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
    SIGNAL s_clk_48MHz, s_reset_48MHz : std_logic;

    component clk48to100 is
		port
		(	-- Clock in ports
			CLK_IN48           : in     std_logic;
			-- Clock out ports
			CLK_OUT100          : out    std_logic;
			-- Status and control signals
			RESET             : in     std_logic;
			LOCKED            : out    std_logic
		);
    end component clk48to100;

    SIGNAL s_main_clk_100MHz, s_main_clk_100MHz_locked : std_logic;
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
            SIGNAL fx3_dq                       : INOUT std_logic_vector(31 DOWNTO 0)
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
    
	COMPONENT clock_control IS
        GENERIC(
            CONSTANT ADR                : std_logic_vector(3 DOWNTO 0) := X"0"
        );
        PORT(
            SIGNAL clk, reset           : IN    std_logic;

            SIGNAL usb_adr_in           : IN    std_logic_vector(3 DOWNTO 0);
            SIGNAL usb_data_in          : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL usb_data_in_valid    : IN    std_logic;
            SIGNAL usb_data_in_ack      : OUT   std_logic;
            SIGNAL usb_data_out         : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL usb_data_out_valid   : OUT   std_logic;
            SIGNAL usb_data_out_busy    : IN    std_logic;

            SIGNAL pin_clk_out          : OUT   std_logic;
            SIGNAL pin_clk_ext          : IN    std_logic;
            SIGNAL pin_trigger          : IN    std_logic;
            SIGNAL trigger_mod          : OUT   std_logic;
            SIGNAL trigger_main         : OUT   std_logic;

            SIGNAL clk_ref              : OUT   std_logic; --Selected reference (int/ext) after PLL (used for referencing)
            SIGNAL clk_mod              : OUT   std_logic; --Slow clock for processing (100MHz, tdc module)
            SIGNAL clk_tdc              : OUT   std_logic; --Fast clock for TDCs (400MHz, delay line and encoder)

            SIGNAL idle_out             : OUT   std_logic
        );
	END COMPONENT clock_control;
    SIGNAL s_trigger_mod, s_trigger_main, s_clk_ref, s_clk_mod, s_clk_tdc : std_logic;
    
    COMPONENT gfz2lino IS
        PORT(
            SIGNAL GFZ_LP       : IN std_logic_vector(1 TO 70);
            SIGNAL GFZ_LN       : IN std_logic_vector(1 TO 70);
            SIGNAL GFZ_RP       : IN std_logic_vector(1 TO 70);
            SIGNAL GFZ_RN       : IN std_logic_vector(1 TO 70);
            
            SIGNAL LINO_MAIN    : OUT std_logic_vector(255 DOWNTO 0);
            SIGNAL LINO_AUX     : OUT std_logic_vector(7 DOWNTO 0)
        );
    END COMPONENT gfz2lino;
    SIGNAL s_lino_main : std_logic_vector(255 DOWNTO 0);
    SIGNAL s_lino_aux : std_logic_vector(7 DOWNTO 0);

	COMPONENT module_clock_adapter IS
		GENERIC(
			CONSTANT ADR                : std_logic_vector(3 DOWNTO 0) := X"0"
		);
		PORT (
			SIGNAL usb_clk 				: IN 	std_logic;
			SIGNAL usb_reset 			: IN 	std_logic;
	
			SIGNAL usb_adr_in           : IN    std_logic_vector(3 DOWNTO 0);
			SIGNAL usb_data_in          : IN    std_logic_vector(31 DOWNTO 0);
			SIGNAL usb_data_in_valid    : IN    std_logic;
			SIGNAL usb_data_in_ack      : OUT   std_logic;
			SIGNAL usb_data_out         : OUT   std_logic_vector(31 DOWNTO 0);
			SIGNAL usb_data_out_valid   : OUT   std_logic;
			SIGNAL usb_data_out_busy    : IN    std_logic;
			SIGNAL usb_hold_pktend		: OUT	std_logic;
	
			SIGNAL mod_clk				: IN 	std_logic;
			SIGNAL mod_reset			: OUT	std_logic;
			
			SIGNAL mod_adr_in           : OUT   std_logic_vector(3 DOWNTO 0);
			SIGNAL mod_data_in          : OUT   std_logic_vector(31 DOWNTO 0);
			SIGNAL mod_data_in_valid    : OUT   std_logic;
			SIGNAL mod_data_in_ack      : IN    std_logic;
			SIGNAL mod_data_out         : IN    std_logic_vector(31 DOWNTO 0);
			SIGNAL mod_data_out_valid   : IN    std_logic;
			SIGNAL mod_data_out_busy    : OUT   std_logic;
			SIGNAL mod_hold_pktend		: IN	std_logic );
	END COMPONENT module_clock_adapter;
	SIGNAL s_mod_reset : std_logic;
	SIGNAL s_mod_data_in_valid, s_mod_data_in_ack, s_mod_data_out_valid, s_mod_data_out_busy, s_mod_hold_pktend : std_logic;
	SIGNAL s_mod_adr_in : std_logic_vector(3 DOWNTO 0);
	SIGNAL s_mod_data_in, s_mod_data_out : std_logic_vector(31 DOWNTO 0);

    COMPONENT tdc_array IS
        GENERIC (
            CONSTANT ADR        : std_logic_vector(3 DOWNTO 0)
        );
        PORT (
            SIGNAL clk_mod, reset           : IN    std_logic;
            SIGNAL usb_adr_in               : IN    std_logic_vector(3 DOWNTO 0);
            SIGNAL usb_data_in              : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL usb_data_in_valid        : IN    std_logic;
            SIGNAL usb_data_in_ack          : OUT   std_logic;
            SIGNAL usb_data_out             : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL usb_data_out_valid       : OUT   std_logic;
            SIGNAL usb_data_out_busy        : IN    std_logic;
            SIGNAL usb_hold_pktend          : OUT   std_logic;
            
            SIGNAL trigger                  : IN    std_logic;
            SIGNAL clk_ref                  : IN    std_logic;
            SIGNAL clk_tdc                  : IN    std_logic;
            SIGNAL inputs                   : IN    std_logic_vector(255 DOWNTO 0)
        );
    END COMPONENT tdc_array;
    
    COMPONENT intensity IS
        GENERIC (
            CONSTANT ADR        : std_logic_vector(3 DOWNTO 0) := X"0"
        );
        PORT (
            SIGNAL clk                      : IN    std_logic;
            SIGNAL usb_adr_in               : IN    std_logic_vector(3 DOWNTO 0);
            SIGNAL usb_data_in              : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL usb_data_in_valid        : IN    std_logic;
            SIGNAL usb_data_in_ack          : OUT   std_logic;
            SIGNAL usb_data_out             : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL usb_data_out_valid       : OUT   std_logic;
            SIGNAL usb_data_out_busy        : IN    std_logic;
            SIGNAL usb_hold_pktend          : OUT   std_logic;
            
            SIGNAL trigger                  : IN    std_logic;
            SIGNAL pixel_inputs             : IN    std_logic_vector(255 DOWNTO 0)
        );
    END COMPONENT intensity;

    COMPONENT auxintensity IS
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
    END COMPONENT auxintensity;

BEGIN
    clk_buf_48 : IBUFG
        PORT MAP(
            I => OSC_48MHZ,
            O => s_clk_48MHz
        );

    clk_48M_to_100M : clk48to100
        PORT MAP(
            CLK_IN48 => s_clk_48MHz,
            CLK_OUT100 => s_main_clk_100MHz,
            RESET => '0',
            LOCKED => s_main_clk_100MHz_locked
        );

    s_logic_clk <= s_main_clk_100MHz;
    s_logic_ready <= s_main_clk_100MHz_locked AND (NOT FX3_GPIO(0));
    logic_reset_gen : reset_generator
        GENERIC MAP(
            RESET_DURATION_SEC => 0.001,
            CLOCK_FREQUENCY_MHZ => 100.0
        )
        PORT MAP(
            clk => s_logic_clk,
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
            fx3_dq => FX3_DQ
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
            ID => X"20150721"
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

    clkctrl : clock_control
    GENERIC MAP(
        ADR => X"3"
    )
    PORT MAP(
        clk => s_logic_clk,
        reset => s_logic_reset,
        usb_adr_in => s_usb_adr_out_mux,
        usb_data_in => s_usb_data_out_mux,
        usb_data_in_valid => s_usb_data_out_valid_mux,
        usb_data_in_ack => s_usb_data_out_ack_mux(3),
        usb_data_out => s_usb_data_in_mux(3),
        usb_data_out_valid => s_usb_data_in_valid_mux(3),
        usb_data_out_busy => s_usb_data_in_busy_mux(3),

        pin_clk_out => CLK_OUT,
        pin_clk_ext => CLK_IN,
        pin_trigger => TRIGGER_IN,
        trigger_mod => s_trigger_mod,
        trigger_main => s_trigger_main,
        clk_ref => s_clk_ref,
        clk_mod => s_clk_mod,
        clk_tdc => s_clk_tdc,
        idle_out => OPEN
    );

    mapper : gfz2lino
        PORT MAP(
            GFZ_LP => GFZ_LP,
            GFZ_LN => GFZ_LN,
            GFZ_RP => GFZ_RP,
            GFZ_RN => GFZ_RN,
            LINO_MAIN => s_lino_main,
            LINO_AUX => s_lino_aux
        );

    clkadapter : module_clock_adapter
        GENERIC MAP(
            ADR => X"4"
        )
        PORT MAP(
            usb_clk => s_logic_clk,
            usb_reset => s_logic_reset,
            
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(4),
            usb_data_out => s_usb_data_in_mux(4),
            usb_data_out_valid => s_usb_data_in_valid_mux(4),
            usb_data_out_busy => s_usb_data_in_busy_mux(4),
            usb_hold_pktend => s_usb_hold_pktend_mux(4),
            
            mod_clk => s_clk_mod,
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
    
    tdcs : tdc_array
        GENERIC MAP(
            ADR => X"4"
        )
        PORT MAP(
            clk_mod => s_clk_mod,
            reset => s_mod_reset,
            usb_adr_in => s_mod_adr_in,
            usb_data_in => s_mod_data_in,
            usb_data_in_valid => s_mod_data_in_valid,
            usb_data_in_ack => s_mod_data_in_ack,
            usb_data_out => s_mod_data_out,
            usb_data_out_valid => s_mod_data_out_valid,
            usb_data_out_busy => s_mod_data_out_busy,
            usb_hold_pktend => s_mod_hold_pktend,
            
            trigger => s_trigger_mod,
            clk_ref => s_clk_ref,
            clk_tdc => s_clk_tdc,
            inputs => s_lino_main
        );
    
    intensity_counters : intensity
        GENERIC MAP(
            ADR => X"5"
        )
        PORT MAP(
            clk => s_logic_clk,
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(5),
            usb_data_out => s_usb_data_in_mux(5),
            usb_data_out_valid => s_usb_data_in_valid_mux(5),
            usb_data_out_busy => s_usb_data_in_busy_mux(5),
            usb_hold_pktend => s_usb_hold_pktend_mux(5),
            
            trigger => s_trigger_main,
            pixel_inputs => s_lino_main
        );

    aux_intensity_counters : auxintensity
        GENERIC MAP(
            ADR => X"6"
        )
        PORT MAP(
            clk => s_logic_clk,
            reset => s_logic_reset,
            usb_adr_in => s_usb_adr_out_mux,
            usb_data_in => s_usb_data_out_mux,
            usb_data_in_valid => s_usb_data_out_valid_mux,
            usb_data_in_ack => s_usb_data_out_ack_mux(6),
            usb_data_out => s_usb_data_in_mux(6),
            usb_data_out_valid => s_usb_data_in_valid_mux(6),
            usb_data_out_busy => s_usb_data_in_busy_mux(6),
            usb_hold_pktend => s_usb_hold_pktend_mux(6),
            
            trigger => s_trigger_main,
            aux_pixels => s_lino_aux
        );
        
END ARCHITECTURE arch;

