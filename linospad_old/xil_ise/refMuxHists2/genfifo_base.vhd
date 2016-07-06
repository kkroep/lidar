LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--Generic single clock fifo for 2**N elements
--Use flags for operation, count is NOT cycle accurate
ENTITY genfifo_base IS
	GENERIC(
		CONSTANT FIFOWIDTH				: natural := 32;
		CONSTANT LOG2_FIFODEPTH			: natural := 9 );
	PORT(
		SIGNAL clk, reset				: IN	std_logic;
		SIGNAL full, empty				: OUT	std_logic;
		SIGNAL wr, rd					: IN	std_logic;
		SIGNAL data_in					: IN	std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
		SIGNAL data_out					: OUT	std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
		SIGNAL count					: OUT	std_logic_vector(LOG2_FIFODEPTH DOWNTO 0) );
END ENTITY genfifo_base;

ARCHITECTURE arch OF genfifo_base IS
	TYPE   t_fifo_mem IS ARRAY (integer RANGE 0 TO (2**LOG2_FIFODEPTH)-1) OF std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
	SIGNAL s_fifo_mem : t_fifo_mem;
	SIGNAL s_read_ptr_reg, s_write_ptr_reg : unsigned(LOG2_FIFODEPTH-1 DOWNTO 0) := (OTHERS=>'0');
	SIGNAL s_element_count_reg : unsigned(LOG2_FIFODEPTH DOWNTO 0) := (OTHERS=>'0');
BEGIN
	make_fifo : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				s_write_ptr_reg <= (OTHERS=>'0');
				s_read_ptr_reg <= (OTHERS=>'0');
			ELSE
				IF wr = '1' THEN
					s_fifo_mem(to_integer(s_write_ptr_reg)) <= data_in;
					s_write_ptr_reg <= s_write_ptr_reg + 1;
				END IF;
				IF rd = '1' THEN
					data_out <= s_fifo_mem(to_integer(s_read_ptr_reg));
					s_read_ptr_reg <= s_read_ptr_reg + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS make_fifo;

	full <= s_element_count_reg(s_element_count_reg'HIGH);
	make_element_count : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				empty <= '1';
				s_element_count_reg <= (OTHERS=>'0');
			ELSE
				IF wr = '1' AND rd = '0' THEN
					empty <= '0';
					s_element_count_reg <= s_element_count_reg + 1;
				ELSIF wr = '0' AND rd = '1' THEN
					s_element_count_reg <= s_element_count_reg - 1;
					IF s_element_count_reg = 1 THEN
						empty <= '1';
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS make_element_count;
	count <= std_logic_vector(s_element_count_reg);
END ARCHITECTURE arch;

