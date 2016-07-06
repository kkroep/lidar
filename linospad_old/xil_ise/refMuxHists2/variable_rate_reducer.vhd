LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY variable_rate_reducer IS
    PORT(
        SIGNAL clk_tdc                      : IN    std_logic;
        SIGNAL valid_in                     : IN    std_logic;
        SIGNAL code_in                      : IN    std_logic_vector(7 DOWNTO 0);
        
        SIGNAL clk_mod                      : IN    std_logic;
        SIGNAL valid_out                    : OUT   std_logic;
        SIGNAL code_out                     : OUT   std_logic_vector(10 DOWNTO 0);
        
        SIGNAL clk_mul                      : IN    std_logic_vector(1 DOWNTO 0) --"00" = 1to3, "01" = 1to4, "11" = 1to5
    );
END ENTITY variable_rate_reducer;

ARCHITECTURE arch OF variable_rate_reducer IS
    COMPONENT variable_clk_en IS
        PORT (
            SIGNAL clk_base                 : IN    std_logic;
            SIGNAL clk_mul                  : IN    std_logic;
            SIGNAL clk_mul_en_delay         : IN    std_logic_vector(2 DOWNTO 0);
            SIGNAL clk_mul_en               : OUT   std_logic
        );
    END COMPONENT variable_clk_en;
    SIGNAL clk_tdc_en_delay, clk_tdc_en_delay_reg : std_logic_vector(2 DOWNTO 0);
    SIGNAL clk_tdc_en : std_logic;
    SIGNAL s_tdc_data_reg, s_tdc_data_reg_sync, s_mod_data_reg : std_logic_vector(39 DOWNTO 0);
    SIGNAL s_tdc_valid_reg, s_tdc_valid_reg_sync : std_logic_vector(4 DOWNTO 0);
    SIGNAL s_mod_top_valid_reg : std_logic_vector(1 DOWNTO 0);
    SIGNAL s_mod_valid_reg : std_logic_vector(4 DOWNTO 0);
    SIGNAL s_rob_data_reg : std_logic_vector(54 DOWNTO 0);
    SIGNAL s_rob_valid_reg : std_logic_vector(4 DOWNTO 0);
    SIGNAL s_rob_counter_reg : unsigned(2 DOWNTO 0) := (OTHERS=>'0');
