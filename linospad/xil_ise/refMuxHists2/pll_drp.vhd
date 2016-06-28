--XAPP879 VHDL version, 1.1.2014

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pll_drp IS
    GENERIC(
        --CONFIG 1: 50MHz (100MHz)
        S1_BANDWIDTH            : string    := "LOW";
        
        S1_CLKFBOUT_MULT        : integer   := 16;
        S1_CLKFBOUT_PHASE       : integer   := 0;
        S1_DIVCLK_DIVIDE        : integer   := 1;
        
        S1_CLKOUT0_DIVIDE       : integer   := 16;
        S1_CLKOUT0_PHASE        : integer   := 0;
        S1_CLKOUT0_DUTY         : integer   := 50000;
        S1_CLKOUT1_DIVIDE       : integer   := 8;
        S1_CLKOUT1_PHASE        : integer   := 0;
        S1_CLKOUT1_DUTY         : integer   := 50000;
        S1_CLKOUT2_DIVIDE       : integer   := 2;
        S1_CLKOUT2_PHASE        : integer   := 0;
        S1_CLKOUT2_DUTY         : integer   := 50000;
        S1_CLKOUT3_DIVIDE       : integer   := 1;
        S1_CLKOUT3_PHASE        : integer   := 0;
        S1_CLKOUT3_DUTY         : integer   := 50000;
        S1_CLKOUT4_DIVIDE       : integer   := 1;
        S1_CLKOUT4_PHASE        : integer   := 0;
        S1_CLKOUT4_DUTY         : integer   := 50000;
        S1_CLKOUT5_DIVIDE       : integer   := 1;
        S1_CLKOUT5_PHASE        : integer   := 0;
        S1_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 2: 100MHz (100MHz)
        S2_BANDWIDTH            : string    := "LOW";
        
        S2_CLKFBOUT_MULT        : integer   := 8;
        S2_CLKFBOUT_PHASE       : integer   := 0;
        S2_DIVCLK_DIVIDE        : integer   := 1;
        
        S2_CLKOUT0_DIVIDE       : integer   := 8;
        S2_CLKOUT0_PHASE        : integer   := 0;
        S2_CLKOUT0_DUTY         : integer   := 50000;
        S2_CLKOUT1_DIVIDE       : integer   := 8;
        S2_CLKOUT1_PHASE        : integer   := 0;
        S2_CLKOUT1_DUTY         : integer   := 50000;
        S2_CLKOUT2_DIVIDE       : integer   := 2;
        S2_CLKOUT2_PHASE        : integer   := 0;
        S2_CLKOUT2_DUTY         : integer   := 50000;
        S2_CLKOUT3_DIVIDE       : integer   := 1;
        S2_CLKOUT3_PHASE        : integer   := 0;
        S2_CLKOUT3_DUTY         : integer   := 50000;
        S2_CLKOUT4_DIVIDE       : integer   := 1;
        S2_CLKOUT4_PHASE        : integer   := 0;
        S2_CLKOUT4_DUTY         : integer   := 50000;
        S2_CLKOUT5_DIVIDE       : integer   := 1;
        S2_CLKOUT5_PHASE        : integer   := 0;
        S2_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 3: 20MHz (100MHz)
        S3_BANDWIDTH            : string    := "LOW";
        
        S3_CLKFBOUT_MULT        : integer   := 40;
        S3_CLKFBOUT_PHASE       : integer   := 0;
        S3_DIVCLK_DIVIDE        : integer   := 1;
        
        S3_CLKOUT0_DIVIDE       : integer   := 40;
        S3_CLKOUT0_PHASE        : integer   := 0;
        S3_CLKOUT0_DUTY         : integer   := 50000;
        S3_CLKOUT1_DIVIDE       : integer   := 8;
        S3_CLKOUT1_PHASE        : integer   := 0;
        S3_CLKOUT1_DUTY         : integer   := 50000;
        S3_CLKOUT2_DIVIDE       : integer   := 2;
        S3_CLKOUT2_PHASE        : integer   := 0;
        S3_CLKOUT2_DUTY         : integer   := 50000;
        S3_CLKOUT3_DIVIDE       : integer   := 1;
        S3_CLKOUT3_PHASE        : integer   := 0;
        S3_CLKOUT3_DUTY         : integer   := 50000;
        S3_CLKOUT4_DIVIDE       : integer   := 1;
        S3_CLKOUT4_PHASE        : integer   := 0;
        S3_CLKOUT4_DUTY         : integer   := 50000;
        S3_CLKOUT5_DIVIDE       : integer   := 1;
        S3_CLKOUT5_PHASE        : integer   := 0;
        S3_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 4: 40MHz (80MHz)
        S4_BANDWIDTH            : string    := "LOW";
        
        S4_CLKFBOUT_MULT        : integer   := 20;
        S4_CLKFBOUT_PHASE       : integer   := 0;
        S4_DIVCLK_DIVIDE        : integer   := 1;
        
        S4_CLKOUT0_DIVIDE       : integer   := 20;
        S4_CLKOUT0_PHASE        : integer   := 0;
        S4_CLKOUT0_DUTY         : integer   := 50000;
        S4_CLKOUT1_DIVIDE       : integer   := 10;
        S4_CLKOUT1_PHASE        : integer   := 0;
        S4_CLKOUT1_DUTY         : integer   := 50000;
        S4_CLKOUT2_DIVIDE       : integer   := 2;
        S4_CLKOUT2_PHASE        : integer   := 0;
        S4_CLKOUT2_DUTY         : integer   := 50000;
        S4_CLKOUT3_DIVIDE       : integer   := 1;
        S4_CLKOUT3_PHASE        : integer   := 0;
        S4_CLKOUT3_DUTY         : integer   := 50000;
        S4_CLKOUT4_DIVIDE       : integer   := 1;
        S4_CLKOUT4_PHASE        : integer   := 0;
        S4_CLKOUT4_DUTY         : integer   := 50000;
        S4_CLKOUT5_DIVIDE       : integer   := 1;
        S4_CLKOUT5_PHASE        : integer   := 0;
        S4_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 5: 80MHz (80MHz)
        S5_BANDWIDTH            : string    := "LOW";
        
        S5_CLKFBOUT_MULT        : integer   := 10;
        S5_CLKFBOUT_PHASE       : integer   := 0;
        S5_DIVCLK_DIVIDE        : integer   := 1;
        
        S5_CLKOUT0_DIVIDE       : integer   := 10;
        S5_CLKOUT0_PHASE        : integer   := 0;
        S5_CLKOUT0_DUTY         : integer   := 50000;
        S5_CLKOUT1_DIVIDE       : integer   := 10;
        S5_CLKOUT1_PHASE        : integer   := 0;
        S5_CLKOUT1_DUTY         : integer   := 50000;
        S5_CLKOUT2_DIVIDE       : integer   := 2;
        S5_CLKOUT2_PHASE        : integer   := 0;
        S5_CLKOUT2_DUTY         : integer   := 50000;
        S5_CLKOUT3_DIVIDE       : integer   := 1;
        S5_CLKOUT3_PHASE        : integer   := 0;
        S5_CLKOUT3_DUTY         : integer   := 50000;
        S5_CLKOUT4_DIVIDE       : integer   := 1;
        S5_CLKOUT4_PHASE        : integer   := 0;
        S5_CLKOUT4_DUTY         : integer   := 50000;
        S5_CLKOUT5_DIVIDE       : integer   := 1;
        S5_CLKOUT5_PHASE        : integer   := 0;
        S5_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 6: 25MHz (100MHz)
        S6_BANDWIDTH            : string    := "LOW";
        
        S6_CLKFBOUT_MULT        : integer   := 32;
        S6_CLKFBOUT_PHASE       : integer   := 0;
        S6_DIVCLK_DIVIDE        : integer   := 1;
        
        S6_CLKOUT0_DIVIDE       : integer   := 32;
        S6_CLKOUT0_PHASE        : integer   := 0;
        S6_CLKOUT0_DUTY         : integer   := 50000;
        S6_CLKOUT1_DIVIDE       : integer   := 8;
        S6_CLKOUT1_PHASE        : integer   := 0;
        S6_CLKOUT1_DUTY         : integer   := 50000;
        S6_CLKOUT2_DIVIDE       : integer   := 2;
        S6_CLKOUT2_PHASE        : integer   := 0;
        S6_CLKOUT2_DUTY         : integer   := 50000;
        S6_CLKOUT3_DIVIDE       : integer   := 1;
        S6_CLKOUT3_PHASE        : integer   := 0;
        S6_CLKOUT3_DUTY         : integer   := 50000;
        S6_CLKOUT4_DIVIDE       : integer   := 1;
        S6_CLKOUT4_PHASE        : integer   := 0;
        S6_CLKOUT4_DUTY         : integer   := 50000;
        S6_CLKOUT5_DIVIDE       : integer   := 1;
        S6_CLKOUT5_PHASE        : integer   := 0;
        S6_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 7: 33.3MHz (100MHz)
        S7_BANDWIDTH            : string    := "LOW";
        
        S7_CLKFBOUT_MULT        : integer   := 24;
        S7_CLKFBOUT_PHASE       : integer   := 0;
        S7_DIVCLK_DIVIDE        : integer   := 1;
        
        S7_CLKOUT0_DIVIDE       : integer   := 24;
        S7_CLKOUT0_PHASE        : integer   := 0;
        S7_CLKOUT0_DUTY         : integer   := 50000;
        S7_CLKOUT1_DIVIDE       : integer   := 8;
        S7_CLKOUT1_PHASE        : integer   := 0;
        S7_CLKOUT1_DUTY         : integer   := 50000;
        S7_CLKOUT2_DIVIDE       : integer   := 2;
        S7_CLKOUT2_PHASE        : integer   := 0;
        S7_CLKOUT2_DUTY         : integer   := 50000;
        S7_CLKOUT3_DIVIDE       : integer   := 1;
        S7_CLKOUT3_PHASE        : integer   := 0;
        S7_CLKOUT3_DUTY         : integer   := 50000;
        S7_CLKOUT4_DIVIDE       : integer   := 1;
        S7_CLKOUT4_PHASE        : integer   := 0;
        S7_CLKOUT4_DUTY         : integer   := 50000;
        S7_CLKOUT5_DIVIDE       : integer   := 1;
        S7_CLKOUT5_PHASE        : integer   := 0;
        S7_CLKOUT5_DUTY         : integer   := 50000;
        
        --CONFIG 8: 66.6MHz (133.3MHz)
        S8_BANDWIDTH            : string    := "LOW";
        
        S8_CLKFBOUT_MULT        : integer   := 12;
        S8_CLKFBOUT_PHASE       : integer   := 0;
        S8_DIVCLK_DIVIDE        : integer   := 1;
        
        S8_CLKOUT0_DIVIDE       : integer   := 12;
        S8_CLKOUT0_PHASE        : integer   := 0;
        S8_CLKOUT0_DUTY         : integer   := 50000;
        S8_CLKOUT1_DIVIDE       : integer   := 6;
        S8_CLKOUT1_PHASE        : integer   := 0;
        S8_CLKOUT1_DUTY         : integer   := 50000;
        S8_CLKOUT2_DIVIDE       : integer   := 2;
        S8_CLKOUT2_PHASE        : integer   := 0;
        S8_CLKOUT2_DUTY         : integer   := 50000;
        S8_CLKOUT3_DIVIDE       : integer   := 1;
        S8_CLKOUT3_PHASE        : integer   := 0;
        S8_CLKOUT3_DUTY         : integer   := 50000;
        S8_CLKOUT4_DIVIDE       : integer   := 1;
        S8_CLKOUT4_PHASE        : integer   := 0;
        S8_CLKOUT4_DUTY         : integer   := 50000;
        S8_CLKOUT5_DIVIDE       : integer   := 1;
        S8_CLKOUT5_PHASE        : integer   := 0;
        S8_CLKOUT5_DUTY         : integer   := 50000
    );
    PORT(
        SIGNAL sclk             : IN    std_logic;
        SIGNAL rst              : IN    std_logic;
        SIGNAL saddr            : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL sen              : IN    std_logic;
        SIGNAL srdy             : OUT   std_logic;
        
        SIGNAL do               : IN    std_logic_vector(15 DOWNTO 0);
        SIGNAL drdy             : IN    std_logic;
        SIGNAL locked           : IN    std_logic;
        SIGNAL dwe              : OUT   std_logic;
        SIGNAL den              : OUT   std_logic;
        SIGNAL daddr_out        : OUT   std_logic_vector(4 DOWNTO 0);
        SIGNAL di_out           : OUT   std_logic_vector(15 DOWNTO 0);
        SIGNAL dclk             : OUT   std_logic;
        SIGNAL rst_pll_out      : OUT   std_logic
    );
END ENTITY pll_drp;

