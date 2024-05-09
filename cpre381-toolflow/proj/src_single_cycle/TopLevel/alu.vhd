LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
    PORT (
        i_RSDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_RTDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        i_IMM : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        i_ALUOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        i_ALUSRC : IN STD_LOGIC;
        i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        o_RESULT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_OVERFLOW : OUT STD_LOGIC;
        o_ZERO : OUT STD_LOGIC
    );
END ALU;

ARCHITECTURE structural OF ALU IS

    COMPONENT addersubtractor_N IS
        GENERIC (
            N : INTEGER := 32
        );
        PORT (
            i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Imm : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_Ctrl : IN STD_LOGIC;
            i_ALUSrc : IN STD_LOGIC;
            o_sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_cout : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

    END COMPONENT;

    COMPONENT bit_width_extender IS
        PORT (
            signedval : IN STD_LOGIC;
            i_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    COMPONENT barrel_shifter IS
        PORT (
            i_sType : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- bit 0: if 0 - right if 1 - left  bit 1: if 0 - logical if 1 - arithmetic  bit 2: 0 - shamt  1 - reg
            i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- shift amount
            i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- rt input to shift 
            i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- register input for shift amount if the 'v' version of instruction is used
            o_Shift : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- shifted output
        );
    END COMPONENT;

    SIGNAL s_SIGNED_IMM : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_ADD_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_ADD_COUT : STD_LOGIC;

    SIGNAL s_SUB_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_SUB_COUT : STD_LOGIC;

    SIGNAL s_AND_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_OR_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_XOR_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_NOR_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_SLL_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_SRL_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_SRA_RESULT : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, s_slt, s_slti, s_SLT_RESULT, s_beq : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL s_slt_switch, T12, T13, s_ZERO : STD_LOGIC;

BEGIN
    --make extender in processor
    -- signedImm : bit_width_extender
    -- PORT MAP(
    --     signedval => i_UNSIGNED,
    --     i_in => i_IMM,
    --     o_out => s_SIGNED_IMM);

    s_SIGNED_IMM <= i_IMM;

    -- Component instantiation
    AddOps : addersubtractor_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_A => i_RSDATA,
        i_B => i_RTDATA,
        i_Imm => s_SIGNED_IMM,
        i_Ctrl => '0',
        -- i_Unsigned => i_UNSIGNED,
        i_ALUSrc => i_ALUSRC,
        o_sum => s_ADD_RESULT,
        o_cout => o_OVERFLOW
    );

    SubOps : addersubtractor_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_A => i_RSDATA,
        i_B => i_RTDATA,
        i_Imm => s_SIGNED_IMM,
        i_Ctrl => '1',
        -- i_Unsigned => i_UNSIGNED,
        i_ALUSrc => i_ALUSRC,
        o_sum => s_SUB_RESULT,
        o_cout => s_SUB_COUT
    );

    zerocheck : addersubtractor_N
    GENERIC MAP(N => 32)
    PORT MAP(
        i_A => i_RSDATA,
        i_B => i_RTDATA,
        i_Imm => s_SIGNED_IMM,
        i_Ctrl => '1',
        -- i_Unsigned => i_UNSIGNED,
        i_ALUSrc => '0',
        o_sum => s_beq,
        o_cout => OPEN
    );

    s_ZERO <= '1' WHEN s_beq = X"00000000" ELSE
        '0';
    T0 <= i_RSDATA AND i_RTDATA;
    T1 <= i_RSDATA AND s_SIGNED_IMM;
    AndOps : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => T0,
        i_D1 => T1,
        o_O => s_AND_RESULT
    );

    T2 <= i_RSDATA OR i_RTDATA;
    T3 <= i_RSDATA OR s_SIGNED_IMM;
    OrOps : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => T2,
        i_D1 => T3,
        o_O => s_OR_RESULT
    );

    T4 <= i_RSDATA XOR i_RTDATA;
    T5 <= i_RSDATA XOR s_SIGNED_IMM;
    XorOps : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => T4,
        i_D1 => T5,
        o_O => s_XOR_RESULT
    );

    s_NOR_RESULT <= i_RSDATA NOR i_RTDATA;

    -- T6 <= i_RTDATA(i_RTDATA'high - to_integer(unsigned(i_RSDATA)) DOWNTO 0) & (32 - i_RTDATA'length - to_integer(unsigned(i_RSDATA)) - 1 DOWNTO 0 => '0');
    -- T7 <= i_RTDATA(i_RTDATA'high - to_integer(unsigned(i_SHAMT)) DOWNTO 0) & (32 - i_RTDATA'length - to_integer(unsigned(i_SHAMT)) - 1 DOWNTO 0 => '0');
    SLLOps : barrel_shifter
    PORT MAP(
        i_sType => "001",
        i_shamt => i_SHAMT,
        i_Data => i_RTDATA,
        i_rs => i_RSDATA,
        o_Shift => T6
    );

    SLLVOps : barrel_shifter
    PORT MAP(
        i_sType => "101",
        i_shamt => i_SHAMT,
        i_Data => i_RTDATA,
        i_rs => i_RSDATA,
        o_Shift => T7
    );

    SLLorSLLV : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => T7,
        i_D1 => T6,
        o_O => s_SLL_RESULT
    );

    -- T8 <= ((to_integer(unsigned(i_RSDATA)) - 1 DOWNTO 0 => '0') & i_RTDATA(i_RTDATA'high DOWNTO to_integer(unsigned(i_RSDATA))));
    -- T9 <= ((to_integer(unsigned(i_SHAMT)) - 1 DOWNTO 0 => '0') & i_RTDATA(i_RTDATA'high DOWNTO to_integer(unsigned(i_SHAMT))));
    SRLOps : barrel_shifter
    PORT MAP(
        i_sType => "000",
        i_shamt => i_SHAMT,
        i_Data => i_RTDATA,
        i_rs => i_RSDATA,
        o_Shift => T8
    );

    SRLVOps : barrel_shifter
    PORT MAP(
        i_sType => "100",
        i_shamt => i_SHAMT,
        i_Data => i_RTDATA,
        i_rs => i_RSDATA,
        o_Shift => T9
    );

    SRLorSRLV : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => T9,
        i_D1 => T8,
        o_O => s_SRL_RESULT
    );

    -- T10 <= ((to_integer(unsigned(i_RSDATA)) - 1 DOWNTO 0 => i_RTDATA(31)) & i_RTDATA(i_RTDATA'high DOWNTO to_integer(unsigned(i_RSDATA))));
    -- T11 <= ((to_integer(unsigned(i_SHAMT)) - 1 DOWNTO 0 => i_RTDATA(31)) & i_RTDATA(i_RTDATA'high DOWNTO to_integer(unsigned(i_SHAMT))));
    SRAOps : barrel_shifter
    PORT MAP(
        i_sType => "010",
        i_shamt => i_SHAMT,
        i_Data => i_RTDATA,
        i_rs => i_RSDATA,
        o_Shift => T10
    );

    SRAVOps : barrel_shifter
    PORT MAP(
        i_sType => "110",
        i_shamt => i_SHAMT,
        i_Data => i_RTDATA,
        i_rs => i_RSDATA,
        o_Shift => T11
    );

    SRAorSRAV : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => T11,
        i_D1 => T10,
        o_O => s_SRA_RESULT
    );

    -- T12 <= signed(i_RSDATA) < signed(i_RTDATA);
    T12 <= '1' WHEN signed(i_RSDATA) < signed(i_RTDATA) ELSE
        '0';

    -- T13 <= signed(i_RSDATA) < signed(s_SIGNED_IMM);
    T13 <= '1' WHEN signed(i_RSDATA) < signed(s_SIGNED_IMM) ELSE
        '0';

    sltsetmux : mux2t1_N
    PORT MAP(
        i_S => T12,
        i_D0 => X"00000000",
        i_D1 => X"00000001",
        o_O => s_slt
    );

    sltisetmux : mux2t1_N
    PORT MAP(
        i_S => T13,
        i_D0 => X"00000000",
        i_D1 => X"00000001",
        o_O => s_slti
    );

    sltmux : mux2t1_N
    PORT MAP(
        i_S => i_ALUSRC,
        i_D0 => s_slt,
        i_D1 => s_slti,
        o_O => s_SLT_RESULT
    );
    WITH i_ALUOP SELECT
        o_RESULT <=
        s_ADD_RESULT WHEN "0001",
        s_SUB_RESULT WHEN "0010",
        s_AND_RESULT WHEN "0011",
        s_OR_RESULT WHEN "0100",
        s_XOR_RESULT WHEN "0101",
        s_NOR_RESULT WHEN "0110",
        s_SLT_RESULT WHEN "0111",
        s_SLL_RESULT WHEN "1000",
        s_SRL_RESULT WHEN "1001",
        s_SRA_RESULT WHEN "1010",
        "00000000000000000000000000000000" WHEN OTHERS; -- Default value

    o_ZERO <= s_ZERO; -- Default value

END structural;