BEGIN
    WITH clk_mul SELECT clk_tdc_en_delay <=
        "001" WHEN "00",
        "011" WHEN "01",
        "000" WHEN "11",
        "---" WHEN OTHERS;
    PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            clk_tdc_en_delay_reg <= clk_tdc_en_delay;
        END IF;
    END PROCESS;
    
    enabler : variable_clk_en
    PORT MAP(
        clk_base => clk_mod,
        clk_mul => clk_tdc,
        clk_mul_en_delay => clk_tdc_en_delay_reg,
        clk_mul_en => clk_tdc_en );
    
    gather : PROCESS(clk_tdc)
    BEGIN
        IF rising_edge(clk_tdc) THEN
            s_tdc_data_reg <= s_tdc_data_reg(31 DOWNTO 0)&code_in;
            s_tdc_valid_reg <= s_tdc_valid_reg(3 DOWNTO 0)&valid_in;
            IF clk_tdc_en = '1' THEN
                s_tdc_data_reg_sync <= s_tdc_data_reg;
                s_tdc_valid_reg_sync <= s_tdc_valid_reg;
            END IF;
        END IF;
    END PROCESS gather;
    
    cross_clk : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            s_mod_data_reg <= s_tdc_data_reg_sync;
            s_mod_valid_reg(4) <= (NOT s_mod_top_valid_reg(1)) AND (NOT s_mod_top_valid_reg(0)) AND s_tdc_valid_reg_sync(4);
            s_mod_valid_reg(3) <= (NOT s_mod_top_valid_reg(0)) AND (NOT s_tdc_valid_reg_sync(4)) AND s_tdc_valid_reg_sync(3);
            s_mod_valid_reg(2) <= (NOT s_tdc_valid_reg_sync(4)) AND (NOT s_tdc_valid_reg_sync(3)) AND s_tdc_valid_reg_sync(2);
            s_mod_valid_reg(1) <= (NOT s_tdc_valid_reg_sync(3)) AND (NOT s_tdc_valid_reg_sync(2)) AND s_tdc_valid_reg_sync(1) AND clk_mul(0);
            s_mod_valid_reg(0) <= (NOT s_tdc_valid_reg_sync(2)) AND (NOT s_tdc_valid_reg_sync(1)) AND s_tdc_valid_reg_sync(0) AND clk_mul(1);
            CASE clk_mul IS
            WHEN "00" => s_mod_top_valid_reg <= s_tdc_valid_reg_sync(3 DOWNTO 2);
            WHEN "01" => s_mod_top_valid_reg <= s_tdc_valid_reg_sync(2 DOWNTO 1);
            WHEN "11" => s_mod_top_valid_reg <= s_tdc_valid_reg_sync(1 DOWNTO 0);
            WHEN OTHERS => s_mod_top_valid_reg <= "--";
            END CASE;
        END IF;
    END PROCESS cross_clk;
    
    roundrobin : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            IF (s_rob_counter_reg = "010" AND clk_mul = "00") OR (s_rob_counter_reg = "011" AND clk_mul = "01") OR (s_rob_counter_reg = "100") THEN
                s_rob_counter_reg <= (OTHERS=>'0');
            ELSE
                s_rob_counter_reg <= s_rob_counter_reg + 1;
            END IF;
            CASE s_rob_counter_reg IS
            WHEN "000" =>
                s_rob_valid_reg <= s_mod_valid_reg;
                s_rob_data_reg <= "000"&s_mod_data_reg(39 DOWNTO 32)&"001"&s_mod_data_reg(31 DOWNTO 24)&"010"&s_mod_data_reg(23 DOWNTO 16)&"011"&s_mod_data_reg(15 DOWNTO 8)&"100"&s_mod_data_reg(7 DOWNTO 0);
            WHEN "001" =>
                s_rob_valid_reg <= s_mod_valid_reg(3 DOWNTO 0)&s_mod_valid_reg(4);
                s_rob_data_reg <= "001"&s_mod_data_reg(31 DOWNTO 24)&"010"&s_mod_data_reg(23 DOWNTO 16)&"011"&s_mod_data_reg(15 DOWNTO 8)&"100"&s_mod_data_reg(7 DOWNTO 0)&"000"&s_mod_data_reg(39 DOWNTO 32);
            WHEN "010" =>
                s_rob_valid_reg <= s_mod_valid_reg(2 DOWNTO 0)&s_mod_valid_reg(4 DOWNTO 3);
                s_rob_data_reg <= "010"&s_mod_data_reg(23 DOWNTO 16)&"011"&s_mod_data_reg(15 DOWNTO 8)&"100"&s_mod_data_reg(7 DOWNTO 0)&"000"&s_mod_data_reg(39 DOWNTO 32)&"001"&s_mod_data_reg(31 DOWNTO 24);
            WHEN "011" =>
                s_rob_valid_reg <= s_mod_valid_reg(1 DOWNTO 0)&s_mod_valid_reg(4 DOWNTO 2);
                s_rob_data_reg <= "011"&s_mod_data_reg(15 DOWNTO 8)&"100"&s_mod_data_reg(7 DOWNTO 0)&"000"&s_mod_data_reg(39 DOWNTO 32)&"001"&s_mod_data_reg(31 DOWNTO 24)&"010"&s_mod_data_reg(23 DOWNTO 16);
            WHEN "100" =>
                s_rob_valid_reg <= s_mod_valid_reg(0)&s_mod_valid_reg(4 DOWNTO 1);
                s_rob_data_reg <= "100"&s_mod_data_reg(7 DOWNTO 0)&"000"&s_mod_data_reg(39 DOWNTO 32)&"001"&s_mod_data_reg(31 DOWNTO 24)&"010"&s_mod_data_reg(23 DOWNTO 16)&"011"&s_mod_data_reg(15 DOWNTO 8);
            WHEN OTHERS =>
                s_rob_valid_reg <= (OTHERS=>'-');
                s_rob_data_reg <= (OTHERS=>'-');
            END CASE;
        END IF;
    END PROCESS roundrobin;
    
    output : PROCESS(clk_mod)
    BEGIN
        IF rising_edge(clk_mod) THEN
            valid_out <= s_rob_valid_reg(4) OR s_rob_valid_reg(3) OR s_rob_valid_reg(2) OR s_rob_valid_reg(1) OR s_rob_valid_reg(0);
            IF s_rob_valid_reg(4) = '1' THEN
                code_out <= s_rob_data_reg(54 DOWNTO 44);
            ELSIF s_rob_valid_reg(3) = '1' THEN
                code_out <= s_rob_data_reg(43 DOWNTO 33);
            ELSIF s_rob_valid_reg(2) = '1' THEN
                code_out <= s_rob_data_reg(32 DOWNTO 22);
            ELSIF s_rob_valid_reg(1) = '1' THEN
                code_out <= s_rob_data_reg(21 DOWNTO 11);
            ELSE
                code_out <= s_rob_data_reg(10 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS output;
END ARCHITECTURE arch;

