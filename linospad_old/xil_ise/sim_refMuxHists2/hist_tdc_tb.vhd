LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hist_tdc_tb IS
END ENTITY hist_tdc_tb;

ARCHITECTURE arch OF hist_tdc_tb IS
	SIGNAL clk : std_logic := '1';

	SIGNAL sim_done : std_logic := '0';

	COMPONENT hist_tdc IS
		PORT(
			SIGNAL clk		: IN	std_logic;
			SIGNAL switch	: IN	std_logic;
    		SIGNAL stw      : IN    std_logic;
    		SIGNAL stw_addr : IN    std_logic_vector(27 DOWNTO 0);
			SIGNAL inc		: IN	std_logic;
			SIGNAL inc_addr	: IN	std_logic_vector(9 DOWNTO 0);
			SIGNAL get		: IN	std_logic;
			SIGNAL get_addr	: IN	std_logic_vector(8 DOWNTO 0);
			SIGNAL count	: OUT	std_logic_vector(31 DOWNTO 0);
			SIGNAL valid	: OUT	std_logic
		);
	END COMPONENT hist_tdc;

	SIGNAL hist_switch, hist_stw, hist_inc, hist_get, hist_valid : std_logic := '0';
	SIGNAL hist_stw_addr : unsigned(27 DOWNTO 0) := X"1234567";
	SIGNAL hist_inc_addr : unsigned(9 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL hist_get_addr : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL hist_count : std_logic_vector(31 DOWNTO 0);
	
BEGIN
	clk <= NOT clk AFTER 5 ns WHEN sim_done = '0';
	
	DUT : hist_tdc PORT MAP(
		clk => clk,
		switch => hist_switch,
		stw => hist_stw,
		stw_addr => std_logic_vector(hist_stw_addr),
		inc => hist_inc,
		inc_addr => std_logic_vector(hist_inc_addr),
		get => hist_get,
		get_addr => std_logic_vector(hist_get_addr),
		count => hist_count,
		valid => hist_valid );

	MAIN : PROCESS
	BEGIN
	    --Increment addr 0
		WAIT UNTIL falling_edge(clk);
		hist_inc <= '1';
		FOR i IN 0 TO 4 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		--Increment addr 1
		hist_inc_addr <= hist_inc_addr + 1;
		FOR i IN 0 TO 4 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		hist_inc <= '0';
		--Switch buffers
		hist_switch <= '1';
		WAIT UNTIL falling_edge(clk);
		hist_switch <= '0';
		FOR i IN 0 TO 1 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		--Read first memory words
		hist_get <= '1';
		hist_get_addr <= (OTHERS=>'0');
		FOR i IN 0 TO 10 LOOP
			WAIT UNTIL falling_edge(clk);
			hist_get_addr <= hist_get_addr + 1;
		END LOOP;
		hist_get <= '0';

		WAIT FOR 100 ns;

        --Increment addr 1
		WAIT UNTIL falling_edge(clk);
		hist_inc <= '1';
		FOR i IN 0 TO 4 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		--Increment addr 2
		hist_inc_addr <= hist_inc_addr + 1;
		FOR i IN 0 TO 4 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		hist_inc <= '0';
		--Switch buffers
		hist_switch <= '1';
		WAIT UNTIL falling_edge(clk);
		hist_switch <= '0';
		FOR i IN 0 TO 1 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		--Read first memory words
		hist_get <= '1';
		hist_get_addr <= (OTHERS=>'0');
		FOR i IN 0 TO 10 LOOP
			WAIT UNTIL falling_edge(clk);
			hist_get_addr <= hist_get_addr + 1;
		END LOOP;
		hist_get <= '0';

		WAIT FOR 100 ns;

        --Store 2 timestamps
		WAIT UNTIL falling_edge(clk);
		hist_stw <= '1';
		WAIT UNTIL falling_edge(clk);
		hist_stw_addr <= hist_stw_addr + 1;
		WAIT UNTIL falling_edge(clk);
		hist_stw <= '0';
		--Switch buffers
		hist_switch <= '1';
		WAIT UNTIL falling_edge(clk);
		hist_switch <= '0';
		FOR i IN 0 TO 1 LOOP
			WAIT UNTIL falling_edge(clk);
		END LOOP;
		--Read first memory words
		hist_get <= '1';
		hist_get_addr <= (OTHERS=>'0');
		FOR i IN 0 TO 10 LOOP
			WAIT UNTIL falling_edge(clk);
			hist_get_addr <= hist_get_addr + 1;
		END LOOP;
		hist_get <= '0';

		sim_done <= '1';
		WAIT;
	END PROCESS MAIN;
	
END ARCHITECTURE arch;

