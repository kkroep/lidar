LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY clock_control IS
    GENERIC(
        CONSTANT ADR                : std_logic_vector(3 DOWNTO 0) := X"0"
    );
    PORT(
        SIGNAL clk, reset           : IN    std_logic;

        SIGNAL usb_adr_in           : IN    std_logic_vector(3 DOWNTO 0);
        SIGNAL usb_data_in          : IN    std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_in_valid    : IN    std_logic;
        SIGNAL usb_data_in_ack      : OUT   std_logic;
        SIGNAL usb_data_out         : OUT   std_logic_vector(31 DOWNTO 0);
        SIGNAL usb_data_out_valid   : OUT   std_logic;
        SIGNAL usb_data_out_busy    : IN    std_logic;

        SIGNAL pin_clk_out          : OUT   std_logic; --(Divided) clock output
        SIGNAL pin_clk_ext          : IN    std_logic; --Reference clock input
        SIGNAL pin_trigger          : IN    std_logic; --Synchronous sampled trigger
        SIGNAL trigger_mod          : OUT   std_logic; --Pulse trigger for low frequencies
        SIGNAL trigger_main         : OUT   std_logic;

        SIGNAL clk_ref              : OUT   std_logic; --Selected reference (int/ext) after PLL (used for referencing)
        SIGNAL clk_mod              : OUT   std_logic; --Slow clock for processing (100MHz, tdc module)
        SIGNAL clk_tdc              : OUT   std_logic; --Fast clock for TDCs (400MHz, delay line and encoder)

        SIGNAL idle_out             : OUT   std_logic
    );
END ENTITY clock_control;

