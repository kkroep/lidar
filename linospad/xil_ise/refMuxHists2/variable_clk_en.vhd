LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY variable_clk_en IS
    PORT (
        SIGNAL clk_base                 : IN    std_logic;
        SIGNAL clk_mul                  : IN    std_logic;
        SIGNAL clk_mul_en_delay         : IN    std_logic_vector(2 DOWNTO 0);
        SIGNAL clk_mul_en               : OUT   std_logic
    );
END ENTITY variable_clk_en;

ARCHITECTURE arch OF variable_clk_en IS
    SIGNAL toggle_reg : std_logic := '0';
    SIGNAL sample_reg : std_logic_vector(1 DOWNTO 0) := "00";
    SIGNAL edge_reg, clk_mul_en_srl, clk_mul_en_reg : std_logic;
BEGIN
    PROCESS(clk_base)
    BEGIN
        IF rising_edge(clk_base) THEN
            toggle_reg <= NOT toggle_reg;
        END IF;
    END PROCESS;
    
    PROCESS(clk_mul)
    BEGIN
        IF rising_edge(clk_mul) THEN
            sample_reg <= sample_reg(0)&toggle_reg;
            edge_reg <= sample_reg(1) XOR sample_reg(0);
            clk_mul_en_reg <= clk_mul_en_srl;
        END IF;
    END PROCESS;
    clk_mul_en <= clk_mul_en_reg;
    
    delay_srl : SRL16E PORT MAP(
        D => edge_reg,
        CE => '1',
        CLK => clk_mul,
        A0 => clk_mul_en_delay(0),
        A1 => clk_mul_en_delay(1),
        A2 => clk_mul_en_delay(2),
        A3 => '0',
        Q => clk_mul_en_srl );
END ARCHITECTURE arch;

