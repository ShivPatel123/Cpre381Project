LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_tb IS
    GENERIC (gCLK_HPER : TIME := 50 ns);
END pc_tb;

ARCHITECTURE tb_arch OF pc_tb IS
    -- Constants for signal widths
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    -- Clock signal
    SIGNAL s_CLK : STD_LOGIC := '0';

    -- Signals for test bench
    SIGNAL i_WE : STD_LOGIC;
    SIGNAL i_RST : STD_LOGIC;
    SIGNAL i_ADDRESS : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL o_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Component declaration
    COMPONENT PC

        PORT (
            i_CLK : IN STD_LOGIC;
            i_WE : IN STD_LOGIC;
            i_RST : IN STD_LOGIC;
            i_ADDRESS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    -- Instantiate the pc module
    DUT0 : PC
    PORT MAP(
        i_CLK => s_CLK,
        i_WE => i_WE,
        i_RST => i_RST,
        i_ADDRESS => i_ADDRESS,
        o_Out => o_Out
    );
    P_CLK : PROCESS
    BEGIN
        s_CLK <= '0';
        WAIT FOR gCLK_HPER;
        s_CLK <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS;

    -- Test Cases
    testcases : PROCESS
    BEGIN

        i_RST <= '1';
        WAIT FOR cCLK_PER;
        i_RST <= '0';
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;
        i_ADDRESS <= X"00001111";
        i_WE <= '1';
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;
        i_WE <= '0';

        WAIT FOR cCLK_PER;

    END PROCESS;

END tb_arch;