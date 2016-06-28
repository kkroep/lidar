LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE std.textio.ALL;
USE work.txt_util.ALL;

ENTITY hist_equalizer_tb IS
END ENTITY hist_equalizer_tb;

ARCHITECTURE arch OF hist_equalizer_tb IS
    SIGNAL reset : std_logic := '1';
    SIGNAL clk, clk_50MHz, clk_100MHz, clk_400MHz : std_logic := '1';

    SIGNAL sim_done : std_logic := '0';
    SIGNAL sim_words_in, sim_words_out : integer := 0;

    COMPONENT hist_equalizer IS
        PORT(
            SIGNAL clk              : IN    std_logic;
            SIGNAL init             : IN    std_logic;
            SIGNAL counts_in        : IN    std_logic_vector(31 DOWNTO 0);
            SIGNAL counts_in_valid  : IN    std_logic;
            SIGNAL counts_out       : OUT   std_logic_vector(31 DOWNTO 0);
            SIGNAL counts_out_valid : OUT   std_logic;
            SIGNAL cmd_mem_wr       : IN    std_logic;
            SIGNAL cmd_mem_wr_addr  : IN    std_logic_vector(13 DOWNTO 0);
            SIGNAL cmd_mem_wr_data  : IN    std_logic_vector(71 DOWNTO 0);
            SIGNAL tdc_coarse_count_max     : IN    std_logic_vector(2 DOWNTO 0);
            SIGNAL idle             : OUT   std_logic
        );
    END COMPONENT hist_equalizer;
    
    SIGNAL counts_in, counts_out : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL counts_in_valid, counts_out_valid, idle : std_logic := '0';
    
    SIGNAL total_counts_in, total_counts_out : integer := 0;
BEGIN
    clk_50MHz <= NOT clk_50MHz AFTER 10 ns WHEN sim_done = '0';
    clk_100MHz <= NOT clk_100MHz AFTER 5 ns WHEN sim_done = '0';
    clk_400MHz <= NOT clk_400MHz AFTER 1250 ps WHEN sim_done = '0';
    clk <= clk_100MHz;

    MAIN : PROCESS
        FILE v_file : text IS IN "hist.txt";
        PROCEDURE next_input IS
            VARIABLE datastr : string(1 TO 8) := "00000000";
            VARIABLE dataslv : std_logic_vector(31 DOWNTO 0);
        BEGIN
            str_read( v_file, datastr );
            dataslv := hex_to_std_logic_vector(datastr);
            counts_in <= dataslv;
        END PROCEDURE next_input;
    BEGIN
        --Write equalizer program to init functions in equalizer architecture
        WAIT FOR 15 ns;
        WAIT UNTIL falling_edge(clk);
        reset <= '0';
        WAIT UNTIL falling_edge(clk) AND idle = '1';

        --Read words and feed to equalizer
        WHILE sim_words_in < 32 LOOP
            WAIT UNTIL falling_edge(clk);
            next_input;
            counts_in_valid <= '1';
        END LOOP;
        counts_in_valid <= '0';

        WAIT FOR 150 ns;
        --WAIT UNTIL rising_edge(clk) AND idle = '1';
        sim_done <= '1';
        WAIT;
    END PROCESS MAIN;

	STATS : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF counts_in_valid = '1' THEN
				sim_words_in <= sim_words_in + 1;
				total_counts_in <= total_counts_in + to_integer("00"&unsigned(counts_in(31 DOWNTO 16)) + unsigned(counts_in(15 DOWNTO 0)));
			END IF;
			IF counts_out_valid = '1' THEN
				sim_words_out <= sim_words_out + 1;
				total_counts_out <= total_counts_out + to_integer("00"&unsigned(counts_out(31 DOWNTO 16)) + unsigned(counts_out(15 DOWNTO 0)));
			END IF;
		END IF;
	END PROCESS STATS;

	DUT : hist_equalizer
	PORT MAP(
		clk => clk,
		init => reset,
		counts_in => counts_in,
		counts_in_valid => counts_in_valid,
		counts_out => counts_out,
		counts_out_valid => counts_out_valid,
		cmd_mem_wr => '0',
		cmd_mem_wr_addr => (OTHERS=>'0'),
		cmd_mem_wr_data => (OTHERS=>'0'),
		tdc_coarse_count_max => "000",
		idle => idle
	);

--    FILEOUTPUT : PROCESS(clk)
--        VARIABLE v_line : line;
--        FILE v_file : text IS OUT "output.txt";
--    BEGIN
--        IF rising_edge(clk) THEN
--            IF counts_out_valid = '1' THEN
--                write( v_line, hstr(counts_out)&" at "&time'IMAGE(NOW) );
--                writeline(v_file, v_line);
--            END IF;
--        END IF;
--    END PROCESS FILEOUTPUT;

END ARCHITECTURE arch;

