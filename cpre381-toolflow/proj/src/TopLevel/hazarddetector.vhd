LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY hazard_detector IS
    PORT (
        i_clk : IN STD_LOGIC;
        i_RtAddress : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_RsAddress : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_RdAddress : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_RdAddressEx : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_RegWr : IN STD_LOGIC;
        i_RegWrEx : IN STD_LOGIC;
        i_J : IN STD_LOGIC;
        i_BranchYesOrNo : IN STD_LOGIC;
        o_Flush : OUT STD_LOGIC;
        o_Stall : OUT STD_LOGIC
    );

END hazard_detector;

ARCHITECTURE structural OF hazard_detector IS
    SIGNAL s_MemDependency : STD_LOGIC;
    SIGNAL s_ExDependency : STD_LOGIC;
    SIGNAL s_FlushTemp : STD_LOGIC;

BEGIN

    s_FlushTemp <= '1' WHEN (i_J = '1' OR i_BranchYesOrNo = '1')
        ELSE
        '0';

    o_Flush <= s_FlushTemp WHEN i_clk = '1';

    s_MemDependency <= '1' WHEN ((i_RsAddress = i_RdAddress AND i_RsAddress /= "00000") OR (i_RtAddress = i_RdAddress AND i_RtAddress /= "00000"))
        ELSE
        '0';

    s_ExDependency <= '1' WHEN ((i_RsAddress = i_RdAddressEx AND i_RsAddress /= "00000") OR (i_RtAddress = i_RdAddressEx AND i_RtAddress /= "00000"))
        ELSE
        '0';

    o_Stall <= (s_ExDependency AND i_RegWrEx) OR (s_MemDependency AND i_RegWr);

END structural;