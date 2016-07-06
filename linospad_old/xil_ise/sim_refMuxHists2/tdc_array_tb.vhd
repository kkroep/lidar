LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
--USE work.txt_util.ALL;

ENTITY tdc_array_tb IS
END ENTITY tdc_array_tb;

ARCHITECTURE arch OF tdc_array_tb IS
	SIGNAL reset : std_logic := '1';
	SIGNAL clk, clk_50MHz, clk_66MHz, clk_80MHz, clk_100MHz, clk_133MHz, clk_400MHz : std_logic := '1';

	SIGNAL usb_adr : std_logic_vector(3 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL usb_data_in, usb_data_out : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL usb_data_in_valid, usb_data_in_ack, usb_data_out_valid, usb_data_out_busy : std_logic := '0';
	
	SIGNAL sim_done : std_logic := '0';
	SIGNAL sim_usb_words_in, sim_usb_words_out : integer := 0;

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
    
    SIGNAL s_lino_main : std_logic_vector(255 DOWNTO 0) := (OTHERS=>'0');
BEGIN
    clk_50MHz <= NOT clk_50MHz AFTER 10 ns WHEN sim_done = '0';
    clk_66MHz <= NOT clk_66MHz AFTER 7.5 ns WHEN sim_done = '0';
    clk_80MHz <= NOT clk_80MHz AFTER 6.25 ns WHEN sim_done = '0';
    clk_100MHz <= NOT clk_100MHz AFTER 5 ns WHEN sim_done = '0';
    clk_133MHz <= NOT clk_133MHz AFTER 3.75 ns WHEN sim_done = '0';
    clk_400MHz <= NOT clk_400MHz AFTER 1.25 ns WHEN sim_done = '0';
    clk <= clk_80MHz;

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
        WAIT FOR 15 ns;
        reset <= '0';

        send_usb( X"0", X"50000183" ); --block_read:block_switch:block_mux:sync_ref:slow_ref:eq_segments:ref_delay:hist_length:global_offset:clk_mul
        send_usb( X"0", X"b0000003" ); --hist_length_out
        WAIT FOR 800 ns; --configuration forwarding
        send_usb( X"0", X"A0000100" ); --number of words
        send_usb( X"0", X"10000000" ); --clear wait cycles
        send_usb( X"0", X"60000010" ); --acq for 16 cycles
        send_usb( X"0", X"00000001" ); --switch mux once

        WAIT FOR 24 ns;
        s_lino_main(0) <= '1', '0' AFTER 3 ns;
        WAIT FOR 12 ns;
        s_lino_main(0) <= '1', '0' AFTER 3 ns;
        WAIT FOR 12 ns;
        s_lino_main(0) <= '1', '0' AFTER 3 ns;
        WAIT FOR 12 ns;
        s_lino_main(0) <= '1', '0' AFTER 3 ns;

--        WAIT FOR 1000 ns;
--        usb_data_out_busy <= '1';
--        WAIT FOR 1000 ns;
--        usb_data_out_busy <= '0';

        send_usb( X"0", X"30000000" ); --get wait cycles
--        WAIT UNTIL sim_usb_words_out >= 2000;
--        WAIT UNTIL rising_edge(clk) AND usb_data_out_valid = '0';
        WAIT FOR 200 ns;

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

--    FILEOUTPUT : PROCESS(clk)
--        VARIABLE v_line : line;
--        FILE v_file : text IS OUT "output.txt";
--    BEGIN
--        IF rising_edge(clk) THEN
--            IF usb_data_out_valid = '1' AND usb_data_out_busy = '0' THEN
--                write( v_line, hstr(usb_data_out)&" at "&time'IMAGE(NOW) );
--                writeline(v_file, v_line);
--            END IF;
--        END IF;
--    END PROCESS FILEOUTPUT;

    DUT : tdc_array
    GENERIC MAP(
        ADR => X"0" )
    PORT MAP(
        clk_mod => clk,
        reset => reset,
        usb_adr_in => usb_adr,
        usb_data_in => usb_data_in,
        usb_data_in_valid => usb_data_in_valid,
        usb_data_in_ack => usb_data_in_ack,
        usb_data_out => usb_data_out,
        usb_data_out_valid => usb_data_out_valid,
        usb_data_out_busy => usb_data_out_busy,
        usb_hold_pktend => OPEN,

        trigger => '0',
        clk_ref => clk_80MHz,
        clk_tdc => clk_400MHz,
        inputs => s_lino_main
    );

END ARCHITECTURE arch;

