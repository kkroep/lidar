LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.txt_util.ALL;

ENTITY toplevel_tb IS
END ENTITY toplevel_tb;

ARCHITECTURE arch OF toplevel_tb IS
    COMPONENT toplevel IS
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
    END COMPONENT toplevel;
    
	SIGNAL clk, OSC_48MHz, FX3_PCLK : std_logic := '1';
	SIGNAL FX3_RESET_N, FX3_SLCS_N, FX3_SLOE_N, FX3_SLRD_N, FX3_SLWR_N, FX3_PKTEND_N : std_logic := '1';
	SIGNAL FX3_FLAG_A, FX3_FLAG_B : std_logic := '1';  --to usb full
	SIGNAL FX3_FLAG_C, FX3_FLAG_D : std_logic := '0'; --from usb empty
	SIGNAL FX3_FIFOADR, FX3_GPIO : std_logic_vector(1 DOWNTO 0) := "00";
	SIGNAL FX3_DQ : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'Z');
	SIGNAL GFZ_LP, GFZ_LN, GFZ_RP, GFZ_RN : std_logic_vector(1 TO 70) := (OTHERS=>'0');
	SIGNAL CLK_OUT, CLK_IN, TRIGGER_IN : std_logic := '0';

    SIGNAL fx3_data : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL sim_done : std_logic := '0';
	SIGNAL sim_usb_words_in, sim_usb_words_out : integer := 0;
BEGIN
    OSC_48MHz <= NOT OSC_48MHz AFTER 10.41666 ns WHEN sim_done = '0';
    FX3_PCLK <= NOT FX3_PCLK AFTER 5 ns WHEN sim_done = '0';
    clk <= FX3_PCLK;

    FX3_DQ <= fx3_data WHEN FX3_SLOE_N = '0' ELSE (OTHERS=>'Z');

    MAIN : PROCESS
        PROCEDURE send_usb( CONSTANT adr : IN std_logic_vector(3 DOWNTO 0); CONSTANT data : IN std_logic_vector(31 DOWNTO 0) ) IS
        BEGIN
            WAIT UNTIL falling_edge(clk);
            fx3_data <= X"0"&adr&X"000001"; --header
            FX3_FLAG_C <= '1'; --flag data available
            WAIT UNTIL rising_edge(clk) AND FX3_SLRD_N = '0';
            WAIT UNTIL falling_edge(clk);
            WAIT UNTIL falling_edge(clk);
            WAIT UNTIL falling_edge(clk);
            fx3_data <= data;
            WAIT UNTIL rising_edge(clk) AND FX3_SLRD_N = '0';
            WAIT UNTIL falling_edge(clk);            
            FX3_FLAG_C <= '0';
            WAIT UNTIL falling_edge(clk);
        END PROCEDURE send_usb;
    BEGIN
	    --Uncomment clkin period in clock_control
	    --Set reset_duration_sec to sensible value (0.0000001) in toplevel

        --read firmware id	    
        send_usb( X"F", X"00000000" );

        --configure tdc array
        send_usb( X"4", X"50000183" ); --block_read:block_switch:block_mux:sync_ref:slow_ref:eq_segments:ref_delay:hist_length:global_offset:clk_mul
        send_usb( X"4", X"b0000003" ); --hist_length_out
        send_usb( X"4", X"A0000100" ); --number of words
        send_usb( X"4", X"10000000" ); --clear wait cycles
        send_usb( X"4", X"60000010" ); --acq for 16 cycles

        --switch clock
 		send_usb( X"3", X"30040304" ); --clock to 80MHz
 		send_usb( X"3", X"00000000" ); --read status
        
        --start one acquisition
        send_usb( X"4", X"00000001" ); --switch mux once

        WAIT FOR 5600 ns;
        --pixel 0 on GFZ_RN(69)
        GFZ_RN(69) <= '1', '0' AFTER 3 ns;
        WAIT FOR 12 ns;
        GFZ_RN(69) <= '1', '0' AFTER 3 ns;
        WAIT FOR 12 ns;
        GFZ_RN(69) <= '1', '0' AFTER 3 ns;
        WAIT FOR 12 ns;
        GFZ_RN(69) <= '1', '0' AFTER 3 ns;

--        WAIT FOR 1000 ns;
--        usb_data_out_busy <= '1';
--        WAIT FOR 1000 ns;
--        usb_data_out_busy <= '0';

        --read wait cycles
        send_usb( X"4", X"30000000" ); --get wait cycles

        --wait for data
        WAIT UNTIL sim_usb_words_out >= 259;
        WAIT FOR 200 ns;

        FX3_GPIO(0) <= '1';
        sim_done <= '1';
        REPORT "SIMULATION DONE" SEVERITY FAILURE;
        WAIT;
    END PROCESS MAIN;

    STATS : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF FX3_SLRD_N = '0' THEN
                sim_usb_words_in <= sim_usb_words_in + 1;
            END IF;
            IF FX3_SLWR_N = '0' THEN
                sim_usb_words_out <= sim_usb_words_out + 1;
            END IF;
        END IF;
    END PROCESS STATS;

    FILEOUTPUT : PROCESS(clk)
        VARIABLE v_line : line;
        FILE v_file : text IS OUT "output.txt";
    BEGIN
        IF rising_edge(clk) THEN
            IF FX3_SLWR_N = '0' THEN
                write( v_line, hstr(FX3_DQ)&" at "&time'IMAGE(NOW) );
                writeline(v_file, v_line);
            END IF;
        END IF;
    END PROCESS FILEOUTPUT;

    DUT : toplevel
    PORT MAP(
        OSC_48MHZ => OSC_48MHZ,
        FX3_PCLK => FX3_PCLK,
        FX3_RESET_N => FX3_RESET_N,
        FX3_SLCS_N => FX3_SLCS_N,
        FX3_SLOE_N => FX3_SLOE_N,
        FX3_SLRD_N => FX3_SLRD_N,
        FX3_SLWR_N => FX3_SLWR_N,
        FX3_PKTEND_N => FX3_PKTEND_N,
        FX3_FLAG_A => FX3_FLAG_A,
        FX3_FLAG_B => FX3_FLAG_B,
        FX3_FLAG_C => FX3_FLAG_C,
        FX3_FLAG_D => FX3_FLAG_D,
        FX3_FIFOADR => FX3_FIFOADR,
        FX3_GPIO => FX3_GPIO,
        FX3_DQ => FX3_DQ,
        GFZ_LP => GFZ_LP,
        GFZ_LN => GFZ_LN,
        GFZ_RP => GFZ_RP,
        GFZ_RN => GFZ_RN,
        CLK_OUT => CLK_OUT,
        CLK_IN => CLK_IN,
        TRIGGER_IN => TRIGGER_IN
    );

END ARCHITECTURE arch;

