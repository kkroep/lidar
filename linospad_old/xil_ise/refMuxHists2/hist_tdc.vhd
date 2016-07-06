LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--Double histogram generator
--One active, one for readout
ENTITY hist_tdc IS
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
END ENTITY hist_tdc;

ARCHITECTURE arch OF hist_tdc IS
	TYPE hist_mem_t IS ARRAY (0 TO 511) OF unsigned(35 DOWNTO 0);
	TYPE hist_array_t IS ARRAY (0 TO 1) OF hist_mem_t;
	SIGNAL s_hist : hist_array_t := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	TYPE hist_mem_data_t IS ARRAY (0 TO 1) OF unsigned(35 DOWNTO 0);
	SIGNAL s_read_data_reg, s_write_data_reg : hist_mem_data_t;
	TYPE hist_mem_addr_t IS ARRAY (0 TO 1) OF unsigned(8 DOWNTO 0);
	SIGNAL s_read_addr_reg, s_write_addr_reg : hist_mem_addr_t;
	TYPE hist_mem_wordenable_t IS ARRAY (0 TO 1) OF std_logic_vector(1 DOWNTO 0);
	SIGNAL s_word_write_reg : hist_mem_wordenable_t;

	CONSTANT PIPEHIGH : natural := 2;
	SIGNAL s_inc_pipe, s_get_pipe : std_logic_vector(0 TO PIPEHIGH) := (OTHERS=>'0');
	TYPE addr_pipe_t IS ARRAY (0 TO PIPEHIGH) OF unsigned(9 DOWNTO 0);
	SIGNAL s_inc_addr_pipe, s_get_addr_pipe : addr_pipe_t;
	SIGNAL s_sel_pipe : unsigned(0 TO PIPEHIGH) := (OTHERS=>'0');
	TYPE sel_int_t IS ARRAY (0 TO PIPEHIGH) OF integer RANGE 0 TO 1;
	SIGNAL s_sel_inc, s_sel_get : sel_int_t;
	SIGNAL s_comp_reg : std_logic_vector(1 DOWNTO 0);
	SIGNAL s_inc_val_reg : unsigned(1 DOWNTO 0);
	SIGNAL s_store_write_reg : std_logic;
	SIGNAL s_store_data_reg : unsigned(27 DOWNTO 0);
	SIGNAL s_store_addr_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
