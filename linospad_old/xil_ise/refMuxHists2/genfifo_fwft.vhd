LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY genfifo_fwft IS
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
END ENTITY genfifo_fwft;

ARCHITECTURE arch OF genfifo_fwft IS
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
    SIGNAL rd_int, empty_int, valid_int : std_logic;
BEGIN
    fifo : genfifo_base
        GENERIC MAP( FIFOWIDTH => FIFOWIDTH, LOG2_FIFODEPTH => LOG2_FIFODEPTH )
        PORT MAP( clk => clk, reset => reset, full => full, empty => empty_int, wr => wr, rd => rd_int, data_in => data_in, data_out => data_out, count => count )
        ;
    
    rd_int <= (NOT empty_int) AND ((NOT valid_int) OR rd);
    empty <= (NOT valid_int);
    
    make_valid : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                valid_int <= '0';
            ELSE
                IF rd_int = '1' THEN
                    valid_int <= '1';
                ELSIF rd = '1' THEN
                    valid_int <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS make_valid;
END ARCHITECTURE arch;

