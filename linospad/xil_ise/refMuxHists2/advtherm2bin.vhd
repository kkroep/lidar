LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY advtherm2bin IS
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
END ENTITY advtherm2bin;

ARCHITECTURE arch OF advtherm2bin IS
    FUNCTION count_ones (X : std_logic_vector) RETURN natural IS
        VARIABLE ret : natural := 0;
    BEGIN
        FOR i IN X'low TO X'high LOOP
            IF X(i) = '1' THEN
                ret := ret+1;
            END IF;
        END LOOP;
        RETURN ret;
    END count_ones;
    
    SIGNAL input_valid_reg : std_logic;
    SIGNAL input_reg : std_logic_vector(139 DOWNTO 0);
    
    SIGNAL valid_stage1_reg : std_logic;
    SIGNAL result_stage1_reg : std_logic_vector(1 DOWNTO 0);
    SIGNAL decide_stage1 : std_logic_vector(1 DOWNTO 0);
    SIGNAL output_stage1_reg : std_logic_vector(51 DOWNTO 0);
    
    SIGNAL valid_stage2_reg : std_logic;
    SIGNAL result_stage2_reg : std_logic_vector(3 DOWNTO 0);
    SIGNAL decide_stage2 : std_logic_vector(1 DOWNTO 0);
    SIGNAL output_stage2_reg : std_logic_vector(23 DOWNTO 0);
    
    SIGNAL valid_stage3_reg : std_logic;
    SIGNAL result_stage3_reg : unsigned(3 DOWNTO 0);
    SIGNAL output_stage3_reg : unsigned(11 DOWNTO 0);
    
    SIGNAL valid_stage4_reg : std_logic;
    SIGNAL result_stage4_reg : unsigned(11 DOWNTO 0);
    
    SIGNAL valid_stage5_reg : std_logic;
    SIGNAL recode_stage5 : unsigned(3 DOWNTO 0);
    SIGNAL result_stage5_reg : unsigned(9 DOWNTO 0);
    
    SIGNAL valid_stage6_reg : std_logic;
    SIGNAL result_stage6_reg : unsigned(8 DOWNTO 0);
BEGIN
    decide_stage1 <= input_reg(91)&input_reg(47);
    decide_stage2 <= output_stage1_reg(35)&output_stage1_reg(19);
    WITH result_stage4_reg(11 DOWNTO 8) SELECT recode_stage5 <=
        "0000" WHEN "0000",
        "0010" WHEN "0001",
        "0100" WHEN "0011",
        "0101" WHEN "0100",
        "0111" WHEN "0101",
        "1001" WHEN "0111",
        "1010" WHEN "1100",
        "1100" WHEN "1101",
        "1110" WHEN "1111",
        "----" WHEN OTHERS;
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            input_reg <= input;
            input_valid_reg <= input_valid;
            
            valid_stage1_reg <= input_valid_reg;
            result_stage1_reg <= decide_stage1;
            CASE decide_stage1 IS
                WHEN "00" => 
                    output_stage1_reg <= input_reg(51 DOWNTO 0);
                WHEN "01" =>
                    output_stage1_reg <= input_reg(95 DOWNTO 44);
                WHEN "11" =>
                    output_stage1_reg <= input_reg(139 DOWNTO 88);
                WHEN OTHERS =>
                    output_stage1_reg <= (OTHERS=>'-');
            END CASE;
            
            valid_stage2_reg <= valid_stage1_reg;
            result_stage2_reg <= result_stage1_reg&decide_stage2;
            CASE decide_stage2 IS
                WHEN "00" =>
                    output_stage2_reg <= output_stage1_reg(23 DOWNTO 0);
                WHEN "01" =>
                    output_stage2_reg <= output_stage1_reg(39 DOWNTO 16);
                WHEN "11" =>
                    output_stage2_reg <= X"0"&output_stage1_reg(51 DOWNTO 32);
                WHEN OTHERS =>
                    output_stage2_reg <= (OTHERS=>'-');
            END CASE;
            
            valid_stage3_reg <= valid_stage2_reg;
            result_stage3_reg <= unsigned(result_stage2_reg);
            output_stage3_reg <= 
                to_unsigned(count_ones(output_stage2_reg(23 DOWNTO 18)),3)
                & to_unsigned(count_ones(output_stage2_reg(17 DOWNTO 12)),3)
                & to_unsigned(count_ones(output_stage2_reg(11 DOWNTO 6)),3)
                & to_unsigned(count_ones(output_stage2_reg(5 DOWNTO 0)),3);
            
            valid_stage4_reg <= valid_stage3_reg;
            result_stage4_reg(11 DOWNTO 8) <= result_stage3_reg; --decide bits
            result_stage4_reg(7 DOWNTO 4) <= ("0"&output_stage3_reg(11 DOWNTO 9))+("0"&output_stage3_reg(8 DOWNTO 6));
            result_stage4_reg(3 DOWNTO 0) <= ("0"&output_stage3_reg(5 DOWNTO 3))+("0"&output_stage3_reg(2 DOWNTO 0));
            
            valid_stage5_reg <= valid_stage4_reg;
            result_stage5_reg(9 DOWNTO 6) <= recode_stage5; --weight 16 & weight 4
            result_stage5_reg(5 DOWNTO 4) <= ("0"&result_stage4_reg(7))+("0"&result_stage4_reg(3))+("0"&result_stage4_reg(10)); --weight 8
            result_stage5_reg(3 DOWNTO 0) <= ("0"&result_stage4_reg(6 DOWNTO 4))+("0"&result_stage4_reg(2 DOWNTO 0));
            
            valid_stage6_reg <= valid_stage5_reg;
            result_stage6_reg(8 DOWNTO 5) <= ("0"&result_stage5_reg(9 DOWNTO 7))+("0"&result_stage5_reg(5)); --weight 16
            result_stage6_reg(4 DOWNTO 0) <= ("0"&result_stage5_reg(3 DOWNTO 0))+("0"&result_stage5_reg(4)&result_stage5_reg(6)&"00");
            
            output_valid <= valid_stage6_reg;
            output <= std_logic_vector((result_stage6_reg(8 DOWNTO 5)+("000"&result_stage6_reg(4)))&result_stage6_reg(3 DOWNTO 0));
        END IF;
    END PROCESS;
END ARCHITECTURE arch;

