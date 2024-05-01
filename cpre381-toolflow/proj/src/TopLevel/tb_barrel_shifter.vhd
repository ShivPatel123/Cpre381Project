LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_barrel_shifter IS
    GENERIC (gCLK_HPER : TIME := 50 ns);
END tb_barrel_shifter;

ARCHITECTURE tb_arch OF tb_barrel_shifter IS
    -- Constants for signal widths
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    -- Clock signal
    SIGNAL s_CLK : STD_LOGIC := '0';
    -- Component declaration
COMPONENT barrel_shifter IS
    PORT (
        i_sType : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- bit 0: if 0 - right if 1 - left  bit 1: if 0 - logical if 1 - arithmetic  bit 2: 0 - shamt  1 - reg
        i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- shift amount
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- rt input to shift 
        i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- register input for shift amount if the 'v' version of instruction is used
        o_Shift : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- shifted output
    );
END COMPONENT;

    -- Signals for ALU inputs and outputs
    SIGNAL s_sType : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_rs : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_oShift : STD_LOGIC_VECTOR(31 DOWNTO 0);
    

BEGIN
    -- Instantiate the ALU module
    DUT0 : barrel_shifter
    PORT MAP(
        i_sType  => s_sType,
        i_shamt  => s_shamt,
        i_Data   => s_Data,
        i_rs     => s_rs,
        o_Shift  => s_oShift
    );

    -- Clock process
    P_CLK : PROCESS
    BEGIN
        s_CLK <= '0';
        WAIT FOR gCLK_HPER;
        s_CLK <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS P_CLK;

    -- Test Cases
    testcases : PROCESS
    BEGIN
        -- Test Case 1: sll
        s_sType   <=  "001";
        s_shamt   <=  "00001";
        s_Data    <=  x"00000001";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000002"
        
        -- Test Case 2: sllv
        s_sType   <=  "101";
        s_shamt   <=  "00001";
        s_Data    <=  x"00000001";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000004"

        -- Test Case 3: srl
        s_sType   <=  "000";
        s_shamt   <=  "00001";
        s_Data    <=  x"0000000F";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000007"

        -- Test Case 4: srlv
        s_sType   <=  "100";
        s_shamt   <=  "00001";
        s_Data    <=  x"0000000F";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000003"

        -- Test Case 5: sra
        s_sType   <=  "010";
        s_shamt   <=  "00001";
        s_Data    <=  x"0000000F";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000007"

        -- Test Case 6: srav
        s_sType   <=  "110";
        s_shamt   <=  "00001";
        s_Data    <=  x"0000000F";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000003"

        -- Test Case 7: sra
        s_sType   <=  "010";
        s_shamt   <=  "00001";
        s_Data    <=  x"F0000000";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"F8000000"

        -- Test Case 8: srav
        s_sType   <=  "110";
        s_shamt   <=  "00001";
        s_Data    <=  x"F0000000";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"B8000000"

        -- Test Case 9: sll
        s_sType   <=  "001";
        s_shamt   <=  "00001";
        s_Data    <=  x"F0000000";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"E000000"

        -- Test Case 10: sll
        s_sType   <=  "001";
        s_shamt   <=  "00001";
        s_Data    <=  x"E0000000";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"C000000"

        -- Test Case 11: sll
        s_sType   <=  "001";
        s_shamt   <=  "00101";
        s_Data    <=  x"00000001";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"0000020"

        -- Test Case 12: sllv
        s_sType   <=  "101";
        s_shamt   <=  "00001";
        s_Data    <=  x"E0000000";
        s_rs      <=  x"00000002";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"8000000"

        -- Test Case 13: sllv
        s_sType   <=  "101";
        s_shamt   <=  "00001";
        s_Data    <=  x"00000001";
        s_rs      <=  x"0000001F";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"8000000"

        -- Test Case 14: sllv
        s_sType   <=  "101";
        s_shamt   <=  "00001";
        s_Data    <=  x"00000001";
        s_rs      <=  x"00000020";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"0000001"

        -- Test Case 15: sllv
        s_sType   <=  "101";
        s_shamt   <=  "00001";
        s_Data    <=  x"00000001";
        s_rs      <=  x"00000028";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"0000100"

        -- Test Case 16: sllv
        s_sType   <=  "101";
        s_shamt   <=  "00001";
        s_Data    <=  x"00000001";
        s_rs      <=  x"0FA10000";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"0000001"

        -- Test Case 17: srl
        s_sType   <=  "000";
        s_shamt   <=  "00001";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10000";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"7FFFFFFF"

        -- Test Case 18: srl
        s_sType   <=  "000";
        s_shamt   <=  "10101";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10000";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"000007FF"

        -- Test Case 19: srl
        s_sType   <=  "000";
        s_shamt   <=  "11111";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10000";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"0000001"

        -- Test Case 20: srlv
        s_sType   <=  "100";
        s_shamt   <=  "11111";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10000";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"FFFFFFFF"

        -- Test Case 21: srlv
        s_sType   <=  "100";
        s_shamt   <=  "11111";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10008";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00FFFFFF"

        -- Test Case 22: sra
        s_sType   <=  "010";
        s_shamt   <=  "11100";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10008";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"FFFFFFFF"

        -- Test Case 23: sra 
        s_sType   <=  "010";
        s_shamt   <=  "11100";
        s_Data    <=  x"7FFFFFFF";
        s_rs      <=  x"0FA10008";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000007"

        -- Test Case 24: sra
        s_sType   <=  "010";
        s_shamt   <=  "11111";
        s_Data    <=  x"7FFFFFFF";
        s_rs      <=  x"0FA10008";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"00000000"

        -- Test Case 25: srav
        s_sType   <=  "110";
        s_shamt   <=  "11100";
        s_Data    <=  x"7FFFFFFF";
        s_rs      <=  x"0FA10008";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"007FFFFF"

        -- Test Case 25: srav
        s_sType   <=  "110";
        s_shamt   <=  "11100";
        s_Data    <=  x"FFFFFFFF";
        s_rs      <=  x"0FA10008";
        WAIT FOR cCLK_PER;
        --Expect s_oShift = x"FFFFFFFF"


        WAIT;
    END PROCESS testcases;

END tb_arch;