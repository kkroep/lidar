LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hist_rotate IS
    PORT(
        SIGNAL clk                      : IN    std_logic;
        SIGNAL init                     : IN    std_logic;
        SIGNAL counts_in                : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL counts_in_valid          : IN    std_logic;
        SIGNAL counts_out               : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL counts_out_valid         : OUT   std_logic;
        SIGNAL rot_mem_wr               : IN    std_logic;
        SIGNAL rot_mem_wr_addr          : IN    std_logic_vector(7 DOWNTO 0);
        SIGNAL rot_mem_wr_data          : IN    std_logic_vector(11 DOWNTO 0); --11 skip flag 10 zero flag 9:0 rotate amount
        SIGNAL hist_length              : IN    std_logic_vector(8 DOWNTO 0);
        SIGNAL idle                     : OUT   std_logic
    );
END ENTITY hist_rotate;

ARCHITECTURE arch OF hist_rotate IS
    SIGNAL init_done_reg : std_logic_vector(3 DOWNTO 0) := (OTHERS=>'0');

    TYPE rot_mem_t IS ARRAY(0 TO 255) OF std_logic_vector(11 DOWNTO 0);
    FUNCTION rot_mem_init RETURN rot_mem_t IS
        VARIABLE init : rot_mem_t := (OTHERS=>"010000000000");
    BEGIN
        RETURN init;
    END rot_mem_init;
    SIGNAL rot_mem : rot_mem_t := rot_mem_init;

    TYPE buf_mem_t IS ARRAY(0 TO 511) OF std_logic_vector(31 DOWNTO 0);
    SIGNAL buf_mem : buf_mem_t := (OTHERS=>(OTHERS=>'0'));
    SIGNAL buf_wr_data_reg, buf_rd_data_reg : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL buf_wr_addr_reg, buf_rd_addr_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL buf_wr_reg, buf_rd_reg : std_logic := '0';

    SIGNAL hist_length_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL wr_count_reg, rd_count_reg, out_count_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL wr_count_top_reg, rd_count_top_reg, rd_count_jump_reg, out_count_zero_reg : std_logic := '0';
    SIGNAL prev_pixel_zero_reg, prev_pixel_half_reg, prev_pixel_half_out_reg, buf_skip_reg : std_logic := '0';
    SIGNAL cur_pixel_reg : unsigned(7 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cur_pixel_rotate_reg : unsigned(11 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cur_pixel_jump_amount_reg, cur_pixel_plus_1_reg, rd_jump_value_minus_1_reg : unsigned(8 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL buf_out_valid_reg, buf_out_last_half_valid_reg : std_logic := '0';
    SIGNAL buf_out_next_half_reg, buf_out_last_half_reg : std_logic_vector(15 DOWNTO 0);
BEGIN
    make_init : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF init = '1' THEN
                init_done_reg <= (OTHERS=>'0');
            ELSE
                init_done_reg <= '1'&init_done_reg(3 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS make_init;
    
    make_rot_mem : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rot_mem_wr = '1' THEN
                rot_mem(to_integer(unsigned(rot_mem_wr_addr))) <= rot_mem_wr_data;
            END IF;
            cur_pixel_rotate_reg <= unsigned(rot_mem(to_integer(cur_pixel_reg)));
        END IF;
    END PROCESS make_rot_mem;
    
    make_buf_mem : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF buf_wr_reg = '1' THEN
                buf_mem(to_integer(buf_wr_addr_reg)) <= buf_wr_data_reg;
            END IF;
            buf_rd_data_reg <= buf_mem(to_integer(buf_rd_addr_reg));
        END IF;
    END PROCESS make_buf_mem;
    
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF init_done_reg(0) = '1' AND wr_count_reg = 0 AND buf_rd_reg = '0' THEN
                idle <= '1';
            ELSE
                idle <= '0';
            END IF;
            
            --Configuration
            hist_length_reg <= unsigned(hist_length);
            
            --Output
            buf_out_valid_reg <= buf_rd_reg AND (NOT buf_skip_reg);
            IF buf_out_valid_reg = '1' THEN
                out_count_reg <= out_count_reg + 1;
                IF out_count_reg = hist_length_reg THEN
                    out_count_reg <= (OTHERS=>'0');
                    out_count_zero_reg <= '1';
                ELSE
                    out_count_zero_reg <= '0';
                END IF;
                
                IF out_count_zero_reg = '1' THEN
                    prev_pixel_half_out_reg <= prev_pixel_half_reg;
                    IF buf_out_last_half_valid_reg = '1' THEN
                        counts_out <= buf_out_last_half_reg&buf_out_next_half_reg;
                        counts_out_valid <= '1';
                    ELSE
                        counts_out_valid <= '0';
                    END IF;
                    IF prev_pixel_half_reg = '1' THEN
                        buf_out_last_half_reg <= buf_rd_data_reg(15 DOWNTO 0);
                        buf_out_next_half_reg <= buf_rd_data_reg(31 DOWNTO 16);
                    ELSE
                        buf_out_next_half_reg <= buf_rd_data_reg(15 DOWNTO 0);
                        buf_out_last_half_reg <= buf_rd_data_reg(31 DOWNTO 16);
                    END IF;
                    buf_out_last_half_valid_reg <= '1';
                ELSE
                    IF prev_pixel_half_out_reg = '1' THEN
                        buf_out_next_half_reg <= buf_rd_data_reg(31 DOWNTO 16);
                        counts_out <= buf_rd_data_reg(15 DOWNTO 0)&buf_out_next_half_reg;
                        counts_out_valid <= '1';
                    ELSE
                        buf_out_next_half_reg <= buf_rd_data_reg(15 DOWNTO 0);
                        buf_out_last_half_reg <= buf_rd_data_reg(31 DOWNTO 16);
                        counts_out <= buf_out_last_half_reg&buf_out_next_half_reg;
                        counts_out_valid <= '1';
                    END IF;
                END IF;
            ELSIF out_count_zero_reg = '1' AND buf_out_last_half_valid_reg = '1' THEN
                counts_out <= buf_out_last_half_reg&buf_out_next_half_reg;
                counts_out_valid <= '1';
                buf_out_last_half_valid_reg <= '0';
            ELSE
                counts_out_valid <= '0';
            END IF;
            
            cur_pixel_jump_amount_reg <= cur_pixel_rotate_reg(9 DOWNTO 1) - hist_length_reg;
            cur_pixel_plus_1_reg <= cur_pixel_rotate_reg(9 DOWNTO 1) + 1;
            
            --Read
            IF buf_rd_reg = '1' THEN
                rd_count_reg <= rd_count_reg + 1;
                IF rd_count_reg = hist_length_reg - 1 THEN
                    rd_count_top_reg <= '1';
                ELSE
                    rd_count_top_reg <= '0';
                END IF;
                IF rd_count_reg = rd_jump_value_minus_1_reg THEN
                    rd_count_jump_reg <= '1';
                ELSE
                    rd_count_jump_reg <= '0';
                END IF;
                IF rd_count_top_reg = '1' THEN
                    buf_rd_reg <= '0';
                    rd_count_reg <= (OTHERS=>'0');
                    IF prev_pixel_zero_reg = '0' THEN
                        buf_rd_addr_reg <= buf_rd_addr_reg + cur_pixel_plus_1_reg;
                    ELSE
                        buf_rd_addr_reg <= buf_rd_addr_reg + cur_pixel_jump_amount_reg;
                    END IF;
                ELSIF rd_count_jump_reg = '1' THEN
                    buf_rd_addr_reg <= buf_rd_addr_reg - hist_length_reg;
                ELSE
                    buf_rd_addr_reg <= buf_rd_addr_reg + 1;
                END IF;
            END IF;
            
            --Write
            buf_wr_reg <= counts_in_valid;
            buf_wr_data_reg <= counts_in;
            IF buf_wr_reg = '1' THEN
                wr_count_reg <= wr_count_reg + 1;
                IF wr_count_reg = hist_length_reg - 1 THEN
                    wr_count_top_reg <= '1';
                ELSE
                    wr_count_top_reg <= '0';
                END IF;
                IF wr_count_top_reg = '1' THEN
                    buf_rd_reg <= '1';
                    buf_skip_reg <= cur_pixel_rotate_reg(11);
                    wr_count_reg <= (OTHERS=>'0');
                    buf_wr_addr_reg <= buf_wr_addr_reg + cur_pixel_jump_amount_reg;
                    prev_pixel_zero_reg <= cur_pixel_rotate_reg(10);
                    prev_pixel_half_reg <= cur_pixel_rotate_reg(0);
                    rd_jump_value_minus_1_reg <= hist_length_reg - cur_pixel_rotate_reg(9 DOWNTO 1) - 1;
                    IF hist_length_reg = cur_pixel_rotate_reg(9 DOWNTO 1) THEN
                        rd_count_jump_reg <= '1';
                    END IF;
                    cur_pixel_reg <= cur_pixel_reg + 1;
                ELSE
                    buf_wr_addr_reg <= buf_wr_addr_reg + 1;
                END IF;
            END IF;
            
            --Init
            IF init_done_reg(0) = '0' THEN
                cur_pixel_reg <= (OTHERS=>'0');
                buf_wr_reg <= '0';
                buf_wr_addr_reg <= (OTHERS=>'0');
                wr_count_reg <= (OTHERS=>'0');
                wr_count_top_reg <= '0';
                buf_rd_reg <= '0';
                buf_rd_addr_reg <= cur_pixel_rotate_reg(9 DOWNTO 1);
                rd_count_reg <= (OTHERS=>'0');
                rd_count_top_reg <= '0';
                rd_count_jump_reg <= '0';
                out_count_reg <= (OTHERS=>'0');
                out_count_zero_reg <= '1';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE arch;

