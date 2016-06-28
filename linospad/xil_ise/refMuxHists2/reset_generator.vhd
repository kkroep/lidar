LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY reset_generator IS
    GENERIC(
        CONSTANT RESET_DURATION_SEC : REAL := 1.0;
        CONSTANT CLOCK_FREQUENCY_MHZ : REAL := 120.0
    );
    PORT(
        SIGNAL clk : IN std_logic;
        SIGNAL ready : IN std_logic;
        SIGNAL reset : OUT std_logic
    );
END ENTITY reset_generator;

ARCHITECTURE arch OF reset_generator IS
    CONSTANT COUNTER_TOP : REAL := RESET_DURATION_SEC*CLOCK_FREQUENCY_MHZ*1000000.0;
    CONSTANT COUNTER_WIDTH : INTEGER := INTEGER(CEIL(LOG2(COUNTER_TOP+1.0)));
    SIGNAL s_reset_counter_reg : unsigned(COUNTER_WIDTH-1 DOWNTO 0)
        := to_unsigned(INTEGER(COUNTER_TOP), COUNTER_WIDTH);
    SIGNAL s_int_reset_reg, s_ext_reset_reg : std_logic := '1';
BEGIN
    reset <= s_ext_reset_reg;
    make_reset : PROCESS(clk, ready)
    BEGIN
        IF ready = '0' THEN
            s_int_reset_reg <= '1';
            s_ext_reset_reg <= '1';
        ELSIF rising_edge(clk) THEN
            IF s_int_reset_reg = '1' THEN
                s_reset_counter_reg <= to_unsigned(INTEGER(COUNTER_TOP), COUNTER_WIDTH);
                s_int_reset_reg <= '0';
            ELSIF s_reset_counter_reg /= 0 THEN
                s_reset_counter_reg <= s_reset_counter_reg - 1;
            ELSE
                s_ext_reset_reg <= '0';
            END IF;
        END IF;
    END PROCESS make_reset;
END ARCHITECTURE arch;

