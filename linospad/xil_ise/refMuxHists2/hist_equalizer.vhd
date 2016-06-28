LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hist_equalizer IS
    PORT(
        SIGNAL clk                      : IN    std_logic;
        SIGNAL init                     : IN    std_logic;
        SIGNAL counts_in                : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL counts_in_valid          : IN    std_logic;
        SIGNAL counts_out               : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL counts_out_valid         : OUT   std_logic;
        SIGNAL cmd_mem_wr               : IN    std_logic;
        SIGNAL cmd_mem_wr_addr          : IN    std_logic_vector(13 DOWNTO 0);
        SIGNAL cmd_mem_wr_data          : IN    std_logic_vector(71 DOWNTO 0);
        SIGNAL tdc_coarse_count_max     : IN    std_logic_vector(2 DOWNTO 0);
        SIGNAL idle                     : OUT   std_logic
    );
END ENTITY hist_equalizer;

ARCHITECTURE arch OF hist_equalizer IS
    SIGNAL buffer_init_reg : std_logic := '1';
    SIGNAL init_done_reg : std_logic := '0';
    SIGNAL stage_valid_reg : std_logic_vector(1 TO 4) := "0000";
    --Stage 1
    --================
    TYPE cmd_mem_t IS ARRAY (0 TO 4095) OF unsigned(71 DOWNTO 0);
    FUNCTION cmd_mem_init RETURN cmd_mem_t IS --Generate 140 code identity function
        VARIABLE init : cmd_mem_t := (OTHERS=>(OTHERS=>'0'));
    BEGIN
        FOR i IN 0 TO 63 LOOP
            init(i*27+0) := X"01000b00000b00000b";
            init(i*27+1) := X"010b00000b00000b00";
            init(i*27+2) := X"0200000b00000b0000";
            init(i*27+3) := X"02000b00000b00000b";
            init(i*27+4) := X"010b00000b00000b00";
            init(i*27+5) := X"0200000b00000b0000";
            init(i*27+6) := X"02000b00000b00000b";
            init(i*27+7) := X"010b00000b00000b00";
            init(i*27+8) := X"0200000b00000b0000";
            init(i*27+9) := X"02000b00000b00000b";
            init(i*27+10) := X"010b00000b00000b00";
            init(i*27+11) := X"0200000b00000b0000";
            init(i*27+12) := X"02000b00000b00000b";
            init(i*27+13) := X"010b00000b00000b00";
            init(i*27+14) := X"0200000b00000b0000";
            init(i*27+15) := X"02000b00000b00000b";
            init(i*27+16) := X"010b00000b00000b00";
            init(i*27+17) := X"0200000b00000b0000";
            init(i*27+18) := X"02000b00000b00000b";
            init(i*27+19) := X"010b00000b00000b00";
            init(i*27+20) := X"0200000b00000b0000";
            init(i*27+21) := X"02000b00000b00000b";
            init(i*27+22) := X"010b00000b00000b00";
            init(i*27+23) := X"2200000b00000b0000";
            init(i*27+24) := X"02000b00000b00000b";
            init(i*27+25) := X"010b00000b00000b00";
            init(i*27+26) := X"110000000000000000";
        END LOOP;
        init(63*27+23) := X"A200000b00000b0000";
        RETURN init;
    END cmd_mem_init;
    SIGNAL cmd_mem_0 : cmd_mem_t := cmd_mem_init;--microcode memory
    SIGNAL cmd_mem_1 : cmd_mem_t := (OTHERS=>(OTHERS=>'0'));
    SIGNAL cmd_mem_2 : cmd_mem_t := (OTHERS=>(OTHERS=>'0'));
    SIGNAL cmd_mem_wr_addr_reg : unsigned(11 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_wr_reg : std_logic_vector(2 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_wr_data_reg : unsigned(71 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_rd_addr_reg : unsigned(13 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_rd_data_reg_0 : unsigned(71 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_rd_data_reg_1 : unsigned(71 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_rd_data_reg_2 : unsigned(71 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_rd_data_sel_reg : unsigned(1 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL cmd_mem_rd_data, cmd_mem_rd_data_buffer_reg : unsigned(71 DOWNTO 0);

    --Microcode memory address sequencing
    SIGNAL cmd_tdc_coarse_count_reg, tdc_coarse_count_max_reg : unsigned(2 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL tdc_last_coarse_reg, tdc_coarse_count_max_zero_reg : std_logic := '0';
    SIGNAL cmd_tdc_base_addr_reg, cmd_next_tdc_addr_reg : unsigned(13 DOWNTO 0) := (OTHERS=>'0');

    --Buffer management
    SIGNAL buffer_action_countdown_reg : unsigned(3 DOWNTO 0);
    SIGNAL buffer_read_reg, buffer_action_reg, buffer_reload_reg, buffer_update_reg : std_logic;
    SIGNAL buffer_read, buffer_reload, buffer_update : std_logic;
    SIGNAL cmd_flags_next : unsigned(7 DOWNTO 0);
    SIGNAL cmd_flags_reg : unsigned(2 DOWNTO 0);
    SIGNAL cmd_buffer_next : unsigned(63 DOWNTO 0);
    SIGNAL cmd_buffer_reg : unsigned(103 DOWNTO 0); --head of code memory
    SIGNAL cmd_buffer_used_reg : unsigned(6 DOWNTO 0); --used bit count for head

    --Datapath
    SIGNAL count_p_reg_1, count_n_reg_1 : unsigned(15 DOWNTO 0); --next 2 counts (previous, next) to process
    SIGNAL cmd_ucode : unsigned(5 DOWNTO 0); --encoded p/n commands
    SIGNAL cmd_length : unsigned(5 DOWNTO 0); --total command length
    SIGNAL cmd_p_n : unsigned(5 DOWNTO 0); --decoded p/n commands
    SIGNAL cmd_p_args, cmd_n_args : unsigned(15 DOWNTO 0);
    SIGNAL cmd_code_p_reg_1, cmd_code_n_reg_1 : unsigned(2 DOWNTO 0);
    SIGNAL fact_first_p_reg, fact_last_p_reg : unsigned(7 DOWNTO 0); --multipliers
    SIGNAL fact_first_n_reg, fact_last_n_reg : unsigned(7 DOWNTO 0);

    --Stage 2
    --================
    SIGNAL frac_first_p, frac_first_p_reg, frac_last_p, frac_last_p_reg : unsigned(23 DOWNTO 0); --multiplication results
    SIGNAL frac_first_n, frac_first_n_reg, frac_last_n, frac_last_n_reg : unsigned(23 DOWNTO 0);
    SIGNAL count_p_reg_2, count_n_reg_2 : unsigned(15 DOWNTO 0);
    SIGNAL cmd_code_p_reg_2, cmd_code_n_reg_2 : unsigned(2 DOWNTO 0);

    --Stage 3
    --================
    SIGNAL frac_rem_p, frac_rem_n : unsigned(15 DOWNTO 0);
    SIGNAL bin_first_p_reg_3, bin_mid_p_reg_3, bin_last_p_reg_3 : unsigned(15 DOWNTO 0); --bin results
    SIGNAL bin_first_n_reg_3, bin_mid_n_reg_3, bin_last_n_reg_3 : unsigned(15 DOWNTO 0);
    SIGNAL bin_third_p_reg, bin_third_n_reg : unsigned(16 DOWNTO 0); --Input to 1/3 multiplier
    SIGNAL commit_count_p_reg_3, commit_count_n_reg_3 : unsigned(2 DOWNTO 0); --commit counts

    --Stage 4
    --================
    SIGNAL mid_third_p, mid_third_n : unsigned(32 DOWNTO 0); --1/3 values for 4 commit case
    SIGNAL mag_third_p, rem_third_p, mag_third_n, rem_third_n : unsigned(1 DOWNTO 0); --Remainder from 1/3 multiplication
    SIGNAL bin_first_p_reg_4, bin_mid_p_reg_4, bin_last_p_reg_4 : unsigned(15 DOWNTO 0); --bin results
    SIGNAL bin_first_n_reg_4, bin_mid_n_reg_4, bin_last_n_reg_4 : unsigned(15 DOWNTO 0);
    SIGNAL commit_counts_reg : unsigned(4 DOWNTO 0); --commit counts
    SIGNAL commit_counts_p_nonzero_reg, commit_counts_n_nonzero_reg : std_logic;
    SIGNAL commit_counts_greater2_reg : std_logic;

    --Stage 5
    --================
    SIGNAL front_count_reg : unsigned(15 DOWNTO 0); --front count
    SIGNAL front_count_overflow_reg : std_logic;
    SIGNAL commit_reg : unsigned(71 DOWNTO 0); --commit word
    SIGNAL commit_write_reg : std_logic;

    --Output fifo
    --================
    COMPONENT genfifo_fwft_reg IS
        GENERIC(
            CONSTANT FIFOWIDTH              : natural := 72;
            CONSTANT LOG2_FIFODEPTH         : natural := 8 );
        PORT(
            SIGNAL clk, reset               : IN    std_logic;
            SIGNAL full, empty              : OUT   std_logic;
            SIGNAL wr, rd                   : IN    std_logic;
            SIGNAL data_in                  : IN    std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
            SIGNAL data_out                 : OUT   std_logic_vector(FIFOWIDTH-1 DOWNTO 0);
            SIGNAL count                    : OUT   std_logic_vector(LOG2_FIFODEPTH DOWNTO 0) );
    END COMPONENT genfifo_fwft_reg;
    SIGNAL fifo_reset, fifo_full, fifo_empty, fifo_rd : std_logic;
    SIGNAL fifo_data_out_std : std_logic_vector(71 DOWNTO 0);
    SIGNAL fifo_data_out : unsigned(71 DOWNTO 0);

    --Output stage
    --================
    SIGNAL counts_out_half_reg : std_logic_vector(15 DOWNTO 0);
    SIGNAL counts_out_half_valid_reg, counts_out_first_n_done_reg, counts_out_last_reg : std_logic;
    SIGNAL num_counts_out_pn : unsigned(5 DOWNTO 0);
    SIGNAL num_counts_out_p, num_counts_out_p_reg, num_counts_out_n, num_counts_out_n_reg : unsigned(2 DOWNTO 0);
    SIGNAL num_counts_out, num_counts_out_reg : unsigned(3 DOWNTO 0);
BEGIN
    idle <= '1' WHEN init_done_reg = '1' AND stage_valid_reg = "0000" AND fifo_empty = '1' AND num_counts_out_reg = 0 ELSE '0';

    --Generate init cycles for first stage and global init_done for all
    make_init : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF init = '1' THEN
                init_done_reg <= '0';
            ELSE
                init_done_reg <= NOT buffer_init_reg;
            END IF;
        END IF;
    END PROCESS make_init;

    --Make microcode memories
    make_cmd_mem : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            cmd_mem_wr_addr_reg <= unsigned(cmd_mem_wr_addr(11 DOWNTO 0));
            cmd_mem_wr_data_reg <= unsigned(cmd_mem_wr_data);
            IF cmd_mem_wr = '1' THEN
                CASE cmd_mem_wr_addr(13 DOWNTO 12) IS
                WHEN "00" => cmd_mem_wr_reg <= "001";
                WHEN "01" => cmd_mem_wr_reg <= "010";
                WHEN "10" => cmd_mem_wr_reg <= "100";
                WHEN OTHERS => cmd_mem_wr_reg <= "---";
                END CASE;
            ELSE
                cmd_mem_wr_reg <= "000";
            END IF;
            IF cmd_mem_wr_reg(0) = '1' THEN
                cmd_mem_0(to_integer(cmd_mem_wr_addr_reg)) <= cmd_mem_wr_data_reg;
            END IF;
            IF cmd_mem_wr_reg(1) = '1' THEN
                cmd_mem_1(to_integer(cmd_mem_wr_addr_reg)) <= cmd_mem_wr_data_reg;
            END IF;
            IF cmd_mem_wr_reg(2) = '1' THEN
                cmd_mem_2(to_integer(cmd_mem_wr_addr_reg)) <= cmd_mem_wr_data_reg;
            END IF;
            
            IF buffer_init_reg = '1' OR buffer_read = '1' THEN
                cmd_mem_rd_data_reg_0 <= cmd_mem_0(to_integer(cmd_mem_rd_addr_reg(11 DOWNTO 0)));
                cmd_mem_rd_data_reg_1 <= cmd_mem_1(to_integer(cmd_mem_rd_addr_reg(11 DOWNTO 0)));
                cmd_mem_rd_data_reg_2 <= cmd_mem_2(to_integer(cmd_mem_rd_addr_reg(11 DOWNTO 0)));
                cmd_mem_rd_data_sel_reg <=cmd_mem_rd_addr_reg(13 DOWNTO 12);
            END IF;
        END IF;
    END PROCESS make_cmd_mem;
    WITH cmd_mem_rd_data_sel_reg SELECT cmd_mem_rd_data <=
        cmd_mem_rd_data_reg_0 WHEN "00",
        cmd_mem_rd_data_reg_1 WHEN "01",
        cmd_mem_rd_data_reg_2 WHEN "10",
        (OTHERS=>'-') WHEN OTHERS;

    --First stage: setup multiplier inputs and next command
    --================
    cmd_ucode <= cmd_buffer_reg(7 DOWNTO 2);
    cmd_length <= cmd_buffer_reg(2 DOWNTO 0)&"000";
    
    cmd_p_args <= cmd_buffer_reg(23 DOWNTO 8);
    
    cmd_n_args <= cmd_buffer_reg(23 DOWNTO 8) WHEN cmd_ucode(2 DOWNTO 1) = "00"
        ELSE cmd_buffer_reg(31 DOWNTO 16) WHEN cmd_ucode(2 DOWNTO 1) = "01"
        ELSE cmd_buffer_reg(39 DOWNTO 24);
    
    WITH cmd_ucode SELECT cmd_p_n <=
        "001001" WHEN "000100",
        "001011" WHEN "010010",
        "011001" WHEN "011010",
        "011011" WHEN "100010",
        "000001" WHEN "000110",
        "001000" WHEN "001000",
        "000011" WHEN "101010",
        "011000" WHEN "000000",
        "000000" WHEN "000010",
        "001010" WHEN "010000",
        "001100" WHEN "011000",
        "001110" WHEN "100000",
        "010001" WHEN "001010",
        "100001" WHEN "001100",
        "110001" WHEN "001110",
        "011010" WHEN "101000",
        "011100" WHEN "110000",
        "011110" WHEN "111000",
        "010011" WHEN "110010",
        "100011" WHEN "111010",
        "110011" WHEN "010100",
        "000010" WHEN "000011",
        "000100" WHEN "001011",
        "000110" WHEN "010011",
        "010000" WHEN "000101",
        "100000" WHEN "001101",
        "110000" WHEN "010101",
        "010010" WHEN "011101",
        "010100" WHEN "100101",
        "010110" WHEN "101101",
        "100010" WHEN "110101",
        "100100" WHEN "111101",
        "100110" WHEN "000111",
        "110010" WHEN "001111",
        "110100" WHEN "010111",
        "110110" WHEN "011111",
        "------" WHEN OTHERS;
    
    buffer_read <= '1' WHEN buffer_read_reg = '1' AND counts_in_valid = '1' ELSE '0';
    buffer_reload <= '1' WHEN buffer_reload_reg = '1' AND counts_in_valid = '1' ELSE '0';
    buffer_update <= '1' WHEN buffer_update_reg = '1' AND counts_in_valid = '1' ELSE '0';

    cmd_flags_next <= cmd_mem_rd_data_buffer_reg(71 DOWNTO 64);
    cmd_buffer_next <= cmd_mem_rd_data_buffer_reg(63 DOWNTO 0);
    
    stage1 : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            tdc_coarse_count_max_reg <= unsigned(tdc_coarse_count_max);
            IF tdc_coarse_count_max_reg = 0 THEN
                tdc_coarse_count_max_zero_reg <= '1';
            ELSE
                tdc_coarse_count_max_zero_reg <= '0';
            END IF;
            
            cmd_code_p_reg_1 <= cmd_p_n(5 DOWNTO 3);
            count_p_reg_1 <= unsigned(counts_in(15 DOWNTO 0));
            fact_last_p_reg <= cmd_p_args(7 DOWNTO 0);
            fact_first_p_reg <= cmd_p_args(15 DOWNTO 8);
            
            cmd_code_n_reg_1 <= cmd_p_n(2 DOWNTO 0);
            count_n_reg_1 <= unsigned(counts_in(31 DOWNTO 16));
            fact_last_n_reg <= cmd_n_args(7 DOWNTO 0);
            fact_first_n_reg <= cmd_n_args(15 DOWNTO 8);

            stage_valid_reg(1) <= counts_in_valid AND init_done_reg;

            IF buffer_init_reg = '1' OR buffer_reload = '1' THEN
                cmd_buffer_reg <= X"0000000000"&cmd_buffer_next(63 DOWNTO 0);
                cmd_buffer_used_reg <= to_unsigned(64, cmd_buffer_used_reg'LENGTH);
            ELSIF buffer_update = '1' THEN
                cmd_buffer_reg <= shift_right(cmd_buffer_reg, to_integer(cmd_length)) OR shift_left(X"0000000000"&cmd_buffer_next, to_integer(cmd_buffer_used_reg-cmd_length));
                cmd_buffer_used_reg <= cmd_buffer_used_reg - cmd_length + 64;
            ELSIF counts_in_valid = '1' THEN
                cmd_buffer_reg <= shift_right(cmd_buffer_reg, to_integer(cmd_length));
                cmd_buffer_used_reg <= cmd_buffer_used_reg - cmd_length;
                buffer_action_countdown_reg <= buffer_action_countdown_reg - 1;
                IF buffer_action_countdown_reg = 1 THEN
                    buffer_read_reg <= '1';
                    buffer_reload_reg <= buffer_action_reg;
                    buffer_update_reg <= NOT buffer_action_reg;
                END IF;
            END IF;

            IF buffer_init_reg = '1' OR buffer_read = '1' THEN
                cmd_mem_rd_data_buffer_reg <= cmd_mem_rd_data;

                buffer_action_countdown_reg <= cmd_flags_next(3 DOWNTO 0);
                buffer_action_reg <= cmd_flags_next(4);
                IF cmd_flags_next(3 DOWNTO 0) = 0 THEN
                    buffer_read_reg <= '1';
                    buffer_reload_reg <= cmd_flags_next(4);
                    buffer_update_reg <= NOT cmd_flags_next(4);
                ELSE
                    buffer_read_reg <= '0';
                    buffer_reload_reg <= '0';
                    buffer_update_reg <= '0';
                END IF;

                --Address sequencing
                cmd_flags_reg <= cmd_flags_next(7 DOWNTO 5);
                IF buffer_init_reg = '0' AND (cmd_flags_reg /= "000") THEN
                    IF cmd_flags_reg(0) = '1' THEN
                        cmd_tdc_coarse_count_reg <= cmd_tdc_coarse_count_reg + 1;
                        IF cmd_tdc_coarse_count_reg = tdc_coarse_count_max_reg-1 THEN
                            tdc_last_coarse_reg <= '1';
                        END IF;
                        
                        cmd_next_tdc_addr_reg <= cmd_mem_rd_addr_reg + 1;
                        cmd_mem_rd_addr_reg <= cmd_tdc_base_addr_reg;
                    END IF;
                    IF tdc_last_coarse_reg = '1' OR tdc_coarse_count_max_zero_reg = '1' THEN
                        cmd_tdc_coarse_count_reg <= (OTHERS=>'0');
                        tdc_last_coarse_reg <= '0';

                        IF cmd_flags_reg(2) = '1' THEN
                            cmd_tdc_base_addr_reg <= (OTHERS=>'0');
                            cmd_mem_rd_addr_reg <= (OTHERS=>'0');
                        ELSIF cmd_flags_reg(1) = '1' THEN
                            cmd_tdc_base_addr_reg <= cmd_next_tdc_addr_reg;
                            cmd_mem_rd_addr_reg <= cmd_next_tdc_addr_reg;
                        ELSE --IF cmd_flags_reg(0) = '1' THEN
                            cmd_tdc_base_addr_reg <= cmd_mem_rd_addr_reg + 1;
                            cmd_mem_rd_addr_reg <= cmd_mem_rd_addr_reg + 1;
                        END IF;
                    END IF;
                ELSE
                    cmd_mem_rd_addr_reg <= cmd_mem_rd_addr_reg + 1;
                END IF;
            END IF;

            IF cmd_mem_rd_addr_reg = 2 THEN
                buffer_init_reg <= '0';
            END IF;
            IF init = '1' THEN
                cmd_tdc_coarse_count_reg <= (OTHERS=>'0');
                tdc_last_coarse_reg <= '0';
                cmd_tdc_base_addr_reg <= (OTHERS=>'0');
                buffer_init_reg <= '1';
            END IF;
        END IF;
    END PROCESS stage1;
    
    --Second stage: Multiply/Drop
    --================
    frac_first_p <= fact_first_p_reg*count_p_reg_1;
    frac_last_p <= fact_last_p_reg*count_p_reg_1;
    
    frac_first_n <= fact_first_n_reg*count_n_reg_1;
    frac_last_n <= fact_last_n_reg*count_n_reg_1;
    
    stage2 : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            stage_valid_reg(2) <= stage_valid_reg(1) AND init_done_reg;

            cmd_code_p_reg_2 <= cmd_code_p_reg_1;
            cmd_code_n_reg_2 <= cmd_code_n_reg_1;

            IF cmd_code_p_reg_1(1 DOWNTO 0) = "11" THEN
                count_p_reg_2 <= (OTHERS=>'0');
            ELSE
                count_p_reg_2 <= count_p_reg_1;
            END IF;
            IF cmd_code_n_reg_1(1 DOWNTO 0) = "11" THEN
                count_n_reg_2 <= (OTHERS=>'0');
            ELSE
                count_n_reg_2 <= count_n_reg_1;
            END IF;

            frac_first_p_reg <= frac_first_p;
            frac_last_p_reg <= frac_last_p;

            frac_first_n_reg <= frac_first_n;
            frac_last_n_reg <= frac_last_n;
        END IF;
    END PROCESS stage2;
    
    --Third stage: calculate bin count distribution
    --================
    frac_rem_p <= count_p_reg_2 - frac_first_p_reg(23 DOWNTO 8) - frac_last_p_reg(23 DOWNTO 8);
    frac_rem_n <= count_n_reg_2 - frac_first_n_reg(23 DOWNTO 8) - frac_last_n_reg(23 DOWNTO 8);
    
    stage3 : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            stage_valid_reg(3) <= stage_valid_reg(2) AND init_done_reg;

            IF cmd_code_p_reg_2(0) = '1' THEN
                bin_first_p_reg_3 <= count_p_reg_2;
                bin_mid_p_reg_3 <= (OTHERS=>'-');
                bin_last_p_reg_3 <= (OTHERS=>'-');
                commit_count_p_reg_3 <= "000";
            ELSE
                CASE cmd_code_p_reg_2(2 DOWNTO 1) IS
                    WHEN "00" =>
                        bin_first_p_reg_3 <= count_p_reg_2 - frac_last_p_reg(23 DOWNTO 8);
                        bin_mid_p_reg_3 <= (OTHERS=>'-');
                        bin_last_p_reg_3 <= frac_last_p_reg(23 DOWNTO 8);
                        commit_count_p_reg_3 <= "001";
                    WHEN "01" =>
                        bin_first_p_reg_3 <= frac_first_p_reg(23 DOWNTO 8);
                        bin_mid_p_reg_3 <= frac_rem_p;
                        bin_last_p_reg_3 <= frac_last_p_reg(23 DOWNTO 8);
                        commit_count_p_reg_3 <= "011";
                    WHEN "10" =>
                        bin_first_p_reg_3 <= frac_first_p_reg(23 DOWNTO 8);
                        bin_mid_p_reg_3 <= "0"&frac_rem_p(15 DOWNTO 1);
                        bin_last_p_reg_3 <= frac_last_p_reg(23 DOWNTO 8) + ("0"&frac_rem_p(0));
                        commit_count_p_reg_3 <= "101";
                    WHEN OTHERS =>
                        bin_first_p_reg_3 <= frac_first_p_reg(23 DOWNTO 8);
                        bin_mid_p_reg_3 <= frac_rem_p;
                        bin_last_p_reg_3 <= frac_last_p_reg(23 DOWNTO 8);
                        commit_count_p_reg_3 <= "111";
                END CASE;
            END IF;
            bin_third_p_reg <= ("0"&frac_rem_p)+1;

            IF cmd_code_n_reg_2(0) = '1' THEN
                bin_first_n_reg_3 <= count_n_reg_2;
                bin_mid_n_reg_3 <= (OTHERS=>'-');
                bin_last_n_reg_3 <= (OTHERS=>'-');
                commit_count_n_reg_3 <= "000";
            ELSE
                CASE cmd_code_n_reg_2(2 DOWNTO 1) IS
                    WHEN "00" =>
                        bin_first_n_reg_3 <= count_n_reg_2 - frac_last_n_reg(23 DOWNTO 8);
                        bin_mid_n_reg_3 <= (OTHERS=>'-');
                        bin_last_n_reg_3 <= frac_last_n_reg(23 DOWNTO 8);
                        commit_count_n_reg_3 <= "001";
                    WHEN "01" =>
                        bin_first_n_reg_3 <= frac_first_n_reg(23 DOWNTO 8);
                        bin_mid_n_reg_3 <= frac_rem_n;
                        bin_last_n_reg_3 <= frac_last_n_reg(23 DOWNTO 8);
                        commit_count_n_reg_3 <= "011";
                    WHEN "10" =>
                        bin_first_n_reg_3 <= frac_first_n_reg(23 DOWNTO 8);
                        bin_mid_n_reg_3 <= "0"&frac_rem_n(15 DOWNTO 1);
                        bin_last_n_reg_3 <= frac_last_n_reg(23 DOWNTO 8) + ("0"&frac_rem_n(0));
                        commit_count_n_reg_3 <= "101";
                    WHEN OTHERS =>
                        bin_first_n_reg_3 <= frac_first_n_reg(23 DOWNTO 8);
                        bin_mid_n_reg_3 <= frac_rem_n;
                        bin_last_n_reg_3 <= frac_last_n_reg(23 DOWNTO 8);
                        commit_count_n_reg_3 <= "111";
                END CASE;
            END IF;
            bin_third_n_reg <= ("0"&frac_rem_n)+1;
        END IF;
    END PROCESS stage3;
    
    --Fourth stage: Calculate 1/3 commit
    --================
    mid_third_p <= bin_third_p_reg*X"5555";
    mag_third_p <= mid_third_p(15 DOWNTO 14)-1;
    rem_third_p <=
        "00" WHEN bin_mid_p_reg_3(15 DOWNTO 14) = "01" AND mag_third_p = "11"
        ELSE mag_third_p + 1 WHEN bin_mid_p_reg_3(15) = '1' AND mag_third_p /= "10"
        ELSE mag_third_p;

    mid_third_n <= bin_third_n_reg*X"5555";
    mag_third_n <= mid_third_n(15 DOWNTO 14)-1;
    rem_third_n <=
        "00" WHEN bin_mid_n_reg_3(15 DOWNTO 14) = "01" AND mag_third_n = "11"
        ELSE mag_third_n + 1 WHEN bin_mid_n_reg_3(15) = '1' AND mag_third_n /= "10"
        ELSE mag_third_n;
    
    stage4 : PROCESS(clk)
        VARIABLE v_commit_counts_pn : unsigned(5 DOWNTO 0);
    BEGIN
        IF rising_edge(clk) THEN
            stage_valid_reg(4) <= stage_valid_reg(3) AND init_done_reg;

            commit_counts_p_nonzero_reg <= commit_count_p_reg_3(0);
            commit_counts_n_nonzero_reg <= commit_count_n_reg_3(0);
            --Commit counts = commit_counts_n*5 + commit_counts_p
            v_commit_counts_pn := commit_count_n_reg_3&commit_count_p_reg_3;
            CASE v_commit_counts_pn IS
                WHEN "000000" => commit_counts_reg <= "00000"; commit_counts_greater2_reg <= '0';
                WHEN "000001" => commit_counts_reg <= "00001"; commit_counts_greater2_reg <= '0';
                WHEN "000011" => commit_counts_reg <= "00010"; commit_counts_greater2_reg <= '0';
                WHEN "000101" => commit_counts_reg <= "00011"; commit_counts_greater2_reg <= '1';
                WHEN "000111" => commit_counts_reg <= "00100"; commit_counts_greater2_reg <= '1';
                WHEN "001000" => commit_counts_reg <= "00101"; commit_counts_greater2_reg <= '0';
                WHEN "001001" => commit_counts_reg <= "00110"; commit_counts_greater2_reg <= '0';
                WHEN "001011" => commit_counts_reg <= "00111"; commit_counts_greater2_reg <= '1';
                WHEN "001101" => commit_counts_reg <= "01000"; commit_counts_greater2_reg <= '1';
                WHEN "001111" => commit_counts_reg <= "01001"; commit_counts_greater2_reg <= '1';
                WHEN "011000" => commit_counts_reg <= "01010"; commit_counts_greater2_reg <= '0';
                WHEN "011001" => commit_counts_reg <= "01011"; commit_counts_greater2_reg <= '1';
                WHEN "011011" => commit_counts_reg <= "01100"; commit_counts_greater2_reg <= '1';
                WHEN "011101" => commit_counts_reg <= "01101"; commit_counts_greater2_reg <= '1';
                WHEN "011111" => commit_counts_reg <= "01110"; commit_counts_greater2_reg <= '1';
                WHEN "101000" => commit_counts_reg <= "01111"; commit_counts_greater2_reg <= '1';
                WHEN "101001" => commit_counts_reg <= "10000"; commit_counts_greater2_reg <= '1';
                WHEN "101011" => commit_counts_reg <= "10001"; commit_counts_greater2_reg <= '1';
                WHEN "101101" => commit_counts_reg <= "10010"; commit_counts_greater2_reg <= '1';
                WHEN "101111" => commit_counts_reg <= "10011"; commit_counts_greater2_reg <= '1';
                WHEN "111000" => commit_counts_reg <= "10100"; commit_counts_greater2_reg <= '1';
                WHEN "111001" => commit_counts_reg <= "10101"; commit_counts_greater2_reg <= '1';
                WHEN "111011" => commit_counts_reg <= "10110"; commit_counts_greater2_reg <= '1';
                WHEN "111101" => commit_counts_reg <= "10111"; commit_counts_greater2_reg <= '1';
                WHEN "111111" => commit_counts_reg <= "11000"; commit_counts_greater2_reg <= '1';
                WHEN OTHERS =>  commit_counts_reg <= "-----"; commit_counts_greater2_reg <= '-';
            END CASE;

            bin_first_p_reg_4 <= bin_first_p_reg_3;
            IF commit_count_p_reg_3 = "111" THEN
                bin_mid_p_reg_4 <= mid_third_p(31 DOWNTO 16) + rem_third_p;
                bin_last_p_reg_4 <= bin_last_p_reg_3;
            ELSE
                bin_mid_p_reg_4 <= bin_mid_p_reg_3;
                bin_last_p_reg_4 <= bin_last_p_reg_3;
            END IF;

            bin_first_n_reg_4 <= bin_first_n_reg_3;
            IF commit_count_n_reg_3 = "111" THEN
                bin_mid_n_reg_4 <= mid_third_n(31 DOWNTO 16) + rem_third_n;
                bin_last_n_reg_4 <= bin_last_n_reg_3;
            ELSE
                bin_mid_n_reg_4 <= bin_mid_n_reg_3;
                bin_last_n_reg_4 <= bin_last_n_reg_3;
            END IF;
        END IF;
    END PROCESS stage4;

    --Fifth stage: Distribute counts and commit
    --================
    stage5 : PROCESS(clk)
        VARIABLE v_front_count : unsigned(17 DOWNTO 0);
        VARIABLE v_front_count_overflow : std_logic;
    BEGIN
        IF rising_edge(clk) THEN
            commit_reg(71 DOWNTO 64) <= "00"&commit_counts_greater2_reg&commit_counts_reg;
            commit_write_reg <= stage_valid_reg(4) AND (commit_counts_p_nonzero_reg OR commit_counts_n_nonzero_reg);
            v_front_count := "00"&front_count_reg;
            v_front_count_overflow := front_count_overflow_reg;

            v_front_count := v_front_count + bin_first_p_reg_4;
            v_front_count_overflow := v_front_count_overflow OR v_front_count(16) OR v_front_count(17);
            commit_reg(15 DOWNTO 0) <= v_front_count(15 DOWNTO 0);
            commit_reg(70) <= v_front_count_overflow;
            commit_reg(31 DOWNTO 16) <= bin_mid_p_reg_4;
            IF commit_counts_p_nonzero_reg = '1' THEN
                v_front_count := "00"&bin_last_p_reg_4;
                v_front_count_overflow := '0';
            END IF;

            v_front_count := v_front_count + bin_first_n_reg_4;
            v_front_count_overflow := v_front_count_overflow OR v_front_count(16) OR v_front_count(17);
            commit_reg(47 DOWNTO 32) <= v_front_count(15 DOWNTO 0);
            commit_reg(71) <= v_front_count_overflow;
            commit_reg(63 DOWNTO 48) <= bin_mid_n_reg_4;
            IF commit_counts_n_nonzero_reg = '1' THEN
                v_front_count := "00"&bin_last_n_reg_4;
                v_front_count_overflow := '0';
            END IF;

            IF init_done_reg = '0' THEN
                front_count_reg <= (OTHERS=>'0');
                front_count_overflow_reg <= '0';
            ELSIF stage_valid_reg(4) = '1' THEN
                front_count_reg <= v_front_count(15 DOWNTO 0);
                front_count_overflow_reg <= v_front_count_overflow;
            END IF;
        END IF;
    END PROCESS stage5;
    
    --Output buffer fifo
    --================
    output_fifo : genfifo_fwft_reg
        GENERIC MAP(
            FIFOWIDTH => 72,
            LOG2_FIFODEPTH => 8 )
        PORT MAP(
            clk => clk,
            reset => fifo_reset,
            full => fifo_full,
            empty => fifo_empty,
            wr => commit_write_reg,
            rd => fifo_rd,
            data_in => std_logic_vector(commit_reg),
            data_out => fifo_data_out_std,
            count => OPEN );
    fifo_reset <= NOT init_done_reg;
    
    --Output stage
    --================
    --Valid fifo words contain at least either a p or a n value
    --there may be 1-4 p and 1-4 n values with the first ones being different
    --two values are output per cycle
    fifo_data_out <= unsigned(fifo_data_out_std);
    WITH fifo_data_out(68 DOWNTO 64) SELECT num_counts_out_pn <=
        "000000" WHEN "00000",
        "000001" WHEN "00001",
        "000010" WHEN "00010",
        "000011" WHEN "00011",
        "000100" WHEN "00100",
        "001000" WHEN "00101",
        "001001" WHEN "00110",
        "001010" WHEN "00111",
        "001011" WHEN "01000",
        "001100" WHEN "01001",
        "010000" WHEN "01010",
        "010001" WHEN "01011",
        "010010" WHEN "01100",
        "010011" WHEN "01101",
        "010100" WHEN "01110",
        "011000" WHEN "01111",
        "011001" WHEN "10000",
        "011010" WHEN "10001",
        "011011" WHEN "10010",
        "011100" WHEN "10011",
        "100000" WHEN "10100",
        "100001" WHEN "10101",
        "100010" WHEN "10110",
        "100011" WHEN "10111",
        "100100" WHEN "11000",
        "------" WHEN OTHERS;
    num_counts_out_p <= num_counts_out_pn(2 DOWNTO 0);
    num_counts_out_n <= num_counts_out_pn(5 DOWNTO 3);
    num_counts_out <=  ("0"&num_counts_out_p) + ("0"&num_counts_out_n);
    fifo_rd <= '1' WHEN fifo_empty = '0' AND (fifo_data_out(69) = '0' OR counts_out_last_reg = '1') ELSE '0';

    output_stage : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            counts_out_valid <= '0';
            IF init_done_reg = '0' THEN
                counts_out_half_valid_reg <= '0';
                num_counts_out_reg <= (OTHERS=>'0');
            ELSIF fifo_empty = '0' AND num_counts_out_reg = 0 THEN
                --Output first 1-2 words
                --First p value always handled here
                IF counts_out_half_valid_reg = '1' THEN
                    --Output left-over value
                    counts_out(15 DOWNTO 0) <= counts_out_half_reg;
                    IF num_counts_out_p > 0 THEN
                        --first p value
                        IF fifo_data_out_std(70) = '0' THEN
                            counts_out(31 DOWNTO 16) <= fifo_data_out_std(15 DOWNTO 0);
                        ELSE
                            counts_out(31 DOWNTO 16) <= (OTHERS=>'1'); --saturate
                        END IF;
                        IF num_counts_out_p > 1 THEN
                            --two p values
                            counts_out_half_reg <= fifo_data_out_std(31 DOWNTO 16);
                        ELSE
                            --one p and first n value
                            IF fifo_data_out_std(71) = '0' THEN
                                counts_out_half_reg <= fifo_data_out_std(47 DOWNTO 32);
                            ELSE
                                counts_out_half_reg <= (OTHERS=>'1'); --saturate
                            END IF;
                        END IF;
                    ELSE
                        --only n values
                        counts_out(31 DOWNTO 16) <= fifo_data_out_std(47 DOWNTO 32);
                        counts_out_half_reg <= fifo_data_out_std(63 DOWNTO 48);
                    END IF;
                ELSE
                    IF num_counts_out_p > 0 THEN
                        --first p value
                        IF fifo_data_out_std(70) = '0' THEN
                            counts_out_half_reg <= fifo_data_out_std(15 DOWNTO 0);
                            counts_out(15 DOWNTO 0) <= fifo_data_out_std(15 DOWNTO 0);
                        ELSE
                            counts_out_half_reg <= (OTHERS=>'1'); --saturate
                            counts_out(15 DOWNTO 0) <= (OTHERS=>'1'); --saturate
                        END IF;
                        IF num_counts_out_p > 1 THEN
                            --two p values
                            counts_out(31 DOWNTO 16) <= fifo_data_out_std(31 DOWNTO 16);
                        ELSE
                            --one p and first n value
                            IF fifo_data_out_std(71) = '0' THEN
                                counts_out(31 DOWNTO 16) <= fifo_data_out_std(47 DOWNTO 32);
                            ELSE
                                counts_out(31 DOWNTO 16) <= (OTHERS=>'1'); --saturate
                            END IF;
                        END IF;
                    ELSE
                        --only n values
                        IF fifo_data_out_std(71) = '0' THEN
                            counts_out_half_reg <= fifo_data_out_std(47 DOWNTO 32);
                            counts_out(15 DOWNTO 0) <= fifo_data_out_std(47 DOWNTO 32);
                        ELSE
                            counts_out_half_reg <= (OTHERS=>'1'); --saturate
                            counts_out(15 DOWNTO 0) <= (OTHERS=>'1'); --saturate
                        END IF;
                        counts_out(31 DOWNTO 16) <= fifo_data_out_std(63 DOWNTO 48);
                    END IF;
                END IF;

                --Output valid flag
                IF num_counts_out > 1 THEN
                    --more than 1 always generate an output
                    counts_out_valid <= '1';
                ELSE
                    --1 only when there is a left-over value
                    counts_out_valid <= counts_out_half_valid_reg;
                    counts_out_half_valid_reg <= NOT counts_out_half_valid_reg;
                END IF;

                --Generate counts and flags for further output
                IF num_counts_out_p > 1 THEN
                    --two p values handled
                    num_counts_out_p_reg <= num_counts_out_p - 2;
                    counts_out_first_n_done_reg <= '0';
                    num_counts_out_n_reg <= num_counts_out_n;
                ELSE
                    --all p and at least 1 n values handled
                    num_counts_out_p_reg <= (OTHERS=>'0');
                    counts_out_first_n_done_reg <= '1';
                    IF num_counts_out_p = 0 THEN
                        --2 n values handled
                        num_counts_out_n_reg <= num_counts_out_n - 2;
                    ELSE
                        --1 n value handled
                        num_counts_out_n_reg <= num_counts_out_n - 1;
                    END IF;
                END IF;

                --Total further output count (triggers additional cycles)
                IF num_counts_out >= 2 THEN
                    num_counts_out_reg <= num_counts_out - 2;
                END IF;
                IF num_counts_out > 2 AND num_counts_out <= 4 THEN
                    counts_out_last_reg <= '1';
                ELSE
                    counts_out_last_reg <= '0';
                END IF;
            ELSIF num_counts_out_reg > 0 THEN
                --Output next two words
                --First p value never occurs here
                IF counts_out_half_valid_reg = '1' THEN
                    --Output left-over value
                    counts_out(15 DOWNTO 0) <= counts_out_half_reg;
                    IF num_counts_out_p_reg > 0 THEN
                        --another p value
                        counts_out(31 DOWNTO 16) <= fifo_data_out_std(31 DOWNTO 16);
                        IF num_counts_out_p_reg > 1 THEN
                            --two p values
                            counts_out_half_reg <= fifo_data_out_std(31 DOWNTO 16);
                        ELSE
                            --one p and first n value
                            IF fifo_data_out_std(71) = '0' THEN
                                counts_out_half_reg <= fifo_data_out_std(47 DOWNTO 32);
                            ELSE
                                counts_out_half_reg <= (OTHERS=>'1'); --saturate
                            END IF;
                        END IF;
                    ELSE
                        IF counts_out_first_n_done_reg = '0' THEN
                            --first n value
                            IF fifo_data_out_std(71) = '0' THEN
                                counts_out(31 DOWNTO 16) <= fifo_data_out_std(47 DOWNTO 32);
                            ELSE
                                counts_out(31 DOWNTO 16) <= (OTHERS=>'1'); --saturate
                            END IF;
                        ELSE
                            --another n value
                            counts_out(31 DOWNTO 16) <= fifo_data_out_std(63 DOWNTO 48);
                        END IF;
                        --another n value
                        counts_out_half_reg <= fifo_data_out_std(63 DOWNTO 48);
                    END IF;
                ELSE
                    IF num_counts_out_p_reg > 0 THEN
                        --another p value
                        counts_out_half_reg <= fifo_data_out_std(31 DOWNTO 16);
                        counts_out(15 DOWNTO 0) <= fifo_data_out_std(31 DOWNTO 16);
                        IF num_counts_out_p_reg > 1 THEN
                            --two p values
                            counts_out(31 DOWNTO 16) <= fifo_data_out_std(31 DOWNTO 16);
                        ELSE
                            --last p and first n value
                            IF fifo_data_out_std(71) = '0' THEN
                                counts_out(31 DOWNTO 16) <= fifo_data_out_std(47 DOWNTO 32);
                            ELSE
                                counts_out(31 DOWNTO 16) <= (OTHERS=>'1'); --saturate
                            END IF;
                        END IF;
                    ELSE
                        IF counts_out_first_n_done_reg = '0' THEN
                            --first n value
                            IF fifo_data_out_std(71) = '0' THEN
                                counts_out_half_reg <= fifo_data_out_std(47 DOWNTO 32);
                                counts_out(15 DOWNTO 0) <= fifo_data_out_std(47 DOWNTO 32);
                            ELSE
                                counts_out_half_reg <= (OTHERS=>'1'); --saturate
                                counts_out(15 DOWNTO 0) <= (OTHERS=>'1'); --saturate
                            END IF;
                        ELSE
                            --another n value
                            counts_out_half_reg <= fifo_data_out_std(63 DOWNTO 48);
                            counts_out(15 DOWNTO 0) <= fifo_data_out_std(63 DOWNTO 48);
                        END IF;
                        --another n value
                        counts_out(31 DOWNTO 16) <= fifo_data_out_std(63 DOWNTO 48);
                    END IF;
                END IF;

                --Output valid flag
                IF num_counts_out_reg > 1 THEN
                    --more than 1 always generate an output
                    counts_out_valid <= '1';
                ELSE
                    --1 only when there is a left-over value
                    counts_out_valid <= counts_out_half_valid_reg;
                    counts_out_half_valid_reg <= NOT counts_out_half_valid_reg;
                END IF;

                --Generate counts and flags for further output
                IF num_counts_out_p_reg > 1 THEN
                    --two p values handled
                    num_counts_out_p_reg <= num_counts_out_p_reg - 2;
                ELSE
                    --all p and at least 1 n value handled
                    num_counts_out_p_reg <= (OTHERS=>'0');
                    counts_out_first_n_done_reg <= '1';
                    IF num_counts_out_p_reg = 0 THEN
                        num_counts_out_n_reg <= num_counts_out_n_reg - 2;
                    ELSE
                        num_counts_out_n_reg <= num_counts_out_n_reg - 1;
                    END IF;
                END IF;

                --Total further output count
                IF counts_out_last_reg = '0' THEN
                    num_counts_out_reg <= num_counts_out_reg - 2;
                    IF num_counts_out_reg <= 4 THEN
                        counts_out_last_reg <= '1';
                    END IF;
                ELSE
                    num_counts_out_reg <= (OTHERS=>'0');
                    counts_out_last_reg <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS output_stage;
END ARCHITECTURE arch;