BEGIN
	make_mem : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			--Memory/Histogram 0
			IF s_word_write_reg(0)(0) = '1' THEN
				s_hist(0)(to_integer(s_write_addr_reg(0)))(17 DOWNTO 0) <= s_write_data_reg(0)(17 DOWNTO 0);
			END IF;
			IF s_word_write_reg(0)(1) = '1' THEN
				s_hist(0)(to_integer(s_write_addr_reg(0)))(35 DOWNTO 18) <= s_write_data_reg(0)(35 DOWNTO 18);
			END IF;
			s_read_data_reg(0) <= s_hist(0)(to_integer(s_read_addr_reg(0)));
			
			--Memory/Histogram 1
			IF s_word_write_reg(1)(0) = '1' THEN
				s_hist(1)(to_integer(s_write_addr_reg(1)))(17 DOWNTO 0) <= s_write_data_reg(1)(17 DOWNTO 0);
			END IF;
			IF s_word_write_reg(1)(1) = '1' THEN
				s_hist(1)(to_integer(s_write_addr_reg(1)))(35 DOWNTO 18) <= s_write_data_reg(1)(35 DOWNTO 18);
			END IF;
			s_read_data_reg(1) <= s_hist(1)(to_integer(s_read_addr_reg(1)));
		END IF;
	END PROCESS make_mem;
	
	make_pipe : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			s_inc_pipe(1 TO PIPEHIGH) <= s_inc_pipe(0 TO PIPEHIGH-1);
			s_inc_pipe(0) <= inc;
			s_inc_addr_pipe(1 TO PIPEHIGH) <= s_inc_addr_pipe(0 TO PIPEHIGH-1);
			s_inc_addr_pipe(0) <= unsigned(inc_addr);
			s_get_pipe(1 TO PIPEHIGH) <= s_get_pipe(0 TO PIPEHIGH-1);
			s_get_pipe(0) <= get;
			s_get_addr_pipe(1 TO PIPEHIGH) <= s_get_addr_pipe(0 TO PIPEHIGH-1);
			s_get_addr_pipe(0) <= unsigned(get_addr)&"0";
			s_sel_pipe(1 TO PIPEHIGH) <= s_sel_pipe(0 TO PIPEHIGH-1);
			IF switch = '1' THEN
				s_sel_pipe(0) <= NOT s_sel_pipe(0);
			END IF;
		END IF;
	END PROCESS make_pipe;
	
	make_sel_helper : FOR i IN 0 TO PIPEHIGH GENERATE
		s_sel_inc(i) <= to_integer(s_sel_pipe(i TO i));
		s_sel_get(i) <= to_integer(NOT s_sel_pipe(i TO i));
	END GENERATE make_sel_helper;
		
	make_doubles : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF s_inc_pipe(0) = '1' AND s_inc_pipe(1) = '1' AND s_inc_addr_pipe(0) = s_inc_addr_pipe(1) AND s_sel_inc(0) = s_sel_inc(1) THEN
				s_comp_reg(0) <= '1';
			ELSE
				s_comp_reg(0) <= '0';
			END IF;
			IF s_inc_pipe(0) = '1' AND s_inc_pipe(2) = '1' AND s_inc_addr_pipe(0) = s_inc_addr_pipe(2) AND s_sel_inc(0) = s_sel_inc(2) THEN
				s_comp_reg(1) <= '1';
			ELSE
				s_comp_reg(1) <= '0';
			END IF;
			
			IF s_comp_reg = "11" THEN
				s_inc_val_reg <= "11";
			ELSIF s_comp_reg = "01" OR s_comp_reg = "10" THEN
				s_inc_val_reg <= "10";
			ELSE
				s_inc_val_reg <= "01";
			END IF;
		END IF;
	END PROCESS;
	
	make_data : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			--Stage 0: initiate memory read
			s_read_addr_reg(s_sel_inc(0)) <= s_inc_addr_pipe(0)(9 DOWNTO 1);
			s_read_addr_reg(s_sel_get(0)) <= s_get_addr_pipe(0)(9 DOWNTO 1);
			
			--Stage 1: memory read

			--Stage 2: initiate writeback

			--Readout
			valid <= s_get_pipe(2);
			--Saturate count 0
			IF s_read_data_reg(s_sel_get(2))(16) = '1' THEN
				count(15 DOWNTO 0) <= (OTHERS=>'1');
			ELSE
				count(15 DOWNTO 0) <= std_logic_vector(s_read_data_reg(s_sel_get(2))(15 DOWNTO 0));
			END IF;
			--Saturate count 1
			IF s_read_data_reg(s_sel_get(2))(34) = '1' THEN
				count(31 DOWNTO 16) <= (OTHERS=>'1');
			ELSE
				count(31 DOWNTO 16) <= std_logic_vector(s_read_data_reg(s_sel_get(2))(33 DOWNTO 18));
			END IF;
			--Clear memory
			s_write_addr_reg(s_sel_get(2)) <= s_get_addr_pipe(2)(9 DOWNTO 1);
			s_write_data_reg(s_sel_get(2)) <= (OTHERS=>'0');
			s_word_write_reg(s_sel_get(2)) <= (OTHERS=>s_get_pipe(2));
			
			IF switch = '1' THEN
			    s_store_addr_reg <= (OTHERS=>'0');
			END IF;
			s_store_write_reg <= stw;
			s_store_data_reg <= unsigned(stw_addr);
			IF s_store_write_reg = '1' THEN
			    s_write_data_reg(s_sel_inc(0))(17 DOWNTO 0) <= "00"&s_store_data_reg(15 DOWNTO 0);
			    s_write_data_reg(s_sel_inc(0))(35 DOWNTO 18) <= "001000"&s_store_data_reg(27 DOWNTO 16);
			    s_write_addr_reg(s_sel_inc(0)) <= s_store_addr_reg;
			    s_word_write_reg(s_sel_inc(0)) <= "11";
			    s_store_addr_reg <= s_store_addr_reg + 1;
			ELSE
    			--Accumulate
    			--Increment 0
    			IF s_read_data_reg(s_sel_inc(2))(16) = '0' THEN
    				s_write_data_reg(s_sel_inc(2))(17 DOWNTO 0) <= s_read_data_reg(s_sel_inc(2))(17 DOWNTO 0) + s_inc_val_reg;
    			ELSE
    				s_write_data_reg(s_sel_inc(2))(17 DOWNTO 0) <= s_read_data_reg(s_sel_inc(2))(17 DOWNTO 0);
    			END IF;
    			--Increment 1
    			IF s_read_data_reg(s_sel_inc(2))(34) = '0' THEN
    				s_write_data_reg(s_sel_inc(2))(35 DOWNTO 18) <= s_read_data_reg(s_sel_inc(2))(35 DOWNTO 18) + s_inc_val_reg;
    			ELSE
    				s_write_data_reg(s_sel_inc(2))(35 DOWNTO 18) <= s_read_data_reg(s_sel_inc(2))(35 DOWNTO 18);
    			END IF;
    			s_write_addr_reg(s_sel_inc(2)) <= s_inc_addr_pipe(2)(9 DOWNTO 1);
    			s_word_write_reg(s_sel_inc(2)) <= (s_inc_pipe(2)&s_inc_pipe(2)) AND (s_inc_addr_pipe(2)(0)&(NOT s_inc_addr_pipe(2)(0)));
			END IF;
			--Stage 3: writeback
		END IF;
	END PROCESS;
END ARCHITECTURE arch;

