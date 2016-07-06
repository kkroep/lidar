LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tdc_core IS
    GENERIC(
        TDC_MAX_CODE : integer );
    PORT(
        SIGNAL trigger      : IN    std_logic;
        SIGNAL clk_tdc      : IN    std_logic;

        SIGNAL clk_mod      : IN    std_logic;
        SIGNAL clk_mul      : IN    std_logic_vector(1 DOWNTO 0);
        SIGNAL valid_out    : OUT   std_logic;
        SIGNAL code_out     : OUT   std_logic_vector(10 DOWNTO 0) );
END ENTITY tdc_core;

ARCHITECTURE arch OF tdc_core IS
    COMPONENT delayline IS
        GENERIC(
            CONSTANT NUM_CARRY_ELEMENTS       : integer );
        PORT(
            SIGNAL trigger          : IN    std_logic;
            SIGNAL clk              : IN    std_logic;
            SIGNAL triggered        : OUT   std_logic;
            SIGNAL samples          : OUT   std_logic_vector(NUM_CARRY_ELEMENTS*4 -1 DOWNTO 0) );
    END COMPONENT delayline;

    COMPONENT advtherm2bin IS
        GENERIC(
            CONSTANT TDC_MAX_CODE   :       integer
        );
        PORT(
            SIGNAL clk              : IN    std_logic;
            SIGNAL input            : IN    std_logic_vector(139 DOWNTO 0);
            SIGNAL input_valid      : IN    std_logic;
            SIGNAL output           : OUT   std_logic_vector(7 DOWNTO 0);
            SIGNAL output_valid     : OUT   std_logic
        );
    END COMPONENT advtherm2bin;

    COMPONENT variable_rate_reducer IS
        PORT(
            SIGNAL clk_tdc                      : IN    std_logic;
            SIGNAL valid_in                     : IN    std_logic;
            SIGNAL code_in                      : IN    std_logic_vector(7 DOWNTO 0);
            
            SIGNAL clk_mod                      : IN    std_logic;
            SIGNAL valid_out                    : OUT   std_logic;
            SIGNAL code_out                     : OUT   std_logic_vector(10 DOWNTO 0);
            
            SIGNAL clk_mul                      : IN    std_logic_vector(1 DOWNTO 0) --"00" = 1to3, "01" = 1to4, "11" = 1to5
        );
    END COMPONENT variable_rate_reducer;

    SIGNAL triggered : std_logic;
    SIGNAL s_raw_sample, s_enc_sample : std_logic_vector(((TDC_MAX_CODE+3)/4)*4-1 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL s_enc_valid : std_logic;
    SIGNAL s_enc_code : std_logic_vector(7 DOWNTO 0);

BEGIN

    line : delayline
    GENERIC MAP(
        NUM_CARRY_ELEMENTS => (TDC_MAX_CODE+3)/4 )
    PORT MAP(
        trigger => trigger,
        clk => clk_tdc,
        triggered => triggered,
        samples => s_raw_sample(((TDC_MAX_CODE+3)/4)*4-1 DOWNTO 0) );
    
    s_enc_sample(TDC_MAX_CODE DOWNTO 0) <= s_raw_sample(TDC_MAX_CODE DOWNTO 0);
    enc : advtherm2bin
    GENERIC MAP(
        TDC_MAX_CODE => TDC_MAX_CODE )
    PORT MAP(
        clk => clk_tdc,
        input => s_enc_sample,
        input_valid => triggered,
        output => s_enc_code,
        output_valid => s_enc_valid );
    
    red : variable_rate_reducer
    PORT MAP(
        clk_tdc => clk_tdc,
        valid_in => s_enc_valid,
        code_in => s_enc_code,
        clk_mod => clk_mod,
        valid_out => valid_out,
        code_out => code_out,
        clk_mul => clk_mul );

END ARCHITECTURE arch;

