LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY hazard_detection IS
    GENERIC (N : INTEGER := 32);
    PORT (
        i_FetchRsVal : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_FetchRtVal : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        i_ExecuteRtVal : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

        i_J : IN STD_LOGIC;
        i_JAL : IN STD_LOGIC;
        i_JR : IN STD_LOGIC;
        iBranch : IN STD_LOGIC;
        i_DMEMWE : IN STD_LOGIC;

        o_PCWE : OUT STD_LOGIC; --STALL
        o_FetchWE : OUT STD_LOGIC; --STALL
        o_FetchFlush : OUT STD_LOGIC; --Flush
        o_DecodeFlush : OUT STD_LOGIC;--Flush
        o_MemoryFlush : OUT STD_LOGIC;--Flush
    );
END hazard_detection;
ARCHITECTURE dataflow OF hazard_detection IS
    SIGNAL s_LoadHazard, s_JumpHazard, s_RegisterHazard, s_BranchHazard : IN STD_LOGIC;

BEGIN
    s_LoadHazard <= '1' WHEN (i_DMEMWE = '1' AND ((i_ExecuteRtVal = i_FetchRsVal) OR (i_ExecuteRtVal = i_FetchRtVal)))ELSE
        '0';

    s_JumpHazard <= '1' WHEN (i_J = '1' OR i_JAL = '1') ELSE
        '0';

    s_RegisterHazard <= '1' WHEN (i_JR = '1' AND i_FetchRsVal = i_ExecuteRtVal) ELSE
        '0';

    s_BranchHazard <= '1' WHEN (iBranch = '1' AND ((i_ExecuteRtVal = i_FetchRsVal) OR (i_ExecuteRtVal = i_FetchRtVal)) AND i_ExecuteRtVal /= "00000") ELSE
        '0';

    o_PCWE <= '0' WHEN (s_LoadHazard = '1' OR s_BranchHazard = '1' OR s_JumpHazard = '1') ELSE
        '1';
    o_FetchWE <= '0' WHEN (s_LoadHazard = '1' OR s_BranchHazard = '1' OR s_JumpHazard = '1') ELSE
        '1';
    o_FetchFlush <= '1' WHEN (s_JumpHazard = '1') ELSE
        '0';

    o_DecodeFlush <= '1' WHEN (s_JumpHazard = '1' OR s_BranchHazard = '1' OR s_LoadHazard = '1') ELSE
        '0';

END dataflow;