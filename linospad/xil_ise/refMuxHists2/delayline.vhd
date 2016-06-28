LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY delayline IS
    GENERIC(
        CONSTANT NUM_CARRY_ELEMENTS       : integer );
    PORT(
        SIGNAL trigger          : IN    std_logic;
        SIGNAL clk              : IN    std_logic;
        SIGNAL triggered        : OUT   std_logic;
        SIGNAL samples          : OUT   std_logic_vector(NUM_CARRY_ELEMENTS*4 -1 DOWNTO 0) );
END ENTITY delayline;

ARCHITECTURE arch OF delayline IS
    ATTRIBUTE RLOC : STRING;
    --Trigger element
    SIGNAL trigger_co : std_logic_vector(3 DOWNTO 0);
    SIGNAL trigger_o : std_logic_vector(3 DOWNTO 0);
    SIGNAL trigger_ci : std_logic;
    SIGNAL trigger_cyinit : std_logic;
    SIGNAL trigger_di : std_logic_vector(3 DOWNTO 0);
    SIGNAL trigger_s : std_logic_vector(3 DOWNTO 0);
    ATTRIBUTE RLOC OF trigger_carry : LABEL IS "X0Y-1";
    ATTRIBUTE RLOC OF trigger_tap : LABEL IS "X0Y-1";
    --Main chain
    CONSTANT topbit : natural := NUM_CARRY_ELEMENTS*4 -1;
    SIGNAL carry_co : std_logic_vector(topbit DOWNTO 0);
    SIGNAL carry_o : std_logic_vector(topbit DOWNTO 0);
    SIGNAL carry_ci : std_logic_vector(NUM_CARRY_ELEMENTS-1 DOWNTO 0);
    SIGNAL carry_cyinit : std_logic_vector(NUM_CARRY_ELEMENTS-1 DOWNTO 0);
    SIGNAL carry_di : std_logic_vector(topbit DOWNTO 0);
    SIGNAL carry_s : std_logic_vector(topbit DOWNTO 0);
BEGIN
    trigger_di <= (3 => trigger, OTHERS=>'0');
    trigger_s <= (OTHERS=>'0');
    trigger_ci <= '0';
    trigger_cyinit <= '0';
    trigger_carry : CARRY4 PORT MAP (
        CO => trigger_co,
        O => trigger_o,
        CI => trigger_ci,
        CYINIT => trigger_cyinit,
        DI => trigger_di,
        S => trigger_s );
    
    --Main chain
    carry_di <= (OTHERS=>'0');
    carry_s <= (OTHERS=>'1');
    carry_ci(0) <= trigger_co(3);
    make_carry_ci : FOR i IN 1 TO NUM_CARRY_ELEMENTS-1 GENERATE
        carry_ci(i) <= carry_co((i-1)*4+3);
    END GENERATE;
    carry_cyinit <= (OTHERS=>'0');
    carry_chain : FOR i IN 0 TO NUM_CARRY_ELEMENTS-1 GENERATE
        ATTRIBUTE RLOC OF carry : LABEL IS "X0Y"&INTEGER'image(i);
    BEGIN
        carry : CARRY4
            PORT MAP (
                CO => carry_co(i*4+3 DOWNTO i*4),
                O => carry_o(i*4+3 DOWNTO i*4),
                CI => carry_ci(i),
                CYINIT => carry_cyinit(i),
                DI => carry_di(i*4+3 DOWNTO i*4),
                S => carry_s(i*4+3 DOWNTO i*4)
            );
    END GENERATE;

    trigger_tap : FDCE
        PORT MAP (
            D => trigger_co(3),
            C => clk,
            CE => '1',
            Q => triggered,
            CLR => '0'
        );

    taps : FOR i IN 0 TO topbit GENERATE
        ATTRIBUTE RLOC OF ff : LABEL IS "X0Y"&INTEGER'image(i/4);
    BEGIN
        ff : FDCE
            PORT MAP (
                D => carry_co(i),
                C => clk,
                CE => '1',
                Q => samples(i),
                CLR => '0'
            );
    END GENERATE;
END ARCHITECTURE arch;

