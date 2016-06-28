LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY genfifo_fwft_reg IS
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
END ENTITY genfifo_fwft_reg;

ARCHITECTURE arch OF genfifo_fwft_reg IS
    COMPONENT genfifo_base IS
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
    END COMPONENT genfifo_base;
    SIGNAL rd_int, empty_int, out_valid : std_logic;
    SIGNAL fifo_valid, buf_valid, write_buf, write_out : std_logic;
    SIGNAL data_out_int, buf : std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
BEGIN
    fifo : genfifo_base
        GENERIC MAP( FIFOWIDTH => FIFOWIDTH, LOG2_FIFODEPTH => LOG2_FIFODEPTH )
        PORT MAP( clk => clk, reset => reset, full => full, empty => empty_int, wr => wr, rd => rd_int, data_in => data_in, data_out => data_out_int, count => count )
        ;
    
    rd_int <= (NOT empty_int) AND (NOT (out_valid AND fifo_valid AND buf_valid));
    empty <= NOT out_valid;
    write_buf <= '1' WHEN fifo_valid = '1' AND (buf_valid = write_out) ELSE '0';
    write_out <= (rd OR (NOT out_valid)) AND (fifo_valid OR buf_valid);
    
    make_fifo : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                fifo_valid <= '0';
                buf_valid <= '0';
                out_valid <= '0';
            ELSE
                IF write_buf = '1' THEN
                    buf <= data_out_int;
                END IF;
                IF write_out = '1' THEN
                    out_valid <= '1';
                    IF buf_valid = '1' THEN
                        data_out <= buf;
                    ELSE
                        data_out <= data_out_int;
                    END IF;
                ELSIF rd = '1' THEN
                    out_valid <= '0';
                END IF;
                IF rd_int = '1' THEN
                    fifo_valid <= '1';
                ELSIF write_buf = '1' OR write_out = '1' THEN
                    fifo_valid <= '0';
                END IF;
                IF write_buf = '1' THEN
                    buf_valid <= '1';
                ELSIF write_out = '1' THEN
                    buf_valid <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS make_fifo;
END ARCHITECTURE arch;

