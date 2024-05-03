LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY control_tb IS
    GENERIC (gCLK_HPER : TIME := 50 ns);
END control_tb;

ARCHITECTURE tb_arch OF control_tb IS
    -- Constants for signal widths
    CONSTANT OP_WIDTH : INTEGER := 6;
    CONSTANT FUNC_WIDTH : INTEGER := 6;
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;
    -- Clock signal
    SIGNAL s_CLK : STD_LOGIC := '0';

    -- Signals for test bench
    SIGNAL s_iOp : STD_LOGIC_VECTOR(OP_WIDTH - 1 DOWNTO 0);
    SIGNAL s_iFunct : STD_LOGIC_VECTOR(FUNC_WIDTH - 1 DOWNTO 0);
    SIGNAL s_oRegDst : STD_LOGIC;
    SIGNAL s_oJ : STD_LOGIC;
    SIGNAL s_oBranch : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_oAxMOut : STD_LOGIC;
    SIGNAL s_oALUOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_oMemWrite : STD_LOGIC;
    SIGNAL s_oALUSrc : STD_LOGIC;
    SIGNAL s_oUnsigned : STD_LOGIC;
    SIGNAL s_oJr : STD_LOGIC;
    SIGNAL s_oJal : STD_LOGIC;
    SIGNAL s_oRegWrite : STD_LOGIC;
    SIGNAL s_shiftSel : STD_LOGIC;

    -- Component declaration
    COMPONENT control
    PORT (
        i_Op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        i_Funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        o_RegDst : OUT STD_LOGIC; --
        o_J : OUT STD_LOGIC; --
        o_Branch : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --
        o_AxMOut : OUT STD_LOGIC; --
        o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --
        o_MemWrite : OUT STD_LOGIC; --
        o_ALUSrc : OUT STD_LOGIC; --
        o_Unsigned : OUT STD_LOGIC; --
        o_Jr : OUT STD_LOGIC; --
        o_Jal : OUT STD_LOGIC; --
        o_RegWrite : OUT STD_LOGIC; --
        o_shiftSel : OUT STD_LOGIC
    );
    END COMPONENT;

BEGIN
    -- Instantiate the control module
    dut : control
    PORT MAP(
        i_Op => s_iOp,
        i_Funct => s_iFunct,
        o_RegDst => s_oRegDst,
        o_J => s_oJ,
        o_Branch => s_oBranch,
        o_AxMOut => s_oAxMOut,
        o_ALUOp => s_oALUOp,
        o_MemWrite => s_oMemWrite,
        o_ALUSrc => s_oALUSrc,
        o_Unsigned => s_oUnsigned,
        o_Jr => s_oJr,
        o_Jal => s_oJal,
        o_RegWrite => s_oRegWrite,
        o_shiftSel => s_shiftSel
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
        -- R-type instructions
        -- 'add' instruction
        s_iOp <= "000000";
        s_iFunct <= "100000"; -- add
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'addu' instruction
        s_iFunct <= "100001";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'sub' instruction
        s_iFunct <= "100010";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'subu' instruction
        s_iFunct <= "100011";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)
        
        -- 'and' instruction
        s_iFunct <= "100100";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'or' instruction
        s_iFunct <= "100101";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'xor' instruction
        s_iFunct <= "100110";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'nor' instruction
        s_iFunct <= "100111";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'slt' instruction
        s_iFunct <= "101010";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'sll' instruction
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'sllv' instruction
        s_iFunct <= "000100";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'srl' instruction
        s_iFunct <= "000010";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'srlv' instruction
        s_iFunct <= "000110";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'sra' instruction
        s_iFunct <= "000011";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'srav' instruction
        s_iFunct <= "000111";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- I-type instructions
        -- 'addi' instruction
        s_iOp <= "001000";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'addiu' instruction
        s_iOp <= "001001";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'andi' instruction
        s_iOp <= "001100";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'ori' instruction
        s_iOp <= "001101";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'xori' instruction
        s_iOp <= "001110";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'slti' instruction
        s_iOp <= "001010";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'lw' instruction
        s_iOp <= "100011";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'lb' instruction
        s_iOp <= "100000";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'lh' instruction
        s_iOp <= "100001";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'lbu' instruction
        s_iOp <= "100100";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'lhu' instruction 
        s_iOp <= "100101";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'lui' instruction
        s_iOp <= "001111";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'sw' instruction
        s_iOp <= "101011";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'beq' instruction
        s_iOp <= "000100";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'bne' instruction
        s_iOp <= "000101";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'j' instruction
        s_iOp <= "000010";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'jal' instruction
        s_iOp <= "000011";
        s_iFunct <= "000000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- 'jr' instruction
        s_iOp <= "000000";
        s_iFunct <= "001000";
        WAIT FOR cCLK_PER;
        -- Expected control signals: (To be filled based on instruction decoding)

        -- End of test cases
        WAIT;
    END PROCESS;

END tb_arch;