ARCHITECTURE arch OF pll_drp IS
   FUNCTION s6_pll_lock_lookup
   (
      divide : integer -- Max divide is 64
   )
   RETURN std_logic_vector IS
      TYPE lookup_t IS ARRAY (0 TO 63) OF std_logic_vector(39 DOWNTO 0);
      CONSTANT lookup : lookup_t := (
         "0100100111111110100011111010010000000001",
         "0100100111111110100011111010010000000001",
         "0110101011111110100011111010010000000001",
         "1001010000111110100011111010010000000001",
         "1011010100111110100011111010010000000001",
         "1101011000111110100011111010010000000001",
         "1111111101111110100011111010010000000001",
         "1111111101111110100011111010010000000001",
         "1111111101111110100011111010010000000001",
         "1111111101111110100011111010010000000001",
         "1111111101111000010011111010010000000001",
         "1111111101110011100111111010010000000001",
         "1111111101101110111011111010010000000001",
         "1111111101101011110011111010010000000001",
         "1111111101101000101011111010010000000001",
         "1111111101100111000111111010010000000001",
         "1111111101100011111111111010010000000001",
         "1111111101100010011011111010010000000001",
         "1111111101100000110111111010010000000001",
         "1111111101011111010011111010010000000001",
         "1111111101011101101111111010010000000001",
         "1111111101011100001011111010010000000001",
         "1111111101011010100111111010010000000001",
         "1111111101011001000011111010010000000001",
         "1111111101011001000011111010010000000001",
         "1111111101010111011111111010010000000001",
         "1111111101010101111011111010010000000001",
         "1111111101010101111011111010010000000001",
         "1111111101010100010111111010010000000001",
         "1111111101010100010111111010010000000001",
         "1111111101010010110011111010010000000001",
         "1111111101010010110011111010010000000001",
         "1111111101010010110011111010010000000001",
         "1111111101010001001111111010010000000001",
         "1111111101010001001111111010010000000001",
         "1111111101010001001111111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001",
         "1111111101001111101011111010010000000001"
      );
   BEGIN
      RETURN lookup(64-divide);
   END FUNCTION s6_pll_lock_lookup;

   FUNCTION s6_pll_filter_lookup
   (
      divide : integer; -- Max divide is 64
      bandwidth : string
   )
   RETURN std_logic_vector IS
      TYPE lookup_t IS ARRAY (0 TO 63) OF std_logic_vector(19 DOWNTO 0);
      CONSTANT lookup : lookup_t := (
         "10111100101101110001",
         "11111101011110110001",
         "10111101100001110001",
         "11111111100110110001",
         "10111111101010110001",
         "11011111101100110001",
         "00111111111100110001",
         "01011111111100110001",
         "10011111110010110001",
         "11101111100010110001",
         "11101111110100110001",
         "00011111110100110001",
         "00011111110100110001",
         "01101111100100110001",
         "01101111100100110001",
         "10101111100100110001",
         "10101111100100110001",
         "10101111110100110001",
         "10101111110100110001",
         "10101111110100110001",
         "10101111110100110001",
         "11001111011000110001",
         "11001111011000110001",
         "11001111101000110001",
         "11001111101000110001",
         "11001111111000110001",
         "11001111111000110001",
         "11001111111000110001",
         "11001111111000110001",
         "11001111111000110001",
         "00101111101000110001",
         "00101111101000110001",
         "11001111111000110001",
         "11001111111000110001",
         "00101111010100110010",
         "00101111010100110010",
         "01001111110100110010",
         "00101111000100110010",
         "00101111000100110010",
         "00101111000100110010",
         "10001101000100110010",
         "10001101000100110010",
         "10001101000100110010",
         "01001101011000110010",
         "00101101111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "10001100111000110010",
         "01001100111000110010",
         "01001100111000110010",
         "01001100111000110010",
         "01001100111000110010",
         "01001100111000110010",
         "01001100111000110010",
         "01001100111000110010",
         "01001100111000110010"
      );
   BEGIN
      IF bandwidth = "LOW" OR bandwidth = "low" THEN
         RETURN lookup(64-divide)(9 DOWNTO 0);
      ELSE
         RETURN lookup(64-divide)(19 DOWNTO 10);
      END IF;
   END FUNCTION s6_pll_filter_lookup;
   
   FUNCTION round_frac
   (
      decimal : integer;
      precision : integer
   )
   RETURN std_logic_vector IS
      CONSTANT FRAC_PRECISION : integer := 10;
   BEGIN
      IF to_unsigned(decimal,32)(FRAC_PRECISION-precision) = '1' THEN
        RETURN std_logic_vector(to_unsigned(decimal+(2**(FRAC_PRECISION-precision)),32));
      ELSE
        RETURN std_logic_vector(to_unsigned(decimal,32));
      END IF;
   END FUNCTION round_frac;

   FUNCTION pll_divider
   (
      divide : integer;     -- Max divide is 128
      duty_cycle : integer  -- Duty cycle is multiplied by 100,000
   )
   RETURN std_logic_vector IS
      CONSTANT FRAC_PRECISION : integer := 10;

      VARIABLE duty_cycle_fix : integer;
      
      VARIABLE high_time, low_time : std_logic_vector(6 DOWNTO 0);
      VARIABLE w_edge, no_count : std_logic;

      VARIABLE temp : std_logic_vector(31 DOWNTO 0);
   BEGIN
      duty_cycle_fix := (duty_cycle * (2**FRAC_PRECISION)) / 100000;

      IF divide = 1 THEN
         high_time   := "0000001";
         w_edge      := '0';
         low_time    := "0000001";
         no_count    := '1';
      ELSE
         temp := round_frac(duty_cycle_fix*divide, 1);
         high_time := temp(FRAC_PRECISION+6 DOWNTO FRAC_PRECISION);
         w_edge    := temp(FRAC_PRECISION-1);
         
         IF unsigned(high_time) = 0 THEN
            high_time   := "0000001";
            w_edge      := '0';
         END IF;

         IF unsigned(high_time) = divide THEN
            high_time   := std_logic_vector(to_unsigned(divide - 1,7));
            w_edge      := '1';
         END IF;
         
         low_time    := std_logic_vector(to_unsigned(divide - to_integer(unsigned(high_time)),7));
         no_count    := '0';
      END IF;
      REPORT "pll_divider - dv: "&integer'IMAGE(divide)&" dc: "&integer'IMAGE(duty_cycle)&", ht: "&integer'IMAGE(to_integer(unsigned(high_time)))
         &", lt: "&integer'IMAGE(to_integer(unsigned(low_time)))&", nc: "&std_logic'IMAGE(no_count)&", edge: "&std_logic'IMAGE(w_edge);
      RETURN w_edge&no_count&high_time(5 DOWNTO 0)&low_time(5 DOWNTO 0);
   END FUNCTION pll_divider;

   FUNCTION pll_phase
   (
      divide : integer; -- Max divide is 128
      phase : integer   -- Phase is given in degrees (-360,000 to 360,000)
   )
   RETURN std_logic_vector IS
      CONSTANT FRAC_PRECISION : integer := 10;
      VARIABLE phase_fixed : integer;
      VARIABLE phase_in_cycles : integer;
      VARIABLE temp : std_logic_vector(31 DOWNTO 0);
   BEGIN
      IF phase < 0 THEN
         phase_fixed := ((phase + 360000) * (2**FRAC_PRECISION)) / 1000;
      ELSE
         phase_fixed := (phase * (2**FRAC_PRECISION)) / 1000;
      END IF;

      phase_in_cycles := ( phase_fixed * divide ) / 360;

      temp  :=  round_frac(phase_in_cycles, 3);
      
      REPORT "pll_phase - dv: "&integer'IMAGE(divide)&", ph: "&integer'IMAGE(phase)
         &", pm: "&integer'IMAGE(to_integer(unsigned(temp(FRAC_PRECISION-1 DOWNTO FRAC_PRECISION-3))))
         &", dt: "&integer'IMAGE(to_integer(unsigned(temp(FRAC_PRECISION+5 DOWNTO FRAC_PRECISION))));
      RETURN temp(FRAC_PRECISION-1 DOWNTO FRAC_PRECISION-3)&temp(FRAC_PRECISION+5 DOWNTO FRAC_PRECISION);
   END FUNCTION pll_phase;

   FUNCTION s6_pll_count_calc
   (
      divide : integer; -- Max divide is 128
      phase : integer;
      duty_cycle : integer
   )
   RETURN std_logic_vector IS
   BEGIN
      RETURN pll_phase(divide,phase)&pll_divider(divide,duty_cycle);
   END FUNCTION s6_pll_count_calc;

   SIGNAL daddr : std_logic_vector(4 DOWNTO 0);
   SIGNAL di : std_logic_vector(15 DOWNTO 0);
   SIGNAL rst_pll : std_logic;
   
   --CONFIG 1 calculations
   CONSTANT  S1_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) := 
      s6_pll_count_calc(S1_CLKFBOUT_MULT, S1_CLKFBOUT_PHASE, 50000);
      
   CONSTANT   S1_DIGITAL_FILT    : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S1_CLKFBOUT_MULT, S1_BANDWIDTH);
      
   CONSTANT  S1_LOCK            : std_logic_vector(39 DOWNTO 0) := 
      s6_pll_lock_lookup(S1_CLKFBOUT_MULT);
      
   CONSTANT  S1_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S1_DIVCLK_DIVIDE, 0, 50000); 
      
   CONSTANT  S1_CLKOUT0         : std_logic_vector(22 DOWNTO 0) := 
      s6_pll_count_calc(S1_CLKOUT0_DIVIDE, S1_CLKOUT0_PHASE, S1_CLKOUT0_DUTY); 
         
   CONSTANT  S1_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S1_CLKOUT1_DIVIDE, S1_CLKOUT1_PHASE, S1_CLKOUT1_DUTY); 
         
   CONSTANT  S1_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S1_CLKOUT2_DIVIDE, S1_CLKOUT2_PHASE, S1_CLKOUT2_DUTY); 
         
   CONSTANT  S1_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S1_CLKOUT3_DIVIDE, S1_CLKOUT3_PHASE, S1_CLKOUT3_DUTY); 
         
   CONSTANT  S1_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S1_CLKOUT4_DIVIDE, S1_CLKOUT4_PHASE, S1_CLKOUT4_DUTY); 
         
   CONSTANT  S1_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S1_CLKOUT5_DIVIDE, S1_CLKOUT5_PHASE, S1_CLKOUT5_DUTY); 
   
   --CONFIG 2 calculations
   CONSTANT  S2_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKFBOUT_MULT, S2_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S2_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S2_CLKFBOUT_MULT, S2_BANDWIDTH);
   
   CONSTANT  S2_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S2_CLKFBOUT_MULT);
   
   CONSTANT  S2_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S2_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKOUT0_DIVIDE, S2_CLKOUT0_PHASE, S2_CLKOUT0_DUTY);
         
   CONSTANT  S2_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKOUT1_DIVIDE, S2_CLKOUT1_PHASE, S2_CLKOUT1_DUTY);
         
   CONSTANT  S2_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKOUT2_DIVIDE, S2_CLKOUT2_PHASE, S2_CLKOUT2_DUTY);
         
   CONSTANT  S2_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKOUT3_DIVIDE, S2_CLKOUT3_PHASE, S2_CLKOUT3_DUTY);
         
   CONSTANT  S2_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKOUT4_DIVIDE, S2_CLKOUT4_PHASE, S2_CLKOUT4_DUTY);
         
   CONSTANT  S2_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S2_CLKOUT5_DIVIDE, S2_CLKOUT5_PHASE, S2_CLKOUT5_DUTY);
    
   --CONFIG 3 calculations
   CONSTANT  S3_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKFBOUT_MULT, S3_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S3_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S3_CLKFBOUT_MULT, S3_BANDWIDTH);
   
   CONSTANT  S3_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S3_CLKFBOUT_MULT);
   
   CONSTANT  S3_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S3_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKOUT0_DIVIDE, S3_CLKOUT0_PHASE, S3_CLKOUT0_DUTY);
         
   CONSTANT  S3_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKOUT1_DIVIDE, S3_CLKOUT1_PHASE, S3_CLKOUT1_DUTY);
         
   CONSTANT  S3_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKOUT2_DIVIDE, S3_CLKOUT2_PHASE, S3_CLKOUT2_DUTY);
         
   CONSTANT  S3_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKOUT3_DIVIDE, S3_CLKOUT3_PHASE, S3_CLKOUT3_DUTY);
         
   CONSTANT  S3_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKOUT4_DIVIDE, S3_CLKOUT4_PHASE, S3_CLKOUT4_DUTY);
         
   CONSTANT  S3_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S3_CLKOUT5_DIVIDE, S3_CLKOUT5_PHASE, S3_CLKOUT5_DUTY);
    
   --CONFIG 4 calculations
   CONSTANT  S4_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKFBOUT_MULT, S4_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S4_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S4_CLKFBOUT_MULT, S4_BANDWIDTH);
   
   CONSTANT  S4_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S4_CLKFBOUT_MULT);
   
   CONSTANT  S4_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S4_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKOUT0_DIVIDE, S4_CLKOUT0_PHASE, S4_CLKOUT0_DUTY);
         
   CONSTANT  S4_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKOUT1_DIVIDE, S4_CLKOUT1_PHASE, S4_CLKOUT1_DUTY);
         
   CONSTANT  S4_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKOUT2_DIVIDE, S4_CLKOUT2_PHASE, S4_CLKOUT2_DUTY);
         
   CONSTANT  S4_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKOUT3_DIVIDE, S4_CLKOUT3_PHASE, S4_CLKOUT3_DUTY);
         
   CONSTANT  S4_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKOUT4_DIVIDE, S4_CLKOUT4_PHASE, S4_CLKOUT4_DUTY);
         
   CONSTANT  S4_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S4_CLKOUT5_DIVIDE, S4_CLKOUT5_PHASE, S4_CLKOUT5_DUTY);
    
   --CONFIG 5 calculations
   CONSTANT  S5_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKFBOUT_MULT, S5_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S5_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S5_CLKFBOUT_MULT, S5_BANDWIDTH);
   
   CONSTANT  S5_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S5_CLKFBOUT_MULT);
   
   CONSTANT  S5_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S5_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKOUT0_DIVIDE, S5_CLKOUT0_PHASE, S5_CLKOUT0_DUTY);
         
   CONSTANT  S5_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKOUT1_DIVIDE, S5_CLKOUT1_PHASE, S5_CLKOUT1_DUTY);
         
   CONSTANT  S5_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKOUT2_DIVIDE, S5_CLKOUT2_PHASE, S5_CLKOUT2_DUTY);
         
   CONSTANT  S5_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKOUT3_DIVIDE, S5_CLKOUT3_PHASE, S5_CLKOUT3_DUTY);
         
   CONSTANT  S5_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKOUT4_DIVIDE, S5_CLKOUT4_PHASE, S5_CLKOUT4_DUTY);
         
   CONSTANT  S5_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S5_CLKOUT5_DIVIDE, S5_CLKOUT5_PHASE, S5_CLKOUT5_DUTY);
    
   --CONFIG 6 calculations
   CONSTANT  S6_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKFBOUT_MULT, S6_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S6_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S6_CLKFBOUT_MULT, S6_BANDWIDTH);
   
   CONSTANT  S6_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S6_CLKFBOUT_MULT);
   
   CONSTANT  S6_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S6_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKOUT0_DIVIDE, S6_CLKOUT0_PHASE, S6_CLKOUT0_DUTY);
         
   CONSTANT  S6_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKOUT1_DIVIDE, S6_CLKOUT1_PHASE, S6_CLKOUT1_DUTY);
         
   CONSTANT  S6_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKOUT2_DIVIDE, S6_CLKOUT2_PHASE, S6_CLKOUT2_DUTY);
         
   CONSTANT  S6_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKOUT3_DIVIDE, S6_CLKOUT3_PHASE, S6_CLKOUT3_DUTY);
         
   CONSTANT  S6_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKOUT4_DIVIDE, S6_CLKOUT4_PHASE, S6_CLKOUT4_DUTY);
         
   CONSTANT  S6_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S6_CLKOUT5_DIVIDE, S6_CLKOUT5_PHASE, S6_CLKOUT5_DUTY);
    
   --CONFIG 7 calculations
   CONSTANT  S7_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKFBOUT_MULT, S7_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S7_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S7_CLKFBOUT_MULT, S7_BANDWIDTH);
   
   CONSTANT  S7_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S7_CLKFBOUT_MULT);
   
   CONSTANT  S7_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S7_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKOUT0_DIVIDE, S7_CLKOUT0_PHASE, S7_CLKOUT0_DUTY);
         
   CONSTANT  S7_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKOUT1_DIVIDE, S7_CLKOUT1_PHASE, S7_CLKOUT1_DUTY);
         
   CONSTANT  S7_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKOUT2_DIVIDE, S7_CLKOUT2_PHASE, S7_CLKOUT2_DUTY);
         
   CONSTANT  S7_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKOUT3_DIVIDE, S7_CLKOUT3_PHASE, S7_CLKOUT3_DUTY);
         
   CONSTANT  S7_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKOUT4_DIVIDE, S7_CLKOUT4_PHASE, S7_CLKOUT4_DUTY);
         
   CONSTANT  S7_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S7_CLKOUT5_DIVIDE, S7_CLKOUT5_PHASE, S7_CLKOUT5_DUTY);
    
   --CONFIG 8 calculations
   CONSTANT  S8_CLKFBOUT        : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKFBOUT_MULT, S8_CLKFBOUT_PHASE, 50000);
   
   CONSTANT  S8_DIGITAL_FILT     : std_logic_vector(9 DOWNTO 0) :=  
      s6_pll_filter_lookup(S8_CLKFBOUT_MULT, S8_BANDWIDTH);
   
   CONSTANT  S8_LOCK            : std_logic_vector(39 DOWNTO 0) :=  
      s6_pll_lock_lookup(S8_CLKFBOUT_MULT);
   
   CONSTANT  S8_DIVCLK          : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_DIVCLK_DIVIDE, 0, 50000); 
   
   CONSTANT  S8_CLKOUT0         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKOUT0_DIVIDE, S8_CLKOUT0_PHASE, S8_CLKOUT0_DUTY);
         
   CONSTANT  S8_CLKOUT1         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKOUT1_DIVIDE, S8_CLKOUT1_PHASE, S8_CLKOUT1_DUTY);
         
   CONSTANT  S8_CLKOUT2         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKOUT2_DIVIDE, S8_CLKOUT2_PHASE, S8_CLKOUT2_DUTY);
         
   CONSTANT  S8_CLKOUT3         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKOUT3_DIVIDE, S8_CLKOUT3_PHASE, S8_CLKOUT3_DUTY);
         
   CONSTANT  S8_CLKOUT4         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKOUT4_DIVIDE, S8_CLKOUT4_PHASE, S8_CLKOUT4_DUTY);
         
   CONSTANT  S8_CLKOUT5         : std_logic_vector(22 DOWNTO 0) :=  
      s6_pll_count_calc(S8_CLKOUT5_DIVIDE, S8_CLKOUT5_PHASE, S8_CLKOUT5_DUTY);
    
    TYPE rom_t IS ARRAY (0 TO 255) OF std_logic_vector(36 DOWNTO 0);
    CONSTANT rom : rom_t := (
        --***********************************************************************
        -- State 1 Initialization
        --***********************************************************************
        0 => "0"&X"5"& X"50FF"&  S1_CLKOUT0(19)& "0"& S1_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S1_CLKOUT0(16)& S1_CLKOUT0(17)& S1_CLKOUT0(15)& S1_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        1 => "0"&X"6"& X"010B"&  S1_CLKOUT1(4)& S1_CLKOUT1(5)& S1_CLKOUT1(3)& S1_CLKOUT1(12)& --bits 15 down to 12
                                  S1_CLKOUT1(1)& S1_CLKOUT1(2)& S1_CLKOUT1(19)& "0"& S1_CLKOUT1(17)& S1_CLKOUT1(16)& --bits 11 down to 6
						          S1_CLKOUT1(14)& S1_CLKOUT1(15)& "0"& S1_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        2 => "0"&X"7"& X"E02C"&  "000"& S1_CLKOUT1(11)& S1_CLKOUT1(9)& S1_CLKOUT1(10)& --bits 15 down to 10
                                  S1_CLKOUT1(8)& S1_CLKOUT1(7)& S1_CLKOUT1(6)& S1_CLKOUT1(20)& "0"& S1_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S1_CLKOUT1(21)& S1_CLKOUT1(22), --bits 3 down to 0
						         
        3 => "0"&X"8"& X"4001"&  S1_CLKOUT2(22)& "0"& S1_CLKOUT2(5)& S1_CLKOUT2(21)& --bits 15 downto 12
                                  S1_CLKOUT2(12)& S1_CLKOUT2(4)& S1_CLKOUT2(3)& S1_CLKOUT2(2)& S1_CLKOUT2(0)& S1_CLKOUT2(19)& --bits 11 down to 6
						          S1_CLKOUT2(17)& S1_CLKOUT2(18)& S1_CLKOUT2(15)& S1_CLKOUT2(16)& S1_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        4 => "0"&X"9"& X"0D03"&  S1_CLKOUT3(14)& S1_CLKOUT3(15)& S1_CLKOUT0(21)& S1_CLKOUT0(22)& "00"& S1_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S1_CLKOUT2(9)& S1_CLKOUT2(8)& S1_CLKOUT2(6)& S1_CLKOUT2(7)& S1_CLKOUT2(13)& S1_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        5 => "0"&X"A"& X"B001"&  "0"& S1_CLKOUT3(13)& "00"& S1_CLKOUT3(21)& S1_CLKOUT3(22)& S1_CLKOUT3(5)& S1_CLKOUT3(4)& --bits 15 downto 8
                                  S1_CLKOUT3(12)& S1_CLKOUT3(2)& S1_CLKOUT3(0)& S1_CLKOUT3(1)& S1_CLKOUT3(18)& S1_CLKOUT3(19)& --bits 7 downto 2
						          S1_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        6 => "0"&X"B"& X"0110"&  S1_CLKOUT0(5)& S1_CLKOUT4(19)& S1_CLKOUT4(14)& S1_CLKOUT4(17)& --bits 15 downto 12
                                  S1_CLKOUT4(15)& S1_CLKOUT4(16)& S1_CLKOUT0(4)& "0"& S1_CLKOUT3(11)& S1_CLKOUT3(10)& --bits 11 downto 6 
						          S1_CLKOUT3(9)& "0"& S1_CLKOUT3(7)& S1_CLKOUT3(8)& S1_CLKOUT3(20)& S1_CLKOUT3(6), --bits 5 downto 0
						         
        7 => "0"&X"C"& X"0B00"&  S1_CLKOUT4(7)& S1_CLKOUT4(8)& S1_CLKOUT4(20)& S1_CLKOUT4(6)& "0"& S1_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S1_CLKOUT4(22)& S1_CLKOUT4(21)& S1_CLKOUT4(4)& S1_CLKOUT4(5)& S1_CLKOUT4(3)& --bits 9 downto 3
						          S1_CLKOUT4(12)& S1_CLKOUT4(1)& S1_CLKOUT4(2), --bits 2 downto 0
						         
        8 => "0"&X"D"& X"0008"&  S1_CLKOUT5(2)& S1_CLKOUT5(3)& S1_CLKOUT5(0)& S1_CLKOUT5(1)& S1_CLKOUT5(18)& --bits 15 downto 11
						          S1_CLKOUT5(19)& S1_CLKOUT5(17)& S1_CLKOUT5(16)& S1_CLKOUT5(15)& S1_CLKOUT0(3)& --bits 10 downto 6
						          S1_CLKOUT0(0)& S1_CLKOUT0(2)& "0"& S1_CLKOUT4(11)& S1_CLKOUT4(9)& S1_CLKOUT4(10), --bits 5 downto 0
						         
        9 => "0"&X"E"& X"00D0"&  S1_CLKOUT5(10)& S1_CLKOUT5(11)& S1_CLKOUT5(8)& S1_CLKOUT5(9)& S1_CLKOUT5(6)& --bits 15 downto 11
						          S1_CLKOUT5(7)& S1_CLKOUT5(20)& S1_CLKOUT5(13)& "00"& S1_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S1_CLKOUT5(5)& S1_CLKOUT5(21)& S1_CLKOUT5(12)& S1_CLKOUT5(4), --bits 3 downto 0
						         
        10 => "0"&X"F"& X"0003"& S1_CLKFBOUT(4)& S1_CLKFBOUT(5)& S1_CLKFBOUT(3)& S1_CLKFBOUT(12)& S1_CLKFBOUT(1)& --bits 15 downto 11
                                  S1_CLKFBOUT(2)& S1_CLKFBOUT(0)& S1_CLKFBOUT(19)& S1_CLKFBOUT(18)& S1_CLKFBOUT(17)& --bits 10 downto 6
						          S1_CLKFBOUT(15)& S1_CLKFBOUT(16)& S1_CLKOUT0(12)& S1_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        11 => "1"&X"0"& X"800C"& "0"& S1_CLKOUT0(9)& S1_CLKOUT0(11)& S1_CLKOUT0(10)& S1_CLKFBOUT(10)& S1_CLKFBOUT(11)& --bits 15 downto 10
						          S1_CLKFBOUT(9)& S1_CLKFBOUT(8)& S1_CLKFBOUT(7)& S1_CLKFBOUT(6)& S1_CLKFBOUT(13)&  --bits 9 downto 5
						          S1_CLKFBOUT(20)& "00"& S1_CLKFBOUT(21)& S1_CLKFBOUT(22), --bits 4 downto 0
								
        12 => "1"&X"1"& X"FC00"& "00"&X"0"& S1_CLKOUT3(3)& S1_CLKOUT3(16)& S1_CLKOUT2(11)& S1_CLKOUT2(1)& S1_CLKOUT1(18)& --bits 15 downto 6
						          S1_CLKOUT1(0)& S1_CLKOUT0(6)& S1_CLKOUT0(20)& S1_CLKOUT0(8)& S1_CLKOUT0(7), --bits 5 downto 0
						          
        13 => "1"&X"2"& X"F0FF"& X"0"& S1_CLKOUT5(14)& S1_CLKFBOUT(14)& S1_CLKOUT4(0)& S1_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        14 => "1"&X"3"& X"5120"& S1_DIVCLK(11)& "0"& S1_DIVCLK(10)& "0"& S1_DIVCLK(7)& S1_DIVCLK(8)&  --bits 15 downto 10
                                  S1_DIVCLK(0)& "0"& S1_DIVCLK(5)& S1_DIVCLK(2)& "0"& S1_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        15 => "1"&X"4"& X"2FFF"& S1_LOCK(1)& S1_LOCK(2)& "0"& S1_LOCK(0)& X"000", --bits 15 downto 0
						          
        16 => "1"&X"5"& X"BFF4"& "0"& S1_DIVCLK(12)& "00"&X"00"& S1_LOCK(38)& "0"& S1_LOCK(32)& S1_LOCK(39), --bits 15 downto 0								  
						          
        17 => "1"&X"6"& X"0A55"& S1_LOCK(15)& S1_LOCK(13)& S1_LOCK(27)& S1_LOCK(16)& "0"& S1_LOCK(10)&   --bits 15 downto 10
                                  "0"& S1_DIVCLK(9)& S1_DIVCLK(1)& "0"& S1_DIVCLK(6)& "0"& S1_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S1_DIVCLK(4)& "0",  --bits 2 downto 0

        18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S1_LOCK(17)& "0"& S1_LOCK(8)& S1_LOCK(9)& S1_LOCK(23)& S1_LOCK(22), --bits 15 downto 0	  
						          
        19 => "1"&X"8"& X"1039"& S1_DIGITAL_FILT(6)& S1_DIGITAL_FILT(7)& S1_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S1_DIGITAL_FILT(2)& S1_DIGITAL_FILT(1)& S1_DIGITAL_FILT(3)& S1_DIGITAL_FILT(9)& --bits 11 downto 8
						          S1_DIGITAL_FILT(8)& S1_LOCK(26)& "000"& S1_LOCK(19)& S1_LOCK(18)& "0", --bits 7 downto 0								
						          
        20 => "1"&X"9"& X"0000"& S1_LOCK(24)& S1_LOCK(25)& S1_LOCK(21)& S1_LOCK(14)& S1_LOCK(11)& --bits 15 downto 11
						          S1_LOCK(12)& S1_LOCK(20)& S1_LOCK(6)& S1_LOCK(35)& S1_LOCK(36)& --bits 10 downto 6
						          S1_LOCK(37)& S1_LOCK(3)& S1_LOCK(33)& S1_LOCK(31)& S1_LOCK(34)& S1_LOCK(30), --bits 5 downto 0
						          
        21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S1_LOCK(28)& S1_LOCK(29),  --bits 15 downto 0

        22 => "1"&X"D"& X"2FFF"& S1_LOCK(7)& S1_LOCK(4)& "0"& S1_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 2 Initialization
        --***********************************************************************
        23+0 => "0"&X"5"& X"50FF"&  S2_CLKOUT0(19)& "0"& S2_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S2_CLKOUT0(16)& S2_CLKOUT0(17)& S2_CLKOUT0(15)& S2_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        23+1 => "0"&X"6"& X"010B"&  S2_CLKOUT1(4)& S2_CLKOUT1(5)& S2_CLKOUT1(3)& S2_CLKOUT1(12)& --bits 15 down to 12
                                  S2_CLKOUT1(1)& S2_CLKOUT1(2)& S2_CLKOUT1(19)& "0"& S2_CLKOUT1(17)& S2_CLKOUT1(16)& --bits 11 down to 6
						          S2_CLKOUT1(14)& S2_CLKOUT1(15)& "0"& S2_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        23+2 => "0"&X"7"& X"E02C"&  "000"& S2_CLKOUT1(11)& S2_CLKOUT1(9)& S2_CLKOUT1(10)& --bits 15 down to 10
                                  S2_CLKOUT1(8)& S2_CLKOUT1(7)& S2_CLKOUT1(6)& S2_CLKOUT1(20)& "0"& S2_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S2_CLKOUT1(21)& S2_CLKOUT1(22), --bits 3 down to 0
						         
        23+3 => "0"&X"8"& X"4001"&  S2_CLKOUT2(22)& "0"& S2_CLKOUT2(5)& S2_CLKOUT2(21)& --bits 15 downto 12
                                  S2_CLKOUT2(12)& S2_CLKOUT2(4)& S2_CLKOUT2(3)& S2_CLKOUT2(2)& S2_CLKOUT2(0)& S2_CLKOUT2(19)& --bits 11 down to 6
						          S2_CLKOUT2(17)& S2_CLKOUT2(18)& S2_CLKOUT2(15)& S2_CLKOUT2(16)& S2_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        23+4 => "0"&X"9"& X"0D03"&  S2_CLKOUT3(14)& S2_CLKOUT3(15)& S2_CLKOUT0(21)& S2_CLKOUT0(22)& "00"& S2_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S2_CLKOUT2(9)& S2_CLKOUT2(8)& S2_CLKOUT2(6)& S2_CLKOUT2(7)& S2_CLKOUT2(13)& S2_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        23+5 => "0"&X"A"& X"B001"&  "0"& S2_CLKOUT3(13)& "00"& S2_CLKOUT3(21)& S2_CLKOUT3(22)& S2_CLKOUT3(5)& S2_CLKOUT3(4)& --bits 15 downto 8
                                  S2_CLKOUT3(12)& S2_CLKOUT3(2)& S2_CLKOUT3(0)& S2_CLKOUT3(1)& S2_CLKOUT3(18)& S2_CLKOUT3(19)& --bits 7 downto 2
						          S2_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        23+6 => "0"&X"B"& X"0110"&  S2_CLKOUT0(5)& S2_CLKOUT4(19)& S2_CLKOUT4(14)& S2_CLKOUT4(17)& --bits 15 downto 12
                                  S2_CLKOUT4(15)& S2_CLKOUT4(16)& S2_CLKOUT0(4)& "0"& S2_CLKOUT3(11)& S2_CLKOUT3(10)& --bits 11 downto 6 
						          S2_CLKOUT3(9)& "0"& S2_CLKOUT3(7)& S2_CLKOUT3(8)& S2_CLKOUT3(20)& S2_CLKOUT3(6), --bits 5 downto 0
						         
        23+7 => "0"&X"C"& X"0B00"&  S2_CLKOUT4(7)& S2_CLKOUT4(8)& S2_CLKOUT4(20)& S2_CLKOUT4(6)& "0"& S2_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S2_CLKOUT4(22)& S2_CLKOUT4(21)& S2_CLKOUT4(4)& S2_CLKOUT4(5)& S2_CLKOUT4(3)& --bits 9 downto 3
						          S2_CLKOUT4(12)& S2_CLKOUT4(1)& S2_CLKOUT4(2), --bits 2 downto 0
						         
        23+8 => "0"&X"D"& X"0008"&  S2_CLKOUT5(2)& S2_CLKOUT5(3)& S2_CLKOUT5(0)& S2_CLKOUT5(1)& S2_CLKOUT5(18)& --bits 15 downto 11
						          S2_CLKOUT5(19)& S2_CLKOUT5(17)& S2_CLKOUT5(16)& S2_CLKOUT5(15)& S2_CLKOUT0(3)& --bits 10 downto 6
						          S2_CLKOUT0(0)& S2_CLKOUT0(2)& "0"& S2_CLKOUT4(11)& S2_CLKOUT4(9)& S2_CLKOUT4(10), --bits 5 downto 0
						         
        23+9 => "0"&X"E"& X"00D0"&  S2_CLKOUT5(10)& S2_CLKOUT5(11)& S2_CLKOUT5(8)& S2_CLKOUT5(9)& S2_CLKOUT5(6)& --bits 15 downto 11
						          S2_CLKOUT5(7)& S2_CLKOUT5(20)& S2_CLKOUT5(13)& "00"& S2_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S2_CLKOUT5(5)& S2_CLKOUT5(21)& S2_CLKOUT5(12)& S2_CLKOUT5(4), --bits 3 downto 0
						         
        23+10 => "0"&X"F"& X"0003"& S2_CLKFBOUT(4)& S2_CLKFBOUT(5)& S2_CLKFBOUT(3)& S2_CLKFBOUT(12)& S2_CLKFBOUT(1)& --bits 15 downto 11
                                  S2_CLKFBOUT(2)& S2_CLKFBOUT(0)& S2_CLKFBOUT(19)& S2_CLKFBOUT(18)& S2_CLKFBOUT(17)& --bits 10 downto 6
						          S2_CLKFBOUT(15)& S2_CLKFBOUT(16)& S2_CLKOUT0(12)& S2_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        23+11 => "1"&X"0"& X"800C"& "0"& S2_CLKOUT0(9)& S2_CLKOUT0(11)& S2_CLKOUT0(10)& S2_CLKFBOUT(10)& S2_CLKFBOUT(11)& --bits 15 downto 10
						          S2_CLKFBOUT(9)& S2_CLKFBOUT(8)& S2_CLKFBOUT(7)& S2_CLKFBOUT(6)& S2_CLKFBOUT(13)&  --bits 9 downto 5
						          S2_CLKFBOUT(20)& "00"& S2_CLKFBOUT(21)& S2_CLKFBOUT(22), --bits 4 downto 0
								
        23+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S2_CLKOUT3(3)& S2_CLKOUT3(16)& S2_CLKOUT2(11)& S2_CLKOUT2(1)& S2_CLKOUT1(18)& --bits 15 downto 6
						          S2_CLKOUT1(0)& S2_CLKOUT0(6)& S2_CLKOUT0(20)& S2_CLKOUT0(8)& S2_CLKOUT0(7), --bits 5 downto 0
						          
        23+13 => "1"&X"2"& X"F0FF"& X"0"& S2_CLKOUT5(14)& S2_CLKFBOUT(14)& S2_CLKOUT4(0)& S2_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        23+14 => "1"&X"3"& X"5120"& S2_DIVCLK(11)& "0"& S2_DIVCLK(10)& "0"& S2_DIVCLK(7)& S2_DIVCLK(8)&  --bits 15 downto 10
                                  S2_DIVCLK(0)& "0"& S2_DIVCLK(5)& S2_DIVCLK(2)& "0"& S2_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        23+15 => "1"&X"4"& X"2FFF"& S2_LOCK(1)& S2_LOCK(2)& "0"& S2_LOCK(0)& X"000", --bits 15 downto 0
						          
        23+16 => "1"&X"5"& X"BFF4"& "0"& S2_DIVCLK(12)& "00"&X"00"& S2_LOCK(38)& "0"& S2_LOCK(32)& S2_LOCK(39), --bits 15 downto 0								  
						          
        23+17 => "1"&X"6"& X"0A55"& S2_LOCK(15)& S2_LOCK(13)& S2_LOCK(27)& S2_LOCK(16)& "0"& S2_LOCK(10)&   --bits 15 downto 10
                                  "0"& S2_DIVCLK(9)& S2_DIVCLK(1)& "0"& S2_DIVCLK(6)& "0"& S2_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S2_DIVCLK(4)& "0",  --bits 2 downto 0

        23+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S2_LOCK(17)& "0"& S2_LOCK(8)& S2_LOCK(9)& S2_LOCK(23)& S2_LOCK(22), --bits 15 downto 0	  
						          
        23+19 => "1"&X"8"& X"1039"& S2_DIGITAL_FILT(6)& S2_DIGITAL_FILT(7)& S2_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S2_DIGITAL_FILT(2)& S2_DIGITAL_FILT(1)& S2_DIGITAL_FILT(3)& S2_DIGITAL_FILT(9)& --bits 11 downto 8
						          S2_DIGITAL_FILT(8)& S2_LOCK(26)& "000"& S2_LOCK(19)& S2_LOCK(18)& "0", --bits 7 downto 0								
						          
        23+20 => "1"&X"9"& X"0000"& S2_LOCK(24)& S2_LOCK(25)& S2_LOCK(21)& S2_LOCK(14)& S2_LOCK(11)& --bits 15 downto 11
						          S2_LOCK(12)& S2_LOCK(20)& S2_LOCK(6)& S2_LOCK(35)& S2_LOCK(36)& --bits 10 downto 6
						          S2_LOCK(37)& S2_LOCK(3)& S2_LOCK(33)& S2_LOCK(31)& S2_LOCK(34)& S2_LOCK(30), --bits 5 downto 0
						          
        23+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S2_LOCK(28)& S2_LOCK(29),  --bits 15 downto 0

        23+22 => "1"&X"D"& X"2FFF"& S2_LOCK(7)& S2_LOCK(4)& "0"& S2_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 3 Initialization
        --***********************************************************************
        46+0 => "0"&X"5"& X"50FF"&  S3_CLKOUT0(19)& "0"& S3_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S3_CLKOUT0(16)& S3_CLKOUT0(17)& S3_CLKOUT0(15)& S3_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        46+1 => "0"&X"6"& X"010B"&  S3_CLKOUT1(4)& S3_CLKOUT1(5)& S3_CLKOUT1(3)& S3_CLKOUT1(12)& --bits 15 down to 12
                                  S3_CLKOUT1(1)& S3_CLKOUT1(2)& S3_CLKOUT1(19)& "0"& S3_CLKOUT1(17)& S3_CLKOUT1(16)& --bits 11 down to 6
						          S3_CLKOUT1(14)& S3_CLKOUT1(15)& "0"& S3_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        46+2 => "0"&X"7"& X"E02C"&  "000"& S3_CLKOUT1(11)& S3_CLKOUT1(9)& S3_CLKOUT1(10)& --bits 15 down to 10
                                  S3_CLKOUT1(8)& S3_CLKOUT1(7)& S3_CLKOUT1(6)& S3_CLKOUT1(20)& "0"& S3_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S3_CLKOUT1(21)& S3_CLKOUT1(22), --bits 3 down to 0
						         
        46+3 => "0"&X"8"& X"4001"&  S3_CLKOUT2(22)& "0"& S3_CLKOUT2(5)& S3_CLKOUT2(21)& --bits 15 downto 12
                                  S3_CLKOUT2(12)& S3_CLKOUT2(4)& S3_CLKOUT2(3)& S3_CLKOUT2(2)& S3_CLKOUT2(0)& S3_CLKOUT2(19)& --bits 11 down to 6
						          S3_CLKOUT2(17)& S3_CLKOUT2(18)& S3_CLKOUT2(15)& S3_CLKOUT2(16)& S3_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        46+4 => "0"&X"9"& X"0D03"&  S3_CLKOUT3(14)& S3_CLKOUT3(15)& S3_CLKOUT0(21)& S3_CLKOUT0(22)& "00"& S3_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S3_CLKOUT2(9)& S3_CLKOUT2(8)& S3_CLKOUT2(6)& S3_CLKOUT2(7)& S3_CLKOUT2(13)& S3_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        46+5 => "0"&X"A"& X"B001"&  "0"& S3_CLKOUT3(13)& "00"& S3_CLKOUT3(21)& S3_CLKOUT3(22)& S3_CLKOUT3(5)& S3_CLKOUT3(4)& --bits 15 downto 8
                                  S3_CLKOUT3(12)& S3_CLKOUT3(2)& S3_CLKOUT3(0)& S3_CLKOUT3(1)& S3_CLKOUT3(18)& S3_CLKOUT3(19)& --bits 7 downto 2
						          S3_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        46+6 => "0"&X"B"& X"0110"&  S3_CLKOUT0(5)& S3_CLKOUT4(19)& S3_CLKOUT4(14)& S3_CLKOUT4(17)& --bits 15 downto 12
                                  S3_CLKOUT4(15)& S3_CLKOUT4(16)& S3_CLKOUT0(4)& "0"& S3_CLKOUT3(11)& S3_CLKOUT3(10)& --bits 11 downto 6 
						          S3_CLKOUT3(9)& "0"& S3_CLKOUT3(7)& S3_CLKOUT3(8)& S3_CLKOUT3(20)& S3_CLKOUT3(6), --bits 5 downto 0
						         
        46+7 => "0"&X"C"& X"0B00"&  S3_CLKOUT4(7)& S3_CLKOUT4(8)& S3_CLKOUT4(20)& S3_CLKOUT4(6)& "0"& S3_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S3_CLKOUT4(22)& S3_CLKOUT4(21)& S3_CLKOUT4(4)& S3_CLKOUT4(5)& S3_CLKOUT4(3)& --bits 9 downto 3
						          S3_CLKOUT4(12)& S3_CLKOUT4(1)& S3_CLKOUT4(2), --bits 2 downto 0
						         
        46+8 => "0"&X"D"& X"0008"&  S3_CLKOUT5(2)& S3_CLKOUT5(3)& S3_CLKOUT5(0)& S3_CLKOUT5(1)& S3_CLKOUT5(18)& --bits 15 downto 11
						          S3_CLKOUT5(19)& S3_CLKOUT5(17)& S3_CLKOUT5(16)& S3_CLKOUT5(15)& S3_CLKOUT0(3)& --bits 10 downto 6
						          S3_CLKOUT0(0)& S3_CLKOUT0(2)& "0"& S3_CLKOUT4(11)& S3_CLKOUT4(9)& S3_CLKOUT4(10), --bits 5 downto 0
						         
        46+9 => "0"&X"E"& X"00D0"&  S3_CLKOUT5(10)& S3_CLKOUT5(11)& S3_CLKOUT5(8)& S3_CLKOUT5(9)& S3_CLKOUT5(6)& --bits 15 downto 11
						          S3_CLKOUT5(7)& S3_CLKOUT5(20)& S3_CLKOUT5(13)& "00"& S3_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S3_CLKOUT5(5)& S3_CLKOUT5(21)& S3_CLKOUT5(12)& S3_CLKOUT5(4), --bits 3 downto 0
						         
        46+10 => "0"&X"F"& X"0003"& S3_CLKFBOUT(4)& S3_CLKFBOUT(5)& S3_CLKFBOUT(3)& S3_CLKFBOUT(12)& S3_CLKFBOUT(1)& --bits 15 downto 11
                                  S3_CLKFBOUT(2)& S3_CLKFBOUT(0)& S3_CLKFBOUT(19)& S3_CLKFBOUT(18)& S3_CLKFBOUT(17)& --bits 10 downto 6
						          S3_CLKFBOUT(15)& S3_CLKFBOUT(16)& S3_CLKOUT0(12)& S3_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        46+11 => "1"&X"0"& X"800C"& "0"& S3_CLKOUT0(9)& S3_CLKOUT0(11)& S3_CLKOUT0(10)& S3_CLKFBOUT(10)& S3_CLKFBOUT(11)& --bits 15 downto 10
						          S3_CLKFBOUT(9)& S3_CLKFBOUT(8)& S3_CLKFBOUT(7)& S3_CLKFBOUT(6)& S3_CLKFBOUT(13)&  --bits 9 downto 5
						          S3_CLKFBOUT(20)& "00"& S3_CLKFBOUT(21)& S3_CLKFBOUT(22), --bits 4 downto 0
								
        46+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S3_CLKOUT3(3)& S3_CLKOUT3(16)& S3_CLKOUT2(11)& S3_CLKOUT2(1)& S3_CLKOUT1(18)& --bits 15 downto 6
						          S3_CLKOUT1(0)& S3_CLKOUT0(6)& S3_CLKOUT0(20)& S3_CLKOUT0(8)& S3_CLKOUT0(7), --bits 5 downto 0
						          
        46+13 => "1"&X"2"& X"F0FF"& X"0"& S3_CLKOUT5(14)& S3_CLKFBOUT(14)& S3_CLKOUT4(0)& S3_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        46+14 => "1"&X"3"& X"5120"& S3_DIVCLK(11)& "0"& S3_DIVCLK(10)& "0"& S3_DIVCLK(7)& S3_DIVCLK(8)&  --bits 15 downto 10
                                  S3_DIVCLK(0)& "0"& S3_DIVCLK(5)& S3_DIVCLK(2)& "0"& S3_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        46+15 => "1"&X"4"& X"2FFF"& S3_LOCK(1)& S3_LOCK(2)& "0"& S3_LOCK(0)& X"000", --bits 15 downto 0
						          
        46+16 => "1"&X"5"& X"BFF4"& "0"& S3_DIVCLK(12)& "00"&X"00"& S3_LOCK(38)& "0"& S3_LOCK(32)& S3_LOCK(39), --bits 15 downto 0								  
						          
        46+17 => "1"&X"6"& X"0A55"& S3_LOCK(15)& S3_LOCK(13)& S3_LOCK(27)& S3_LOCK(16)& "0"& S3_LOCK(10)&   --bits 15 downto 10
                                  "0"& S3_DIVCLK(9)& S3_DIVCLK(1)& "0"& S3_DIVCLK(6)& "0"& S3_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S3_DIVCLK(4)& "0",  --bits 2 downto 0

        46+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S3_LOCK(17)& "0"& S3_LOCK(8)& S3_LOCK(9)& S3_LOCK(23)& S3_LOCK(22), --bits 15 downto 0	  
						          
        46+19 => "1"&X"8"& X"1039"& S3_DIGITAL_FILT(6)& S3_DIGITAL_FILT(7)& S3_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S3_DIGITAL_FILT(2)& S3_DIGITAL_FILT(1)& S3_DIGITAL_FILT(3)& S3_DIGITAL_FILT(9)& --bits 11 downto 8
						          S3_DIGITAL_FILT(8)& S3_LOCK(26)& "000"& S3_LOCK(19)& S3_LOCK(18)& "0", --bits 7 downto 0								
						          
        46+20 => "1"&X"9"& X"0000"& S3_LOCK(24)& S3_LOCK(25)& S3_LOCK(21)& S3_LOCK(14)& S3_LOCK(11)& --bits 15 downto 11
						          S3_LOCK(12)& S3_LOCK(20)& S3_LOCK(6)& S3_LOCK(35)& S3_LOCK(36)& --bits 10 downto 6
						          S3_LOCK(37)& S3_LOCK(3)& S3_LOCK(33)& S3_LOCK(31)& S3_LOCK(34)& S3_LOCK(30), --bits 5 downto 0
						          
        46+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S3_LOCK(28)& S3_LOCK(29),  --bits 15 downto 0

        46+22 => "1"&X"D"& X"2FFF"& S3_LOCK(7)& S3_LOCK(4)& "0"& S3_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 4 Initialization
        --***********************************************************************
        69+0 => "0"&X"5"& X"50FF"&  S4_CLKOUT0(19)& "0"& S4_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S4_CLKOUT0(16)& S4_CLKOUT0(17)& S4_CLKOUT0(15)& S4_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        69+1 => "0"&X"6"& X"010B"&  S4_CLKOUT1(4)& S4_CLKOUT1(5)& S4_CLKOUT1(3)& S4_CLKOUT1(12)& --bits 15 down to 12
                                  S4_CLKOUT1(1)& S4_CLKOUT1(2)& S4_CLKOUT1(19)& "0"& S4_CLKOUT1(17)& S4_CLKOUT1(16)& --bits 11 down to 6
						          S4_CLKOUT1(14)& S4_CLKOUT1(15)& "0"& S4_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        69+2 => "0"&X"7"& X"E02C"&  "000"& S4_CLKOUT1(11)& S4_CLKOUT1(9)& S4_CLKOUT1(10)& --bits 15 down to 10
                                  S4_CLKOUT1(8)& S4_CLKOUT1(7)& S4_CLKOUT1(6)& S4_CLKOUT1(20)& "0"& S4_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S4_CLKOUT1(21)& S4_CLKOUT1(22), --bits 3 down to 0
						         
        69+3 => "0"&X"8"& X"4001"&  S4_CLKOUT2(22)& "0"& S4_CLKOUT2(5)& S4_CLKOUT2(21)& --bits 15 downto 12
                                  S4_CLKOUT2(12)& S4_CLKOUT2(4)& S4_CLKOUT2(3)& S4_CLKOUT2(2)& S4_CLKOUT2(0)& S4_CLKOUT2(19)& --bits 11 down to 6
						          S4_CLKOUT2(17)& S4_CLKOUT2(18)& S4_CLKOUT2(15)& S4_CLKOUT2(16)& S4_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        69+4 => "0"&X"9"& X"0D03"&  S4_CLKOUT3(14)& S4_CLKOUT3(15)& S4_CLKOUT0(21)& S4_CLKOUT0(22)& "00"& S4_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S4_CLKOUT2(9)& S4_CLKOUT2(8)& S4_CLKOUT2(6)& S4_CLKOUT2(7)& S4_CLKOUT2(13)& S4_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        69+5 => "0"&X"A"& X"B001"&  "0"& S4_CLKOUT3(13)& "00"& S4_CLKOUT3(21)& S4_CLKOUT3(22)& S4_CLKOUT3(5)& S4_CLKOUT3(4)& --bits 15 downto 8
                                  S4_CLKOUT3(12)& S4_CLKOUT3(2)& S4_CLKOUT3(0)& S4_CLKOUT3(1)& S4_CLKOUT3(18)& S4_CLKOUT3(19)& --bits 7 downto 2
						          S4_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        69+6 => "0"&X"B"& X"0110"&  S4_CLKOUT0(5)& S4_CLKOUT4(19)& S4_CLKOUT4(14)& S4_CLKOUT4(17)& --bits 15 downto 12
                                  S4_CLKOUT4(15)& S4_CLKOUT4(16)& S4_CLKOUT0(4)& "0"& S4_CLKOUT3(11)& S4_CLKOUT3(10)& --bits 11 downto 6 
						          S4_CLKOUT3(9)& "0"& S4_CLKOUT3(7)& S4_CLKOUT3(8)& S4_CLKOUT3(20)& S4_CLKOUT3(6), --bits 5 downto 0
						         
        69+7 => "0"&X"C"& X"0B00"&  S4_CLKOUT4(7)& S4_CLKOUT4(8)& S4_CLKOUT4(20)& S4_CLKOUT4(6)& "0"& S4_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S4_CLKOUT4(22)& S4_CLKOUT4(21)& S4_CLKOUT4(4)& S4_CLKOUT4(5)& S4_CLKOUT4(3)& --bits 9 downto 3
						          S4_CLKOUT4(12)& S4_CLKOUT4(1)& S4_CLKOUT4(2), --bits 2 downto 0
						         
        69+8 => "0"&X"D"& X"0008"&  S4_CLKOUT5(2)& S4_CLKOUT5(3)& S4_CLKOUT5(0)& S4_CLKOUT5(1)& S4_CLKOUT5(18)& --bits 15 downto 11
						          S4_CLKOUT5(19)& S4_CLKOUT5(17)& S4_CLKOUT5(16)& S4_CLKOUT5(15)& S4_CLKOUT0(3)& --bits 10 downto 6
						          S4_CLKOUT0(0)& S4_CLKOUT0(2)& "0"& S4_CLKOUT4(11)& S4_CLKOUT4(9)& S4_CLKOUT4(10), --bits 5 downto 0
						         
        69+9 => "0"&X"E"& X"00D0"&  S4_CLKOUT5(10)& S4_CLKOUT5(11)& S4_CLKOUT5(8)& S4_CLKOUT5(9)& S4_CLKOUT5(6)& --bits 15 downto 11
						          S4_CLKOUT5(7)& S4_CLKOUT5(20)& S4_CLKOUT5(13)& "00"& S4_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S4_CLKOUT5(5)& S4_CLKOUT5(21)& S4_CLKOUT5(12)& S4_CLKOUT5(4), --bits 3 downto 0
						         
        69+10 => "0"&X"F"& X"0003"& S4_CLKFBOUT(4)& S4_CLKFBOUT(5)& S4_CLKFBOUT(3)& S4_CLKFBOUT(12)& S4_CLKFBOUT(1)& --bits 15 downto 11
                                  S4_CLKFBOUT(2)& S4_CLKFBOUT(0)& S4_CLKFBOUT(19)& S4_CLKFBOUT(18)& S4_CLKFBOUT(17)& --bits 10 downto 6
						          S4_CLKFBOUT(15)& S4_CLKFBOUT(16)& S4_CLKOUT0(12)& S4_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        69+11 => "1"&X"0"& X"800C"& "0"& S4_CLKOUT0(9)& S4_CLKOUT0(11)& S4_CLKOUT0(10)& S4_CLKFBOUT(10)& S4_CLKFBOUT(11)& --bits 15 downto 10
						          S4_CLKFBOUT(9)& S4_CLKFBOUT(8)& S4_CLKFBOUT(7)& S4_CLKFBOUT(6)& S4_CLKFBOUT(13)&  --bits 9 downto 5
						          S4_CLKFBOUT(20)& "00"& S4_CLKFBOUT(21)& S4_CLKFBOUT(22), --bits 4 downto 0
								
        69+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S4_CLKOUT3(3)& S4_CLKOUT3(16)& S4_CLKOUT2(11)& S4_CLKOUT2(1)& S4_CLKOUT1(18)& --bits 15 downto 6
						          S4_CLKOUT1(0)& S4_CLKOUT0(6)& S4_CLKOUT0(20)& S4_CLKOUT0(8)& S4_CLKOUT0(7), --bits 5 downto 0
						          
        69+13 => "1"&X"2"& X"F0FF"& X"0"& S4_CLKOUT5(14)& S4_CLKFBOUT(14)& S4_CLKOUT4(0)& S4_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        69+14 => "1"&X"3"& X"5120"& S4_DIVCLK(11)& "0"& S4_DIVCLK(10)& "0"& S4_DIVCLK(7)& S4_DIVCLK(8)&  --bits 15 downto 10
                                  S4_DIVCLK(0)& "0"& S4_DIVCLK(5)& S4_DIVCLK(2)& "0"& S4_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        69+15 => "1"&X"4"& X"2FFF"& S4_LOCK(1)& S4_LOCK(2)& "0"& S4_LOCK(0)& X"000", --bits 15 downto 0
						          
        69+16 => "1"&X"5"& X"BFF4"& "0"& S4_DIVCLK(12)& "00"&X"00"& S4_LOCK(38)& "0"& S4_LOCK(32)& S4_LOCK(39), --bits 15 downto 0								  
						          
        69+17 => "1"&X"6"& X"0A55"& S4_LOCK(15)& S4_LOCK(13)& S4_LOCK(27)& S4_LOCK(16)& "0"& S4_LOCK(10)&   --bits 15 downto 10
                                  "0"& S4_DIVCLK(9)& S4_DIVCLK(1)& "0"& S4_DIVCLK(6)& "0"& S4_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S4_DIVCLK(4)& "0",  --bits 2 downto 0

        69+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S4_LOCK(17)& "0"& S4_LOCK(8)& S4_LOCK(9)& S4_LOCK(23)& S4_LOCK(22), --bits 15 downto 0	  
						          
        69+19 => "1"&X"8"& X"1039"& S4_DIGITAL_FILT(6)& S4_DIGITAL_FILT(7)& S4_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S4_DIGITAL_FILT(2)& S4_DIGITAL_FILT(1)& S4_DIGITAL_FILT(3)& S4_DIGITAL_FILT(9)& --bits 11 downto 8
						          S4_DIGITAL_FILT(8)& S4_LOCK(26)& "000"& S4_LOCK(19)& S4_LOCK(18)& "0", --bits 7 downto 0								
						          
        69+20 => "1"&X"9"& X"0000"& S4_LOCK(24)& S4_LOCK(25)& S4_LOCK(21)& S4_LOCK(14)& S4_LOCK(11)& --bits 15 downto 11
						          S4_LOCK(12)& S4_LOCK(20)& S4_LOCK(6)& S4_LOCK(35)& S4_LOCK(36)& --bits 10 downto 6
						          S4_LOCK(37)& S4_LOCK(3)& S4_LOCK(33)& S4_LOCK(31)& S4_LOCK(34)& S4_LOCK(30), --bits 5 downto 0
						          
        69+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S4_LOCK(28)& S4_LOCK(29),  --bits 15 downto 0

        69+22 => "1"&X"D"& X"2FFF"& S4_LOCK(7)& S4_LOCK(4)& "0"& S4_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 5 Initialization
        --***********************************************************************
        92+0 => "0"&X"5"& X"50FF"&  S5_CLKOUT0(19)& "0"& S5_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S5_CLKOUT0(16)& S5_CLKOUT0(17)& S5_CLKOUT0(15)& S5_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        92+1 => "0"&X"6"& X"010B"&  S5_CLKOUT1(4)& S5_CLKOUT1(5)& S5_CLKOUT1(3)& S5_CLKOUT1(12)& --bits 15 down to 12
                                  S5_CLKOUT1(1)& S5_CLKOUT1(2)& S5_CLKOUT1(19)& "0"& S5_CLKOUT1(17)& S5_CLKOUT1(16)& --bits 11 down to 6
						          S5_CLKOUT1(14)& S5_CLKOUT1(15)& "0"& S5_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        92+2 => "0"&X"7"& X"E02C"&  "000"& S5_CLKOUT1(11)& S5_CLKOUT1(9)& S5_CLKOUT1(10)& --bits 15 down to 10
                                  S5_CLKOUT1(8)& S5_CLKOUT1(7)& S5_CLKOUT1(6)& S5_CLKOUT1(20)& "0"& S5_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S5_CLKOUT1(21)& S5_CLKOUT1(22), --bits 3 down to 0
						         
        92+3 => "0"&X"8"& X"4001"&  S5_CLKOUT2(22)& "0"& S5_CLKOUT2(5)& S5_CLKOUT2(21)& --bits 15 downto 12
                                  S5_CLKOUT2(12)& S5_CLKOUT2(4)& S5_CLKOUT2(3)& S5_CLKOUT2(2)& S5_CLKOUT2(0)& S5_CLKOUT2(19)& --bits 11 down to 6
						          S5_CLKOUT2(17)& S5_CLKOUT2(18)& S5_CLKOUT2(15)& S5_CLKOUT2(16)& S5_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        92+4 => "0"&X"9"& X"0D03"&  S5_CLKOUT3(14)& S5_CLKOUT3(15)& S5_CLKOUT0(21)& S5_CLKOUT0(22)& "00"& S5_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S5_CLKOUT2(9)& S5_CLKOUT2(8)& S5_CLKOUT2(6)& S5_CLKOUT2(7)& S5_CLKOUT2(13)& S5_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        92+5 => "0"&X"A"& X"B001"&  "0"& S5_CLKOUT3(13)& "00"& S5_CLKOUT3(21)& S5_CLKOUT3(22)& S5_CLKOUT3(5)& S5_CLKOUT3(4)& --bits 15 downto 8
                                  S5_CLKOUT3(12)& S5_CLKOUT3(2)& S5_CLKOUT3(0)& S5_CLKOUT3(1)& S5_CLKOUT3(18)& S5_CLKOUT3(19)& --bits 7 downto 2
						          S5_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        92+6 => "0"&X"B"& X"0110"&  S5_CLKOUT0(5)& S5_CLKOUT4(19)& S5_CLKOUT4(14)& S5_CLKOUT4(17)& --bits 15 downto 12
                                  S5_CLKOUT4(15)& S5_CLKOUT4(16)& S5_CLKOUT0(4)& "0"& S5_CLKOUT3(11)& S5_CLKOUT3(10)& --bits 11 downto 6 
						          S5_CLKOUT3(9)& "0"& S5_CLKOUT3(7)& S5_CLKOUT3(8)& S5_CLKOUT3(20)& S5_CLKOUT3(6), --bits 5 downto 0
						         
        92+7 => "0"&X"C"& X"0B00"&  S5_CLKOUT4(7)& S5_CLKOUT4(8)& S5_CLKOUT4(20)& S5_CLKOUT4(6)& "0"& S5_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S5_CLKOUT4(22)& S5_CLKOUT4(21)& S5_CLKOUT4(4)& S5_CLKOUT4(5)& S5_CLKOUT4(3)& --bits 9 downto 3
						          S5_CLKOUT4(12)& S5_CLKOUT4(1)& S5_CLKOUT4(2), --bits 2 downto 0
						         
        92+8 => "0"&X"D"& X"0008"&  S5_CLKOUT5(2)& S5_CLKOUT5(3)& S5_CLKOUT5(0)& S5_CLKOUT5(1)& S5_CLKOUT5(18)& --bits 15 downto 11
						          S5_CLKOUT5(19)& S5_CLKOUT5(17)& S5_CLKOUT5(16)& S5_CLKOUT5(15)& S5_CLKOUT0(3)& --bits 10 downto 6
						          S5_CLKOUT0(0)& S5_CLKOUT0(2)& "0"& S5_CLKOUT4(11)& S5_CLKOUT4(9)& S5_CLKOUT4(10), --bits 5 downto 0
						         
        92+9 => "0"&X"E"& X"00D0"&  S5_CLKOUT5(10)& S5_CLKOUT5(11)& S5_CLKOUT5(8)& S5_CLKOUT5(9)& S5_CLKOUT5(6)& --bits 15 downto 11
						          S5_CLKOUT5(7)& S5_CLKOUT5(20)& S5_CLKOUT5(13)& "00"& S5_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S5_CLKOUT5(5)& S5_CLKOUT5(21)& S5_CLKOUT5(12)& S5_CLKOUT5(4), --bits 3 downto 0
						         
        92+10 => "0"&X"F"& X"0003"& S5_CLKFBOUT(4)& S5_CLKFBOUT(5)& S5_CLKFBOUT(3)& S5_CLKFBOUT(12)& S5_CLKFBOUT(1)& --bits 15 downto 11
                                  S5_CLKFBOUT(2)& S5_CLKFBOUT(0)& S5_CLKFBOUT(19)& S5_CLKFBOUT(18)& S5_CLKFBOUT(17)& --bits 10 downto 6
						          S5_CLKFBOUT(15)& S5_CLKFBOUT(16)& S5_CLKOUT0(12)& S5_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        92+11 => "1"&X"0"& X"800C"& "0"& S5_CLKOUT0(9)& S5_CLKOUT0(11)& S5_CLKOUT0(10)& S5_CLKFBOUT(10)& S5_CLKFBOUT(11)& --bits 15 downto 10
						          S5_CLKFBOUT(9)& S5_CLKFBOUT(8)& S5_CLKFBOUT(7)& S5_CLKFBOUT(6)& S5_CLKFBOUT(13)&  --bits 9 downto 5
						          S5_CLKFBOUT(20)& "00"& S5_CLKFBOUT(21)& S5_CLKFBOUT(22), --bits 4 downto 0
								
        92+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S5_CLKOUT3(3)& S5_CLKOUT3(16)& S5_CLKOUT2(11)& S5_CLKOUT2(1)& S5_CLKOUT1(18)& --bits 15 downto 6
						          S5_CLKOUT1(0)& S5_CLKOUT0(6)& S5_CLKOUT0(20)& S5_CLKOUT0(8)& S5_CLKOUT0(7), --bits 5 downto 0
						          
        92+13 => "1"&X"2"& X"F0FF"& X"0"& S5_CLKOUT5(14)& S5_CLKFBOUT(14)& S5_CLKOUT4(0)& S5_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        92+14 => "1"&X"3"& X"5120"& S5_DIVCLK(11)& "0"& S5_DIVCLK(10)& "0"& S5_DIVCLK(7)& S5_DIVCLK(8)&  --bits 15 downto 10
                                  S5_DIVCLK(0)& "0"& S5_DIVCLK(5)& S5_DIVCLK(2)& "0"& S5_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        92+15 => "1"&X"4"& X"2FFF"& S5_LOCK(1)& S5_LOCK(2)& "0"& S5_LOCK(0)& X"000", --bits 15 downto 0
						          
        92+16 => "1"&X"5"& X"BFF4"& "0"& S5_DIVCLK(12)& "00"&X"00"& S5_LOCK(38)& "0"& S5_LOCK(32)& S5_LOCK(39), --bits 15 downto 0								  
						          
        92+17 => "1"&X"6"& X"0A55"& S5_LOCK(15)& S5_LOCK(13)& S5_LOCK(27)& S5_LOCK(16)& "0"& S5_LOCK(10)&   --bits 15 downto 10
                                  "0"& S5_DIVCLK(9)& S5_DIVCLK(1)& "0"& S5_DIVCLK(6)& "0"& S5_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S5_DIVCLK(4)& "0",  --bits 2 downto 0

        92+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S5_LOCK(17)& "0"& S5_LOCK(8)& S5_LOCK(9)& S5_LOCK(23)& S5_LOCK(22), --bits 15 downto 0	  
						          
        92+19 => "1"&X"8"& X"1039"& S5_DIGITAL_FILT(6)& S5_DIGITAL_FILT(7)& S5_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S5_DIGITAL_FILT(2)& S5_DIGITAL_FILT(1)& S5_DIGITAL_FILT(3)& S5_DIGITAL_FILT(9)& --bits 11 downto 8
						          S5_DIGITAL_FILT(8)& S5_LOCK(26)& "000"& S5_LOCK(19)& S5_LOCK(18)& "0", --bits 7 downto 0								
						          
        92+20 => "1"&X"9"& X"0000"& S5_LOCK(24)& S5_LOCK(25)& S5_LOCK(21)& S5_LOCK(14)& S5_LOCK(11)& --bits 15 downto 11
						          S5_LOCK(12)& S5_LOCK(20)& S5_LOCK(6)& S5_LOCK(35)& S5_LOCK(36)& --bits 10 downto 6
						          S5_LOCK(37)& S5_LOCK(3)& S5_LOCK(33)& S5_LOCK(31)& S5_LOCK(34)& S5_LOCK(30), --bits 5 downto 0
						          
        92+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S5_LOCK(28)& S5_LOCK(29),  --bits 15 downto 0

        92+22 => "1"&X"D"& X"2FFF"& S5_LOCK(7)& S5_LOCK(4)& "0"& S5_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 6 Initialization
        --***********************************************************************
        115+0 => "0"&X"5"& X"50FF"&  S6_CLKOUT0(19)& "0"& S6_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S6_CLKOUT0(16)& S6_CLKOUT0(17)& S6_CLKOUT0(15)& S6_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        115+1 => "0"&X"6"& X"010B"&  S6_CLKOUT1(4)& S6_CLKOUT1(5)& S6_CLKOUT1(3)& S6_CLKOUT1(12)& --bits 15 down to 12
                                  S6_CLKOUT1(1)& S6_CLKOUT1(2)& S6_CLKOUT1(19)& "0"& S6_CLKOUT1(17)& S6_CLKOUT1(16)& --bits 11 down to 6
						          S6_CLKOUT1(14)& S6_CLKOUT1(15)& "0"& S6_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        115+2 => "0"&X"7"& X"E02C"&  "000"& S6_CLKOUT1(11)& S6_CLKOUT1(9)& S6_CLKOUT1(10)& --bits 15 down to 10
                                  S6_CLKOUT1(8)& S6_CLKOUT1(7)& S6_CLKOUT1(6)& S6_CLKOUT1(20)& "0"& S6_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S6_CLKOUT1(21)& S6_CLKOUT1(22), --bits 3 down to 0
						         
        115+3 => "0"&X"8"& X"4001"&  S6_CLKOUT2(22)& "0"& S6_CLKOUT2(5)& S6_CLKOUT2(21)& --bits 15 downto 12
                                  S6_CLKOUT2(12)& S6_CLKOUT2(4)& S6_CLKOUT2(3)& S6_CLKOUT2(2)& S6_CLKOUT2(0)& S6_CLKOUT2(19)& --bits 11 down to 6
						          S6_CLKOUT2(17)& S6_CLKOUT2(18)& S6_CLKOUT2(15)& S6_CLKOUT2(16)& S6_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        115+4 => "0"&X"9"& X"0D03"&  S6_CLKOUT3(14)& S6_CLKOUT3(15)& S6_CLKOUT0(21)& S6_CLKOUT0(22)& "00"& S6_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S6_CLKOUT2(9)& S6_CLKOUT2(8)& S6_CLKOUT2(6)& S6_CLKOUT2(7)& S6_CLKOUT2(13)& S6_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        115+5 => "0"&X"A"& X"B001"&  "0"& S6_CLKOUT3(13)& "00"& S6_CLKOUT3(21)& S6_CLKOUT3(22)& S6_CLKOUT3(5)& S6_CLKOUT3(4)& --bits 15 downto 8
                                  S6_CLKOUT3(12)& S6_CLKOUT3(2)& S6_CLKOUT3(0)& S6_CLKOUT3(1)& S6_CLKOUT3(18)& S6_CLKOUT3(19)& --bits 7 downto 2
						          S6_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        115+6 => "0"&X"B"& X"0110"&  S6_CLKOUT0(5)& S6_CLKOUT4(19)& S6_CLKOUT4(14)& S6_CLKOUT4(17)& --bits 15 downto 12
                                  S6_CLKOUT4(15)& S6_CLKOUT4(16)& S6_CLKOUT0(4)& "0"& S6_CLKOUT3(11)& S6_CLKOUT3(10)& --bits 11 downto 6 
						          S6_CLKOUT3(9)& "0"& S6_CLKOUT3(7)& S6_CLKOUT3(8)& S6_CLKOUT3(20)& S6_CLKOUT3(6), --bits 5 downto 0
						         
        115+7 => "0"&X"C"& X"0B00"&  S6_CLKOUT4(7)& S6_CLKOUT4(8)& S6_CLKOUT4(20)& S6_CLKOUT4(6)& "0"& S6_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S6_CLKOUT4(22)& S6_CLKOUT4(21)& S6_CLKOUT4(4)& S6_CLKOUT4(5)& S6_CLKOUT4(3)& --bits 9 downto 3
						          S6_CLKOUT4(12)& S6_CLKOUT4(1)& S6_CLKOUT4(2), --bits 2 downto 0
						         
        115+8 => "0"&X"D"& X"0008"&  S6_CLKOUT5(2)& S6_CLKOUT5(3)& S6_CLKOUT5(0)& S6_CLKOUT5(1)& S6_CLKOUT5(18)& --bits 15 downto 11
						          S6_CLKOUT5(19)& S6_CLKOUT5(17)& S6_CLKOUT5(16)& S6_CLKOUT5(15)& S6_CLKOUT0(3)& --bits 10 downto 6
						          S6_CLKOUT0(0)& S6_CLKOUT0(2)& "0"& S6_CLKOUT4(11)& S6_CLKOUT4(9)& S6_CLKOUT4(10), --bits 5 downto 0
						         
        115+9 => "0"&X"E"& X"00D0"&  S6_CLKOUT5(10)& S6_CLKOUT5(11)& S6_CLKOUT5(8)& S6_CLKOUT5(9)& S6_CLKOUT5(6)& --bits 15 downto 11
						          S6_CLKOUT5(7)& S6_CLKOUT5(20)& S6_CLKOUT5(13)& "00"& S6_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S6_CLKOUT5(5)& S6_CLKOUT5(21)& S6_CLKOUT5(12)& S6_CLKOUT5(4), --bits 3 downto 0
						         
        115+10 => "0"&X"F"& X"0003"& S6_CLKFBOUT(4)& S6_CLKFBOUT(5)& S6_CLKFBOUT(3)& S6_CLKFBOUT(12)& S6_CLKFBOUT(1)& --bits 15 downto 11
                                  S6_CLKFBOUT(2)& S6_CLKFBOUT(0)& S6_CLKFBOUT(19)& S6_CLKFBOUT(18)& S6_CLKFBOUT(17)& --bits 10 downto 6
						          S6_CLKFBOUT(15)& S6_CLKFBOUT(16)& S6_CLKOUT0(12)& S6_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        115+11 => "1"&X"0"& X"800C"& "0"& S6_CLKOUT0(9)& S6_CLKOUT0(11)& S6_CLKOUT0(10)& S6_CLKFBOUT(10)& S6_CLKFBOUT(11)& --bits 15 downto 10
						          S6_CLKFBOUT(9)& S6_CLKFBOUT(8)& S6_CLKFBOUT(7)& S6_CLKFBOUT(6)& S6_CLKFBOUT(13)&  --bits 9 downto 5
						          S6_CLKFBOUT(20)& "00"& S6_CLKFBOUT(21)& S6_CLKFBOUT(22), --bits 4 downto 0
								
        115+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S6_CLKOUT3(3)& S6_CLKOUT3(16)& S6_CLKOUT2(11)& S6_CLKOUT2(1)& S6_CLKOUT1(18)& --bits 15 downto 6
						          S6_CLKOUT1(0)& S6_CLKOUT0(6)& S6_CLKOUT0(20)& S6_CLKOUT0(8)& S6_CLKOUT0(7), --bits 5 downto 0
						          
        115+13 => "1"&X"2"& X"F0FF"& X"0"& S6_CLKOUT5(14)& S6_CLKFBOUT(14)& S6_CLKOUT4(0)& S6_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        115+14 => "1"&X"3"& X"5120"& S6_DIVCLK(11)& "0"& S6_DIVCLK(10)& "0"& S6_DIVCLK(7)& S6_DIVCLK(8)&  --bits 15 downto 10
                                  S6_DIVCLK(0)& "0"& S6_DIVCLK(5)& S6_DIVCLK(2)& "0"& S6_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        115+15 => "1"&X"4"& X"2FFF"& S6_LOCK(1)& S6_LOCK(2)& "0"& S6_LOCK(0)& X"000", --bits 15 downto 0
						          
        115+16 => "1"&X"5"& X"BFF4"& "0"& S6_DIVCLK(12)& "00"&X"00"& S6_LOCK(38)& "0"& S6_LOCK(32)& S6_LOCK(39), --bits 15 downto 0								  
						          
        115+17 => "1"&X"6"& X"0A55"& S6_LOCK(15)& S6_LOCK(13)& S6_LOCK(27)& S6_LOCK(16)& "0"& S6_LOCK(10)&   --bits 15 downto 10
                                  "0"& S6_DIVCLK(9)& S6_DIVCLK(1)& "0"& S6_DIVCLK(6)& "0"& S6_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S6_DIVCLK(4)& "0",  --bits 2 downto 0

        115+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S6_LOCK(17)& "0"& S6_LOCK(8)& S6_LOCK(9)& S6_LOCK(23)& S6_LOCK(22), --bits 15 downto 0	  
						          
        115+19 => "1"&X"8"& X"1039"& S6_DIGITAL_FILT(6)& S6_DIGITAL_FILT(7)& S6_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S6_DIGITAL_FILT(2)& S6_DIGITAL_FILT(1)& S6_DIGITAL_FILT(3)& S6_DIGITAL_FILT(9)& --bits 11 downto 8
						          S6_DIGITAL_FILT(8)& S6_LOCK(26)& "000"& S6_LOCK(19)& S6_LOCK(18)& "0", --bits 7 downto 0								
						          
        115+20 => "1"&X"9"& X"0000"& S6_LOCK(24)& S6_LOCK(25)& S6_LOCK(21)& S6_LOCK(14)& S6_LOCK(11)& --bits 15 downto 11
						          S6_LOCK(12)& S6_LOCK(20)& S6_LOCK(6)& S6_LOCK(35)& S6_LOCK(36)& --bits 10 downto 6
						          S6_LOCK(37)& S6_LOCK(3)& S6_LOCK(33)& S6_LOCK(31)& S6_LOCK(34)& S6_LOCK(30), --bits 5 downto 0
						          
        115+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S6_LOCK(28)& S6_LOCK(29),  --bits 15 downto 0

        115+22 => "1"&X"D"& X"2FFF"& S6_LOCK(7)& S6_LOCK(4)& "0"& S6_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 7 Initialization
        --***********************************************************************
        138+0 => "0"&X"5"& X"50FF"&  S7_CLKOUT0(19)& "0"& S7_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S7_CLKOUT0(16)& S7_CLKOUT0(17)& S7_CLKOUT0(15)& S7_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        138+1 => "0"&X"6"& X"010B"&  S7_CLKOUT1(4)& S7_CLKOUT1(5)& S7_CLKOUT1(3)& S7_CLKOUT1(12)& --bits 15 down to 12
                                  S7_CLKOUT1(1)& S7_CLKOUT1(2)& S7_CLKOUT1(19)& "0"& S7_CLKOUT1(17)& S7_CLKOUT1(16)& --bits 11 down to 6
						          S7_CLKOUT1(14)& S7_CLKOUT1(15)& "0"& S7_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        138+2 => "0"&X"7"& X"E02C"&  "000"& S7_CLKOUT1(11)& S7_CLKOUT1(9)& S7_CLKOUT1(10)& --bits 15 down to 10
                                  S7_CLKOUT1(8)& S7_CLKOUT1(7)& S7_CLKOUT1(6)& S7_CLKOUT1(20)& "0"& S7_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S7_CLKOUT1(21)& S7_CLKOUT1(22), --bits 3 down to 0
						         
        138+3 => "0"&X"8"& X"4001"&  S7_CLKOUT2(22)& "0"& S7_CLKOUT2(5)& S7_CLKOUT2(21)& --bits 15 downto 12
                                  S7_CLKOUT2(12)& S7_CLKOUT2(4)& S7_CLKOUT2(3)& S7_CLKOUT2(2)& S7_CLKOUT2(0)& S7_CLKOUT2(19)& --bits 11 down to 6
						          S7_CLKOUT2(17)& S7_CLKOUT2(18)& S7_CLKOUT2(15)& S7_CLKOUT2(16)& S7_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        138+4 => "0"&X"9"& X"0D03"&  S7_CLKOUT3(14)& S7_CLKOUT3(15)& S7_CLKOUT0(21)& S7_CLKOUT0(22)& "00"& S7_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S7_CLKOUT2(9)& S7_CLKOUT2(8)& S7_CLKOUT2(6)& S7_CLKOUT2(7)& S7_CLKOUT2(13)& S7_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        138+5 => "0"&X"A"& X"B001"&  "0"& S7_CLKOUT3(13)& "00"& S7_CLKOUT3(21)& S7_CLKOUT3(22)& S7_CLKOUT3(5)& S7_CLKOUT3(4)& --bits 15 downto 8
                                  S7_CLKOUT3(12)& S7_CLKOUT3(2)& S7_CLKOUT3(0)& S7_CLKOUT3(1)& S7_CLKOUT3(18)& S7_CLKOUT3(19)& --bits 7 downto 2
						          S7_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        138+6 => "0"&X"B"& X"0110"&  S7_CLKOUT0(5)& S7_CLKOUT4(19)& S7_CLKOUT4(14)& S7_CLKOUT4(17)& --bits 15 downto 12
                                  S7_CLKOUT4(15)& S7_CLKOUT4(16)& S7_CLKOUT0(4)& "0"& S7_CLKOUT3(11)& S7_CLKOUT3(10)& --bits 11 downto 6 
						          S7_CLKOUT3(9)& "0"& S7_CLKOUT3(7)& S7_CLKOUT3(8)& S7_CLKOUT3(20)& S7_CLKOUT3(6), --bits 5 downto 0
						         
        138+7 => "0"&X"C"& X"0B00"&  S7_CLKOUT4(7)& S7_CLKOUT4(8)& S7_CLKOUT4(20)& S7_CLKOUT4(6)& "0"& S7_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S7_CLKOUT4(22)& S7_CLKOUT4(21)& S7_CLKOUT4(4)& S7_CLKOUT4(5)& S7_CLKOUT4(3)& --bits 9 downto 3
						          S7_CLKOUT4(12)& S7_CLKOUT4(1)& S7_CLKOUT4(2), --bits 2 downto 0
						         
        138+8 => "0"&X"D"& X"0008"&  S7_CLKOUT5(2)& S7_CLKOUT5(3)& S7_CLKOUT5(0)& S7_CLKOUT5(1)& S7_CLKOUT5(18)& --bits 15 downto 11
						          S7_CLKOUT5(19)& S7_CLKOUT5(17)& S7_CLKOUT5(16)& S7_CLKOUT5(15)& S7_CLKOUT0(3)& --bits 10 downto 6
						          S7_CLKOUT0(0)& S7_CLKOUT0(2)& "0"& S7_CLKOUT4(11)& S7_CLKOUT4(9)& S7_CLKOUT4(10), --bits 5 downto 0
						         
        138+9 => "0"&X"E"& X"00D0"&  S7_CLKOUT5(10)& S7_CLKOUT5(11)& S7_CLKOUT5(8)& S7_CLKOUT5(9)& S7_CLKOUT5(6)& --bits 15 downto 11
						          S7_CLKOUT5(7)& S7_CLKOUT5(20)& S7_CLKOUT5(13)& "00"& S7_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S7_CLKOUT5(5)& S7_CLKOUT5(21)& S7_CLKOUT5(12)& S7_CLKOUT5(4), --bits 3 downto 0
						         
        138+10 => "0"&X"F"& X"0003"& S7_CLKFBOUT(4)& S7_CLKFBOUT(5)& S7_CLKFBOUT(3)& S7_CLKFBOUT(12)& S7_CLKFBOUT(1)& --bits 15 downto 11
                                  S7_CLKFBOUT(2)& S7_CLKFBOUT(0)& S7_CLKFBOUT(19)& S7_CLKFBOUT(18)& S7_CLKFBOUT(17)& --bits 10 downto 6
						          S7_CLKFBOUT(15)& S7_CLKFBOUT(16)& S7_CLKOUT0(12)& S7_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        138+11 => "1"&X"0"& X"800C"& "0"& S7_CLKOUT0(9)& S7_CLKOUT0(11)& S7_CLKOUT0(10)& S7_CLKFBOUT(10)& S7_CLKFBOUT(11)& --bits 15 downto 10
						          S7_CLKFBOUT(9)& S7_CLKFBOUT(8)& S7_CLKFBOUT(7)& S7_CLKFBOUT(6)& S7_CLKFBOUT(13)&  --bits 9 downto 5
						          S7_CLKFBOUT(20)& "00"& S7_CLKFBOUT(21)& S7_CLKFBOUT(22), --bits 4 downto 0
								
        138+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S7_CLKOUT3(3)& S7_CLKOUT3(16)& S7_CLKOUT2(11)& S7_CLKOUT2(1)& S7_CLKOUT1(18)& --bits 15 downto 6
						          S7_CLKOUT1(0)& S7_CLKOUT0(6)& S7_CLKOUT0(20)& S7_CLKOUT0(8)& S7_CLKOUT0(7), --bits 5 downto 0
						          
        138+13 => "1"&X"2"& X"F0FF"& X"0"& S7_CLKOUT5(14)& S7_CLKFBOUT(14)& S7_CLKOUT4(0)& S7_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        138+14 => "1"&X"3"& X"5120"& S7_DIVCLK(11)& "0"& S7_DIVCLK(10)& "0"& S7_DIVCLK(7)& S7_DIVCLK(8)&  --bits 15 downto 10
                                  S7_DIVCLK(0)& "0"& S7_DIVCLK(5)& S7_DIVCLK(2)& "0"& S7_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        138+15 => "1"&X"4"& X"2FFF"& S7_LOCK(1)& S7_LOCK(2)& "0"& S7_LOCK(0)& X"000", --bits 15 downto 0
						          
        138+16 => "1"&X"5"& X"BFF4"& "0"& S7_DIVCLK(12)& "00"&X"00"& S7_LOCK(38)& "0"& S7_LOCK(32)& S7_LOCK(39), --bits 15 downto 0								  
						          
        138+17 => "1"&X"6"& X"0A55"& S7_LOCK(15)& S7_LOCK(13)& S7_LOCK(27)& S7_LOCK(16)& "0"& S7_LOCK(10)&   --bits 15 downto 10
                                  "0"& S7_DIVCLK(9)& S7_DIVCLK(1)& "0"& S7_DIVCLK(6)& "0"& S7_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S7_DIVCLK(4)& "0",  --bits 2 downto 0

        138+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S7_LOCK(17)& "0"& S7_LOCK(8)& S7_LOCK(9)& S7_LOCK(23)& S7_LOCK(22), --bits 15 downto 0	  
						          
        138+19 => "1"&X"8"& X"1039"& S7_DIGITAL_FILT(6)& S7_DIGITAL_FILT(7)& S7_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S7_DIGITAL_FILT(2)& S7_DIGITAL_FILT(1)& S7_DIGITAL_FILT(3)& S7_DIGITAL_FILT(9)& --bits 11 downto 8
						          S7_DIGITAL_FILT(8)& S7_LOCK(26)& "000"& S7_LOCK(19)& S7_LOCK(18)& "0", --bits 7 downto 0								
						          
        138+20 => "1"&X"9"& X"0000"& S7_LOCK(24)& S7_LOCK(25)& S7_LOCK(21)& S7_LOCK(14)& S7_LOCK(11)& --bits 15 downto 11
						          S7_LOCK(12)& S7_LOCK(20)& S7_LOCK(6)& S7_LOCK(35)& S7_LOCK(36)& --bits 10 downto 6
						          S7_LOCK(37)& S7_LOCK(3)& S7_LOCK(33)& S7_LOCK(31)& S7_LOCK(34)& S7_LOCK(30), --bits 5 downto 0
						          
        138+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S7_LOCK(28)& S7_LOCK(29),  --bits 15 downto 0

        138+22 => "1"&X"D"& X"2FFF"& S7_LOCK(7)& S7_LOCK(4)& "0"& S7_LOCK(5)& X"000",	--bits 15 downto 0

        --***********************************************************************
        -- State 8 Initialization
        --***********************************************************************
        161+0 => "0"&X"5"& X"50FF"&  S8_CLKOUT0(19)& "0"& S8_CLKOUT0(18)& "0"&--bits 15 down to 12
                                  S8_CLKOUT0(16)& S8_CLKOUT0(17)& S8_CLKOUT0(15)& S8_CLKOUT0(14)& X"00",--bits 11 downto 0
						         
        161+1 => "0"&X"6"& X"010B"&  S8_CLKOUT1(4)& S8_CLKOUT1(5)& S8_CLKOUT1(3)& S8_CLKOUT1(12)& --bits 15 down to 12
                                  S8_CLKOUT1(1)& S8_CLKOUT1(2)& S8_CLKOUT1(19)& "0"& S8_CLKOUT1(17)& S8_CLKOUT1(16)& --bits 11 down to 6
						          S8_CLKOUT1(14)& S8_CLKOUT1(15)& "0"& S8_CLKOUT0(13)& "00", --bits 5 down to 0
						         
        161+2 => "0"&X"7"& X"E02C"&  "000"& S8_CLKOUT1(11)& S8_CLKOUT1(9)& S8_CLKOUT1(10)& --bits 15 down to 10
                                  S8_CLKOUT1(8)& S8_CLKOUT1(7)& S8_CLKOUT1(6)& S8_CLKOUT1(20)& "0"& S8_CLKOUT1(13)& --bits 9 down to 4 
						          "00"& S8_CLKOUT1(21)& S8_CLKOUT1(22), --bits 3 down to 0
						         
        161+3 => "0"&X"8"& X"4001"&  S8_CLKOUT2(22)& "0"& S8_CLKOUT2(5)& S8_CLKOUT2(21)& --bits 15 downto 12
                                  S8_CLKOUT2(12)& S8_CLKOUT2(4)& S8_CLKOUT2(3)& S8_CLKOUT2(2)& S8_CLKOUT2(0)& S8_CLKOUT2(19)& --bits 11 down to 6
						          S8_CLKOUT2(17)& S8_CLKOUT2(18)& S8_CLKOUT2(15)& S8_CLKOUT2(16)& S8_CLKOUT2(14)& "0", --bits 5 down to 0
						         
        161+4 => "0"&X"9"& X"0D03"&  S8_CLKOUT3(14)& S8_CLKOUT3(15)& S8_CLKOUT0(21)& S8_CLKOUT0(22)& "00"& S8_CLKOUT2(10)& "0"& --bits 15 downto 8
                                  S8_CLKOUT2(9)& S8_CLKOUT2(8)& S8_CLKOUT2(6)& S8_CLKOUT2(7)& S8_CLKOUT2(13)& S8_CLKOUT2(20)& "00", --bits 7 downto 0
						         
        161+5 => "0"&X"A"& X"B001"&  "0"& S8_CLKOUT3(13)& "00"& S8_CLKOUT3(21)& S8_CLKOUT3(22)& S8_CLKOUT3(5)& S8_CLKOUT3(4)& --bits 15 downto 8
                                  S8_CLKOUT3(12)& S8_CLKOUT3(2)& S8_CLKOUT3(0)& S8_CLKOUT3(1)& S8_CLKOUT3(18)& S8_CLKOUT3(19)& --bits 7 downto 2
						          S8_CLKOUT3(17)& "0", --bits 1 downto 0
						          
        161+6 => "0"&X"B"& X"0110"&  S8_CLKOUT0(5)& S8_CLKOUT4(19)& S8_CLKOUT4(14)& S8_CLKOUT4(17)& --bits 15 downto 12
                                  S8_CLKOUT4(15)& S8_CLKOUT4(16)& S8_CLKOUT0(4)& "0"& S8_CLKOUT3(11)& S8_CLKOUT3(10)& --bits 11 downto 6 
						          S8_CLKOUT3(9)& "0"& S8_CLKOUT3(7)& S8_CLKOUT3(8)& S8_CLKOUT3(20)& S8_CLKOUT3(6), --bits 5 downto 0
						         
        161+7 => "0"&X"C"& X"0B00"&  S8_CLKOUT4(7)& S8_CLKOUT4(8)& S8_CLKOUT4(20)& S8_CLKOUT4(6)& "0"& S8_CLKOUT4(13)& --bits 15 downto 10
                                  "00"& S8_CLKOUT4(22)& S8_CLKOUT4(21)& S8_CLKOUT4(4)& S8_CLKOUT4(5)& S8_CLKOUT4(3)& --bits 9 downto 3
						          S8_CLKOUT4(12)& S8_CLKOUT4(1)& S8_CLKOUT4(2), --bits 2 downto 0
						         
        161+8 => "0"&X"D"& X"0008"&  S8_CLKOUT5(2)& S8_CLKOUT5(3)& S8_CLKOUT5(0)& S8_CLKOUT5(1)& S8_CLKOUT5(18)& --bits 15 downto 11
						          S8_CLKOUT5(19)& S8_CLKOUT5(17)& S8_CLKOUT5(16)& S8_CLKOUT5(15)& S8_CLKOUT0(3)& --bits 10 downto 6
						          S8_CLKOUT0(0)& S8_CLKOUT0(2)& "0"& S8_CLKOUT4(11)& S8_CLKOUT4(9)& S8_CLKOUT4(10), --bits 5 downto 0
						         
        161+9 => "0"&X"E"& X"00D0"&  S8_CLKOUT5(10)& S8_CLKOUT5(11)& S8_CLKOUT5(8)& S8_CLKOUT5(9)& S8_CLKOUT5(6)& --bits 15 downto 11
						          S8_CLKOUT5(7)& S8_CLKOUT5(20)& S8_CLKOUT5(13)& "00"& S8_CLKOUT5(22)& "0"& --bits 10 downto 4
						          S8_CLKOUT5(5)& S8_CLKOUT5(21)& S8_CLKOUT5(12)& S8_CLKOUT5(4), --bits 3 downto 0
						         
        161+10 => "0"&X"F"& X"0003"& S8_CLKFBOUT(4)& S8_CLKFBOUT(5)& S8_CLKFBOUT(3)& S8_CLKFBOUT(12)& S8_CLKFBOUT(1)& --bits 15 downto 11
                                  S8_CLKFBOUT(2)& S8_CLKFBOUT(0)& S8_CLKFBOUT(19)& S8_CLKFBOUT(18)& S8_CLKFBOUT(17)& --bits 10 downto 6
						          S8_CLKFBOUT(15)& S8_CLKFBOUT(16)& S8_CLKOUT0(12)& S8_CLKOUT0(1)& "00", --bits 5 downto 0
						          
        161+11 => "1"&X"0"& X"800C"& "0"& S8_CLKOUT0(9)& S8_CLKOUT0(11)& S8_CLKOUT0(10)& S8_CLKFBOUT(10)& S8_CLKFBOUT(11)& --bits 15 downto 10
						          S8_CLKFBOUT(9)& S8_CLKFBOUT(8)& S8_CLKFBOUT(7)& S8_CLKFBOUT(6)& S8_CLKFBOUT(13)&  --bits 9 downto 5
						          S8_CLKFBOUT(20)& "00"& S8_CLKFBOUT(21)& S8_CLKFBOUT(22), --bits 4 downto 0
								
        161+12 => "1"&X"1"& X"FC00"& "00"&X"0"& S8_CLKOUT3(3)& S8_CLKOUT3(16)& S8_CLKOUT2(11)& S8_CLKOUT2(1)& S8_CLKOUT1(18)& --bits 15 downto 6
						          S8_CLKOUT1(0)& S8_CLKOUT0(6)& S8_CLKOUT0(20)& S8_CLKOUT0(8)& S8_CLKOUT0(7), --bits 5 downto 0
						          
        161+13 => "1"&X"2"& X"F0FF"& X"0"& S8_CLKOUT5(14)& S8_CLKFBOUT(14)& S8_CLKOUT4(0)& S8_CLKOUT4(18)&  X"00",  --bits 15 downto 0
						          
        161+14 => "1"&X"3"& X"5120"& S8_DIVCLK(11)& "0"& S8_DIVCLK(10)& "0"& S8_DIVCLK(7)& S8_DIVCLK(8)&  --bits 15 downto 10
                                  S8_DIVCLK(0)& "0"& S8_DIVCLK(5)& S8_DIVCLK(2)& "0"& S8_DIVCLK(13)& X"0",  --bits 9 downto 0
						          
        161+15 => "1"&X"4"& X"2FFF"& S8_LOCK(1)& S8_LOCK(2)& "0"& S8_LOCK(0)& X"000", --bits 15 downto 0
						          
        161+16 => "1"&X"5"& X"BFF4"& "0"& S8_DIVCLK(12)& "00"&X"00"& S8_LOCK(38)& "0"& S8_LOCK(32)& S8_LOCK(39), --bits 15 downto 0								  
						          
        161+17 => "1"&X"6"& X"0A55"& S8_LOCK(15)& S8_LOCK(13)& S8_LOCK(27)& S8_LOCK(16)& "0"& S8_LOCK(10)&   --bits 15 downto 10
                                  "0"& S8_DIVCLK(9)& S8_DIVCLK(1)& "0"& S8_DIVCLK(6)& "0"& S8_DIVCLK(3)&  --bits 9 downto 3
						          "0"& S8_DIVCLK(4)& "0",  --bits 2 downto 0

        161+18 => "1"&X"7"& X"FFD0"& "00"&X"00"& S8_LOCK(17)& "0"& S8_LOCK(8)& S8_LOCK(9)& S8_LOCK(23)& S8_LOCK(22), --bits 15 downto 0	  
						          
        161+19 => "1"&X"8"& X"1039"& S8_DIGITAL_FILT(6)& S8_DIGITAL_FILT(7)& S8_DIGITAL_FILT(0)& "0"& --bits 15 downto 12
						          S8_DIGITAL_FILT(2)& S8_DIGITAL_FILT(1)& S8_DIGITAL_FILT(3)& S8_DIGITAL_FILT(9)& --bits 11 downto 8
						          S8_DIGITAL_FILT(8)& S8_LOCK(26)& "000"& S8_LOCK(19)& S8_LOCK(18)& "0", --bits 7 downto 0								
						          
        161+20 => "1"&X"9"& X"0000"& S8_LOCK(24)& S8_LOCK(25)& S8_LOCK(21)& S8_LOCK(14)& S8_LOCK(11)& --bits 15 downto 11
						          S8_LOCK(12)& S8_LOCK(20)& S8_LOCK(6)& S8_LOCK(35)& S8_LOCK(36)& --bits 10 downto 6
						          S8_LOCK(37)& S8_LOCK(3)& S8_LOCK(33)& S8_LOCK(31)& S8_LOCK(34)& S8_LOCK(30), --bits 5 downto 0
						          
        161+21 => "1"&X"A"& X"FFFC"& "00"&X"000"& S8_LOCK(28)& S8_LOCK(29),  --bits 15 downto 0

        161+22 => "1"&X"D"& X"2FFF"& S8_LOCK(7)& S8_LOCK(4)& "0"& S8_LOCK(5)& X"000",	--bits 15 downto 0

        OTHERS => (OTHERS=>'0')
        );
    
    SIGNAL rom_addr : unsigned(7 DOWNTO 0);
    SIGNAL rom_do : std_logic_vector(36 DOWNTO 0);
    
    SIGNAL next_srdy : std_logic;
    
    SIGNAL next_rom_addr : unsigned(7 DOWNTO 0);
    SIGNAL next_daddr : std_logic_vector(4 DOWNTO 0);
    SIGNAL next_dwe, next_den, next_rst_pll : std_logic;
    SIGNAL next_di : std_logic_vector(15 DOWNTO 0);
    
    TYPE state_t IS (RESTART, WAIT_SEN, ADDRESS, WAIT_A_DRDY, BITMASK, BITSET, WRITE, WAIT_DRDY);
    SIGNAL current_state, next_state : state_t := RESTART;

    CONSTANT STATE_COUNT_CONST : integer := 23;
    SIGNAL state_count, next_state_count : unsigned(4 DOWNTO 0) := to_unsigned(STATE_COUNT_CONST,5);