ARCHITECTURE arch OF clock_control IS
    COMPONENT clock_freq_estimator IS
        GENERIC(
            CONSTANT REF_TICKS_PER_MSEC  : integer := 100_000
        );
        PORT(
            SIGNAL clk, reset           : IN    std_logic;

            SIGNAL ext_clk              : IN    std_logic;
            SIGNAL measured_ticks       : OUT   std_logic_vector(31 DOWNTO 0)
        );
    END COMPONENT clock_freq_estimator;

    CONSTANT DCM_RST_TIME   : integer := 20; --DCM: 3 clkin cycles
    CONSTANT DCM_LCK_TIME   : integer := 10_000_000; --DCM: 5ms for f>50MHz, 50ms max
    CONSTANT PLL_RST_TIME   : integer := 10; --PLL: 5ns
    CONSTANT PLL_LCK_TIME   : integer := 20_000; --PLL: 100us

    TYPE state_t IS (RESET_DCM, PROG_DCM, WAIT_DCM, RESET_PLL, PROG_PLL, WAIT_DRP, WAIT_PLL, IDLE, SEND_DATA );
    SIGNAL s_state_reg : state_t := RESET_DCM;
    SIGNAL s_clk_ctrl_counter_reg : unsigned(31 DOWNTO 0) := to_unsigned( DCM_RST_TIME, 32 );
    SIGNAL s_freq_measure : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_dcm_programmed : std_logic;
    SIGNAL s_dcm_configuration : std_logic_vector(15 DOWNTO 0);
    SIGNAL s_pll_configuration : std_logic_vector(3 DOWNTO 0);

    CONSTANT SELECT_INTERNAL : std_logic := '0';
    CONSTANT SELECT_EXTERNAL : std_logic := '1';
    SIGNAL s_clk_ctrl_select_reg : std_logic := SELECT_INTERNAL;
    SIGNAL s_clk_int, s_clk_ext, s_clk_sel, clk_ref_int, clk_ref_int_inv, clk_mod_int : std_logic;

    SIGNAL div_counter, div_count : unsigned(15 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL div_enable, div_toggle : std_logic := '0';
    SIGNAL div_ddr_d : std_logic_vector(1 DOWNTO 0);

    SIGNAL ext_trigger_sample_reg_mod, ext_trigger_sample_reg_main : std_logic_vector(2 DOWNTO 0);
    SIGNAL int_trigger_sample_reg_mod, int_trigger_sample_reg_main : std_logic_vector(2 DOWNTO 0);
    SIGNAL ext_trigger_pulse_reg_mod, ext_trigger_pulse_reg_main : std_logic;
    SIGNAL int_trigger_pulse_reg_mod, int_trigger_pulse_reg_main, trigger_main_int : std_logic;
    SIGNAL mod_trigger_sel_reg, main_trigger_sel_reg : std_logic := '0';
    
    SIGNAL s_trig_measure, s_trig_counter : unsigned(16 DOWNTO 0);
    SIGNAL s_trig_measure_ms_tick : unsigned(17 DOWNTO 0);

    SIGNAL s_dcm_reset, s_pll_reset : std_logic := '1';

    SIGNAL s_dcm_prog_counter_reg : unsigned(4 DOWNTO 0);
    SIGNAL s_dcm_progdata_reg : std_logic_vector(31 DOWNTO 0);
    SIGNAL s_dcm_progen_reg : std_logic_vector(31 DOWNTO 0);

    SIGNAL dcm_reset, dcm_locked, dcm_progdata, dcm_progen, dcm_progdone : std_logic;
    SIGNAL dcm_status : std_logic_vector(2 DOWNTO 1);

    SIGNAL pll_reset, pll_locked, pll_clkfb, pll_clkout0, pll_clkout1, pll_clkout2 : std_logic;
    SIGNAL pll_drdy, pll_dclk, pll_den, pll_dwe : std_logic;
    SIGNAL pll_daddr : std_logic_vector(4 DOWNTO 0);
    SIGNAL pll_do, pll_di : std_logic_vector(15 DOWNTO 0);

    SIGNAL s_dcm_locked_reg, s_pll_locked_reg, s_fallback_disabled_reg : std_logic;

    SIGNAL drp_saddr : std_logic_vector(3 DOWNTO 0) := "0000";
    SIGNAL drp_sen, drp_srdy, drp_pll_reset : std_logic := '0';
BEGIN
    int_clock_dcm : DCM_CLKGEN
        GENERIC MAP(
            CLKFX_DIVIDE => 4,
            CLKFX_MULTIPLY => 2,
            CLKFX_MD_MAX => 1.334 --Overconstrain here for higher frequencies (1.360 for 68MHz)
        )
        PORT MAP(
            CLKIN => clk,
            FREEZEDCM => '0',
            PROGCLK => clk,
            PROGDATA => dcm_progdata,
            PROGEN => dcm_progen,
            RST => dcm_reset,
            STATUS => dcm_status,
            CLKFX => s_clk_int,
            CLKFX180 => OPEN,
            CLKFXDV => OPEN,
            LOCKED => dcm_locked,
            PROGDONE => dcm_progdone
        );
    dcm_reset <= s_dcm_reset;
    
    ext_clk_buf : IBUFG
        PORT MAP(
            I => pin_clk_ext,
            O => s_clk_ext
        );
    
    --Measure external
    clock_freq_estimator_inst : clock_freq_estimator
        GENERIC MAP(
            REF_TICKS_PER_MSEC => 100_000
        )
        PORT MAP(
            clk => clk,
            reset => reset,
            ext_clk => s_clk_ext,
            measured_ticks => s_freq_measure
        );
    
    clk_mux : BUFGMUX
        GENERIC MAP(
            CLK_SEL_TYPE => "ASYNC"
        )
        PORT MAP(
            O => s_clk_sel,
            I0 => s_clk_int,
            I1 => s_clk_ext,
            S => s_clk_ctrl_select_reg
        );
    
    clk_div : PROCESS(clk_ref_int)
    BEGIN
        IF rising_edge(clk_ref_int) THEN
            div_counter <= div_counter - 1;
            IF div_counter = 0 THEN
                div_counter <= div_count;
                div_toggle <= NOT div_toggle;
            END IF;
            IF div_enable = '1' THEN
                div_ddr_d <= div_toggle&div_toggle;
            ELSE
                div_ddr_d <= "01";
            END IF;
        END IF;
    END PROCESS clk_div;
    
    clk_ref_int_inv <= NOT clk_ref_int;
    CLKOUT_BUF : ODDR2 PORT MAP(
        Q => pin_clk_out,
        C0 => clk_ref_int,
        C1 => clk_ref_int_inv,
        CE => '1',
        D0 => div_ddr_d(0),
        D1 => div_ddr_d(1),
        R => '0',
        S => '0'
    );
    
    make_trigger_mod : PROCESS(clk_mod_int)
    BEGIN
        IF rising_edge(clk_mod_int) THEN
            ext_trigger_sample_reg_mod <= ext_trigger_sample_reg_mod(1 DOWNTO 0)&pin_trigger;
            ext_trigger_pulse_reg_mod <= (NOT ext_trigger_sample_reg_mod(2)) AND ext_trigger_sample_reg_mod(1);
            int_trigger_sample_reg_mod <= int_trigger_sample_reg_mod(1 DOWNTO 0)&div_toggle;
            int_trigger_pulse_reg_mod <= (NOT int_trigger_sample_reg_mod(2)) AND int_trigger_sample_reg_mod(1);
            IF mod_trigger_sel_reg = '1' THEN
                trigger_mod <= int_trigger_pulse_reg_mod;
            ELSE
                trigger_mod <= ext_trigger_pulse_reg_mod;
            END IF;
        END IF;
    END PROCESS make_trigger_mod;

    make_trigger_main : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            ext_trigger_sample_reg_main <= ext_trigger_sample_reg_main(1 DOWNTO 0)&pin_trigger;
            ext_trigger_pulse_reg_main <= (NOT ext_trigger_sample_reg_main(2)) AND ext_trigger_sample_reg_main(1);
            int_trigger_sample_reg_main <= int_trigger_sample_reg_main(1 DOWNTO 0)&div_toggle;
            int_trigger_pulse_reg_main <= (NOT int_trigger_sample_reg_main(2)) AND int_trigger_sample_reg_main(1);
            IF main_trigger_sel_reg = '1' THEN
                trigger_main_int <= int_trigger_pulse_reg_main;
            ELSE
                trigger_main_int <= ext_trigger_pulse_reg_main;
            END IF;
        END IF;
    END PROCESS make_trigger_main;
    trigger_main <= trigger_main_int;
    
    make_trigger_measure : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF s_trig_measure_ms_tick(17) = '1' THEN
                s_trig_measure_ms_tick <= to_unsigned( 31072, 18 );
                s_trig_measure <= s_trig_counter;
                s_trig_counter <= (OTHERS=>'0');
            ELSE
                s_trig_measure_ms_tick <= s_trig_measure_ms_tick + 1;
                IF trigger_main_int = '1' THEN
                    s_trig_counter <= s_trig_counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS make_trigger_measure;
    
    clock_pll : PLL_ADV
        GENERIC MAP(
            SIM_DEVICE => "SPARTAN6",
            
            BANDWIDTH => "LOW",
            COMPENSATION => "INTERNAL",
            
            --REF_JITTER => 0.080,
            --CLKIN1_PERIOD => 20.000,
            --CLKIN2_PERIOD => 20.000,
            
            CLK_FEEDBACK => "CLKFBOUT",
            CLKFBOUT_MULT => 6,
            CLKFBOUT_PHASE => 0.000,
            
            DIVCLK_DIVIDE => 1,
            
            CLKOUT0_DIVIDE => 6,
            CLKOUT0_PHASE => 0.000,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT1_DIVIDE => 6,
            CLKOUT1_PHASE => 0.000,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT2_DIVIDE => 2,
            CLKOUT2_PHASE => 0.000,
            CLKOUT2_DUTY_CYCLE => 0.500
        )
        PORT MAP(
            --CLKFBDCM => OPEN
            CLKFBOUT => pll_clkfb,
            
            CLKOUT0 => pll_clkout0,
            CLKOUT1 => pll_clkout1,
            CLKOUT2 => pll_clkout2,
            CLKOUT3 => OPEN,
            CLKOUT4 => OPEN,
            CLKOUT5 => OPEN,
            
            --CLKOUTDCM0 => OPEN,
            --CLKOUTDCM1 => OPEN,
            --CLKOUTDCM2 => OPEN,
            --CLKOUTDCM3 => OPEN,
            --CLKOUTDCM4 => OPEN,
            --CLKOUTDCM5 => OPEN,
            
            DO => pll_do,
            DRDY => pll_drdy,
            DADDR => pll_daddr,
            DCLK => pll_dclk,
            DEN => pll_den,
            DI => pll_di,
            DWE => pll_dwe,
            
            LOCKED => pll_locked,
            CLKFBIN => pll_clkfb,
            
            CLKIN1 => s_clk_sel,
            CLKIN2 => '0',
            CLKINSEL => '1',
            
            REL => '0',
            RST => pll_reset
        );
    pll_reset <= s_pll_reset OR drp_pll_reset;

    drp_port : ENTITY work.pll_drp PORT MAP(
            sclk => clk,
            rst => reset,
            saddr => drp_saddr,
            sen => drp_sen,
            srdy => drp_srdy,
            
            do => pll_do,
            drdy => pll_drdy,
            locked => s_pll_locked_reg,
            dwe => pll_dwe,
            den => pll_den,
            daddr_out => pll_daddr,
            di_out => pll_di,
            dclk => pll_dclk,
            rst_pll_out => drp_pll_reset
        );
    
    clk_ref_buf : BUFG PORT MAP( I => pll_clkout0, O => clk_ref_int ); clk_ref <= clk_ref_int;
    clk_mod_buf : BUFG PORT MAP( I => pll_clkout1, O => clk_mod_int ); clk_mod <= clk_mod_int;
    clk_tdc_buf : BUFG PORT MAP( I => pll_clkout2, O => clk_tdc );
    
    usb_data_in_ack <= '1' WHEN s_state_reg = IDLE ELSE '0';
    idle_out <= '1' WHEN s_state_reg = IDLE ELSE '0';
    
    make_state : PROCESS(clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
			IF reset = '1' THEN
				usb_data_out_valid <= '0';
				s_clk_ctrl_select_reg <= SELECT_INTERNAL;
				s_dcm_reset <= '1';
				s_pll_reset <= '1';
				s_clk_ctrl_counter_reg <= to_unsigned( DCM_RST_TIME, 32 );
				s_state_reg <= RESET_DCM;
			ELSE
			    s_dcm_locked_reg <= dcm_locked;
				s_pll_locked_reg <= pll_locked;
				CASE s_state_reg IS
					WHEN IDLE =>
						IF usb_data_in_valid = '1' THEN
						    IF usb_adr_in = ADR THEN
							    --READ STATUS
							    IF usb_data_in(31 DOWNTO 28) = X"0" THEN
								    usb_data_out(31 DOWNTO 28) <= (OTHERS=>'0');
								    usb_data_out(27 DOWNTO 24) <= s_pll_configuration;
								    usb_data_out(23 DOWNTO 8) <= s_dcm_configuration;
								    usb_data_out(7 DOWNTO 6) <= (OTHERS=>'0');
								    usb_data_out(5) <= s_dcm_programmed;
								    usb_data_out(4) <= s_pll_reset;
								    usb_data_out(3) <= s_dcm_reset;
								    usb_data_out(2) <= s_pll_locked_reg;
								    usb_data_out(1) <= s_dcm_locked_reg;
								    usb_data_out(0) <= s_clk_ctrl_select_reg;
								    usb_data_out_valid <= '1';
								    s_state_reg <= SEND_DATA;
							    --SEND FREQUENCY MEASUREMENT
							    ELSIF usb_data_in(31 DOWNTO 28) = X"1" THEN
								    usb_data_out <= s_freq_measure;
								    usb_data_out_valid <= '1';
								    s_state_reg <= SEND_DATA;
							    --SWITCH CLOCK
							    ELSIF usb_data_in(31 DOWNTO 28) = X"2" THEN
								    s_clk_ctrl_select_reg <= usb_data_in(0);
								    s_fallback_disabled_reg <= usb_data_in(1);
								    s_pll_reset <= '1';
								    s_clk_ctrl_counter_reg <= to_unsigned( PLL_RST_TIME, 32 );
								    s_state_reg <= RESET_PLL;
								--PROGRAM CLOCKS
								ELSIF usb_data_in(31 DOWNTO 28) = X"3" THEN
								    s_pll_configuration <= usb_data_in(19 DOWNTO 16);
								    drp_saddr <= usb_data_in(19 DOWNTO 16);
								    s_dcm_configuration <= usb_data_in(15 DOWNTO 0);
								    s_dcm_progdata_reg <= "00000000"&usb_data_in(15 DOWNTO 8)&"110000"&usb_data_in(7 DOWNTO 0)&"01";
								    s_dcm_progen_reg <= "00010000111111111100001111111111";
								    s_dcm_prog_counter_reg <= (OTHERS=>'1');
							        s_pll_reset <= '1';
								    s_state_reg <= PROG_DCM;
								ELSIF usb_data_in(31 DOWNTO 28) = X"4" THEN
								    main_trigger_sel_reg <= usb_data_in(24);
								    mod_trigger_sel_reg <= usb_data_in(20);
                                    div_enable <= usb_data_in(16);
                                    div_count <= unsigned(usb_data_in(15 DOWNTO 0));
                                ELSIF usb_data_in(31 DOWNTO 28) = X"5" THEN
                                    usb_data_out <= "000000000000000"&std_logic_vector(s_trig_measure);
                                    usb_data_out_valid <= '1';
                                    s_state_reg <= SEND_DATA;
							    --SOFT RESET
							    ELSIF usb_data_in(31 DOWNTO 28) = X"F" THEN
								    usb_data_out_valid <= '0';
								    s_clk_ctrl_select_reg <= SELECT_INTERNAL;
								    s_dcm_reset <= '1';
								    s_pll_reset <= '1';
								    s_clk_ctrl_counter_reg <= to_unsigned( DCM_RST_TIME, 32 );
								    s_state_reg <= RESET_DCM;
							    END IF;
							END IF;
				        ELSIF s_fallback_disabled_reg = '0' AND s_pll_locked_reg = '0' AND s_clk_ctrl_select_reg = SELECT_EXTERNAL THEN
					        usb_data_out_valid <= '0';
					        s_clk_ctrl_select_reg <= SELECT_INTERNAL;
							s_pll_reset <= '1';
					        s_clk_ctrl_counter_reg <= to_unsigned( PLL_RST_TIME, 32 );
					        s_state_reg <= RESET_PLL;
				        END IF;
					WHEN SEND_DATA =>
						IF usb_data_out_busy = '0' THEN
							usb_data_out_valid <= '0';
							s_state_reg <= IDLE;
						END IF;
					WHEN RESET_DCM =>
						s_dcm_programmed <= '0';
						s_dcm_configuration <= (OTHERS=>'0');
						s_pll_configuration <= (OTHERS=>'0');
						drp_saddr <= (OTHERS=>'0');
						IF s_clk_ctrl_counter_reg /= 0 THEN
							s_clk_ctrl_counter_reg <= s_clk_ctrl_counter_reg - 1;
						ELSE
							s_dcm_reset <= '0';
							s_clk_ctrl_counter_reg <= to_unsigned( DCM_LCK_TIME, 32 );
							s_state_reg <= WAIT_DCM;
						END IF;
					WHEN PROG_DCM =>
					    IF s_dcm_prog_counter_reg /= 0 THEN
					        s_dcm_prog_counter_reg <= s_dcm_prog_counter_reg - 1;
					        dcm_progdata <= s_dcm_progdata_reg(0);
					        s_dcm_progdata_reg <= '0'&s_dcm_progdata_reg(31 DOWNTO 1);
					        dcm_progen <= s_dcm_progen_reg(0);
					        s_dcm_progen_reg <= '0'&s_dcm_progen_reg(31 DOWNTO 1);
					    ELSE
					        s_dcm_programmed <= '1';
					        s_clk_ctrl_counter_reg <= to_unsigned( DCM_LCK_TIME, 32 );
					        s_state_reg <= WAIT_DCM;
					    END IF;
					WHEN WAIT_DCM =>
					    IF dcm_progdone = '1' AND s_dcm_locked_reg = '1' THEN
					        drp_sen <= '1';
					        s_state_reg <= PROG_PLL;
						ELSIF s_clk_ctrl_counter_reg /= 0 THEN
							s_clk_ctrl_counter_reg <= s_clk_ctrl_counter_reg - 1;
						ELSE
							--Failed to lock, reset DCM
							s_dcm_reset <= '1';
							s_clk_ctrl_counter_reg <= to_unsigned( DCM_RST_TIME, 32 );
							s_state_reg <= RESET_DCM;
						END IF;
					WHEN PROG_PLL =>
					    drp_sen <= '0';
					    s_state_reg <= WAIT_DRP;
					WHEN WAIT_DRP =>
					    s_clk_ctrl_counter_reg <= to_unsigned( PLL_LCK_TIME, 32 );
					    IF drp_srdy = '1' THEN
					        s_pll_reset <= '0';
					        s_state_reg <= WAIT_PLL;
					    END IF;
					WHEN RESET_PLL =>
						IF s_clk_ctrl_counter_reg /= 0 THEN
							s_clk_ctrl_counter_reg <= s_clk_ctrl_counter_reg - 1;
						ELSE
							s_pll_reset <= '0';
							s_clk_ctrl_counter_reg <= to_unsigned( PLL_LCK_TIME, 32 );
							s_state_reg <= WAIT_PLL;
						END IF;
					WHEN WAIT_PLL =>
						IF s_pll_locked_reg = '1' THEN
							s_state_reg <= IDLE;
						ELSIF s_clk_ctrl_counter_reg /= 0 THEN
							s_clk_ctrl_counter_reg <= s_clk_ctrl_counter_reg - 1;
						ELSE
							--Failed to lock, put PLL in reset and switch back to internal clock
							s_pll_reset <= '1';
							IF s_clk_ctrl_select_reg = SELECT_EXTERNAL THEN
								s_clk_ctrl_select_reg <= SELECT_INTERNAL;
								s_clk_ctrl_counter_reg <= to_unsigned( PLL_RST_TIME, 32 );
								s_state_reg <= RESET_PLL;
							ELSE --on internal, keep PLL in reset
								s_state_reg <= IDLE;
							END IF;
						END IF;
					WHEN OTHERS =>
						NULL;
				END CASE;
			END IF;
        END IF;
    END PROCESS make_state;
    
END ARCHITECTURE arch;

