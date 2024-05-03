LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
    GENERIC (gCLK_HPER : TIME := 50 ns);
END alu_tb;

ARCHITECTURE tb_arch OF alu_tb IS
    -- Constants for signal widths
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    -- Clock signal
    SIGNAL s_CLK : STD_LOGIC := '0';
    -- Component declaration
    COMPONENT ALU IS
        PORT (
            i_RSDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_RTDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_IMM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_ALUOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            i_ALUSRC : IN STD_LOGIC;
            i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            o_RESULT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_CARRYOUT : OUT STD_LOGIC;
            o_OVERFLOW : OUT STD_LOGIC;
            o_ZERO : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals for ALU inputs and outputs
    SIGNAL s_RSDATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_RTDATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_IMM : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_ALUSRC : STD_LOGIC;
    SIGNAL s_SHAMT : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_CARRYOUT : STD_LOGIC;
    SIGNAL s_OVERFLOW : STD_LOGIC;
    SIGNAL s_ZERO : STD_LOGIC;

BEGIN
    -- Instantiate the ALU module
    DUT0 : ALU
    PORT MAP(
        i_RSDATA => s_RSDATA,
        i_RTDATA => s_RTDATA,
        i_IMM => s_IMM,
        i_ALUOP => s_ALUOP,
        i_ALUSRC => s_ALUSRC,
        i_SHAMT => s_SHAMT,
        o_RESULT => s_RESULT,
        o_CARRYOUT => s_CARRYOUT,
        o_OVERFLOW => s_OVERFLOW,
        o_ZERO => s_ZERO
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

        -- Test Case 1: addi expected 15
        s_RSDATA <= X"0000000A"; -- Input data 1
        s_RTDATA <= X"00000000"; -- Input data 2
        s_IMM <= X"00000005"; -- Immediate value
        s_ALUOP <= "0001"; -- ALU operation (addition)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 2: add
        s_RSDATA <= X"0000000A"; -- Input data 1
        s_RTDATA <= X"00000005"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0001"; -- ALU operation (addition)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- -- Test Case 3: addiu
        -- s_RSDATA <= X"0000000A"; -- Input data 1
        -- s_RTDATA <= X"00000005"; -- Input data 2
        -- s_IMM <= X"0005"; -- Immediate value
        -- s_ALUOP <= "0001"; -- ALU operation (addition)
        -- s_ALUSRC <= '1'; -- ALU source
        -- s_SHAMT <= (OTHERS => '0'); -- Shift amount
        -- WAIT FOR cCLK_PER;

        -- -- Test Case 4: addu
        -- s_RSDATA <= X"FFFFFFFF"; -- Input data 1
        -- s_RTDATA <= X"00000001"; -- Input data 2
        -- s_IMM <= (OTHERS => '0'); -- Immediate value
        -- s_ALUOP <= "0001"; -- ALU operation (addition)
        -- s_ALUSRC <= '0'; -- ALU source
        -- s_SHAMT <= (OTHERS => '0'); -- Shift amount
        -- WAIT FOR cCLK_PER;

        -- Test Case 5: sub
        s_RSDATA <= X"00000005"; -- Input data 1
        s_RTDATA <= X"00000003"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0010"; -- ALU operation (subtraction)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- -- Test Case 6: subu
        -- s_RSDATA <= X"00000005"; -- Input data 1
        -- s_RTDATA <= X"00000003"; -- Input data 2
        -- s_IMM <= (OTHERS => '0'); -- Immediate value
        -- s_ALUOP <= "0010"; -- ALU operation (subtraction)
        -- s_ALUSRC <= '0'; -- ALU source
        -- s_SHAMT <= (OTHERS => '0'); -- Shift amount
        -- WAIT FOR cCLK_PER;

        -- Test Case 7: and expected is X0000FFFF
        s_RSDATA <= X"FFFFFFFF"; -- Input data 1
        s_RTDATA <= X"0000FFFF"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0011"; -- ALU operation (AND)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 8: andi expected 000000000000000000011111111111111111111
        s_RSDATA <= X"FFFFFFFF"; -- Input data 1
        s_RTDATA <= X"00000000"; -- Input data 2
        s_IMM <= X"0000FFFF"; -- Immediate value
        s_ALUOP <= "0011"; -- ALU operation (AND)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 9: or expected 11111111111111111111111111111
        s_RSDATA <= X"0000F0FF"; -- Input data 1
        s_RTDATA <= X"FFFF0F0F"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0100"; -- ALU operation (OR)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 10: ori expected X0000FFFF
        s_RSDATA <= X"000000FF"; -- Input data 1
        s_RTDATA <= X"00000000"; -- Input data 2
        s_IMM <= X"0000FF00"; -- Immediate value
        s_ALUOP <= "0100"; -- ALU operation (OR)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 11: xor expected 1111111111111100000000
        s_RSDATA <= X"FFFF00FF"; -- Input data 1
        s_RTDATA <= X"0000FFFF"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0101"; -- ALU operation (XOR)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 12: xori  expected 000000001111111111111111111
        s_RSDATA <= X"FFFFFFFF"; -- Input data 1
        s_RTDATA <= X"00000000"; -- Input data 2
        s_IMM <= X"FF000000"; -- Immediate value
        s_ALUOP <= "0101"; -- ALU operation (XOR)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 13: nor expected 1111111111111111111111111111
        s_RSDATA <= X"00000000"; -- Input data 1
        s_RTDATA <= X"00000000"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0110"; -- ALU operation (NOR)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 14: slt  expected FFFFFFFF
        s_RSDATA <= X"00000001"; -- Input data 1
        s_RTDATA <= X"00000002"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "0111"; -- ALU operation (SLT)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 15: slti expected 00000000
        s_RSDATA <= X"00000002"; -- Input data 1
        s_RTDATA <= X"00000001"; -- Input data 2
        s_IMM <= X"00000001"; -- Immediate value
        s_ALUOP <= "0111"; -- ALU operation (SLT)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 16: sll expected 0000000000000000000001000
        s_RSDATA <= X"00000001"; -- Input data 1
        s_RTDATA <= X"00000001"; -- Input data 2
        s_IMM <= (OTHERS => '0'); -- Immediate value
        s_ALUOP <= "1000"; -- ALU operation (SLL)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= "00011"; -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 17: sllv 00000000000000001100
        s_RSDATA <= X"00000002"; -- Input data 1
        s_RTDATA <= X"00000003"; -- Input data 2
        s_IMM <= X"00000000"; -- Immediate value
        s_ALUOP <= "1000"; -- ALU operation (SLL)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 18: srl expected 000100000000000000000
        s_RSDATA <= (OTHERS => '0'); -- Input data 1
        s_RTDATA <= X"80000000"; -- Input data 2
        s_IMM <= X"00000000"; -- Immediate value
        s_ALUOP <= "1001"; -- ALU operation (SRL)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= "00011"; -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 19: srlv expected 000100000000000000000
        s_RSDATA <= X"00000003"; -- Input data 1
        s_RTDATA <= X"80000000"; -- Input data 2
        s_IMM <= X"00000000"; -- Immediate value
        s_ALUOP <= "1001"; -- ALU operation (SRL)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= "00001"; -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 20: sra  expected 1111000000000000000
        s_RSDATA <= X"80000000"; -- Input data 1
        s_RTDATA <= X"80000000"; -- Input data 2
        s_IMM <= X"00000000"; -- Immediate value
        s_ALUOP <= "1010"; -- ALU operation (SRA)
        s_ALUSRC <= '1'; -- ALU source
        s_SHAMT <= "00011"; -- Shift amount
        WAIT FOR cCLK_PER;

        -- Test Case 21: srav expected 1111000000000000000
        s_RSDATA <= X"00000003"; -- Input data 1
        s_RTDATA <= X"80000000"; -- Input data 2
        s_IMM <= X"00000000"; -- Immediate value
        s_ALUOP <= "1010"; -- ALU operation (SRA)
        s_ALUSRC <= '0'; -- ALU source
        s_SHAMT <= (OTHERS => '0'); -- Shift amount
        WAIT FOR cCLK_PER;

        WAIT;
    END PROCESS testcases;

END tb_arch;