BEGIN
    daddr_out <= daddr;
    di_out <= di;
    rst_pll_out <= rst_pll;

    dclk <= sclk AFTER 100 ps; --delay for proper simulation

    rom_p : PROCESS(sclk)
    BEGIN
        IF rising_edge(SCLK) THEN
            rom_do <= rom(to_integer(rom_addr));
        END IF;
    END PROCESS rom_p;

    outputs : PROCESS(sclk)
    BEGIN
        IF rising_edge(SCLK) THEN
            daddr <= next_daddr;
            dwe <= next_dwe;
            den <= next_den;
            rst_pll <= next_rst_pll;
            di <= next_di;
            
            srdy <= next_srdy;
            
            rom_addr <= next_rom_addr;
            state_count <= next_state_count;
        END IF;
    END PROCESS outputs;

    state : PROCESS(sclk)
    BEGIN
        IF rising_edge(sclk) THEN
            IF rst = '1' THEN
                current_state <= RESTART;
            ELSE
                current_state <= next_state;
            END IF;
        END IF;
    END PROCESS state;
    
    nextstate : PROCESS (daddr, rst_pll, di, rom_addr, state_count, current_state, locked, sen, saddr, rom_do, do, drdy)
    BEGIN
        next_srdy <= '0';
        next_daddr <= daddr;
        next_dwe <= '0';
        next_den <= '0';
        next_rst_pll <= rst_pll;
        next_di <= di;
        next_rom_addr <= rom_addr;
        next_state_count <= state_count;
        
        CASE current_state IS
            WHEN RESTART =>
                next_daddr <= (OTHERS=>'0');
                next_di <= (OTHERS=>'0');
                next_rom_addr <= (OTHERS=>'0');
                next_rst_pll <= '0';
                next_state <= WAIT_SEN;
            WHEN WAIT_SEN =>
                next_state_count <= to_unsigned(STATE_COUNT_CONST,next_state_count'LENGTH);
                IF sen = '1' THEN
                    IF saddr = "0001" THEN
                        next_rom_addr <= to_unsigned(1*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSIF saddr = "0010" THEN
                        next_rom_addr <= to_unsigned(2*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSIF saddr = "0011" THEN
                        next_rom_addr <= to_unsigned(3*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSIF saddr = "0100" THEN
                        next_rom_addr <= to_unsigned(4*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSIF saddr = "0101" THEN
                        next_rom_addr <= to_unsigned(5*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSIF saddr = "0110" THEN
                        next_rom_addr <= to_unsigned(6*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSIF saddr = "0111" THEN
                        next_rom_addr <= to_unsigned(7*STATE_COUNT_CONST,next_rom_addr'LENGTH);
                    ELSE
                        next_rom_addr <= (OTHERS=>'0');
                    END IF;
                    next_state <= ADDRESS;
                ELSE
                    next_srdy <= '1';
                    next_state <= WAIT_SEN;
                END IF;
            WHEN ADDRESS =>
                next_rst_pll <= '1';
                next_den <= '1';
                next_daddr <= rom_do(36 DOWNTO 32);
                next_state <= WAIT_A_DRDY;
            WHEN WAIT_A_DRDY =>
                IF drdy = '1' THEN
                    next_state <= BITMASK;
                ELSE
                    next_state <= WAIT_A_DRDY;
                END IF;
            WHEN BITMASK =>
                next_di <= rom_do(31 DOWNTO 16) AND do;
                next_state <= BITSET;
            WHEN BITSET =>
                next_di <= rom_do(15 DOWNTO 0) OR di;
                next_rom_addr <= rom_addr + 1;
                next_state <= WRITE;
            WHEN WRITE =>
                next_dwe <= '1';
                next_den <= '1';
                next_state_count <= state_count - 1;
                next_state <= WAIT_DRDY;
            WHEN WAIT_DRDY =>
                IF drdy = '1' THEN
                    IF state_count /= 0 THEN
                        next_state <= ADDRESS;
                    ELSE
                        next_state <= RESTART;
                    END IF;
                ELSE
                    next_state <= WAIT_DRDY;
                END IF;
            WHEN OTHERS =>
                next_state <= RESTART;
        END CASE;
    END PROCESS nextstate;
END ARCHITECTURE arch;
