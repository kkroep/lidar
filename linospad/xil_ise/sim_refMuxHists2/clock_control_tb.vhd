LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY clock_control_tb IS
END ENTITY clock_control_tb;

ARCHITECTURE arch OF clock_control_tb IS
	SIGNAL reset : std_logic := '1';
	SIGNAL clk, clk_1MHz, clk_50MHz, clk_100MHz, clk_400MHz : std_logic := '1';

	SIGNAL usb_adr : std_logic_vector(3 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL usb_data_in : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL usb_data_in_valid, usb_data_in_ack, usb_data_out_valid, usb_data_out_busy : std_logic := '0';
	
	SIGNAL sim_done : std_logic := '0';
	SIGNAL sim_usb_words_in, sim_usb_words_out : integer := 0;

    COMPONENT clock_control IS
        GENERIC (
            CONSTANT ADR        : std_logic_vector(3 DOWNTO 0)
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
            SIGNAL pin_clk_ext          : IN    std_logic; --Connect to reference clock input
            SIGNAL pin_trigger          : IN    std_logic; --Synchronous trigger
            SIGNAL trigger_mod          : OUT   std_logic; --Pulse trigger for low frequencies
            SIGNAL trigger_main         : OUT   std_logic;

            SIGNAL clk_ref              : OUT   std_logic; --Selected reference (int/ext) after PLL (used for referencing)
            SIGNAL clk_mod              : OUT   std_logic; --Slow clock for processing (100MHz, tdc module)
            SIGNAL clk_tdc              : OUT   std_logic; --Fast clock for TDCs (400MHz, delay line and encoder)

            SIGNAL idle_out             : OUT   std_logic
        );
    END COMPONENT clock_control;
    SIGNAL s_idle : std_logic;
BEGIN
    clk_50MHz <= NOT clk_50MHz AFTER 10 ns WHEN sim_done = '0';
	clk_100MHz <= NOT clk_100MHz AFTER 5 ns WHEN sim_done = '0';
	clk_400MHz <= NOT clk_400MHz AFTER 1250 ps WHEN sim_done = '0';
	clk <= clk_100MHz;

	MAIN : PROCESS
		PROCEDURE send_usb( CONSTANT adr : IN std_logic_vector(3 DOWNTO 0); CONSTANT data : IN std_logic_vector(31 DOWNTO 0) ) IS
		BEGIN
			WAIT UNTIL falling_edge(clk);
			usb_adr <= adr;
			usb_data_in <= data;
			usb_data_in_valid <= '1';
			WAIT UNTIL rising_edge(clk) AND usb_data_in_ack = '1';
			WAIT UNTIl falling_edge(clk);
			usb_data_in_valid <= '0';
		END PROCEDURE send_usb;
	BEGIN
	    --Uncomment clkin period in clock_control
		WAIT FOR 50 ns;
		reset <= '0';
		
        --Program 80Mhz clock
 		send_usb( X"0", X"30040304" );
		
		WAIT UNTIL s_idle = '1';
		reset <= '1';
		WAIT FOR 100 ns;
		sim_done <= '1';
		WAIT;
	END PROCESS MAIN;

	STATS : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF usb_data_in_valid = '1' AND usb_data_in_ack = '1' THEN
				sim_usb_words_in <= sim_usb_words_in + 1;
			END IF;
			IF usb_data_out_valid = '1' AND usb_data_out_busy = '0' THEN
				sim_usb_words_out <= sim_usb_words_out + 1;
			END IF;
		END IF;
	END PROCESS STATS;

	DUT : clock_control
	GENERIC MAP(
	    ADR => X"0" )
	PORT MAP(
		clk => clk,
		reset => reset,
		usb_adr_in => usb_adr,
		usb_data_in => usb_data_in,
		usb_data_in_valid => usb_data_in_valid,
		usb_data_in_ack => usb_data_in_ack,
		usb_data_out => OPEN,
		usb_data_out_valid => usb_data_out_valid,
		usb_data_out_busy => usb_data_out_busy,
		
		pin_clk_out => OPEN,
        pin_clk_ext => clk_50MHz,
        pin_trigger => clk_1MHz,
        trigger_mod => OPEN,
        trigger_main => OPEN,
        
        clk_ref => OPEN,
        clk_mod => OPEN,
        clk_tdc => OPEN,
        idle_out => s_idle
	);
	
END ARCHITECTURE arch;

