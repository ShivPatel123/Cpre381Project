LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FetchLogic_tb IS
    GENERIC (gCLK_HPER : TIME := 50 ns);
END FetchLogic_tb;

ARCHITECTURE testbench OF FetchLogic_tb IS
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    -- Clock signal
    SIGNAL s_CLK : STD_LOGIC := '0';
    -- Reset signal
    SIGNAL s_RST : STD_LOGIC := '0';
    -- Branch signals
    SIGNAL s_BRANCH : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    -- Jump and link signal
    SIGNAL s_JAL : STD_LOGIC := '0';
    -- Zero flag signal
    SIGNAL s_ZERO : STD_LOGIC := '0';
    -- Jump register signal
    SIGNAL s_JR : STD_LOGIC := '0';
    -- Jump signal
    SIGNAL s_J : STD_LOGIC := '0';
    -- Immediate value
    SIGNAL s_IMM : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- Register data
    SIGNAL s_RSDATA, s_JADDRESS : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    -- Outputs from FetchLogic module
    SIGNAL s_JALDATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_IMEMADDRESS : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Instantiate the FetchLogic module
    COMPONENT FetchLogic
        PORT (
            i_CLK : IN STD_LOGIC;
            i_RST : IN STD_LOGIC;
            i_BRANCH : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            i_JAL : IN STD_LOGIC;
            i_ZERO : IN STD_LOGIC;
            i_JR : IN STD_LOGIC;
            i_J : IN STD_LOGIC;
            i_IMM : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --signed imm value after bitwidth extender
            i_JADDRESS : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            i_RSDATA : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            o_JALDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_IMEMADDRESS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    -- Instantiate the FetchLogic module
    dut : FetchLogic
    PORT MAP(
        i_CLK => s_CLK,
        i_RST => s_RST,
        i_BRANCH => s_BRANCH,
        i_JAL => s_JAL,
        i_ZERO => s_ZERO,
        i_JR => s_JR,
        i_J => s_J,
        i_IMM => s_IMM,
        i_JADDRESS => s_JADDRESS,
        i_RSDATA => s_RSDATA,
        o_JALDATA => s_JALDATA,
        o_IMEMADDRESS => s_IMEMADDRESS
    );

    -- Clock process (generate clock signal)
    P_CLK : PROCESS
    BEGIN
        s_CLK <= '0';
        WAIT FOR gCLK_HPER;
        s_CLK <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS;

    -- Test stimuli generation process
    testcases : PROCESS
    BEGIN

        s_RST <= '1';
        WAIT FOR cCLK_PER;
        s_RST <= '0';
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;
        -- Test case 1: Normal instruction fetch
        s_RST <= '0';
        s_BRANCH <= "00"; -- No branching
        s_JAL <= '0';
        s_ZERO <= '0';
        s_JR <= '0';
        s_J <= '0';
        s_IMM <= (OTHERS => '0'); -- No immediate value
        s_RSDATA <= (OTHERS => '0'); -- No register data
        WAIT FOR cCLK_PER;

        -- Test case 2: Branch instruction BEQ
        s_BRANCH <= "01"; -- Branch taken
        s_IMM <= X"00000003"; -- Branch offset
        s_ZERO <= '1';
        WAIT FOR cCLK_PER;

        -- Test case 2: Branch instruction BNE
        s_BRANCH <= "10"; -- Branch taken
        s_IMM <= X"00000011"; -- Branch offset
        s_ZERO <= '0';
        WAIT FOR cCLK_PER;

        -- Test case 3: Jump instruction
        s_BRANCH <= "00"; -- No branching
        s_J <= '1'; -- Jump
        s_JADDRESS <= X"00001000"; -- Jump target address
        WAIT FOR cCLK_PER;

        -- Test case 4: Jump and link instruction
        s_J <= '0'; -- No jump
        s_JAL <= '1'; -- Jump and link
        s_JADDRESS <= X"00002000"; -- Jump target address for JAL
        WAIT FOR cCLK_PER;

        -- Test case 5: Jump Register instruction
        s_JAL <= '0'; -- No jump
        s_JR <= '1'; -- Jump and link
        s_RSDATA <= X"0000000A"; -- Jump target address for JAL
        WAIT FOR cCLK_PER;
        WAIT;
    END PROCESS;

END testbench;