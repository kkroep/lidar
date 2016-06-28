LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY clock_freq_estimator IS
    GENERIC(
        CONSTANT REF_TICKS_PER_MSEC  : integer := 100_000
    );
    PORT(
        SIGNAL clk, reset           : IN    std_logic;

        SIGNAL ext_clk              : IN    std_logic;
        SIGNAL measured_ticks       : OUT   std_logic_vector(31 DOWNTO 0)
    );
END ENTITY clock_freq_estimator;

ARCHITECTURE arch OF clock_freq_estimator IS
    SIGNAL s_msec_counter_reg : unsigned(31 DOWNTO 0);
    SIGNAL s_msec_pulse_reg, s_msec_pulse_sync_reg, s_ext_reset_active_reg : std_logic;
    SIGNAL s_ext_reset_reg : std_logic_vector(2 DOWNTO 0);
    SIGNAL s_ext_count_reg, s_ext_counter_reg : unsigned(31 DOWNTO 0);
BEGIN
    make_ext_reset : PROCESS(ext_clk, s_msec_pulse_reg)
    BEGIN
        IF s_msec_pulse_reg = '1' THEN
            s_msec_pulse_sync_reg <= '0';
            s_ext_reset_reg <= "111";
        ELSIF rising_edge(ext_clk) THEN
            s_ext_reset_reg <= "0"&s_ext_reset_reg(2 DOWNTO 1);
            IF s_ext_reset_reg = "011" THEN
                s_msec_pulse_sync_reg <= '1';
            ELSE
                s_msec_pulse_sync_reg <= '0';
            END IF;
        END IF;
    END PROCESS make_ext_reset;

    make_count : PROCESS(ext_clk)
    BEGIN
        IF rising_edge(ext_clk) THEN
            IF s_msec_pulse_sync_reg = '1' THEN
                s_ext_count_reg <= s_ext_counter_reg;
                s_ext_counter_reg <= (OTHERS=>'0');
            ELSIF s_ext_counter_reg(31) = '0' THEN
                s_ext_counter_reg <= s_ext_counter_reg + 1;
            END IF;
        END IF;
    END PROCESS make_count;
    
    make_msec_pulse : PROCESS(clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
	        IF reset = '1' THEN
    	        s_msec_pulse_reg <= '1';
    	        s_msec_counter_reg <= (OTHERS=>'0');
    	    ELSE
    	    	s_ext_reset_active_reg <= s_ext_reset_reg(0);
				IF s_msec_counter_reg = REF_TICKS_PER_MSEC THEN
					s_msec_pulse_reg <= '1';
					s_msec_counter_reg <= (OTHERS=>'0');
					IF s_ext_reset_active_reg = '0' THEN
						measured_ticks <= std_logic_vector(s_ext_count_reg);
					ELSE
						measured_ticks <= (OTHERS=>'0');
					END IF;
				ELSE
					s_msec_pulse_reg <= '0';
					s_msec_counter_reg <= s_msec_counter_reg + 1;
				END IF;
			END IF;
        END IF;
    END PROCESS make_msec_pulse;
END ARCHITECTURE arch;

